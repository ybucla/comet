#! /u/home/y/ybwang/perl

use strict;
use warnings;
use Getopt::Std;
use File::Copy;
use File::Basename;

my $usage=
"------
$0 -f rawfile

This is a parser to filter the false discovery hits from comet software.

Options:
-e comet.exe file (default /u/home/y/ybwang/comet/bin/comet.2015020.win64.exe)
-p comet.params file (default /u/home/y/ybwang/comet/bin/comet.params)
-d comet search database file

-f Thermo raw file
-o Output dir
";

# initial paramaters
my %options=();

getopts("e:p:d:f:o:",\%options);

my ($exe, $params, $database, $rawfiles, $outdir) = ($options{'e'}, $options{'p'}, $options{'d'}, $options{'f'},$options{'o'});

die $usage if !defined($rawfiles);

die "$rawfiles not found!" if !defined($rawfiles);

$exe = '/u/home/y/ybwang/comet/bin/comet.2015020.win64.exe' if !defined($exe);

$params = '/u/home/y/ybwang/comet/bin/comet.params' if !defined($params);

$outdir = 'out' if !defined($outdir);

mkdir $outdir if !-e $outdir;

# ----- print paramaters ----- #
print '# The comet searh program is starting',"\n";

print "@ comet_exec = $exe\n";
print "@ comet_para = $params\n";
print "@ comet_data = $database\n";

print "@ output_dir = $outdir\n";
print "@ raw_files = $rawfiles\n";

print "------------------------------------------------------------\n";

# get raw fils 
my @rawfilelist = $rawfiles =~ /;/ ? (split/;/,$rawfiles):(glob "$rawfiles");

foreach(@rawfilelist){

	(my $basename = basename($_)) =~ s/\.\w*$//g;;

	my $outfile = $outdir.'/'.$basename;

	# do comet search
	my $cmd ="WINEDEBUG=fixme-all,err-all /u/home/y/ybwang/comet/wine $exe -P$params -D$database -N$outfile $_";
	
	print $cmd,"\n";
	
	system("$cmd");
		
#	my $finish_tag = 'FALSE';	

#	while($finish_tag eq 'FALSE'){

#		my @stdout = `$cmd`;

#		$finish_tag = 'TRUE' if('Search end' ~~ @stdout);
		
#		print 'Search Error happen, Seach again!\n';		

#		sleep(10);
#	}	
}

