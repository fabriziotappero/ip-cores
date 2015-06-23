#!/usr/bin/perl
# Purpose: Initialize the combinatorial tmp variables
#          to avoid instanciation in synthesis

if ($#ARGV < 0) {
    die ("# Call: init.pl [getinit <comp> <record>|infile <file>|rem <file>]\n");
}
$cmd = $ARGV[0];
$arg1 = $ARGV[1];
$arg2 = $ARGV[2];
$ident = "[a-zA-Z][a-zA-Z0-9_]*";
$exp = "[a-zA-Z0-9_\\-+*\\(\\)\s]*";
$space = "[[:space:]]*";
$nl = "\n";

if ($cmd eq "getinit") {
    getinit($arg1,$arg2);
} elsif ($cmd eq "infile") {
    infile($arg1);
} elsif ($cmd eq "remfile") {
    remfile($arg1);
}

sub infile {
    my ($file) = @_;
    my $comp = compname($file);
    ($s,$last,$lastfn) = readfiles($comp);
    if (!($file eq $lastfn)) {
	die ("Error: $file not last file of \"make $comp\"\n");
    } else {
	print STDERR ("Scanning file $file\n");
    }
    $last = process($s,$last);
    
    if (-f $file) {
	print STDERR ("Making backup of $file\n");
	`cp $file $file.bck`;
    }
    if (open(RF, ">$file")) {
	print RF $last;
	close(RF);
    } else {
	print "opening \"$n\": $!\n";
    }
}

sub remfile {
    my ($file) = @_;
    $s = readin($file);
    $s = removeinit($s);
    if (-f $file) {
	print STDERR ("Making backup of $file\n");
	`cp $file $file.bck`;
    }
    if (open(RF, ">$file")) {
	print RF $s;
	close(RF);
    } else {
	print "opening \"$n\": $!\n";
    }
}


sub getinit {
    my ($comp,$record) = @_;
    my $s,my $last,my $lastfn;
    
    ($s,$last,$lastfn) = readfiles($comp);
    $s .= $last;
    ($rec,$pos) = getrecord($record,$s);
    $i = InitRec("%start%",$record,$rec,$f.substr($s,0,$pos));
    print $i;
}

sub readfiles {
    my ($comp) = @_;
    my $r, my @r, my $f, my $rf,my @a,my $fn, my $s;
    my $last, my $lastfn;
    $r = `make clean`;
    $r = `make -n $comp`;
    @r = split("\n",$r);
    $f = "";
    $rf = "";
    $pr = "";
    @a = ();
    foreach(@r) {
	$fn = $_;
	if ($fn =~ /([^\s]*\.vhd)$/) {
	    push(@a,$1);
	}
    }
    
    $s = "";
    $last = "";
    $lastfn = "";
    foreach(@a) {
	print STDERR ("Append file: $_\n");
	$lastfn = $_;
	$last = readin($lastfn);
	$s .= $last;
    }
    return ($s,$last,$lastfn);
}
	    
#$reg = "    -- \$(init-automatically-generated-for-synthesis:\(($ident):($record)\)$nl";
#$reg .= "    -- \$(/init-automatically-generated-for-synthesis:\(\1:\2\)$nl";
#$s =~ s/$reg//i;
#    
#	print STDERR ("Scanning $1\n");
#	$fn = $1;
#	$pr = process($fn);
#	$f .= $pr;
#	$rf .= $pr;
#print $rf;

sub removeinit {
    my ($s) = @_;
    my $reg;
    my $r = "";
    
    $reg = "    -- \\\$\\(init-automatically-generated-for-synthesis:\\(($ident):($ident)\\)\\)([^\\\$]*)?";
    $reg .= "    -- \\\$\\(/init-automatically-generated-for-synthesis:\\(\\1:\\2\\)\\)[\r\n]*";
    while ($s =~ /$reg/) {
	my $p = index($s,$&,0);
	print STDERR ("Removed previous init for $1:$2\n");
	$r .= substr($s,0,$p);
	$s = substr($s,$p+length($&));
    }
    $r .= $s;
    return $r;
}

