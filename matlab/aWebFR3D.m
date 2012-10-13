function [] = aWebFR3D(query)

% read in configuration file
get_config;
cd(config.fr3d);
addpath(config.webfr3d_mcode);
addpath([config.fr3d filesep 'FR3DSource']);
addpath([config.fr3d filesep 'PDBFiles']);
addpath([config.fr3d filesep 'PrecomputedData']);

id = query(7:end-2);
destination = [config.results filesep id];
if ~exist(destination,'dir')
    mkdir(destination);
end
fidi = fopen([config.running filesep query],'r');
Query = [];

while 1
    tline = fgetl(fidi);
    if ~ischar(tline),   break,   end

    try
        eval(tline);
    catch
        fprintf('Problem with line: %s\n',tline);
        message = 'Critical error. Execution aborted.';
        reportMistake(config.running,id,message,Query);
        try
            movefile([config.running filesep query], [config.failed filesep query]);
        catch

        end
        break;
    end
end
fclose(fidi);

try
    movefile([config.running filesep query], [config.results filesep id filesep query]);
catch

end

quit;
end


function reportMistake(result,id,message,Query)

    get_config;
    disp(message);
    fid = fopen([config.results filesep id filesep 'results.php'],'w');
    fprintf(fid, '<html><head><link rel="stylesheet" type="text/css" href="%s/Library.css"><title>FR3D results</title></head><body>',config.css);
    fprintf(fid, '<div class="message">\n');
    fprintf(fid, '<h2>Thank you for using FR3D</h2><br>\n');
    fprintf(fid, '<p>%s</p><br><br>\n',message);
    fprintf(fid, '</div></body></html>');
    fclose(fid);
    if isfield(Query, 'Email')
        link = sprintf('%s/%s/results.php', config.web_results, id);
        message = sprintf('Please visit this webpage to see your FR3D results: %s  This is an automated message. For support email %s', link, config.email);
        command = sprintf('echo "%s" | tee email.txt | mail -s "FR3D results %s" %s; rm email.txt;', message, id, Query.Email);
        unix(command);
        clear Query.Email;
    end
    disp('Standby');

end
