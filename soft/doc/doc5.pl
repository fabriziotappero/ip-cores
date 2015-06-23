@d5_cuts; 
$d5_dumphtml = "";
$d5_dumphtml_types = "";
%d5_dumphtml_types_alloc = ();
$d5_divstart = "\n<div onclick=\"javascript:totop('%id%')\" id=\"T%id%\" style=\"visibility:hidden; position:absolute; BACKGROUND-COLOR: white;\">\n<table border=1 cellpadding=0 cellspacing=0><tr><td><a href=\"javascript:hide('%id%')\"><img src=\"%img_docclose%\" alt=\"close\"></a>";
$d5_divend = "</td></tr></table>\n</div>";	

sub d5_addcut
{
    my ($posbeg,$posend,$cmd,$arg) = @_;
    my (%cut,$filename);
    if ($dbgon == 1) { print ("\n+Addcut($posbeg,$posend,$cmd,$arg)\n");}
    %cut = ( posbeg => $posbeg,
	     posend => $posend,
	     cmd    => $cmd,
	     arg    => $arg );
    push (@d5_cuts,[%cut]);
}

sub d5_dumpcut
{
    my $filename;
    my ($posbeg,$posend,$cmd,$arg,$i);
    my %tmp;
    if ($dbgon == 1) {
	for($i = 0;$i < $#d5_cuts;$i++) {
	    %tmp = @{$d5_cuts[$i]};
	    $posbeg = $tmp{posbeg};
	    $posend = $tmp{posend};
	    $cmd = $tmp{cmd};
	    $arg = $tmp{arg};
	    $filename = d3_filename ($posbeg);
	    print("$filename"."[$posbeg-$posend]: $cmd($arg)\n");
	}
    }
}

sub d5_gethtml
{
    my ($beg,$end,$ommit) = @_;
    my ($filename,$posbeg,$posend,$ok,$id);
    my $cmd,my $arg,my $i=0,my $off,my $html="",my $part;
    my %tmp = ();
    my @cuts =();
    if ($dbgon == 1) {
	print ("Dump[$beg,$end]\n");
    }
    for($i = 0;$i <= $#d5_cuts;$i++) {
	%tmp = @{$d5_cuts[$i]};
	$posbeg = $tmp{posbeg};
	$posend = $tmp{posend};
	if (($posbeg >= $beg && $posbeg < $end) || 
	    ($posend > $beg && $posend <= $end)) {
	    if ($posbeg < $beg) {
		$posbeg = $beg;
	    }
	    if ($posend > $end) {
		$posend = $end;
	    }
	    $tmp{posbeg} = $posbeg;
	    $tmp{posend} = $posend;
	    push(@cuts,[%tmp]);
	}
    }
    $off = $beg;
    if ($dbgon == 1) {
	print ("Start Cutting from $off\n");
    }
    $html = "<pre><code class=\"vhdl\">";
    for($i = 0;$i <= $#cuts;$i++) {
	%tmp = @{$cuts[$i]};
	$posbeg = $tmp{posbeg};
	$posend = $tmp{posend};
	$part = substr($body_all,$posbeg,$posend-$posbeg);
	$cmd = $tmp{cmd};
	$arg = $tmp{arg};
	if ($dbgon == 1) {
	    print ("Cut [$posbeg,$posend]: $cmd,$arg\n");
	}
	if ($off < $posbeg) {
	    $html .= substr($body_all,$off,$posbeg-$off);
	}
	if (($cmd eq "vartyp") || ($cmd eq "record")) {
	    ($ok,$id) = d5_addtype_dumphtml($arg);
	    if ($ok == 1 && (not ($arg eq $ommit))) {
		$html .= "<a name=\"$arg\" href=\"javascript:show('$id')\">".$part."</a>";
	    } else {
		$html .= $part;
	    }
	} elsif ($cmd eq "const") {
	    ($ok,$id) = d5_addconst_dumphtml($arg);
	    if ($ok == 1 && (not ($arg eq $ommit))) {
		$html .= "<a name=\"$arg\" href=\"javascript:show('$id')\">".$part."</a>";
	    } else {
		$html .= $part;
	    }
	} elsif ($cmd eq "proc") {
	    ($ok,$id) = d5_addproc_dumphtml($arg);
	    if ($ok == 1 && (not ($arg eq $ommit))) {
		$html .= "<a name=\"$arg\" href=\"javascript:show('$id')\">".$part."</a>";
	    } else {
		$html .= $part;
	    }
	} elsif ($cmd eq "func") {
	    ($ok,$id) = d5_addfunc_dumphtml($arg);
	    if ($ok == 1 && (not ($arg eq $ommit))) {
		$html .= "<a name=\"$arg\" href=\"javascript:show('$id')\">".$part."</a>";
	    } else {
		$html .= $part;
	    }
	} elsif ($cmd eq "enum") {
	    ($ok,$id) = d5_addenum_dumphtml($arg);
	    if ($ok == 1 && (not ($arg eq $ommit))) {
		$html .= "<a name=\"$arg\" href=\"javascript:show('$id')\">".$part."</a>";
	    } else {
		$html .= $part;
	    }
	} elsif ($cmd eq "file") {
	    
	    ($ok,$id) = d5_addfile_dumphtml($arg);
	    if ($ok == 1 && (not ($arg eq $ommit))) {
		$html .= "<a href=\"javascript:show('$id')\">".$part."</a>";
	    } else {
		$html .= $part;
	    }
	} elsif ($cmd eq "style") {
	    
	    $html .= "<span class=\"$arg\">$part</span>";
	    
	} else {
	    $html .= $part;
	}
	$off = $posend;
    }
    if ($off < $end) {
	$html .= substr($body_all,$off,$end-$off);
    }
    $html .= "</code></pre>";
}

