<?php

namespace Tests\Feature;

use App\Models\Guru;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\Nilai;
use App\Models\Penugasan;
use App\Models\PengumpulanTugas;
use App\Models\PeriodeAkademik;
use App\Models\Siswa;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SiswaNilaiPdfTest extends TestCase
{
    use RefreshDatabase;

    public function test_grade_index_only_contains_the_authenticated_students_submissions(): void
    {
        [$user, $student, $class] = $this->createStudent('nilai-owner@example.test');
        $otherStudent = $this->createStudentInClass($class, 'nilai-peer@example.test');
        $teacher = $this->createTeacher('nilai-teacher@example.test');
        $subject = $this->createSubject('MAT01', 'Matematika', 75);
        $schedule = $this->createSchedule($class, $subject, $teacher);

        $gradedTask = $this->createTask($schedule, $teacher, 'Persamaan Linear');
        $pendingTask = $this->createTask($schedule, $teacher, 'Latihan Aljabar');
        $gradedSubmission = $this->createSubmission($gradedTask, $student, '2026-11-23 08:30:00');
        $pendingSubmission = $this->createSubmission($pendingTask, $student, '2026-11-24 08:30:00');
        $this->createGrade($gradedSubmission, $teacher, 88.0, 'Pengerjaan baik.');

        // A second student in the same class must never contribute to this student's totals.
        $peerSubmission = $this->createSubmission($gradedTask, $otherStudent, '2026-11-23 08:35:00');
        $this->createGrade($peerSubmission, $teacher, 10.0, 'Nilai milik siswa lain.');

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/siswa/nilai');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('meta.jumlah_mapel', 1)
            ->assertJsonPath('meta.jumlah_pengumpulan', 2)
            ->assertJsonPath('meta.jumlah_dinilai', 1)
            ->assertJsonPath('data.0.mapel_id', $subject->id)
            ->assertJsonPath('data.0.jumlah_penilaian', 2)
            ->assertJsonPath('data.0.jumlah_dinilai', 1)
            ->assertJsonPath('data.0.jumlah_menunggu', 1);

        $this->assertSame(88.0, (float) $response->json('data.0.rata_rata'));
        $returnedIds = collect($response->json('data.0.hasil'))
            ->pluck('pengumpulan_id')
            ->sort()
            ->values()
            ->all();
        $this->assertSame(
            collect([$gradedSubmission->id, $pendingSubmission->id])->sort()->values()->all(),
            $returnedIds,
        );
        $this->assertNotContains($peerSubmission->id, $returnedIds);
    }

    public function test_student_can_view_subject_grades_and_calculated_completion_status(): void
    {
        [$user, $student, $class] = $this->createStudent('nilai-detail@example.test');
        $teacher = $this->createTeacher('nilai-detail-teacher@example.test');
        $subject = $this->createSubject('IPA01', 'Ilmu Pengetahuan Alam', 80);
        $schedule = $this->createSchedule($class, $subject, $teacher);
        $task = $this->createTask($schedule, $teacher, 'Ekosistem');
        $submission = $this->createSubmission($task, $student, '2026-11-23 09:00:00');
        $this->createGrade($submission, $teacher, 85.0, 'Sudah memahami materi.');

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/siswa/nilai/mapel/' . $subject->id);
        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.mapel.id', $subject->id)
            ->assertJsonPath('data.mapel.kkm', 80)
            ->assertJsonPath('data.hasil.0.judul_tugas', 'Ekosistem')
            ->assertJsonPath('data.hasil.0.status_ketuntasan', 'tuntas')
            ->assertJsonPath('data.hasil.0.catatan', 'Sudah memahami materi.');

        $this->assertSame(85.0, (float) $response->json('data.rata_rata'));
        $this->assertSame(85.0, (float) $response->json('data.hasil.0.nilai'));
    }

    public function test_student_cannot_view_or_download_grades_for_a_subject_outside_their_class(): void
    {
        [$user] = $this->createStudent('nilai-isolation@example.test');
        [, , $otherClass] = $this->createStudent('nilai-other-class@example.test');
        $teacher = $this->createTeacher('nilai-other-teacher@example.test');
        $otherSubject = $this->createSubject('FIS01', 'Fisika', 75);
        $this->createSchedule($otherClass, $otherSubject, $teacher);

        Sanctum::actingAs($user);

        $this->getJson('/api/siswa/nilai/mapel/' . $otherSubject->id)->assertNotFound();
        $this->get('/api/siswa/nilai/mapel/' . $otherSubject->id . '/pdf')->assertNotFound();
    }

    public function test_student_can_download_a_valid_subject_pdf_attachment(): void
    {
        [$user, $student, $class] = $this->createStudent('nilai-pdf-mapel@example.test');
        $teacher = $this->createTeacher('nilai-pdf-mapel-teacher@example.test');
        $subject = $this->createSubject('BHS01', 'Bahasa Indonesia', 75);
        $schedule = $this->createSchedule($class, $subject, $teacher);
        $task = $this->createTask($schedule, $teacher, 'Teks Eksplanasi');
        $submission = $this->createSubmission($task, $student, '2026-11-23 09:00:00');
        $this->createGrade($submission, $teacher, 91.5, 'Struktur tulisan sudah tepat.');

        Sanctum::actingAs($user);

        $response = $this->get('/api/siswa/nilai/mapel/' . $subject->id . '/pdf');

        $this->assertValidPdfDownload(
            $response,
            'nilai-mapel-' . $subject->id . '-siswa-' . $student->id . '.pdf',
        );
    }

    public function test_student_can_download_a_valid_recap_pdf_attachment(): void
    {
        [$user, $student, $class] = $this->createStudent('nilai-pdf-recap@example.test');
        $teacher = $this->createTeacher('nilai-pdf-recap-teacher@example.test');

        $math = $this->createSubject('MAT02', 'Matematika', 75);
        $science = $this->createSubject('IPA02', 'Ilmu Pengetahuan Alam', 78);
        $mathSchedule = $this->createSchedule($class, $math, $teacher, 'Senin');
        $scienceSchedule = $this->createSchedule($class, $science, $teacher, 'Selasa');

        $mathTask = $this->createTask($mathSchedule, $teacher, 'Aritmetika');
        $scienceTask = $this->createTask($scienceSchedule, $teacher, 'Sistem Organisasi Kehidupan');
        $mathSubmission = $this->createSubmission($mathTask, $student, '2026-11-23 09:00:00');
        $scienceSubmission = $this->createSubmission($scienceTask, $student, '2026-11-24 09:00:00');
        $this->createGrade($mathSubmission, $teacher, 90.0, 'Baik.');
        // Keep one submission ungraded to verify the recap can render pending grades.

        Sanctum::actingAs($user);

        $response = $this->get('/api/siswa/nilai/rekap/pdf');

        $this->assertValidPdfDownload(
            $response,
            'rekap-nilai-siswa-' . $student->id . '.pdf',
        );
        $this->assertNotSame($mathSubmission->id, $scienceSubmission->id);
    }

    public function test_subject_pdf_renders_an_empty_grades_state(): void
    {
        [$user, $student, $class] = $this->createStudent('nilai-empty-subject@example.test');
        $teacher = $this->createTeacher('nilai-empty-subject-teacher@example.test');
        $subject = $this->createSubject('IPS01', 'Ilmu Pengetahuan Sosial', 75);
        $this->createSchedule($class, $subject, $teacher);

        Sanctum::actingAs($user);

        $response = $this->get('/api/siswa/nilai/mapel/' . $subject->id . '/pdf');

        $this->assertValidPdfDownload(
            $response,
            'nilai-mapel-' . $subject->id . '-siswa-' . $student->id . '.pdf',
        );
    }

    public function test_recap_pdf_renders_when_the_student_has_no_subjects_or_grades(): void
    {
        [$user, $student] = $this->createStudent('nilai-empty-recap@example.test');
        Sanctum::actingAs($user);

        $response = $this->get('/api/siswa/nilai/rekap/pdf');

        $this->assertValidPdfDownload($response, 'rekap-nilai-siswa-' . $student->id . '.pdf');
    }

    public function test_teacher_cannot_access_student_grade_or_pdf_endpoints(): void
    {
        $teacherUser = $this->createUser('guru', 'nilai-denied-teacher@example.test');
        Sanctum::actingAs($teacherUser);

        $this->getJson('/api/siswa/nilai')->assertForbidden();
        $this->getJson('/api/siswa/nilai/mapel/1')->assertForbidden();
        $this->get('/api/siswa/nilai/rekap/pdf')->assertForbidden();
    }

    public function test_guest_cannot_access_student_grade_or_pdf_endpoints(): void
    {
        // Mobile API clients send Accept: application/json (ApiConfig.headers).
        // Without that header, the app's Authenticate middleware correctly
        // redirects browser-style requests to the login page (HTTP 302).
        $this->getJson('/api/siswa/nilai')->assertUnauthorized();
        $this->getJson('/api/siswa/nilai/rekap/pdf')->assertUnauthorized();
        $this->getJson('/api/siswa/nilai/mapel/1/pdf')->assertUnauthorized();
    }

    private function assertValidPdfDownload($response, string $filename): void
    {
        $response->assertOk();
        $this->assertSame('application/pdf', $response->headers->get('Content-Type'));
        $this->assertStringContainsString(
            'attachment; filename=' . $filename,
            (string) $response->headers->get('Content-Disposition'),
        );
        $content = $response->getContent();
        $this->assertIsString($content);
        $this->assertStringStartsWith('%PDF-', $content);
        $this->assertGreaterThan(500, strlen($content));
        $this->assertSame((string) strlen($content), (string) $response->headers->get('Content-Length'));
    }

    /** @return array{0: User, 1: Siswa, 2: Kelas} */
    private function createStudent(string $email): array
    {
        $user = $this->createUser('siswa', $email);
        $class = Kelas::create([
            'nama_kelas' => 'VII A ' . $user->id,
            'tingkat' => 7,
            'kapasitas' => 30,
        ]);

        return [$user, $this->createStudentProfile($user, $class), $class];
    }

    private function createStudentInClass(Kelas $class, string $email): Siswa
    {
        $user = $this->createUser('siswa', $email);

        return $this->createStudentProfile($user, $class);
    }

    private function createStudentProfile(User $user, Kelas $class): Siswa
    {
        return Siswa::create([
            'user_id' => $user->id,
            'nis' => 'NIS-' . $user->id,
            'nisn' => 'NISN-' . $user->id,
            'nama_lengkap' => 'Siswa ' . $user->id,
            'jenis_kelamin' => 'L',
            'tanggal_lahir' => '2010-01-01',
            'tempat_lahir' => 'Nganjuk',
            'kelas_id' => $class->id,
        ]);
    }

    private function createUser(string $role, string $email): User
    {
        return User::create([
            'name' => ucfirst($role) . ' ' . $email,
            'email' => $email,
            'password' => 'password-test',
            'role' => $role,
            'is_active' => true,
            'must_change_password' => false,
        ]);
    }

    private function createTeacher(string $email): Guru
    {
        $user = $this->createUser('guru', $email);

        return Guru::create([
            'user_id' => $user->id,
            'nip' => 'NIP-' . $user->id,
            'nama_lengkap' => 'Guru ' . $user->id,
            'jenis_kelamin' => 'L',
        ]);
    }

    private function createSubject(string $code, string $name, int $kkm): MataPelajaran
    {
        return MataPelajaran::create([
            'kode' => $code,
            'nama' => $name,
            'kkm' => $kkm,
        ]);
    }

    private function createSchedule(
        Kelas $class,
        MataPelajaran $subject,
        Guru $teacher,
        string $day = 'Senin',
    ): JadwalPelajaran {
        $period = PeriodeAkademik::firstOrCreate(
            ['nama' => 'Semester Ganjil 2026/2027'],
            [
                'tahun_ajaran' => '2026/2027',
                'semester' => 'ganjil',
                'tanggal_mulai' => '2026-07-13',
                'tanggal_selesai' => '2026-12-19',
                'is_active' => true,
            ],
        );

        return JadwalPelajaran::create([
            'periode_id' => $period->id,
            'kelas_id' => $class->id,
            'mapel_id' => $subject->id,
            'guru_id' => $teacher->id,
            'hari' => $day,
            'jam_mulai' => '08:00:00',
            'jam_selesai' => '08:40:00',
            'ruangan' => 'Ruang 1',
        ]);
    }

    private function createTask(JadwalPelajaran $schedule, Guru $teacher, string $title): Penugasan
    {
        return Penugasan::create([
            'jadwal_id' => $schedule->id,
            'guru_id' => $teacher->id,
            'judul' => $title,
            'deskripsi' => 'Materi pengujian ' . $title,
            'jenis' => 'tugas',
            'deadline' => '2026-12-01 23:59:00',
            'bobot' => 100,
        ]);
    }

    private function createSubmission(Penugasan $task, Siswa $student, string $submittedAt): PengumpulanTugas
    {
        return PengumpulanTugas::create([
            'penugasan_id' => $task->id,
            'siswa_id' => $student->id,
            'jawaban' => 'Jawaban untuk ' . $task->judul,
            'file_jawaban' => null,
            'waktu_pengumpulan' => $submittedAt,
            'status' => 'tepat_waktu',
        ]);
    }

    private function createGrade(
        PengumpulanTugas $submission,
        Guru $teacher,
        float $score,
        string $feedback,
    ): Nilai {
        return Nilai::create([
            'pengumpulan_id' => $submission->id,
            'guru_id' => $teacher->id,
            'nilai' => $score,
            'catatan' => $feedback,
            'tanggal_penilaian' => '2026-11-25 10:00:00',
        ]);
    }
}
