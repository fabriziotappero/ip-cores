#!/usr/bin/env perl

my $indent = ' ' x 2;
my $separator = '-' x 80;

################################################################################
# Input arguments
#
use Getopt::Std;
my %opts;
getopts('hva:d:r:kz', \%opts);

die("\n".
    "Usage: $0 [options] fileSpec\n".
    "\n".
    "Options:\n".
    "${indent}-h        display this help message\n".
    "${indent}-v        verbose\n".
    "${indent}-a bitNb  the number of program address bits\n".
    "${indent}-d bitNb  the number of data bits\n".
    "${indent}-r bitNb  the number of register address bits\n".
    "${indent}-k        keep source comments in VHDL code\n".
    "${indent}-z        zero don't care bits in VHDL ROM code\n".
    "\n".
    "Assemble code to VHDL for the nanoBlaze processor.\n".
    "\n".
    "More information with: perldoc $0\n".
    "\n".
    ""
   ) if ($opts{h});

my $verbose              = $opts{v};
my $keepComments         = $opts{k};
my $zeroDontCares        = $opts{z};
my $addressBitNb         = $opts{a} || 10;
my $registerBitNb        = $opts{d} || 8;
my $registerAddressBitNb = $opts{r} || 4;

my $asmFileSpec = $ARGV[0] || 'nanoTest.asm';
my $outFileSpec = $ARGV[1] || 'rom_mapped.vhd';

#-------------------------------------------------------------------------------
# System constants
#
my $binaryOpCodeLength = 6;
my $binaryBranchLength = 5;
my $binaryBranchConditionLength = 3;

my $opCodeBaseLength = 10;
my $vhdlAddressLength = 14;

#-------------------------------------------------------------------------------
# Derived values
#
                                                                    # file specs
my $baseFileSpec = $asmFileSpec;
$baseFileSpec =~ s/\..*//i;
my $asm1FileSpec = "$baseFileSpec.asm1";        # formatted assembly code
my $asm2FileSpec = "$baseFileSpec.asm2";        # code with addresses replaced
my $vhdlFileSpec = "$baseFileSpec.vhd";
                                                            # instruction length
my $binaryOperationInstructionLength =
  $binaryOpCodeLength +
  $registerAddressBitNb +
  $registerBitNb;
my $binaryBranchInstructionLength =
  $binaryBranchLength +
  $binaryBranchConditionLength +
  $addressBitNb;
my $binaryInstructionLength = $binaryOperationInstructionLength;
if ($binaryBranchInstructionLength > $binaryInstructionLength) {
  $binaryInstructionLength = $binaryBranchInstructionLength
}
                                                      # assembler string lengths
my $registerCharNb = int( ($registerBitNb-1)/4 ) + 1;
my $addressCharNb = int( ($addressBitNb-1)/4 ) + 1;
                                                           # vhdl string lengths
my $vhdlOpCodeLength = $binaryOpCodeLength + 4;
my $opCodeTotalLength = 22 + $registerCharNb;
my $vhdlOperand1Length = $registerAddressBitNb + 3;
my $vhdlOperand2Length = $registerBitNb + 4;
if ($addressBitNb + 3 > $vhdlOperand2Length) {
  $vhdlOperand2Length = $addressBitNb + 3
}
my $vhdlTotalLength = $vhdlOpCodeLength;
$vhdlTotalLength = $vhdlTotalLength + $vhdlOperand1Length + $vhdlOperand2Length;
$vhdlTotalLength = $vhdlTotalLength + 2*2; # '& '
$vhdlTotalLength = $vhdlTotalLength + 1;   # ','

#-------------------------------------------------------------------------------
# System variables
#
my %constants = ();
my %addresses = ();

################################################################################
# Functions
#

#-------------------------------------------------------------------------------
# Find constant from "CONSTANT" statement
#
sub findNewConstant {
  my ($codeLine) = @_;

  $codeLine =~ s/CONSTANT\s+//;
  my ($name, $value) = split(/,\s*/, $codeLine);
  $value = hex($value);

  return ($name, $value);
}

#-------------------------------------------------------------------------------
# Find address from "ADDRESS" statement
#
sub findNewAddress {
  my ($codeLine) = @_;

  $codeLine =~ s/ADDRESS\s*//;
  my $address = hex($codeLine);

  return $address;
}

