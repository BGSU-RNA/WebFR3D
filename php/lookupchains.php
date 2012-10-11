<?php
$dbhost = "localhost";
$dbuser = "webfr3d";
$dbpass = "HKc4aLx6K7nVtG2U";
$dbname = "PDB";
//Connect to MySQL Server
$link = mysql_connect($dbhost, $dbuser, $dbpass);
//Select Database
mysql_select_db($dbname) or die(mysql_error());
// Retrieve data from Query String
$pdb = mysql_real_escape_string($_GET['pdb']);
$list = mysql_real_escape_string($_GET['nts']);
//build query
$nts = explode(",", $list);
//$return = '<div class="chains" id="chains"><table><tr>';	
$return = '<td class="rowheader"></td>';
for ($i = 0; $i < count($nts); $i++) {
    $query = "SELECT DISTINCT Chain FROM `Nucleotides_with_ind` WHERE PDB = '$pdb' AND Nt='$nts[$i]'";
    $result = mysql_query($query) or die(mysql_error());

    $c = 0;
    $options = '';
    while($row = mysql_fetch_array($result)){
    	$options .= "<option value='$row[Chain]' >$row[Chain]</option>";
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
//$return .= '</table></tr></div>';




echo $return;
mysql_close($link);

?>