var base = [window.location.origin, 'webfr3d'].join('/');

function FillQueryParameters(qdata,form)
{
//    alert(qdata)
//    var query = JSON.parse(qdata);  // doesn't seem to be necessary
//    alert(qdata["type"])
//    alert("Converted query to JavaScript object")
    document.getElementById("NumNT").value = qdata["numpositions"];
    document.getElementById("UnitIDs").value = "";
    if ("unitID" in qdata) {
        document.getElementById("UnitIDs").value = qdata["unitID"];
    }
    document.getElementById("disc").value = "";
    if ("discrepancy" in qdata) {
        document.getElementById("disc").value = qdata["discrepancy"];
    }
    document.getElementById("StructuresToSearch").value = qdata["structuresToSearch"];
    document.getElementById("RepSetRelease").value = qdata["repSetRelease"];
    document.getElementById("RepSetResolution").value = qdata["repSetResolution"];
    document.getElementById("SearchName").value = qdata["name"];
    document.getElementById("email").value = qdata["email"];
    CreateMatrix(form)

    cells = qdata["numpositions"];
    for ( i = 1; i <= cells; i++ )
    {
        for ( j = 1; j <= cells; j++ )
        {
            document.getElementById("cell"+i+","+j).value = "temp";

            document.getElementById("cell"+i+","+j).value = qdata["interactionMatrix"][i-1][j-1].replace(/\*/g,"'");

        }
    }


//    document.getElementById("mat").value = qdata["interactionMatrix"];


}

function resultUrl(id) {
  'use strict';
  return [base, 'Results', id, 'results.php'].join('/');
}

function resultLink(id) {
  'use strict';
  return "<a href='" + resultUrl(id) + "'>View results</a>";
}

function Check(form)
{
    if ( ValidateTargetPDBs() ) {
        if (ValidateNumNT() ) {
        	return true;
        }
    }
    return false;
}

function ShowHelp(obj)
{
	var classname = obj.className;
	var help = document.getElementById('help');
	var message = '';
	var helplink = '';

	if (classname.search(/disc/) != -1) {
		message = 'Select a number between 0 and 0.7<br>';
		helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Discrepancy', this.href)\">More</a>";
	} else if (classname.search(/email/) != -1) {
		 message = 'You can enter your email to get notified when the results are ready.<br>';
		 helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Email', this.href)\">More</a>";
	} else if (classname.search(/dist/) != -1) {
		 message = 'Difference between nucleotide numbers in the chain.<br>Valid options: >,<,=,>=,<= <br>';
		 helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Distance constraints', this.href)\">More</a>";
	} else if (classname.search(/inter/) != -1) {
		 message = 'Base-base interactions and relations<br>';
		 helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Interaction constraints', this.href)\">More</a>";
	} else if (classname.search(/diagonal/) != -1) {
		 message = 'Nucleotide mask<br>Valid options: N, A, AG, R, Y<br>';
		 helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Nucleotide mask', this.href)\">More</a>";
	} else if (classname.search(/ntsinput/) != -1) {
		 message = 'Enter up to 15 unit ids separated by commas.<br>';
		 helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Input nucleotides', this.href)\">More</a>";
	} else if (classname.search(/where/) != -1) {
		 message = 'You can select multiple structures by holding Cmd or Alt key.<br>';
		 helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Search files', this.href)\">More</a>";
	}
	if (helplink != '') {
		help.innerHTML = message + helplink;
	}
}

function ValidateMatrix()
{
    var mat = document.getElementById('matrix');
    var ncells = Math.pow(mat.childNodes.length,2);
    for (i = 1; i <= ncells; i++)
    {
        var cell = document.getElementById('cell' + i);

        if (cell.value.match(/cWW/)) {alert('cWW');}
    }
}

