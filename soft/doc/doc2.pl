$d2_mrecord   = "type".$sp."(".$id.")".$sp.
	        "is".$sp."record".$sp."([\\s\\S]*?)".
	        "end".$sp."record".$sp.";";
$d2_mfunction = "function".$sp."(".$id.")".$sp.
                "\\(".$sp."([\\s\\S]*?)".$sp."\\)".$sp.
                "return".$sp."([\\s\\S]*?)".$sp.
                "is".$sp."([\\s\\S]*?)".$sp.
                "begin".$sp."([\\s\\S]*?)".$sp.
                "end".$sp.";";
$d2_mprocedure = "procedure".$sp."(".$id.")".$sp.
                "\\(".$sp."([\\s\\S]*?)".$sp."\\)".$sp.
                "is".$sp."([\\s\\S]*?)".$sp.
                "begin".$sp."([\\s\\S]*?)".$sp.
                "end".$sp.";";
$d2_mconst     = "constant".$sp."(".$id.")".$sp.
                ":".$sp."([\\s\\S]*?)".$sp.":=".$sp.
                "([\\s\\S]*?)".$sp.
                ";";
$d2_menum      = "type".$sp."(".$id.")".$sp.
                "is".$sp."\\(".$sp."([\\s\\S]*?)".$sp.
                "\\)".$sp.";";
 
$d2_march      = "architecture".$sp."(".$id.")".$sp.
                "of".$sp."(".$id.")".$sp.
                "is".$sp."([\\s\\S]*?)".$sp.
                "end".$sp."\\1".$sp.";";

$d2_mentity    = "entity".$sp."(".$id.")".$sp.
                "is".$sp."port".$sp.
                "\\(".$sp."([\\s\\S]*?)".$sp."\\)".$sp.";".$sp.
                "end".$spid.$sp.";";


%d2_records;
%d2_funcs;
%d2_procs;
%d2_consts;
%d2_enums;
%d2_enumelems;
%d2_archs;
%d2_entities;
%d2_ends;
%d2_begs;
$d2_id = 0;

sub d2_scanrecords
{
    my ($body) = @_;
    my (@match,$pos,@part,$def,@def);
    my $i=0;
    my %tmp;
    my $off = 0,my %elem=();
    if ($dbgon == 1) {
	print ("Scanning for  records:\n");
    }
    while (length($body) != 0) {
	($body,@match) = d2_scannext($body,$d2_mrecord);
	if ($#match != -1) {
	    %elem = d2_splitdef($match[2]);
	    if ($dbgon == 1) {
		print ("$i: found record $match[1]\n");
	    }
	    %tmp = ( body => $match[0], 
	             def  => $match[2], 
		     elem => [%elem],
		     id   => $d2_id++,
	             posbeg  => $off+$match[6],
		     posend  => $off+$match[6]+length($match[0]));
	    $d2_records{$match[1]} = [%tmp];
	    $off += $match[6]+length($match[0]);
	    $i++;
	} 
    }
}

sub d2_scanfuncs
{
    my ($body) = @_;
    my @match,my $pos,my $i=0;
    my %tmp;
    my $off = 0,my %args=(),my %vari=();
    if ($dbgon == 1) {
	print ("Scanning for functions:\n");
    }
    while (length($body) != 0) {
	($body,@match) = d2_scannext($body,$d2_mfunction);
	if ($#match != -1) {
	    %args = d2_splitdef($match[2]);
	    %vari = d2_splitdef($match[4]);
	    if ($dbgon == 1) {
		print ("$i: found function $match[1]\n");
	    }
	    %tmp = ( body => $match[0], 
	             args => $match[2],
		     argselem => [%args],
	             retu => $match[3], 
	             vari => $match[4],
		     varielem => [%vari],
	             code => $match[5], 
		     id   => $d2_id++,
	             posbeg  => $off + $match[6],
		     posend  => $off + $match[6]+length($match[0]));
	    $d2_funcs{$match[1]} = [%tmp];
	    d2_addend($match[1],$tmp{posbeg},$match[0]);
	    $off += $match[6]+length($match[0]);
	    $i++;
	} 
    }
}

sub d2_scanprocedures
{
    my ($body) = @_;
    my @match,my $pos,my $i=0, my %tmp;
    my $off = 0,my %args=(),my %vari=();;
    if ($dbgon == 1) {
	print ("Scanning for procedures:\n");
    }
    while (length($body) != 0) {
	($body,@match) = d2_scannext($body,$d2_mprocedure);
	if ($#match != -1) {
	    if ($dbgon == 1) {
		print ("$i: found procedure $match[1]\n");
	    }
	    %args = d2_splitdef($match[2]);
	    %vari = d2_splitdef($match[3]);
	    %tmp = ( body => $match[0], 
	             args => $match[2],
		     argselem => [%args],
	             vari => $match[3], 
		     varielem => [%vari],
	             code => $match[4], 
		     id   => $d2_id++,
	             posbeg  => $off+$match[6],
		     posend  => $off+$match[6]+length($match[0]));
	    $d2_procs{$match[1]} = [%tmp];
	    d2_addend($match[1],$tmp{posbeg},$match[0]);
	    $off += $match[6]+length($match[0]);
	    $i++;
	} 
    }        
}

