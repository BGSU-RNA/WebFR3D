% pMakeModelsFromLibrary reads the motif library and makes SCFG/MRF models for each motif

disp('Make sure the Matlab current folder is My Dropbox\BGSURNA\Motifs');

loopType = 'HL';                          % hairpins only
loopType = 'IL';                          % internal loops only

Param = [0 4];                            % Verbose, pair substitution method

Param = [1 4 0 1 10 1];                   % Verbose, etc.  6th is "use near"

Prior = [.5 .5 .5 .5 0];              % Prior distribution for insertion bases 

% ----------------------------------------- Set variables

Verbose = Param(1);
Focus = loopType(1);
Types = {'HL','IL','JL'};                 % types of models we have

% ----------------------------------------- Read file names from the library

Filenames = dir(['MotifLibrary' filesep]);

keep = [];                               % of all models, which to keep

switch Focus,

case 'H',
  typ = 1;
  for m = 1:length(Filenames),
    if (length(Filenames(m).name) > 2),
      if (Filenames(m).name(1:2) == 'HP'),
        keep(m) = 1;
        Filenames(m).name = strrep(Filenames(m).name,'.mat','');
      end
    end 
  end

case 'I',
  typ = 2;
  for m = 1:length(Filenames),
      if (length(Filenames(m).name) > 2),
        if (Filenames(m).name(1:2) == 'IL'), 
            keep(m) = 1;
            Filenames(m).name = strrep(Filenames(m).name,'.mat','');
        end
    end 
  end

case 'J',
  typ = 3;
  for m = 1:length(Filenames),
    if strcmp(Filenames(m).name(1:3),'LIB') && (Filenames(m).name(9) == '_') && (Filenames(m).name(10) == 'J'), 
      keep(m) = 1;
      Filenames(m).name = strrep(Filenames(m).name,'.mat','');
    end 
  end

end

Filenames = Filenames(find(keep));

% ----------------------------------------- 

% ----------------------------------------- Load each search, make a model

CL = zClassLimits;                              % read ClassLimits matrix

if exist('PairExemplars.mat','file') > 0,
  load('PairExemplars','Exemplar');
else
  Exemplar = [];
end

for m = 1:length(Filenames),
  MN = Filenames(m).name;
  FN = ['MotifLibrary' filesep MN '.mat'];
  load(FN,'Search','-mat')                             % Load search data


%   if length(MN) < 9 && strcmp(MN(1:6),'Group_'),      % needs leading 0's
%     fprintf('Renaming %s as ', MN);
%     while length(MN) < 9,
%       MN = [MN(1:6) '0' MN(7:end)];                   % pad with zeros
%     end
%     fprintf('%s\n', MN);
%     FN = ['MotifLibrary' filesep MN '.mat'];
%     Filenames(m).name = MN;
%     save(FN,'Search','-mat');
%   end

  fprintf('\nCurrent model is : %s\n', MN);

  Search.origmatfilename = [MN '.mat'];

  % ----- Calculate coplanar measure for each File in Search

  if ~isfield(Search.File(1),'Coplanar'),
    [L,N] = size(Search.Candidates);        % L = num instances; N = num NT
    N = N - 1;                              % number of nucleotides
    clear NewFile
    for ff = 1:length(Search.File),
      F = Search.File(ff);
      if ~isempty(F.NT),
        F.Coplanar = sparse(F.NumNT,F.NumNT);
        NewFile(ff) = F;
      end
    end
    Search.File = NewFile;

    for c = 1:length(Search.Candidates(:,1)),
      ff = Search.Candidates(c,N+1);
      i = Search.Candidates(c,1:N);

      for a = 1:length(i),
        for b = (a+1):length(i),
          if Search.File(ff).Edge(i(a),i(b)) ~= 0,
            NT1 = Search.File(ff).NT(i(a));
            NT2 = Search.File(ff).NT(i(b));
            Pair = zAnalyzePair(NT1,NT2,CL,Exemplar);
            Search.File(ff).Coplanar(i(a),i(b)) = Pair.Coplanar;
            Search.File(ff).Coplanar(i(b),i(a)) = Pair.Coplanar;
          end
        end 
      end
    end
    save(FN,'Search','-mat');
  end

  if Verbose > 0,
    fprintf('pMakeModelsFromLibrary:  Making a JAR3D SCFG/MRF model for %s\n', MN);
  end

  % --------------------------------------- Make model and write it

  [Node,Truncate,Signature] = pMakeMotifModelFromSSF(Search,Param,Prior);

  Search.Signature = Signature;

  save(FN,'Search','-mat');

  MNSig = [MN '_' Signature];
  FNSig = ['MotifLibrary' filesep MNSig '.mat'];

  Search.matfilename = [MNSig '.mat'];

  Filenames(m).namesig = MNSig;

  if ~strcmp(MN(4:5),'99'),                 % don't do this for helices!
    for n = 1:length(Node),
      if fix(abs(Node(n).Edge)) == 1,       % cWW basepair
