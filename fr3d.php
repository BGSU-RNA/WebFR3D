<?php
include('php/include.php');
include('php/loadquery.php');
if (isset($_GET['id'])) {
//    echo $_GET['id'];

	$root = $config['root'];
//	echo $root;
    $qdata = loadJSONQueryFile($_GET['id'],$root);
//    echo $qdata;

} else {
	$qdata = '';
    // Fallback behaviour goes here
}
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=iso-8859-1">
    <title>WebFR3D search</title>
    <script src="./js/inputpage.js" type="text/javascript"></script>
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
    <script src="<?=$config['webroot']?>/jmol/Jmol.js" type='text/javascript'></script>
	<script type="text/javascript" src="./js/dom-drag.js"></script>
	<?php include 'php/pythonfunctions.php'; google_analytics(); ?>
    <link rel="shortcut icon" href="http://rna.bgsu.edu/rna3dhub/icons/F_icon.png">
</head>

<body onLoad='FillQueryParameters(<?=$qdata?>,this.form);'>
<noscript>Your browser does not support JavaScript. Please turn it on or update your browser</noscript>
<div class="menu">
	<ul>
    <li><a href="<?= $config['webroot'] . "/webfr3d" ?>">WebFR3D</a></li>
	<li><a>Symbolic search examples</a>
		<ul>
			<li><a onclick="TripleShearedSymbolic()">Triple sheared internal loop</a></li>
			<li><a onclick="AMinorSymbolic()">A-minor motif</a></li>
			<li><a onclick="GNRASymbolic()">GNRA hairpin</a></li>
<!--			<li><a onclick="SarcinTemplate()">Sarcin-ricin Internal Loop</a></li>
			<li><a onclick="TLoopTemplate()">T-loop Hairpin</a></li>
			<li><a onclick="Kt7Template()">Kink-turn 7</a></li>
			<li><a onclick="CLoopTemplate()">C-loop</a></li>
			-->
		</ul>
	</li>
	<li><a>Mixed search examples</a>
		<ul>
			<li><a onclick="TripleShearedMixed()">Triple Sheared internal loop</a></li>
			<li><a onclick="SarcinCore5Mixed()">Sarcin-ricin 5 nucleotide core</a></li>
			<li><a onclick="SarcinCore7Mixed()">Sarcin-ricin 7 nucleotide core</a></li>
<!--			<li><a onclick="TLoopTemplate()">T-loop Hairpin</a></li>
			<li><a onclick="Kt7Template()">Kink-turn 7</a></li>
			<li><a onclick="CLoopTemplate()">C-loop</a></li>
		-->
		</ul>
	</li>
	<li><a>Geometric search examples</a>
		<ul>
			<li><a onclick="SarcinCore5Geometric()">Sarcin-ricin 5 nucleotide core</a></li>
			<li><a onclick="AMinorGeometric()">A-minor interaction</a></li>
			<li><a onclick="cWWAminoAcidGeometric()">Watson-Crick basepair with aa</a></li>

<!--			<li><a onclick="TLoopTemplate()">T-loop Hairpin</a></li>
			<li><a onclick="Kt7Template()">Kink-turn 7</a></li>
			<li><a onclick="CLoopTemplate()">C-loop</a></li>
-->
		</ul>
	</li>
	<li><a>Help</a>
		<ul>
			<li><a href="https://www.bgsu.edu/research/rna/web-applications/webfr3d/instructions-and-help.html" target="_blank">In a new window</a></li>
		</ul>
	</li>

	<li><a>Links</a>
		<ul>
            <li><a href="<?= $config['webroot'] ?>">RNA BGSU group</a></li>
            <li><a href="<?= $config['webroot'] . "/rna3dhub" ?>">RNA 3D Hub</a></li>
            <li><a href="<?= $config['webroot'] . "/FR3D" ?>">FR3D</a></li>
			<li><a href="https://github.com/BGSU-RNA/WebFR3D">WebFR3D on Github</a></li>
		</ul>
	</li>

	</ul>
</div>

<form action="php/pythonsearch.php" name="main" method="post" onSubmit="return Check(this.form)" id="mainform">
	<input class='hidden' type='text' value='geometric' name='geometric'>

