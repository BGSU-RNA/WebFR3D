% pDisplayModelScores displays the results of pMakeModelsFromLibrary
% S(i,2k-1) tells the score that model k gave to sequences from model i
% S(i,2k)   tells the score that model k gave to reversed sequences from i
% We would hope that S(i,2i-1) would be the largest score in row i.

[s,t] = size(S);                         % s by 2s matrix

% ---------------------------------------- Read model names

n = 1;

fid = fopen(['models' filesep loopType '_Models.txt']);
if fid > 0,
  L = 1;
  while L > -1,
    L = fgetl(fid);                      % read a line
    if L > -1,
      Names{n} = L;
      switch loopType
      case 'IL'
        Names{n+1} = ['R ' L];
        n = n + 2;
      case 'HL'
        n = n + 1;
      end
    end
  end
else
  fprintf('Could not open file of model names\n');
end

% ------------------------- Recast scores as relative to max across all models

RelSeq = [];
RelModel = [];

counter = 0;
counter2 = 0;
counter3 = 0;

for i = 1:s,
  RelSeq(i,:) = S(i,:) - max(S(i,:));    % subtract the maximum; make it zero
  SLab{i} = Names{2*i-1}(1:9);           % short labels
  Lab{i} = Names{2*i-1};                 % full labels

  if RelSeq(i,2*i-1) == 0,               % own model gives highest score
    counter = counter + 1;               % 
  end
  if RelSeq(i,2*i-1) >= -2,              % own model gives good score
    counter2 = counter2 + 1;
  end
  if RelSeq(i,2*i-1) < -5,
    [z,index] = max(RelSeq(i,:));
    group = floor(index/2);
    rev = [];
    if ~mod(index,2) == 0,
        rev ='Reversed';
    end
    fprintf('Group %d : %d\n',i,S(i,2*i-1));
    fprintf('Group %d max for Group %i %s\n',i,group,rev);
    counter3 = counter3 + 1;
  end

end
fprintf('%d out of %d sequences are given a poor score by their own forward model\n', counter3, s);
fprintf('%d out of %d sequences are given the highest score by their own forward model\n', counter, s);
fprintf('%d out of %d sequences are given a good score by their own forward model\n', counter2, s);

% -----------------------------------------------

ModelNames = Names(1:2:(t-1));

% ----------------------------------------------- Store scores of own sequences

for i = 1:s,
  SelfScore(i,1) = S(i, 2*i-1);
  ScoreGap(i,1)  = RelSeq(i, 2*i-1);
end

save Motif_Self_Scores ModelNames SelfScore ScoreGap

% ----------------------------------------------- 


maxlen = 0;
for i = 1:s,
  maxlen = max(maxlen,length(Lab{i}));
end
for i = 1:maxlen,
  blank(i) = ' ';
end
for i = 1:s,
  FL = blank;
  FL(1:length(Lab{i})) = Lab{i};
  FullLab{i} = FL(7:end);
end

for j = 1:t,
  RelModel(:,j) = S(:,j) - max(S(:,j));  % subtract the maximum; make it zero
end

% ------------------------------------ re-order sequences
D = [];

for i = 1:s,
  for j = 1:s,
    ii = [2*i-1 2*i];                % indices of forward and reversed
    jj = [2*j-1 2*j];
    D(i,j) = min(min([max([0 0],(S(i,ii)-S(i,jj))) max([0 0],(S(j,jj)-S(j,ii)))]));
  end
end

figure(10)
clf

p = 1:s;
q = 1:t;

T = RelSeq(p,q);
T = RelSeq;
T(s+1,t+1) = 0;
pcolor(T);
hold on
axis ij
shading flat
axis([1 2*s+1 1 s+1]);
caxis([-8 0]);
colormap('default')
map = colormap;
map = map(8:56,:);
%map = [1 1 1; map];
map = [map; 1 1 1];

q = [];
for i = 1:s,
  q = [q 2*p(i)-1 2*p(i)];          % how to permute models, keep together
  plot([2*i 2*i+2 2*i+2 2*i 2*i]-1,[i i i+1 i+1 i],'k');
  hold on