#-------------------------------------------------------------------------------
# Format opcodes
#
sub prettyPrint {
  my ($codeLine) = @_;

  my ($opcode, $arguments) = split(/ /, $codeLine, 2);
  $opcode = $opcode . ' ' x ($opCodeBaseLength - length($opcode));
  $arguments =~ s/,*\s+/, /;
  $codeLine = $opcode . $arguments;

  return $codeLine;
}

#-------------------------------------------------------------------------------
# Format to binary
#
sub toBinary {
  my ($operand, $bitNb) = @_;

  #$operand = sprintf("%0${bitNb}b", $operand);

  my $hexCharNb = int($bitNb/4) + 1;
  $operand = sprintf("%0${hexCharNb}X", $operand);
  $operand =~ s/0/0000/g;
  $operand =~ s/1/0001/g;
  $operand =~ s/2/0010/g;
  $operand =~ s/3/0011/g;
  $operand =~ s/4/0100/g;
  $operand =~ s/5/0101/g;
  $operand =~ s/6/0110/g;
  $operand =~ s/7/0111/g;
  $operand =~ s/8/1000/g;
  $operand =~ s/9/1001/g;
  $operand =~ s/A/1010/g;
  $operand =~ s/B/1011/g;
  $operand =~ s/C/1100/g;
  $operand =~ s/D/1101/g;
  $operand =~ s/E/1110/g;
  $operand =~ s/F/1111/g;
  $operand = substr($operand, length($operand)-$bitNb, $bitNb);

  return $operand;
}

################################################################################
# Program start
#

#-------------------------------------------------------------------------------
# Display information
#
if ($verbose > 0) {
  print "$separator\n";
  print "Assembling $asmFileSpec to $vhdlFileSpec\n";
}

#-------------------------------------------------------------------------------
# Calculate adresses, store address labels
#
if ($verbose > 0) {
  print "${indent}Pass 1: from $asmFileSpec to $asm1FileSpec\n";
}

my $romAddress = 0;
open(asm1File, ">$asm1FileSpec") or die "Unable to open file, $!";
open(asmFile, "<$asmFileSpec") or die "Unable to open file, $!";
while(my $line = <asmFile>) {
  chomp($line);
                                                        # split code and comment
  my ($codeLine, $comment) = split(/;/, $line, 2);
                                                          # handle address label
  if ($codeLine =~ m/:/) {
    (my $label, $codeLine) = split(/:/, $codeLine);
    $label =~ s/\s*//;
    print asm1File "; _${label}_:\n";
    $addresses{$label} = sprintf("%0${addressCharNb}X", $romAddress);
  }
                                                                  # cleanup code
  $codeLine =~ s/\s+/ /g;
  $codeLine =~ s/\A\s//;
  $codeLine =~ s/\s\Z//;
  $codeLine =~ s/\s,/,/;
  if ($codeLine) {
                                                    # handle ADDRESS declaration
    if ($codeLine =~ m/ADDRESS/) {
      $romAddress = findNewAddress($codeLine);
    }
                                                   # handle CONSTANT declaration
    elsif ($codeLine =~ m/CONSTANT/) {
      ($name, $value) = findNewConstant($codeLine);
      $constants{$name} = sprintf("%0${registerCharNb}X", $value);
    }
                                                         # print cleaned-up code
    else {
      $codeLine = prettyPrint($codeLine);
      print asm1File sprintf("%0${addressCharNb}X", $romAddress), ": $codeLine";
      if ($comment) {
        print asm1File " ;$comment";
      }
      print asm1File "\n";
      $romAddress = $romAddress + 1;
    }
  }
  else {
    print asm1File ";$comment\n";
  }
}
close(asmFile);
close(asm1File);

#-------------------------------------------------------------------------------
# Replace constant values and address labels
#
if ($verbose > 0) {
  print "${indent}Pass 2: from $asm1FileSpec to $asm2FileSpec\n";
}

