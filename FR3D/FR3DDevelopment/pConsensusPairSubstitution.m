% pConsensusPairSubstitution(a,b,f,File,F,L,Search) looks at the letter pairs corresponding to nucleotides a and b of the query motif in Search, 

function [Score] = pConsensusPairSubstitution(a,b,f,File,F,L,Search,Param)

method = 4;             % method for assigning pair subst probs

if length(Param) > 1,
  method  = Param(2);
end

N = length(Search.Candidates(1,:)) - 1;

Verbose = Param(1);

Verbose = 1;

load PairExemplars

Score = zeros(4,4);              % ready to sum IsoScores for this pair 

cl = fix(F.Edge(a,b));

if any(cl == [-1 -2 -7 -8 -101 -102 -107 -108]),
  cl = -cl;
end

for c = 1:L,                                    % loop through candidates
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
end

if sum(e == cl) / L >= 0.5 && abs(cl)>0 && abs(cl) < 30 ,   
                                              % more than half in the categ
  e = ones(size(e)) * cl;                     % use this one every time
  fprintf('pConsensusPairSubstitution: Consensus is %4s\n', zEdgeText(cl));
else
  fprintf('pConsensusPairSubstitution: No consensus; near pairs will be used\n');  
end

for c = 1:L,                            % loop through candidates

  i   = Search.Candidates(c,a);         % index 1 of pair in candidate
  j   = Search.Candidates(c,b);         % index 2 of pair in candidate
  NT1 = File(f(c)).NT(i);               % retrieve the first nucleotide
  NT2 = File(f(c)).NT(j);               % retrieve the second nucleotide

  if Verbose > 0,
    fprintf('pConsensusPairSubstitution: File %4s has %s%4s and %s%4s making %4s\n', File(f(c)).Filename, NT1.Base, NT1.Number, NT2.Base, NT2.Number, zEdgeText(File(f(c)).Edge(i,j)));
  end



    newScore = pIsoScore(e(c),NT1.Base,NT2.Base,method,ExemplarIDI,ExemplarFreq);
                                             % use consensus edge
    Score = Score + newScore;

%newScore(1:7)
end

Score = Score / L;                          % average *** need better idea!

%Score
