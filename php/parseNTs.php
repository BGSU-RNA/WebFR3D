<?php
error_reporting(E_ALL);

if (isset($_POST['nucleotides'])) {    
    $list = $_POST['nucleotides'];
    if ($list == 'all') {
        return;    
    }
    $pdb = $_POST['PDBquery'];
//    $ch = $_POST['ch'];
    parseNTs($pdb,$list);
}


//echo 'Problem';

////////////////////////////////
//////// Functions /////////////
////////////////////////////////

function parseNTs($pdb,$list)
{
    $MAXNT = 25;
    //Database parameters
    $dbhost = "localhost";
    $dbuser = "webfr3d";
    $dbpass = "HKc4aLx6K7nVtG2U";
    $dbname = "PDB";
    //Connect to MySQL Server
    $link = mysql_connect($dbhost, $dbuser, $dbpass);
    mysql_select_db($dbname,$link) or die(mysql_error());
            
    $list = preg_replace('/ +/',',',$list);
    $list = preg_replace('/,+/',',',$list);
    $units = explode(",", $list);
    $NTs = $blocks = array();
    for ($i = 0; $i < count($units); $i++) {
        if (preg_match('/^-*\d+\w*$/',$units[$i])) { //negative nucleotides are OK
            array_push($NTs,$units[$i]);
        } elseif (preg_match('/-*\d+\w*:-*\d+\w*/',$units[$i])) {
            array_push($blocks,$units[$i]);
        } else {
            echo "Please check this fragment: $units[$i]";
            return;
        }
    }
    //look up single nucleotides in the database
    $problems = CheckSingleNucleotideList($NTs,$pdb,$link);
    if (strlen($problems) > 0) {
        echo $problems;
        return;
    }
    //parse nucleotide ranges
    $expanded_nts = array();
    for ($i = 0; $i < count($blocks); $i++) {
        $expand = ExpandRange($blocks[$i],$pdb,$link);
        if (is_string($expand)) { //contains error messages
            echo $expand;
            return;
        }
        elseif (is_array($expand)) { //contains nucleotides
            $expanded_nts = array_merge($expanded_nts, $expand);
        }
    }
    
    $final_list_array = array_unique(array_merge($NTs,$expanded_nts));
    if (count($final_list_array) > $MAXNT) {
    	echo "Please limit your search to 25 nucleotides";
    	return;
    }
    $final_list_string = implode(',',$final_list_array);
    echo($final_list_string);
    mysql_close($link);
    return $final_list_string;
}

function CheckSingleNucleotideList($NTs,$pdb,$link) {

    $pdb = mysql_real_escape_string($pdb);
//    $ch = mysql_real_escape_string($ch);

    $errors = array();
    for ($i = 0; $i < count($NTs); $i++) {
        $NTs[$i] = mysql_real_escape_string($NTs[$i]);
        $query = "SELECT * FROM `Nucleotides_with_ind` WHERE PDB = '$pdb' AND Nt='$NTs[$i]'";
        $result = mysql_query($query,$link) or $return = mysql_error();
        if ((mysql_num_rows($result) == NULL) or (mysql_num_rows($result) == 0)) {
            array_push($errors,$NTs[$i]);
        }
    }

    $problems = '';
    if (count($errors) > 0) {
        if (count($errors)==1) {
            $problems = "No nucleotide ";
        } else {
            $problems = "No nucleotides ";
        }
        for ($i = 0; $i < min(20,count($errors)); $i++) {
            $problems .= $errors[$i] . ',';
        }
        $problems = substr($problems,0,-1);
//        $problems .= " in chain $ch in $pdb";
        $problems .= " in $pdb";        
    }
    return $problems;
}

function ExpandRange($block,$pdb,$link) {

    $pdb = mysql_real_escape_string($pdb);
//    $ch = mysql_real_escape_string($ch);

    $problems = '';
    preg_match('/(\d+\w*)[:-](\d+\w*)/',$block,$matches);
    $query = "SELECT ind FROM `Nucleotides_with_ind` WHERE PDB = '$pdb' AND Nt ='$matches[1]'";
    $result = mysql_query($query,$link) or die(mysql_error());
    $row = mysql_fetch_array($result, MYSQL_ASSOC);
    if (isset($row["ind"])) {
       $start = $row["ind"];
    }
    else {
        $problems .= "Nucleotide $matches[1] doesn't exist ($block)\n";
    }

    $query = "SELECT ind FROM `Nucleotides_with_ind` WHERE PDB = '$pdb' AND Nt ='$matches[2]'";
    $result = mysql_query($query,$link) or die(mysql_error());
    $row = mysql_fetch_array($result, MYSQL_ASSOC);
    if (isset($row["ind"])) {
       $stop = $row["ind"];
    }
    else {
        $problems .= "Nucleotide $matches[2] doesn't exist ($block)\n";
    }
    if (strlen($problems) > 0) {
        return $problems;
    }

    $expand = array();
    $range = array($start,$stop);
    sort($range,SORT_NUMERIC);
    for ($j = $range[0]; $j <= $range[1]; $j++) {
        $query = "SELECT Nt FROM `Nucleotides_with_ind` WHERE PDB = '$pdb' AND ind = '$j'";
        $result = mysql_query($query,$link) or die(mysql_error());
        $row = mysql_fetch_array($result, MYSQL_ASSOC);
        array_push($expand,$row["Nt"]);
    }
    return $expand;
}


?>
