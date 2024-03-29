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

/*
    Input: $_POST or $_GET arrays. Look for 'pdb_ids' array or a single entry.
    Output: an array of pdb ids or an empty array.
*/
function get_submitted_pdb_files() {

    // use either POST or GET
    if ( isset($_POST['pdb_ids']) and count($_POST['pdb_ids']) > 0 ) {
        $submitted = explode(',', $_POST['pdb_ids']);
    } elseif ( isset($_GET['pdb_ids']) and count($_GET['pdb_ids']) > 0 ) {
        $submitted = explode(',', $_GET['pdb_ids']);
    } else {
        $submitted = array();
    }

    $pdb_ids = array();
    if ( count($submitted) > 0 ) {
        foreach($submitted as $pdb_id) {
            // check each entry with a regex
            if ( preg_match('/[A-z0-9]{4}/', $pdb_id ) ) {
                $pdb_ids[] = $pdb_id;
            }
        }
    }

    return $pdb_ids;
}


function get_all_pdb_files($mode, $selected = NULL)
{
    include('include.php');

    $query = "SELECT DISTINCT structureId FROM `pdb_info`;";
    $result = mysql_query($query) or die(mysql_error());

    while($row = mysql_fetch_array($result)){
        $sid = $row['structureId'];
        if ( $selected and in_array($sid , $selected) ) {
            echo "<option value=\"$sid\" selected>$sid</option>\n";
        } else {
            echo "<option value=\"$sid\">$sid</option>\n";
        }
    }
    echo "</select>\n";

    mysql_close($link);
}


function get_nr_releases()
{
    include('include.php');

    $query = "SELECT `id` FROM `nr_releases` ORDER BY `date` DESC;";
    $result = mysql_query($query) or die(mysql_error());

    $i = 0;
    while($row = mysql_fetch_array($result)){
        if ( $i == 0 ) {
    		echo "<option value=\"$row[id]\">Current</option>\n";
    		$i = 1;
		} else {
    		echo "<option value=\"$row[id]\">$row[id]</option>\n";
		}
    }

    mysql_close($link);
}

function get_nr_list_for_matlab($release_id, $resolution)
{
    include('include.php');

    $query = "SELECT `id` FROM `nr_pdbs` WHERE `rep` = 1 AND `release_id` = '$release_id' AND `class_id` LIKE 'NR_{$resolution}%';";
    $result = mysql_query($query) or die(mysql_error());
    $text = '';
    while($row = mysql_fetch_array($result)){
        $text .= "$row[id]\n";
    }
    mysql_close($link);

    return $text;
}

function createJSONQueryFile($_POST, $id, $root)
{

    // ============== JSON output ============================
//    $JSONFileName = "$root/InputScript/Input/Query_{$id}.json";
    $JSON = new StdClass();

    if (($_POST["UnitIDs"] != '') && (strpos($_POST["UnitIDs"],'|') !== false))
    {
        $JSON->type = 'mixed';
        $JSON->discrepancy = floatval($_POST["disc"]);
        $JSON->unitID = explode(",",$_POST['UnitIDs']);
        $JSON->numpositions = count($JSON->unitID);
    } else {
        $JSON->type = 'symbolic';
        $JSON->numpositions = (int)$_POST["NT"][0];
    }

    $JSON->queryID = "{$id}";
    $JSON->name = $_POST["SearchName"];

    $JSON->email = "{$_POST["mail"]}";

    $numpdb = count($_POST['StructuresToSearch']);

    $JSON->structuresToSearch = $_POST['StructuresToSearch'];
    $JSON->repSetRelease = $_POST['RepSetRelease'];
    $JSON->repSetResolution = $_POST['RepSetResolution'];

    $sf = $_POST['StructuresToSearch'];

    if ( $_POST['RepSetRelease'] != '') {
        if ($_POST['RepSetResolution'] != '') {
           $sf = $sf .",http://rna.bgsu.edu/rna3dhub/nrlist/download/".$_POST["RepSetRelease"]."/".$_POST["RepSetResolution"]."/csv";
        }
    }

    $JSON->searchFiles = explode(",",$sf);

    $mat = array_chunk($_POST['mat'],sqrt(count($_POST['mat'])));
    $JSON->interactionMatrix = $mat;

    $JSONstring = json_encode($JSON);

    $JSONFileName = "$root/Results/{$id}/Query_{$id}.json";
    $JSONfh = fopen($JSONFileName, 'w') or die("Can't open Query file");
    fwrite($JSONfh, $JSONstring);
    fclose($JSONfh);

    $JSONFileName = "$root/InputScript/Input/Query_{$id}.json";
    $JSONfh = fopen($JSONFileName, 'w') or die("Can't open Query file");
    fwrite($JSONfh, $JSONstring);
    fclose($JSONfh);

}

