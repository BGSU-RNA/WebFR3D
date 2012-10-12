<?php

function google_analytics() {

echo <<<EOT
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-9081629-5']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
EOT;

}


function makeListFromDatabase($mode) {

    include('include.php');

    $query = "SELECT DISTINCT structureId FROM `pdb_info`;";
    $result = mysql_query($query) or die(mysql_error());
    if ( $mode == 'what' )
    {
        echo "<select class=\"what\" name=\"PDBquery\" id=\"PDB\">\n";
        echo "<option value=\"----\">----</option>\n";
    }
    else
    {
        echo "<select class='where' id='SelectElem' multiple='multiple' name='wheretosearch[]' onclick='ShowHelp(this)'>\n";
    }
    if ( $mode == 'where' ) {
		if ($handle = opendir('./lists')) {
		    while (false !== ($file = readdir($handle))) {
		        if ($file != "." && $file != ".." && $file != ".DS_Store") {
		        	$file = substr($file, 0, strrpos($file, '.'));
			        echo "<option value=\"$file\">$file</option>\n";
		        }
		    }
		    closedir($handle);
		}
	}

    while($row = mysql_fetch_array($result)){
		echo "<option value=\"$row[structureId]\">$row[structureId]</option>\n";
    }
    echo "</select>\n";

    mysql_close($link);
}

?>