<?php

namespace Tests\Feature;

use App\Models\AbsensiHarian;
use App\Models\Guru;
use App\Models\JadwalPelajaran;
use App\Models\Kelas;
use App\Models\MataPelajaran;
use App\Models\Penugasan;
use App\Models\PengumpulanTugas;
use App\Models\PeriodeAkademik;
use App\Models\Siswa;
use App\Models\SuratAbsensi;
use App\Models\User;
use App\Services\SuratAbsensiApprovalService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SiswaAbsensiAndPrivacyTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Notification::fake();
    }

    public function test_student_can_submit_full_day_leave_with_default_scope(): void
    {
        [$user, $student] = $this->createStudent('student-one@example.test');
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/siswa/pengajuan-izin', [
            'jenis_izin' => 'izin',
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-24',
            'keterangan' => 'Keperluan keluarga.',
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.siswa_id', $student->id)
            ->assertJsonPath('data.cakupan', 'sehari_penuh')
            ->assertJsonPath('data.status_verifikasi', 'pending');

        $this->assertDatabaseHas('surat_absensi', [
            'siswa_id' => $student->id,
            'jenis' => 'izin',
            'cakupan' => 'sehari_penuh',
            'jadwal_acuan_id' => null,
            'status_verifikasi' => 'pending',
        ]);
    }

    public function test_guru_cannot_submit_a_student_leave_request(): void
    {
        $guruUser = $this->createUser('guru', 'teacher@example.test');
        Sanctum::actingAs($guruUser);

        $this->postJson('/api/siswa/pengajuan-izin', [
            'jenis_izin' => 'sakit',
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-23',
            'keterangan' => 'Tidak masuk.',
        ])->assertForbidden();
    }

    public function test_partial_leave_rejects_a_schedule_from_another_class(): void
    {
        [$studentUser, $student] = $this->createStudent('partial-student@example.test');
        $otherClass = $this->createClass('VII B', 7);
        $schedule = $this->createSchedule(
            $otherClass->id,
            'Senin',
            '08:00:00',
            '08:40:00',
            '2026-11-23',
            '2026-11-27',
        );
        Sanctum::actingAs($studentUser);

        $this->postJson('/api/siswa/pengajuan-izin', [
            'jenis_izin' => 'sakit',
            'cakupan' => 'pulang_lebih_awal',
            'jadwal_acuan_id' => $schedule->id,
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-24',
            'keterangan' => 'Sakit dan harus pulang.',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('jadwal_acuan_id');

        $this->assertDatabaseMissing('surat_absensi', [
            'siswa_id' => $student->id,
            'tanggal_mulai' => '2026-11-23',
        ]);
    }

    public function test_partial_leave_rejects_a_reference_lesson_already_marked_present(): void
    {
        [$studentUser, $student] = $this->createStudent('present-student@example.test');
        $schedule = $this->createSchedule(
            $student->kelas_id,
            'Senin',
            '08:00:00',
            '08:40:00',
            '2026-11-23',
            '2026-11-27',
        );
        AbsensiHarian::create([
            'siswa_id' => $student->id,
            'jadwal_id' => $schedule->id,
            'tanggal' => '2026-11-23',
            'status' => 'hadir',
            'metode' => 'qr',
        ]);
        Sanctum::actingAs($studentUser);

        $this->postJson('/api/siswa/pengajuan-izin', [
            'jenis_izin' => 'izin',
            'cakupan' => 'pulang_lebih_awal',
            'jadwal_acuan_id' => $schedule->id,
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-24',
            'keterangan' => 'Ada keperluan mendadak.',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('jadwal_acuan_id');

        $this->assertDatabaseMissing('surat_absensi', [
            'siswa_id' => $student->id,
            'cakupan' => 'pulang_lebih_awal',
        ]);
    }

    public function test_student_can_submit_partial_leave_with_a_valid_class_schedule(): void
    {
        [$studentUser, $student] = $this->createStudent('partial-valid@example.test');
        $schedule = $this->createSchedule(
            $student->kelas_id,
            'Senin',
            '08:00:00',
            '08:40:00',
            '2026-11-23',
            '2026-11-27',
        );
        Sanctum::actingAs($studentUser);

        $response = $this->postJson('/api/siswa/pengajuan-izin', [
            'jenis_izin' => 'sakit',
            'cakupan' => 'pulang_lebih_awal',
            'jadwal_acuan_id' => $schedule->id,
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-24',
            'keterangan' => 'Kondisi kesehatan.',
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.siswa_id', $student->id)
            ->assertJsonPath('data.cakupan', 'pulang_lebih_awal')
            ->assertJsonPath('data.jadwal_acuan_id', $schedule->id);

        $this->assertDatabaseHas('surat_absensi', [
            'siswa_id' => $student->id,
            'cakupan' => 'pulang_lebih_awal',
            'jadwal_acuan_id' => $schedule->id,
            'status_verifikasi' => 'pending',
        ]);
    }

    public function test_partial_approval_starts_at_reference_lesson_then_covers_following_days_and_preserves_present_rows(): void
    {
        [, $student] = $this->createStudent('approval-partial@example.test');
        $verifier = $this->createUser('guru', 'verifier-partial@example.test');

        $mondayBefore = $this->createSchedule($student->kelas_id, 'Senin', '07:00:00', '07:40:00', '2026-11-23', '2026-11-27');
        $mondayReference = $this->createSchedule($student->kelas_id, 'Senin', '08:00:00', '08:40:00', '2026-11-23', '2026-11-27');
        $mondayAfter = $this->createSchedule($student->kelas_id, 'Senin', '09:00:00', '09:40:00', '2026-11-23', '2026-11-27');
        $tuesdayFirst = $this->createSchedule($student->kelas_id, 'Selasa', '07:00:00', '07:40:00', '2026-11-23', '2026-11-27');
        $tuesdaySecond = $this->createSchedule($student->kelas_id, 'Selasa', '08:00:00', '08:40:00', '2026-11-23', '2026-11-27');
        $tuesdayThird = $this->createSchedule($student->kelas_id, 'Selasa', '09:00:00', '09:40:00', '2026-11-23', '2026-11-27');

        $before = $this->createAttendance($student->id, $mondayBefore->id, '2026-11-23', 'hadir');
        $reference = $this->createAttendance($student->id, $mondayReference->id, '2026-11-23', 'alpa');
        $tuesdayPresent = $this->createAttendance($student->id, $tuesdayFirst->id, '2026-11-24', 'hadir');

        $letter = SuratAbsensi::create([
            'siswa_id' => $student->id,
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-24',
            'jenis' => 'izin',
            'cakupan' => 'pulang_lebih_awal',
            'jadwal_acuan_id' => $mondayReference->id,
            'alasan' => 'Pulang lebih awal.',
            'status_verifikasi' => 'pending',
        ]);

        $updated = app(SuratAbsensiApprovalService::class)->approve($letter, (int) $verifier->id);

        $this->assertSame(4, $updated);
        $this->assertSame('hadir', $before->fresh()->status);
        $this->assertNull($before->fresh()->surat_absensi_id);
        $this->assertSame('izin', $reference->fresh()->status);
        $this->assertSame($letter->id, $reference->fresh()->surat_absensi_id);
        $this->assertSame('hadir', $tuesdayPresent->fresh()->status);

        foreach ([[$mondayAfter, '2026-11-23'], [$tuesdaySecond, '2026-11-24'], [$tuesdayThird, '2026-11-24']] as [$schedule, $date]) {
            // The date column may be serialized with a midnight time component
            // by SQLite/Eloquent. Compare by calendar date, not raw storage text.
            $this->assertTrue(
                AbsensiHarian::query()
                    ->where('siswa_id', $student->id)
                    ->where('jadwal_id', $schedule->id)
                    ->whereDate('tanggal', $date)
                    ->where('status', 'izin')
                    ->where('surat_absensi_id', $letter->id)
                    ->exists(),
                sprintf('Expected schedule %d on %s to be marked izin for letter %d.', $schedule->id, $date, $letter->id),
            );
        }

        $this->assertSame('disetujui', $letter->fresh()->status_verifikasi);
    }

    public function test_full_day_approval_covers_each_scheduled_lesson_without_downgrading_hadir(): void
    {
        [, $student] = $this->createStudent('approval-full@example.test');
        $verifier = $this->createUser('guru', 'verifier-full@example.test');
        $first = $this->createSchedule($student->kelas_id, 'Senin', '07:00:00', '07:40:00', '2026-11-23', '2026-11-27');
        $second = $this->createSchedule($student->kelas_id, 'Senin', '08:00:00', '08:40:00', '2026-11-23', '2026-11-27');
        $present = $this->createAttendance($student->id, $first->id, '2026-11-23', 'hadir');
        $alpa = $this->createAttendance($student->id, $second->id, '2026-11-23', 'alpa');

        $letter = SuratAbsensi::create([
            'siswa_id' => $student->id,
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-23',
            'jenis' => 'sakit',
            'cakupan' => 'sehari_penuh',
            'alasan' => 'Sakit.',
            'status_verifikasi' => 'pending',
        ]);

        $updated = app(SuratAbsensiApprovalService::class)->approve($letter, (int) $verifier->id);

        $this->assertSame(1, $updated);
        $this->assertSame('hadir', $present->fresh()->status);
        $this->assertSame('sakit', $alpa->fresh()->status);
        $this->assertSame($letter->id, $alpa->fresh()->surat_absensi_id);
    }

    public function test_partial_leave_rejects_a_sunday_start_date(): void
    {
        [$studentUser, $student] = $this->createStudent('sunday-student@example.test');
        $schedule = $this->createSchedule(
            $student->kelas_id,
            'Senin',
            '08:00:00',
            '08:40:00',
            '2026-11-23',
            '2026-11-27',
        );
        Sanctum::actingAs($studentUser);

        $this->postJson('/api/siswa/pengajuan-izin', [
            'jenis_izin' => 'izin',
            'cakupan' => 'pulang_lebih_awal',
            'jadwal_acuan_id' => $schedule->id,
            'tanggal_mulai' => '2026-11-29',
            'tanggal_selesai' => '2026-11-30',
            'keterangan' => 'Pengajuan pada hari libur.',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('tanggal_mulai');
    }

    public function test_approval_service_rejects_processing_the_same_letter_twice(): void
    {
        [, $student] = $this->createStudent('approval-twice@example.test');
        $verifier = $this->createUser('guru', 'verifier-twice@example.test');
        $this->createSchedule($student->kelas_id, 'Senin', '08:00:00', '08:40:00', '2026-11-23', '2026-11-27');
        $letter = SuratAbsensi::create([
            'siswa_id' => $student->id,
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-23',
            'jenis' => 'izin',
            'cakupan' => 'sehari_penuh',
            'alasan' => 'Keperluan.',
            'status_verifikasi' => 'pending',
        ]);

        $service = app(SuratAbsensiApprovalService::class);
        $service->approve($letter, (int) $verifier->id);

        $this->expectException(ValidationException::class);
        $service->approve($letter->fresh(), (int) $verifier->id);
    }

    public function test_approval_does_not_overwrite_absence_already_linked_to_another_letter(): void
    {
        [, $student] = $this->createStudent('overlap-student@example.test');
        $verifier = $this->createUser('guru', 'overlap-verifier@example.test');
        $schedule = $this->createSchedule($student->kelas_id, 'Senin', '08:00:00', '08:40:00', '2026-11-23', '2026-11-27');

        $otherLetter = $this->createLetter($student->id);
        $otherLetter->update(['status_verifikasi' => 'disetujui']);
        $protectedAttendance = $this->createAttendance($student->id, $schedule->id, '2026-11-23', 'izin');
        $protectedAttendance->update(['surat_absensi_id' => $otherLetter->id]);

        $incomingLetter = SuratAbsensi::create([
            'siswa_id' => $student->id,
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-23',
            'jenis' => 'sakit',
            'cakupan' => 'sehari_penuh',
            'alasan' => 'Pengajuan kedua.',
            'status_verifikasi' => 'pending',
        ]);

        $updated = app(SuratAbsensiApprovalService::class)->approve($incomingLetter, (int) $verifier->id);

        $this->assertSame(0, $updated);
        $this->assertSame('izin', $protectedAttendance->fresh()->status);
        $this->assertSame($otherLetter->id, $protectedAttendance->fresh()->surat_absensi_id);
    }

    public function test_student_surat_list_only_contains_the_authenticated_students_letters(): void
    {
        [$userA, $studentA] = $this->createStudent('surat-owner@example.test');
        [, $studentB] = $this->createStudent('surat-other@example.test');
        $ownLetter = $this->createLetter($studentA->id);
        $otherLetter = $this->createLetter($studentB->id);
        Sanctum::actingAs($userA);

        $response = $this->getJson('/api/siswa/surat-izin');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $ownLetter->id);
        $this->assertNotSame($ownLetter->id, $otherLetter->id);
    }

    public function test_student_cannot_download_another_students_surat_document(): void
    {
        [$userA] = $this->createStudent('surat-file-owner@example.test');
        [, $studentB] = $this->createStudent('surat-file-other@example.test');
        $otherLetter = $this->createLetter($studentB->id, 'surat-absensi/private-other.pdf');
        Sanctum::actingAs($userA);

        $this->get('/api/siswa/surat/' . $otherLetter->id . '/file')->assertNotFound();
    }

    public function test_student_absence_history_only_contains_the_authenticated_students_rows(): void
    {
        [$userA, $studentA] = $this->createStudent('history-owner@example.test');
        [, $studentB] = $this->createStudent('history-other@example.test');
        $schedule = $this->createSchedule($studentA->kelas_id, 'Senin', '08:00:00', '08:40:00', '2026-11-23', '2026-11-27');
        $ownAttendance = $this->createAttendance($studentA->id, $schedule->id, '2026-11-23', 'hadir');
        $otherAttendance = $this->createAttendance($studentB->id, $schedule->id, '2026-11-23', 'izin');
        Sanctum::actingAs($userA);

        $response = $this->getJson('/api/siswa/absensi/riwayat');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data.data')
            ->assertJsonPath('data.data.0.id', $ownAttendance->id);
        $this->assertNotSame($ownAttendance->id, $otherAttendance->id);
    }

    public function test_guru_cannot_read_student_absence_or_surat_endpoints(): void
    {
        $guruUser = $this->createUser('guru', 'privacy-teacher@example.test');
        Sanctum::actingAs($guruUser);

        $this->getJson('/api/siswa/surat-izin')->assertForbidden();
        $this->getJson('/api/siswa/absensi/riwayat')->assertForbidden();
    }

    public function test_teacher_cannot_approve_a_letter_for_a_class_they_do_not_teach(): void
    {
        [, $student] = $this->createStudent('approve-scope-student@example.test');
        $teacherUser = $this->createUser('guru', 'unassigned-teacher@example.test');
        $otherClass = $this->createClass('VII C', 7);
        $this->createSchedule(
            $otherClass->id,
            'Senin',
            '08:00:00',
            '08:40:00',
            '2026-11-23',
            '2026-11-27',
        );
        $letter = $this->createLetter($student->id);
        Sanctum::actingAs($teacherUser);

        $this->postJson('/api/guru/surat-verifikasi/' . $letter->id . '/approve')
            ->assertNotFound();

        $this->assertSame('pending', $letter->fresh()->status_verifikasi);
    }

    public function test_student_cannot_open_a_task_assigned_to_another_class(): void
    {
        [$studentUser] = $this->createStudent('task-privacy-owner@example.test');
        [, $otherStudent] = $this->createStudent('task-privacy-other@example.test');
        $schedule = $this->createSchedule(
            $otherStudent->kelas_id,
            'Senin',
            '08:00:00',
            '08:40:00',
            '2026-11-23',
            '2026-11-27',
        );
        $task = Penugasan::create([
            'jadwal_id' => $schedule->id,
            'guru_id' => $schedule->guru_id,
            'judul' => 'Tugas kelas lain',
            'deskripsi' => 'Tidak boleh terlihat oleh siswa kelas lain.',
            'jenis' => 'tugas',
            'deadline' => '2026-11-27 23:59:00',
            'bobot' => 100,
        ]);
        Sanctum::actingAs($studentUser);

        $this->getJson('/api/siswa/tugas/' . $task->id)->assertNotFound();
    }

    public function test_student_cannot_download_another_students_submission_file(): void
    {
        [$studentUser] = $this->createStudent('submission-privacy-owner@example.test');
        [, $otherStudent] = $this->createStudent('submission-privacy-other@example.test');
        $schedule = $this->createSchedule(
            $otherStudent->kelas_id,
            'Senin',
            '08:00:00',
            '08:40:00',
            '2026-11-23',
            '2026-11-27',
        );
        $task = Penugasan::create([
            'jadwal_id' => $schedule->id,
            'guru_id' => $schedule->guru_id,
            'judul' => 'Tugas siswa lain',
            'deskripsi' => 'Tugas untuk menguji kepemilikan berkas.',
            'jenis' => 'tugas',
            'deadline' => '2026-11-27 23:59:00',
            'bobot' => 100,
        ]);
        $submission = PengumpulanTugas::create([
            'penugasan_id' => $task->id,
            'siswa_id' => $otherStudent->id,
            'jawaban' => 'Jawaban privat.',
            'file_jawaban' => 'pengumpulan-tugas/private-answer.pdf',
            'waktu_pengumpulan' => '2026-11-23 09:00:00',
            'status' => 'tepat_waktu',
        ]);
        Sanctum::actingAs($studentUser);

        $this->get('/api/siswa/pengumpulan/' . $submission->id . '/file')->assertNotFound();
    }

    /** @return array{0: User, 1: Siswa} */
    private function createStudent(string $email): array
    {
        $user = $this->createUser('siswa', $email);
        $class = $this->createClass('VII A', 7);
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

        return [$user, $student];
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

    private function createClass(string $name, int $level): Kelas
    {
        return Kelas::create([
            'nama_kelas' => $name,
            'tingkat' => $level,
            'kapasitas' => 30,
        ]);
    }

    private function createSchedule(
        int $classId,
        string $day,
        string $start,
        string $end,
        string $periodStart,
        string $periodEnd,
    ): JadwalPelajaran {
        $period = PeriodeAkademik::firstOrCreate(
            ['nama' => 'Semester Ganjil 2026/2027'],
            [
                'tahun_ajaran' => '2026/2027',
                'semester' => 'ganjil',
                'tanggal_mulai' => $periodStart,
                'tanggal_selesai' => $periodEnd,
                'is_active' => true,
            ],
        );
        $teacherUser = User::firstOrCreate(
            ['email' => 'schedule-teacher@example.test'],
            [
                'name' => 'Guru Jadwal',
                'password' => 'password-test',
                'role' => 'guru',
                'is_active' => true,
                'must_change_password' => false,
            ],
        );
        $teacher = Guru::firstOrCreate(
            ['user_id' => $teacherUser->id],
            [
                'nip' => 'NIP-' . $teacherUser->id,
                'nama_lengkap' => 'Guru Jadwal',
                'jenis_kelamin' => 'L',
            ],
        );
        $subject = MataPelajaran::firstOrCreate(
            ['kode' => 'MAP' . $teacherUser->id],
            ['nama' => 'Matematika', 'kkm' => 75],
        );

        return JadwalPelajaran::create([
            'periode_id' => $period->id,
            'kelas_id' => $classId,
            'mapel_id' => $subject->id,
            'guru_id' => $teacher->id,
            'hari' => $day,
            'jam_mulai' => $start,
            'jam_selesai' => $end,
            'ruangan' => 'Ruang 1',
        ]);
    }

    private function createAttendance(int $studentId, int $scheduleId, string $date, string $status): AbsensiHarian
    {
        return AbsensiHarian::create([
            'siswa_id' => $studentId,
            'jadwal_id' => $scheduleId,
            'tanggal' => $date,
            'status' => $status,
            'metode' => 'manual',
        ]);
    }

    private function createLetter(int $studentId, ?string $filePath = null): SuratAbsensi
    {
        return SuratAbsensi::create([
            'siswa_id' => $studentId,
            'tanggal_mulai' => '2026-11-23',
            'tanggal_selesai' => '2026-11-23',
            'jenis' => 'izin',
            'cakupan' => 'sehari_penuh',
            'alasan' => 'Keperluan keluarga.',
            'file_surat' => $filePath,
            'status_verifikasi' => 'pending',
        ]);
    }
}