function ValidateTargetPDBs()
{
    var PDBs = document.getElementById('SelectElem');
    var nrlist = document.getElementById('nr_release_list');
    if ( PDBs.selectedIndex == -1 && nrlist.selectedIndex <= 0 ) {
        alert("No target files selected");
        PDBs.focus();
        return false;
    }
    else {
        return true;
    }
}

function ValidateUnitIDs()
{
    var units = document.getElementById('UnitIDs').value;

    units = units.trim();
    units = units.replace(/\s+/g,",");
    units = units.replace(/\t/g,",");
    units = units.replace(/,,/g,",");
    units = units.replace(/,,/g,",");
    units = units.replace(/,,/g,",");

    document.getElementById("UnitIDs").value = units

    if(/[^A-Za-z0-9|,-\s]/.test(units))
    {
        var invalidChars = units.match(/[^A-Za-z0-9\|,-\s]/g);
        alert('The following characters are invalid: ' + invalidChars.join(''));
    }

    var disc = document.getElementById('disc');
    if (disc.value == "")
    {
        document.getElementById("disc").value = "0.4";
    }
    var unitarray = units.split(',');
    document.getElementById('NumNT').value = unitarray.length;

    if (unitarray.length > 1) {
        document.getElementById('submit').disabled = false;
        document.getElementById('viewquery').disabled = false;
    } else {
        document.getElementById('submit').disabled = true;
        document.getElementById('viewquery').disabled = true;
    }
}

function ValidateDiscrepancy()
{
    var disc = document.getElementById('disc');
    disc.value = disc.value.replace(/,/,'.');
    var expr = /^0.\d+$/;
    if ( disc.value < 0 | disc.value > 0.7 | !disc.value.match(expr) )
    {
        alert("Please select a discrepancy cutoff greater than 0 and less than or equal to 0.7.");
        return false;
    }
    else
    {
        document.getElementById('submit').disabled = false;
        return true;
    }
}


function ValidateNumNT()
{
    var NumNT = document.getElementById('NumNT');

    if ( !NumNT.value.match(/^\d+$/) || NumNT.value > 15 ) {
        alert('Please select an integer between 2 and 15');
    }
    else {
        return true;
    }
}

function CreateMatrix(form)
{
	if ( ValidateNumNT() )
	{
        var NT = document.getElementById('NumNT');

        var cells = NT.value;

        var check = document.getElementById('mat');
        if ( check != null )
        {
            if (check.childNodes.length != cells)
            {
                RemoveNodes(check);
            }
        }

        var theMat = document.getElementById('mat');
        var newTable = document.createElement("table");
        newTable.setAttribute('id','matrix');
        newTable.setAttribute('class','intmatrix');
        theMat.appendChild(newTable);
        var headerRow = document.createElement("tr");
        newTable.appendChild(headerRow);
        var count = 0;
        for (i = 0; i <= cells; i++)
        {
            var headerTd = document.createElement('td');
            headerTd.setAttribute('class','header');
            if ( i == 0 )
            {
                headerTd.innerHTML = '';
            }
            else
            {
                headerTd.innerHTML = 'Position' + i;
            }
            headerRow.appendChild(headerTd);
        }
        for ( i = 1; i <= cells; i++ )
        {
            var newTR = document.createElement("tr");
            newTable.appendChild(newTR);
            for (j = 1; j <= Number(cells) + 1; j++)
            {
                  var newTD = document.createElement("td");
                  newTD.setAttribute('class','header');
                  newTR.appendChild(newTD);
                  if ( j == 1 )
                  {
                      newTD.innerHTML = 'Position' + i;
                  }
                  else
                  {
                      count += 1;
                      if ( i == j-1 )
                      {
                      newTD.innerHTML = "<input type='text' onclick='ShowHelp(this)' name='mat[]' value='N' class='diagonal' id='cell"+i+","+(j-1)+"'</input>";
                      }
                      if ( i < j-1 )
                      {
                      newTD.innerHTML = "<input type='text' onclick='ShowHelp(this)' name='mat[]' value='' class='inter' id='cell"+i+","+(j-1)+"'</input>";
                      }
                      if ( i > j-1 )
                      {
                      newTD.innerHTML = "<input type='text' onclick='ShowHelp(this)' name='mat[]' value='' class='dist' id='cell"+i+","+(j-1)+"'</input>";
                      }
                  }
            }
        }
        document.getElementById('submit').disabled = false;
        document.getElementById('submit').focus();
    }
}

