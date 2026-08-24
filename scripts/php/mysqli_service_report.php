<?php
// Get main loaded php.ini
$loaded = php_ini_loaded_file();
if ($loaded) {
    echo "Main php.ini: " . $loaded . "<br>\n";
} else {
    echo "No main php.ini loaded.<br>\n";
}

// Get extra scanned ini files
$scanned = php_ini_scanned_files();
if ($scanned) {
    $files = explode(',', $scanned);
    echo "Scanned files:\n<ul>\n";
    foreach ($files as $file) {
        echo "<li>" . trim($file) . "</li>\n";
    }
    echo "</ul>\n";
} else {
    echo "No additional scanned ini files.<br><br>\n";
}

// ==========================================
// SQL Extension Status Report
// ==========================================
echo "<h3>SQL Driver Status</h3>\n<ul>\n";

// Check MySQLi Extension
if (extension_loaded('mysqli')) {
    echo "<li><strong>MySQLi Extension:</strong> <span style='color:green;'>ENABLED</span></li>\n";
} else {
    echo "<li><strong>MySQLi Extension:</strong> <span style='color:red;'>DISABLED (Missing or unchecked in php.ini)</span></li>\n";
}

// Check PDO MySQL Extension
if (extension_loaded('pdo_mysql')) {
    echo "<li><strong>PDO MySQL Extension:</strong> <span style='color:green;'>ENABLED</span></li>\n";
} else {
    echo "<li><strong>PDO MySQL Extension:</strong> <span style='color:red;'>DISABLED (Missing or unchecked in php.ini)</span></li>\n";
}

// Check Native Driver
if (extension_loaded('mysqlnd')) {
    echo "<li><strong>MySQL Native Driver (mysqlnd):</strong> <span style='color:green;'>AVAILABLE</span></li>\n";
} else {
    echo "<li><strong>MySQL Native Driver (mysqlnd):</strong> <span style='color:red;'>UNAVAILABLE</span></li>\n";
}

echo "</ul>\n";
?>
