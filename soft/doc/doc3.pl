@d3_files = ();
%d3_partfn = ();
%d3_usedby_set = ();
%d3_templates = ();
%d3_pathreplace = ();
$d3_header = "";
$d3_maintemplate = "";
$d3_frame = "";
$d3_framebase = "";

$cf = $ARGV[0];
if (!(-f $cf)) { die("$cf does not exist\n");}
open $CF,"$cf" or die ("Unable to open $cf\n");
$cfs = "";
$state = 0;
while (<$CF>) {
    s/[[:space:]\n\r]*//g;
    if (!($_ eq "")) {
	if (/\[files\]/) {
	    $state = 1;
	}
	elsif (/\[templates\]/) {
	    $state = 2;
	}
	elsif (/\[main\]/) {
	    $state = 3;
	}
	elsif (/\[header\]/) {
	    $state = 4;
	}
	elsif (/\[frames\]/) {
	    $state = 5;
	}
	elsif (/\[out-fileselect\]/) {
	    $state = 6;
	}
	elsif (/\[out-base\]/) {
	    $state = 7;
	}
	elsif ($state == 1) {
	    print ("Adding file $_\n");
	    push (@d3_files,$_);
	}
	elsif ($state == 2) {
	    if (/(%[^%]*%)=readfile\("([^"]*)"\)/) {
	        print ("Adding template $1=$2\n");
		$d3_templates{$1} = d3_readfile($2);
	    } elsif (/(%[^%]*%)=pathreplace\("([^"]*)"\)/) {
		$d3_pathreplace{$1} = $2;
	    }
	}
	elsif ($state == 3) {
	    $d3_maintemplate = $_;
	}
	elsif ($state == 4) {
	    $d3_header = $_;
	}
	elsif ($state == 5) {
	    $d3_frame = $_;
	    $d3_frame = d3_readfile($d3_frame,0);
	}
	elsif ($state == 6) {
	    $d3_fileselect = $_;
	}
	elsif ($state == 7) {
	    $d3_framebase = $_;
	}
    }
    $d3_templates{"%date%"} = `date`;
}
close $CF;

sub d3_dumpfilelist 
{
    my @ar = @d3_files;
    my $i = 0;
    if ($dbgon == 1) {
	foreach(@ar) {
	    print ("$i:$_\n");
	    $i++;
	}
    }
}

sub d3_template_replace
{
    my ($body) = @_;
    my $a = 0;

    foreach $a (keys %d3_templates) {
	$body =~ s/$a/$d3_templates{$a}/gi;
    }
    return $body;
}

$d3_pathreplaceid = 0;

sub d3_template_pathreplace
{
    my ($body,$path) = @_;
    my $a = "";
    my $tmp = "", my $fn = "";
    
    foreach $a (keys %d3_pathreplace) {
	$fn = $d3_pathreplace{$a};
	$fn = d3_relpath($path,$fn);
	$body =~ s/$a/$fn/gi;
    }

    return $body;
}

sub d3_relpath
{
    my ($src,$dest) = @_;
    my @src = split("[\\/]",$src);
    my @dest = split("[\\/]",$dest);
    my $a,my $i,my $r = "";
    for ($i=0;($i <= $#src-1) && ($#dest > 0);$i++) {
	if ($src[$i] eq $dest[0]) {
	    splice (@dest,0,1);
	} else {
	    last;
	}
    }
    
    for (;$i <= $#src-1;$i++) {
	$r .= "../";
    }
    foreach $a (@dest) {
	if ((!($r eq "")) and ! (substr($r,length($r)-1,1) eq "/")) {
	    $r .= "/"
	}
	$r .= $a
    }
    
    return $r;
}

sub d3_readfile 
{
    my ($fn,$replace) = @_;
    my $F,my $body = "";
    open $F,"$fn" or die ("Unable to open $fn\n");
    while (<$F>) {
	s/\r\n$]*/\n/g;
	if ($replace == 1) {
	    s/</&lt;/g;
	    s/>/&gt;/g;
	}
	$body .= $_;
    }
    close $F;
    return $body;
}

sub d3_readallfiles 
{
    my @ar = @d3_files;
    my $body = "";
    my $off = 0,my %tmp,my $fn;
    foreach(@ar) {
	$fn = $_;
	$d3_partfn{$off} = $_;
	$body .= d3_readfile($_,1);
	$off = length($body);
    }
    return $body;
}

sub d3_createusage
{
    my ($compbody) = @_;
    my @ar = @d3_files;
    my ($usagereg,$pos,$fn,$cfn,$pfn,$body);
    my $reg = "($id)\\.vhd\$";
    my (@usage,$htmlname,$vhdlname);
    %d3_usedby_set = ();
    foreach(@ar) {
	$pfn = $_;
	print ("Create usage for $_\n");
	if (/$reg/) {
	    $cfn = $1;
	    
	    $usagereg = "use".$sp."work".$sp."\\.".$sp."$cfn".$sp."\\.".$sp."all".$sp.";";
	    if ($dbgon == 1) {
		print ("Creating usage for $cfn: $usagereg\n");
	    }
	    $pos = 0;
	    $body = $compbody;
	    @usage = ();
	    while (length($body) != 0) {
		($body,@match) = d2_scannext($body,$usagereg);
		if ($#match != -1) {
		    $fn = d3_filename($pos + $match[6]);
		    if ($dbgon == 1) {
			print ("Found using file:$fn\n"); 
		    }
		    push (@usage,$fn);
		    $pos = $pos + $match[6] + $match[0];
		}
	    }
	    $html = "";
	    foreach(@usage) {
		$vhdlname = $_;
		$htmlname = d3_gethtmlname($vhdlname);
		$d3_pathreplace{"%$d3_pathreplaceid%"} = $htmlname;
		$html .= "used by <a href=\"%$d3_pathreplaceid%\">$_</a>\n<br>";
		$d3_pathreplaceid++;
	    }
	    
	    $vhdlname = $pfn;
	    $htmlname = d3_gethtmlname($vhdlname);
		
	    $d3_pathreplace{"%$d3_pathreplaceid%"} = $htmlname;

	    $title = "&nbsp;&nbsp;&nbsp;File <b><a href=\"%$d3_pathreplaceid%\">$vhdlname</a></b> ";
	    $title = $d5_divstart."$title<br>";
	    $title =~ s/%id%/$d2_id/g;

	    $d3_pathreplaceid++;
	    
	    $html = $title.$html.$d5_divend;
	    
	    %tmp = ( id   => $d2_id++,
		     html => $html
		     );
	    $d3_usedby_set{$cfn} = [%tmp];
	}
    }
}

sub d3_gethtmlname
{
    my ($fn) = @_;
    $fn =~ s/vhd$/html/i;
    return $fn;
}

sub d3_filename 
{
    my ($off) = @_;
    my $ke;
    my $filename = $d3_partfn{0};
    for $ke (sort { $a <=> $b } keys (%d3_partfn)) {
	if ($ke>$off) {
	    last;
	}
	$filename = $d3_partfn{$ke};
    }
    return $filename;
}

1;
