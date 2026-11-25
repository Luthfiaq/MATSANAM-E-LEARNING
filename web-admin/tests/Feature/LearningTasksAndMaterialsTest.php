<?php

namespace Tests\Feature;

use App\Models\Guru;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\Materi;
use App\Models\MataPelajaran;
use App\Models\Nilai;
use App\Models\Penugasan;
use App\Models\PenugasanFile;
use App\Models\PengumpulanTugas;
use App\Models\PengumpulanTugasFile;
use App\Models\PeriodeAkademik;
use App\Models\Siswa;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class LearningTasksAndMaterialsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Notification::fake();
        Storage::fake('public');
        Storage::fake('local');
    }

    public function test_student_material_list_is_limited_to_their_class_and_supports_search(): void
    {
        [$studentUser, $student, $class] = $this->createStudent('materials-owner@example.test');
        $teacher = $this->createTeacher('materials-teacher@example.test');
        $ownSchedule = $this->createSchedule($class, $teacher, 'MAT-OWN', 'Matematika');

        [, , $otherClass] = $this->createStudent('materials-other@example.test');
        $otherTeacher = $this->createTeacher('materials-other-teacher@example.test');
        $otherSchedule = $this->createSchedule($otherClass, $otherTeacher, 'IPA-OTHER', 'IPA');

        $ownMaterial = $this->createMaterial($ownSchedule, $teacher, 'Aljabar Dasar');
        $this->createMaterial($otherSchedule, $otherTeacher, 'Aljabar Rahasia');
        $this->createMaterial($ownSchedule, $teacher, 'Sistem Persamaan');

        Sanctum::actingAs($studentUser);

        $response = $this->getJson('/api/siswa/materi?q=Aljabar');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $ownMaterial->id)
            ->assertJsonPath('data.0.judul', 'Aljabar Dasar');
    }

    public function test_student_cannot_view_or_download_material_from_another_class(): void
    {
        [$studentUser] = $this->createStudent('materials-private-owner@example.test');
        [, , $otherClass] = $this->createStudent('materials-private-other@example.test');
        $teacher = $this->createTeacher('materials-private-teacher@example.test');
        $schedule = $this->createSchedule($otherClass, $teacher, 'MAT-PRIVATE', 'Matematika');
        $path = 'materi/private/other-class.pdf';
        Storage::disk('public')->put($path, '%PDF-1.4 private material');
        $material = $this->createMaterial($schedule, $teacher, 'Materi Privat', 'pdf', $path);

        Sanctum::actingAs($studentUser);

        $this->getJson('/api/siswa/materi/' . $material->id)->assertNotFound();
        $this->get('/api/siswa/materi/' . $material->id . '/file')->assertNotFound();
    }

    public function test_teacher_can_publish_link_material_for_a_schedule_they_teach(): void
    {
        $teacherUser = $this->createUser('guru', 'materials-publish@example.test');
        $teacher = $this->createTeacherProfile($teacherUser);
        $class = $this->createClass('VII Materi', 7);
        $schedule = $this->createSchedule($class, $teacher, 'MAT-LINK', 'Matematika');
        Sanctum::actingAs($teacherUser);

        $response = $this->postJson('/api/guru/materi', [
            'jadwal_id' => $schedule->id,
            'judul' => 'Video Persamaan Linear',
            'deskripsi' => 'Materi pengayaan berbentuk tautan.',
            'tipe' => 'link',
            'link' => 'https://example.test/persamaan-linear',
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.tipe', 'link')
            ->assertJsonPath('data.link', 'https://example.test/persamaan-linear');

        $this->assertDatabaseHas('materi', [
            'jadwal_id' => $schedule->id,
            'guru_id' => $teacher->id,
            'judul' => 'Video Persamaan Linear',
            'tipe' => 'link',
            'file_path' => null,
        ]);
    }

    public function test_teacher_cannot_publish_material_to_another_teachers_schedule(): void
    {
        $teacherUser = $this->createUser('guru', 'materials-scope-owner@example.test');
        $this->createTeacherProfile($teacherUser);
        $otherTeacher = $this->createTeacher('materials-scope-other@example.test');
        $class = $this->createClass('VII Materi B', 7);
        $foreignSchedule = $this->createSchedule($class, $otherTeacher, 'MAT-FOREIGN', 'Matematika');
        Sanctum::actingAs($teacherUser);

        $this->postJson('/api/guru/materi', [
            'jadwal_id' => $foreignSchedule->id,
            'judul' => 'Materi Tidak Sah',
            'deskripsi' => 'Uji pembatasan jadwal.',
            'tipe' => 'link',
            'link' => 'https://example.test/material',
        ])->assertForbidden();

        $this->assertDatabaseMissing('materi', ['judul' => 'Materi Tidak Sah']);
    }

    public function test_material_link_must_use_http_or_https(): void
    {
        $teacherUser = $this->createUser('guru', 'materials-scheme@example.test');
        $teacher = $this->createTeacherProfile($teacherUser);
        $class = $this->createClass('VII Materi C', 7);
        $schedule = $this->createSchedule($class, $teacher, 'MAT-SCHEME', 'Matematika');
        Sanctum::actingAs($teacherUser);

        $this->postJson('/api/guru/materi', [
            'jadwal_id' => $schedule->id,
            'judul' => 'Tautan dengan skema tidak didukung',
            'deskripsi' => 'Uji validasi skema URL.',
            'tipe' => 'link',
            'link' => 'ftp://example.test/material.pdf',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('link');

        $this->assertDatabaseMissing('materi', ['judul' => 'Tautan dengan skema tidak didukung']);
    }

    public function test_teacher_can_upload_pdf_material_and_invalid_file_type_is_rejected(): void
    {
        $teacherUser = $this->createUser('guru', 'materials-pdf@example.test');
        $teacher = $this->createTeacherProfile($teacherUser);
        $class = $this->createClass('VII Materi D', 7);
        $schedule = $this->createSchedule($class, $teacher, 'MAT-PDF', 'Matematika');
        Sanctum::actingAs($teacherUser);

        $response = $this->post('/api/guru/materi', [
            'jadwal_id' => $schedule->id,
            'judul' => 'Ringkasan Bab Bilangan',
            'deskripsi' => 'File PDF untuk siswa.',
            'tipe' => 'pdf',
            'file' => UploadedFile::fake()->create('ringkasan.pdf', 12, 'application/pdf'),
        ], ['Accept' => 'application/json']);

        $response->assertCreated();
        $material = Materi::where('judul', 'Ringkasan Bab Bilangan')->firstOrFail();
        $this->assertNotEmpty($material->file_path);
        Storage::disk('public')->assertExists($material->file_path);

        $this->post('/api/guru/materi', [
            'jadwal_id' => $schedule->id,
            'judul' => 'PDF dengan file gambar',
            'deskripsi' => 'File type mismatch.',
            'tipe' => 'pdf',
            'file' => UploadedFile::fake()->create('bukan-pdf.txt', 2, 'text/plain'),
        ], ['Accept' => 'application/json'])->assertUnprocessable();

        $this->assertDatabaseMissing('materi', ['judul' => 'PDF dengan file gambar']);
    }

    public function test_teacher_cannot_update_or_delete_material_owned_by_another_teacher(): void
    {
        $actingUser = $this->createUser('guru', 'materials-edit-actor@example.test');
        $this->createTeacherProfile($actingUser);
        $owner = $this->createTeacher('materials-edit-owner@example.test');
        $class = $this->createClass('VII Materi E', 7);
        $schedule = $this->createSchedule($class, $owner, 'MAT-EDIT', 'Matematika');
        $material = $this->createMaterial($schedule, $owner, 'Materi Milik Guru Lain', 'link', null, 'https://example.test/old');
        Sanctum::actingAs($actingUser);

        $this->putJson('/api/guru/materi/' . $material->id, [
            'judul' => 'Materi Diambil Alih',
        ])->assertNotFound();
        $this->deleteJson('/api/guru/materi/' . $material->id)->assertNotFound();

        $this->assertDatabaseHas('materi', [
            'id' => $material->id,
            'judul' => 'Materi Milik Guru Lain',
        ]);
    }

    public function test_student_task_list_contains_only_tasks_for_their_class(): void
    {
        [$studentUser, , $class] = $this->createStudent('tasks-list-owner@example.test');
        $teacher = $this->createTeacher('tasks-list-teacher@example.test');
        $ownSchedule = $this->createSchedule($class, $teacher, 'TUGAS-OWN', 'Matematika');
        $ownTask = $this->createTask($ownSchedule, $teacher, 'Latihan Pecahan');

        [, , $otherClass] = $this->createStudent('tasks-list-other@example.test');
        $otherTeacher = $this->createTeacher('tasks-list-other-teacher@example.test');
        $otherSchedule = $this->createSchedule($otherClass, $otherTeacher, 'TUGAS-OTHER', 'IPA');
        $this->createTask($otherSchedule, $otherTeacher, 'Tugas kelas lain');

        Sanctum::actingAs($studentUser);
        $response = $this->getJson('/api/siswa/tugas');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $ownTask->id)
            ->assertJsonPath('data.0.status', 'belum_dikumpulkan');
    }

    public function test_student_cannot_view_or_download_task_from_another_class(): void
    {
        [$studentUser] = $this->createStudent('tasks-private-owner@example.test');
        [, , $otherClass] = $this->createStudent('tasks-private-other@example.test');
        $teacher = $this->createTeacher('tasks-private-teacher@example.test');
        $schedule = $this->createSchedule($otherClass, $teacher, 'TUGAS-PRIVATE', 'IPA');
        $task = $this->createTask($schedule, $teacher, 'Tugas Rahasia');
        $path = 'tugas/private/other-class.pdf';
        Storage::disk('public')->put($path, '%PDF-1.4 private task');
        $task->update(['file_materi' => $path]);

        Sanctum::actingAs($studentUser);
        $this->getJson('/api/siswa/tugas/' . $task->id)->assertNotFound();
        $this->get('/api/siswa/tugas/' . $task->id . '/file')->assertNotFound();
    }

    public function test_student_can_submit_multiple_files_and_retry_same_batch_without_duplicates(): void
    {
        [$studentUser, $student, $class] = $this->createStudent('tasks-multifile@example.test');
        $teacher = $this->createTeacher('tasks-multifile-teacher@example.test');
        $schedule = $this->createSchedule($class, $teacher, 'TUGAS-MULTI', 'Bahasa Indonesia');
        $task = $this->createTask($schedule, $teacher, 'Menulis Teks Eksplanasi');
        Sanctum::actingAs($studentUser);

        $batchId = 'student-batch-20261125-001';
        $firstRequest = [
            'jawaban' => 'Terlampir dua dokumen tugas.',
            'upload_batch_id' => $batchId,
            'files' => [
                UploadedFile::fake()->create('jawaban.pdf', 20, 'application/pdf'),
                UploadedFile::fake()->create('referensi.txt', 2, 'text/plain'),
            ],
        ];

        $first = $this->post('/api/siswa/tugas/' . $task->id . '/kumpulkan', $firstRequest, [
            'Accept' => 'application/json',
        ]);
        $first->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(2, 'data.files');

        $submission = PengumpulanTugas::where('penugasan_id', $task->id)
            ->where('siswa_id', $student->id)
            ->firstOrFail();
        $this->assertDatabaseCount('pengumpulan_tugas_files', 2);
        $this->assertNotEmpty($submission->last_upload_batch_id);
        foreach ($submission->files as $file) {
            Storage::disk('local')->assertExists($file->file_path);
        }

        $retry = $this->post('/api/siswa/tugas/' . $task->id . '/kumpulkan', [
            'jawaban' => 'Terlampir dua dokumen tugas.',
            'upload_batch_id' => $batchId,
            'files' => [
                UploadedFile::fake()->create('jawaban.pdf', 20, 'application/pdf'),
                UploadedFile::fake()->create('referensi.txt', 2, 'text/plain'),
            ],
        ], ['Accept' => 'application/json']);

        $retry->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id', $submission->id);
        $this->assertDatabaseCount('pengumpulan_tugas', 1);
        $this->assertDatabaseCount('pengumpulan_tugas_files', 2);
    }

    public function test_student_must_provide_answer_or_at_least_one_file_to_submit(): void
    {
        [$studentUser, , $class] = $this->createStudent('tasks-empty-submit@example.test');
        $teacher = $this->createTeacher('tasks-empty-teacher@example.test');
        $schedule = $this->createSchedule($class, $teacher, 'TUGAS-EMPTY', 'Matematika');
        $task = $this->createTask($schedule, $teacher, 'Tugas Wajib Jawaban');
        Sanctum::actingAs($studentUser);

        $this->postJson('/api/siswa/tugas/' . $task->id . '/kumpulkan', [
            'jawaban' => '   ',
        ])->assertUnprocessable();

        $this->assertDatabaseMissing('pengumpulan_tugas', ['penugasan_id' => $task->id]);
    }

    public function test_student_cannot_resubmit_task_after_teacher_has_graded_it(): void
    {
        [$studentUser, $student, $class] = $this->createStudent('tasks-graded-owner@example.test');
        $teacher = $this->createTeacher('tasks-graded-teacher@example.test');
        $schedule = $this->createSchedule($class, $teacher, 'TUGAS-GRADED', 'Matematika');
        $task = $this->createTask($schedule, $teacher, 'Tugas Sudah Dinilai');
        $submission = PengumpulanTugas::create([
            'penugasan_id' => $task->id,
            'siswa_id' => $student->id,
            'jawaban' => 'Jawaban awal.',
            'waktu_pengumpulan' => now()->subHour(),
            'status' => 'tepat_waktu',
        ]);
        Nilai::create([
            'pengumpulan_id' => $submission->id,
            'guru_id' => $teacher->id,
            'nilai' => 85,
            'catatan' => 'Baik.',
            'tanggal_penilaian' => now(),
        ]);
        Sanctum::actingAs($studentUser);

        $this->postJson('/api/siswa/tugas/' . $task->id . '/kumpulkan', [
            'jawaban' => 'Mencoba mengganti setelah dinilai.',
        ])->assertStatus(409);

        $this->assertSame('Jawaban awal.', $submission->fresh()->jawaban);
    }

    public function test_teacher_can_create_task_with_multiple_files_and_idempotent_request_key(): void
    {
        $teacherUser = $this->createUser('guru', 'tasks-create-owner@example.test');
        $teacher = $this->createTeacherProfile($teacherUser);
        $class = $this->createClass('VII Tugas Baru', 7);
        $schedule = $this->createSchedule($class, $teacher, 'TUGAS-CREATE', 'Matematika');
        Sanctum::actingAs($teacherUser);

        $request = [
            'jadwal_id' => $schedule->id,
            'judul' => 'Latihan Operasi Bilangan',
            'deskripsi' => 'Kerjakan soal pada lampiran.',
            'jenis' => 'tugas',
            'deadline' => now()->addDays(4)->toDateTimeString(),
            'bobot' => 100,
            'client_request_id' => 'teacher-task-request-001',
            'files' => [UploadedFile::fake()->create('soal.pdf', 15, 'application/pdf')],
        ];

        $first = $this->post('/api/guru/tugas', $request, ['Accept' => 'application/json']);
        $first->assertCreated()->assertJsonPath('success', true);
        $taskId = $first->json('data.id');
        $this->assertDatabaseCount('penugasan', 1);
        $this->assertDatabaseCount('penugasan_files', 1);

        $retry = $this->post('/api/guru/tugas', [
            'jadwal_id' => $schedule->id,
            'judul' => 'Latihan Operasi Bilangan',
            'deskripsi' => 'Kerjakan soal pada lampiran.',
            'jenis' => 'tugas',
            'deadline' => now()->addDays(4)->toDateTimeString(),
            'bobot' => 100,
            'client_request_id' => 'teacher-task-request-001',
            'files' => [UploadedFile::fake()->create('soal-duplikat.pdf', 15, 'application/pdf')],
        ], ['Accept' => 'application/json']);

        $retry->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id', $taskId);
        $this->assertDatabaseCount('penugasan', 1);
        $this->assertDatabaseCount('penugasan_files', 1);
    }

    public function test_teacher_cannot_create_task_for_another_teachers_schedule(): void
    {
        $teacherUser = $this->createUser('guru', 'tasks-create-scope-owner@example.test');
        $this->createTeacherProfile($teacherUser);
        $otherTeacher = $this->createTeacher('tasks-create-scope-other@example.test');
        $class = $this->createClass('VII Tugas Asing', 7);
        $schedule = $this->createSchedule($class, $otherTeacher, 'TUGAS-FOREIGN', 'IPA');
        Sanctum::actingAs($teacherUser);

        $this->postJson('/api/guru/tugas', [
            'jadwal_id' => $schedule->id,
            'judul' => 'Tugas Bukan Kelas Saya',
            'deskripsi' => 'Tidak boleh dibuat oleh guru lain.',
            'jenis' => 'tugas',
            'deadline' => now()->addDays(3)->toDateTimeString(),
            'bobot' => 100,
        ])->assertForbidden();

        $this->assertDatabaseMissing('penugasan', ['judul' => 'Tugas Bukan Kelas Saya']);
    }

    public function test_teacher_cannot_update_or_delete_task_owned_by_another_teacher(): void
    {
        $actingUser = $this->createUser('guru', 'tasks-edit-actor@example.test');
        $this->createTeacherProfile($actingUser);
        $owner = $this->createTeacher('tasks-edit-owner@example.test');
        $class = $this->createClass('VII Tugas Pemilik', 7);
        $schedule = $this->createSchedule($class, $owner, 'TUGAS-EDIT', 'IPA');
        $task = $this->createTask($schedule, $owner, 'Tugas Guru Pemilik');
        Sanctum::actingAs($actingUser);

        $this->putJson('/api/guru/tugas/' . $task->id, [
            'judul' => 'Tugas Diubah Guru Lain',
        ])->assertNotFound();
        $this->deleteJson('/api/guru/tugas/' . $task->id)->assertNotFound();

        $this->assertDatabaseHas('penugasan', [
            'id' => $task->id,
            'judul' => 'Tugas Guru Pemilik',
        ]);
    }

    public function test_teacher_submission_roster_only_contains_students_from_the_task_class(): void
    {
        $teacherUser = $this->createUser('guru', 'tasks-roster-teacher@example.test');
        $teacher = $this->createTeacherProfile($teacherUser);
        $class = $this->createClass('VII Tugas Roster', 7);
        $schedule = $this->createSchedule($class, $teacher, 'TUGAS-ROSTER', 'Bahasa Indonesia');
        $task = $this->createTask($schedule, $teacher, 'Tugas Roster Kelas');
        [, $ownStudent] = $this->createStudent('tasks-roster-own@example.test', $class);

        [, $otherStudent, $otherClass] = $this->createStudent('tasks-roster-other@example.test');
        PengumpulanTugas::create([
            'penugasan_id' => $task->id,
            'siswa_id' => $ownStudent->id,
            'jawaban' => 'Jawaban siswa kelas tugas.',
            'waktu_pengumpulan' => now()->subMinutes(15),
            'status' => 'tepat_waktu',
        ]);
        $foreignSubmission = PengumpulanTugas::create([
            'penugasan_id' => $task->id,
            'siswa_id' => $otherStudent->id,
            'jawaban' => 'Data lintas kelas yang tidak boleh tampil.',
            'waktu_pengumpulan' => now()->subMinutes(10),
            'status' => 'tepat_waktu',
        ]);
        Sanctum::actingAs($teacherUser);

        $response = $this->getJson('/api/guru/tugas/' . $task->id . '/submission');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('meta.total_siswa', 1)
            ->assertJsonPath('meta.total_mengumpulkan', 1)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.siswa_id', $ownStudent->id);
        $this->assertNotSame($ownStudent->id, $otherStudent->id);
        $this->assertDatabaseHas('pengumpulan_tugas', ['id' => $foreignSubmission->id]);
    }

    public function test_role_boundaries_and_guest_access_are_enforced_for_learning_endpoints(): void
    {
        $teacherUser = $this->createUser('guru', 'learning-boundary-teacher@example.test');
        $this->createTeacherProfile($teacherUser);
        [$studentUser] = $this->createStudent('learning-boundary-student@example.test');

        $this->getJson('/api/siswa/materi')->assertUnauthorized();
        $this->getJson('/api/guru/tugas')->assertUnauthorized();

        Sanctum::actingAs($teacherUser);
        $this->getJson('/api/siswa/materi')->assertForbidden();
        $this->getJson('/api/siswa/tugas')->assertForbidden();

        Sanctum::actingAs($studentUser);
        $this->getJson('/api/guru/materi')->assertForbidden();
        $this->getJson('/api/guru/tugas')->assertForbidden();
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
        return $this->createTeacherProfile($this->createUser('guru', $email));
    }

    private function createTeacherProfile(User $user): Guru
    {
        return Guru::create([
            'user_id' => $user->id,
            'nip' => 'NIP-' . $user->id,
            'nama_lengkap' => 'Guru ' . $user->id,
            'jenis_kelamin' => 'L',
        ]);
    }

    private function createClass(string $name, int $level): Kelas
    {
        return Kelas::create([
            'nama_kelas' => $name,
            'tingkat' => $level,
            'kapasitas' => 30,
        ]);
    }

    /** @return array{0: User, 1: Siswa, 2: Kelas} */
    private function createStudent(string $email, ?Kelas $class = null): array
    {
        $user = $this->createUser('siswa', $email);
        $class ??= $this->createClass('VII ' . $user->id, 7);
        $student = Siswa::create([
            'user_id' => $user->id,
            'nis' => 'NIS-' . $user->id,
            'nisn' => 'NISN-' . $user->id,
            'nama_lengkap' => 'Siswa ' . $user->id,
            'jenis_kelamin' => 'L',
            'tanggal_lahir' => '2010-01-01',
            'tempat_lahir' => 'Nganjuk',
            'kelas_id' => $class->id,
        ]);

        return [$user, $student, $class];
    }

    private function createSchedule(
        Kelas $class,
        Guru $teacher,
        string $subjectCode,
        string $subjectName,
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
        $subject = MataPelajaran::create([
            'kode' => $subjectCode,
            'nama' => $subjectName,
            'kkm' => 75,
        ]);

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

    private function createMaterial(
        JadwalPelajaran $schedule,
        Guru $teacher,
        string $title,
        string $type = 'link',
        ?string $filePath = null,
        ?string $link = null,
    ): Materi {
        return Materi::create([
            'jadwal_id' => $schedule->id,
            'guru_id' => $teacher->id,
            'judul' => $title,
            'deskripsi' => 'Deskripsi ' . $title,
            'tipe' => $type,
            'file_path' => $filePath,
            'link' => $link,
        ]);
    }

    private function createTask(JadwalPelajaran $schedule, Guru $teacher, string $title): Penugasan
    {
        return Penugasan::create([
            'jadwal_id' => $schedule->id,
            'guru_id' => $teacher->id,
            'judul' => $title,
            'deskripsi' => 'Deskripsi ' . $title,
            'jenis' => 'tugas',
            'deadline' => now()->addDays(5),
            'bobot' => 100,
        ]);
    }
}
