<?php

$file = 'C:/Users/Chrisna/Documents/Projek S3/Projek/MATSANAM-E-LEARNING/web-admin/app/Http/Controllers/Admin/NilaiController.php';
$content = file_get_contents($file);
$bytes = array_values(unpack('C*', $content));

echo "First 200 bytes:\n";
for ($i = 0; $i < min(200, count($bytes)); $i++) {
    printf("%02X ", $bytes[$i]);
    if (($i + 1) % 16 == 0) echo "\n";
}
echo "\n\n";

echo "Total bytes: " . count($bytes) . "\n";

// Check for BOM
if (count($bytes) >= 3 && $bytes[0] == 0xEF && $bytes[1] == 0xBB && $bytes[2] == 0xBF) {
    echo "BOM detected!\n";
} else {
    echo "No BOM\n";
}

// Show lines around 77
$lines = explode("\n", file_get_contents($file));
echo "\nLines 70-82:\n";
for ($i = 69; $i <= 81 && $i < count($lines); $i++) {
    echo ($i+1) . ": [" . strlen($lines[$i]) . "] " . $lines[$i] . "\n";
}