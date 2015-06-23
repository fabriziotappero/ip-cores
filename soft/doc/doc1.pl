%d1_arch_scope;
%d1_func_scope;
@d1_scope = ("none");

sub d1_process
{
    my ($body,$off) = @_;
    my (@match,$pos,$tok);
    my (%tmp,$posbeg,$posend,$reg);
    while (length($body) != 0) {
	if ($body =~ /([\W]*--[^\n]*\n)/) {
	    $body = substr($body,length($1));
	    $off += length($1);
	} else {
	    ($body,@match) = d2_scannext($body,"($id)");
	    if ($#match != -1) {
		$tok = $match[1];
		$posbeg = $off+$match[6]; 
		$posend = $off+$match[6]+length($match[0]); 
		$off = $posend; 
		if ($dbgon == 1) { print ("<$tok [$posbeg:$posend]>");}
		if      (exists($d4_keyword{$tok})) {
		    if      ($tok eq "architecture") {
			if (exists($d2_begs{$posbeg})) {
			    d1_initarch($d2_begs{$posbeg});
			    push(@d1_scope,"arch");
			} else {
			    
			}
		    } elsif ($tok eq "function") {
			if (exists($d2_begs{$posbeg})) {
			    d1_initfunc($d2_begs{$posbeg});
			    push(@d1_scope,"func");
			} else {
			}
		    } elsif ($tok eq "procedure") {
			if (exists($d2_begs{$posbeg})) {
			    d1_initproc($d2_begs{$posbeg});
			    push(@d1_scope,"func");
			} else {
			}
		    } elsif ($tok eq "end") {
			if (exists($d2_ends{$posbeg})) {
			    pop(@d1_scope);
			} else {
			}
		    } elsif ($tok eq "variable") {
			$reg = $match[0].$body;
			if ($d1_scope[$#d1_scope] eq "arch") {
			    if ($reg =~ /variable([^;]*);/) {
				d1_addarch($1);
			    }
			}
		    } elsif ($tok eq "signal") {
			$reg = $match[0].$body;
			if ($d1_scope[$#d1_scope] eq "arch") {
			    if ($reg =~ /signal([^;]*);/) {
				d1_addarch($1);
			    }
			}
		    } elsif ($tok eq "record") {
			$reg = $match[0].$body;
			if ($d1_scope[$#d1_scope] eq "arch") {
			    if ($reg =~ /signal([^;]*);/) {
				d1_addarch($1);
			    }
			}
		    } else {
			d5_addcut($posbeg,$posend,"style",$d4_keyword{$tok}{style});
		    }
		} elsif (exists($d2_records{$tok})) {
		    d5_addcut($posbeg,$posend,"record",$tok);
		} elsif (exists($d2_funcs{$tok})){
		    d5_addcut($posbeg,$posend,"func",$tok);
		} elsif (exists($d2_procs{$tok})){
		    d5_addcut($posbeg,$posend,"proc",$tok);
		} elsif (exists($d2_consts{$tok})){
		    d5_addcut($posbeg,$posend,"const",$tok);
		} elsif (exists($d2_enums{$tok})) {
		    d5_addcut($posbeg,$posend,"enum",$tok);
		} elsif (exists($d2_enumelems{$tok})) {
		    d5_addcut($posbeg,$posend,"enum",$d2_enumelems{$tok});
		} else {
		    $type = d1_vartype($tok);
		    if (not ($type eq "")) {
			d5_addcut($posbeg,$posend,"vartyp",$type);
			($body,@match) = d1_travvar($body,$type,$off);
			$off = $off+$match[6]+length($match[0]);
		    } else {
			if (exists($d3_usedby_set{$tok})) {
			    
			    d5_addcut($posbeg,$posend,"file",$tok);
			}
		    }
		}
	    }
	}
    }
}

sub d1_travvar
{
    my ($body,$type,$off) = @_;
    my $pos = -1,my $tok,my $posbeg,my $posend;
    my @match = (),my %tmp,my %elem,my @tmpmatch;
    my $reg = "^($sp\\.$sp)($id)";
    my $regindex = "^$sp\\([^\\)]*?\\)";
    $match[0] = "";
    $match[6] = 0;
    if ($body =~ /$regindex/) {
	$match[0] = $&;
	$body = substr($body,length($&));
    }
    if ($body =~ /$reg/) {
	$tok = $2;
	$posbeg = $off + length($match[0])+length($1);
	$posend = $off + length($match[0])+length($&);
	$off = $posend;
	%tmp = @{$d2_records{$type}};
	%elem = @{$tmp{elem}};
	if (exists($elem{$tok})) {
	    $match[0] .= $&;
	    $body = substr($body,length($&));
	    d5_addcut($posbeg,$posend,"vartyp",$elem{$tok});
	    ($body,@tmpmatch) = d1_travvar($body,$elem{$tok},$off);
	    $match[0].= $tmpmatch[0];
	}
    }
    return ($body,@match);
}

sub d1_initfunc
{
    my ($n) = @_;
    my (%tmp,%args,%vari,$ke);
    %tmp = @{$d2_funcs{$n}};
    %args = @{$tmp{argselem}};
    %vari = @{$tmp{varielem}};
    
    %d1_func_scope = ();
    if ($dbgon == 1) { print ("Initializing function scope\n"); };
    for $ke (sort keys(%args)) {
	$d1_func_scope{$ke} = $args{$ke};
	if ($dbgon == 1) { print ("-Add $ke:".$args{$ke}."\n"); };
    }
    for $ke (sort keys(%vari)) {
	$d1_func_scope{$ke} = $vari{$ke};
	if ($dbgon == 1) { print ("-Add $ke:".$vari{$ke}."\n"); };
    }
}

sub d1_initproc
{
    my ($n) = @_;
    my (%tmp,%args,%vari,$ke);
    %tmp = @{$d2_procs{$n}};
    %args = @{$tmp{argselem}};
    %vari = @{$tmp{varielem}};
    
    %d1_func_scope = ();
    if ($dbgon == 1) { print ("Initializing procedure scope\n"); };
    for $ke (sort keys(%args)) {
	$d1_func_scope{$ke} = $args{$ke};
	if ($dbgon == 1) { print ("-Add $ke:".$args{$ke}."\n"); };
    }
    for $ke (sort keys(%vari)) {
	$d1_func_scope{$ke} = $vari{$ke};
	if ($dbgon == 1) { print ("-Add $ke:".$vari{$ke}."\n"); };
    }
}

sub d1_initarch 
{
    my ($n) = @_;
    my (%tmp,%port,$ke,$enti);
    %d1_arch_scope = ();
    %tmp = @{$d2_archs{$n}};
    $enti = $tmp{enti};
    
    %d1_arch_scope = ();
    if ($dbgon == 1) { 
	print ("Initializing architecture scope $n of $enti\n"); 
    };
    if (exists($d2_entities{$enti})) {
	%tmp = @{$d2_entities{$enti}};
	%port = @{$tmp{portelem}};
	for $ke (sort keys(%port)) {
	    $d1_arch_scope{$ke} = $port{$ke};
	    if ($dbgon == 1) { print ("-Add $ke:".$port{$ke}."\n"); };
	}
    }
}

sub d1_addarch
{
    my ($def) = @_;
    my %elem;
    %elem = d2_splitdef($def);
    for $ke (keys(%elem)) {
	$d1_arch_scope{$ke} = $elem{$ke};
    }
}

sub d1_vartype
{
    my ($tok) = @_;
    my $type = "";
    if ($d1_scope[$#d1_scope] eq "arch") {
	if (exists($d1_arch_scope{$tok})) {
	    $type = $d1_arch_scope{$tok};
	}
    } elsif ($d1_scope[$#d1_scope] eq "func") {
	if (exists($d1_func_scope{$tok})) {
	    $type = $d1_func_scope{$tok};
	}
    }
    return $type;
}

1;