sub d5_addfile_dumphtml() 
{
    my ($type) = @_;
    my ($posbeg,$posend,$fname);
    my %tmp = ();
    my ($id,$html,$title);
    if (exists($d3_usedby_set{$type})) {
	%tmp = @{$d3_usedby_set{$type}};
	$html = $tmp{html};
	$id = $tmp{id};
	if (not (exists($d5_dumphtml_types_alloc{$id}))) {
	    if ($dbgon == 1) {
		print ("Output file usage div [$id:$type]\n");
	    }
	    $d5_dumphtml_types_alloc{$id} = 1;
	    $d5_dumphtml_types .= $html;
	}
	return (1,$id);
    }
    return (0,-1);
}

sub d5_addenum_dumphtml() 
{
    my ($type) = @_;
    my ($posbeg,$posend,$fname);
    my %tmp = ();
    my ($id,$html,$title);
    if (exists($d2_enums{$type})) {
	%tmp = @{$d2_enums{$type}};
	$posbeg = $tmp{posbeg};
	$posend = $tmp{posend};
	$id = $tmp{id};
	if (not (exists($d5_dumphtml_types_alloc{$id}))) {
	    if ($dbgon == 1) {
		print ("Output const div [$id:$type]\n");
	    }
	    $d5_dumphtml_types_alloc{$id} = 1;
	    $fname = d3_filename($posbeg);
	    
	    $d3_pathreplace{"%$d3_pathreplaceid%"} = d3_gethtmlname($fname);
	    $title = "&nbsp;&nbsp;&nbsp;Enum <b>$type</b> defined in <a href=\"%$d3_pathreplaceid%#$type\">$fname</a>";
	    $title = $d5_divstart."$title<br>";
	    $title =~ s/%id%/$id/g;
	    $d3_pathreplaceid++;

	    $html = d5_gethtml($posbeg,$posend,$type);
	    $d5_dumphtml_types .= $title.$html.$d5_divend;
	    
	}
	return (1,$id);
    }
    return (0,-1);
}

sub d5_addfunc_dumphtml() 
{
    my ($type) = @_;
    my ($posbeg,$posend,$fname);
    my %tmp = ();
    my ($id,$html,$title);
    if (exists($d2_funcs{$type})) {
	%tmp = @{$d2_funcs{$type}};
	$posbeg = $tmp{posbeg};
	$posend = $tmp{posend};
	$id = $tmp{id};
	if (not (exists($d5_dumphtml_types_alloc{$id}))) {
	    if ($dbgon == 1) {
		print ("Output const div [$id:$type]\n");
	    }
	    $d5_dumphtml_types_alloc{$id} = 1;
	    $fname = d3_filename($posbeg);
	    $d3_pathreplace{"%$d3_pathreplaceid%"} = d3_gethtmlname($fname);
	    $title = "&nbsp;&nbsp;&nbsp;Function <b>$type</b> defined in <a href=\"%$d3_pathreplaceid%#$type\">$fname</a>";
	    $title = $d5_divstart."$title<br>";
	    $title =~ s/%id%/$id/g;
	    $d3_pathreplaceid++;

	    $html = d5_gethtml($posbeg,$posend,$type);
	    $d5_dumphtml_types .= $title.$html.$d5_divend;
	    
	}
	return (1,$id);
    }
    return (0,-1);
}

