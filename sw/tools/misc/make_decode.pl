#!/usr/bin/perl -w

sub month_to_number {
  if ($_[0] eq "0") {
      $_[0] = "0";
  } elsif ($_[0] eq "1") {
      $_[0] = "1";
  } elsif ($_[0] eq "IMM3") {
      $_[0] = "???";
  } elsif ($_[0] eq "RS") {
      $_[0] = "???";
  } elsif ($_[0] eq "RD") {
      $_[0] = "???";
  } elsif ($_[0] eq "IMM4") {
      $_[0] = "????";
  } elsif ($_[0] eq "RS1") {
      $_[0] = "???";
  } elsif ($_[0] eq "RS2") {
      $_[0] = "???";
  } elsif ($_[0] eq "REL9") {
      $_[0] = "?????????";
  } elsif ($_[0] eq "REL10") {
      $_[0] = "??????????";
  } elsif ($_[0] eq "RB") {
      $_[0] = "???";
  } elsif ($_[0] eq "OFFS5") {
      $_[0] = "?????";
  } elsif ($_[0] eq "RI") {
      $_[0] = "???";
  } elsif ($_[0] eq "IMM8") {
      $_[0] = "????????";
  } else {
      printf "Bad Instruction Parameter: %s\n", $_[0];
      $_[0] = "";
  }
}

sub set_default_values {
    print "  always \@*\n";
    print "    begin\n";
    print "      enable_rd = 0;\n";
    print "      enable_imm3 = 0;\n";
    print "      enable_rs = 0;\n";
    print "      enable_imm4 = 0;\n";
    print "      enable_rs1 = 0;\n";
    print "      enable_rs2 = 0;\n";
    print "      enable_rel9 = 0;\n";
    print "      enable_rel10 = 0;\n";
    print "      enable_rb = 0;\n";
    print "      enable_offs5 = 0;\n";
    print "      enable_ri = 0;\n";
    print "      enable_imm8 = 0;\n";
    print "      ena_rd_low_byte = 0;\n";
    print "      ena_rd_high_byte = 0;\n";
    print "      ena_bra_ = 0;\n";
    print "      ena_alu_ = 0;\n";
    print "\n";
    print "      case (op_code)\n";
}


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

$i = 1;
@op_code_list = ();
set_default_values;
while (<source_file>) {
  chomp;
  s/\\$//;      # remove trailing \
  s/}$//;       # remove trailing }
  s/{.*//;      # get rid of all the lines starting with {
  s/\\\w*//g;   # get rid of all words starting with \
  s/^ *//g;     # get rid of all leading blanks
  s/'96RI/-RI/; # swap oddball minus sign format
  if ($_) {
    if (! / [01] [01] / ) {
      print "\n      // Instruction Group -- $_ \n";
    } else {
      /( [01] )/;
      $inst = index($_, $1);
      $instruction = substr($_, 0, $inst);
      $op_code = substr($_, $inst++);
      # print "Instruction Line = $_\n";
      @bit_fields = split / /, $op_code;
      shift @bit_fields;  # get rid of leading blank element
      $case_var = "";
      foreach $field (@bit_fields) {
	$case_var = $case_var . &month_to_number($field);
      }
      push @op_code_list, $case_var;
      print "\n      // Instruction = $instruction, Op Code = $op_code\n";
      print "      16'b$case_var :\n";
      print "         begin\n";
      print "           ena_bra_ = 1;\n";
      print "           ena_alu_ = 1;\n";
      if (index($instruction, "RD") != -1) {
        print "           ena_rd_low_byte = 1;\n";
        print "           ena_rd_high_byte = 1;\n";
      }
      if (index($instruction, "IMM3") != -1) {print "           enable_imm3 = 1;\n"}
      if (index($instruction, "RS") != -1) {print "           enable_rs = 1;\n"}
      if (index($instruction, "IMM4") != -1) {print "           enable_imm4 = 1;\n"}
      if (index($instruction, "RS1") != -1) {print "           enable_rs1 = 1;\n"}
      if (index($instruction, "RS2") != -1) {print "           enable_rs2 = 1;\n"}
      if (index($instruction, "REL9") != -1) {print "           enable_rel9 = 1;\n"}
      if (index($instruction, "REL10") != -1) {print "           enable_rel10 = 1;\n"}
      if (index($instruction, "RB") != -1) {print "           enable_rb = 1;\n"}
      if (index($instruction, "OFFS5") != -1) {print "           enable_offs5 = 1;\n"}
      if (index($instruction, "RI") != -1) {print "           enable_ri = 1;\n"}
      if (index($instruction, "IMM8") != -1) {print "           enable_imm8 = 1;\n"}
      print "         end\n";
      $i++;
    }
  }
}

print "      default :\n";
print "        begin\n";
print "        end\n";
print "    endcase\n";

print "    end\n";


close( source_file );
close( verilog_file );

sort @op_code_list;
foreach $item (@op_code_list) {
  print "$item\n"
}

