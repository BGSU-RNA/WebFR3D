function [] = aWriteToPDB(Search, LibName)

pdbdatabase = '/Servers/rna.bgsu.edu/webfred/Results/PDBDatabase';

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

if ~isempty(Search.Candidates)

    M = length(Search.Candidates(:,1));            % number of candidates

    f     = Search.Candidates(1,N+1);
    Model = File(f).NT(Search.Candidates(1,1:N));  % first cand, taken as model

    % ------------------ Write candidates to separate locations

    a = 1;                                         % atom number
    if~(exist(pdbdatabase, 'dir')),
        mkdir(pdbdatabase);
    end

    for c = 1:M,                                   % loop through candidates
        f     = Search.Candidates(c,N+1);             % file number, this candidate
        Cand  = File(f).NT(Search.Candidates(c,1:N)); % current candidate
        [R,Sh] = xSuperimposeCandidates(Model,Cand,LW,AW);

        if~(exist([pdbdatabase filesep LibName],'dir')),
            mkdir([pdbdatabase filesep LibName]);
        end

        ID  = strcat(Search.Query.Name,'_',num2str(c));
        fid = fopen([pdbdatabase filesep LibName filesep ID '.pdb'],'W');       % open for writing
        a = 1;                                         % atom number
        VP.Sugar = 1;

        for i = 1:N,                                  % loop through nucleotides
            NT = Cand(i);                                % current nucleotide
            a = zWriteNucleotidePDB(fid,NT,a,0,R',Sh);
        end
        fclose(fid);
    end
end