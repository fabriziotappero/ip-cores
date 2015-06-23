#!/usr/bin/perl -w

sub test_for_keyword {
  foreach $keyword (@instruction_keyword_list) {
    if ($_[0] eq $keyword) {
      return 1;
    }
  }
  return 0;
}

sub print_symbol_table {
  while (($key, $value) = each %symbol_table) {
    print "Symbol Name $key => $value\n";
  }
}

sub do_expression {
  print "Do Expersion input = $_[0]\n";
  @expresion = split /([()+-])/, $_[0];
  $converted = 0;
  print "Do Expression - Expresion parts are: @expresion\n";
  $i = 0;
  foreach (@expresion) {
    print "Foreach value is: $_\n";
    s/ *$//g;     # get rid of trailing blanks
    s/^ *//g;     # get rid of all leading blanks
    if (/^\$/) {
      $temp = &hex_to_num;
      $expresion[$i] = $temp;
    } elsif (/^[0-9]/) {
      $temp = &dec_to_num;
      $expresion[$i] = $temp;
    } elsif (/^[a-zA-Z_]/) {
      $temp = &symbol_to_num;
      $expresion[$i] = $temp;
    }
    print "  -- Expression part is: $expresion[$i]\n";
    $i++;
  }
  $converted = @expresion[0];
  print "Final Do Expression is: $converted, expression = @expresion\n";
  return $converted;
}

sub hex_to_num {
  my ($i, $temp, $converted);
  s/^\$//;
  $i = 1;
  @chars = split //, $_;
  @chars = reverse @chars;
  $converted = 0;
  foreach $c (@chars) {
    if ($c =~ /[A-F]/) {
      $temp = ord($c) - ord("A") + 10;
    } elsif ($c =~ /[a-f]/) {
      $temp = ord($c) - ord("a") + 10;
    } elsif ($c =~ /[0-9]/) {
      $temp = ord($c) - ord("0");
    } else {
        print "ERROR - in hex number conversion\n";
    }
    $temp = $temp * $i;
    $converted = $converted + $temp;
    $i = $i*16;
  }
  return $converted;
}

sub dec_to_num {
  my ($i, $temp, $converted);
  s/^\$//;
  $i = 1;
  @chars = split //, $_;
  @chars = reverse @chars;
  $converted = 0;
  foreach $c (@chars) {
    if ($c =~ /[0-9]/) {
      $temp = ord($c) - ord("0");
    } else {
        print "ERROR - in dec number conversion\n";
    }
    $temp = $temp * $i;
    $converted = $converted + $temp;
    $i = $i*10;
  }
  return $converted;
}

sub symbol_to_num {
  my $converted;
  print "Symbol_convert - $_\n";
  $converted = $symbol_table{$_};
  if ($converted =~ /XXX/) {
    print "ERROR - Undefined Symbol Conversion => $_/n";
  }
  return $converted;
}

sub print_memory_image {
  $j = 0;
  foreach $i (@memory_image) {
    print "Address $j => $i\n";
    $j++;
  }
}

sub reg_to_num {
  my $register = $_;
  if ($register eq "R0") {
      $register = "000";
  } elsif ($register eq "R1") {
      $register = "001";
  } elsif ($register eq "R2") {
      $register = "010";
  } elsif ($register eq "R3") {
      $register = "011";
  } elsif ($register eq "R4") {
      $register = "100";
  } elsif ($register eq "R5") {
      $register = "101";
  } elsif ($register eq "R6") {
      $register = "110";
  } elsif ($register eq "R7") {
      $register = "111";
  } else {
      printf "Bad Register Name: %s\n", $register;
      $register = "";
  }
}

sub translate_RD {
  $rd_prototype = "00000???00000000";
  &fill_field($rd_prototype, &reg_to_num($_[0]));
}