sub process
{
    my ($def,$s)=@_;
    my $ns = "";
    my $pos,$n,$typ,$rec,$i;
    my @e,@s;
    
    $s = removeinit($s);

    @s = split("\n",$s);
    foreach (@s) {
	s/[\r\n]//g;
	if (/\$\(init\(($ident):($ident)\)\)/) {
	    #print("\n-Init: $1:$2\n");
	    $dn = $1,
	    $dtyp = $2;
	    ($rec,$pos) = getrecord($dtyp,$def.$s);
	    $i = InitRec($dn,$dtyp,$rec,$f.substr($def.$s,0,$pos));
	    $ns .= $_."$nl";
	    $ns .= "    -- \$(init-automatically-generated-for-synthesis:($dn:$dtyp))$nl";
	    $ns .= $i."$nl";
	    $ns .= "    -- \$(/init-automatically-generated-for-synthesis:($dn:$dtyp))$nl";
	}
	else {
	    $ns .= $_."$nl";
	}
    }
    return $ns;
}

sub InitRec
{
    my ($n,$typ,$rec,$beg)=@_;
    my $ntyp,$nn,$i,$enum;
    my $nrec,$npos;
    my $r = "";
    my @e = ();
    #print "\-Initialize $n:$typ";

    @e = ExpandRec($rec,$beg);
    
    for $i ( 0 .. $#e ) {
	$nn = $e[$i][0];
	$ntyp = $e[$i][1];
	#print ("-Elem $nn:$ntyp\n");
	if ($ntyp =~ /[[:space:]]*std_logic_vector[[:space:]]*\(/) {
	    $r .= "    $n.$nn := (others => '0');$nl";
	} 
	elsif ($ntyp =~ /[[:space:]]*std_logic$/)  {
	    $r .= "    $n.$nn := '0';$nl";
	}
	elsif ($ntyp =~ /[[:space:]]*integer/)  {
	    $r .= "    $n.$nn := 0;$nl";
	}
	else {
	    $enum = GetEnum($ntyp,$beg);
	    if ($enum eq "") {
		($nrec,$npos) = getrecord($ntyp,$beg);
		$r .= InitRec($n.".".$nn,$ntyp,$nrec,$beg);
	    }
	    else {
		$r .= "    $n.$nn := $enum;$nl";
	    }
	}
    }
    return $r;
} 


sub lin_log2 {
    my ($val) = @_;
    my $r;
    my @lin_log2a  = ("x",0,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,
				5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6);
    if ($val > $#lin_log2a) {
	$r = 6;
    }
    $r = $lin_log2a[$val];
    return $r;
}
sub lin_log2x {
    my ($val) = @_;
    my $r;
    my @lin_log2xa :=("x",1,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,
				5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6);
    if ($val > $#lin_log2xa) {
	$r = 6;
    }
    $r = $lin_log2xa[$val];
    return $r;
}

sub ExpandRec 
{
    my ($rec,$beg)=@_;
    my $e,$typ,$reg,$typdef,$l,$r;
    my @rec,@n,@tmp;
    my @r = ();

    @rec = split("\n",$rec);
    
    for $e (@rec) {
	$e =~ s/--(.)*$//g;
	if ($e =~ /(.*?):(.*);/) {
	    $typ = $2;
	    @n = split (",",$1);
	    $typ =~ s/[[:space:]]*//g;
	    for $e (@n) {
		$e =~ s/[[:space:]]*//g;
		$reg = $space."(".$ident.")".$space."\\(".$space.
		    "([0-9]*)".$space."downto".$space."([0-9]*)".$space."\\)";
		$reg = $space."(".$ident.")".$space."\\(".$space.
		    "($exp)".$space."downto".$space."($exp)".$space."\\)";
		
		if (!($typ =~ /[[:space:]]*std_logic_vector[\s\r\n\(\)\$]/ || $typ =~ /[[:space:]]*std_logic[\s\r\n\$]/) && 
		      $typ =~ /$reg/ ) {
		    my $p = 0;
		    $typdef = $1;
		    $l = $2;
		    $r = $3;
		    ($typdef,$p) = GetType($typdef,$beg);
		    print STDERR ("Type resolve: $typdef\n");
		    
		    $l = ResolveExp($l,$beg);
		    $r = ResolveExp($r,$beg);
		    print STDERR ("-Left resolved to $l:");
		    print STDERR ("eval($l)=");
		    $l = eval "$l";
		    print STDERR ($l."\n");
		    print STDERR ("-Right resolved to $r:");
		    print STDERR ("eval($r)=");
		    $r = eval "$r";
		    print STDERR ($r."\n");
		    
		    for ($i=$r;$i<=$l;$i++) {
			@tmp = ($e."($i)",$typdef);
			push @r, [ @tmp ];
		    }
		}
		else {
		    @tmp = ($e,$typ);
		    push @r, [ @tmp ];
		}
	    }
	}
    }
    return @r;
}

sub ResolveExp 
{
    my ($exp,$beg) = @_;
    my $n = 0, my $p;
    my $resolve = "",my $id;
    print STDERR ("Resolve: $exp\n");
    while ($exp =~ /($ident)/) {
	$id = $1;
	$p = index($exp,$&,0);
	$resolve .= substr($exp,0,$p);
	if (($id eq "lin_log2") || ($id eq "log2")) {
	    $resolve .= "lin_log2";
	} elsif (($id eq "lin_log2x") || ($id eq "log2x")) {
	    $resolve .= "lin_log2x";
	} else {
	    $resolve .= GetConstant($id,$beg);
	}
	$exp = substr($exp,$p+length($id));
    }
    $resolve .= $exp;
    return $resolve;
}

sub GetConstant 
{
    my ($id,$beg) = @_;
    my $p,my $exp,$resolve="";
    print STDERR ("Search for constant $id \n"); 
    $exp2 = "[a-zA-Z0-9_\\-+*\\(\\)\s]*";
    
    if ($beg =~ /constant\s*$id\s*:\s*integer\s*[^:]*:=\s*([^;]*)\s*;/) {
	$exp = $1;
	$p = index($beg,$&,0);
	$beg = substr($beg,0,$p);
	print STDERR ("$id = $exp\n"); 
	if ($exp =~ /$ident/) {
	    $exp = ResolveExp($exp,substr($beg,0,$p));
	}
    } else {
	die ("Could not find constant $id\n");
    }
    return $exp;
}

sub GetType
{
    my ($typ,$beg)=@_;
    my $r = "",my $p = 0;
    if ($beg =~/type\s*$typ\s*is\s*array\s*\(\s*natural\s*range\s*<\s*>\s*\)\s*of\s*([^;]*)/) {
	$r = $1;
	$p = index($beg,$&,0);
    }
    else {
	die ("Did not find typedef $typ");
    }
    return ($r,$p);
}

sub GetEnum
{
    my ($typ,$beg)=@_;
    my $r = "";
    
    if ($beg =~/type\s*$typ\s*is\s*\(\s*($ident)/) {
	$r = $1;
    }
    return $r;
}

sub getrecord
{
    my ($rn,$s)=@_;
    my $rec,$pos=0;
    
    $reg = "type".$space.$rn.$space."is".$space."record([[:print:][:space:]]*?)end".$space."record";
    
    if ($s =~ /$reg/g) {
	$pos = index($s,$&,0);
	$rec = $1;
    } else {
	die ("Did not find record $rn with $reg ");
    }
    return ($rec,$pos);
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
    
    if ($l =~ /[\\r][\\n]/) {
	#$nl = "\r\n";
    }
    return $l;
}

sub getnewline {
    my ($f) = @_;
    if ($f =~ /[\\r][\\n]/) {
	return "\r\n";
    } else {
	return "\n";
    }
}
