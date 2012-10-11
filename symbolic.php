<?php include('php/include.php'); ?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=iso-8859-1">
    <title>Symbolic FR3D</title>
    <script src="./js/symbolic.js" type="text/javascript"></script>
    <link rel="stylesheet" type="text/css" href="./css/FR3D.css">
   	<link rel="stylesheet" media="all" type="text/css" href="./css/menu_style.css">
    <meta name="description" content="Symbolic search for RNA 3D motifs in PDB files">
    <meta name="keywords" content="WebFR3D,RNA,3D motifs,symbolic search">
    <?php include 'php/functions.php'; google_analytics();?>
	<!--greybox-->
	<script type="text/javascript">
	    var GB_ROOT_DIR = "<?=$config['webroot']?>/js/greybox/";
	</script>
	<script type="text/javascript" src="./js/greybox/AJS.js"></script>
	<script type="text/javascript" src="./js/greybox/AJS_fx.js"></script>
	<script type="text/javascript" src="./js/greybox/gb_scripts.js"></script>
	<link href="./js/greybox/gb_styles.css" rel="stylesheet" type="text/css">
	<!--greybox-->
</head>

<body>

<div class="menu">
	<ul>
	<li><a href="./index.html">WebFR3D</a></li>
	<li><a href="./symbolic.php">Symbolic Search</a></li>
	<li><a>Switch to</a>
		<ul>
			<li><a href="./geometric.php">Geometric search</a></li>
		</ul>
	</li>
	<li><a>Select an example</a>
		<ul>
			<li><a onclick="Hairpins()">All Hairpin Loops in 3I8I</a></li>
			<li><a onclick="Tetraloops()">All Tetraloops in 3I8I</a></li>
			<li><a onclick="InternalLoops()">All Internal Loops in 3I8I</a></li>
			<li><a onclick="TripleSheared()">Triple Sheared Internal Loop</a></li>
			<li><a onclick="cWW_tHWBaseTriples()">cWW_tHW Base Triples in 3I8I</a></li>
		</ul>
	</li>
	<li><a>Help</a>
		<ul>
			<li><a href="http://goo.gl/2vENT" target="_blank">In a new window</a></li>
		</ul>
	</li>
	</ul>
</div>
<noscript>Your browser does not support JavaScript. Please turn it on or update your browser</noscript>

<form action="php/Search.php" name="main" method="post" onSubmit="return Check(this.form)" id="mainform">
<input class='hidden' type='text' value='symbolic' name='symbolic'>
<div class='select left_side'>
	<div class='handle'>Structures to search</div>
	<div style="margin-top:1px" class='content'><?php makeListFromDatabase('where'); ?></div>
</div>

<div class = "dynamic">
    Number of nucleotides: <select id="NumNT" name="NT[]">
    <option value="2">2</option>
    <option value="3">3</option>
    <option value="4">4</option>
    <option value="5">5</option>
    <option value="6">6</option>
    <option value="7">7</option>
    <option value="8">8</option>
    <option value="9">9</option>
    <option value="10">10</option>
    <option value="11">11</option>
    <option value="12">12</option>
    <option value="13">13</option>
    <option value="14">14</option>
    <option value="15">15</option>
    </select>&nbsp;&nbsp;
    <input type="button" value="Interaction Matrix" onClick="CreateMatrix(this.form)">
    <input disabled="disabled" type="submit" id="submit" value="Search">
    <br><br>
    <div id="mat">

    </div>
<br>
</div>

<div class="options left_side">
	<div class='handle'>Options</div>
	<div class='content'>
    Email address (optional):<br>
    <input class='email' id="email" type="text" name="mail" onclick='ShowHelp(this)'><br><br>
    <input type="button" value="Reset" onClick="ResetAll()">
    </div>
</div>

</form>

<div class='help left_side'>
	<div class='handle'>Help</div>
	<div id='help' class='content'>Click an element to view help</div>
</div>

</body>
</html>