function ViewQuery()
{
    var url = "http://rna.bgsu.edu/rna3dhub/display3D/unitid/"+document.getElementById("UnitIDs").value;
    window.open(url,'_blank');
}

function ResetAll()
{
    document.getElementById("NumNT").value = "2";
    document.getElementById("NumNT").selectedIndex = 0;
    document.getElementById("UnitIDs").value = "";
    document.getElementById("disc").value = "";
    document.getElementById("StructuresToSearch").value = "";
    document.getElementById("email").value = "";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").value = "";
    document.getElementById("RepSetResolution").selectedIndex = 0;
    document.getElementById("SearchName").value = "";
    document.getElementById("email").value = "";

    var theForm = document.getElementById('mat');
    if (theForm != null)
    {
        RemoveNodes(theForm);
    }
    else alert('Interaction Matrix not found');

    document.getElementById('submit').disabled = true;
    document.getElementById('viewquery').disabled = true;
}

function RemoveNodes(cell)
{
    if ( cell.hasChildNodes() )
    {
        while ( cell.childNodes.length >= 1 )
        {
            cell.removeChild( cell.firstChild );
        }
    }
}

function Tetraloops()
{
	ResetAll();
    document.getElementById("NumNT").value = "6";
    document.getElementById("SelectElem").value = "4V9F";
    document.getElementById("help").innerHTML = resultLink('4d0804a7bb1d0');
    CreateMatrix(this.form);

    document.getElementById("cell6").value = 'cWW flank';

    document.getElementById("cell7").value = '=1';
    document.getElementById("cell14").value = '=1';
    document.getElementById("cell21").value = '=1';
    document.getElementById("cell28").value = '=1';
    document.getElementById("cell35").value = '=1';
}

function Hairpins()
{
	ResetAll();
    document.getElementById("NumNT").value = "2";
    document.getElementById("SelectElem").value = "3I8I";
    CreateMatrix(this.form);

    document.getElementById("cell2").value = 'cWW flank';

    document.getElementById("cell3").value = '>';
    document.getElementById("help").innerHTML = resultLink('4d07a35dd4635');
}

function InternalLoops()
{
	ResetAll();
    document.getElementById("NumNT").value = "6";
    document.getElementById("SelectElem").value = "3I8I";
    CreateMatrix(this.form);

    document.getElementById("cell3").value = 'flank';
    document.getElementById("cell6").value = 'cWW';
    document.getElementById("cell16").value = 'cWW';
    document.getElementById("cell24").value = 'flank';

    document.getElementById("cell7").value = '>';
    document.getElementById("cell14").value = '>';
    document.getElementById("cell28").value = '>';
    document.getElementById("cell35").value = '>';
    document.getElementById("help").innerHTML = resultLink('4d07a68037c2b');
}

function cWW_tHWBaseTriples()
{
	ResetAll();
    document.getElementById("NumNT").value = "3";
    document.getElementById("SelectElem").value = "3I8I";
    CreateMatrix(this.form);

    document.getElementById("cell2").value = 'cWW';
    document.getElementById("cell6").value = 'tHW';

    document.getElementById("help").innerHTML = resultLink('4d07acda133a4');
}

