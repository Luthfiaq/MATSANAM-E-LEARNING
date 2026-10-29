<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Histori Verifikasi Surat Absensi | MATSANAM</title>
    <style>
        :root{--blue:#1d4ed8;--blue-dark:#1d4ed8;--slate:#1e293b;--muted:#94a3b8;--line:#e2e8f0;--bg:#f6f8fc;--green:#047857;--red:#dc2626}
        *{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--slate);font-family:Arial,Helvetica,sans-serif;font-size:13px}
        button,input,select{font:inherit}button{cursor:pointer}button:disabled{opacity:.35;cursor:not-allowed}
        .sidebar{position:fixed;inset:0 auto 0 0;width:230px;background:#fff;border-right:1px solid var(--line);display:flex;flex-direction:column;z-index:5}
        .brand{height:62px;display:flex;align-items:center;gap:12px;padding:0 20px;border-bottom:1px solid #f1f5f9}.brand-icon{height:36px;width:36px;border-radius:12px;background:#2563eb;color:#fff;display:grid;place-items:center;font-size:22px}.brand-name{font-size:14px;font-weight:800}.brand-sub{font-size:10px;color:var(--muted);margin-top:3px}
        nav{flex:1;overflow:auto;padding:20px 12px;font-size:12px}nav section{margin-bottom:22px}nav .nav-title{font-size:10px;font-weight:700;letter-spacing:1px;color:var(--muted);padding:0 8px;margin:0 0 8px}nav a{display:block;text-decoration:none;color:#334155;padding:11px 12px;border-radius:8px;margin:2px 0}nav a:hover{background:#f8fafc}nav a.active{background:#2563eb;color:#fff;font-weight:600}.pill-count{float:right;background:#ef4444;color:white;border-radius:20px;padding:2px 7px;font-size:10px}
        .connection{padding:12px;border-top:1px solid #f1f5f9}.connection-card{border:1px solid var(--line);border-radius:9px;padding:12px}.connection-card small{color:var(--muted);font-size:10px}.connection-card p{color:var(--green);font-weight:700;font-size:11px;margin:7px 0 0}
        .main{margin-left:230px}.topbar{position:sticky;top:0;z-index:4;min-height:62px;background:#fff;border-bottom:1px solid var(--line);display:flex;align-items:center;gap:12px;padding:12px 28px;flex-wrap:wrap}.year{border:1px solid #bfdbfe;background:#eff6ff;color:#1d4ed8;border-radius:8px;padding:9px 12px;font-size:12px;white-space:nowrap}.top-search{min-width:180px;flex:1;background:#f8fafc;border:1px solid var(--line);border-radius:8px;padding:10px 12px;outline:none;font-size:12px}.profile{margin-left:auto;text-align:right}.profile strong{display:block;font-size:12px}.profile small{display:block;color:#2563eb;font-size:10px;margin-top:4px}.avatar{height:36px;width:36px;border-radius:50%;background:#2563eb;color:white;display:grid;place-items:center}
        main{max-width:1600px;margin:auto;padding:28px;display:flex;flex-direction:column;gap:20px}.intro{display:flex;justify-content:space-between;gap:18px;align-items:center}.crumb{font-size:10px;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:var(--muted);margin-bottom:10px}.intro h1{font-size:26px;letter-spacing:-.5px;margin:0;font-weight:750}.intro p{font-size:12px;line-height:1.7;color:#64748b;max-width:700px;margin:10px 0 0}.actions{display:flex;gap:8px;flex-wrap:wrap}.btn{border:1px solid var(--line);background:white;border-radius:8px;padding:11px 14px;font-weight:700;font-size:11px;color:#334155}.btn:hover{background:#f8fafc}.btn-primary{background:#1d4ed8;border-color:#1d4ed8;color:white}.btn-primary:hover{background:#1e40af}
        .stats{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}.stat{background:#fff;border:1px solid #f1f5f9;border-bottom:4px solid #1d4ed8;border-radius:12px;padding:20px}.stat.green{border-bottom-color:#047857}.stat.red{border-bottom-color:#ef4444}.stat-top{display:flex;justify-content:space-between;align-items:flex-start}.stat-label{font-size:10px;font-weight:700;letter-spacing:1px;color:var(--muted)}.stat-number{font-size:32px;font-weight:750;margin-top:6px}.stat.green .stat-number{color:#047857}.stat.red .stat-number{color:#dc2626}.stat-icon{padding:12px;border-radius:12px;font-size:20px;background:#eff6ff;color:#1d4ed8}.stat.green .stat-icon{background:#ecfdf5;color:#047857}.stat.red .stat-icon{background:#fef2f2;color:#dc2626}.stat-note{font-size:10px;color:var(--muted);margin-top:18px}
        .filters{background:white;border:1px solid #f1f5f9;border-radius:12px;padding:16px;display:flex;flex-direction:column;gap:16px}.filter-top{display:flex;gap:12px}.filter-search{flex:1;min-width:0;background:#eef2ff99;border:1px solid var(--line);border-radius:8px;padding:12px;font-size:12px;outline:none}.status-tabs{display:flex;gap:3px;background:#eef2ff;padding:4px;border-radius:8px;white-space:nowrap}.status-tabs button{border:0;background:transparent;padding:9px 12px;border-radius:6px;color:#475569;font-size:10px}.status-tabs button.selected{background:#fff;color:#1d4ed8;font-weight:700;box-shadow:0 1px 3px #0001}.green-text{color:#047857}.red-text{color:#dc2626}.filter-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px}.field{font-size:10px;font-weight:700;color:var(--muted);display:block}.field select{display:block;width:100%;margin-top:7px;border:1px solid var(--line);background:#fff;border-radius:8px;padding:11px 12px;font-size:12px;font-weight:400;color:#334155;outline:none}
        .table-card{background:#fff;border:1px solid #f1f5f9;border-radius:12px;overflow:hidden}.table-head{padding:16px;border-bottom:1px solid #f1f5f9;display:flex;justify-content:space-between;gap:12px;align-items:center}.table-head h2{font-size:14px;margin:0;font-weight:750}.table-head h2 span{color:#1d4ed8}.table-head small{font-size:10px;font-weight:400;color:var(--muted);margin-left:8px}.sort{font-size:10px;color:var(--muted);white-space:nowrap}.sort select{border:0;background:white;color:#1d4ed8;font-weight:700;outline:none}.table-wrap{overflow-x:auto}table{border-collapse:collapse;width:100%;min-width:1100px;text-align:left;font-size:11px}thead{background:#eef2ffcc;color:#475569}th{padding:13px 12px;font-weight:700}td{padding:16px 12px;border-bottom:1px solid #f1f5f9;vertical-align:top}tbody tr:last-child td{border-bottom:0}tbody tr:hover{background:#f8fafcaa}.num{font-weight:700}.file-id{margin-top:5px;font-weight:700;overflow-wrap:anywhere;color:#1d4ed8}.file-id.rejected{color:#dc2626}.muted{color:var(--muted)}.tiny{font-size:9px;margin-top:5px}.student{display:flex;gap:8px}.initials{width:32px;height:32px;flex-shrink:0;border-radius:11px;background:#eef2ff;color:#1d4ed8;display:grid;place-items:center;font-weight:700}.student-name{min-width:110px;font-weight:700}.subline{color:#64748b;margin-top:5px}.file-btn{border:0;background:#eef2ff;border-radius:8px;padding:9px 10px;text-align:left;color:#1d4ed8}.file-btn:hover{background:#e0e7ff}.file-name{font-weight:700;max-width:150px;overflow-wrap:anywhere}.status{display:inline-block;border-radius:30px;padding:6px 10px;font-size:10px;font-weight:700;white-space:nowrap}.approved{background:#d1fae5;color:#047857}.rejected-badge{background:#fee2e2;color:#dc2626}.note-btn{max-width:150px;border:0;border-radius:6px;padding:9px;text-align:left;line-height:1.5;background:#f8fafc;color:#475569}.note-btn.rejected-note{background:#fef2f2;color:#b91c1c}.detail-link{display:block;color:#2563eb;font-weight:700;margin-top:5px}.empty{text-align:center;color:var(--muted);padding:48px}.pagination{padding:16px;display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;color:#64748b;font-size:10px}.pagination select{border:1px solid var(--line);border-radius:6px;padding:6px;background:#fff}.pages{display:flex;align-items:center;gap:4px}.pages button{border:0;background:white;border-radius:5px;padding:8px 10px}.pages button:hover{background:#f1f5f9}.pages .current{background:#1d4ed8;color:white;font-weight:700}
        .integrity{display:flex;gap:12px;align-items:center;background:white;border:1px solid #f1f5f9;border-radius:12px;padding:16px}.integrity-icon{height:40px;width:40px;flex-shrink:0;border-radius:12px;background:#d1fae5;color:#047857;display:grid;place-items:center;font-size:20px}.integrity h3{font-size:14px;margin:0}.integrity p{font-size:10px;line-height:1.5;color:var(--muted);margin:5px 0 0}.integrity-tag{margin-left:auto;white-space:nowrap;font-size:10px;color:#047857;font-weight:700}
        .modal-backdrop{position:fixed;inset:0;z-index:20;background:#02061766;display:none;align-items:center;justify-content:center;padding:16px}.modal-backdrop.open{display:flex}.modal{background:#fff;width:100%;max-width:620px;max-height:92vh;overflow:auto;border-radius:16px;padding:24px;box-shadow:0 20px 60px #0003}.modal-head{display:flex;justify-content:space-between;gap:12px}.modal-kicker{font-size:11px;color:#1d4ed8;font-weight:700}.modal h2{font-size:22px;margin:8px 0 0}.close{border:0;background:white;border-radius:8px;font-size:24px;padding:0 9px;align-self:flex-start}.detail-grid{margin-top:20px;display:grid;grid-template-columns:1fr 1fr;gap:12px;font-size:13px}.detail-item{overflow-wrap:anywhere}.detail-item strong{display:block;font-size:11px;color:#64748b;margin-bottom:4px}.preview-title{font-weight:700;margin:22px 0 8px}.preview{width:100%;height:360px;border:1px solid var(--line);border-radius:8px}.preview-image{max-width:100%;max-height:360px;object-fit:contain;display:block;margin:auto;border:1px solid var(--line);border-radius:8px}.audit-note{margin-top:18px;background:#f8fafc;padding:12px;border-radius:8px;font-size:12px}.modal-close-bottom{margin-top:20px;width:100%;padding:12px;border:0;border-radius:8px;background:#1d4ed8;color:white;font-weight:700}
        @media(max-width:1100px){.sidebar{display:none}.main{margin-left:0}.filter-grid{grid-template-columns:repeat(2,minmax(0,1fr))}main{padding:20px}.topbar{padding:12px 20px}}
        @media(max-width:720px){.intro{align-items:flex-start;flex-direction:column}.intro h1{font-size:22px}.stats{grid-template-columns:1fr}.filter-top{flex-direction:column}.status-tabs{overflow-x:auto}.filter-grid{grid-template-columns:1fr}.top-search{order:3;flex-basis:100%}.profile{margin-left:auto}.table-head{align-items:flex-start;flex-direction:column}.integrity{align-items:flex-start;flex-wrap:wrap}.integrity-tag{margin-left:52px}.detail-grid{grid-template-columns:1fr}}
        @media print{.sidebar,.topbar,.actions,.filters,.pagination,.integrity,.file-btn,.note-btn,.sort{display:none!important}.main{margin:0}main{padding:0;max-width:none}.table-card,.stat{break-inside:avoid}body{background:#fff}.stats{grid-template-columns:repeat(3,1fr)}}
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="brand"><div class="brand-icon">◈</div><div><div class="brand-name">MATSANAM</div><div class="brand-sub">Digital Academic Portal</div></div></div>
    <nav>
        <section><p class="nav-title">NAVIGASI UTAMA</p><a href="/">▦ &nbsp; Dashboard Utama</a></section>
        <section><p class="nav-title">MANAJEMEN GURU</p><a href="#">♣ &nbsp; List Penugasan Guru</a><a href="#">♙ &nbsp; Atur Penugasan Baru</a></section>
        <section><p class="nav-title">VERIFIKASI &amp; IZIN</p><a href="#">▤ &nbsp; Verifikasi Surat <span class="pill-count">5</span></a><a class="active" href="/histori">◴ &nbsp; Histori Verifikasi</a></section>
        <section><p class="nav-title">PRESENSI &amp; LAPORAN</p><a href="#">▣ &nbsp; Rekap Absensi Siswa</a></section>
        <section><p class="nav-title">KONFIGURASI</p><a href="#">☷ &nbsp; Pengaturan &amp; Master Data</a></section>
    </nav>
    <div class="connection"><div class="connection-card"><small>Koneksi Database</small><p>● Terhubung Aktif</p></div></div>
</aside>
<div class="main">
    <header class="topbar">
        <span class="year">▣ T.A. 2026/2027 Ganjil</span>
        <input id="globalSearch" class="top-search" placeholder="⌕  Cari NIP, nama guru, kelas, atau siswa...">
        <div class="profile"><strong>Ust. H. Ahmad Zulfikar</strong><small>Super Admin / Tata Usaha</small></div><div class="avatar">♙</div>
    </header>
    <main>
        <section class="intro">
            <div><div class="crumb">Kesiswaan &amp; Tata Usaha › Histori &amp; Log Audit</div><h1>Histori Verifikasi Surat Absensi</h1><p>Arsip komprehensif dan jejak audit verifikasi surat sakit, dispensasi kegiatan, serta izin wali murid yang telah disahkan oleh unit Tata Usaha MTsN 6 Nganjuk.</p></div>
            <div class="actions"><button class="btn" onclick="window.print()">▤ Cetak Arsip</button><button class="btn btn-primary" id="exportCsv">↓ Ekspor Log (.csv)</button></div>
        </section>
        
<section class="stats">
    <div class="stat">
        <div class="stat-top">
            <div>
                <div class="stat-label">TOTAL SURAT DIPROSES</div>
                <div class="stat-number">{{ $totalDiproses }}</div>
            </div>
            <div class="stat-icon">♧</div>
        </div>
        <div class="stat-note">
            {{ $totalDiproses }} berkas menunggu verifikasi
        </div>
    </div>

    <div class="stat green">
        <div class="stat-top">
            <div>
                <div class="stat-label">DISETUJUI / SAH</div>
                <div class="stat-number">{{ $totalDiterima }}</div>
            </div>
            <div class="stat-icon">✿</div>
        </div>
        <div class="stat-note">
            {{ $totalDiterima }} berkas sah
        </div>
    </div>

    <div class="stat red">
        <div class="stat-top">
            <div>
                <div class="stat-label">DITOLAK / GUGUR</div>
                <div class="stat-number">{{ $totalDitolak }}</div>
            </div>
            <div class="stat-icon">♧</div>
        </div>
        <div class="stat-note">
            {{ $totalDitolak }} berkas tidak sah
        </div>
    </div>
</section>
        <section class="filters">
            
<div class="filter-top">
    <input id="tableSearch" class="filter-search"
        placeholder="⌕  Cari ID berkas, nama siswa, NISN, atau instansi dokter...">

    <div class="status-tabs">
        <button class="selected" data-status="Semua Arsip">
            Semua Arsip ({{ $totalArsip }})
        </button>

        <button data-status="Disetujui">
            Disetujui <span class="green-text">({{ $totalDiterima }})</span>
        </button>

        <button data-status="Ditolak">
            Ditolak <span class="red-text">({{ $totalDitolak }})</span>
        </button>
    </div>
</div>

            <div class="filter-grid">
                <label class="field">TINGKAT / KELAS<select id="kelas"><option value="">Semua Kelas</option><option value="7">Kelas 7</option><option value="8">Kelas 8</option><option value="9">Kelas 9</option></select></label>
                
<label class="field">JENIS SURAT
    <select id="jenis">>
        <option value="">Semua Jenis Surat</option>
        <option value="izin">Izin Keluarga</option>
        <option value="dispensasi">Dispensasi Lomba</option>
        <option value="keterangan_sakit">Surat Keterangan Sakit</option>
    </select>
</label>

<label class="field">
    PERIODE SEMESTER
    <select id="tanggal">
        <option value="">Semua Semester</option>
        @foreach($daftarSemester as $semester)
            <option value="{{ $semester['nilai'] }}">
                {{ $semester['label'] }}
            </option>
        @endforeach
    </select>
</label>
                
<label class="field">VALIDATOR   
<select id="validator">
    <option value="">Semua Petugas Validator</option>
    <option value="Ust. H. Ahmad Zulfikar">Ust. H. Ahmad Zulfikar</option>
    <option value="Hj. Siti Maemunah">Hj. Siti Maemunah</option>
</select>
</label>
            </div>
        </section>
        <section class="table-card">
            <div class="table-head"><h2><span>●</span> Daftar Audit Dokumen Verifikasi <small id="countText">(Menampilkan 5 dari 5 arsip contoh)</small></h2><label class="sort">Urutkan: <select id="sort"><option value="desc">Terbaru ke Terlama</option><option value="asc">Terlama ke Terbaru</option></select></label></div>
            <div class="table-wrap"><table><thead><tr><th>No &amp; ID Berkas</th><th>Siswa &amp; Rombel</th><th>Jenis &amp; Durasi Izin</th><th>Berkas Terlampir</th><th>Waktu Verifikasi</th><th>Status Keputusan</th><th>Catatan Audit</th></tr></thead><tbody id="tableBody"></tbody></table></div>
            <div class="pagination"><div style="display:flex;align-items:center;gap:9px;flex-wrap:wrap"><span>Tampilkan per halaman:</span><select id="pageSize"><option value="5">5 baris</option><option value="10">10 baris</option></select><span id="rangeText">Menampilkan 1–5 dari 5 arsip contoh</span></div><div class="pages"><button id="firstPage">«</button><button id="prevPage">‹</button><span class="current" id="pageNum">1</span><button id="nextPage">›</button><button id="lastPage">»</button></div></div>
        </section>
        <section class="integrity"><div class="integrity-icon">♢</div><div style="flex:1"><h3>Integritas Log Verifikasi Digital Kesekretariatan Matsanam</h3><p>Setiap perubahan status surat absensi tercatat permanen pada sistem audit trail madrasah sesuai kebijakan administrasi.</p></div><span class="integrity-tag">♙ Enkripsi SHA-256 Terverifikasi</span></section>
    </main>
</div>
<div class="modal-backdrop" id="modalBackdrop" onclick="if(event.target===this)closeModal()"><div class="modal" role="dialog" aria-modal="true" aria-labelledby="detailTitle"><div class="modal-head"><div><div class="modal-kicker">DETAIL ARSIP VERIFIKASI</div><h2 id="detailTitle">Nama Siswa</h2></div><button class="close" onclick="closeModal()" aria-label="Tutup detail">×</button></div><div id="modalContent"></div><button class="modal-close-bottom" onclick="closeModal()">Tutup</button></div></div>
<script>
const suratData = @json($surat);
let activeStatus='Semua Arsip', page=1;
const $=id=>document.getElementById(id);
const escapeHtml=value=>String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function filteredData(){
 const search=($('tableSearch').value||$('globalSearch').value).toLowerCase().trim();
 let rows=suratData.filter(s=>{
  const matchSearch=`${s.nomor} ${s.nama} ${s.nisn} ${s.jenis}`.toLowerCase().includes(search);
  return matchSearch && (!activeStatus||activeStatus==='Semua Arsip'||s.status===activeStatus)
   && (!$('kelas').value||s.kelas.startsWith($('kelas').value))
   && (!$('jenis').value||s.jenis===$('jenis').value)
   && (!$('validator').value||s.validator===$('validator').value)
   && (
    !$('tanggal').value ||
    (() => {
        const tanggal = new Date(s.tanggal);
        const bulan = tanggal.getMonth() + 1;
        const tahun = tanggal.getFullYear();

        let semester;
        let tahunAjaran;

        if (bulan >= 7) {
            semester = 'Ganjil';
            tahunAjaran = `${tahun}/${tahun + 1}`;
        } else {
            semester = 'Genap';
            tahunAjaran = `${tahun - 1}/${tahun}`;
        }

        return `${semester} ${tahunAjaran}` === $('tanggal').value;
    })()
);
 });
 return rows.sort((a,b)=>$('sort').value==='desc'?b.id-a.id:a.id-b.id);
}
function render(){
 const rows=filteredData(), size=Number($('pageSize').value), totalPages=Math.max(1,Math.ceil(rows.length/size));
 page=Math.min(page,totalPages); const start=(page-1)*size, shown=rows.slice(start,start+size);
 $('countText').textContent=`(Menampilkan ${shown.length} dari ${rows.length} arsip contoh)`;
 $('rangeText').textContent=`Menampilkan ${rows.length?start+1:0}–${Math.min(start+size,rows.length)} dari ${rows.length} arsip contoh`;
 $('pageNum').textContent=page;
 ['firstPage','prevPage'].forEach(id=>$(id).disabled=page===1);
 ['nextPage','lastPage'].forEach(id=>$(id).disabled=page>=totalPages);
 $('tableBody').innerHTML=shown.length?shown.map((s,i)=>`<tr>
 <td style="max-width:115px"><div class="num">#${start+i+1}</div><div class="file-id ${s.status==='Ditolak'?'rejected':''}">${escapeHtml(s.nomor)}</div><div class="tiny muted">Via Portal Siswa</div></td>
 <td><div class="student"><span class="initials">${escapeHtml(s.inisial)}</span><div><div class="student-name">${escapeHtml(s.nama)}</div><div class="subline">Kelas ${escapeHtml(s.kelas)}</div><div class="tiny muted">NISN: ${escapeHtml(s.nisn)}</div></div></div></td>
 <td style="max-width:160px"><strong>${escapeHtml(s.jenis)}</strong><div class="subline">${escapeHtml(s.durasi)}</div></td>
 <td><button class="file-btn" onclick="showDetail(${s.id})"><div class="file-name">▤ ${escapeHtml(s.berkas)}</div><div class="tiny muted">${escapeHtml(s.ukuran)}</div></button></td>
 <td><strong style="white-space:nowrap">${escapeHtml(s.tanggal)}</strong><div class="tiny muted">08:40 WIB</div><div class="tiny muted" style="max-width:120px">Oleh: ${escapeHtml(s.validator)}</div></td>
 <td><span class="status ${s.status==='Disetujui'?'approved':'rejected-badge'}">${s.status==='Disetujui'?'✓':'⊗'} ${escapeHtml(s.status)}</span></td>
 <td><button class="note-btn ${s.status==='Ditolak'?'rejected-note':''}" onclick="showDetail(${s.id})">${escapeHtml(s.catatan)}<span class="detail-link">Lihat detail →</span></button></td></tr>`).join(''):`<tr><td colspan="7" class="empty">Tidak ada arsip yang sesuai dengan filter.</td></tr>`;
}
function showDetail(id){
 const s=suratData.find(x=>x.id===id); if(!s)return;
 $('detailTitle').textContent=s.nama;
 const ext=s.berkas.toLowerCase();
 let preview='<p style="padding:12px;background:#fffbeb;color:#b45309;border-radius:8px">File belum tersedia. Silakan hubungkan dengan file surat yang asli.</p>';
 if(s.fileUrl && ext.endsWith('.pdf')) preview=`<iframe class="preview" src="${escapeHtml(s.fileUrl)}" title="Pratinjau ${escapeHtml(s.berkas)}"></iframe>`;
 else if(s.fileUrl && /\.(jpg|jpeg|png)$/i.test(ext)) preview=`<img class="preview-image" src="${escapeHtml(s.fileUrl)}" alt="Surat ${escapeHtml(s.nama)}">`;
 $('modalContent').innerHTML=`<div class="detail-grid">
 <div class="detail-item"><strong>ID Berkas</strong>${escapeHtml(s.nomor)}</div><div class="detail-item"><strong>Kelas</strong>${escapeHtml(s.kelas)}</div>
 <div class="detail-item"><strong>NISN</strong>${escapeHtml(s.nisn)}</div><div class="detail-item"><strong>Jenis surat</strong>${escapeHtml(s.jenis)}</div>
 <div class="detail-item"><strong>Dokumen</strong>${escapeHtml(s.berkas)}</div><div class="detail-item"><strong>Tanggal verifikasi</strong>${escapeHtml(s.tanggal)}</div>
 <div class="detail-item"><strong>Validator</strong>${escapeHtml(s.validator)}</div><div class="detail-item"><strong>Status</strong>${escapeHtml(s.status)}</div></div>
 <div class="preview-title">Pratinjau Dokumen</div>${preview}<div class="audit-note"><strong>Catatan audit</strong><p>${escapeHtml(s.catatan)}</p></div>`;
 $('modalBackdrop').classList.add('open');
}
function closeModal(){$('modalBackdrop').classList.remove('open')}
document.querySelectorAll('[data-status]').forEach(button=>button.addEventListener('click',()=>{activeStatus=button.dataset.status;page=1;document.querySelectorAll('[data-status]').forEach(b=>b.classList.toggle('selected',b===button));render()}));
['tableSearch','globalSearch','kelas','jenis','tanggal','validator','sort','pageSize'].forEach(id=>$(id).addEventListener('input',()=>{page=1;render()}));
$('firstPage').onclick=()=>{page=1;render()};$('prevPage').onclick=()=>{page=Math.max(1,page-1);render()};
$('nextPage').onclick=()=>{page++;render()};$('lastPage').onclick=()=>{page=Math.max(1,Math.ceil(filteredData().length/Number($('pageSize').value)));render()};
$('exportCsv').onclick=()=>{const headers=['Nomor Berkas','Nama Siswa','Kelas','NISN','Jenis Surat','Tanggal','Status','Validator','Catatan'];const rows=filteredData().map(s=>[s.nomor,s.nama,s.kelas,s.nisn,s.jenis,s.tanggal,s.status,s.validator,s.catatan]);const csv=[headers,...rows].map(r=>r.map(v=>`"${String(v).replace(/"/g,'""')}"`).join(',')).join('\n');const blob=new Blob(['\uFEFF'+csv],{type:'text/csv;charset=utf-8;'});const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download='histori-verifikasi.csv';a.click();URL.revokeObjectURL(url)};
render();
</script>
</body>
</html>
