% zWebFR3DSearchWithLimits(Query,CandidateLimit,TimeLimit) conducts a FR3D search

function [Search] = zWebFR3DSearchWithLimits(Query,CandidateLimit,TimeLimit)

% The result of running xFR3DSearch is a variable Search with these fields:
%
%    .Query                     % a description of the search parameters
%    .Filenames                 % names of files that were searched
%    .TotalTime                 % how much time the search took
%    .Date                      % date of the search
%    .Time                      % time the search was started
%    .SaveName                  % name for the saved search file
%    .Candidates                % L x N+1 matrix of indices of candidates
                                % L is the number of candidates found
                                % N is the number of search nucleotides
                                % the last column of Candidates is the index
                                % of the file in which the candidate was found
%    .Discrepancy               % geometric discrepancy of each candidate
                                % from the query, for geometric searches


if 10 > 1,

  Verbose = 1;
  config.results = 'temp';

else
  % read in WebFR3D config file
  get_config;
end

if ~exist('Verbose'),
  Verbose = 1;                               % default is to print output
end

if isfield(Query,'SearchFiles'),           % if query specifies files
  Filenames = Query.SearchFiles;
else
  Filenames = {'1s72'};                    % default that should never get used!
end

% ------------------------------------------- Construct details of search ---

if isfield(Query,'Filename'),                % if query motif is from a file
  LoadedFile = zAddNTData(Query.Filename);   % load data for Query, if needed
  Query = xConstructQuery(Query,LoadedFile); % preliminary calculations
else
  LoadedFile.Filename = '';                    % dummy for below
  Query = xConstructQuery(Query);              % preliminary calculations
end

clear Search
Search.SaveName = [datestr(now,31) '-' Query.Name];
                                  % use date and time to identify this search
Search.Candidates = [];
Search.Discrepancy = [];
Search.Query = Query;
Search.Filenames   = Filenames;
Search.Date        = Search.SaveName(1:10);
Search.Time        = Search.SaveName(12:18);
Search.SaveName    = strrep(Search.SaveName,' ','_');
Search.SaveName    = strrep(Search.SaveName,':','_');
Search.SaveName    = strrep(Search.SaveName,'<','_');
Search.SaveName    = strrep(Search.SaveName,'>','_');
Search.SaveName    = strrep(Search.SaveName,'?','_');
Search.SaveName    = strrep(Search.SaveName,'*','_');
Search.SaveName    = strrep(Search.SaveName,'&','_');

