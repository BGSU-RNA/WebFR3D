lock = new Array();

document.onkeydown=function(e){
    if(e.which == 74 ) {
	    previous();
    } else if (e.which == 75) {
    	next();
    }
//    else if (e.which == 65) {
//		if (document.getElementById('mastercheck').checked) {
//			document.getElementById('mastercheck').checked = false;
//			jmolScript("frame all; hide all");
//			var num = 1;
//			while (document.getElementById('structure'+num)) {
//				document.getElementById('structure'+num).checked = false;
//				num++;
//			}
//		} else {
//			document.getElementById('mastercheck').checked = true;
//			jmolScript("frame all; display all");
//			var num = 1;
//			while (document.getElementById('structure'+num)) {
//				document.getElementById('structure'+num).checked = true;
//				num++;
//			}
//		}
//    }
}

function SwitchModelLayer() {
	if (document.getElementById('layer').checked) { // display neighborhood
		document.getElementById('master1').style.visibility="hidden";
		document.getElementById('master0').style.visibility="visible";
		document.getElementById('layer0').style.zIndex="1";
		document.getElementById('layer1').style.zIndex="0";
		var i = 1;
		while (document.getElementById('structure'+i)) {
			jmolScript("select "+i+".2;color grey");
			if (document.getElementById('structure'+i).checked) {
				document.getElementById('neighbors'+i).checked = true;
				jmolScript("frame all;display displayed or "+i+".2");
			}
			if (!document.getElementById('structure'+i).checked) {
				document.getElementById('neighbors'+i).checked = false;
			}
			i++;
		}
		if (document.getElementById('mastercheck1').checked) {
			document.getElementById('mastercheck0').checked = true;
		}
		if (!document.getElementById('mastercheck1').checked) {
			document.getElementById('mastercheck0').checked = false;
		}
	} else { // hide neighborhood
		document.getElementById('master0').style.visibility="hidden";
		document.getElementById('master1').style.visibility="visible";
		document.getElementById('layer1').style.zIndex="1";
		document.getElementById('layer0').style.zIndex="0";
		var i = 1;
		while (document.getElementById('neighbors'+i)) {
			if (document.getElementById('neighbors'+i).checked) {
				document.getElementById('structure'+i).checked = true;
				jmolScript("frame all;display displayed or "+i+".1");
			}
			if (!document.getElementById('neighbors'+i).checked) {
				document.getElementById('structure'+i).checked = false;
			}
			jmolScript("frame all;display displayed and not "+i+".2");
			i++;
		}
		if (document.getElementById('mastercheck0').checked) {
			document.getElementById('mastercheck1').checked = true;
		} else {
			document.getElementById('mastercheck1').checked = false;
		}
	}
}

