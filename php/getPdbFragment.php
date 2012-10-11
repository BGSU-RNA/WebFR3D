<?php

//$chains = 'A,A,A';
//$nts = '300,301,302';

$chains = $_POST["ch"];
$nts = $_POST["nts"];
$pdb = $_POST["pdb"];

$a = explode(',', $chains);
$b = explode(',', $nts);
for ($i = 0; $i <= count($b); $i++) {
	$chain_corr{$b[$i]} = $a[$i];
}
$expr = '/^\s*(' . str_replace(',', '|', $nts) . ')\s*$/';

$filename = 'temp/' . uniqid() . ".pdb";
$myFile = '/Servers/rna.bgsu.edu/webfred/' . $filename;
$fh = fopen($myFile, 'w') or die("can't open file");

$handle = @fopen('./FR3D_submodule/PDBFiles/' . $pdb . '.pdb', "r");
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
        echo "Error: unexpected fgets() fail\n";
    }
    fclose($handle);
}
fclose($fh);

echo 'http://rna.bgsu.edu/webfred/' . $filename;

?>