end

colormap(map);
colorbar('eastoutside');
set(gca,'YTick',(1:s)+0.5)
set(gca,'YTickLabel',FullLab(p),'FontSize',5,'FontName','FixedWidth')
title('Scores of sequences against models and reversed models, relative to max score for those sequences');
xlabel('Models and reversed models, paired, in the order on the y axis');


figure(11)

p = zOrderbySimilarity(D);

clf
zGraphDistanceMatrix(abs(D(p,p)),FullLab(p),maxlen);
caxis([0 8])
colormap(map);
colorbar('eastoutside');
title('Similarity of models according to how they score each others sequences');

ModelNames = Names(1:2:(t-1));

figure(12)
clf

DD = abs(zDistance(max(-4,RelSeq)));   % how similarly sequences are scored
p = zOrderbySimilarity(DD);

q = [];
for i = 1:s,
  q = [q 2*p(i)-1 2*p(i)];          % how to permute models, keep together
end

T = RelSeq(p,q);
T(s+1,t+1) = 0;
pcolor(T);
hold on
axis ij
shading flat
axis([1 2*s+1 1 s+1]);
caxis([-8 0]);
colormap('default')
map = colormap;
map = map(8:56,:);
%map = [1 1 1; map];
map = [map; 1 1 1];

for i = 1:s,
  plot([2*i 2*i+2 2*i+2 2*i 2*i]-1,[i i i+1 i+1 i],'k');
  hold on
end

colormap(map);
colorbar('eastoutside');
set(gca,'YTick',(1:s)+0.5)
set(gca,'YTickLabel',FullLab(p),'FontSize',5,'FontName','FixedWidth')
title('Scores of sequences against models and reversed models, relative to max score for those sequences');
xlabel('Models and reversed models, paired, in the order on the y axis');

figure(13)
clf

DD(end+1,end+1) = 0;
pcolor(DD(p,p));
hold on
axis ij
shading flat
colorbar('eastoutside');
set(gca,'YTick',(1:s)+0.5)
set(gca,'YTickLabel',FullLab(p),'FontSize',5,'FontName','FixedWidth')
title('Scores of sequences against models and reversed models, relative to max score for those sequences');
xlabel('Models and reversed models, paired, in the order on the y axis');

dt = strrep(datestr(now,31),':','_');

% ----------------------------------- order by how forward models scores seqs

figure(14)
clf

DD = abs(zDistance(max(-4,RelSeq(:,2:2:end)')));
p = zOrderbySimilarity(DD);

q = [];
for i = 1:s,
  q = [q 2*p(i)-1 2*p(i)];          % how to permute models, keep together
end

T = RelSeq(p,q);
T(s+1,t+1) = 0;
pcolor(T);
hold on
axis ij
shading flat
axis([1 2*s+1 1 s+1]);
caxis([-8 0]);
colormap('default')
map = colormap;
map = map(8:56,:);
%map = [1 1 1; map];
map = [map; 1 1 1];

for i = 1:s,
  plot([2*i 2*i+2 2*i+2 2*i 2*i]-1,[i i i+1 i+1 i],'k');
  hold on
end

colormap(map);
colorbar('eastoutside');
set(gca,'YTick',(1:s)+0.5)
set(gca,'YTickLabel',FullLab(p),'FontSize',5,'FontName','FixedWidth')
title('Scores of sequences against models and reversed models, relative to max score for those sequences');
xlabel('Models and reversed models, paired, in the order on the y axis');

figure(10)
set(gcf,'renderer','painters')
set(gca,'fontsize',4)
orient landscape
saveas(gcf,['Sequence scores original order ' dt '_' num2str(counter) '_Correct.pdf'])

figure(12)
set(gcf,'renderer','painters')
set(gca,'fontsize',4)
orient landscape
saveas(gcf,['Sequence scores similarity order ' dt '_' num2str(counter) '_Correct.pdf'])

figure(13)
set(gcf,'renderer','painters')
set(gca,'fontsize',4)
orient landscape
saveas(gcf,['Distance between sequence scores ' dt '_' num2str(counter) '_Correct.pdf'])
