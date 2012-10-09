% pConsensusInteractions(Search) determines the consensus interactions in the candidates in Search

function [Edge,BPh,BR,Search] = pConsensusInteractions(Search)

[L,N] = size(Search.Candidates);        % L = num instances; N = num NT
N = N - 1;                              % number of nucleotides

f = Search.Candidates(:,N+1);           % file numbers of motifs

BPh = zeros(N,N);
BR  = zeros(N,N);

% ----- Calculate coplanar measure for each File in Search

if ~isfield(Search.File(1),'Coplanar'),

disp('Adding coplanar values')

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
          Pair = zAnalyzePair(NT1,NT2);
          Search.File(ff).Coplanar(i(a),i(b)) = Pair.Coplanar;
          Search.File(ff).Coplanar(i(b),i(a)) = Pair.Coplanar;
        end
      end 
    end
  end
end



% ----------------------------------------------- find consensus basepairs

Edge = sparse(N,N);

for a = 1:N,                                    % first NT of possible pair
  for b = 1:N,                                  % second NT of possible pair
    e = [];                                     % record observed edges
    cp= [];
    for c = 1:L,                                % run through candidates
      i = Search.Candidates(c,a);               % index of first nucleotide
      j = Search.Candidates(c,b);               % index of second nucleotide
      e = [e Search.File(f(c)).Edge(i,j)];      % append observed interaction
      cp= [cp Search.File(f(c)).Coplanar(i,j)]; % append coplanar information
    end

    e = fix(e);                                 % round subcategories

    for d = 1:length(e),
      if any(e(d) == [-1 -2 -7 -8 -101 -102 -107 -108]),% don't distinguish sign
        e(d) = -e(d);
      end
    end

    if any((abs(e)>0).*(abs(e)<30)),            % there was some bp or stack
      ee = e(find((abs(e) > 0) .* (abs(e) < 30))); % FR3D basepairs and stacks
      if ~isempty(ee),
        Edge(a,b) = mode(ee);                      % use the most common one
        Edge(b,a) = -Edge(a,b);                   % record twice
      end
    else                                        % only near interactions
      ee = e(find((abs(e) > 100) .* (cp > 0))); % near, coplanar pairs
      if ~isempty(ee),
        Edge(a,b) = mode(ee);
        Edge(b,a) = -Edge(a,b); 
      end
    end
  end
end

% ----------------------------------------------- consensus BPh interactions

for a = 1:N,                                    % first NT of possible BPh
  for b = 1:N,                                  % second NT of possible BPh
    e = [];                                     % record observed edges
    for c = 1:L,                                % run through candidates
      i = Search.Candidates(c,a);               % index of first nucleotide
      j = Search.Candidates(c,b);               % index of second nucleotide
      e = [e Search.File(f(c)).BasePhosphate(i,j)];      % append observed interaction
    end

    e = fix(e);                                 % round subcategories

    if max(abs(e)) > 0 && min(abs(e)) < 30,     % there was some bp interaction
%  e
      BPh(a,b) = mode(e);                    % use the most common one
  % a more sophisticated method for determining the consensus is needed
  % count how many times each one occurs, giving maybe 0.5 for near
    end
  end
end

% ----------------------------------------------- consensus BR interactions

if ~isfield(Search.File(1),'BaseRibose'),
  disp('Adding base-ribose interactions')
  Search.File = zBaseRiboseInteractions(Search.File);
end

for a = 1:N,                                    % first NT of possible BR
  for b = 1:N,                                  % second NT of possible BR
    e = [];                                     % record observed edges
    for c = 1:L,                                % run through candidates
      i = Search.Candidates(c,a);               % index of first nucleotide
      j = Search.Candidates(c,b);               % index of second nucleotide
      e = [e Search.File(f(c)).BaseRibose(i,j)];  % append observed interaction
    end

    e = fix(e);                                 % round subcategories

    if max(abs(e)) > 0 && min(abs(e)) < 30,     % there was some bp interaction
%  e
      BR(a,b) = mode(e);                    % use the most common one
  % a more sophisticated method for determining the consensus is needed
  % count how many times each one occurs, giving maybe 0.5 for near
    end
  end
end

end
