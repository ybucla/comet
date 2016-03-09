#! /u/home/y/ybwang/perl

# search with comet parameters
# # decoy_search = 1
use strict;
use warnings;
use Getopt::Std;
use List::MoreUtils qw(uniq);
use File::Basename;

my $usage=
"------
$0 -t targetfile -d decoyfile -f FDR

This is a parser to filter the false discovery hits from comet software.

Options:
-f percolator file
-r FDR (default: 0.01)
";

my %options=();
getopts("f:r:",\%options);
my ($file, $FDR) = ($options{'f'},$options{'r'});
die $usage if !defined($file);
$FDR = 0.01 if !defined($FDR);

my $dirname = dirname($file);
my $basename = basename($file);

my $outdir = $dirname.'/'.$FDR;

mkdir $outdir if !-e $outdir;

(my $out_psm = $outdir.'/'.$basename) =~ s/\.\w*$/.$FDR.psm.percolator/g; 

(my $out_pep = $outdir.'/'.$basename) =~ s/\.\w*$/.$FDR.pep.percolator/g; 

(my $out_pro = $outdir.'/'.$basename) =~ s/\.\w*$/.$FDR.pro.percolator/g; 

(my $out_decoy_psm = $outdir.'/'.$basename) =~ s/\.\w*$/.$FDR.decoy.psm.percolator/g; 

(my $out_decoy_pep = $outdir.'/'.$basename) =~ s/\.\w*$/.$FDR.decoy.pep.percolator/g; 

(my $out_decoy_pro = $outdir.'/'.$basename) =~ s/\.\w*$/.$FDR.decoy.pro.percolator/g; 
#print $out_psm,"\n";
&percolator($file, $out_psm, $out_pep, $out_pro, $out_decoy_psm, $out_decoy_pep, $out_decoy_pro, $FDR);


## -- subroutine -- ##
sub percolator {
	my $in = shift;
	my $out_psm = shift;
	my $out_pep = shift;
	my $out_pro = shift;
	my $out_decoy_psm = shift;
	my $out_decoy_pep = shift;
	my $out_decoy_pro = shift;
	my $fdr = shift;
	system("/u/home/y/ybwang/percolator-2.08/bin/percolator -A $in -t $fdr -F $fdr -m $out_psm -r $out_pep -l $out_pro -M $out_decoy_psm -B $out_decoy_pep -L $out_decoy_pro");
}


