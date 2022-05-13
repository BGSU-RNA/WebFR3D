<?php


function loadJSONQueryFile($id,$root)
{
//    echo "hello there";
//    echo $id;

    $JSONFileName = "$root/Results/{$id}/Query_{$id}.json";

//    echo $JSONFileName;

    $JSONfh = fopen($JSONFileName, 'r') or die("Can't open Query file");
    $JSONdata = fread($JSONfh, filesize($JSONFileName));
    fclose($JSONfh);

//    echo $JSONdata;
//    echo "endofJSONdata";

    // the single apostrophe on sO interactions confuses PHP
    // convert it to * here, convert back when setting the query
    $JSONdata = str_replace("'","*",$JSONdata);

    return $JSONdata;
//    return "new data";
    }

?>