function HidePDBDiv()
{
	document.getElementById('root').style.visibility = 'hidden';
	RemoveNodes(document.getElementById('pdbhint'));
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

function Lock(num)
{
	if (!document.getElementById('structure'+num).checked) {
		document.getElementById('structure'+num).checked = true;
		jmolScript("frame all;display displayed or "+num+  ".1");
	}
	var image = document.getElementById('lock'+num);
	if (image.className == 'lock') {
		image.className = 'locked';
		lock.push(num);
	} else {
		image.className = 'lock';
		var idx = lock.indexOf(num);
		if(idx!=-1) lock.splice(idx, 1);
	}
}

function next()
{

	if (document.getElementById('layer').checked) {
		var prefix = 'neighbors';
		var second = 'structure';
		var mode = '0';
	} else {
		var prefix = 'structure';
		var second = 'neighbors';
		var mode = '1';
	}

	var checkedBoxes = new Array();
	var i = 1;
	while (document.getElementById(prefix+i)) {
		if (document.getElementById(prefix+i).checked) {
			if (lock.indexOf(i) == -1) {
				checkedBoxes.push(i);
			}
		}
		i++;
	}
	i = 0;
	while (i<checkedBoxes.length) {
		var current = checkedBoxes[i];
		var next = checkedBoxes[i]+1;
		if (lock.indexOf(next) != -1) {
			next = checkedBoxes[i]+2;
		}
		if (!document.getElementById(prefix+next)) {
			break;
		}
		while (document.getElementById(prefix+next).checked) {
			next++;
			if (!document.getElementById(prefix+next)) {
				break;
			}
		}
		if (document.getElementById(prefix+next)) {
			if (lock.indexOf(current) == -1) {
				jmolScript("frame all;display displayed and not "+current+  "." +mode);
				document.getElementById(prefix+current).checked = false;
				document.getElementById(second+current).checked = false;
			}
			jmolScript("frame all;display displayed or "+next+  "." + mode);
			document.getElementById(prefix+next).checked = true;
			document.getElementById(second+next).checked = true;
		}
		i = checkedBoxes.indexOf(next-1);
		if (i == -1) {
			break;
		}
		i++;

	}
}

function previous()
{

	if (document.getElementById('layer').checked) {
		var prefix = 'neighbors';
		var second = 'structure';
		var mode = '0';
	} else {
		var prefix = 'structure';
		var second = 'neighbors';
		var mode = '1';
	}

	var checkedBoxes = new Array();
	var i = 1;
	while (document.getElementById(prefix+i)) {
		if (document.getElementById(prefix+i).checked) {
			if (lock.indexOf(i) == -1) {
				checkedBoxes.push(i);
			}				}
		i++;
	}
	var i = checkedBoxes.length - 1;
	while (i>=0) {
		var current = checkedBoxes[i];
		var next = checkedBoxes[i]-1;
		if (!document.getElementById(prefix+next)) {
			break;
		}
		while (document.getElementById(prefix+next).checked) {
			next--;
			if (!document.getElementById(prefix+next)) {
				break;
			}
		}
		if (document.getElementById(prefix+next)) {
			if (lock.indexOf(current) == -1) {
				jmolScript("frame all;display displayed and not "+current+  "."+mode);
				document.getElementById(prefix+current).checked = false;
				document.getElementById(second+current).checked = false;
			}
			jmolScript("frame all;display displayed or "+next+  "."+mode);
			document.getElementById(prefix+next).checked = true;
			document.getElementById(second+next).checked = true;
		}
		i = checkedBoxes.indexOf(next+1);
		i--;
	}
}

function setUp()
{
	var oRows = document.getElementById('maintable').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	if (iRowCount < 12) {
		var newheight = 25*iRowCount + 20;
		document.getElementById('annotations').style.height = newheight + 'px';
	}
}

function LookUpPDBInfo(pdb)
{
	var ajaxRequest = CreateAjaxRequestObject();
	ajaxRequest.open("POST", "http://rna.bgsu.edu/webfr3d/lookuppdbinfo.php", true);
	ajaxRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	re = /[a-zA-Z0-9]{4}/;
	pdb = re.exec(pdb);
	ajaxRequest.send('pdb='+pdb[0]);
	ajaxRequest.onreadystatechange = function() {//Call a function when the state changes.
		if(ajaxRequest.readyState == 4 && ajaxRequest.status == 200) {
		     document.getElementById('pdbhint').innerHTML = ajaxRequest.responseText;
		     var post = parseInt(document.getElementById('annotations').offsetLeft) + 450;
			 document.getElementById('root').style.left= post + 'px';
			 document.getElementById('root').style.visibility = 'visible';
		}
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


/*

	Tablecloth
	written by Alen Grakalic, provided by Css Globe (cssglobe.com)
	please visit http://cssglobe.com/lab/tablecloth/

*/

this.tablecloth = function(){

	// CONFIG

	// if set to true then mouseover a table cell will highlight entire column (except sibling headings)
	var highlightCols = true;

	// if set to true then mouseover a table cell will highlight entire row	(except sibling headings)
	var highlightRows = true;

	// if set to true then click on a table sell will select row or column based on config
	var selectable = true;

	// this function is called when
	// add your own code if you want to add action
	// function receives object that has been clicked
	this.clickAction = function(obj){
		//alert(obj.innerHTML);

	};



	// END CONFIG (do not edit below this line)


	var tableover = false;
	this.start = function(){
		var tables = document.getElementById('maintable'); //sByTagName("table"); //ById("maintable");
//		for (var i=0;i<tables.length;i++){
			tables.onmouseover = function(){tableover = true};
			tables.onmouseout = function(){tableover = false};
			rows(tables);
//		};
	};

	this.rows = function(table){
		var css = "";
		var tr = table.getElementsByTagName("tr");
		for (var i=0;i<tr.length;i++){
			css = (css == "odd") ? "even" : "odd";
			tr[i].className = css;
			var arr = new Array();
			for(var j=0;j<tr[i].childNodes.length;j++){
				if(tr[i].childNodes[j].nodeType == 1) arr.push(tr[i].childNodes[j]);
			};
			for (var j=0;j<arr.length;j++){
				arr[j].row = i;
				arr[j].col = j;
				if(arr[j].innerHTML == "&nbsp;" || arr[j].innerHTML == "") arr[j].className += " empty";
				arr[j].css = arr[j].className;
				arr[j].onmouseover = function(){
					over(table,this,this.row,this.col);
				};
				arr[j].onmouseout = function(){
					out(table,this,this.row,this.col);
				};
				arr[j].onmousedown = function(){
					down(table,this,this.row,this.col);
				};
				arr[j].onmouseup = function(){
					up(table,this,this.row,this.col);
				};
				arr[j].onclick = function(){
					click(table,this,this.row,this.col);
				};
			};
		};
	};

	// appyling mouseover state for objects (th or td)
	this.over = function(table,obj,row,col){
		if (!highlightCols && !highlightRows) obj.className = obj.css + " over";
		if(check1(obj,col)){
			if(highlightCols) highlightCol(table,obj,col);
			if(highlightRows) highlightRow(table,obj,row);
		};
	};
	// appyling mouseout state for objects (th or td)
	this.out = function(table,obj,row,col){
		if (!highlightCols && !highlightRows) obj.className = obj.css;
		unhighlightCol(table,col);
		unhighlightRow(table,row);
	};
	// appyling mousedown state for objects (th or td)
	this.down = function(table,obj,row,col){
		obj.className = obj.css + " down";
	};
	// appyling mouseup state for objects (th or td)
	this.up = function(table,obj,row,col){
		obj.className = obj.css + " over";
	};
	// onclick event for objects (th or td)
	this.click = function(table,obj,row,col){
		if(check1){
			if(selectable) {
				unselect(table);
				if(highlightCols) highlightCol(table,obj,col,true);
				if(highlightRows) highlightRow(table,obj,row,true);
				document.onclick = unselectAll;
			}
		};
		clickAction(obj);
	};

	this.highlightCol = function(table,active,col,sel){
		var css = (typeof(sel) != "undefined") ? "selected" : "over";
		var tr = table.getElementsByTagName("tr");
		for (var i=0;i<tr.length;i++){
			var arr = new Array();
			for(j=0;j<tr[i].childNodes.length;j++){
				if(tr[i].childNodes[j].nodeType == 1) arr.push(tr[i].childNodes[j]);
			};
			var obj = arr[col];
			if (check2(active,obj) && check3(obj)) obj.className = obj.css + " " + css;
		};
	};
	this.unhighlightCol = function(table,col){
		var tr = table.getElementsByTagName("tr");
		for (var i=0;i<tr.length;i++){
			var arr = new Array();
			for(j=0;j<tr[i].childNodes.length;j++){
				if(tr[i].childNodes[j].nodeType == 1) arr.push(tr[i].childNodes[j])
			};
			var obj = arr[col];
			if(check3(obj)) obj.className = obj.css;
		};
	};
	this.highlightRow = function(table,active,row,sel){
		var css = (typeof(sel) != "undefined") ? "selected" : "over";
		var tr = table.getElementsByTagName("tr")[row];
		for (var i=0;i<tr.childNodes.length;i++){
			var obj = tr.childNodes[i];
			if (check2(active,obj) && check3(obj)) obj.className = obj.css + " " + css;
		};
	};
	this.unhighlightRow = function(table,row){
		var tr = table.getElementsByTagName("tr")[row];
		for (var i=0;i<tr.childNodes.length;i++){
			var obj = tr.childNodes[i];
			if(check3(obj)) obj.className = obj.css;
		};
	};
	this.unselect = function(table){
		tr = table.getElementsByTagName("tr")
		for (var i=0;i<tr.length;i++){
			for (var j=0;j<tr[i].childNodes.length;j++){
				var obj = tr[i].childNodes[j];
				if(obj.className) obj.className = obj.className.replace("selected","");
			};
		};
	};
	this.unselectAll = function(){
		if(!tableover){
			tables = document.getElementsByTagName("table");
			for (var i=0;i<tables.length;i++){
				unselect(tables[i])
			};
		};
	};
	this.check1 = function(obj,col){
		return (!(col == 0 && obj.className.indexOf("empty") != -1));
	}
	this.check2 = function(active,obj){
		return (!(active.tagName == "TH" && obj.tagName == "TH"));
	};
	this.check3 = function(obj){
		return (obj.className) ? (obj.className.indexOf("selected") == -1) : true;
	};

	start();

};

/* script initiates on page load. */
//window.onload = tablecloth;
