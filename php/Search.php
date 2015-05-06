<?php
error_reporting(E_ALL);

include('config.php');
include('functions.php');
include('parseNTs.php');

$root = $config['root'];
$url  = $config['webroot'];

$uid = uniqid();
$path = "$root/webfr3d/Results/{$uid}";
mkdir($path);
chmod($path,0777);

createPlaceHolder($uid,$root);
$location = "Location: $url/webfr3d/Results/{$uid}";
header($location);

$list = $_POST["nucleotides"];
$pdb = $_POST["PDBquery"];
$_POST["nucleotides"] = parseNTs($pdb,$list);

$_POST = process_nrlists($_POST);

if ( isset( $_POST["geometric"] ) ) {
	createGeometricQueryFile($_POST, $uid, $root);
}
elseif ( isset( $_POST["symbolic"] ) ) {
	createSymbolicQueryFile($_POST, $uid, $root);
}

?>
