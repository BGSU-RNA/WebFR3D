<html>

<head>
    <title>FR3D RNAO</title>
    <script src="./rnao.js" type="text/javascript"></script>
    <link rel="stylesheet" type="text/css" href="./css/FR3D.css" >
   	<link rel="stylesheet" media="all" type="text/css" href="./css/menu_style.css" />
    <meta name="description" content="Search for RNA 3D motifs in PDB files with RNAO terms" />
    <meta name="keywords" content="WebFR3D,RNA,3D motifs,search,RNAO,ontology" />
    <?php include 'php/functions.php'; google_analytics();
     ?>
</head>

<body>

<div class="menu">
	<ul>
	<li><a href="./index.html">WebFR3D</a></li>
	<li><a href="./rnao.php">RNAO Search</a></li>
	<li><a>Switch to</a>
		<ul>
			<li><a href="./symbolic.php">Symbolic search</a></li>
			<li><a href="./geometric.php">Geometric search</a></li>
		</ul>
	</li>
<!--	<li><a>Select a template</a>
		<ul>
			<li><a onclick="Tloop()">T-loop</a></li>
		</ul>
	</li>	-->
	</ul>
</div>
<noscript>Your browser does not support JavaScript. Please turn it on or update your browser</noscript>

<h1>RNAO WebFR3D is no longer supported. Please use <a href='http://rna.bgsu.edu/webfr3d/symbolic.php'>symbolic</a> or
<a href='http://rna.bgsu.edu/webfr3d/symbolic.php'>geometric</a> WebFR3D instead.</h1>
<!--
<form action="functions/php/Search.php" name="main" method="post" onSubmit="return Check(this.form)">

<input class='hidden' type='text' value='rnao' name='rnao'/>
<div class = "select">
Structures to search:<br><br>
<?php makeListFromDatabase('where'); ?>
</div>

<div class="dynamic">
RNAO query:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input disabled="disabled" type="submit" id="submit" value="Search">
<br><br>
<textarea name="rnao_query" id="rnao_input" onChange="return EnableSubmit(this.form)"></textarea>
</div>

<div class="disc">
    Email address (optional):<br>
    <input id="email" type="text" name="mail"/><br><br>
    <input type="button" value="Reset" onClick="ResetAll()" />
</div>

</form>
-->
</body>
</html>