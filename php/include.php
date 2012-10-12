<?php

include('config.php');

//Connect to MySQL Server
$link = mysql_connect($config['dbhost'], $config['dbuser'], $config['dbpass']);
//Select Database
mysql_select_db($config['dbname']) or die(mysql_error());

?>