function createSymbolicQueryFile($_POST, $id, $root)
{
    error_reporting(E_ALL);

    // ============== JSON output ============================
//    $JSONFileName = "$root/InputScript/Input/Query_{$id}.json";
    $JSONFileName = "$root/Results/{$id}/Query_{$id}.json";
    $JSONfh = fopen($JSONFileName, 'w') or die("Can't open Query file");
    $JSON = new StdClass();
    $JSON->type = 'symbolic';
    $JSON->name = "{$id}";
    $JSON->numpositions = (int)$_POST["NT"][0];

    if ( $_POST["mail"] != '')
    {
        $JSON->email = "{$_POST["mail"]}";
    }

    $numpdb = count($_POST['wheretosearch']);

    $sf = $_POST['wheretosearch'];

    if ( $_POST['nrlist'] ) {
        array_push($sf,$_POST["nrlist"]);
    }

    $JSON->searchfiles = $sf;

    $numnt = sqrt(count($_POST['mat']));
    $mat = array_chunk($_POST['mat'],sqrt(count($_POST['mat'])));

    $JSON->interactionMatrix = $mat;

    $JSONstring = json_encode($JSON);
    fwrite($JSONfh, $JSONstring);
    fclose($JSONfh);


    // ================ Matlab output, writes a .m file which is then executed ====
    $FileName = "$root/InputScript/Input/Query_{$id}.m";
    $fh = fopen($FileName, 'w') or die("Can't open Query file");

    fwrite($fh, "Query.Name = '{$id}';\n");
    fwrite($fh, "Query.Geometric = 0;\n");
    fwrite($fh, "Query.ExcludeOverlap = 1;\n");
    fwrite($fh, "Query.NumNT = '{$_POST["NT"][0]}';\n");

    if ( $_POST["mail"] != '')
    {
    	fwrite($fh, "Query.Email = '{$_POST["mail"]}';\n");
    }


    $numpdb = count($_POST['wheretosearch']);
    fwrite($fh, "Query.SearchFiles = {};\n");
    for ($i = 0; $i < $numpdb; $i++)
    {
        $ii = $i+1;
        fwrite($fh, "Query.SearchFiles{{$ii}} = '{$_POST["wheretosearch"][$i]}';\n");
    }

    if ( $_POST['nrlist'] ) {
        fwrite($fh, "Query.SearchFiles{end+1} = '{$_POST['nrlist']}';\n");
    }

    $numnt = sqrt(count($_POST['mat']));
    $mat = array_chunk($_POST['mat'],sqrt(count($_POST['mat'])));
    for ($i = 0; $i < $numnt; $i++)
    {
        for ($j = 0; $j < $numnt; $j++)
        {
            $ii = $i+1; $jj = $j+1;
            if ($i == $j)
            {
                fwrite($fh, "Query.Diagonal{"."$ii"."} ='{$mat[$i][$j]}';\n");
            }
        }
    }

    for ($i = 0; $i < $numnt; $i++)
    {
        for ($j = 0; $j <= ($i-1); $j++)
        {
            $ii = $i+1; $jj = $j+1;
            fwrite($fh, "Query.Diff{"."$ii".","."$jj"."} ='{$mat[$i][$j]}';\n");
        }
    }


    for ($i = 0; $i < $numnt; $i++)
    {
        for ($j = ($i+1); $j < $numnt; $j++)
        {
            $ii = $i+1; $jj = $j+1;
            fwrite($fh, "Query.Edges{"."$ii".","."$jj"."} ='{$mat[$i][$j]}';\n");
        }
    }

    $developers = array("zirbel@bgsu.edu","jjcanno@bgsu.edu","leontis@bgsu.edu","sria@bgsu.edu");

    if (in_array($_POST["mail"],$developers))
    {
        echo "Not running Matlab";
    }
    else
    {
        fwrite($fh, "tic;aWebFR3DSearch;\n");
        fwrite($fh, "aWriteHTMLForSearch('{$id}');toc;");
    }

    fclose($fh);

}

function createPlaceHolder($id, $root)
{
    error_reporting(E_ALL);

    $FileName = "$root/Results/{$id}/{$id}.html";
    mkdir("$root/Results/{$id}") or die("Can't make query directory");
    ini_set("track_errors", '1');
    $fh = fopen($FileName, 'w') or die("Can't open file Query '$php_errormsg'");
    chmod($FileName,0775);
    $htmlcode = '<html>
    <head>
    <meta http-equiv="refresh" content="2" >
    <title>WebFR3D results</title>
   	<link rel="stylesheet" media="all" type="text/css" href="../../css/Library.css" />
    </head>

    <body>
	<div class="message">
    <h2>Thank you for using WebFR3D.</h2><br>
    <p>Your job request has been successfully submitted. The results will appear here shortly.<br>
    You can bookmark this page and return later to check your results.</p><br><br>

    This page will automatically refresh every 2 seconds until the results become available.<br><br>

    </div>
    </body>
    </html>';

    fwrite($fh,$htmlcode);
    fclose($fh);
}

// nrlists
function process_nrlists($input)
{
    $nr_release = $input["nr_release_list"];
    $nr_resolution = $input["nr_resolution"];
    if ( isset( $nr_release ) and isset( $nr_resolution ) and $nr_release != 'none') {
        $nrlist = get_nr_list_filename($nr_release, $nr_resolution);
        if ( !file_exists($nrlist) ) {
            $fh = fopen($nrlist, 'w') or die("Can't open nrlist file");
            fwrite($fh, get_nr_list_for_matlab($nr_release, $nr_resolution) );
            fclose($nrlist);
            chmod($nrlist, 0775);
        }
        $input['nrlist'] = "NR_{$nr_release}_{$nr_resolution}_list.pdb";
    } else {
        $input['nrlist'] = FALSE;
    }
    return $input;
}

function get_nr_list_filename($release, $resolution)
{
    include('config.php');
    return $config['fr3d'] . "/PDBFiles/NR_{$release}_{$resolution}_list.pdb";
}

?>
