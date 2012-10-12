function Check(form)
{
    if ( ValidateTargetPDBs() ) {
        if (ValidateNT() ) {
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
		 message = 'Enter up to 25 nucleotides separated by commas. You can specify ranges using semicolon.<br>';
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

function ValidateNT()
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
	if ( ValidateNT() )
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
                    headerTd.innerHTML = 'NT' + i;
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
                          newTD.innerHTML = 'NT' + i;
                      }
                      else
                      {
                          count += 1;
                          if ( i == j-1 )
                          {
                          newTD.innerHTML = "<input type='text' onclick='ShowHelp(this)' name='mat[]' value='N' class='diagonal' id='cell"+count+"'</input>";
                          }
                          if ( i < j-1 )
                          {
                          newTD.innerHTML = "<input type='text' onclick='ShowHelp(this)' name='mat[]' value='' class='inter' id='cell"+count+"'</input>";
                          }
                          if ( i > j-1 )
                          {
                          newTD.innerHTML = "<input type='text' onclick='ShowHelp(this)' name='mat[]' value='' class='dist' id='cell"+count+"'</input>";
                          }
                      }
                }
            }
            document.getElementById('submit').disabled = false;
            document.getElementById('submit').focus();
        }
}

function ResetAll()
{
    document.getElementById("NumNT").value = "";
    document.getElementById("SelectElem").selectedIndex = -1;
    document.getElementById("email").value = "";
//    document.getElementById("templates").selectedIndex = 0;
    document.getElementById("NumNT").selectedIndex = 0;

    var theForm = document.getElementById('mat');
    if (theForm != null)
    {
        RemoveNodes(theForm);
    }
    else alert('Interaction Matrix not found');

    document.getElementById('submit').disabled = true;
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
    document.getElementById("SelectElem").value = "3I8I";
    document.getElementById("help").innerHTML = '<a href="http://rna.bgsu.edu/WebFR3D/Results/4d0804a7bb1d0/results.php">View results</a>';
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
    document.getElementById("help").innerHTML = '<a href="http://rna.bgsu.edu/WebFR3D/Results/4d07a35dd4635/results.php">View results</a>';
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
    document.getElementById("help").innerHTML = '<a href="http://rna.bgsu.edu/WebFR3D/Results/4d07a68037c2b/results.php">View results</a>';
}

function cWW_tHWBaseTriples()
{
	ResetAll();
    document.getElementById("NumNT").value = "3";
    document.getElementById("SelectElem").value = "3I8I";
    CreateMatrix(this.form);

    document.getElementById("cell2").value = 'cWW';
    document.getElementById("cell6").value = 'tHW';

    document.getElementById("help").innerHTML = '<a href="http://rna.bgsu.edu/WebFR3D/Results/4d07acda133a4/results.php">View results</a>';
}

function TripleSheared()
{
	ResetAll();
    document.getElementById("NumNT").value = "10";
    document.getElementById("SelectElem").value = "3I8I";
    CreateMatrix(this.form);

    document.getElementById("cell10").value = 'cWW';
    document.getElementById("cell19").value = 'tSH ntSH';
    document.getElementById("cell28").value = 'tSH ntSH';
    document.getElementById("cell37").value = 'tHS ntHS';
    document.getElementById("cell46").value = 'cWW';

    document.getElementById("cell11").value = '=1';
    document.getElementById("cell22").value = '=1';
    document.getElementById("cell33").value = '=1';
    document.getElementById("cell44").value = '=1';
    document.getElementById("cell66").value = '=1';
    document.getElementById("cell77").value = '=1';
    document.getElementById("cell88").value = '=1';
    document.getElementById("cell99").value = '=1';

    document.getElementById("help").innerHTML = '<a href="http://rna.bgsu.edu/WebFR3D/Results/4d07b26217358/results.php">View results</a>';
}
