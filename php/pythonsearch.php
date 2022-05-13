<?php
error_reporting(E_ALL);

include('config.php');
include('pythonfunctions.php');
include('parseNTs.php');

$root = $config['root'];
$url  = $config['webroot'];

$uid = uniqid();
$path = "$root/webfr3d/Results/{$uid}";
mkdir($path);
chmod($path,0777);

createPlaceHolder($uid,$root);
$location = "Location: $url/webfr3d/Results/{$uid}/{$uid}.html";
header($location);

$list = $_POST["nucleotides"];
$pdb = $_POST["PDBquery"];
$_POST["nucleotides"] = parseNTs($pdb,$list);

$_POST = process_nrlists($_POST);

createJSONQueryFile($_POST, $uid, $root);

?>
