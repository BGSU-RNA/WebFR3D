<?php
error_reporting(E_ALL);
$root = '/Servers/rna.bgsu.edu/WebFR3D';
$url  = 'http://rna.bgsu.edu/WebFR3D';
$uid = uniqid();
$path = "$root/Results/{$uid}"; 
mkdir($path);
chmod($path,0777);

//print_r($_POST);

//return;

createPlaceHolder($uid,$root);
$location = "Location: $url/Results/{$uid}/results.php";
header($location);

include('parseNTs.php');
$list = $_POST["nucleotides"];
$pdb = $_POST["PDBquery"];
$_POST["nucleotides"] = parseNTs($pdb,$list);

if ( isset( $_POST["geometric"] ) ) {
	createGeometricQueryFile($_POST, $uid, $root);
}
elseif ( isset( $_POST["symbolic"] ) ) {
	createSymbolicQueryFile($_POST, $uid, $root);
}
elseif ( isset( $_POST["rnao"] ) ) {
	createRNAOQueryFile($_POST, $uid, $root);
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

//    fwrite($fh, "NTList = '{$_POST["nucleotides"]}';\n");
	$nts = explode(',',$_POST["nucleotides"]);
	$nts_matlab = '';
//	print_r($_POST);
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
//    echo $_POST["wheretosearch"][0];
    fwrite($fh, "Query.SearchFiles = cell(1,$numpdb);\n");
    for ($i = 0; $i < $numpdb; $i++)
    {
        $ii = $i+1;
        fwrite($fh, "Query.SearchFiles{{$ii}} = '{$_POST["wheretosearch"][$i]}';\n");           
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

//    if ( $_POST["wheretosearch"][0] == 'Reduced redundancy dataset' )
//    {
//    	fwrite($fh, "Query.SearchFiles{{$i}} = 'Non_redundant_list_2_8_08.txt';\n");      
//    	$FileName = "Non_redundant_list_2_8_08.txt";
//    	$nr = fopen($FileName, 'r') or die("Can't open non-redundant list");	
//    	$nr_list = fread($nr,filesize($FileName));
//    	$pdblist = split("@", $nr_list);
//    	for ($i = 1; $i < count($pdblist)-1; $i++)
//    	{
//	        fwrite($fh, "Query.SearchFiles{{$i}} = '{$pdblist[$i]}';\n");      
//    	} 
//    }   
//    else
//    {
	    $numpdb = count($_POST['wheretosearch']);
	    fwrite($fh, "Query.SearchFiles = cell(1,$numpdb);\n");
	    for ($i = 0; $i < $numpdb; $i++)
	    {
	        $ii = $i+1;
	        fwrite($fh, "Query.SearchFiles{{$ii}} = '{$_POST["wheretosearch"][$i]}';\n");           
	    }        
//    } 
    
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
    
//    fwrite($fh, "try,");    
//    fwrite($fh, "xFR3DSearch;\n");
    fwrite($fh, "tic;aWebFR3DSearch;\n");    

    fwrite($fh, "aWriteHTMLForSearch('{$id}');toc;");
//	fwrite($fh, "catch ME, movefile('$root/InputScript/Input/Query_{$id}.m','$root/OnlineFR3D/InputScript/Failed');");
//	fwrite($fh, "disp('An error occured while processing the query');return;end");
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
   	<link rel="stylesheet" media="all" type="text/css" href="http://rna.bgsu.edu/WebFR3D/Library.css" />	     
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
}
?>    