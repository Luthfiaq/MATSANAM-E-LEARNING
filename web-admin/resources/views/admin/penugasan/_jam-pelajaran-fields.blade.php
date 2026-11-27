@php
    $selectedJamMulai = old('jam_mulai_ke', $jamMulaiKe ?? ($legacyJamMulai !== null ? 'legacy' : ''));
    $selectedJamSelesai = old('jam_selesai_ke', $jamSelesaiKe ?? ($legacyJamSelesai !== null ? 'legacy' : ''));
    $selectClass = 'w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20';
    $legacyMulaiLabel = $legacyJamMulai !== null ? str_replace(':', '.', substr($legacyJamMulai, 0, 5)) : null;
    $legacySelesaiLabel = $legacyJamSelesai !== null ? str_replace(':', '.', substr($legacyJamSelesai, 0, 5)) : null;
@endphp

<!-- Jam Mulai -->
<div>
    <label for="jam_mulai_ke" class="block text-sm font-medium text-gray-700 mb-2">
        Jam Mulai <span class="text-red-500">*</span>
    </label>
    <select
        id="jam_mulai_ke"
        name="jam_mulai_ke"
        required
        class="{{ $selectClass }}"
    >
        <option value="">Pilih Jam Mulai</option>
        @if($legacyJamMulai !== null)
            <option value="legacy" {{ (string) $selectedJamMulai === 'legacy' ? 'selected' : '' }}>
                Waktu tersimpan: {{ $legacyMulaiLabel }} (di luar slot standar)
            </option>
        @endif
        @foreach($jamPelajaran as $jamKe => $slot)
            <option value="{{ $jamKe }}" {{ (string) $selectedJamMulai === (string) $jamKe ? 'selected' : '' }}>
                Jam ke-{{ $jamKe }} ({{ str_replace(':', '.', $slot['mulai']) }} - {{ str_replace(':', '.', $slot['selesai']) }})
            </option>
        @endforeach
    </select>
    @error('jam_mulai_ke')
        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
    @enderror
</div>

<!-- Jam Selesai -->
<div>
    <label for="jam_selesai_ke" class="block text-sm font-medium text-gray-700 mb-2">
        Jam Selesai <span class="text-red-500">*</span>
    </label>
    <select
        id="jam_selesai_ke"
        name="jam_selesai_ke"
        required
        class="{{ $selectClass }}"
    >
        <option value="">Pilih Jam Selesai</option>
        @if($legacyJamSelesai !== null)
            <option value="legacy" {{ (string) $selectedJamSelesai === 'legacy' ? 'selected' : '' }}>
                Waktu tersimpan: {{ $legacySelesaiLabel }} (di luar slot standar)
            </option>
        @endif
        @foreach($jamPelajaran as $jamKe => $slot)
            <option value="{{ $jamKe }}" {{ (string) $selectedJamSelesai === (string) $jamKe ? 'selected' : '' }}>
                Jam ke-{{ $jamKe }} ({{ str_replace(':', '.', $slot['mulai']) }} - {{ str_replace(':', '.', $slot['selesai']) }})
            </option>
        @endforeach
    </select>
    @error('jam_selesai_ke')
        <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
    @enderror
</div>