function GNRASymbolic()
{
    ResetAll();

    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;">GNRA hairpin symbolic query</h2> \
    This query searches for a GNRA hairpin along with the flanking Watson-Crick basepair.\
    Positions 2 and 5 must make a tSH or near tSH basepair; 5 instances have near tSH but the same overall geometry.\
    Also, positions 2 and 5 must make a GA base combination; position 2 must be G, position 5 must be A.  This could be relaxed. \
    Positions 3, 4, and 5 must be stacked on one another.\
    The nucleotides in positions 1 to 6 must be in 5 prime to 3 prime order, that is, increasing nucleotide number.\
    Because some GNRA hairpins have bulged bases, the sequential distance is only restrained to be less than 4.\
    <br> ';

    document.getElementById("NumNT").value = "6";
    document.getElementById("StructuresToSearch").value = "4V9F";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").selectedIndex = "";

    document.getElementById("SearchName").value = "GNRA hairpin symbolic query";

    CreateMatrix(this.form);

    document.getElementById("cell1,6").value = 'cWW';
    document.getElementById("cell2,5").value = 'tSH ntSH GA';
    document.getElementById("cell3,4").value = 'stack';
    document.getElementById("cell4,5").value = 'stack';

    document.getElementById("cell4,4").value = 'R';

    document.getElementById("cell2,1").value = '=1 >';
    document.getElementById("cell3,2").value = '<4 >';
    document.getElementById("cell4,3").value = '<4 >';
    document.getElementById("cell5,4").value = '<4 >';
    document.getElementById("cell6,5").value = '=1 >';

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
}

function TripleShearedSymbolic()
{
	ResetAll();

    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;">Triple sheared internal loop query</h2>The triple sheared internal loop consists of 10 nucleotides, with 5 on each strand and cis Watson-Crick basepairs at either end.  The six interior bases make tSH basepairs.  These basepairs are specified in the yellow boxes.  The blue boxes indicate the distance along the chain between successive nucleotides on each strand.<br> ';

    document.getElementById("NumNT").value = "10";
    document.getElementById("StructuresToSearch").value = "4Y4O";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").selectedIndex = "";

    document.getElementById("SearchName").value = "Triple sheared internal loop symbolic search";

    CreateMatrix(this.form);

    document.getElementById("cell1,10").value = 'cWW';
    document.getElementById("cell2,9").value = 'tSH ntSH';
    document.getElementById("cell3,8").value = 'tSH ntSH';
    document.getElementById("cell4,7").value = 'tHS ntHS';
    document.getElementById("cell5,6").value = 'cWW';

    document.getElementById("cell2,1").value = '=1';
    document.getElementById("cell3,2").value = '=1';
    document.getElementById("cell4,3").value = '=1';
    document.getElementById("cell5,4").value = '=1';
    document.getElementById("cell7,6").value = '=1';
    document.getElementById("cell8,7").value = '=1';
    document.getElementById("cell9,8").value = '=1';
    document.getElementById("cell10,9").value = '=1';

    // 2019-07-06 result link http://rna.bgsu.edu/webfr3d/Results/5d20f85773208/5d20f85773208.html just 4Y4O

    document.getElementById("help").innerHTML = resultLink('4d07b26217358');

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
}

function AMinorSymbolic()
{
    ResetAll();

    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;"> \
    A-minor motif geometric search</h2> \
    A highly recurrent long-range interaction often has an A making one or two basepairs with a \
    the sugar edges (minor groove) of a \
    Watson-Crick basepair in a helix which is distant in the secondary structure. \
    The most common long-range basepair is a trans sugar/sugar (tSS) basepair. \
    The nucleotides in positions 1 and 2 correspond to the bases making the Watson-Crick basepair, and the nucleotide in \
    position 3 corresponds to the base making the long-range interaction tSS basepair with the nucleotide in position 1. \
    The search does not require any particular base in positions 1, 2, or 3. \
    <br> ';

    document.getElementById("SearchName").value = "A-minor motif symbolic search";
    document.getElementById("NumNT").value = "3";

    document.getElementById("StructuresToSearch").value = "4V9F";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").selectedIndex = "";

    CreateMatrix(this.form);

    document.getElementById("cell1,2").value = 'cWW';
    document.getElementById("cell1,3").value = 'LR tSS';

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;

}

