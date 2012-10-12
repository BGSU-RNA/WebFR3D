% WebFR3D configuration

% customizable parameters
config.root = '/Servers/rna.bgsu.edu/webfred';
config.webroot = 'http://rna.bgsu.edu/webfred';
config.email = 'rnabgsu@gmail.com';

% result file locations
config.results = fullfile(config.root, 'Results');
config.pdbdatabase = fullfile(config.results, 'PDBDatabase');
config.pictures = fullfile(config.results, 'Pictures');

% matlab paths
config.fr3d = fullfile(config.root, 'FR3D_submodule');
config.webfr3d_mcode = fullfile(config.root, 'matlab');

% urls
config.web_pdbdatabase = strcat(config.webroot, '/', 'Results', '/', 'PDBDatabase');
config.web_pictures = strcat(config.webroot, '/', 'Results', '/', 'Pictures');
config.web_results = strcat(config.webroot, '/', 'Results');
config.css = strcat(config.webroot, '/', 'css');
config.js = strcat(config.webroot, '/', 'js');

% InputScript folders
config.failed = fullfile(config.root, 'InputScript', 'Failed');
config.toolong = fullfile(config.root, 'InputScript', 'TooLong');
config.running = fullfile(config.root, 'InputScript', 'Running');
config.input = fullfile(config.root, 'InputScript', 'Input');