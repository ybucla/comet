#! /u/home/y/ybwang/perl

use strict;
use warnings;
use Getopt::Std;
use File::Copy;
use File::Copy;
use File::Basename;
use Thread;

my $usage=
"------
$0 -f rawfile

This is a parser to filter the false discovery hits from comet software.

Options:
-e comet.exe file (default /u/home/y/ybwang/comet/bin/comet.2015020.win64.exe)
-p comet.params file (default /u/home/y/ybwang/comet/bin/comet.params)
-d comet search database file

-f Thermo raw file
-t Threshold number (default 4);

-o Output dir

Example:
$0 -d ./yeast.fasta -f 'dir/*.tsv'
$0 -d ./yeast.fasta -f 1.tsv,2.tsv,3.tsv
";

# initial parameters
my %options=();

getopts("e:p:d:f:t:o:",\%options);

my ($exe, $params, $database, $rawfiles, $batchnum, $outdir) = ($options{'e'},$options{'p'},$options{'d'}, $options{'f'}, $options{'t'}, $options{'o'});

die $usage if !defined($database);

die $usage if !defined($rawfiles);

die $usage if !defined($outdir);

$exe = '/u/home/y/ybwang/comet/bin/comet.2015025.win64.exe' if !defined($exe);

$params = '/u/home/y/ybwang/comet/bin/comet.params' if !defined($params);

$batchnum = 4 if !defined($batchnum);

mkdir $outdir if -! $outdir;

# get raw files input 
my @rawlist = $rawfiles =~ /,/ ? {split/,/,$rawfiles}:(glob "$rawfiles");

my @jobid :shared = ();

# split files to $batchnum to qsub
my @arr = ();
foreach(0..$batchnum){
	$arr[$_] = '';
}
my $n = 0;
foreach(@rawlist){	
	$n = 0 if $n >= $batchnum;
	$arr[$n] = $_.';'.$arr[$n];
	$n++;
}
# qsub each search
my @threads;

my $tempcount = 0;

my $randfile = 100000 + int rand( 99999-10000+1 );

foreach(0..$batchnum-1){

	next if $arr[$_] eq '';	

	$threads[$tempcount]=Thread->new(\&run,$arr[$_],$_.''.$randfile, $exe, $params, $database, $outdir);

	$tempcount++;
}

foreach my $thread (@threads) {

	my $r = $thread->join();
}

# monitor job status
print join "\n", @jobid,"\n";

my $finish_tag = 'false';

while($finish_tag eq 'false'){

	my $finish_num = 0;

	my @state = `myjob`;

	foreach my $line(@state){

		foreach my $id(@jobid){
		
			if($line =~ /^$id/){

				$finish_num++;
				
				my $time = localtime;

				print "Job '$id' is still running!\t",$time,"\n";
			}
		}	
	}

	$finish_tag = 'true' if $finish_num == 0;	

	sleep(60);
}
# end comet search



# #----------------------------  Subroutine  ------------------------------------#
sub run {

	my $str = shift;

	my $index = shift;

	my $exe = shift;

	my $params = shift;

	my $database = shift;

	my $outdir = shift;

	$str =~ s/;$//g;	

	my $cmd = "/u/home/y/ybwang/comet/bin/search.pl -e $exe -p $params -d $database -o $outdir -f '$str'";

	print $cmd,"\n";
	
	my @output = `qsub -cwd -V -N ybwang$index -l h_data=15G,,h_rt=10:00:00 -M eplau -m bea $cmd`;
	
	my $id = '';

	if($output[0] =~ /Your job (\d+) /){
		
		$id = $1;
	}

	{
		lock(@jobid);
	
		push @jobid, $id;
	}
}
