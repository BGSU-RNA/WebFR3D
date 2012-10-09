% zPlotMotifScores makes a log-log plot of 

function [void] = zPlotMotifScores(aligseqs,aligcounts,aligscore,MinAligStructDist,logcounts,logbins)

color = {'k.','g.','r.','m.','c.','b.','o.','y.','b.'};


for d = 0:max(MinAligStructDist),               % largest possible dist to struct

  g = find(MinAligStructDist == d);             % sequences at distance d
  if d == 0,                                % these are 3D structure seqs
    plot(aligcounts(g),aligscore(g),color{d+1},'markersize',14);
  elseif d == 6,                            % color these organge
    plot(aligcounts(g),aligscore(g),'.','color',[255 165 0]/255,'markersize',10);
  else
    plot(aligcounts(g),aligscore(g),color{d+1},'markersize',10);
  end
  hold on
end

hold on
for s = 1:length(aligcounts),
  if strcmp(class(aligseqs),'char'),
    text(aligcounts(s)*1.1,aligscore(s),aligseqs(s,:),'fontsize',max(4,8-2*MinAligStructDist(s)));
  else
    text(aligcounts(s)*1.1,aligscore(s),aligseqs{s},'fontsize',max(4,8-2*MinAligStructDist(s)));
  end
end

% --------------------------------------- plot stacked histogram

zStackedBar(exp(logbins),logcounts,'kgrmcboyboyboyboy','H');

set(gca,'Xscale','log');
set(gca,'Yscale','log');

x = exp((-1+log(max(aligcounts)))/2);
a = min(logbins);
b = max(logbins);
c = a + 0.4*(b-a);
y = exp(c:-(c-a)/10:a);

    text(x,y(1),'Black means the sequence was observed in a 3D structure');
    text(x,y(2),'Green means Hamming distance 1 from a 3D sequence');
    text(x,y(3),'Red means Hamming distance 2 from a 3D sequence');
    text(x,y(4),'Magenta means Hamming distance 3 from a 3D sequence');
    text(x,y(5),'Cyan means Hamming distance 4 from a 3D sequence');
    text(x,y(6),'Blue means Hamming distance 5 from a 3D sequence');
    text(x,y(7),'Orange means Hamming distance 6 from a 3D sequence');
    text(x,y(8),'Yellow means Hamming distance 7 from a 3D sequence');
    text(x,y(9),'Blue, Orange, Yellow repeats after that');

  orient landscape

  axis([0.1 5*max(aligcounts),min(exp(logbins)),2*max(max(aligscore),max(exp(logbins)))]);