sub d2_scanconsts
{
    my ($body) = @_;
    my @match,my $pos,my $i=0;
    my $off = 0;
    if ($dbgon == 1) {
	print ("Scanning for constants:\n");
    }
    while (length($body) != 0) {
	($body,@match) = d2_scannext($body,$d2_mconst);
	if ($#match != -1) {
	    if ($dbgon == 1) {
		print ("$i: found constant $match[1]\n");
	    }
	    %tmp = ( body => $match[0], 
	             type => $match[2], 
	             valu => $match[3], 
		     id   => $d2_id++,
	             posbeg  => $off+$match[6],
		     posend  => $off+$match[6]+length($match[0]));
	    $d2_consts{$match[1]} = [%tmp];
	    $off += $match[6]+length($match[0]);
	    $i++;
	} 
    }        
}

sub d2_scanenums
{
    my ($body) = @_;
    my ($enum,@enum);
    my @match,my $pos,my $i=0;
    my $off = 0, my %tmp;
    if ($dbgon == 1) {
	print ("Scanning for enums:\n");
    }
    while (length($body) != 0) {
	($body,@match) = d2_scannext($body,$d2_menum);
	if ($#match != -1) {
	    if ($dbgon == 1) {
		print ("$i: found enum $match[1]\n");
	    }
	    %tmp = ( body => $match[0], 
	             enum => $match[2], 
		     id   => $d2_id++,
	             posbeg  => $off+$match[6],
		     posend  => $off+$match[6]+length($match[0]));
	    $off += $match[6]+length($match[0]);
	    $d2_enums{$match[1]} = [%tmp];
	    $enum = $match[2];
	    @enum = split (",",$enum);
	    foreach(@enum) {
		s/[\s\n\r]//g;
		$d2_enumelems{$_} = $match[1];
	    }
	    $i++;
	} 
    }        
}

sub d2_scanarchs
{
    my ($body) = @_;
    my @match,my $pos,my $i=0,my $reg;
    my $off = 0;
    if ($dbgon == 1) {
	print ("Scanning for architectures:\n");
    }
    while (length($body) != 0) {
	($body,@match) = d2_scannext($body,$d2_march);
	if ($#match != -1) {
	    if ($dbgon == 1) {
		print ("$i: found architecture $match[1]\n");
	    }
	    %tmp = ( body => $match[0], 
	             enti => $match[2], 
		     id   => $d2_id++,
	             posbeg  => $off+$match[6],
		     posend  => $off+$match[6]+length($match[0]));
	    $off += $match[6]+length($match[0]);
	    $d2_archs{$match[2]} = [%tmp];
       	    $reg = "end$sp".$match[1]."$sp;\$";
	    $match[0] =~ s/$reg/end;/g;
	    d2_addend($match[2],$tmp{posbeg},$match[0]);
	    $i++;
	} 
    }        
}

sub d2_scanentities
{
    my ($body) = @_;
    my @match,my $pos,my $i=0,my $reg;
    my $off = 0,my %port=(),my %tmp;
    if ($dbgon == 1) {
	print ("Scanning for entities:\n");
    }
    while (length($body) != 0) {
	($body,@match) = d2_scannext($body,$d2_mentity);
	if ($#match != -1) {
	    
	    if ($dbgon == 1) {
		print ("$i: found entity $match[1]\n");
	    }
	    %port = d2_splitdef($match[2]);
	    %tmp = ( body => $match[0], 
	             port  => $match[2],
		     portelem => [%port],
		     id   => $d2_id++,
	             posbeg  => $off+$match[6],
		     posend  => $off+$match[6]+length($match[0]));
	    $off += $match[6]+length($match[0]);
	    $d2_entities{$match[1]} = [%tmp];
       	    $reg = "end$sp".$match[1]."$sp;\$";
	    $i++;
	} 
    }        
}

sub d2_addend
{
    my ($name,$posbeg,$match) = @_;
    my $pos,my $reg = "end$sp;$sp\$";
    $match =~ s/$reg//;
    $pos = $posbeg+length($match);
    $d2_ends{$pos} = '1';
    $d2_begs{$posbeg} = $name;
}

