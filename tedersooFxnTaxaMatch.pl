#!/usr/bin/perl
#Eric Morrison
#6/15/15
#tedersooFxnTaxaMatch.pl

use strict;
use warnings;

my $in = $ARGV[0];
my $genus = $ARGV[1];
my $famIn = $ARGV[2];
my $out = $ARGV[3];

open(IN, "$in") || die "Can't open taxa file.\n";
open(GEN, "$genus") || die "Can't open genus function file.\n";
open(FAM, "$famIn") || die "Can't open family function file.\n";
open(OUT, ">$out") || die "Can't open output.\n";

chomp(my @in = <IN>);
chomp(my @genus = <GEN>);
chomp(my @famIn = <FAM>);

if(scalar @in == 1)
	{
	$in[0] =~ s/\r|\r\n|\n/\n/g;
	@in = split("\n", $in[0]);
	}
if(scalar @genus == 1)
	{
	$genus[0] = s/\r|\r\n|\n/\n/g;
	@genus = split("\n", $genus[0]);
	}
if(scalar @famIn == 1)
	{
	$famIn[0] =~ s/\r|\r\n|\n/\n/g;
	@famIn = split("\n", $famIn[0]);
	}


shift(@in);
shift(@genus);
shift(@famIn);
print OUT "\ttrophicStatus\tdecayType\tyeast\n";
foreach my $otu (@in)
	{
	my %taxFunc;
	my $found = 0;
 	my @otu = split("\t", $otu);
	#Assign no blast hit entries
	if($otu[1] =~ /.*No_blast_hit.*/)
		{
		$taxFunc{$otu[0]}{"trophic"} = "Unknown";
		$taxFunc{$otu[0]}{"decay"} = "NA";
		$taxFunc{$otu[0]}{"yeast"} = "Unknown";
		$found = 1;
		}
	#Assign entries that are unknown at the genus and family level
	if($otu[1] =~ /.*unidentified.*/ && $otu[2] =~ /.*unidentified.*/)
		{
		$taxFunc{$otu[0]}{"trophic"} = "Unknown";
		$taxFunc{$otu[0]}{"decay"} = "NA";
		$taxFunc{$otu[0]}{"yeast"} = "Unknown";
		$found = 1;
		}
	#Assign taxa that are unassigned at genus level but assigned at family
	if($otu[1] =~ /.*unidentified.*/ && $otu[2] !~ /.*unidentified.*/)
		{
		$otu[2] =~ /f__(.+)/;
		my $searchFam = $1;
		foreach my $fam (@famIn)
			{
			my @fam = split("\t", $fam);
			if($searchFam eq $fam[0])
				{
				$found = 1;
				if($fam[1] =~ /.*Saprotroph/)
					{
					$taxFunc{$otu[0]}{"trophic"} = $fam[1];
					}
				if($fam[1] =~ /.*Biotroph/ || $fam[1] =~ /.*Symbiotroph/)
					{
					$taxFunc{$otu[0]}{"trophic"} = $fam[3];
					}
				if($fam[1] =~ /.*Unknown/)
					{
					$taxFunc{$otu[0]}{"trophic"} = "Unknown";
					}
				#Assign decay type if avaialble
				if($fam[5] !~ /.*Undefined/ && $fam[5] !~ /.*Unknown/)
					{
					$taxFunc{$otu[0]}{"decay"} = $fam[5];
					}else{
					$taxFunc{$otu[0]}{"decay"} = "NA";
					}
				#Assign yeast or not
				$taxFunc{$otu[0]}{"yeast"} = $fam[7];
				last;
				}
			}
		}
	#Assign taxa that are assigned at the genus level
	if($otu[1] !~ /.*unidentified.*/ && $otu[1] !~ /No_blast_hit/)
		{
		$otu[1] =~ /g__(.+)/;
		my $searchGen = $1;
		foreach my $gen (@genus)
			{
			my @gen = split("\t", $gen);
			if($searchGen eq $gen[0])
				{
				$found = 1;
				#Assign trophic status/lifestyle
				if($gen[1] =~ /.*Saprotroph/)
					{
					$taxFunc{$otu[0]}{"trophic"} = $gen[1];
					}
				if($gen[1] =~ /.*Biotroph/ || $gen[1] =~ /.*Symbiotroph/)
					{
					$taxFunc{$otu[0]}{"trophic"} = $gen[2];
					}
				if($gen[1] =~ /.*Unknown/)
					{
					$taxFunc{$otu[0]}{"trophic"} = "Unknown";
					}
				#Assign decay type if avaialble
				if($gen[3] !~ /.*Undefined/ && $gen[3] !~ /.*Unknown/)
					{
					$taxFunc{$otu[0]}{"decay"} = $gen[3];
					}else{
					$taxFunc{$otu[0]}{"decay"} = "NA";
					}
				#Assign yeast or not
				$taxFunc{$otu[0]}{"yeast"} = $gen[4];
				last;
				}
			}
		}
	if($found == 0)
		{
		$taxFunc{$otu[0]}{"trophic"} = "Unknown";
		$taxFunc{$otu[0]}{"decay"} = "NA";
		$taxFunc{$otu[0]}{"yeast"} = "Unknown";
		}
	$taxFunc{$otu[0]}{"trophic"} =~ s/\s/\./g;
	$taxFunc{$otu[0]}{"decay"} =~ s/\s/\./g;
	$taxFunc{$otu[0]}{"yeast"} =~ s/\s/\./g;
	print OUT "$otu[0]\t$taxFunc{$otu[0]}{'trophic'}\t$taxFunc{$otu[0]}{'decay'}\t$taxFunc{$otu[0]}{'yeast'}\n";
	}