open(asm2File, ">$asm2FileSpec") or die "Unable to open file, $!";
open(asm1File, "<$asm1FileSpec") or die "Unable to open file, $!";
while(my $line = <asm1File>) {
  chomp($line);
                                                        # split code and comment
  my ($opcode, $comment) = split(/;/, $line, 2);
  if ( ($line =~ m/;/) and ($comment eq '') ) {
    $comment = ' ';
  }
                                                                  # cleanup code
  $opcode =~ s/\s+\Z//;
                                                             # replace constants
  foreach my $name (keys %constants) {
    $opcode =~ s/$name/$constants{$name}/g;
  }
                                                             # replace addresses
  foreach my $label (keys %addresses) {
    $opcode =~ s/$label/$addresses{$label}/g;
  }
                                                                  # cleanup code
  $opcode = uc($opcode);
  $opcode =~ s/\sS([0-9A-F])/ s$1/g;
                                                         # print cleaned-up code
  if ($comment) {
    if ($opcode) {
      $opcode = $opcode . ' ' x ($opCodeTotalLength - length($opcode));
    }
    $comment =~ s/\s+\Z//;
    print asm2File "$opcode;$comment\n";
  }
  else {
    print asm2File "$opcode\n";
  }
}
close(asm1File);
close(asm2File);

