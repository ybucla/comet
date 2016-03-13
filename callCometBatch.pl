#! /u/home/y/ybwang/perl

use strict;
use warnings;
use 5.010;

my $rawindex = shift;
my $db = '~/scratch/HumanSpecificExon/data/blastDb/uniprot_1ident_58896.fasta';
my $rawdir = '~/scratch/Mathias_Wilhelm/proteom/';
my $outdir = 'cometout_20160313';

callCometSearch($rawindex, $db, $rawdir, $outdir);

sub callCometSearch {
        my ($rawindex, $db, $rawdir, $outdir) = @_;
	die "$0 index database rawdir\n" if !defined($rawindex) or !defined($rawdir) or !defined($db);

	$outdir = 'cometout' if !defined($outdir);
        mkdir $outdir if !-e $outdir;

        my @rawfiles = `ls $rawdir/*.raw`;
        my %hash = ();
        my $n = 1;
        foreach(@rawfiles){
                chomp;
                $hash{$n} = $_;
                $n++;
        }

        say "/u/home/y/ybwang/comet/bin/search.pl -e /u/home/y/ybwang/comet/bin/comet.2015025.win64.exe -p /u/home/y/ybwang/comet/comet.params.high-low -d $db -o $outdir -f $hash{$rawindex}";
	system("/u/home/y/ybwang/comet/bin/search.pl -e /u/home/y/ybwang/comet/bin/comet.2015025.win64.exe -p /u/home/y/ybwang/comet/comet.params.high-low -d $db -o $outdir -f $hash{$rawindex}");
}

