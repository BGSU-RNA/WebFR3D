<?php

include 'include.php';

$nts    = $_POST["nts"];
$chains = $_POST["ch"];
$pdb    = $_POST["pdb"];

$download = False;

if (!isset($nts)) {
    $nts = $_GET["nts"];
    $download = True;
}

if (!isset($chains)) {
    $chains = $_GET["ch"];
}

if (!isset($pdb)) {
    $pdb = $_GET["pdb"];
}

$chain_list = explode(',', $chains);
$nt_list = explode(',', $nts);
$count = count($nt_list);

$query = "SELECT `coordinates` FROM `pdb_coordinates` WHERE pdb = '$pdb' AND (";
for ($i = 0; $i < $count; $i++) {
    if ($i == $count - 1) {
        $query .= "(`number` = $nt_list[$i] and `chain` = '$chain_list[$i]')";
    } else {
        $query .= "(`number` = $nt_list[$i] and `chain` = '$chain_list[$i]') OR ";
    }
}
$query .= ');';

$result = mysql_query($query) or die(mysql_error());

$return = '';
while($row = mysql_fetch_array($result)){
    $return .= $row[coordinates] . "\n";
}

mysql_close($link);

// force download
if ($download) {
    header('Content-Disposition: attachment; filename=coordinates.pdb');
}

echo $return;

?>