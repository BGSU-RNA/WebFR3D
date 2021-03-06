function [T] = aListCandidates(Search,NumToOutput,id)


File        = Search.File;
Query       = Search.Query;
Candidates  = Search.Candidates;
s           = length(Candidates(:,1));
N           = Query.NumNT;

if s == 0
    fprintf('There are no candidates to list\n');
    return;
end

if N == 2
    CP = zeros(1,s);
end

if nargin < 2
    NumToOutput = Inf;                    % limit on number printed to screen
end

% -------------------------------------- print header line
t = 1;
Text{1} = '<table id="maintable"><tr>';


if isfield(Search,'AvgDisc'),
    Text{t} = [Text{t} sprintf('<th>Filename</th><th>Avg</th><th>Discrep</th>')];
elseif Query.Geometric > 0,
    Text{t} = [Text{t} sprintf('<th>Result id</th><th>Filename</th><th>Discrepancy</th>')];
else
%     Text{t} = [Text{t} sprintf('<td>Result id</td><td>Filename</td><td>Number</td><td>Nucl<td>')];
    Text{t} = [Text{t} sprintf('<th>Result id</th><th>Filename</th>')];
end

for i=1:N,
    Text{t} = [Text{t} sprintf('<th>%d</th>', i)];
end

Text{t} = [Text{t} '<th>Chains</th>'];

% indices for base pairs
for i=1:N,
    for j=(i+1):N,
        Text{t} = [Text{t} sprintf('<th>%s</th>', [num2str(i) '-' num2str(j)])];
    end
end
% indices for base phosphates
for i=1:N,
    for j=1:N,
        if i~=j
            Text{t} = [Text{t} sprintf('<th>%s</th>', [num2str(i) '-' num2str(j)])];
        end
    end
end

if N == 2,
    Text{t} = [Text{t} sprintf('<th>Pair data</th><th></th><th></th><th></th>')];
end

Text{t} = [Text{t} '</tr>'];

for i=1:min(s,NumToOutput),

    Text{i+t} = '<tr>';

    f = double(Candidates(i,N+1));

    Text{i+t} = [Text{i+t} sprintf('<td>%s %i</td>', id,i)];

%     Infofile = zGetPDBInfo(File(f));
%     Text{i+t} = [Text{i+t} sprintf('<td><a href = "http://www.pdb.org/pdb/explore/explore.do?structureId=%s" target="_blank" Title = "Resolution %6.2fA&#10;%s">%s</a></td>', ...
%         File(f).Filename, Infofile.Info.Resolution, Infofile.Info.Descriptor, File(f).Filename)];
    Text{i+t} = [Text{i+t} sprintf('<td><a href="javascript:LookUpPDBInfo(''%s'');" class="pdblink">%s</a></td>',File(f).Filename,File(f).Filename)];


    Indices = Candidates(i,1:N);                 % indices of nucleotides

    if isfield(Search,'DisttoCenter'),
        Text{i+t} = [Text{i+t} sprintf('<td>%12.4f</td>',Search.DisttoCenter(i))];
    elseif Query.Geometric > 0,
        Text{i+t} = [Text{i+t} sprintf('<td>%12.4f</td>',Search.Discrepancy(i))];
    else
%         Text{i+t} = [Text{i+t} sprintf('<td>%d</td>',Search.Discrepancy(i))];      % original candidate number
    end

    for j=1:N,
        Text{i+t} = [Text{i+t} sprintf('<td>%s&nbsp;',File(f).NT(Indices(j)).Base)];
        Text{i+t} = [Text{i+t} sprintf('%s</td>',File(f).NT(Indices(j)).Number)];
    end


    Text{i+t} = [Text{i+t} '<td>'];
    for j=1:N,
        Text{i+t} = [Text{i+t} sprintf('%s',File(f).NT(Indices(j)).Chain)];
    end
    Text{i+t} = [Text{i+t} '</td>'];

    for k=1:length(Indices),
        for j=(k+1):length(Indices),
            C1 = File(f).NT(Indices(k)).Code;
            C2 = File(f).NT(Indices(j)).Code;
            Text{i+t} = [Text{i+t} sprintf('<td>%s</td>', zEdgeText(File(f).Edge(Indices(k),Indices(j)),0,C1,C2))];
        end
    end

    %     Text{i+t} = [Text{i+t} sprintf(' ')];
    %
    %     for k=1:length(Indices),
    %       Text{i+t} = [Text{i+t} sprintf('%c', Config{File(f).NT(Indices(k)).Syn+1})];
    %     end
    %
    %     for k=1:length(Indices),
    %       for j=(k+1):length(Indices),
    %         Text{i+t} = [Text{i+t} sprintf('%6d', abs(double(Indices(k))-double(Indices(j))))];
    %       end
    %     end
    %
    for k=1:length(Indices),
        for j=1:length(Indices),
            if j ~= k,
                Text{i+t} = [Text{i+t} sprintf('<td>%5s</td>', zBasePhosphateText(File(f).BasePhosphate(Indices(k),Indices(j))))];
            end
        end
    end
    %     end

    if N == 2,                        % special treatment for basepairs

        CP(i) = norm(File(f).NT(Candidates(i,1)).Sugar(1,:) - ...
            File(f).NT(Candidates(i,2)).Sugar(1,:));
        Text{i+t} = [Text{i+t} sprintf('<td>C1*-C1*: %8.4f</td>', CP(i))];
        Edge= full(File(f).Edge(Candidates(i,1),Candidates(i,2)));
        Text{i+t} = [Text{i+t} sprintf('<td>%7.1f</td>', Edge)];
        %    BP  = full(File(f).BasePhosphate(Candidates(i,1),Candidates(i,2)));
        %    Text{i+t} = [Text{i+t} sprintf(' %4s ', zBasePhosphateText(BP))];
        SA = {'A', 'S'};
        Text{i+t} = [Text{i+t} sprintf('<td>%c</td>', SA{1+File(f).NT(Candidates(i,1)).Syn})];
        Text{i+t} = [Text{i+t} sprintf('<td>%c</td>', SA{1+File(f).NT(Candidates(i,2)).Syn})];
    end
    Text{i+t} = [Text{i+t} '</tr>'];
end
Text{i+t} = [Text{i+t} '</table>'];

output = {};
for i = 1:length(Text)
    s = regexp(Text{i},'</td>','split');
    if i == 1
        s = regexp(Text{i},'</th>','split');
    end
    output = [output; s];
end
delete = [];
for i = 1:length(output(1,:))
    include = 0;
    for j = 2:length(output(:,i))
        if ~strcmp(output(j,i),'<td>---- ') && ~strcmp(output(j,i),'<td>    -') && ~strcmp(output(j,i),'<td>     ')
            include = 1;
        end
    end
    if include == 0
        delete(end+1) = i; %#ok<AGROW>
    end
end
output(:,delete) = [];

T = cell(1,length(output(:,1)));
for i = 1:length(output(:,1))
    for j = 1:length(output(1,:))
        if i == 1
            if j~=length(output(1,:))
                T{i} = [T{i} output{i,j} '</th>'];
            else
                T{i} = [T{i} output{i,j}];
            end
        elseif j ~= length(output(1,:))
            T{i} = [T{i} output{i,j} '</td>'];
        else
            T{i} = [T{i} output{i,j}];
        end
    end
end





