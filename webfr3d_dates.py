import os, pdb, datetime

folder = '/Servers/rna.bgsu.edu/WebFR3D/Results'
files = os.listdir(folder)

def modification_date(filename):
    t = os.path.getmtime(filename)
    return datetime.datetime.fromtimestamp(t)

for i,f in enumerate(files):
    d = modification_date(os.path.join(folder,f))
    print d.strftime("%m/%d/%y"), ',' , i