%        Node(n).SubsProb = ones(4,4)/16;    % make cWW pairs noninformative
%        Node(n).SubsProb = [0 0 0 1; 0 0 1 0; 0 1 0 1; 1 0 1 0]/6;
                                            % make cWW pairs noninformative
      end
    end
  end

  Search.Truncate = Truncate;

  % --------------------------------------- Write sequences in FASTA format
  Text = xFASTACandidates(Search.File,Search,0,MN);

  fprintf('pMakeModelsFromLibrary:  First sequence is %s\n',Text{2});

  fid = fopen(['Sequences' filesep MNSig '.fasta'],'w');
  for t = 1:length(Text),
    fprintf(fid,'%s\n',Text{t});
  end
  fclose(fid);

  Search.ownsequencefasta = [MNSig '.fasta'];

%  if strcmp(MN(1:8),'LIB00012'),
%    Node(3).SubsProb = [1 1 1 1; 1 1 10 1; 1 1 1 1; 1 1 1 1]/25;
%  end
%   if strcmp(MN(10:11),'HL'),
%     pWriteJavaNodeFile(Search.Query,Node,4,[MN '.txt']);
%   elseif strcmp(MN(10:11),'IL'),
%     pWriteJavaNodeFile(Search.Query,Node,5,[MN '.txt']);
%   elseif strcmp(MN(10:11),'JL'),
%     pWriteJavaNodeFile(Search.Query,Node,5,[MN '.txt']);
%   end

  pWriteJavaNodeFile(Search.Query,Node,5,[MNSig '.txt']);

  Search.modelfilename = [MNSig '.txt'];
  save(FN,'Search','-mat');

end

% ----------------------------------------- Write names of models for JAR3D

fid = fopen(['Models' filesep Types{typ} '_Models.txt'],'w');
for m=1:length(Filenames),
  %if strcmp(Types{typ},Filenames(m).name(10:11)),
    fprintf(fid,'%s\n',[Filenames(m).name '.txt']);
  %end
end
fclose(fid);

% ----------------------------------------- Write extended names instead

fid = fopen(['Models' filesep Types{typ} '_Models.txt'],'w');
for m=1:length(Filenames),
  %if strcmp(Types{typ},Filenames(m).name(10:11)),
    fprintf(fid,'%s\n',[Filenames(m).namesig '.txt']);
  %end
end
fclose(fid);

% ----------------------------------------- Run JAR3D on these models

%clear java; JAR3D_path;  loopType = 'IL'; clc; S = JAR3DMatlab.MotifTest(pwd,loopType);

%clc; JAR3D_path;  loopType = 'IL'; S =
%JAR3DMatlab.MotifTest(pwd,loopType);

JAR3D_path;  loopType = 'IL'; S = JAR3DMatlab.MotifTest(pwd,loopType);

loopType = 'IL';

[s,t] = size(S);
switch loopType,
case 'IL'
  S = S(:,1:(2*s));
case 'HL'
  S = S(:,1:s);
end

% ----------------------------------------- Display results graphically

pDisplayModelScores