sub d2_dumpscan
{
    my ($k,$ke,$v,$body);
    my $i=0;
    my (%tmp,%args,%vari,%port);
    if ($dbgon == 1) {
	for $k (sort keys(%d2_records)) {
	    print ("$i: Record $k:\n");
	    %tmp = @{$d2_records{$k}};
	    $body = $tmp{body};
	    %elem = @{$tmp{elem}};
	    $body =~ s/\n/\n  /g;
	    print ("start-body:\n  ".$body."end-body\n");
	    print ("posbeg: ".$tmp{posbeg}."\n");
	    print ("posend: ".$tmp{posend}."\n");
	    for $ke (sort keys(%elem)) {
		print ("    elem: $ke:".$elem{$ke}."\n");
	    }
	    $i++;
	}
	for $k (sort keys(%d2_funcs)) {
	    print ("$i: Function $k:\n");
	    %tmp = @{$d2_funcs{$k}};
	    $body = $tmp{body};
	    %args = @{$tmp{argselem}};
	    %vari = @{$tmp{varielem}};
	    $body =~ s/\n/\n  /g;
	    print ("start-body:\n  ".$body."\nend-body\n");
	    for $ke (sort keys(%args)) {
		print ("    args: $ke:".$args{$ke}."\n");
	    }
	    for $ke (sort keys(%vari)) {
		print ("    vars: $ke:".$vari{$ke}."\n");
	    }
	    $i++;
	}
	for $k (sort keys(%d2_procs)) {
	    print ("$i: Procedure $k:\n");
	    %tmp = @{$d2_procs{$k}};
	    $body = $tmp{body};
	    %args = @{$tmp{argselem}};
	    %vari = @{$tmp{varielem}};
	    $body =~ s/\n/\n  /g;
	    print ("start-body:\n  ".$body."\nend-body\n");
	    for $ke (sort keys(%args)) {
		print ("    args: $ke:".$args{$ke}."\n");
	    }
	    for $ke (sort keys(%vari)) {
		print ("    vars: $ke:".$vari{$ke}."\n");
	    }
	    $i++;
	}
	for $k (sort keys(%d2_consts)) {
	    print ("$i: Constant $k:\n");
	    %tmp = @{$d2_consts{$k}};
	    $body = $tmp{body};
	    $body =~ s/\n/\n  /g;
	    print ("start-body:\n  ".$body."\nend-body\n");
	    $i++;
	}
	for $k (sort keys(%d2_enums)) {
	    print ("$i: Enum $k:\n");
	    %tmp = @{$d2_enums{$k}};
	    $body = $tmp{body};
	    $body =~ s/\n/\n  /g;
	    print ("start-body:\n  ".$body."\nend-body\n");
	    $i++;
	}
	for $k (sort keys(%d2_archs)) {
	    print ("$i: Architecture $k:\n");
	    %tmp = @{$d2_archs{$k}};
	    $enti = $tmp{enti};
	    print ("  architecture $k of $enti\n");
	    print ("  posbeg: ".$tmp{posbeg}."\n");
	    print ("  posend: ".$tmp{posend}."\n");
	    $i++;
	}
	for $k (sort keys(%d2_entities)) {
	    print ("$i: Entity $k:\n");
	    %tmp = @{$d2_entities{$k}};
	    %port = @{$tmp{portelem}};
	    for $ke (sort keys(%port)) {
		print ("    ports: $ke:".$port{$ke}."\n");
	    }
	    print ("  posbeg: ".$tmp{posbeg}."\n");
	    print ("  posend: ".$tmp{posend}."\n");
	    $i++;
	}
    } 
}

sub d2_scannext
{
    my ($body,$reg) = @_;
    my $pos = -1;
    my @match = ();
    if ($body =~ /$reg/) {
	$pos = index($body,$&,0);
	if ($pos != -1) {
	    $match[0] = $&;
	    $match[1] = $1;
	    $match[2] = $2;
	    $match[3] = $3;
	    $match[4] = $4;
	    $match[5] = $5;
	    $match[6] = $pos;
	    $body = substr($body,$pos+length($match[0]));
	    
	} else {
	    $body = "";
	}
    } else {
	$body = "";
    }
    return ($body,@match);
}

sub d2_remcomment
{
    my ($s) = @_;
    $s =~ s/--.*\n/\n/g;
    return $s;
}

sub d2_remspace
{
    my ($s) = @_;
    my $reg = $sp;
    $s =~ s/$sp//g;
    return $s;
}

sub d2_remindex
{
    my ($s) = @_;
    my $reg = "\\([^\\)]*?\\)";
    $s =~ s/$reg//g; 
    $s = d2_remspace($s);
    return $s;
}

sub d2_splitdef
{
    my ($def) = @_;
    my %elem = (),my $reg;
    my @part,my @list,my $listelem;
    $def = d2_remcomment($def);
    $def =~ s/\bvariable\b//g; 
    $def =~ s/\bin\b//g; 
    $def =~ s/\bout\b//g; 
    $def =~ s/\binout\b//g; 
    @def = split(";",$def);
    %elem=();
    foreach (@def) {
	@part = split (":",$_);
	@list = split (",",$part[0]);
	$reg = "^$sp($id)";
	if ($part[1] =~ /$reg/) {
	    $part[1] = $1;
	    foreach (@list) {
		$listelem = $_;
		$listelem = d2_remspace($listelem);
		if (not ($part[0] eq "")) { 
		    $elem{$listelem} = $part[1];
		}
	    }
	}
    }
    return %elem;
}

sub d2_dumpmasks
{
    if ($dbgon == 1) {
	print ("record    mask: $d2_mrecord \n");
	print ("function  mask: $d2_mfunction \n");
	print ("procedure mask: $d2_mprocedure \n");
	print ("constants mask: $d2_mconst \n");
	print ("enum      mask: $d2_menum \n");
	print ("entities  mask: $d2_mentity \n");
    }
}
1;
