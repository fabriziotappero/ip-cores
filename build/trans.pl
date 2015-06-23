#!/usr/bin/perl

if ($#ARGV < 1) {
    die ("# Call: trans.pl <basedir> [replacelib <lib> <with>]\n");
}
$base = $ARGV[0];

$cmd = "find $base";
print STDERR $cmd;
$a = `$cmd`;
@a = split("\n",$a);
%h = ();
%d = ();
$cmd = $ARGV[1];
$cmd_arg1 = $ARGV[2];
$cmd_arg2 = $ARGV[3];

foreach $f (@a) {
    if ( $f =~ /\.vhd$/) {
	($fn,$pn) = splitpath($f);
	if ($fn =~ /^([^\.]*)\.vhd$/) {
	    $h{$1} = $f;
	}
    }
}

foreach $f (@a) {
    $dep = "$f: ";
    if ( $f =~ /\.vhd$/) {
	if (1) { #if (!$noread{$f}){
	    ($fn,$pn) = splitpath($f);
	    if (open(FILEH, "$f")) {
		close(FILEH);
		$fc = readin($f);
		if ($cmd eq "replacelib") {
		    if ($cmd_arg1 eq "" || $cmd_arg2 eq "") {
			die ("Use: trans.pl <basedir> replacelib <lib> <with>\n");
		    }
		    leonconfig($f,$fn,$pn,$fc,$cmd_arg1,$cmd_arg2);
		}
	    }
	}
    }
}

sub leonconfig {
    my ($f,$fn,$pn,$fc,$cmd_arg1,$cmd_arg2) = @_;
    if (!($fc =~(/\$\(trans-do-not-touch\)/))) {
	if (compname($f) eq "$cmd_arg1") {
	    if ($fc =~ /package $cmd_arg1 is/) {
		$fc =~ s/package $cmd_arg1 is/package $cmd_arg2 is/gi;
		$f =~ s/$cmd_arg1.vhd/$cmd_arg2.vhd/gi;
		print ("Writing $f\n");
		if (open (FILEH,">$f")) {
		    print FILEH $fc;
		    close FILEH;
		} else {
		    print "writing \"$f\": $!\n";
		}
	    } else {
		print ("Error: \"package $cmd_arg1 is\" in $f not found\n");
	    }
	} else {
	    if ($fc =~ /use[[:space:]]*work\.$cmd_arg1\.all/) {
		$fc =~ s/use[[:space:]]*work\.$cmd_arg1\.all/use work.$cmd_arg2.all/gi;
		if (-f $f) {
		    print ("Backup $f:\n");
		    print `cp $f $f.bck`;
		}
		print ("Writing $f\n");
		if (open (FILEH,">$f")) {
		    print FILEH $fc;
		    close FILEH;
		} else {
		    print "writing \"$f\": $!\n";
		}
	    }
	}
    }
}
		
sub tagfile() {
    my ($n) = @_;
    $n =~ s/\//_/gi;
    $n =~ s/\.vhd$//gi;
    $n = "tags/$n";
    return $n;
}

sub compname() {
    my ($n) = @_;
    my ($f,$p) = splitpath($n);
    $f =~ s/\.vhd$//gi;
    return $f;
}
	
sub splitpath() {
    my ($n) = @_;
    my @n = split("/",$n);
    if ($#n > -1) {
	my $f = splice(@n,$#n,1);
	my $p = join("/",@n);
	return ($f,$p);
    }
    return $n;
}


sub readin() {
    my ($n) = @_;
    my $l = "";
    if (open(RF, "$n")) {
	while (<RF>) {
	    $l .= $_;
	}
	close(RF);
    } else {
	print "opening \"$n\": $!\n";
    }
    return $l;
}