if isfield(Query,'NumNT'),                    % if query is specified OK

  % ------------------------------------------- Display query information------

  if Verbose > 0,
    fprintf('Query %s:', Query.Name);             % display query name

    if isfield(Query,'Description'),
      fprintf(' %s\n', Query.Description);
    else
      fprintf('\n');
    end
  end

  % ----------------------------------------- Read PDB lists, if any

  FullList = [];

  for j=1:length(Filenames),
      FullList = [FullList; zReadPDBList(Filenames{j},1)];
  end

  FullList = unique(FullList);
  Filenames = FullList;

  % ------------------------------------------- Loop through files to search

  AllCandidates = [];
  AllDiscrepancies = [];
  f = 1;
  starttime = cputime;

  while f <= length(Filenames) && (cputime - starttime) < TimeLimit && (Query.Geometric == 1 || length(AllDiscrepancies) < CandidateLimit),

    if strcmp(Filenames{f},LoadedFile.Filename),
      File = LoadedFile;
    else
      File = zAddNTData(Filenames{f});
      if Verbose > 1,
        fprintf('Loaded %s\n',File.Filename);
      end
    end

    % ------------------------------------------- Calc more distances if needed

    if isempty(File.Distance),
      dmin = 0;
    else
      dmin = ceil(max(max(File.Distance)));
    end

    if (ceil(Query.DistCutoff) > dmin) && (File.NumNT > 0),
      c = cat(1,File.NT.Center);
      File.Distance = zMutualDistance(c,Query.DistCutoff);
               % sparse matrix of center-center distances, up to Query.DistCutoff
    end

    % ------------------------------------ Find candidates in current file

    Candidates = xFindCandidates(File,Query,Verbose);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(Candidates),                         % some candidate(s) found
      if Query.Geometric > 0,
        [Discrepancy, Candidates] = xRankCandidates(File,Query,Candidates,Verbose);

        if (Query.ExcludeOverlap > 0) && (length(Discrepancy) > 0) ...
          && (Query.NumNT >= 2),

          [C, D] = xReduceOverlap(Candidates,Discrepancy);
                                                         % quick reduction in number

          [Candidates, Discrepancy] = xExcludeOverlap(C,D,min(1000,CandidateLimit));
                                                        % find top 1000 distinct ones

          [Candidates, Discrepancy] = xExcludeRedundantCandidates(File,Candidates,Discrepancy);

          if Verbose > 0,
            fprintf('Removed highly overlapping candidates from %s, kept %d\n', File.Filename, length(Candidates(:,1)));
          end
        end

      elseif Query.NumNT > 2,
        if (Query.ExcludeOverlap > 0)
          [Candidates] = xExcludeRedundantCandidates(File,Candidates);
          if Verbose > 0,
            fprintf('Removed candidates from redundant chains in %s, kept %d\n', File.Filename, length(Candidates(:,1)));
          end
        end

        A = [Candidates sum(Candidates')'];        % compute sum of indices
        N = Query.NumNT;                           % number of nucleotides
        [y,i] = sortrows(A,[N+2 1:N]);             % sort by this sum
        Candidates = Candidates(i,:);              % reorder
        Discrepancy = (1:length(Candidates(:,1)))';% number candidates in symbolic search
      elseif Query.NumNT == 2,
        if (Query.ExcludeOverlap > 0)
          [Candidates] = xExcludeRedundantCandidates(File,Candidates);
          if Verbose > 0,
            fprintf('Removed candidates from redundant chains, kept %d\n', length(Candidates(:,1)));
          end
        end

        N = Query.NumNT;                           % number of nucleotides
        [y,i] = sortrows(Candidates,[1 2]);
        Candidates = Candidates(i,:);              % put all permutations together
        Discrepancy = (1:length(Candidates(:,1)))';% helps identify candidates
      end

      if length(Discrepancy) > 0,
        clear TempSearch
        TempSearch.Candidates = Candidates;
        TempSearch.Query = Query;
        TempSearch = xAddFiletoSearch(File,TempSearch);

        if ~isfield(TempSearch.File(1),'AA');
          TempSearch.File(f).AA = [];
        end

        if isfield(TempSearch.File(1),'Het'),
          rmfield(TempSearch.File(1),'Het');
        end

TempSearch.File(1)

        Search.File(f) = TempSearch.File(1);

        Candidates(:,end) = f;                       % use current file number

        AllCandidates = [AllCandidates; Candidates];
        AllDiscrepancies = [AllDiscrepancies; Discrepancy];
      end

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    f = f + 1;                 % move on to next file

  end

  if (cputime - starttime) > TimeLimit,
    Search.TimeTruncated = 1;
  else
    Search.TimeTruncated = 0;
  end


  if Verbose > 0,
    fprintf('Found %d candidates in the desired discrepancy range\n',length(AllDiscrepancies));
    fprintf('Entire search took %8.4f seconds, or %8.4f minutes\n', (cputime-starttime), (cputime-starttime)/60);
  end

  % -------------------------------------------------- Save results of search

  Search.TotalTime   = cputime - starttime;

  if length(AllDiscrepancies) <= CandidateLimit,
    Search.Candidates  = AllCandidates;
    Search.Discrepancy = AllDiscrepancies;
    Search.CandidateTruncated = 0;
  elseif Query.Geometric > 0,
    [d,i] = sort(AllDiscrepancies);
    Search.Candidates = AllCandidates(i(1:CandidateLimit),:);
    Search.Discrepancy = AllDiscrepancies(i(1:CandidateLimit),:);
    Search.CandidateTruncated = 1;
  else
    Search.Candidates = AllCandidates(1:CandidateLimit,:);
    Search.Discrepancy = AllDiscrepancies(1:CandidateLimit,:);
    Search.CandidateTruncated = 1;
  end

  % ------------------------------------------------ Save results

  if (~exist(config.results,'dir')),
    mkdir(config.results);
    mkdir(fullfile(config.results, Query.Name));
  end

  save( fullfile(config.results, Query.Name, [Query.Name '.mat']), 'Search');

end