function SarcinCore5Mixed()
{
    ResetAll();

    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;"> \
    5-nucleotide core of the Sarcin-Ricin motif</h2> \
    The Sarcin-Ricin motif is named after a highly conserved internal loop was originally identified in Helix 95 \
    of the eukaryotic large ribosomal subunit. A prominent feature is a GUA base triple. \
    This query uses 5 nucleotides from a very high resolution structure of the motif. \
    It will match arbitrary 5-nucleotide sets with the same geometry, allowing for base substitutions. \
    This query imposes one basepair constraint, which dramatically speeds up the query compared to purely geometric. \
    The discrepancy is large enough to allow some substantial variation. \
    This query searches the E. coli large and small ribosomal subunit and the 5S rRNA. \
    Some instances lack the characteristic basepairs and stacking interactions in the Sarcin-Ricin motif. \
    <br> ';

    document.getElementById("NumNT").value = "5";
    document.getElementById("StructuresToSearch").value = "5J7L|1|DA,5J7L|1|AA,5J7L|1|DB";
    document.getElementById("disc").value = "0.6";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").selectedIndex = "";

    document.getElementById("SearchName").value = "Sarcin-Ricin 5 nucleotide core";

    document.getElementById("UnitIDs").value = "4NLF|1|A|G|2655,4NLF|1|A|U|2656,4NLF|1|A|A|2657,4NLF|1|A|G|2664,4NLF|1|A|A|2665";

    CreateMatrix(this.form);

    document.getElementById("cell2,5").value = 'tWH ntWH';

    document.getElementById('viewquery').disabled = false;

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;

    // http://rna.bgsu.edu/webfr3d/Results/5d33e40d0a109/5d33e40d0a109.html 18 candidates in 7 seconds. Nice.
}

function SarcinCore7Mixed()
{
    ResetAll();

    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;"> \
    7-nucleotide core of the Sarcin-Ricin motif</h2> \
    The Sarcin-Ricin motif is named after a highly conserved internal loop was originally identified in Helix 95 \
    of the eukaryotic large ribosomal subunit. A prominent feature is a GUA base triple. \
    This query uses 7 nucleotides from a high resolution structure of the motif. \
    It will match arbitrary 7-nucleotide sets with the same geometry, allowing for base substitutions. \
    This query imposes one basepair constraint, which dramatically speeds up the query compared to purely geometric. \
    This query searches the human large and small ribosomal subunit and the 5.8S and 5S rRNA. \
    Eight of the candidates have discrepancy over 0.4 compared to the query motif, but still maintain the basic geometry. \
    <br> ';

    document.getElementById("NumNT").value = "7";
    document.getElementById("StructuresToSearch").value = "6QZP|1|L5+6QZP|1|L8,6QZP|1|S2,6QZP|1|L7";
    document.getElementById("disc").value = "0.5";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").selectedIndex = "";

    document.getElementById("SearchName").value = "Sarcin-Ricin 7 nucleotide core mixed";

    document.getElementById("UnitIDs").value = "1Q96|1|A||9,1Q96|1|A||10,1Q96|1|A||11,1Q96|1|A||12,1Q96|1|A||19,1Q96|1|A||20,1Q96|1|A||21";

    CreateMatrix(this.form);

    document.getElementById("cell3,6").value = 'tWH ntWH';

    document.getElementById('viewquery').disabled = false;

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;

    // http://rna.bgsu.edu/webfr3d/Results/5d33e73e5c41a/5d33e73e5c41a.html 18 instances, lots of variation
}

