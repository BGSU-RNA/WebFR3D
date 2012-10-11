function [] = aWriteToPDB_neigh(Search, LibName)

get_config;

%------------------------inline xWriteCandidatePDB begins
File = Search.File;

N = Search.Query.NumNT;                        % number of nucleotides in each

if isfield(Search.Query,'LocWeight'),
    LW = Search.Query.LocWeight;
else
    LW = ones(N,1);
end

if isfield(Search.Query,'AngleWeight'),
    AW = Search.Query.AngleWeight;
else
    AW = ones(N,1);
end

[FullFile,FIndex] = zAddNTData(Search.CandidateFilenames);
    for f = 1:length(FullFile),
      if ~isfield(FullFile,'Distance'),
        FullFile(f).Distance = [];
      end
      if isempty(FullFile(f).Distance) && ~isempty(FullFile(f).NumNT),
       if (FullFile(f).NumNT > 0),
        c = cat(1,FullFile(f).NT.Center); % nucleotide centers
        FullFile(f).Distance = zMutualDistance(c,16); % compute distances < 16 Angstroms
       end
      end
    end


if ~isempty(Search.Candidates)

    M = length(Search.Candidates(:,1));            % number of candidates
    f     = Search.Candidates(1,N+1);
    Model = File(f).NT(Search.Candidates(1,1:N));  % first cand, taken as model

    a = 1;                                         % atom number
    if~(exist(config.pdbdatabase,'dir')),
        mkdir(config.pdbdatabase);
    end
    for c = 1:M,                                   % loop through candidates
        f     = Search.Candidates(c,N+1);             % file number, this candidate
        Cand  = File(f).NT(Search.Candidates(c,1:N)); % current candidate
        [R,Sh] = xSuperimposeCandidates(Model,Cand,LW,AW);

        if~(exist([config.pdbdatabase filesep LibName],'dir')),
            mkdir([config.pdbdatabase filesep LibName]);
        end

        ID  = strcat(Search.Query.Name,'_',num2str(c));
        fid = fopen([config.pdbdatabase filesep LibName filesep ID '.pdb'],'W');       % open for writing
        a = 1;                                         % atom number
        VP.Sugar = 1;
        fprintf(fid,'MODEL        1\n');
        for i = 1:N,                                  % loop through nucleotides
            NT = Cand(i);                                % current nucleotide
            a = zWriteNucleotidePDB(fid,NT,a,0,R',Sh);
        end
        fprintf(fid,'ENDMDL\n');

        a=1;
%         FullFile = zAddNTData(File(f).Filename);
        NewIndices = LargerNeighborhood(FullFile(FIndex(f)),Search.Candidates(c,1:N),3);
        try
        Cand = FullFile(FIndex(f)).NT(setdiff(NewIndices,Search.Candidates(c,1:N)));
        catch
            keyboard;
        end
        fprintf(fid,'MODEL        2\n');
        for i = 1:length(Cand),
            try
            NT = Cand(i);
            catch
                keyboard;
            end
            a = zWriteNucleotidePDB(fid,NT,a,0,R',Sh);
        end
        fprintf(fid,'ENDMDL\n');

        fclose(fid);


    end
end

end

function [NewIndices] = LargerNeighborhood(File,Indices,v)

    N = length(Indices);                                 % number of nucleotides

    if ~isfield(File,'Distance'),
        c = cat(1,File.NT(1:File.NumNT).Center); % nucleotide centers
        File.Distance = zMutualDistance(c,16); % compute distances < 16 Angstroms
    end

    if isempty(File.Distance),
        c = cat(1,File.NT(1:File.NumNT).Center); % nucleotide centers
        File.Distance = zMutualDistance(c,16); % compute distances < 16 Angstroms
    end

    NewIndices = Indices;                                % always start here

    if v > 0,                                          % add basepairs
        for n = 1:N,
            e = abs(File.Edge(Indices(n),:));              % interactions with n
            j = find( (e > 0) .* (e < 14) );               % basepairing with n
            NewIndices = [NewIndices j];
        end
        for n = (N+1):length(NewIndices),                % add what these pair with
            e = abs(File.Edge(NewIndices(n),:));           % interactions with n
            j = find( (e > 0) .* (e < 14) );               % basepairing with n
            NewIndices = [NewIndices j];
        end
    end

    if v > 1,                                            % add intervening ones
        for n = 1:N,
            NewIndices = [NewIndices (Indices(n)-1):(Indices(n)+1)];
        end
    end

    if v > 2,
        d = [1 1 8 10 12];
        a = zeros(1,File.NumNT);
        for j=1:length(Indices),
            a = a + (File.Distance(Indices(j),:) < d(v)) .* ...
                (File.Distance(Indices(j),:) > 0);
        end
        NewIndices = [NewIndices find(a)];
    end

    NewIndices = unique(NewIndices);
    NewIndices = sort(NewIndices);
    NewIndices = NewIndices(NewIndices>0);
    NewIndices = NewIndices(NewIndices<File.NumNT);

end