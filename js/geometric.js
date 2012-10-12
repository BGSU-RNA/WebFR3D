function Check(form)
{
	queryNTs = '';
    if ( ValidatePDB() )
    {
        if ( ValidateTargetPDBs() )
        {
            if ( ValidateDiscrepancy() )
            {
                if (LookUpNTs(document.getElementById('NT'),'synch') )
                {
                    if (ValidateChains() ) {
                    	EnableAllChains();
                	   return true;
                    }
                }
            }
        }
    }

    return false;
}

function SetUp()
{
	queryNTs = '';
}

function ViewQuery()
{
    if ( ValidatePDB() == false ) {
    	return;
    }
    if (queryNTs == '') {
    	alert('Please enter nucleotides');
    	return;
    }
	LookUpNTs(document.getElementById('NT'),'synch');
	var pdb = document.getElementById('PDB').value;
	var nts = queryNTs.split(',');
	var chains = '';
	var i;

	if (document.getElementById('chain_' + (nts.length-1)) == null) {
		getChainFromPDB('synch');
	}
	for (i=0;i<nts.length;i++) {
		chains = chains + document.getElementById('chain_' + i).value + ',';
	}
	var queryString = 'nts=' + queryNTs + '&ch=' + chains + '&pdb=' + pdb;
    var ajaxRequest = CreateAjaxRequestObject();
	ajaxRequest.open("POST", "php/getPdbFragment.php", true);
	ajaxRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	ajaxRequest.send(queryString);
	ajaxRequest.onreadystatechange = function() {//Call a function when the state changes.
		if(ajaxRequest.readyState == 4 && ajaxRequest.status == 200) {
			RemoveNodes(document.getElementById('jmol'));
			document.getElementById('root').style.visibility = 'visible';
			jmolInitialize('../jmol');
			jmolSetDocument(false);
			jmolSetAppletColor('white');
            var downloadUrl = window.location.origin + '/' + window.location.pathname.split('/')[1] + '/php/';
			var jmoldiv = jmolAppletInline(300,ajaxRequest.responseText,'select [U]; color navy; select [C]; color gold;select [G]; color chartreuse; select [A]; color red;select all;spacefill off;cartoon;');
			jmoldiv = jmoldiv + jmolCheckbox('select *.C5;label "%n%R";color labels black;', "labels off", "nucleotide numbers", false);
			jmoldiv = jmoldiv + "&nbsp;&nbsp;&nbsp;";
			jmoldiv += "<a href='"+downloadUrl+"getPdbFragment.php?" + queryString + "' class='small_font'>Download pdb</a>";
			document.getElementById('jmol').innerHTML = jmoldiv;
		}
	}
}

function onDownload(dataToDownload) {
    document.location = 'data:Application/octet-stream,' + dataToDownload;
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
		 message = 'Enter up to 25 nucleotides separated by commas. You can specify ranges using colons.<br>';
		 helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Input nucleotides', this.href)\">More</a>";
	} else if (classname.search(/where/) != -1) {
		 message = 'You can select multiple structures by holding Cmd or Alt key.<br>';
		 helplink  = "<a href='help.html#" + classname + "' onclick=\"return GB_showCenter('Search files', this.href)\">More</a>";
	}
	if (helplink != '') {
		help.innerHTML = message + helplink;
	}
}

function EnableAllChains()
{ // disabled elements must be enabled to be submitted
	var i = 0;
	while (document.getElementById('chain_' + i))  {
		document.getElementById('chain_' + i).disabled = false;
		i++;
	}
	return true;
}