function TripleShearedMixed()
{
    ResetAll();
    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;"> \
    Triple sheared pair mixed search</h2> \
    <br> ';
    document.getElementById("UnitIDs").value = "4Y4O|1|2A|G|1856,4Y4O|1|2A|G|1857,4Y4O|1|2A|G|1858,4Y4O|1|2A|A|1859,4Y4O|1|2A|G|1860,4Y4O|1|2A|C|1882,4Y4O|1|2A|G|1883,4Y4O|1|2A|A|1884,4Y4O|1|2A|A|1885,4Y4O|1|2A|C|1886";
    document.getElementById("help").innerHTML = resultLink("4d07a1a83f7dd");
    document.getElementById("disc").value = "0.4";
    document.getElementById("NumNT").value = "10";
    document.getElementById("StructuresToSearch").value = "4Y4O";
    document.getElementById("SearchName").value = "Triple sheared internal loop mixed search";

    CreateMatrix(this.form);

    document.getElementById("cell1,2").value = 'stack nstack';
    document.getElementById("cell2,3").value = 'stack nstack';
    document.getElementById("cell4,5").value = 'stack nstack';
    document.getElementById("cell9,10").value = 'stack nstack';

    document.getElementById("cell1,10").value = 'cWW';
    document.getElementById("cell5,6").value = 'cWW';

    document.getElementById("cell2,9").value = 'tSH ntSH';
    document.getElementById("cell3,8").value = 'tSH ntSH';
    document.getElementById("cell4,7").value = 'tHS ntHS';

    document.getElementById("cell2,1").value = '<3';
    document.getElementById("cell3,2").value = '<3';
    document.getElementById("cell4,3").value = '<3';
    document.getElementById("cell5,4").value = '<3';
    document.getElementById("cell7,6").value = '<3';
    document.getElementById("cell8,7").value = '<3';
    document.getElementById("cell9,8").value = '<3';
    document.getElementById("cell10,9").value = '<3';

    document.getElementById('viewquery').disabled = false;

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
}

function Sarcin9ntMixed()
{
    ResetAll();
    document.getElementById("NT").value = "2701:2704, 2694:2690";
    queryNTs = "2701,2702,2703,2704,2690,2691,2692,2693,2694";
    document.getElementById("help").innerHTML = resultLink("4e023dc5d5c08");
    var what = document.getElementById("PDB").options;
    for (i = 0; i <= what.length; i++)
    {
        if ( what[i].value == '1S72' )
        {
            document.getElementById("PDB").selectedIndex = i;
            break;
        }
    }
    document.getElementById("disc").value = "0.4";
    document.getElementById("nr_release_list").value = "0.22";
    document.getElementById("nr_resolution").selectedIndex = 5;
    CreateMatrix(this.form);

    document.getElementById("cell9").value = 'pair npair';
    document.getElementById("cell17").value = 'pair npair';
    document.getElementById("cell24").value = 'pair npair';
    document.getElementById("cell32").value = 'pair npair';
    document.getElementById("cell62").value = 'pair npair';

    document.getElementById("cell10").value = '<3';
    document.getElementById("cell20").value = '<3';
    document.getElementById("cell30").value = '<3';
    document.getElementById("cell50").value = '<3';
    document.getElementById("cell60").value = '<3';
    document.getElementById("cell70").value = '<3';
    document.getElementById("cell80").value = '<3';
}

