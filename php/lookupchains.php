<?php

include('include.php');

// Retrieve data from Query String
$pdb = mysql_real_escape_string($_GET['pdb']);
$list = mysql_real_escape_string($_GET['nts']);
//build query
$nts = explode(",", $list);

$return = '<td class="rowheader"></td>';
for ($i = 0; $i < count($nts); $i++) {
    $query = "SELECT DISTINCT `chain` FROM `pdb_coordinates` WHERE pdb = '$pdb' AND number='$nts[$i]' AND unit IN ('A', 'C', 'G', 'U');";
    $result = mysql_query($query) or die(mysql_error());

    $c = 0;
    $options = '';
    while($row = mysql_fetch_array($result)){
    	$options .= "<option value='$row[chain]' >$row[chain]</option>";
    	$c++;
    }
    if ( $c == 0 ) {
        $return .= "<td><select class='chain warning' name='chain_$i' value='----' id='warning' disabled='disabled'>";
    	$return .= "<option value='----'>----</option>";
    }
    elseif ($c == 1) {
        $return .= "<td><select class='chain' name='chain_$i' id='chain_$i' disabled='disabled'>";
        $return .= $options;
    }
    else {
        $return .= "<td><select class='chain' name='chain_$i' id='chain_$i'>";
    	$return .= $options;
    }

    $return .= '</select></td>';
}

echo $return;
mysql_close($link);

?>