function LookUpNTs(nts,mode)
{
	var PDB = document.getElementById('PDB').value;
	if (PDB == '----') { // nothing to check yet
		return;
	}

	if (nts.value != '') {
  	    var ajaxRequest = CreateAjaxRequestObject();
		var queryString = 'nucleotides=' + nts.value + '&PDBquery=' + PDB;

        var ReactToAjaxResponse = function(nts,responseText) {
    		if (responseText.search(/Please/) != -1) {
    			alert(responseText);
    			nts.focus();
    			queryNTs = '';
    			return false;
    		}
    	    if (responseText.search(/No nucleotide/i) != -1 ) {
    			alert(responseText);
    			nts.focus();
    			queryNTs = '';
    			return false;
    	    }
    	    if (responseText.search(/doesn't exist/i) != -1 ) {
    			alert(responseText);
    			nts.focus();
    			queryNTs = '';
    			return false;
    	    }
    	    queryNTs = responseText;
    		return true;
        }

		if (mode == 'asynch') {
    		ajaxRequest.open("POST", "php/parseNTs.php", true);
    		ajaxRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    		ajaxRequest.send(queryString);
    		ajaxRequest.onreadystatechange = function() {//Call a function when the state changes.
    			if(ajaxRequest.readyState == 4 && ajaxRequest.status == 200) {
    			     return ReactToAjaxResponse(nts,ajaxRequest.responseText);
    			}
    		}
		} else {
    		ajaxRequest.open("POST", "php/parseNTs.php", false);
    		ajaxRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    		ajaxRequest.send(queryString);
            return ReactToAjaxResponse(nts,ajaxRequest.responseText);
		}

	}
	else {
		alert('Please enter nucleotides');
		nts.focus();
		return false;
	}
}

function CreateAjaxRequestObject()
{
	var ajaxRequest;
	try{ // Opera 8.0+, Firefox, Safari
		ajaxRequest = new XMLHttpRequest();
		ajaxRequest.overrideMimeType('text/xml');
		return ajaxRequest;
	} catch (e){ // Internet Explorer Browsers
		try{
			ajaxRequest = new ActiveXObject("Msxml2.XMLHTTP");
			return ajaxRequest;
		} catch (e) {
			try{
				ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
				return ajaxRequest;
			} catch (e){ // Something went wrong
				alert("Your browser doesn't support AJAX");
				return false;
			}
		}
	}
}

function HideJmolDiv()
{
	document.getElementById('root').style.visibility = 'hidden';
	RemoveNodes(document.getElementById('jmol'));
}

function getChainFromPDB(mode)
{
    var PDB = document.getElementById('PDB');
	var nts = queryNTs;
	var ajaxRequest = CreateAjaxRequestObject();

    var ReactToAjaxResponse = function(responseText) {
		var chaintr = document.getElementById('chaintr');
		if (chaintr != null) {
			chaintr.parentNode.removeChild(chaintr);
//			document.getElementById('matrix').removeNode(chaintr);
		}
        var mat = document.getElementById('matrix');
		var newTR = document.createElement('tr');
		newTR.setAttribute('id','chaintr');
		mat.appendChild(newTR);
		newTR.innerHTML = ajaxRequest.responseText;
    }

	var queryString = "?pdb=" + PDB.value + '&nts=' + nts;
	if (mode == 'asynch') {
		ajaxRequest.open("GET", "php/lookupchains.php" + queryString, true);
   		ajaxRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
   		ajaxRequest.send(queryString);
   		ajaxRequest.onreadystatechange = function() {//Call a function when the state changes.
   			if(ajaxRequest.readyState == 4 && ajaxRequest.status == 200) {
   			     ReactToAjaxResponse(ajaxRequest.responseText);
   			}
   		}
	} else {
		ajaxRequest.open("GET", "php/lookupchains.php" + queryString, false);
   		ajaxRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
   		ajaxRequest.send(queryString);
        ReactToAjaxResponse(nts,ajaxRequest.responseText);
	}
}

function ValidateChains()
{
	var warning = document.getElementById("warning");
	if (warning != null) {
		alert('Please check your nucleotide selection');
		warning.focus;
		return false;
	}
	return true;
}

function ValidateMatrix()
{
    var mat = document.getElementById('matrix');
    var ncells = Math.pow(mat.childNodes.length,2);
//    var expr = //

    for (i = 1; i <= ncells; i++)
    {
        var cell = document.getElementById('cell' + i);

        if (cell.value.match(/cWW/)) {alert('cWW');}
    }

}

function ValidateDiscrepancy()
{
    var disc = document.getElementById('disc');
    disc.value = disc.value.replace(/,/,'.');
    var expr = /^0.\d+$/;
    if ( disc.value < 0 | disc.value > 1.2 | !disc.value.match(expr) )
    {
        alert("Please select a discrepancy cutoff between 0 and 0.8.");
        return false;
    }
    else
    {
        return true;
    }
}

function ValidatePDB()
{
    var PDB = document.getElementById('PDB');
    if ( PDB.value == '----' )
    {
        alert("Invalid PDB");
        PDB.focus();
        return false;
    }
    else
    {
        return true;
    }
}

function ValidateTargetPDBs()
{
    var PDBs = document.getElementById('SelectElem');
    if ( PDBs.selectedIndex == -1 )
    {
        alert("No target files selected");
        PDBs.focus();
        return false;
    }
    else
    {
        return true;
    }
}


function ValidateNT()
{
    var NT = document.getElementById('NT');
    NT.value = NT.value.replace(/ +/g,',');
    NT.value = NT.value.replace(/,,/g,',');
    var NTs = NT.value;
	var nts = NTs.split(',');
	nts.sort(function(a,b){return a-b});
	NT.value = nts;
    var expr = /^(\d+[,|:]?)+$/;

    if ( NT.length == 0 | !NT.value.match(expr) | !NT.value.match(/[,|:]/))
    {
            alert('Invalid nucleotides');
    }
    else
    {
        NT.value = NT.value.replace(/,$/,'');
        if ( NT.value.match(/:/) )
        {
            expr = /\d+:\d+/g;
            var block = NT.value.match(expr);
            for (i = 0; i < block.length; i++)
            {
                thisblock = block[i].toString();
                var myArray = thisblock.split(':');
                var temp = '';
                for (j = myArray[0]; j <= myArray[1]; j++)
                {
                    if ( j < myArray[1] )
                    {
                        temp += j+',';
                    }
                    else
                    {
                        temp += j
                    }
                }
                NT.value = NT.value.replace(thisblock, temp);
            }
        }
        var commas = NT.value.match(/,/g);
    	if ( commas.length > 24 )
    	{
    		alert('Please limit your search to 25 nucleotides');
    		return false;
    	}
    	else
    	{
    		return true;
    	}
    }
}

function CreateMatrix()
{

//    var form = document.getElementById('mainform');
//	if ( ValidateNT() && ValidatePDB() )

	if ( ValidatePDB() )
	{
		if (queryNTs == '') {
			LookUpNTs(document.getElementById('NT'),'synch');
		}
		var NT = queryNTs;
//		NT = document.getElementById('NT').value;
//        var NT = form.nucleotides.value;
        if (NT != '')
        {
            var fields = NT.match(/,/g);
            var cells = fields.length + 1;
    		var nts = NT.split(',');
//    		nts.sort(function(a,b){return a-b});

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
                    headerTd.innerHTML = 'NT' + nts[i-1];
                }
                headerRow.appendChild(headerTd);
            }
            for ( i = 1; i <= cells; i++ )
            {
                var newTR = document.createElement("tr");
                newTable.appendChild(newTR);
                for (j = 1; j <= cells + 1; j++)
                {
                      var newTD = document.createElement("td");
                      newTR.appendChild(newTD);
                      if ( j == 1 )
                      {
                          newTD.innerHTML = 'NT' + nts[i-1];
                          newTD.setAttribute("class","rowheader");
                      }
                      else
                      {
                          count += 1;
                          if ( i == j-1 )
                          {
                          newTD.innerHTML = "<input type='text' name='mat[]' value='N' onclick='ShowHelp(this);' class='diagonal' id='cell"+count+"'</input>";
                          }
                          if ( i < j-1 )
                          {
                          newTD.innerHTML = "<input type='text' name='mat[]' class='inter' onclick='ShowHelp(this);' id='cell"+count+"'</input>";
                          }
                          if ( i > j-1 )
                          {
                          newTD.innerHTML = "<input type='text' name='mat[]' class='dist' onclick='ShowHelp(this);' id='cell"+count+"'</input>";
                          }
                      }
                }
            }
            document.getElementById('submit').disabled = false;
            document.getElementById('view').disabled = false;
            document.getElementById('view').focus();
    	    getChainFromPDB('asynch');
        }
	}
}