function SarcinCore5Geometric()
{
    ResetAll();

    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;"> \
    5-nucleotide core of the Sarcin-Ricin motif</h2> \
    The Sarcin-Ricin motif is named after a highly conserved internal loop was originally identified in Helix 95 \
    of the eukaryotic large ribosomal subunit. A prominent feature is a GUA base triple. \
    This query uses 5 nucleotides from a very high resolution structure of the motif. \
    It will match arbitrary 5-nucleotide sets with the same geometry, allowing for base substitutions. \
    This query searches the E. coli large and small ribosomal subunit and the 5S rRNA. \
    Note that all but one instance have cSH, tWH, and tHS basepairs. \
    Most instances have the same base-phosphate and base-ribose interactions. \
    All three types of stacking interactions (s35, s33, s55) are present in each instance. \
    Note that a discrepancy of 0.6 would make this purely geometric search take far too long. \
    <br> ';

    document.getElementById("NumNT").value = "5";
    document.getElementById("StructuresToSearch").value = "5J7L|1|DA,5J7L|1|AA,5J7L|1|DB";
    document.getElementById("disc").value = "0.4";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").selectedIndex = "";

    document.getElementById("SearchName").value = "Sarcin-Ricin 5 nucleotide core";

    document.getElementById("UnitIDs").value = "4NLF|1|A|G|2655,4NLF|1|A|U|2656,4NLF|1|A|A|2657,4NLF|1|A|G|2664,4NLF|1|A|A|2665";

    document.getElementById('submit').disabled = false;
    document.getElementById('viewquery').disabled = false;

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;

    // 5d33dfdef4125 is the result with discrepancy 0.6, only one chain returned results, 677 seconds, 596 was matrix discrepancy! 76 for intersection, not so bad
    // 5d33dc9921668 is the result with discrepancy 0.4, quite reasonable

}

function AMinorGeometric()
{
    ResetAll();

    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;"> \
    A-minor motif geometric search</h2> \
    A highly recurrent long-range interaction often has an A making one or two basepairs with a \
    the sugar edges (minor groove) of a \
    Watson-Crick basepair in a helix which is distant in the secondary structure. \
    This query uses one example of this interaction and does a purely geometric search. \
    The nucleotides in positions 1 and 2 correspond to the bases making the Watson-Crick basepair, and the nucleotide in \
    position 3 corresponds to the base making the long-range interaction. \
    However, this query is purely geometric, it does not require that the bases in positions 1 and 2 \
    make a Watson-Crick basepair, nor does it require a basepair between 1,2 and 3. \
    It does not require any particular base in positions 1, 2, or 3. \
    Even so, all candidates have a Watson-Crick basepair between positions 1 and 2, some have a base other than A in position 3, \
    and most candidates have at least one basepair (cSS, tSS, or both) between postions 1,2 and position 3. \
    <br> ';

    document.getElementById("SearchName").value = "A-minor motif geometric search";
    document.getElementById("NumNT").value = "3";
    document.getElementById("UnitIDs").value = "4V9F|1|0|G|1832,4V9F|1|0|C|1844,4V9F|1|0|A|874";
    document.getElementById("disc").value = "0.4";
    document.getElementById("StructuresToSearch").value = "4V9F";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").selectedIndex = "";

    document.getElementById('submit').disabled = false;
    document.getElementById('viewquery').disabled = false;

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;

    // http://rna.bgsu.edu/webfr3d/Results/5d3b2798e78c5/5d3b2798e78c5.html
}

function cWWAminoAcidGeometric()
{
    ResetAll();

    document.getElementById("query_description").innerHTML = '<h2 style = "margin-top: 0px;"> \
    Watson-Crick basepair interacting with amino acid</h2> \
    This geometric query starts with two RNA bases making a Watson-Crick basepair \
    and interacting with an amino acid in the minor groove. \
    Note that X is a single letter abbreviation for "protein". \
    <br> ';

    document.getElementById("NumNT").value = "3";
    document.getElementById("UnitIDs").value = "4V9F|1|0|A|2089,4V9F|1|0|U|2655,4V9F|1|B|GLN|254";
    document.getElementById("disc").value = "0.3";

    CreateMatrix(this.form);

    document.getElementById("cell3,3").value = 'X';

    document.getElementById("StructuresToSearch").value = "4V9F";
    document.getElementById("RepSetRelease").value = "";
    document.getElementById("RepSetResolution").selectedIndex = "";

    document.getElementById("SearchName").value = "Watson-Crick basepair with amino acid in minor groove";

    document.getElementById('submit').disabled = false;
    document.getElementById('viewquery').disabled = false;

    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
}

