#!/usr/bin/perl
#Eric Morrison
#6/15/15
#tedersooFxnlAssn.pl


use strict;
use warnings;

my $fxn = $ARGV[0];

open(FXN, "$fxn") || die "Can't open Tedersoo data file.\n";
open(GEN, ">TedersooGenusFunction.txt") || die "Can't open output for genus assignments.\n";
open(FAM, ">TedersooFamilyFunction.txt") || die "Can't open output for family assignments.\n";

chomp(my @fxn = <FXN>);

if(scalar(@fxn) == 1)
	{
	$fxn[0] =~ s/\r|\r\n|\n/\n/;
	@fxn = split("\n", $fxn[0]);
	}

#remove first row which is notes
shift(@fxn);
@fxn = split("\t", $fxn[0]);
print scalar(@fxn), "\n";
################################
#Some funky text encoding in the 
#data file requires this manual 
#splitting of array
my @newFxn;
while(@fxn)
	{
	my $temp = join("\t", splice(@fxn, 0 , 15) );
	push(@newFxn, $temp);
	}
print scalar(@newFxn), "\n";
@fxn = @newFxn;
#################################

my @fxnHead = split("\t", $fxn[0]);
shift(@fxn);

my $genusInd;
my $famInd;
my $trophInd;
my $lifestyleInd;
my $decayInd;
my $growthFormInd;

for(my $i = 0; $i < @fxnHead; $i++)
	{
#print $fxnHead[$i], "\n";
	if($fxnHead[$i] =~ /.*genus.*/i)
		{
		$genusInd = $i;
		}
	if($fxnHead[$i] =~ /.*family.*/i)
		{
		$famInd = $i;
		}
	if($fxnHead[$i] =~ /.*Trophic Status.*/i)
		{
		$trophInd = $i;
		}
	if($fxnHead[$i] =~ /.*lifestyle.*/i)
		{
		$lifestyleInd = $i;
		}
	if($fxnHead[$i] =~ /.*decay type.*/i)
		{
		$decayInd = $i;
		}
	if($fxnHead[$i] =~ /.*Growth form.*/i)
		{
		$growthFormInd = $i;
		}
	}	
	

#Create hash for storing functional assignment by genus
my %genera;
my %fam;
foreach(@fxn)
	{
	my @genFxn = split("\t", $_);
	my %fxn;
	if(defined($genFxn[$trophInd]) == 1 && $genFxn[$trophInd] =~ /.*\w+.*/)
		{
		$genera{$genFxn[$genusInd]}{"trophic"} = $genFxn[$trophInd];
		$fam{$genFxn[$famInd]}{"trophic"}{$genFxn[$trophInd]}++;
		}else{
		$genera{$genFxn[$genusInd]}{"trophic"} = "Unknown";
		$fam{$genFxn[$famInd]}{"trophic"}{"Unknown"}++;
		}
	if(defined($genFxn[$lifestyleInd]) == 1 && $genFxn[$lifestyleInd] =~ /.*\w+.*/)
		{
		$genera{$genFxn[$genusInd]}{"lifestyle"} = $genFxn[$lifestyleInd];
		$fam{$genFxn[$famInd]}{"lifestyle"}{$genFxn[$lifestyleInd]}++;
		}else{
		$genera{$genFxn[$genusInd]}{"lifestyle"} = "Undefined";
		$fam{$genFxn[$famInd]}{"lifestyle"}{"Undefined"}++;
		}
	if(defined($genFxn[$decayInd]) == 1 && $genFxn[$decayInd] =~ /.*\w+.*/)
		{
		$genera{$genFxn[$genusInd]}{"decay"} = $genFxn[$decayInd];
		$fam{$genFxn[$famInd]}{"decay"}{$genFxn[$decayInd]}++;
		}else{
		$genera{$genFxn[$genusInd]}{"decay"} = "Undefined";
		$fam{$genFxn[$famInd]}{"decay"}{"Undefined"}++;
		}
	if(defined($genFxn[$growthFormInd]) == 1 && $genFxn[$growthFormInd] =~ /.*yeast.*/ig)
		{
		$genera{$genFxn[$genusInd]}{"yeast"} = "YeastLike";
		$fam{$genFxn[$famInd]}{"yeast"}{"YeastLike"}++;
		}else{
		$genera{$genFxn[$genusInd]}{"yeast"} = "NotYeast";
		$fam{$genFxn[$famInd]}{"yeast"}{"NotYeast"}++;
		}
	}

#take proportion of family assignments
my %famAvg;
foreach my$fam (keys %fam)
	{
	foreach my$cat (keys %{ $fam{$fam} })
		{
		my $total = 0;
		foreach my$type (keys %{ $fam{$fam}{$cat} })
			{
			$total += $fam{$fam}{$cat}{$type};
			}
		foreach my$type (keys %{ $fam{$fam}{$cat} })
			{
			if ($fam{$fam}{$cat}{$type}/$total >= 0.95)
				{
				$famAvg{$fam}{$cat} = $type."\t".$fam{$fam}{$cat}{$type}/$total;
				}elsif($fam{$fam}{$cat}{$type}/$total >= 0.75)
				{
				$famAvg{$fam}{$cat} = "putative".$type."\t".$fam{$fam}{$cat}{$type}/$total;
				}
			}
		if(defined($famAvg{$fam}{$cat}) == 0)
			{
			$famAvg{$fam}{$cat} = "Unknown\tNA";
			}
		}
	}
	
#print genus assignments
print GEN "genus\ttrophic\tlifestyle\tdecay\tyeast\n";
foreach my$genus (keys %genera)
	{
	#print $genus, "\n";#, "\t", keys(%{ $genera{$genus} }), "\n";
	print GEN "$genus\t$genera{$genus}{'trophic'}\t$genera{$genus}{'lifestyle'}\t",
	"$genera{$genus}{'decay'}\t$genera{$genus}{'yeast'}\n";
	}
	
#print family assignments
print FAM "family\ttrophic\tporportion\tlifestyle\tproportion\tdecay\tproportion\tyeast\tpropotion\n";
foreach my$fam (keys %famAvg)
	{
	print FAM "$fam\t$famAvg{$fam}{'trophic'}\t$famAvg{$fam}{'lifestyle'}\t$famAvg{$fam}{'decay'}\t$famAvg{$fam}{'yeast'}\n";
	}
