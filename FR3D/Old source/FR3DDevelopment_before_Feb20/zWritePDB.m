% zWritePDB(File) writes the nucleotides in File to a PDB file

function [void] = zWritePDB(File,Filename,Rot,sh)

if nargin < 3,
  Rot = eye(3);
  sh = [0 0 0];
end

fid = fopen(Filename,'w');       % open for writing

a = 1;                                         % atom number

for n = 1:length(File.NT),
  a = zWriteNucleotidePDB(fid,File.NT(n),a,0,Rot,sh);
end

fclose(fid);
