<?php

$config['webroot'] = 'http://rna.bgsu.edu/webfred';
$config['root'] = '/Servers/rna.bgsu.edu/webfred';
$config['pdbs'] = '/Servers/rna.bgsu.edu/nrlist/pdb';

$dbhost = "localhost";
$dbuser = "webfr3d";
$dbpass = "HKc4aLx6K7nVtG2U";
$dbname = "PDB";

//Connect to MySQL Server
$link = mysql_connect($dbhost, $dbuser, $dbpass);
//Select Database
mysql_select_db($dbname) or die(mysql_error());

?>