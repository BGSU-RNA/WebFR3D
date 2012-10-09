function [] = aWebFR3D(query)

fr3d = '/Servers/rna.bgsu.edu/WebFR3D/FR3D';
cd(fr3d);
result = '/Servers/rna.bgsu.edu/WebFR3D/Results';
failed = '/Servers/rna.bgsu.edu/WebFR3D/InputScript/Failed';
mydir = '/Servers/rna.bgsu.edu/WebFR3D/InputScript/Running';
addpath([fr3d filesep 'aFR3DSource']);
addpath([fr3d filesep 'FR3DSource']);
addpath([fr3d filesep 'FR3DDevelopment']);
addpath([fr3d filesep 'PDBFiles']);
addpath([fr3d filesep 'PrecomputedData']);

id = query(7:end-2);
destination = [result filesep id];
if ~exist(destination,'dir')
    mkdir(destination);
end
fidi = fopen([mydir filesep query],'r');
Query = [];
if strfind(query,'rnao')

    try
        Query = xReadRNAOQuery([mydir filesep query]);   
    catch
        message = 'Parsing failed. Check your syntax.';
        reportMistake(result,id,message,Query);
        movefile([mydir filesep query], [failed filesep query]);
        quit;
    end
    try
        aWebFR3DSearch;
    catch
        message = 'Problem during FR3D search.';                    
        reportMistake(result,id,message,Query);
        movefile([mydir filesep query], [failed filesep query]);
        quit;        
    end               
    if isfield(Search,'Candidates') && ~isempty(Search.Candidates)
        try 
            r = size(Search.Candidates);            
            if r(1) < 300
                aWriteHTMLForSearch(id);
            else
                message = ['Too many candidates (' int2str(r(1)) ')'];
                reportMistake(result,id,message,Query);
                movefile([mydir filesep query], [result filesep id filesep query]);                     
                quit;                
            end
        catch
            message = 'Problem creating the webpage';                    
            reportMistake(result,id,message,Query);
            movefile([mydir filesep query], [failed filesep query]);                     
            quit;                            
        end                        
    else
        message = 'No candidates found';
        reportMistake(result,id,message,Query);
        movefile([mydir filesep query], [result filesep id filesep query]);                     
        quit;                        
    end               
else        
    while 1
        tline = fgetl(fidi);
        if ~ischar(tline),   break,   end
%                 disp(tline); 
        try 
            eval(tline);
        catch 
            fprintf('Problem with line: %s\n',tline);
            message = 'Critical error. Execution aborted.';
            reportMistake(result,id,message,Query);                    
            try
                movefile([mydir filesep query], [failed filesep query]);                
            catch

            end
            break;
        end
    end
    fclose(fidi); 
end
try
    movefile([mydir filesep query], [result filesep id filesep query]);
catch

end

quit;
end


function reportMistake(result,id,message,Query)

    webroot = 'http://rna.bgsu.edu/WebFR3D';
    disp(message);                
    fid = fopen([result filesep id filesep 'results.php'],'w');      
%     fprintf(fid, '<html><head><title>FR3D
%     results</title></head><body>\n');
    fprintf(fid, '<html><head><link rel="stylesheet" type="text/css" href="%s/Library.css"><title>FR3D results</title></head><body>',webroot);
    fprintf(fid, '<div class="message">\n');
    fprintf(fid, '<h2>Thank you for using FR3D</h2><br>\n');
    fprintf(fid, '<p>%s</p><br><br>\n',message);      
    fprintf(fid, '</div></body></html>');        
    fclose(fid);
    if isfield(Query, 'Email')
        link = sprintf('%s/Results/%s/results.php', webroot, id);
        message = sprintf('Please visit this webpage to see your FR3D results: %s  This is an automated message. For support email apetrov@bgsu.edu', link);
        command = sprintf('echo "%s" | tee foo | mail -s "FR3D results %s" %s', message, id, Query.Email);
        unix(command);
        clear Query.Email;
    end            
    disp('Standby');        
    
end
