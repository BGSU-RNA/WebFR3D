<?php

include('include.php');

$nts    = $_POST["nts"];
$pdb    = $_POST["pdb"];
$chains = $_POST["ch"];

$a = explode(',', $chains);
$b = explode(',', $nts);
for ($i = 0; $i <= count($b); $i++) {
	$chain_corr{$b[$i]} = $a[$i];
}
$expr = '/^\s*(' . str_replace(',', '|', $nts) . ')\s*$/';

$filename = 'temp/' . uniqid() . ".pdb";
$myFile = $config['root'] . '/' . $filename;
$fh = fopen($myFile, 'w') or die("can't open file");

$handle = @fopen( $config['pdbs'] . '/' . $pdb . '.pdb', "r");
if ($handle) {
    while (($line = fgets($handle, 4096)) !== false) {
		$pos = strpos($line, 'ATOM');
		if ($pos !== false) {
	    	if (preg_match($expr,substr($line, 22, 5),$match)) {
	    		if (substr($line, 21, 1)  == $chain_corr{$match[1]}) {
					fwrite($fh, $line);
	    		}
	    	}
    	}
    }
    if (!feof($handle)) {
        echo "Error: unexpected fgets() failure\n";
    }
    fclose($handle);
}
fclose($fh);

echo $config['webroot'] . '/' . $filename;

?>