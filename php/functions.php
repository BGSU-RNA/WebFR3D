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


function get_all_pdb_files($mode) {

    include('include.php');

    $query = "SELECT DISTINCT structureId FROM `pdb_info`;";
    $result = mysql_query($query) or die(mysql_error());

    while($row = mysql_fetch_array($result)){
		echo "<option value=\"$row[structureId]\">$row[structureId]</option>\n";
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

function createGeometricQueryFile($_POST, $id, $root)
{
    $FileName = "$root/InputScript/Input/Query_{$id}.m";
    $fh = fopen($FileName, 'w') or die("Can't open Query file");
    fwrite($fh, "Query.Filename = '{$_POST["PDBquery"]}';\n");
    if ( $_POST["mail"] != '')
    {
    	fwrite($fh, "Query.Email = '{$_POST["mail"]}';\n");
    }

	$nts = explode(',',$_POST["nucleotides"]);
	$nts_matlab = '';
    for ($i = 0; $i < count($nts); $i++)
    {
    	$chain = $_POST["chain_$i"];
    	$command = 'Query.ChainList{' . ($i + 1) . '}=' . "'$chain';\n";
	    fwrite($fh, $command);
		$nts_matlab .= 	$nts[$i] . '_' . $chain . ',';
    }
	$nts_matlab = substr($nts_matlab,0,-1);
    fwrite($fh, "NTList = '$nts_matlab';\n");

    fwrite($fh, "Query.DiscCutoff = {$_POST["disc"]};\n");
    fwrite($fh, "Query.Name = '{$id}';\n");
    fwrite($fh, "Query.Geometric = 1;\n");
    fwrite($fh, "Query.ExcludeOverlap=1;\n");

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

    fwrite($fh, "[File,QIndex] = zAddNTData(Query.Filename);\n");
    fwrite($fh, "[Indices,Ch] = zIndexLookup(File(QIndex),NTList);\n");
    fwrite($fh, "Query.NumNT = length(Indices);\n");

//    fwrite($fh, "for i=1:Query.NumNT,");
//    fwrite($fh, "        Query.ChainList{i}=Ch{1,i}{1};");
//    fwrite($fh, "end \n");

    fwrite($fh, "for i=1:min(25,length(Indices)),");
    fwrite($fh, "    Query.NTList{i} =File(QIndex).NT(Indices(i)).Number;");
    fwrite($fh, "    Query.NT(i) = File(QIndex).NT(Indices(i));");
    fwrite($fh, "end\n");

    $numnt = sqrt(count($_POST['mat']));
    $mat = array_chunk($_POST['mat'],sqrt(count($_POST['mat'])));
    for ($i = 0; $i < $numnt; $i++)
    {
        for ($j = 0; $j < $numnt; $j++)
        {
            $ii = $i+1; $jj = $j+1;
//            if ($i > $j)
//            {
//                fwrite($fh, "Query.Edges{"."$ii,$jj"."} ='{$mat[$i][$j]}';\n");
//            }
//            elseif ($i < $j)
//            {
//                fwrite($fh, "Query.Diff{"."$ii".","."$jj"."} ='{$mat[$i][$j]}';\n");
//            }
//            else
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


//    fwrite($fh, "try,");
//    fwrite($fh, "xFR3DSearch;\n");
    fwrite($fh, "tic;aWebFR3DSearch;\n");
    fwrite($fh, "aWriteHTMLForSearch('{$id}');toc;");
//	fwrite($fh, "catch ME, movefile('$root/InputScript/Input/Query_{$id}.m','$root/InputScript/Failed');");
//	fwrite($fh, "disp('An error occured while processing the query');return;end");
    fclose($fh);

    //$command = '/Applications/Octave.app/Contents/Resources/bin/octave -q --braindead ~/Sites/OnlineFR3D/            Query.oct 2>&1';
    //$response = shell_exec($command);
    //echo "<pre>$response</pre>\n";
}

function createSymbolicQueryFile($_POST, $id, $root)
{
    error_reporting(E_ALL);
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

    fwrite($fh, "tic;aWebFR3DSearch;\n");
    fwrite($fh, "aWriteHTMLForSearch('{$id}');toc;");
    fclose($fh);

}

function createRNAOQueryFile($_POST, $uid, $root)
{
    $FileName = "$root/InputScript/Input/Qrnao_{$uid}.m";
    $fh = fopen($FileName, 'w') or die("Can't open Query file");
    $q = $_POST["rnao_query"];
    $q = stripcslashes($q);
    fwrite($fh, "{$q}\n");
    $numpdb = count($_POST['wheretosearch']);
    echo $_POST["wheretosearch"][0];
    fwrite($fh, "Query.SearchFiles = cell(1,$numpdb);\n");
    fwrite($fh, "Query.Name = '{$uid}';\n");
    fwrite($fh, "Query.Geometric = 0;\n");
    fwrite($fh, "Query.ExcludeOverlap = 1;\n");
    for ($i = 0; $i < $numpdb; $i++)
    {
        $ii = $i+1;
        fwrite($fh, "Query.SearchFiles{{$ii}} = '{$_POST["wheretosearch"][$i]}';\n");
    }
    if ( $_POST["mail"] != '')
    {
    	fwrite($fh, "Query.Email = '{$_POST["mail"]}';\n");
    }
    fclose($fh);
}

function createPlaceHolder($id, $root)
{
    error_reporting(E_ALL);

    $FileName = "$root/Results/{$id}/results.php";
    $fh = fopen($FileName, 'w') or die("Can't open file Query");
    chmod($FileName,0775);
    $htmlcode = '<html>
    <head>
    <meta http-equiv="refresh" content="10" >
    <title>FR3D results</title>
   	<link rel="stylesheet" media="all" type="text/css" href="../../css/Library.css" />
    </head>

    <body>
	<div class="message">
    <h2>Thank you for using FR3D.</h2><br>
    <p>Your job request has been successfully submitted. The results will appear here shortly.<br>
    You can bookmark this page and return later to check your results.</p><br><br>

    This page will automatically refresh every 10 seconds until the results become available.<br><br>

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