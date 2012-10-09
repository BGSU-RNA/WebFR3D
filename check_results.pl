#!/usr/bin/perl -w

my $RESULTS = '/Servers/rna.bgsu.edu/WebFR3D/Results';
my $RUN_DIR = '/Servers/rna.bgsu.edu/WebFR3D/InputScript/Running';
#my $FAILED_DIR = '/Servers/rna.bgsu.edu/WebFR3D/InputScript/Failed';
my $LONG_DIR = '/Servers/rna.bgsu.edu/WebFR3D/InputScript/TooLong';

if ( $ARGV[0] =~ /[Query|Qrnao]_(\w+)\.m/ ) {
	$uid = $1;	
} else {
	die;	
}

my $file = $RESULTS . '/' . $uid . '/results.php';
open(IN, '<', $file) or die("Cant open $file\n");
my $content = '';
while (<IN>) { $content .= $_;};
close(IN);


if ($content =~ /until the results become available/) {
open(IN, '>', $file) or die("Cant open $file\n");
	# still placeholder, no work done	
	print IN '<html><head><title>FR3D results</title></head><body>';
	print IN '<div style="width:650px;height:350px;margin:auto;border-style:groove;text-align:center; "';
	print IN '<h2>Thank you for using FR3D</h2><br>';
	print IN '<p>The job was aborted because it took longer than 30 minutes. Please consider installing FR3D locally to perform ';
	print IN '	very intense calculations or revise your query. Try searching in fewer pdb files or impose stricter constraints.';
	print IN '</p><br><br>';
	print IN '</div></body></html>';

	my $command = 'mv ' . $RUN_DIR . '/' . $ARGV[0] . ' ' . $LONG_DIR  . '/' . $ARGV[0];
	system($command);
close(IN);            		
}






__END__