sub d5_addproc_dumphtml() 
{
    my ($type) = @_;
    my ($posbeg,$posend,$fname);
    my %tmp = ();
    my ($id,$html,$title);
    if (exists($d2_procs{$type})) {
	%tmp = @{$d2_procs{$type}};
	$posbeg = $tmp{posbeg};
	$posend = $tmp{posend};
	$id = $tmp{id};
	if (not (exists($d5_dumphtml_types_alloc{$id}))) {
	    if ($dbgon == 1) {
		print ("Output const div [$id:$type]\n");
	    }
	    $d5_dumphtml_types_alloc{$id} = 1;
	    $fname = d3_filename($posbeg);
	    $d3_pathreplace{"%$d3_pathreplaceid%"} = d3_gethtmlname($fname);
	    $title = "&nbsp;&nbsp;&nbsp;Procedure <b>$type</b> defined in <a href=\"%$d3_pathreplaceid%#$type\">$fname</a>";
	    $title = $d5_divstart."$title<br>";
	    $title =~ s/%id%/$id/g;
	    $d3_pathreplaceid++;

	    $html = d5_gethtml($posbeg,$posend,$type);
	    $d5_dumphtml_types .= $title.$html.$d5_divend;
	    
	}
	return (1,$id);
    }
    return (0,-1);
}

sub d5_addconst_dumphtml() 
{
    my ($type) = @_;
    my ($posbeg,$posend,$fname);
    my %tmp = ();
    my ($id,$html,$title);
    if (exists($d2_consts{$type})) {
	%tmp = @{$d2_consts{$type}};
	$posbeg = $tmp{posbeg};
	$posend = $tmp{posend};
	$id = $tmp{id};
	if (not (exists($d5_dumphtml_types_alloc{$id}))) {
	    if ($dbgon == 1) {
		print ("Output const div [$id:$type]\n");
	    }
	    $d5_dumphtml_types_alloc{$id} = 1;
	    $fname = d3_filename($posbeg);
	    $d3_pathreplace{"%$d3_pathreplaceid%"} = d3_gethtmlname($fname);
	    $title = "&nbsp;&nbsp;&nbsp;Constant <b>$type</b> defined in <a href=\"%$d3_pathreplaceid%#$type\">$fname</a>";
	    $title = $d5_divstart."$title<br>";
	    $title =~ s/%id%/$id/g;
	    $d3_pathreplaceid++;

	    $html = d5_gethtml($posbeg,$posend,$type);
	    $d5_dumphtml_types .= $title.$html.$d5_divend;
	    
	}
	return (1,$id);
    }
    return (0,-1);
}
	    

sub d5_addtype_dumphtml
{
    my ($type) = @_;
    my ($posbeg,$posend,$fname);
    my %tmp = ();
    my ($id,$html,$title);
    
    if (exists($d2_records{$type})) {
	%tmp = @{$d2_records{$type}};
	$posbeg = $tmp{posbeg};
	$posend = $tmp{posend};
	$id = $tmp{id};
	if (not (exists($d5_dumphtml_types_alloc{$id}))) {
	    if ($dbgon == 1) {
		print ("Output record div [$id:$type]\n");
	    }
	    $d5_dumphtml_types_alloc{$id} = 1;
	    $fname = d3_filename($posbeg);
	    $d3_pathreplace{"%$d3_pathreplaceid%"} = d3_gethtmlname($fname);
	    $title = "&nbsp;&nbsp;&nbsp;Type <b>$type</b> defined in <a href=\"%$d3_pathreplaceid%#$type\">$fname</a>";
	    $title = $d5_divstart."$title<br>";
	    $title =~ s/%id%/$id/g;
	    $d3_pathreplaceid++;
	    
	    $html = d5_gethtml($posbeg,$posend,$type);
	    $d5_dumphtml_types .= $title.$html.$d5_divend;
	}
	return (1,$id);
    }
    return (0,-1);
}

sub d5_assemblehtml
{
    my ($filename,$html,$dhtml,$template,$header) = @_;
    my $body = d3_readfile($template,0);
    $body =~ s/%replace%/$html$dhtml/g;
    $body =~ s/%header%/$header/g;
    $body =~ s/%filename%/$filename/g;
    return $body;
}

1;
