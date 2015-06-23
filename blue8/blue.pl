#!/usr/bin/perl
# Part of Blue 8 by Al Williams http://blue.hotsolder.com
# V2 supports # constant syntax
# we used to support multiple files on command line
# but now that the driver script uses cpp, assume 1 file only


eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
    if $running_under_some_shell;
			# this emulates #! processing on NIH machines.
			# (remove #! line above if indigestible)

eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_0-9]+=)(.*)/ && shift;
			# process any FOO=bar switches




$[ = 1;			# set array base to 1
$, = ' ';		# set output field separator
$\ = "\n";		# set output record separator

$pass = 1;
$location = 0;


%opmap = ('dw', 0, 'hlt', 0, 'nop', 1,
  'add' ,0x1000,'xor',0x2000, 'and', 0x3000,
  'ior', 0x4000, 'not', 2,'lda', 0x6000, 'sta', 0x7000,
  'call', 0x8000, 'jmp', 0xa000, 'ldx', 0xb000,
  'ral', 3, 'org', -1, 
  'equ', -1, 'end', -1, 'inca', 5, 'deca', 6, 'sz', 0x12, 'snz', 0x1a,
  "spos", 0x21, "sneg", 0x20, "qon", 0x23, "qoff", 0x22, "qtog", 0x24,
  'sub', 0x9000, 'cmp', 0x5000, 'ldi', 0x25,  
  'so', 0x0011, 'sz',0x0012, 'szo', 0x0013, 'sc', 0x0014, 'sco', 0x0015,
  'scz', 0x0016, 'sczo', 0x0017, 'sno', 0x0019, 'snz', 0x001a, 'snzo', 0x001b,
  'snc', 0x001c, 'snco', 0x001d, 'sncz', 0x001e, 'snczo', 0x001f,
  'ldax', 0xe000, 'stax', 0xf000, 'incx', 0x0030, 'decx', 0x0031,
  'stx', 0x0032, 'jmpa', 0x0033, 'swap', 0x0034, 'lds', 0xc000,
  'push', 0x0050, 'pop', 0x0040, 'ret', 0x0041, 'popx', 0x0042, 'pushx', 0x52,
  'pushf', 0x0053, 'popf', 0x0043, 'frame', 0x0008, 'rar', 0x0007, 'ldxa', 0x0009
);

%adda = ( 'dw', 1, 'hlt',0, 'nop', 0,
  'add', 1, 'and',1, 'ior',1,
  'not', 0, 'lda', 1, 'sta', 1, 'call', 1, 'jmp', 1,
  'ldx', 1, 'ral', 0, 'inca', 0, 'deca', 0,
  'sz', 0, 'snz', 0, "spos", 0, "sneg", 0, "qon", 0, "qoff", 0, "qtog", 0,
  'sub', 1, 'cmp', 1, 'ldi', 2,
  'so', 0, 'sz',0, 'szo', 0, 'sc', 0, 'sco', 0,
  'scz', 0, 'sczo', 0, 'sno', 0, 'snz', 0, 'snzo', 0,
  'snc', 0, 'snco', 0, 'sncz', 0, 'snczo', 0,
  'ldax', 1, 'stax', 1, 'incx', 0, 'decx', 0, 'stx', 0, 'jmpa', 0, 'swap', 0,
  'lds', 1, 'push', 0, 'pop', 0, 'ret', 0, 'popx', 0, 'pushx', 0, 'pushf', 0,
  'popf', 0, 'frame', 0, 'rar', 0, 'ldxa', 0 
);


floop: while (@ARGV) {
   $file=shift;
   &procfile($file);
}
print '// Symbols';
foreach $v (keys %symtab) {
    if ($v ne '_location_') { printf( "// %s: %04x\n", $v, $symtab{$v}); }
}
print '// End Symbols';


# need to localize 
# so we can call recursively (for INCLUDE)
sub procfile {
    local ($file)=@_;
    local($base);    
     unless (open(F,$file)) {  # may have to close and reopen before recurse?
     print STDERR "Can't open $file.\n";
     exit(1);
     }
    $base=$location;
line: while (<F>) {
line0:
    @lines=split(/\|/);
    foreach (@lines) {
    $f=&procline($_);
    if ($f==0) { return; }
    if ($f==2) { seek(F,0,0); next; }
}
    if (eof(F)) { 
      if ($pass==1) { 
	  print STDERR "Warning: Missing end in $file"; 
	  print "//! Warning: Missing end in $file";
      }
      $_=" END"; 
      goto line0; 
      }

    }
# the only way to get here is if no end, so warn and fake the end
#  if ($pass==1) { 
#    print STDERR "warning: Missing end in $file"; 
#    &procline(" END");
#    seek(F,0,0);
#    goto line;
#    }
#  if ($pass==2) {&procline("  END"); }
}

sub procline {
    chomp;	# strip record separator

pline:
   s/;.*$//g;

    $theLine = $_;
    if (/^[ \t]*$/) {
	return 1;
    }
    @Fld = split(' ', $_, 9999);


    $clabel = '';

    if (/^[a-zA-Z_][a-zA-Z_0-9]*[:]/) {
        $t=$Fld[1];
	$s = ':', $Fld[1] =~ s/$s//;
	$clabel = &toLOWER($Fld[1]);
	$s = $t, s/$s//g;
	$lvalue = $location;
        @Fld = split(' ', $_, 9999);
    }

# must resolve in 1st pass!
    if ($pass == 1) {
	$opcode = &toLOWER($Fld[1]);
	if ($Fld[2]!~/['"]/) { $afield = &toLOWER($Fld[2]); } 
         else {
          s/^[^'"#]*(['"#])/\1/;  # get whole string
          $afield=$_;
         }
	# we need to check for psuedo op
	# end, org, equ
	if ($opcode eq 'org') {
	    $location = &xeval($afield);
	}
# must resolve in 1st pass!
	if ($opcode eq 'equ') {
	    $lvalue = &xeval($afield);
	}
	if ($clabel =~ /^[a-zA-Z_]/ && $symtab{$clabel} ne '') {
	    print STDERR $clabel . ': Multiple definition';
	    print "//!" .  $clabel . ': Multiple definition';
	}
#	if ($lvalue eq "\$") {
#	    $lvalue = $location;
#	}
	if ($clabel =~ /^[a-zA-Z_]/) {
	    $symtab{$clabel} = $lvalue;
	}
	if ($opcode eq 'ds') {
	    &dostring($_);
	    return 1;
        }	

	if ($opcode eq 'end') {
	    foreach $c (keys %con) {
		if ($symtab{$c} eq '') {
  		  $symtab{$c} = $location;
		  $con2{$location}=$c;
		  &emit(0,-1);  #placeholder
	      }
	    }
	    $pass = 2;
	    $location = $base;
            return 2;
	}
        if ($opcode eq '') { } else {
# need to process afield in case of constant
           if ($opmap{$opcode}>=0) { $location=$location+1; &xeval($afield); }
           if ($adda{$opcode}==2) { $location=$location+1; }
        }
	return 1;  # end pass 1
    }

    if ($pass == 2) {
	$opcode = &toLOWER($Fld[1]);
 	if ($Fld[2]!~/['"]/) {
  	  $afield = &toLOWER($Fld[2]);
          }
        else { 
          s/^[^'"#]*(['"#])/\1/;  # get whole string
          $afield=$_;
          }
	$afield = &xeval($afield);
    if ($opcode eq 'org') {
        $location = &xeval($afield);
	printf("@ %03x\n",$location);
	return 1;
    }

    if ($opcode eq 'ds') {
	&dostring($_);
	return 1;
    }
	if ($opcode eq 'end') {
	    while ($con2{$location} ne '') {
		&emit($con{$con2{$location}},-1);
	    }
            $pass=1;
            close F;

              return 0;
	}
        if ($opcode ne '') {
          $v=$opmap{$opcode};
          if ($v eq "") { 
	      print STDERR ("Bad opcode $opcode"); 
	      print "//! Bad opcode $opcode";
	  }
          if ($adda{$opcode}==1) {  $v+=$afield; }
          if ($v ne -1)  { &emit($v); }
	  if ($adda{$opcode}==2) { &emit($afield,-1); }
      }
    return 1;
   } 





sub emit {
    local($n,$flag) = @_;
    if ($pass == 2) {
	if ($flag==-1) {
	    printf("%04x    // (%03x)\n",$n,$location);
	} else {
	    printf("%04x    // (%03x)%s\n",$n,$location,$theLine);	
	}
    }
    $location = $location + 1;
}


sub toLOWER {
    local ($s)=@_;
    $s=~s/([^\W0-9_])/\l$1/g; 
    return $s;
}

sub xeval {
    local ($S)=@_;
    $SERR=$S;
    $symtab{'_location_'}=$location;
# handle immediate constant '#xxx'
   if ($S=~/^#/) {
     $S=~s/#(.*)/\1/;
     $sv=&xeval($S);
     $con{"_con_" . $sv}=$sv; 
     return $symtab{"_con_" . $sv};
   }
# need to interpret string literals
    if ($S=~/'/) {
        $S=~s/'(.*)'/\$tstr="\1"/;
        eval($S);
        if (length($tstr)==1) { $S=sprintf("%d",ord($tstr)); }
        else { $S=sprintf("%d",ord(substr($tstr,1,1))*256+ord(substr($tstr,2,1))); }

    } elsif ($S=~/"/) {
        $S=~s/"(.*)"/\$tstr="\1"/;
        eval($S);
        if (length($tstr)==1) { $S=sprintf("%d",ord($tstr)); }
        else { $S=sprintf("%d",ord(substr($tstr,1,1))*256+ord(substr($tstr,2,1))); }
    } else {
        $S=~s/(^|\W)([A-zA-Z_][a-zA-Z_0-9]*)/\1\$symtab{'\2'}/g;
   }
    $rv= eval($S);
# Would like to detect undefined symbols here but tough to do
    if ($pass==2 && $rv eq "" & $S ne "") { 
       print STDERR "Undefined: " . $SERR; 
       print "//! Undefined: $SERR";
    }
    return $rv;
  }
}


sub dostring {
    local ($S)=@_;
    $S=~s/^[^'"]*(['"])/\1/;
    $type=substr($S,1,1);  # ' or "
    $S=~s/['"](.*)['"]/\$tstr="\1"/;
    eval($S);
	    $l=length($tstr);
	    $j=1;
	    if ($type eq '"') { $j=2; }
	    $tstr="$tstr ";  # space pad odd string
	    for ($i=1;$i<=$l;$i=$i+$j) {
		$c=ord(substr($tstr,$i,1));
		if ($j==2) { $c=$c*256+ord(substr($tstr,$i+1,1)); }
		&emit($c,$i==1?0:-1);
	    }
	}
