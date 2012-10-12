<?php
include 'include.php';
// Retrieve data from Query String
$pdb = mysql_real_escape_string($_POST['pdb']);

$query = "SELECT * FROM `pdb_info` WHERE structureId = '$pdb' limit 1;";
$result = mysql_query($query) or die(mysql_error());

$row = mysql_fetch_array($result);

$return = "<u>Title</u>: $row[structureTitle]<br>";
$return .= "<u>Resolution</u>: $row[resolution]<br>";
$return .= "<u>Method</u>: $row[experimentalTechnique]<br>";
$return .= "<u>Organism</u>: $row[source]<br><br>";
$return .= "<a href = 'http://www.pdb.org/pdb/explore/explore.do?structureId=$pdb' target='_blank'>More</a><br>";
echo $return;
mysql_close($link);

?>