sub do_compiler_command {
  if ($white_split[0] eq "EQU") {
    shift @white_split;
    print "\nStarting EQU - Symbol = $current_symbol, @white_split\n";
    $junk_temp = &do_expression(@white_split);
    print "Ending EQU - value is $junk_temp\n\n";
    $symbol_table{$current_symbol} = $junk_temp;
  } elsif ($white_split[0] eq "ORG") {
    $program_address = $white_split[1];
    $symbol_table{$current_symbol} = $program_address;
  } elsif ($white_split[0] eq "ALIGN") {
    $program_address = $white_split[1];
    $symbol_table{$current_symbol} = $program_address;
  } elsif ($white_split[0] eq "DW") {
    $symbol_table{$current_symbol} = $program_address;
    $program_address = $program_address + 1;
  } elsif ($white_split[0] eq "DB") {
    $symbol_table{$current_symbol} = $program_address;
    $program_address++;
  } elsif ($white_split[0] eq "FCC") {
    $program_address = $white_split[1];
    $symbol_table{$current_symbol} = $program_address;
  }
}

sub do_instruction {
  if ($white_split[0] eq "BRK") {
     $protype_op_code = "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0";
     $xyzpp = "0000000000000000";

  } elsif ($white_split[0] eq "NOP") {
     $protype_op_code =  "0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0";
     $xyzpp = "0000000100000000";

  } elsif ($white_split[0] eq "RTS") {
     $protype_op_code =  "0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0";
     $xyzpp = "0000001000000000";

  } elsif ($white_split[0] eq "SIF") {
     $protype_op_code =  "0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0";
     $xyzpp = "0000001100000000";

  } elsif ($white_split[0] eq "CSEM") {
     $protype_op_code =  "0 0 0 0 0 IMM3 1 1 1 1 0 0 0 0";
     $xyzpp = "00000???11110000";

     $protype_op_code =  "0 0 0 0 0 RS 1 1 1 1 0 0 0 1";
     $xyzpp = "00000???11110001";

 } elsif ($white_split[0] eq "SSEM") {
     $protype_op_code =  "0 0 0 0 0 IMM3 1 1 1 1 0 0 1 0";
     $xyzpp = "00000???11110010";

     $protype_op_code =  "0 0 0 0 0 RS 1 1 1 1 0 0 1 1";
     $xyzpp = "00000???11110011";


  } elsif ($white_split[0] eq "SEX") {
     $protype_op_code =  "0 0 0 0 0 RD 1 1 1 1 0 1 0 0";
     $xyzpp = "00000???11110100";

  } elsif ($white_split[0] eq "PAR") {
     $protype_op_code =  "0 0 0 0 0 RD 1 1 1 1 0 1 0 1";
     $xyzpp = "00000???11110101";

  } elsif ($white_split[0] eq "JAL") {
     $protype_op_code =  "0 0 0 0 0 RD 1 1 1 1 0 1 1 0";
     $xyzpp = "00000???11110110";

  } elsif ($white_split[0] eq "SIF") {
     $protype_op_code =  "0 0 0 0 0 RS 1 1 1 1 0 1 1 1";
     $xyzpp = "00000???11110111";


  } elsif ($white_split[0] eq "TFR") {
    # RD,CCR
     $protype_op_code =  "0 0 0 0 0 RD 1 1 1 1 1 0 0 0";
     $xyzpp = "00000???11111000";

  } elsif ($white_split[0] eq "TFR") {
    # CCR,RS
     $protype_op_code =  "0 0 0 0 0 RS 1 1 1 1 1 0 0 1";
     $xyzpp = "00000???11111001";

  } elsif ($white_split[0] eq "TFR") {
    # RD,PC
     $protype_op_code =  "0 0 0 0 0 RD 1 1 1 1 1 0 1 0";
     $xyzpp = "00000???11111010";


  } elsif ($white_split[0] eq "BFFO") {
     $protype_op_code =  "0 0 0 0 1 RD RS 1 0 0 0 0";
     $xyzpp = "00001??????10000";

  } elsif ($white_split[0] eq "ASR") {
     $_ = $white_space[2];
     if (/R[0-7]/) {
       $protype_op_code =  "0 0 0 0 1 RD RS 1 0 0 0 1";
       $xyzpp = "00001??????10001";
     } else {
     $protype_op_code =  "0 0 0 0 1 RD IMM4 1 0 0 1";
     $xyzpp = "00001???????1001";
     }
  } elsif ($white_split[0] eq "CSL") {
     $protype_op_code =  "0 0 0 0 1 RD RS 1 0 0 1 0";
     $xyzpp = "00001??????10010";

     $protype_op_code =  "0 0 0 0 1 RD IMM4 1 0 1 0";
     $xyzpp = "00001???????1010";

  } elsif ($white_split[0] eq "CSR") {
     $protype_op_code =  "0 0 0 0 1 RD RS 1 0 0 1 1";
     $xyzpp = "00001??????10011";

     $protype_op_code =  "0 0 0 0 1 RD IMM4 1 0 1 1";
     $xyzpp = "00001???????1011";

  } elsif ($white_split[0] eq "LSL") {
     $protype_op_code =  "0 0 0 0 1 RD RS 1 0 1 0 0";
     $xyzpp = "00001??????10100";

     $protype_op_code =  "0 0 0 0 1 RD IMM4 1 1 0 0";
     $xyzpp = "00001???????1100";

  } elsif ($white_split[0] eq "LSR") {
     $protype_op_code =  "0 0 0 0 1 RD RS 1 0 1 0 1";
     $xyzpp = "00001??????10101";

     $protype_op_code =  "0 0 0 0 1 RD IMM4 1 1 0 1";
     $xyzpp = "00001???????1101";

  } elsif ($white_split[0] eq "ROL") {
     $protype_op_code =  "0 0 0 0 1 RD RS 1 0 1 1 0";
     $xyzpp = "00001??????10110";

     $protype_op_code =  "0 0 0 0 1 RD IMM4 1 1 1 0";
     $xyzpp = "00001???????1110";

  } elsif ($white_split[0] eq "ROR") {
     $protype_op_code =  "0 0 0 0 1 RD RS 1 0 1 1 1";
     $xyzpp = "00001??????10111";

     $protype_op_code =  "0 0 0 0 1 RD IMM4 1 1 1 1";
     $xyzpp = "00001???????1111";

  } elsif ($white_split[0] eq "AND") {
     $protype_op_code =  "0 0 0 1 0 RD RS1 RS2 0 0";
     $xyzpp = "00010?????????00";

  } elsif ($white_split[0] eq "OR") {
     $protype_op_code =  "0 0 0 1 0 RD RS1 RS2 1 0";
     $xyzpp = "00010?????????10";

  } elsif ($white_split[0] eq "XNOR") {
     $protype_op_code =  "0 0 0 1 0 RD RS1 RS2 1 1";
     $xyzpp = "00010?????????11";

  } elsif ($white_split[0] eq "SUB") {
     $protype_op_code =  "0 0 0 1 1 RD RS1 RS2 0 0";
     $xyzpp = "00011?????????00";

  } elsif ($white_split[0] eq "SBC") {
     $protype_op_code =  "0 0 0 1 1 RD RS1 RS2 0 1";
     $xyzpp = "00011?????????01";

  } elsif ($white_split[0] eq "ADD") {
     $protype_op_code =  "0 0 0 1 1 RD RS1 RS2 1 0";
     $xyzpp = "00011?????????10";

  } elsif ($white_split[0] eq "ADC") {
     $protype_op_code =  "0 0 0 1 1 RD RS1 RS2 1 1";
     $xyzpp = "00011?????????11";


  } elsif ($white_split[0] eq "BCC") {
     $protype_op_code =  "0 0 1 0 0 0 0 REL9";
     $xyzpp = "0010000?????????";

  } elsif ($white_split[0] eq "BCS") {
     $protype_op_code =  "0 0 1 0 0 0 1 REL9";
     $xyzpp = "0010001?????????";

  } elsif ($white_split[0] eq "BNE") {
     $protype_op_code =  "0 0 1 0 0 1 0 REL9";
     $xyzpp = "0010010?????????";

  } elsif ($white_split[0] eq "BEQ") {
     $protype_op_code =  "0 0 1 0 0 1 1 REL9";
     $xyzpp = "0010011?????????";

  } elsif ($white_split[0] eq "BPL") {
     $protype_op_code =  "0 0 1 0 1 0 0 REL9";
     $xyzpp = "0010100?????????";

  } elsif ($white_split[0] eq "BMI") {
     $protype_op_code =  "0 0 1 0 1 0 1 REL9";
     $xyzpp = "0010101?????????";

  } elsif ($white_split[0] eq "BVC") {
     $protype_op_code =  "0 0 1 0 1 1 0 REL9";
     $xyzpp = "0010110?????????";

  } elsif ($white_split[0] eq "BVS") {
     $protype_op_code =  "0 0 1 0 1 1 1 REL9";
     $xyzpp = "0010111?????????";

  } elsif ($white_split[0] eq "BHI") {
     $protype_op_code =  "0 0 1 1 0 0 0 REL9";
     $xyzpp = "0011000?????????";

  } elsif ($white_split[0] eq "BLS") {
     $protype_op_code =  "0 0 1 1 0 0 1 REL9";
     $xyzpp = "0011001?????????";

  } elsif ($white_split[0] eq "BGE") {
     $protype_op_code =  "0 0 1 1 0 1 0 REL9";
     $xyzpp = "0011010?????????";

  } elsif ($white_split[0] eq "BLT") {
     $protype_op_code =  "0 0 1 1 0 1 1 REL9";
     $xyzpp = "0011011?????????";

  } elsif ($white_split[0] eq "BGT") {
     $protype_op_code =  "0 0 1 1 1 0 0 REL9";
     $xyzpp = "0011100?????????";

  } elsif ($white_split[0] eq "BLE") {
     $protype_op_code =  "0 0 1 1 1 0 1 REL9";
     $xyzpp = "0011101?????????";

  } elsif ($white_split[0] eq "BRA") {
     $protype_op_code =  "0 0 1 1 1 1 REL10";
     $xyzpp = "001111??????????";


  } elsif ($white_split[0] eq "LDB") {
     $_ = $white_space[3];
     if (/\#/) {
       $protype_op_code =  "0 1 0 0 0 RD RB #OFFS5";
       $xyzpp = "01000???????????";
     }
     $protype_op_code =  "0 1 1 0 0 RD RB RI 0 0";
     $xyzpp = "01100?????????00";

     $protype_op_code =  "0 1 1 0 0 RD RB RI+ 0 1";
     $xyzpp = "01100?????????01";

     $protype_op_code =  "0 1 1 0 0 RD RB -RI 1 0";
     $xyzpp = "01100?????????10";

  } elsif ($white_split[0] eq "LDW") {
     $protype_op_code =  "0 1 0 0 1 RD RB #OFFS5";
     $xyzpp = "01001???????????";

     $protype_op_code =  "0 1 1 0 1 RD RB RI 0 0";
     $xyzpp = "01101?????????00";

     $protype_op_code =  "0 1 1 0 1 RD RB RI+ 0 1";
     $xyzpp = "01101?????????01";

     $protype_op_code =  "0 1 1 0 1 RD RB -RI 1 0";
     $xyzpp = "01101?????????10";

  } elsif ($white_split[0] eq "STB") {
     $protype_op_code =  "0 1 0 1 0 RS RB #OFFS5";
     $xyzpp = "01010???????????";

     $protype_op_code =  "0 1 1 1 0 RS RB RI 0 0";
     $xyzpp = "01110?????????00";

     $protype_op_code =  "0 1 1 1 0 RS RB RI+ 0 1";
     $xyzpp = "01110?????????01";

     $protype_op_code =  "0 1 1 1 0 RS RB -RI 1 0";
     $xyzpp = "01110?????????10";

  } elsif ($white_split[0] eq "STW") {
     $protype_op_code =  "0 1 0 1 1 RS RB #OFFS5";
     $xyzpp = "01011???????????";

     $protype_op_code =  "0 1 1 1 1 RS RB RI 0 0";
     $xyzpp = "01111?????????00";

     $protype_op_code =  "0 1 1 1 1 RS RB RI+ 0 1";
     $xyzpp = "01111?????????01";

     $protype_op_code =  "0 1 1 1 1 RS RB -RI 1 0";
     $xyzpp = "01111?????????10";


  } elsif ($white_split[0] eq "BFEXT") {
     $protype_op_code =  "0 1 1 0 0 RD RS1 RS2 1 1";
     $xyzpp = "01100?????????11";

  } elsif ($white_split[0] eq "BFINS") {
     $protype_op_code =  "0 1 1 0 1 RD RS1 RS2 1 1";
     $xyzpp = "01101?????????11";

  } elsif ($white_split[0] eq "BFINSI") {
     $protype_op_code =  "0 1 1 1 0 RD RS1 RS2 1 1";
     $xyzpp = "01110?????????11";

  } elsif ($white_split[0] eq "BFINSX") {
     $protype_op_code =  "0 1 1 1 1 RD RS1 RS2 1 1";
     $xyzpp = "01111?????????11";


  } elsif ($white_split[0] eq "ANDL") {
     $protype_op_code =  "1 0 0 0 0 RD IMM8";
     $xyzpp = "10000???????????";

  } elsif ($white_split[0] eq "ANDH") {
     $protype_op_code =  "1 0 0 0 1 RD IMM8";
     $xyzpp = "10001???????????";

  } elsif ($white_split[0] eq "BITL") {
     $protype_op_code =  "1 0 0 1 0 RD IMM8";
     $xyzpp = "10010???????????";

  } elsif ($white_split[0] eq "BITH") {
     $protype_op_code =  "1 0 0 1 1 RD IMM8";
     $xyzpp = "10011???????????";

  } elsif ($white_split[0] eq "ORL") {
     $protype_op_code =  "1 0 1 0 0 RD IMM8";
     $xyzpp = "10100???????????";

  } elsif ($white_split[0] eq "ORH") {
     $protype_op_code =  "1 0 1 0 1 RD IMM8";
     $xyzpp = "10101???????????";

  } elsif ($white_split[0] eq "XNORL") {
     $protype_op_code =  "1 0 1 1 0 RD IMM8";
     $xyzpp = "10110???????????";

  } elsif ($white_split[0] eq "XNORH") {
     $protype_op_code =  "1 0 1 1 1 RD IMM8";
     $xyzpp = "10111???????????";


  } elsif ($white_split[0] eq "SUBL") {
     $protype_op_code =  "1 1 0 0 0 RD IMM8";
     $xyzpp = "11000???????????";

  } elsif ($white_split[0] eq "SUBH") {
     $protype_op_code =  "1 1 0 0 1 RD IMM8";
     $xyzpp = "11001???????????";

  } elsif ($white_split[0] eq "CMPL") {
     $protype_op_code =  "1 1 0 1 0 RS IMM8";
     $xyzpp = "11010???????????";

  } elsif ($white_split[0] eq "CPCH") {
     $protype_op_code =  "1 1 0 1 1 RS IMM8";
     $xyzpp = "11011???????????";

  } elsif ($white_split[0] eq "ADDL") {
     $protype_op_code =  "1 1 1 0 0 RD IMM8";
     $xyzpp = "11100???????????";

  } elsif ($white_split[0] eq "ADDH") {
     $protype_op_code =  "1 1 1 0 1 RD IMM8";
     $xyzpp = "11101???????????";

  } elsif ($white_split[0] eq "LDL") {
     $protype_op_code =  "1 1 1 1 0 RD IMM8";
     $xyzpp = "11110???????????";

  } elsif ($white_split[0] eq "LDH") {
     $protype_op_code =  "1 1 1 1 1 RD IMM8";
     $xyzpp = "11111???????????";
  }

  $memory_image[$program_address] = $xyzpp;
  $program_address = $program_address + 1;
}

