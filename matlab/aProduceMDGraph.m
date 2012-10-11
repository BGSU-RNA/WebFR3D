function [] = aProduceMDGraph (Search, MotifNumber)

pictures = '/Servers/rna.bgsu.edu/webfred/Results/Pictures';

if length(Search.Candidates(:,1)) > 1,
    [L,N] = size(Search.Candidates);
    N = N - 1;
    if ~isfield(Search,'File'),
          File = FullFile;
          Search.Query.Geometric = 0;
          Search.Query.NumNT = N;
          Search.Discrepancy = 1:L;
    else
          File = Search.File;                        % use what was saved w/ Search
    end

    if ~isfield(Search,'Disc'),
          Search.Disc         = sparse(zeros(L,L));
          Search.DiscComputed = sparse(zeros(1,L));
      if Search.Query.Geometric > 0,
            Search.Disc(:,1) = Search.Discrepancy;
            Search.Disc(1,1) = 0;
            Search.DiscComputed(1,1) = 1;
      end
    end

    Search = xMutualDiscrepancy(File,Search,300); % calculate some discrepancies
    if ~exist ([pictures filesep MotifNumber],'dir'),
          mkdir([pictures filesep MotifNumber]);
    end

    myPath = fullfile(pictures, MotifNumber, [MotifNumber '.png']);
    Done   = find(Search.DiscComputed);            % ones already computed

    Lab = cell(1,L);
    for i = 1:L
        Lab{i} = int2str(i);
    end

    D = Search.Disc(Done,Done);                    % mutual distances to consider

    figure(99)
    clf
    p = zOrderbySimilarity(D);
    Lab = Lab(p);
    zGraphDistanceMatrix(D(p,p),Lab,15,0);
    title('Table of discrepancies between candidates','fontsize',12);

    if length(Lab) > 10
        xtitle{1} = 'Candidates in the order of appearance from top to bottom:';
        curr = 2;
        xtitle{curr} = '';
        for i = 1:length(Lab)
            xtitle{curr} = strcat(xtitle{curr},Lab{i},',');
            if length(xtitle{curr}) > 80
                curr = curr+1;
                xtitle{curr} = '';
            end
        end
        xtitle{end} = xtitle{end}(1:end-1);
        xlabel(xtitle,'fontsize',8);
    end

    if length(Lab) > 20
        set(gca,'YTick',[]);
    end

    colormap('default');
    map = colormap;
    map = map((end-8):-1:8,:);
    colormap(map);
    caxis([0 0.8]);
    colorbar('location','eastoutside');

%     keyboard;

    set(gcf,'Renderer','painters');
    try
        saveas(gcf, myPath );
        close(gcf);
    catch
        command = sprintf('print -dpng %s.png',myPath);
        eval(command);
    %     print -dpng Pathway; % for octave
    end

end
