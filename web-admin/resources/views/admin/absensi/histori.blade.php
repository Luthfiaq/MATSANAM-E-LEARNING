@extends('layouts.admin')

@section('content')
<style>
    .histori-page {
        padding: 24px;
        background: #f7f9fc;
        min-height: 100vh;
        color: #172033;
    }

    .histori-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
        margin-bottom: 25px;
    }

    .breadcrumb {
        font-size: 11px;
        color: #91a0b9;
        font-weight: 700;
        letter-spacing: .5px;
        margin-bottom: 8px;
    }

    .breadcrumb span { color: #0754d5; }

    .histori-header h2 {
        font-size: 24px;
        font-weight: 750;
        margin: 0 0 5px;
    }

    .histori-header p {
        color: #64748b;
        font-size: 14px;
        max-width: 570px;
        margin: 0;
        line-height: 1.5;
    }

    .header-actions {
        display: flex;
        gap: 9px;
        flex-shrink: 0;
    }

    .action-btn {
        padding: 11px 16px;
        border-radius: 9px;
        border: 0;
        font-size: 12px;
        font-weight: 650;
        cursor: pointer;
        text-decoration: none;
    }

    .print-btn { background: white; color: #344256; }
    .export-btn { background: #0754d5; color: white; }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 16px;
        margin-bottom: 22px;
    }

    .stat-card {
        background: white;
        border-radius: 11px;
        padding: 18px 17px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 2px 7px #17203308;
        border-bottom: 4px solid #0754d5;
    }

    .stat-card.approved { border-color: #07845b; }
    .stat-card.rejected { border-color: #ef3434; }

    .stat-label {
        color: #8b9bb5;
        font-size: 11px;
        font-weight: 700;
        letter-spacing: .4px;
    }

    .stat-number {
        font-size: 30px;
        font-weight: 750;
        margin-top: 4px;
    }

    .stat-card.approved .stat-number { color: #07845b; }
    .stat-card.rejected .stat-number { color: #e72d2d; }

    .stat-note {
        color: #94a3b8;
        font-size: 11px;
        margin-top: 12px;
    }

    .filter-panel {
        background: white;
        border-radius: 11px;
        padding: 16px;
        margin-bottom: 22px;
        box-shadow: 0 2px 7px #17203308;
    }

    .filter-top {
        display: grid;
        grid-template-columns: 1.3fr 1fr;
        gap: 20px;
        margin-bottom: 17px;
    }

    .search-box {
        display: flex;
        align-items: center;
        gap: 10px;
        background: #f1f3ff;
        border-radius: 9px;
        padding: 0 13px;
    }

    .search-box span { color: #64748b; font-size: 18px; }

    .search-box input {
        width: 100%;
        border: 0;
        outline: none;
        background: transparent;
        padding: 12px 0;
        font-size: 12px;
    }

    .status-tabs {
        display: flex;
        gap: 5px;
        padding: 4px;
        background: #f1f3ff;
        border-radius: 9px;
    }

    .status-tabs a {
        flex: 1;
        text-align: center;
        text-decoration: none;
        padding: 9px 7px;
        color: #475569;
        border-radius: 7px;
        font-size: 11px;
        white-space: nowrap;
    }

    .status-tabs a.active {
        background: white;
        color: #172033;
        box-shadow: 0 1px 4px #00000010;
        font-weight: 700;
    }

    .status-tabs .count { color: #0754d5; font-weight: 700; }

    .filter-bottom {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 10px;
    }

    .filter-field label {
        display: block;
        color: #91a0b9;
        font-size: 10px;
        font-weight: 750;
        margin-bottom: 6px;
    }

    .filter-field select {
        width: 100%;
        border: 0;
        outline: none;
        border-radius: 8px;
        padding: 11px;
        background: #f1f3ff;
        color: #172033;
        font-size: 11px;
    }

    .table-card {
        background: white;
        border-radius: 11px;
        overflow: hidden;
        box-shadow: 0 2px 7px #17203308;
    }

    .table-heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 18px;
        gap: 10px;
    }

    .table-heading h3 {
        margin: 0;
        font-size: 15px;
        font-weight: 750;
    }

    .table-heading small {
        color: #94a3b8;
        font-size: 11px;
    }

    .table-wrap { overflow-x: auto; }

    .histori-table {
        width: 100%;
        border-collapse: collapse;
        min-width: 1050px;
    }

    .histori-table th {
        background: #f1f3ff;
        color: #475569;
        font-size: 11px;
        font-weight: 750;
        text-align: left;
        padding: 14px;
        white-space: nowrap;
    }

    .histori-table td {
        padding: 15px 14px;
        border-bottom: 1px solid #edf0f5;
        font-size: 11px;
        vertical-align: top;
    }

    .file-id {
        color: #0754d5;
        font-weight: 750;
        margin-top: 4px;
    }

    .muted {
        color: #94a3b8;
        font-size: 10px;
        margin-top: 4px;
    }

    .student-name {
        font-size: 13px;
        font-weight: 750;
        color: #172033;
    }

    .class-tag {
        display: inline-block;
        padding: 4px 7px;
        background: #e9edff;
        border-radius: 4px;
        color: #475569;
        margin-top: 5px;
    }

    .file-link {
        display: inline-block;
        padding: 9px;
        background: #f1f3ff;
        color: #0754d5;
        text-decoration: none;
        border-radius: 7px;
        font-weight: 700;
        max-width: 190px;
        overflow-wrap: anywhere;
    }

    .file-link:hover { background: #e3e9ff; }

    .status-badge {
        display: inline-block;
        padding: 6px 10px;
        border-radius: 20px;
        font-weight: 700;
        white-space: nowrap;
    }

    .badge-disetujui { color: #07845b; background: #d9f8e9; }
    .badge-ditolak { color: #dc2626; background: #fee2e2; }
    .badge-pending { color: #a16207; background: #fef3c7; }

    .detail-btn {
        border: 0;
        border-radius: 7px;
        background: #eaf0ff;
        color: #0754d5;
        padding: 8px 11px;
        font-size: 11px;
        font-weight: 700;
        cursor: pointer;
        white-space: nowrap;
    }

    .empty-state {
        text-align: center !important;
        padding: 35px !important;
        color: #94a3b8;
    }

    .pagination-wrap { padding: 15px; }

    .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        z-index: 9999;
        background: #10182899;
        justify-content: center;
        align-items: center;
        padding: 20px;
    }

    .modal-box {
        width: 100%;
        max-width: 570px;
        max-height: 90vh;
        overflow-y: auto;
        background: white;
        border-radius: 13px;
        padding: 22px;
    }

    .modal-heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }

    .modal-heading h3 { margin: 0; font-size: 17px; }

    .modal-close {
        border: 0;
        background: #f1f3f5;
        padding: 7px 11px;
        border-radius: 7px;
        cursor: pointer;
    }

    .detail-item {
        padding: 11px 0;
        border-bottom: 1px solid #edf0f5;
        font-size: 13px;
    }

    .detail-item strong {
        display: block;
        font-size: 11px;
        color: #94a3b8;
        margin-bottom: 5px;
    }

    .modal-file {
        display: inline-block;
        background: #eaf0ff;
        color: #0754d5;
        border-radius: 8px;
        padding: 10px 13px;
        text-decoration: none;
        font-weight: 700;
        font-size: 12px;
        margin: 5px 8px 5px 0;
    }

    @media(max-width: 850px) {
        .histori-header { align-items: flex-start; flex-direction: column; }
        .filter-top { grid-template-columns: 1fr; }
        .filter-bottom { grid-template-columns: 1fr 1fr; }
    }

    @media(max-width: 600px) {
        .histori-page { padding: 13px; }
        .stats-grid { grid-template-columns: 1fr; }
        .filter-bottom { grid-template-columns: 1fr; }
        .header-actions { flex-wrap: wrap; }
    }

    @media print {
        .no-print, .filter-panel, .detail-btn, .pagination-wrap,
        .modal-overlay { display: none !important; }
        .histori-page { padding: 0; background: white; }
        .table-card, .stat-card { box-shadow: none; }
    }

/* Penyesuaian ukuran font */
.histori-header h2 {
    font-size: 27px;
}

.histori-header p {
    font-size: 15px;
}

.stat-label {
    font-size: 12px;
}

.stat-number {
    font-size: 34px;
}

.stat-note {
    font-size: 12px;
}

.search-box input {
    font-size: 13px;
}

.filter-field label {
    font-size: 11px;
}

.filter-field select {
    font-size: 13px;
}

.status-tabs a {
    font-size: 12px;
}

.table-heading h3 {
    font-size: 17px;
}

.table-heading small {
    font-size: 12px;
}

.histori-table th {
    font-size: 12px;
}

.histori-table td {
    font-size: 12px;
}

.student-name {
    font-size: 14px;
}

.file-link {
    font-size: 12px;
}

.muted {
    font-size: 11px;
}

.detail-btn {
    font-size: 12px;
}

</style>

<div class="histori-page">

    <div class="histori-header">
        <div>
            <div class="breadcrumb">
                KESISWAAN & TATA USAHA &gt; <span>HISTORI & LOG AUDIT</span>
            </div>
            <h2>Histori Verifikasi Surat Absensi</h2>
            <p>
                Arsip pengajuan dan jejak verifikasi surat sakit maupun izin siswa yang telah diproses dan disahkan oleh unit Tata Usaha MTsN 6 Nganjuk.
            </p>
        </div>

        <div class="header-actions no-print">
            <button class="action-btn print-btn" onclick="window.print()">
                Cetak Arsip
            </button>
            <button class="action-btn export-btn" onclick="exportCSV()">
                Ekspor Log (.xlsx)
            </button>
        </div>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-label">TOTAL SURAT DIPROSES</div>
            <div class="stat-number">{{ $totalSemua }}</div>
            <div class="stat-note">Seluruh arsip surat absensi</div>
        </div>

        <div class="stat-card approved">
            <div class="stat-label">DISETUJUI / SAH</div>
            <div class="stat-number">{{ $totalDisetujui }}</div>
            <div class="stat-note">{{ $totalDisetujui }} berkas disetujui</div>
        </div>

        <div class="stat-card rejected">
            <div class="stat-label">DITOLAK / GUGUR</div>
            <div class="stat-number">{{ $totalDitolak }}</div>
            <div class="stat-note">{{ $totalDitolak }} berkas ditolak</div>
        </div>
    </div>

    <div class="filter-panel no-print">
        <div class="filter-top">
            <form action="{{ route('admin.absensi.histori') }}" method="GET" id="searchForm">
                <input type="hidden" name="status" value="{{ request('status', 'semua') }}">
                <input type="hidden" name="kelas" value="{{ request('kelas') }}">
                <input type="hidden" name="jenis" value="{{ request('jenis') }}">
                <input type="hidden" name="semester" value="{{ request('semester') }}">

                <div class="search-box">
                    <span>⌕</span>
                    <input type="text" name="q" id="searchInput"
                           value="{{ request('q') }}"
                           placeholder="Cari ID berkas, nama siswa, atau NISN...">
                </div>
            </form>

            <div class="status-tabs">
                <a class="{{ !in_array(request('status'), ['disetujui','ditolak','pending']) ? 'active' : '' }}"
                   href="{{ route('admin.absensi.histori', array_merge(request()->except('page'), ['status' => 'semua'])) }}">
                    Semua Arsip <span class="count">({{ $totalSemua }})</span>
                </a>

                <a class="{{ request('status') === 'pending' ? 'active' : '' }}"
                    href="{{ route('admin.absensi.histori', array_merge(request()->except('page'), ['status' => 'pending'])) }}">
                    Pending <span class="count">({{ $totalPending }})</span>
                </a>


                <a class="{{ request('status') === 'disetujui' ? 'active' : '' }}"
                   href="{{ route('admin.absensi.histori', array_merge(request()->except('page'), ['status' => 'disetujui'])) }}">
                    Disetujui <span class="count">({{ $totalDisetujui }})</span>
                </a>

                <a class="{{ request('status') === 'ditolak' ? 'active' : '' }}"
                   href="{{ route('admin.absensi.histori', array_merge(request()->except('page'), ['status' => 'ditolak'])) }}">
                    Ditolak <span class="count">({{ $totalDitolak }})</span>
                </a>
            </div>
        </div>

        <div class="filter-bottom">
            <div class="filter-field">
                <label>TINGKAT / KELAS</label>
                <select id="kelasFilter">
                    <option value="">Semua Kelas</option>
                    @foreach($kelasList as $kelas)
                        <option value="{{ $kelas->id }}"
                            {{ request('kelas') == $kelas->id ? 'selected' : '' }}>
                            {{ $kelas->nama_kelas }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div class="filter-field">
                <label>JENIS SURAT</label>
                <select id="jenisFilter">
                    <option value="">Semua Kategori</option>
                    <option value="sakit" {{ request('jenis') == 'sakit' ? 'selected' : '' }}>Sakit</option>
                    <option value="izin" {{ request('jenis') == 'izin' ? 'selected' : '' }}>Izin</option>
                </select>
            </div>

            <div class="filter-field">
                <label>SEMESTER</label>
                <select id="semesterFilter">
                    <option value="">Semua Semester</option>
                    <option value="1" {{ request('semester') == '1' ? 'selected' : '' }}>Semester 1</option>
                    <option value="2" {{ request('semester') == '2' ? 'selected' : '' }}>Semester 2</option>
                </select>
            </div>
        </div>
    </div>

    <div class="table-card">
        <div class="table-heading">
            <div>
                <h3>🔵 Daftar Audit Dokumen Verifikasi</h3>
                <small>Menampilkan {{ $surats->count() }} dari {{ $surats->total() }} arsip pada hasil pencarian</small>
            </div>
        </div>

        <div class="table-wrap">
            <table class="histori-table" id="historiTable">
                <thead>
                    <tr>
                        <th>No & ID Berkas</th>
                        <th>Siswa & Rombel</th>
                        <th>Jenis & Durasi Izin</th>
                        <th>Berkas Terlampir</th>
                        <th>Waktu Verifikasi</th>
                        <th>Status Keputusan</th>
                        <th>Catatan</th>
                        <th class="no-print">Detail</th>
                    </tr>
                </thead>

                <tbody>
                    @forelse($surats as $index => $surat)
                        @php
                            $namaSiswa = $surat->siswa->nama_lengkap ?? '-';
                            $nisn = $surat->siswa->nisn ?? '-';
                            $namaKelas = $surat->siswa->kelas->nama_kelas ?? '-';
                            $jenis = ucfirst($surat->jenis ?? '-');
                            $mulai = $surat->tanggal_mulai
                                ? $surat->tanggal_mulai->format('d M Y') : '-';
                            $selesai = $surat->tanggal_selesai
                                ? $surat->tanggal_selesai->format('d M Y') : '-';
                            $status = $surat->status_verifikasi ?? 'pending';
                            $tanggalVerifikasi = $surat->tanggal_verifikasi
                                ? $surat->tanggal_verifikasi->format('d M Y H:i') : '-';
                            $fileUrl = $surat->file_surat
                                ? route('admin.absensi.surat.file', $surat->id)
                                : null;
                            $downloadUrl = $surat->file_surat
                                ? route('admin.absensi.surat.file', ['id' => $surat->id, 'download' => 1])
                                : null;
                        @endphp

                        <tr>
                            <td>
                                <strong>#{{ $surats->firstItem() + $index }}</strong>
                                <div class="file-id">
                                    VRF-{{ date('Y') }}-{{ str_pad($surat->id, 4, '0', STR_PAD_LEFT) }}
                                </div>
                                <div class="muted">Via Portal</div>
                            </td>

                            <td>
                                <div class="student-name">{{ $namaSiswa }}</div>
                                <div class="class-tag">{{ $namaKelas }}</div>
                                <div class="muted">NISN: {{ $nisn }}</div>
                            </td>

                            <td>
                                <strong>{{ $jenis }}</strong>
                                <div class="muted">{{ $mulai }} - {{ $selesai }}</div>
                                <div class="muted">{{ $surat->alasan ?: '-' }}</div>
                            </td>

                            <td>
                                @if($fileUrl)
                                    <a class="file-link" href="{{ $fileUrl }}" target="_blank">
                                        📄 {{ basename($surat->file_surat) }}
                                    </a>
                                @else
                                    <span class="muted">Tidak ada berkas</span>
                                @endif
                            </td>

                            <td>
                                <strong>{{ $tanggalVerifikasi }}</strong>
                                <div class="muted">
                                    {{ $surat->tanggal_verifikasi ? 'Sudah diverifikasi' : 'Belum diverifikasi' }}
                                </div>
                            </td>

                            <td>
                                <span class="status-badge badge-{{ $status }}">
                                    {{ ucfirst($status) }}
                                </span>
                            </td>

                            <td>{{ $surat->catatan_verifikasi ?: '-' }}</td>

                            <td class="no-print">
                                <button type="button" class="detail-btn"
                                    onclick="showDetail(this)"
                                    data-id="VRF-{{ date('Y') }}-{{ str_pad($surat->id, 4, '0', STR_PAD_LEFT) }}"
                                    data-nama="{{ $namaSiswa }}"
                                    data-nisn="{{ $nisn }}"
                                    data-kelas="{{ $namaKelas }}"
                                    data-jenis="{{ $jenis }}"
                                    data-mulai="{{ $mulai }}"
                                    data-selesai="{{ $selesai }}"
                                    data-alasan="{{ $surat->alasan ?: '-' }}"
                                    data-tanggal="{{ $tanggalVerifikasi }}"
                                    data-status="{{ ucfirst($status) }}"
                                    data-catatan="{{ $surat->catatan_verifikasi ?: '-' }}"
                                    data-file="{{ $fileUrl ?? '' }}"
                                    data-download="{{ $downloadUrl ?? '' }}"
                                    data-filename="{{ $surat->file_surat ? basename($surat->file_surat) : '' }}">
                                    Lihat Detail
                                </button>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="empty-state">
                                Tidak ada arsip surat yang ditemukan.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="pagination-wrap">
            {{ $surats->links() }}
        </div>
    </div>
</div>

<div class="modal-overlay" id="detailModal">
    <div class="modal-box">
        <div class="modal-heading">
            <h3>Detail Dokumen Verifikasi</h3>
            <button type="button" class="modal-close" onclick="closeDetail()">✕</button>
        </div>
        <div id="detailContent"></div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
<script>
    const baseUrl = "{{ route('admin.absensi.histori') }}";

    function submitFilters() {
        const params = new URLSearchParams(window.location.search);

        params.delete('page');
        params.set('kelas', document.getElementById('kelasFilter').value);
        params.set('jenis', document.getElementById('jenisFilter').value);
        params.set('semester', document.getElementById('semesterFilter').value);

        window.location.href = baseUrl + '?' + params.toString();
    }

    document.getElementById('kelasFilter').addEventListener('change', submitFilters);
    document.getElementById('jenisFilter').addEventListener('change', submitFilters);
    document.getElementById('semesterFilter').addEventListener('change', submitFilters);

    let searchTimer;
    document.getElementById('searchInput').addEventListener('input', function() {
        clearTimeout(searchTimer);
        searchTimer = setTimeout(function() {
            document.getElementById('searchForm').submit();
        }, 550);
    });

    function showDetail(button) {
        const fields = [
            ['ID Berkas', 'id'],
            ['Nama Siswa', 'nama'],
            ['NISN', 'nisn'],
            ['Kelas', 'kelas'],
            ['Jenis Surat', 'jenis'],
            ['Tanggal Mulai', 'mulai'],
            ['Tanggal Selesai', 'selesai'],
            ['Alasan Pengajuan', 'alasan'],
            ['Waktu Verifikasi', 'tanggal'],
            ['Status Keputusan', 'status'],
            ['Catatan Verifikasi', 'catatan']
        ];

        const content = document.getElementById('detailContent');
        content.innerHTML = '';

        fields.forEach(function(field) {
            const item = document.createElement('div');
            item.className = 'detail-item';

            const label = document.createElement('strong');
            label.textContent = field[0];

            const value = document.createElement('span');
            value.textContent = button.dataset[field[1]] || '-';

            item.appendChild(label);
            item.appendChild(value);
            content.appendChild(item);
        });

        const fileUrl = button.dataset.file;
        const downloadUrl = button.dataset.download;
        const fileName = button.dataset.filename;

        const fileItem = document.createElement('div');
        fileItem.className = 'detail-item';

        const fileLabel = document.createElement('strong');
        fileLabel.textContent = 'Berkas Terlampir';
        fileItem.appendChild(fileLabel);

        if (fileUrl) {
            const viewLink = document.createElement('a');
            viewLink.className = 'modal-file';
            viewLink.href = fileUrl;
            viewLink.target = '_blank';
            viewLink.rel = 'noopener';
            viewLink.textContent = 'Lihat ' + fileName;

            const downloadLink = document.createElement('a');
            downloadLink.className = 'modal-file';
            downloadLink.href = downloadUrl;
            downloadLink.textContent = 'Unduh Berkas';

            fileItem.appendChild(viewLink);
            fileItem.appendChild(downloadLink);
        } else {
            const noFile = document.createElement('span');
            noFile.textContent = 'Tidak ada berkas terlampir.';
            fileItem.appendChild(noFile);
        }

        content.appendChild(fileItem);
        document.getElementById('detailModal').style.display = 'flex';
    }

    function closeDetail() {
        document.getElementById('detailModal').style.display = 'none';
    }

    document.getElementById('detailModal').addEventListener('click', function(event) {
        if (event.target === this) closeDetail();
    });


    function exportCSV() {
        const rows = [...document.querySelectorAll('#historiTable tr')];

        const data = rows.map(row => {
            return [...row.querySelectorAll('th, td')]
                .filter(cell => !cell.classList.contains('no-print'))
                .map(cell => cell.innerText
                    .replace(/\s+/g, ' ')
                    .trim()
                );
        });

        const worksheet = XLSX.utils.aoa_to_sheet(data);

        // Mengatur lebar kolom agar lebih nyaman dibaca
        worksheet['!cols'] = [
            { wch: 22 },
            { wch: 30 },
            { wch: 25 },
            { wch: 25 },
            { wch: 23 },
            { wch: 20 },
            { wch: 30 },
            { wch: 15 }
        ];

        const workbook = XLSX.utils.book_new();

        XLSX.utils.book_append_sheet(
            workbook,
            worksheet,
            'Histori Verifikasi Surat'
        );

        XLSX.writeFile(
            workbook,
            'histori-verifikasi-surat.xlsx'
        );
    }
</script>
@endsection
