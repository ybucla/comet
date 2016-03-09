#! /u/home/y/ybwang/perl
use strict;
use warnings;
use Getopt::Std;
use File::Basename;

my $usage=
"------
$0 -f percolatorfile

This is a parser to filter the false discovery hits from comet software.

Options:
-f Comet output percolator .tsv file

Example:
run.pl -f 'dir/*.tsv'
run.pl -f 1.tsv,2.tsv,3.tsv
";

my %options=();

getopts("f:r:",\%options);

my ($tsvfile, $FDR) = ($options{'f'}, $options{'r'});

die $usage if !defined($tsvfile);

$FDR = 0.01 if !defined($FDR);

my @tsvfilelist = $tsvfile =~ /,/ ? {split/,/,$tsvfile}:(glob "$tsvfile");


# combine all comet tsv files together and perform percolator filter
my $randfile = 100000 + int rand( 99999-10000+1 );

my $dir = dirname($tsvfilelist[0]).'/';


# get head
my $headtmp = $dir.$randfile.'.head';

`head -n 1 $tsvfilelist[0] > $headtmp`;


# get content
my $contenttmp = $dir.$randfile.'.content';

my $tsvlist = join ' ', @tsvfilelist;

 `cat $tsvlist | grep -v -e '^id' > $contenttmp`;


# get tab file
my $percolatorfile = $dir.$randfile.'.tab';

`cat $headtmp $contenttmp > $percolatorfile`;

unlink("$headtmp");
unlink("$contenttmp");


# perform percolator analysis
percolator("$percolatorfile");


#----------------------------  Subroutine  ------------------------------------#
sub percolator {

        my $file = shift;

	print $file,"\n";	

	my ($highin, $lowin) = ($file.'.0.01', $file.'.0.05');

        my $cmd_high = "/u/home/y/ybwang/comet/bin/percolator.pl -f $file -r 0.01";

        my $cmd_low = "/u/home/y/ybwang/comet/bin/percolator.pl -f $file -r 0.05";
	
	print "Parse Percolator analysis with FDR 0.01\nCommand:\t$cmd_high\n";
        `$cmd_high`;

        print "Parse Percolator analysis with FDR 0.05\nCommand:\t$cmd_low\n";
        `$cmd_low`;
}