################################################################################
# Main
################################################################################

if( @ARGV < 1 ) {
  $progname = `basename $0`;
  chomp($progname);
  print "Syntax: $progname <Infile> <Outfile>\n";
  die;
} elsif ( @ARGV < 2 ) {
  print "Using default output file \"temp.v\"\n";
  $Infile = shift @ARGV;
  $Outfile = 'temp.v';
} else {
  $Infile = shift @ARGV;
  $Outfile = shift @ARGV;
}

open( source_file,  "<$Infile" )  || die "Could not open Input file";
open( verilog_file, ">$Outfile" ) || die "Could not open Output file";

$source_line_number = 1;
$program_address = 0;
$cpu_type = "";
@memory_image = "";
@instruction_keyword_list = qw/ CPU ALIGN ORG EQU DW DB FCC /;
push @instruction_keyword_list, qw/ BRK NOP RTS SIF CSEM SSEM SEX PAR /;
push @instruction_keyword_list, qw/ JAL SIF TFR BFFO ASR CSL CSR LSL LSR /;
push @instruction_keyword_list, qw/ ROL ROR AND OR XNOR SUB SBC ADD BCC BCS /;
push @instruction_keyword_list, qw/ BNE BEQ BPL BMI BVC BVS BHI BLS BGE BLT /;
push @instruction_keyword_list, qw/ BGT BLE BRA LDB LDW STB STW BFEXT BFINS /;
push @instruction_keyword_list, qw/ BFINSI BFINSX ANDL ANDH BITL BITH ORL /;
push @instruction_keyword_list, qw/ ORH XNORL XNORH SUBL SUBH CMPL CPCH /;
push @instruction_keyword_list, qw/ ADDL ADDH LDL LDH /;

