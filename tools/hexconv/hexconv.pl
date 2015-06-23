################################################################################
# hexconv.pl -- inserts object code in HEX format into an VHDL template.
#
# This program reads an Intel HEX file with 8-bit object code and inserts it 
# into a VHDL template, in the form of a VHDL std_logic_vector array 
# initializer. This is meant to initialize FPGA ROM/RAM blocks with object code.
# When the program finds a template line which begins with "--@rom_data", it 
# replaces the whole line with the VHDL table. 
# When it finds the text @PROGNAME@ in a line, it replaces that text with the
# file name (without path or extension) of the hex file.
# Otherwise, it just copies the template to stdout verbatim.
#
# See usage details below, and examples in the BAT file in the asm directory.
################################################################################

$usage = "Use: hexconv.pl <hexfile> <template file> <start addr> <table size>";

# read command line arguments; HEX file name...
$file = shift(@ARGV);
if($file eq ''){die $usage};
# ...VHDL template file name...
$template = shift(@ARGV);
if($template eq ''){die $usage};
# ...object code start address...
$start_addr = shift(@ARGV);
if($start_addr eq ''){die $usage};
$start_addr = hex $start_addr;
# ...and VHDL table size
$table_size = shift(@ARGV);
if($table_size eq ''){die $usage};
$table_size = hex $table_size;

# read HEX file...
open(INFO, $file) or die "file $file not found";
@lines = <INFO>;
close(INFO);

# ...and VHDL template
open(INFO, $template) or die "file $template not found";
@vhdl_lines = <INFO>;
close(INFO);

$min_address = 65536;
$max_address = 0;
$bytes_read = 0;

# make up a 'ram image' table of 64K bytes where the object code will be put.
@data_array = ();
for($i=0;$i<65536;$i++){ $data_array[$i] = 0; };

# read input HEX file into ram image table
$line_no = 0;
foreach $line (@lines){
  
  chomp($line);
  $line_no++;
  
  if(length($line)>=11 and substr($line, 0, 1) eq ':'){
    $total_length = length($line);
    $len =  substr($line, 1,2);
    $addr = substr($line, 3,4);
    $type = substr($line, 7,2);
    $csum = substr($line, $total_length-3,2);
    $data = substr($line, 9,$total_length-11);
    
    # Process data records and utterly ignore all others.
    # Note that the checksum field is ignored too; we rely on the correctness
    # of the hex file.
    if($type eq '00'){
      $len = hex $len;
      $first_addr = hex $addr;
      $last_addr = $first_addr + $len - 1;
      
      if($first_addr < $min_address){
        $min_address = $first_addr;
      };
      if($last_addr > $max_address){
        $max_address = $last_addr;
      };
      
      $chksum = 0;
      for($i=0;$i<$len;$i++){
        $data_byte = substr($line, 9+$i*2, 2);
        $data_byte = hex $data_byte;
        $chksum += $data_byte;
        $data_array[$first_addr+$i] = $data_byte;
        $bytes_read++;
      }
    }
  }
  else{
    die "Wrong format in line $line_no\n";
  }
}

# Make sure all the object code we read from the hex file will fit in the VHDL
# memory; this is a typo-catcher.

if($min_address < $start_addr or $max_address < $start_addr){
  die "Hex data out of bounds";
}

$upper_bound = $start_addr + $table_size;

if($min_address > $upper_bound or 
        $max_address > $upper_bound){
  die "Hex data out of bounds: ".$upper_bound;
}

# debug output
#printf "Data address span [%04x : %04x]\n", $min_address, $max_address;
#$bytes_defaulted = ($max_address-$min_address+1)-$bytes_read;
#if($bytes_defaulted > 0){
#  printf "(%d bytes defaulted to 0)\n", $bytes_defaulted;
#}

#### Now process the template inserting the ROM bytes where necessary

# display only the template filename, cut away any path that may be present
if($template =~ /^.*[\\\/](.*\..*)/){ $template = $1; }
# put a reminder in the 1st lines of the VHDL output
$comm = "--------------------";
print $comm.$comm.$comm.$comm."\n";
print "-- Generated from template $template by hexconv.pl\n";

# Extract program name from the hex file name, stripping path and extension
if($file =~ /^.*[\\\/](.*)\..*/){ 
  $file = $1; 
}
elsif($file =~ /^(.*)\..*/){
  $file = $1;
}

# Output template file contents to stdout, line by line, inserting the object
# code when we find the 'data tag' "@rom_data".
foreach $vhdl (@vhdl_lines){
  if($vhdl =~ /^\s*--\@rom_data/){
    # if we find the ROM data tag in a comment line, replace line
    # with VHDL table.
    print_rom_code($start_addr, $table_size, @data_array);
  }
  else{
    # otherwise, output template line
    $vhdl =~ s/\@PROGNAME\@/$file/;
    printf $vhdl;
  };
}

# Prints a chunk of bytes as a VHDL table of std_logic_vectors, formatted as 
# 8 bytes per column.
#
# print_rom_code ($obj_code_table, $obj_code_start, $obj_code_size)
# $obj_code_start : address of the 1st byte that we want to put in the VHDL RAM.
# $obj_code_size : number of bytes to put in the VHDL memory.
# @obj_code_table : image of the CPU 64K memory map with the object code in it.
sub print_rom_code {
  my($obj_code_start, $obj_code_size, @obj_code_table) = @_;
  $col = 0;
  for($i=0;$i<$obj_code_size;$i++){
    $q = $obj_code_table[$obj_code_start+$i];
    print $q
    printf "X\"%02x\"", $q;
    if($i<$obj_code_size-1){
      printf ",";
    }
    $col++;
    if($col eq 8){
      print "\n";
      $col = 0;
    }
  }
}
