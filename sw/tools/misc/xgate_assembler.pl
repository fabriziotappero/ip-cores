#!/usr/bin/perl -w


sub fill_field {
  my($prototype, $data) = $_;
  my($i, $j);
  $j =  0;
  $out_field = "";
  for ($i = 0, $i <= 15, $i++) {
    if ($_[0][$i] eq "?") {
      $out_field = $_[1][$j] . $out_field;
      $j++;
    } else {
      $out_field = $_[0][$i] . $out_field;
  }
}


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
while (<source_file>) {
  chomp;
  #s/\\$//;      # remove trailing \
  #s/}$//;       # remove trailing }
  #s/{.*//;      # get rid of all the lines starting with {
  #s/\\\w*//g;   # get rid of all words starting with \
  s/;.*$//g;    # get rid of everything after ;
  s/ *$//g;     # get rid of trailing blanks
  s/^ *//g;     # get rid of all leading blanks
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
     $i++;
    }
  }
}


close( source_file );
close( verilog_file );