while (<source_file>) {
  chomp;
  s/;.*$//g;    # get rid of everything after ;
  s/ *$//g;     # get rid of trailing blanks
  s/^ *//g;     # get rid of all leading blanks
  if ($_) {
    print "Instruction Line = $_  number = $source_line_number\n";
    #@white_split = split; # Breakout fields on white space
    @white_split = split /\s+|,/; # Breakout fields on white space or ,
    $i = 0;
    foreach (@white_split) {
      s/\(R/R/;                   # Remove leading "(" if it is part of Register name
      s/\)\)/\)/;                 # Take of one of ")" of double "))"
      if (/^\$/) {                # Take care of the simple case of a hex number
        $white_split[$i] = &hex_to_num($white_split[$i]);
      }
      if (/^[0-9]/) {             # Take care of the simple case of a dec number
        $white_split[$i] = &dec_to_num($white_split[$i]);
      }
      $i++;
    }
    if (! &test_for_keyword($white_split[0])) {  # Line starts with a symbol name
      $current_symbol = $white_split[0];
      if ($symbol_table{$current_symbol}) {
        print "Error Reused Symbol - $current_symbol - Source Line Number $source_line_number\n";
      } else {
        $symbol_table{$current_symbol} = "XXX"; # initilize to junk
      }
      shift @white_split;
    }
    if (! @white_split) {  # The only thing in the line was a symbol
      $symbol_table{$current_symbol} = $program_address;
    } else {
      &do_compiler_command(@white_split);
      &do_instruction;
    }
  }
  $source_line_number++;
}

&print_symbol_table;
&print_memory_image;

close( source_file );
close( verilog_file );