function TLoopTemplate()
{
    ResetAll();
    document.getElementById("NT").value = "312:319";
    queryNTs = "312,313,314,315,316,317,318,319";
    document.getElementById("help").innerHTML = resultLink("4e023e7dac8d1");
    var what = document.getElementById("PDB").options;
    for (i = 0; i <= what.length; i++)
    {
        if ( what[i].value == '1S72' )
        {
            document.getElementById("PDB").selectedIndex = i;
            break;
        }
    }
    document.getElementById("disc").value = "0.4";
    document.getElementById("nr_release_list").value = "0.22";
    document.getElementById("nr_resolution").selectedIndex = 5;

    CreateMatrix(this.form);

    document.getElementById("cell8").value = 'cWW flank';

    document.getElementById("cell9").value  = '<3';
    document.getElementById("cell18").value = '<3';
    document.getElementById("cell27").value = '<3';
    document.getElementById("cell36").value = '<3';
    document.getElementById("cell45").value = '<3';
    document.getElementById("cell54").value = '<3';
    document.getElementById("cell63").value = '<3';
}

function Kt7Template()
{
    ResetAll();
    document.getElementById("NT").value = "77:81,93:100";
    queryNTs = "77,78,79,80,81,93,94,95,96,97,98,99,100";
    document.getElementById("help").innerHTML = resultLink("4e02415c73c35");
    var what = document.getElementById("PDB").options;
    for (i = 0; i <= what.length; i++)
    {
        if ( what[i].value == '1S72' )
        {
            document.getElementById("PDB").selectedIndex = i;
            break;
        }
    }
    document.getElementById("disc").value = "0.5";
    document.getElementById("nr_release_list").value = "0.22";
    document.getElementById("nr_resolution").selectedIndex = 5;

    CreateMatrix(this.form);

    document.getElementById("cell13").value = 'cWW';
    document.getElementById("cell25").value = 'tSH ntSH';
    document.getElementById("cell37").value = 'tSH ntSH';
    document.getElementById("cell49").value = 'tHS ntHS';
    document.getElementById("cell58").value = 'cWW';
    document.getElementById("cell14").value  = '<5';
    document.getElementById("cell28").value  = '<5';
    document.getElementById("cell42").value  = '<5';
    document.getElementById("cell56").value  = '<5';
    document.getElementById("cell84").value  = '<5';
    document.getElementById("cell98").value  = '<5';
    document.getElementById("cell112").value  = '<5';
    document.getElementById("cell126").value  = '<5';
    document.getElementById("cell140").value  = '<5';
    document.getElementById("cell154").value  = '<5';
    document.getElementById("cell168").value  = '<5';
}

function CLoopTemplate()
{
    ResetAll();
    document.getElementById("NT").value = "73:77,95:101";
    queryNTs = "73,74,75,76,77,95,96,97,98,99,100,101";
    document.getElementById("help").innerHTML = resultLink("4e02420231066");
    var what = document.getElementById("PDB").options;
    for (i = 0; i <= what.length; i++)
    {
        if ( what[i].value == '1KOG' )
        {
            document.getElementById("PDB").selectedIndex = i;
            break;
        }
    }
    document.getElementById("disc").value = "0.5";
    document.getElementById("nr_release_list").value = "0.22";
    document.getElementById("nr_resolution").selectedIndex = 5;

    CreateMatrix(this.form);

    document.getElementById("cell12").value = 'cWW';
    document.getElementById("cell54").value = 'cWW';
    document.getElementById("cell13").value  = '<5';
    document.getElementById("cell26").value  = '<5';
    document.getElementById("cell39").value  = '<5';
    document.getElementById("cell52").value  = '<5';
    document.getElementById("cell78").value  = '<5';
    document.getElementById("cell91").value  = '<5';
    document.getElementById("cell104").value  = '<5';
    document.getElementById("cell117").value  = '<5';
    document.getElementById("cell130").value  = '<5';
    document.getElementById("cell143").value  = '<5';
}
