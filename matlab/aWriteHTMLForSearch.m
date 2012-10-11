function [] = aWriteHTMLForSearch(filename)

root = '/Servers/rna.bgsu.edu/webfred';
webroot = 'http://rna.bgsu.edu/webfred';

resultsdir = fullfile(root, 'Results', filename); %strcat('/Servers/rna.bgsu.edu/webfred/Results/',filename);
fr3dpath = fullfile(root, 'FR3D_submodule');
pdbdatabase = fullfile(root, 'Results', 'PDBDatabase');
web_pdbdatabase = strcat(webroot, '/', 'Results', '/', 'PDBDatabase');
pictures = fullfile(root, 'Results', 'Pictures');
web_pictures = strcat(webroot, '/', 'Results', '/', 'Pictures');

MAXPDB = 40;

if exist([resultsdir filesep filename '.mat'],'file')
    load([resultsdir filesep filename '.mat']);
else
    ShowMessage(resultsdir,webroot,'Some error occured while processing your request. Please try again later.');
    return;
end

if isempty(Search.Candidates)
    ShowMessage(resultsdir,webroot,'There were no candidates found in the desired discrepancy range.',Search,filename);
    return;
    %     fid = fopen([resultsdir filesep 'results.php'],'w');
    %     fprintf(fid, '<html><head><link rel="stylesheet" type="text/css" href="%s/Library.css"><title>FR3D results</title></head><body>',webroot);
    %     fprintf(fid, '<div class="message">');
    %     fprintf(fid, '<h2>Thank you for using FR3D</h2><br>');
    %     fprintf(fid, '<p>There were no candidates found in the desired discrepancy range.</p><br><br>');
    %     fprintf(fid, '</div></body></html>');
    %     fclose(fid);
    %     if isfield(Search.Query, 'Email')
    %         link = sprintf('%s/Results/%s/results.php', webroot, filename);
    %         message = sprintf('Please visit this webpage to see your FR3D results: %s  This is an automated message. For support, email apetrov@bgsu.edu', link);
    %         command = sprintf('echo "%s" | tee foo | mail -s "FR3D results %s" %s', message, filename, Search.Query.Email);
    %         unix(command);
    %         clear Search.Query.Email;
    %     end
    %     return;
end


aWriteToPDB_neigh(Search, filename);
command=sprintf('cd %s/%s; zip %s.zip *.pdb', pdbdatabase, filename, filename);
unix(command);
aProduceMDGraph(Search, filename);
close(gcf);
Text = aListCandidates(Search,Inf,filename);

