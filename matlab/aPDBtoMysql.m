function [] = aPDBtoMysql()

    temp = dir([pwd filesep 'PDBFiles' filesep '*.pdb']);
    list = cell(1,length(temp));
    for i = 1:length(temp)
        if length(temp(i).name) == 8
            list{i} = temp(i).name(1:end-4);
        end
    end
    list(cellfun(@isempty,list)) = [];

    fid = fopen('pdbdatabase.csv','w');
    for i = 1:length(list)
        File = zAddNTData(list{i});        
        pdb = File.Filename;
        for j = 1:length(File.NT(:))
            this = File.NT(j);
            ch = this.Chain;
            base = this.Base;
            num = this.Number;
            fprintf(fid,'%i,%s,%s,%s,%s\n',j,pdb,ch,base,num);
        end
    end
    
    fclose(fid);

end