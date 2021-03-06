#!/usr/bin/perl

use strict;
use warnings;

use threads;
use threads::shared;
use Thread::Queue;
use FindBin qw($RealBin);

### Global Variables ###

# Maximum working threads
my $MAX_THREADS = 1;

# Flag to inform all threads that application is terminating
my $TERM :shared = 0;

# Threads add their ID to this queue when they are ready for work
# Also, when app terminates a -1 is added to this queue
my $IDLE_QUEUE = Thread::Queue->new();

# set WebFR3D location
use Cwd 'abs_path';
my $WEBFR3D = abs_path($0);
# delete script name from the path
$WEBFR3D =~ s/\/\w+\.pl$//;

# CPU time out for each query in seconds
my $TIMEOUT = 1800;
#my $TIMEOUT = 1;

my %config = do $RealBin . '/webfr3d_queue_config.pl';
my $WEBFR3D_matlab = $WEBFR3D . '/matlab';
my $RESULTS        = $WEBFR3D . '/Results';
my $INPUT_DIR      = $WEBFR3D . '/InputScript/Input';
my $RUN_DIR        = $WEBFR3D . '/InputScript/Running';
# jvm is required for urlread and other matlab functions
my $MATLAB         = $config{matlab};
# my $PYTHON         = $config{python};

### Signal Handling ###

# Gracefully terminate application on ^C or command line 'kill'
$SIG{'INT'} = $SIG{'TERM'} =
    sub {
        print(">>> Terminating <<<\n");
        $TERM = 1;
        # Add -1 to head of idle queue to signal termination
        $IDLE_QUEUE->insert(0, -1);
    };


### Main Processing Section ###
MAIN:
{
    ### INITIALIZE ###

    # Thread work queues referenced by thread ID
    my %work_queues;

    # Create the thread pool
    for (1..$MAX_THREADS) {
        # Create a work queue for a thread
        my $work_q = Thread::Queue->new();

        # Create the thread, and give it the work queue
        my $thr = threads->create('worker', $work_q);

        # Remember the thread's work queue
        $work_queues{$thr->tid()} = $work_q;
    }


    ### DO WORK ###

    # open input directory
#    opendir(IND, $INPUT_DIR) || die("Cannot open directory $INPUT_DIR");

    # Manage the thread pool until signalled to terminate
    while (! $TERM) {

       # get Matlab queries
       my @queries = <$INPUT_DIR/*.m>;

       if ( scalar(@queries) > 0 ) {
            # Wait for an available thread
            my $tid = $IDLE_QUEUE->dequeue();

            # Check for termination condition
            last if ($tid < 0);

            # Give the thread some work to do
            # my $work = 5 + int(rand(10));
            my $job = pop(@queries);
            my @parts = split('/',$job);
            $job = $parts[-1];
            my $command = 'mv ' . $INPUT_DIR . '/' . $job . ' ' . $RUN_DIR  . '/' . $job;
            system($command);
            print($command . "\n");

            $command = $MATLAB . '"addpath(' . "'" . $WEBFR3D_matlab . "')" . ';aWebFR3D(' . "'" . $job . "')" . '"';
            my $work = "ulimit -t $TIMEOUT;$command;perl $WEBFR3D" . '/' . "check_results.pl $job";
            print($work . "\n");
            $work_queues{$tid}->enqueue($work);

        }

       # get Python queries
       @queries = <$INPUT_DIR/*.json>;

       if ( scalar(@queries) > 0 ) {
            # Wait for an available thread
            my $tid = $IDLE_QUEUE->dequeue();

            # Check for termination condition
            last if ($tid < 0);

            # Give the thread some work to do
            # my $work = 5 + int(rand(10));
            my $job = pop(@queries);
            my @parts = split('/',$job);
            $job = $parts[-1];
            my $command = 'rm ' . $INPUT_DIR . '/' . $job;
            system($command);
            print($command . "\n");

            my $pythonwork = 'scl enable python27 "export PYTHONPATH=/usr/local/pipeline/fr3d-python; /opt/rh/python27/root/usr/bin/python /var/www/web-fr3d/python/FR3D.py ' . $job .'"';
            print($pythonwork . "\n");
            $work_queues{$tid}->enqueue($pythonwork);
        }

        sleep(2);
    }


    ### CLEANING UP ###

    # Signal all threads that there is no more work
#    $work_queues{$_}->enqueue(-1) foreach keys(%work_queues);
    $work_queues{$_}->enqueue('') foreach keys(%work_queues);

    # Wait for all the threads to finish
    $_->join() foreach threads->list();

#    closedir(IND);
}

print("Done\n");
exit(0);


### Thread Entry Point Subroutines ###

# A worker thread
sub worker
{
    my ($work_q) = @_;

    # This thread's ID
    my $tid = threads->tid();

    # Work loop
     while (! $TERM) {
        # Indicate that we are are ready to do work
        printf("Idle     -> %2d\n", $tid);
        $IDLE_QUEUE->enqueue($tid);

        # Wait for work from the queue
        my $work = $work_q->dequeue();

        # If no more work, exit
        last if ($work eq '');

        # Do some work while monitoring $TERM
        printf("            %2d <- Working\n", $tid);
        while (! $TERM) {
            system($work);
            last;
        }

        # Loop back to idle state if not told to terminate
    }

    # All done
    printf("Finished -> %2d\n", $tid);
}


__END__