#-------------------------------------------------------------------------------
# Write VHDL ROM code
#
if ($verbose > 0) {
  print "${indent}Pass 3: from $asm2FileSpec to $vhdlFileSpec\n";
}
open(vhdlFile, ">$vhdlFileSpec") or die "Unable to open file, $!";
print vhdlFile <<DONE;
ARCHITECTURE mapped OF programRom IS

  subtype opCodeType is std_ulogic_vector(5 downto 0);
  constant opLoadC   : opCodeType := "000000";
  constant opLoadR   : opCodeType := "000001";
  constant opInputC  : opCodeType := "000100";
  constant opInputR  : opCodeType := "000101";
  constant opFetchC  : opCodeType := "000110";
  constant opFetchR  : opCodeType := "000111";
  constant opAndC    : opCodeType := "001010";
  constant opAndR    : opCodeType := "001011";
  constant opOrC     : opCodeType := "001100";
  constant opOrR     : opCodeType := "001101";
  constant opXorC    : opCodeType := "001110";
  constant opXorR    : opCodeType := "001111";
  constant opTestC   : opCodeType := "010010";
  constant opTestR   : opCodeType := "010011";
  constant opCompC   : opCodeType := "010100";
  constant opCompR   : opCodeType := "010101";
  constant opAddC    : opCodeType := "011000";
  constant opAddR    : opCodeType := "011001";
  constant opAddCyC  : opCodeType := "011010";
  constant opAddCyR  : opCodeType := "011011";
  constant opSubC    : opCodeType := "011100";
  constant opSubR    : opCodeType := "011101";
  constant opSubCyC  : opCodeType := "011110";
  constant opSubCyR  : opCodeType := "011111";
  constant opShRot   : opCodeType := "100000";
  constant opOutputC : opCodeType := "101100";
  constant opOutputR : opCodeType := "101101";
  constant opStoreC  : opCodeType := "101110";
  constant opStoreR  : opCodeType := "101111";

  subtype shRotCinType is std_ulogic_vector(2 downto 0);
  constant shRotLdC : shRotCinType := "00-";
  constant shRotLdM : shRotCinType := "01-";
  constant shRotLdL : shRotCinType := "10-";
  constant shRotLd0 : shRotCinType := "110";
  constant shRotLd1 : shRotCinType := "111";

  constant registerAddressBitNb : positive := $registerAddressBitNb;
  constant shRotPadLength : positive
    := dataOut'length - opCodeType'length - registerAddressBitNb
     - 1 - shRotCinType'length;
  subtype shRotDirType is std_ulogic_vector(1+shRotPadLength-1 downto 0);
  constant shRotL : shRotDirType := (0 => '0', others => '-');
  constant shRotR : shRotDirType := (0 => '1', others => '-');

  subtype branchCodeType is std_ulogic_vector(4 downto 0);
  constant brRet  : branchCodeType := "10101";
  constant brCall : branchCodeType := "11000";
  constant brJump : branchCodeType := "11010";
  constant brReti : branchCodeType := "11100";
  constant brEni  : branchCodeType := "11110";

  subtype branchConditionType is std_ulogic_vector(2 downto 0);
  constant brDo : branchConditionType := "000";
  constant brZ  : branchConditionType := "100";
  constant brNZ : branchConditionType := "101";
  constant brC  : branchConditionType := "110";
  constant brNC : branchConditionType := "111";

  subtype memoryWordType is std_ulogic_vector(dataOut'range);
  type memoryArrayType is array (0 to 2**address'length-1) of memoryWordType;

  signal memoryArray : memoryArrayType := (
DONE
open(asm2File, "<$asm2FileSpec") or die "Unable to open file, $!";
while(my $line = <asm2File>) {
  chomp($line);
                                                        # split code and comment
  my ($opcode, $comment) = split(/;/, $line, 2);
  if ( ($line =~ m/;/) and ($comment eq '') ) {
    $comment = ' ';
  }
                                                             # addresses to VHDL
  my $address;
  if ($opcode) {
    ($address, $opcode) = split(/:\s+/, $opcode, 2);
    $address = '16#' . $address . '# =>';
    $address = ' ' x ($vhdlAddressLength - length($address)) . $address;
  }
                                                                # opcode to VHDL
  if ($opcode) {
    if ($comment eq '') {
      $comment = ' ' . $opcode;
    }
    else {
      $comment = ' ' . $opcode . ';' . $comment;
    }
                                                                   # replace NOP
    $opcode =~ s/\ANOP/LOAD s0, s0/;
                                                    # split opcodes and operands
    $opcode =~ s/\s+/ /;
    $opcode =~ s/\s+\Z//;
    ($opcode, my $operand1, my $operand2) = split(/\s/, $opcode);
    $operand1 =~ s/,//;
    $operand1 =~ s/S/s/;
    $operand2 =~ s/S/s/;
    if ( ($opcode =~ m/\ASL/) or ($opcode =~ m/\ASR/) ) {
      $operand2 = substr($opcode, 0, 3);
      $opcode = 'SHIFT';
    }
    if ( ($opcode =~ m/\ARL/)  or ($opcode =~ m/\ARR/) ) {
      $operand2 = substr($opcode, 0, 2);
      $opcode = 'ROT';
    }
    if ( ($opcode eq 'JUMP') or ($opcode eq 'CALL') or ($opcode eq 'RETURN') ) {
      unless ($operand2) {
        unless ($opcode eq 'RETURN') {
          $operand2 = $operand1;
        }
        $operand1 = 'AW'; # AlWays
      }
    }
    #...........................................................................
                                                               # opcodes to VHDL
    $opcode =~ s/LOAD/opLoadC/;
    $opcode =~ s/AND/opAndC/;
    $opcode =~ s/XOR/opXorC/;
    $opcode =~ s/ADDCY/opAddCyC/;
    $opcode =~ s/SUBCY/opSubCyC/;
    $opcode =~ s/ADD/opAddC/;
    $opcode =~ s/SUB/opSubC/;
    $opcode =~ s/SHIFT/opShRot/;
    $opcode =~ s/ROT/opShRot/;
    $opcode =~ s/COMPARE/opCompC/;
    $opcode =~ s/TEST/opTestC/;
    $opcode =~ s/FETCH/opFetchC/;
    $opcode =~ s/STORE/opStoreC/;
    $opcode =~ s/OR/opOrC/;
    $opcode =~ s/INPUT/opInputC/;
    $opcode =~ s/OUTPUT/opOutputC/;
    $opcode =~ s/JUMP/brJump/;
    $opcode =~ s/CALL/brCall/;
    $opcode =~ s/RETURN/brRet/;
    if ($operand2 =~ m/s[0-9A-F]/) {
      $opcode =~ s/C\Z/R/;
    }
    $opcode = $opcode . ' ' x ($vhdlOpCodeLength - length($opcode)) . '& ';
    #...........................................................................
                                                     # register as first operand
    if ($operand1 =~ m/s[0-9A-F]/) {
      $operand1 =~ s/\As//;
      $operand1 = '"' . toBinary($operand1, $registerAddressBitNb) . '"';
    }
                                                                # test condition
    $operand1 =~ s/NC/brNC/;
    $operand1 =~ s/NZ/brNZ/;
    $operand1 =~ s/\AC/brC/;
    $operand1 =~ s/\AZ/brZ/;
    $operand1 =~ s/AW/brDo/;
    if ($opcode =~ m/brRet/) {
      $operand2 = 0;
    }
    if ($operand2 eq '') {
      $operand1 = $operand1 . ',';
    }
    $operand1 = $operand1 . ' ' x ($vhdlOperand1Length - length($operand1));
    unless ($operand2 eq '') {
      $operand1 = $operand1 . '& ';
    }
#print "|$opcode| |$operand1| |$operand2|\n";
    #...........................................................................
                                                    # register as second operand
    $operand2 =~ s/\A\((.*)\)\Z/$1/;
    if ($operand2 =~ m/s[0-9A-F]/) {
      $operand2 =~ s/\As//;
      $operand2 = toBinary($operand2, $registerAddressBitNb);
      if ($registerBitNb > $registerAddressBitNb) {
        $operand2 = $operand2 . '-' x ($registerBitNb - $registerAddressBitNb);
        if ($zeroDontCares) {
          $operand2 =~ s/\-/0/g;
        }
      }
    }
                                                     # address as second operand
    elsif ($opcode =~ m/\Abr/) {
      my $fill = '';
      if ($binaryBranchInstructionLength < $binaryInstructionLength) {
        $fill = '-' x ($binaryInstructionLength - $binaryBranchInstructionLength);
        if ($zeroDontCares) {
          $fill =~ s/\-/0/g;
        }
      }
      if ( ($opcode =~ m/Ret/) ) {
        $operand2 = $fill . '-' x $addressBitNb;
      }
      else {
        $operand2 = $fill . toBinary(hex($operand2), $addressBitNb);
      }
    }
                                                  # shift and rotate operators
    elsif ($opcode =~ m/opShRot/) {
      $operand2 =~ s/SL0/shRotL & shRotLd0/;
      $operand2 =~ s/SL1/shRotL & shRotLd1/;
      $operand2 =~ s/SLX/shRotL & shRotLdL/;
      $operand2 =~ s/SLA/shRotL & shRotLdC/;
      $operand2 =~ s/SR0/shRotR & shRotLd0/;
      $operand2 =~ s/SR1/shRotR & shRotLd1/;
      $operand2 =~ s/SRX/shRotR & shRotLdM/;
      $operand2 =~ s/SRA/shRotR & shRotLdC/;
      $operand2 =~ s/RL/shRotL & shRotLdH/;
      $operand2 =~ s/RR/shRotR & shRotLdL/;
    }
                                                  # constant as second operand
    else {
      $operand2 = toBinary(hex($operand2), $registerBitNb);
      if ($registerAddressBitNb > $registerBitNb) {
        $operand2 = '-' x ($registerAddressBitNb - $registerBitNb) . $operand2;
      }
    }
    unless ($opcode =~ m/opShRot/) {
      $operand2 = '"' . $operand2 . '"';
    }
                                                          # add separator at end
    if ($operand2) {
      $operand2 = $operand2 . ',';
    }
    #...........................................................................
                                               # concatenate opcode and operands
    $opcode = $opcode . $operand1 . $operand2;
  }
  else {
    $address = ' ' x $vhdlAddressLength;
  }
                                                               # print VHDL code
  if ($keepComments == 0) {
    if ($opcode) {
      print vhdlFile "$address $opcode\n";
    }
  }
  else {
    $opcode = $opcode . ' ' x ($vhdlTotalLength - length($opcode));
    if ($comment) {
      $comment =~ s/\s+\Z//;
      print vhdlFile "$address $opcode--$comment\n";
    }
    else {
      print vhdlFile "$address $opcode\n";
    }
  }
}
close(asm2File);
print vhdlFile <<DONE;
    others => (others => '0')
  );

BEGIN

  process (clock)
  begin
    if rising_edge(clock) then
      if en = '1' then
        dataOut <= memoryArray(to_integer(address));
      end if;
    end if;
  end process;

END ARCHITECTURE mapped;
DONE
close(vhdlFile);

#-------------------------------------------------------------------------------
# Delete original file and copy VHDL file
#
if ($verbose > 0) {
  print "Copying $vhdlFileSpec to $outFileSpec\n";
}

use File::Copy;
unlink($outFileSpec);
copy($vhdlFileSpec, $outFileSpec) or die "File cannot be copied.";
#rename($vhdlFileSpec, $outFileSpec);

if ($verbose > 0) {
  print "$separator\n";
}
