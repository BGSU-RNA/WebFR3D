<?php include('php/include.php'); ?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=iso-8859-1">
    <title>Geometric FR3D</title>
    <script src="./js/geometric.js" type="text/javascript"></script>
    <link rel="stylesheet" type="text/css" href="./css/FR3D.css" >
	<link rel="stylesheet" media="all" type="text/css" href="./css/menu_style.css" >
    <meta name="description" content="Geometric search for RNA 3D motifs in PDB files.Geometric queries of PDB files.Online version of FR3D.WebFR3D." >
    <meta name="keywords" content="WebFR3D,RNA,3D motifs,geometric search,RNA 3D structure,PDB" >
	<!--greybox-->
	<script type="text/javascript">
	    var GB_ROOT_DIR = "<?=$config['webroot']?>/js/greybox/";
	</script>
	<script type="text/javascript" src="./js/greybox/AJS.js"></script>
	<script type="text/javascript" src="./js/greybox/AJS_fx.js"></script>
	<script type="text/javascript" src="./js/greybox/gb_scripts.js"></script>
	<link href="./js/greybox/gb_styles.css" rel="stylesheet" type="text/css" >
	<!--greybox-->
	<script src='http://rna.bgsu.edu/jmol/Jmol.js' type='text/javascript'></script>
	<script type="text/javascript" src="./js/dom-drag.js"></script>
	<?php include 'php/functions.php'; google_analytics(); ?>
</head>

<body onLoad='SetUp();'>
<noscript>Your browser does not support JavaScript. Please turn it on or update your browser</noscript>
<div class="menu">
	<ul>
	<li><a href="./index.html">WebFR3D</a></li>
	<li><a href="./geometric.php">Geometric Search</a></li>
	<li><a>Switch to</a>
		<ul>
			<li><a href="./symbolic.php">Symbolic search</a></li>
		</ul>
	</li>
	<li><a>Select an example</a>
		<ul>
			<li><a onclick="TripleShearedTemplate()">Triple Sheared Internal Loop</a></li>
			<li><a onclick="SarcinTemplate()">Sarcin-ricin Internal Loop</a></li>
			<li><a onclick="TLoopTemplate()">T-loop Hairpin</a></li>
			<li><a onclick="Kt7Template()">Kink-turn 7</a></li>
			<li><a onclick="CLoopTemplate()">C-loop</a></li>
		</ul>
	</li>
	<li><a>Help</a>
		<ul>
			<li><a href="http://goo.gl/2vENT" target="_blank">In a new window</a></li>
		</ul>
	</li>
	</ul>
</div>

<form action="php/Search.php" name="main" method="post" onSubmit="return Check(this.form)" id="mainform">
	<input class='hidden' type='text' value='geometric' name='geometric'>

	<div class='select left_side'>
		<div class='handle'>Structures to search</div>
		<div style="margin-top:1px" class='content'><?php makeListFromDatabase('where'); ?></div>
	</div>
	<div class="options left_side">
		<div class='handle'>Options</div>
		<div class='content'>
		    Discrepancy: <input id="disc" class="discrepancy" type="text" name="disc" value="0.4" size="6" onChange="ValidateDiscrepancy()" onClick="ShowHelp(this)"> <br>
		    Email address (optional):
		    <input id="email" type="text" name="mail" class="email" onClick="ShowHelp(this)">
		    <input type="button" value="Reset" onClick="ResetAll()" >
	    </div>
	</div>
	<div class='help left_side'>
		<div class='handle'>Help</div>
		<div id='help' class='content'>Click an element to view help</div>
	</div>

	<div class = "dynamic">
	    Query PDB: <?php makeListFromDatabase('what'); ?> &nbsp;
	    Query nucleotides: <input id="NT" type="text" class='ntsinput' name="nucleotides" onChange="LookUpNTs(this,'asynch')" onClick="ShowHelp(this)">
	    <input type="button" value="Interaction Matrix" onClick="CreateMatrix()">
	    <input type="button" value="View Query" onClick="ViewQuery()" disabled='disabled' id='view'>
	    <input disabled="disabled" type="submit" id="submit" value="Search">
	    <br><br>
	    <div id="mat"></div>
		<br>
	</div>
</form>

<div id="root" class='rootdiv' style="left:220px; top:100px;">
	<div id="handle" class='handle'>Drag<img src="./js/greybox/w_close.gif" alt="Close" id='closewin' onClick='HideJmolDiv()'></div>
	<div id='jmol' class='content'></div>
</div>
<script type="text/javascript" language="javascript">
	var theHandle = document.getElementById("handle");
	var theRoot   = document.getElementById("root");
	Drag.init(theHandle, theRoot);
</script>

</body>
</html>