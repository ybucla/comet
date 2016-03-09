#! /u/home/y/ybwang/perl

use strict;
use warnings;
use Getopt::Std;
use List::MoreUtils qw(uniq);

my $usage=
"------
$0 -f percolatorfile -f FDR

This is a parser to filter the local false discovery hits from percolator output result file.
The output file of percolator should contains at lease:
PSMId\tscore\tq-value\tposterior_error_prob\tpeptide	proteinIds

The program will use the PEP as threshold to calculate the FDR = sum of pep / total numbers.

Options:
-f percolator file
-r localFDR (default: 0.01)
";

my %options=();
getopts("f:r:",\%options);
my ($file, $FDR) = ($options{'f'},$options{'r'});
die $usage if !defined($file);
$FDR = 0.01 if !defined($FDR);

my ($target, $target_peptide) = readOutput($file);

my @uniq = sort {$a<=>$b} uniq(@{$target});
#print scalar(@uniq);
my $result = '';

foreach my $s (@uniq){

	my $sum = 0;
	my $content = '';
	my $total = scalar(@{$target_peptide});
	
	foreach my $l (@{$target_peptide}){
		my ($score, $pep) = (split/\t/,$l)[1, 3];
		if($pep < $s){
			$sum += $pep;
			$content .= $l."\n";
		}		
	}

	my $fdr = $sum / $total;
	last if $fdr > $FDR;
	$result = $content;	
}

(my $out = $file) =~ s/\.\w*$/_$FDR.localFDR/g; 
print 'Output to:',"\t",$out,"\n";
open OUT, ">$out";
print OUT '# LocalFDR filtered: ',$FDR,"\n";
print OUT $result;
close OUT;


sub readOutput {
	my $in = shift;
	my @target_score;
	my @target_content;
	open IN, $in or die "open failed:\t $in";
	while(<IN>){
		chomp;
		next if /^CometVersion|^scan/;
		my ($score, $protein) = (split/\t/)[3, 5];
		push @target_score, $score;
		push @target_content, $_;
	}
	close IN;
	return (\@target_score,\@target_content);
}