<div id = "query_description" style = "margin-bottom: 20px;">
<h2 style = "margin-top: 0px;">FR3D search page</h2>
</div>

	<table>
	<tr>
	<td><font size="+2">1.</font></td><td>

		Describe the motif you are looking for, using (a), (b), or both.

	</td></tr><tr><td><font size="+1">a.</font></td><td>
		For a purely symbolic search, specify the number of positions in the motif.
			<select id="NumNT" name="NT[]" onChange="ValidateNumNT()" >
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

	</td></tr><tr><td valign="top"><font size="+1">b.</font></td><td>
		If you have a set of nucleotides that form the motif, and you want to search for other instances
	    according to the geometry of the motif, fill in the next two boxes.<br>

	    Unit IDs, separated by commas: <input id="UnitIDs" type="text" class='name' name="UnitIDs" size="120" onChange="ValidateUnitIDs()" onClick="ShowHelp(this)">

	    <input disabled="disabled" type="button" id="viewquery" value="View query" onClick="ViewQuery()">

	    <br>
	    Maximum geometric discrepancy: <input id="disc" class="discrepancy" type="text" name="disc" value="" size="6" onChange="ValidateDiscrepancy()" onClick="ShowHelp(this)">

	</td></tr><tr><td valign="top"><font size="+2">2.</font></td><td>
	    To add symbolic constraints, click the Interaction Matrix button:
	    <input type="button" value="Interaction Matrix" onClick="CreateMatrix(this.form)"><br>
	    <div id="mat"></div>

	</td></tr><tr><td valign="top"><font size="+2">3.</font></td><td>
	    What structures from the Protein Data Bank should be searched?  Use (a), (b), or both.
	</td></tr><tr><td valign="top"><font size="+1">a.</font></td><td>
	    List individual structures (like 6ZMI) or chains (like 6ZMI|1|L5), separated by commas:
		<input id="StructuresToSearch" type="text" size="100" name="StructuresToSearch" onClick="ShowHelp(this)">
	</td></tr><tr><td valign="top"><font size="+1">b.</font></td><td>
		Specify a <a href="http://rna.bgsu.edu/rna3dhub/nrlist">representative set</a> to search by typing the release number:
		<input id="RepSetRelease" type="text" class='ntsinput' name="RepSetRelease" onClick="ShowHelp(this)">
		and the resolution cutoff:
            <select id='RepSetResolution' name='RepSetResolution'>
              <option value=''></option>
              <option value='1.5A'>1.5&Aring X-ray</option>
              <option value='2.0A'>2.0&Aring X-ray and cryo-EM</option>
              <option value='2.5A'>2.5&Aring X-ray and cryo-EM</option>
              <option value='3.0A'>3.0&Aring X-ray and cryo-EM</option>
              <option value='3.5A'>3.5&Aring X-ray and cryo-EM</option>
              <option value='4.0A'>4.0&Aring X-ray and cryo-EM</option>
              <option value='20.0A'>X-ray and cryoEM</option>
              <option value='NMR'>NMR</option>
              <option value='all'>X-ray and cryoEM and NMR</option>
            </select><br>

        <br>
	</td></tr><tr><td valign="top"><font size="+2">4.</font></td><td>
	    Give your search a name (optional, only ASCII characters):
	    <input id="SearchName" type="text" name="SearchName" class="name" size="100" onClick="ShowHelp(this)">

	</td></tr><tr><td valign="top"><font size="+2">5.</font></td><td>
	    Email address for persistent link to results (optional):
	    <input id="email" type="text" name="mail" class="email" size="20" onClick="ShowHelp(this)">

	</td></tr><tr><td valign="top"><font size="+2">6.</font></td><td>
	    When you are ready to launch the search, click the Search button:
	    <input disabled="disabled" type="submit" id="submit" value="Search">
	    <br><br>

	</td></tr><tr><td valign="top"></td><td>
	    Clear the entire form to start again:
	    <input type="button" value="Reset" onClick="ResetAll()" >

	</div>

	<div>
		<div class='handle'>Help</div>
		<div id='help' class='content'>Click an element to view help</div>
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