fid = fopen([resultsdir filesep 'results.php'],'w');
fprintf(fid,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/html4/loose.dtd">');
fprintf(fid,'<html lang = "en"><head><meta http-equiv="Content-Type" content="text/html;charset=utf-8" >');
fprintf(fid,'<title>FR3D results</title>');
fprintf(fid,'<link rel="stylesheet" type="text/css" href="%s/Library.css" >',webroot);
fprintf(fid,'<link rel="stylesheet" media="all" type="text/css" href="%s/css/menu_style.css" />',webroot);
fprintf(fid,'	<!--greybox-->');
fprintf(fid,'	<script type="text/javascript">');
fprintf(fid,'	    var GB_ROOT_DIR = "http://rna.bgsu.edu/webfr3d/greybox/";');
fprintf(fid,'	</script>');
fprintf(fid,'	<script type="text/javascript" src="http://rna.bgsu.edu/webfr3d/greybox/AJS.js"></script>');
fprintf(fid,'	<script type="text/javascript" src="http://rna.bgsu.edu/webfr3d/greybox/AJS_fx.js"></script>');
fprintf(fid,'	<script type="text/javascript" src="http://rna.bgsu.edu/webfr3d/greybox/gb_scripts.js"></script>');
fprintf(fid,'	<link href="http://rna.bgsu.edu/webfr3d/greybox/gb_styles.css" rel="stylesheet" type="text/css" />');
fprintf(fid,'	<!--greybox-->');


fprintf(fid,'<script src="%s/js/results.js" type="text/javascript"></script>',webroot);
% fprintf(fid,'<script src="%s/js/sorttable.js" type="text/javascript"></script>',webroot');

fprintf(fid,'<script src="../../../jmol/Jmol.js" type="text/javascript"></script></head>');
fprintf(fid,'<body onload="setUp();tablecloth();">');

fprintf(fid,'<div class="menu">');
fprintf(fid,'	<ul>');
fprintf(fid,'	<li><a href="http://rna.bgsu.edu/WebFR3D/index.html">WebFR3D</a></li>');
fprintf(fid,'	<li><a href="http://rna.bgsu.edu/WebFR3D/geometric.php">Geometric Search</a></li>');
fprintf(fid,'	<li><a>Switch to</a>');
fprintf(fid,'		<ul>');
fprintf(fid,'			<li><a href="http://rna.bgsu.edu/WebFR3D/symbolic.php">Symbolic search</a></li>');
fprintf(fid,'		</ul>');
fprintf(fid,'	</li>');
fprintf(fid,'	</ul>');
fprintf(fid,'</div><br>');


fprintf(fid,'<noscript>Your browser does not support JavaScript. Please turn it on or update your browser</noscript>\n');
fprintf(fid,'<div class="container">');
% fprintf(fid,'<h2 class="center">%s</h2>',filename);

fprintf(fid, '<div class="annotations" id="annotations">');

fprintf(fid,'<div id="root" class="rootdiv" style="left:600px; top:80px;">');
fprintf(fid,'<div id="handle" class="handle">PDB Info<img src="%s/greybox/w_close.gif" alt="Close" id="closewin" onClick="HidePDBDiv()"/></div>',webroot);
fprintf(fid,'<div id="pdbhint"></div>');
fprintf(fid,'</div>');


for c = 1:length(Text),
    fprintf(fid, '%s',Text{c});
end
fprintf(fid,'</div><br>\n');

% fprintf(fid,'<div style="margin-left:auto;margin-right:auto;text-align:center;width:100%%;">');
% if length(Search.Candidates(:,1)) > 1,
%     fprintf(fid,'<a href="%s/%s/%s.png">View Mutual Discrepancy Graph</a>', web_pictures,filename,filename);
% end
% fprintf(fid,'</div><br>');

fprintf(fid,'<table class="results"><tr>');
% fprintf(fid,'<td nowrap>');
fprintf(fid,'<td id="jmtd"><div class="jmolwindow">');
fprintf(fid,'<script type="text/javascript">');
fprintf(fid,'jmolInitialize("../../../jmol");');
fprintf(fid,'jmolSetAppletColor("white");');

 if length(Search.Candidates(:,1)) ~= 1,
     fprintf(fid,'jmolApplet(400, ''load files ');
 else
     fprintf(fid,'jmolApplet(400, ''load ');
 end
 for c = 1:min(length(Search.Candidates(:,1)),MAXPDB)
     fprintf(fid, '"%s/%s/%s_%i.pdb" ', web_pdbdatabase, filename, filename, c);
 end
 fprintf(fid, ';hide all;spacefill off;frame all;select [U]; color navy; select [C]; color gold;select [G]; color chartreuse; select [A]; color red;select all;display 1.1'');');

% fprintf(fid,'// a radio group');
% fprintf(fid,'jmolHtml("atoms ");');
% fprintf(fid,'jmolRadioGroup([');
% fprintf(fid,'   ["spacefill off",  "off", "checked"],');
% fprintf(fid,'   ["spacefill 20%%",  "20%%"],');
% fprintf(fid,'   ["spacefill 100%%", "100%%"]');
% fprintf(fid,'   ]);');
% fprintf(fid,'jmolBr();');
%fprintf(fid,'// a button');
%fprintf(fid,'jmolButton("reset", "Reset to original orientation");');
% fprintf(fid,'jmolButton("select [U]; color navy; select [C]; color gold;select [G]; color chartreuse; select [A]; color red;select all", "Color by nucleotide");');
fprintf(fid,'</script></div>');
fprintf(fid,'<script>');
fprintf(fid,'jmolBr();');
fprintf(fid,'jmolCheckbox("stereo on", "stereo off","Stereo on/off");');
fprintf(fid,'jmolHtml("&nbsp;&nbsp;");');
fprintf(fid,'jmolCheckbox(''select *.C5;label "%%n%%R";color labels black;'', "labels off", "nucleotide numbers on/off", false);');
% fprintf(fid,'jmolBr();');
fprintf(fid,'</script>');
fprintf(fid,'&nbsp;&nbsp;<input type="checkbox" onclick="SwitchModelLayer();" id="layer"/><label for="layer">16A neighborhood</label><br>');
% fprintf(fid,'Learn more about basepairs at the ');
% fprintf(fid,'<a href="%s">Online Basepair Catalog</a><br><br><br>','http://rna.bgsu.edu/FR3D/basepairs/');

fprintf(fid,'</td>\n');

fprintf(fid,'<td id="cbtd"><br>');
fprintf(fid,'<a href="javascript:previous()" title="keyboard shortcut: j" class="pdblink">Previous</a>&nbsp;|&nbsp;');
fprintf(fid,'<a href="javascript:next()" title="keyboard shortcut: k" class="pdblink">Next</a><br><br>');
fprintf(fid, '<div class="checkboxwrapper">');
fprintf(fid, '<div class="checkboxes" id="layer1">');
fprintf(fid, '<script type = "text/javascript">');
c = 1;
checkboxlist1 = '';
hideall = 'hide all;';
while (c <= min(length(Search.Candidates(:,1)),MAXPDB)),
    thisid =  sprintf('"structure%i"',c);
    if c == 1,
        fprintf(fid,'jmolHtml("<table class=''checklock''><tr><td>");');
        fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.1","frame all;display displayed and not %i.1","%s %i","checked",%s);',c,c,filename,c,thisid);
        fprintf(fid,'jmolHtml("</td><td>");');
        fprintf(fid,'jmolHtml("<span><img class=''lock'' id=''lock%i'' src=''http://rna.bgsu.edu/WebFR3D/images/Lock.png'' onclick=''Lock(%i);''></span>");',c,c);
        fprintf(fid,'jmolHtml("</td></tr>");');
    else
        fprintf(fid,'jmolHtml("<tr><td>");');
        fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.1","frame all;display displayed and not %i.1","%s %i",false,%s);',c,c,filename,c,thisid);
        fprintf(fid,'jmolHtml("</td><td>");');
        fprintf(fid,'jmolHtml("<span><img class=''lock'' id=''lock%i'' src=''http://rna.bgsu.edu/WebFR3D/images/Lock.png'' onclick=''Lock(%i);''></span>");',c,c);
        fprintf(fid,'jmolHtml("</td></tr>");');

%         fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.1","frame all;display displayed and not %i.1","%s %i",false,%s);',c,c,filename,c,thisid);
    end
    checkboxlist1 = strcat(checkboxlist1,thisid,',');
    hideall = sprintf('%sdisplay displayed or %i.1;',hideall,c);
%     fprintf(fid,'jmolBr();');
    c = c+1;
end
checkboxlist1 = checkboxlist1(1:end-1); % remove the last comma
fprintf(fid, '</script></table></div>');

fprintf(fid, '<div class="checkboxes" id="layer0" style="z-index:-1;">');
fprintf(fid, '<script type = "text/javascript">');
c = 1;
checkboxlist0 = '';
while (c <= min(length(Search.Candidates(:,1)),MAXPDB)),
    thisid =  sprintf('"neighbors%i"',c);
    if c == 1,
        fprintf(fid,'jmolHtml("<table class=''checklock''><tr><td>");');
        fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.0","frame all;display displayed and not %i.0","%s %i","checked",%s);',c,c,filename,c,thisid);
        fprintf(fid,'jmolHtml("</td><td>");');
        fprintf(fid,'jmolHtml("<img class=''lock'' id=''lock%i'' src=''http://rna.bgsu.edu/WebFR3D/images/Lock.png'' onclick=''Lock(%i);''>");',c,c);
        fprintf(fid,'jmolHtml("</td></tr>");');
    else
        fprintf(fid,'jmolHtml("<tr><td>");');
        fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.0","frame all;display displayed and not %i.0","%s %i",false,%s);',c,c,filename,c,thisid);
        fprintf(fid,'jmolHtml("</td><td>");');
        fprintf(fid,'jmolHtml("<img class=''lock'' id=''lock%i'' src=''http://rna.bgsu.edu/WebFR3D/images/Lock.png'' onclick=''Lock(%i);''>");',c,c);
        fprintf(fid,'jmolHtml("</td></tr>");');

%         fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.1","frame all;display displayed and not %i.1","%s %i",false,%s);',c,c,filename,c,thisid);
    end
    checkboxlist0 = strcat(checkboxlist0,thisid,',');
%     fprintf(fid,'jmolBr();');
    c = c+1;
end
checkboxlist0 = checkboxlist0(1:end-1); % remove the last comma
fprintf(fid, '</script></table></div>');

fprintf(fid,'<div class="mastercheckbox" id="master1"><script type = "text/javascript">');
fprintf(fid,'jmolBr();');
fprintf(fid,'jmolCheckbox("%s","frame all; hide all","Show/hide all",false,"mastercheck1");',hideall);
fprintf(fid,'jmolSetCheckboxGroup("mastercheck1",%s);',checkboxlist1);
fprintf(fid,'</script></div>');

hideall = strrep(hideall,'.1','.0');
fprintf(fid,'<div class="mastercheckbox" id="master0"><script type = "text/javascript">');
fprintf(fid,'jmolBr();');
fprintf(fid,'jmolCheckbox("%s","frame all; hide all","Show/hide all",false,"mastercheck0");',hideall);
fprintf(fid,'jmolSetCheckboxGroup("mastercheck0",%s);',checkboxlist0);
fprintf(fid,'</script></div></div>');






fprintf(fid, '</div>');


fprintf(fid,'</td>\n');

% fprintf(fid,'<td class="locks"><br><br><br>');
% c = 1;
% while (c <= min(length(Search.Candidates(:,1)),MAXPDB)),
%     fprintf(fid,'<span><img class="lock" id="lock%i" src="http://rna.bgsu.edu/WebFR3D/images/Lock.png" onclick="Lock(%i);"></span><br>',c,c);
%     c = c+1;
% end
% fprintf(fid,'</td>\n');


fprintf(fid,'<td><br>');
if length(Search.Candidates(:,1)) > 1,
    fprintf(fid,'<b><a href="%s/%s/%s.png" rel="gb_image[]">Mutual Discrepancy Graph</a></b><br>',web_pictures,filename,filename);
    fprintf(fid,'<a href="%s/%s/%s.png"><img src="%s/%s/%s.png" class="mutdisc"></a><br>',web_pictures,filename,filename,web_pictures,filename,filename);
end
fprintf(fid,'<div class="share">');
fprintf(fid,'<div class="addthis_toolbox addthis_default_style ">')
fprintf(fid,'<a href="http://www.addthis.com/bookmark.php?v=250&amp;username=xa-4d002299773bf696" class="addthis_button_compact">Share</a>')
fprintf(fid,'</div>')
fprintf(fid,'<script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#username=xa-4d002299773bf696"></script>')
fprintf(fid,'</div><br>');
fprintf(fid,'<a href="%s/%s/%s.zip">Download all candidates (.zip)</a><br><br>',web_pdbdatabase, filename, filename);
fprintf(fid, '</td></tr></table><br>');
fprintf(fid,'</div></body></html>');
fclose(fid);
disp('File processed');

if isfield(Search.Query, 'Email')
    link = sprintf('%s/Results/%s/results.php', webroot, filename);
    message = sprintf('Please visit this webpage to see your FR3D results: %s  This is an automated message. For support, email apetrov@bgsu.edu', link);
    command = sprintf('echo "%s" | tee foo | mail -s "FR3D results %s" %s', message, filename, Search.Query.Email);
    unix(command);
    clear Search.Query.Email;
end


end

function [] = ShowMessage(resultsdir,webroot,message,Search,filename)

    if nargin < 5
        filename = '';
    end

    fid = fopen([resultsdir filesep 'results.php'],'w');
    fprintf(fid, '<html><head><link rel="stylesheet" type="text/css" href="%s/Library.css"><title>FR3D results</title></head><body>',webroot);
    fprintf(fid, '<div class="message">');
    fprintf(fid, '<h2>Thank you for using FR3D</h2><br>');
    fprintf(fid, '<p>%s</p><br><br>',message);
    fprintf(fid, '</div></body></html>');
    fclose(fid);

    if nargin == 4
        if isfield(Search.Query, 'Email')
            link = sprintf('%s/Results/%s/results.php', webroot, filename);
            message = sprintf('Please visit this webpage to see your FR3D results: %s  This is an automated message. For support, email apetrov@bgsu.edu', link);
            command = sprintf('echo "%s" | tee foo | mail -s "FR3D results %s" %s', message, filename, Search.Query.Email);
            unix(command);
        end
    end

end



