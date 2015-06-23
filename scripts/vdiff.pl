#!/usr/bin/perl

open(FIL1,"<$ARGV[0]")|| die "## cannot open reference $ARGV[0]\nUSAGE: vdiff.pl ref_file out_file\n";
open(FIL2,"<$ARGV[1]")|| die "## cannot open log file $ARGV[1]\nUSAGE: vdiff.pl ref_file out_file\n";
$ok=1;
$lines=0;


    while(<FIL1>){
	$lines++;
	if(/(\w+)\s+\w+\s+\w+\s+(\w+)\s+\w+\s+(\w+)/){
	    $timel=$1;
	    $addrl=$2;
	    $valuel=$3;
#	    print "$1=$timel $2=$addrl $3=$valuel\n";
	    $line=<FIL2>;

	    
	    if($line=~/(\w+)\s+\w+\s+\w+\s+(\w+)\s+\w+\s+(\w+)/){
	    $timer=$1;
	    $addrr=$2;
	    $valuer=$3;
#	    print "$1=$timer $2=$addrr $3=$valuer\n";
	    if(!("$addrl" eq "$addrr")){
		    print "#### (line:$lines) < $_ (line:$lines)> $line";
		    $ok=0;
			}
		if((!($valuel=~/U+/)) && (!($valuel eq $valuer))){
		    print "#### ------------ $timer $addrr $valuel $valuer   \n";
		    print "#### (line:$lines)< $_ (line:$lines)> $line";
		    $ok=0;
			}

#		if((!($valr=~/U+/)) && (!($valr eq $valrr))){
#		    print "++++++++++ $addr $vall $valr $1 $2 $3\n";
#		    print " (line:$lines)< $_ (line:$lines)> $line";
#		    $ok=0;
#		}

		}
		else {
			print "#### log missing from (line:$lines) !!!\n";
			$ok=0;	   
			exit($ok);
		}
	}
  }
exit($ok);

#exit(-99);