function ResetAll()
{
    document.getElementById("NT").value = '';
    document.getElementById("PDB").value = '----';
    document.getElementById("help").innerHTML = '';
    document.getElementById("disc").value = "0.4";
    document.getElementById("SelectElem").selectedIndex = -1;
    document.getElementById("email").value = "";

    var theForm = document.getElementById('mat');
    if (theForm != null) {
        RemoveNodes(theForm);
    }
	queryNTs = '';
    document.getElementById('submit').disabled = true;
    document.getElementById('view').disabled = false;
    HideJmolDiv();
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

function TripleShearedTemplate()
{
	ResetAll();
//    document.getElementById("NT").value = "1856,1857,1858,1859,1860,1882,1883,1884,1885,1886";
//    queryNTs = "1856,1857,1858,1859,1860,1882,1883,1884,1885,1886";
    document.getElementById("NT").value = "1856:1860, 1882:1886";
    queryNTs = "1856,1857,1858,1859,1860,1882,1883,1884,1885,1886";
	document.getElementById("help").innerHTML = "<a href='http://rna.bgsu.edu/WebFR3D/Results/4d07a1a83f7dd/results.php'>View results</a>";
    var what = document.getElementById("PDB").options;
    for (i = 0; i <= what.length; i++)
    {
        if ( what[i].value == '3I8I' )
        {
            document.getElementById("PDB").selectedIndex = i;
            break;
        }
    }
    document.getElementById("disc").value = "0.4";
    document.getElementById("SelectElem").value = "3I8I";
    CreateMatrix(this.form);

    document.getElementById("cell2").value = 'stack nstack';
    document.getElementById("cell13").value = 'stack nstack';
    document.getElementById("cell35").value = 'stack nstack';
    document.getElementById("cell90").value = 'stack nstack';

    document.getElementById("cell10").value = 'cWW';
    document.getElementById("cell46").value = 'cWW';

    document.getElementById("cell19").value = 'tSH ntSH';
    document.getElementById("cell28").value = 'tSH ntSH';
    document.getElementById("cell37").value = 'tHS ntHS';

    document.getElementById("cell11").value = '<3';
    document.getElementById("cell11").value = '<3';
    document.getElementById("cell22").value = '<3';
    document.getElementById("cell33").value = '<3';
    document.getElementById("cell44").value = '<3';
    document.getElementById("cell66").value = '<3';
    document.getElementById("cell77").value = '<3';
    document.getElementById("cell88").value = '<3';
    document.getElementById("cell99").value = '<3';
}

function SarcinTemplate()
{
	ResetAll();
    document.getElementById("NT").value = "2701:2704, 2694:2690";
    queryNTs = "2701,2702,2703,2704,2690,2691,2692,2693,2694";
	document.getElementById("help").innerHTML = "<a href='http://rna.bgsu.edu/WebFR3D/Results/4e023dc5d5c08/results.php'>View results</a>";
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
    document.getElementById("SelectElem").value = "NR_list_4A_2011-06-18";
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

function TLoopTemplate()
{
	ResetAll();
    document.getElementById("NT").value = "312:319";
    queryNTs = "312,313,314,315,316,317,318,319";
	document.getElementById("help").innerHTML = "<a href='http://rna.bgsu.edu/WebFR3D/Results/4e023e7dac8d1/results.php'>View results</a>";
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
    document.getElementById("SelectElem").value = "NR_list_4A_2011-06-18";
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
	document.getElementById("help").innerHTML = "<a href='http://rna.bgsu.edu/WebFR3D/Results/4e02415c73c35/results.php'>View results</a>";
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
    document.getElementById("SelectElem").value = "NR_list_4A_2011-06-18";
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
	document.getElementById("help").innerHTML = "<a href='http://rna.bgsu.edu/WebFR3D/Results/4e02420231066/results.php'>View results</a>";
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
    document.getElementById("SelectElem").value = "NR_list_4A_2011-06-18";
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
