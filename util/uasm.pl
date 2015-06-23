################################################################################
# uasm.pl : light8080 core microcode assembler
################################################################################
# Usage: perl uasm.pl <microcode file name> <command list>
# 
# The command list is a space-separated sequence of the following:
#
# -lst      : Shows a listing of the assembled microinstructions next to their
#             assembler source lines. Not very useful because it does not show 
#             assembler pragma, label or comment lines.
# -labels   : Shows a list of all defined labels with their address and the 
#             number of times they are used.
# -bitfields: Shows a list of all the different microinstructions generated, 
#             plus the number of times they are used. Might be useful to encode
#             the microinstructions and save rom bits.
# -instructions: Shows a list of all defined instructions with the address their
#             microcode starts at.
# -rom_bin  : Shows a raw list of all the binary microinstructions.
# -rom_vhdl : Shows a vhdl block containing the microcode rom declaration.
#
# If none of the above commands is given, the program just exits silently. Any 
# unrecognized command is silently ignored.
################################################################################
# Assembler format (informal definition, source is the ultimate reference!):
#
#<microinstruction line> := 
#    [<label>] | (*1)
#    <operand stage control> ; <ALU stage control> [; [<flag list>]] |
#    JSR <destination address>|TJSR <destination address>
#
#<label> := {':' immediately followed by a common identifier}
#<destination address> := {an identifier defined as label anywhere in the file}
#<operand stage control> :=  <op_reg> = <op_src> | NOP
#<op_reg> := T1 | T2
#<op_src> := <register> | DI | <IR register>
#<IR register> := {s}|{d}|{p}0|{p}1 (*3)
#<register> := _a|_b|_c|_d|_e|_h|_l|_f|_a|_ph|_pl|_x|_y|_z|_w|_sh|_sl|
#<ALU stage control> := <alu_dst> = <alu_op> | NOP 
#<alu_dst> := <register> | DO
#<alu_op> := add|adc|sub|sbb| and|orl|not|xrl| rla|rra|rlca|rrca| aaa|
#            t1|rst|daa|cpc|sec|psw
#<flag list> := <flag> [, <flag> ...] 
#<flag> := #decode|#di|#ei|#io|#auxcy|#clrt1|#halt|#end|#ret|#rd|#wr|#setacy 
#          #ld_al|#ld_addr|#fp_c|#fp_r|#fp_rc|#clr_cy_ac  (*2)
#
#  *1 Labels appear alone by themselves in a line
#  *2 There are some restrictions on the flags that can be used together
#  *3 Registers are specified by IR field
#
################################################################################
# ALU operations 
#
#Operation      Encoding    ALU result
#===============================================================================
#ADD            001100      T2 + T1
#ADC            001101      T2 + T1 + CY
#SUB            001110      T2 - T1
#SBB            001111      T2 – T1 - CY
#AND            000100      T1 AND T2
#ORL            000101      T1 OR T2
#NOT            000110      NOT T1 
#XRL            000111      T1 XOR T2
#RLA            000000      8080 RLC
#RRA            000001      8080 RRC
#RLCA           000010      8080 RAL
#RRCA           000011      8080 RAR
#T1             010111      T1
#RST            011111      8*IR(5..3), as per RST instruction
#DAA            101000      DAA T1 (but only after executing 2 in a row)
#CPC            101100      UNDEFINED     (CY complemented)
#SEC            101101      UNDEFINED     (CY set)
################################################################################
# Flags :
# --- Flags from group 1: use only one of these
# #decode :  Load address counter and IR with contents of data input lines,
#            thus starting opcode decoging.
# #ei :      Set interrupt enable register.
# #di :      Reset interrupt enable register.
# #io :      Activate io signal for 1st cycle.
# #auxcy :   Use aux carry instead of regular carry for this operation. 
# #clrt1 :   Clear T1 at the end of 1st cycle.
# #halt :    Jump to microcode address 0x07 without saving return value.
# 
# --- Flags from group 2: use only one of these
# #setacy :  Set aux carry at the start of 1st cycle (used for ++).
# #end :     Jump to microinstruction address 3 after the present m.i.
# #ret :     Jump to address saved by the last JST or TJSR m.i.
# #rd :      Activate rd signal for the 2nd cycle.
# #wr :      Activate wr signal for the 2nd cycle.
# --- Independent flags: no restrictions
# #ld_al :   Load AL register with register bank output as read by operation 1.
#            (used in memory and io access). 
# #ld_addr : Load address register (H byte = register bank output as read by 
#            operation 1, L byte = AL). 
#            Activate vma signal for 1st cycle.
# #clr_acy : Instruction clears CY and AC flags. Use with #fp_rc.
# --- PSW update flags: use only one of these
# #fp_r :    This instruction updates all PSW flags except for C.
# #fp_c :    This instruction updates only the C flag in the PSW.
# #fp_rc :   This instruction updates all the flags in the PSW.
################################################################################
# Read the design notes for a brief reference to the micromachine internal
# behavior, including implicit loads/erases.
################################################################################

$file = shift(@ARGV);

open(INFO, $file) or die "unable to open file '$file'\n";
@lines = <INFO>;
close(INFO);

$field2_nop = '0'.'0000'.'00'.'0'.'0'.'000000';
$field2_jsr = '0'.'0000'.'00'.'0'.'0'.'000000';

%field1_ops = 
  ( 'nop',        '000'.'000'.'00000'.'00'.'0000'.$field2_nop,
    'jsr',        '000'.'010'.'00000'.'00'.'0000'.$field2_jsr,
    'tjsr',       '000'.'100'.'00000'.'00'.'0000'.$field2_jsr,
     
    't1 = {s}',   '000'.'000'.'00101'.'01'.'0000'.$field2_nop,
    't1 = {d}',   '000'.'000'.'00101'.'10'.'0000'.$field2_nop,
    't1 = {p}0',  '000'.'000'.'00101'.'11'.'0000'.$field2_nop,
    't1 = {p}1',  '000'.'000'.'00101'.'11'.'0001'.$field2_nop,
    't1 = di',    '000'.'000'.'00100'.'00'.'0000'.$field2_nop,
    't1 = _b',    '000'.'000'.'00101'.'00'.'0000'.$field2_nop,
    't1 = _c',    '000'.'000'.'00101'.'00'.'0001'.$field2_nop,
    't1 = _d',    '000'.'000'.'00101'.'00'.'0010'.$field2_nop,
    't1 = _e',    '000'.'000'.'00101'.'00'.'0011'.$field2_nop,
    't1 = _h',    '000'.'000'.'00101'.'00'.'0100'.$field2_nop,
    't1 = _l',    '000'.'000'.'00101'.'00'.'0101'.$field2_nop,
    't1 = _a',    '000'.'000'.'00101'.'00'.'0111'.$field2_nop,
    't1 = _f',    '000'.'000'.'00101'.'00'.'0110'.$field2_nop,
    't1 = _ph',   '000'.'000'.'00101'.'00'.'1000'.$field2_nop,
    't1 = _pl',   '000'.'000'.'00101'.'00'.'1001'.$field2_nop,
    't1 = _x',    '000'.'000'.'00101'.'00'.'1010'.$field2_nop,
    't1 = _y',    '000'.'000'.'00101'.'00'.'1011'.$field2_nop,
    't1 = _z',    '000'.'000'.'00101'.'00'.'1100'.$field2_nop,
    't1 = _w',    '000'.'000'.'00101'.'00'.'1101'.$field2_nop,
    't1 = _sh',   '000'.'000'.'00101'.'00'.'1110'.$field2_nop,
    't1 = _sl',   '000'.'000'.'00101'.'00'.'1111'.$field2_nop,

    't2 = {s}',   '000'.'000'.'00011'.'01'.'0000'.$field2_nop,
    't2 = {d}',   '000'.'000'.'00011'.'10'.'0000'.$field2_nop,
    't2 = {p}0',  '000'.'000'.'00011'.'11'.'0000'.$field2_nop,
    't2 = {p}1',  '000'.'000'.'00011'.'11'.'0001'.$field2_nop,
    't2 = di',    '000'.'000'.'00010'.'00'.'0000'.$field2_nop,
    't2 = _b',    '000'.'000'.'00011'.'00'.'0000'.$field2_nop,
    't2 = _c',    '000'.'000'.'00011'.'00'.'0001'.$field2_nop,
    't2 = _d',    '000'.'000'.'00011'.'00'.'0010'.$field2_nop,
    't2 = _e',    '000'.'000'.'00011'.'00'.'0011'.$field2_nop,
    't2 = _h',    '000'.'000'.'00011'.'00'.'0100'.$field2_nop,
    't2 = _l',    '000'.'000'.'00011'.'00'.'0101'.$field2_nop,
    't2 = _a',    '000'.'000'.'00011'.'00'.'0111'.$field2_nop,
    't2 = _f',    '000'.'000'.'00011'.'00'.'0110'.$field2_nop,
    't2 = _ph',   '000'.'000'.'00011'.'00'.'1000'.$field2_nop,
    't2 = _pl',   '000'.'000'.'00011'.'00'.'1001'.$field2_nop,
    't2 = _x',    '000'.'000'.'00011'.'00'.'1010'.$field2_nop,
    't2 = _y',    '000'.'000'.'00011'.'00'.'1011'.$field2_nop,
    't2 = _z',    '000'.'000'.'00011'.'00'.'1100'.$field2_nop,
    't2 = _w',    '000'.'000'.'00011'.'00'.'1101'.$field2_nop,
    't2 = _sh',   '000'.'000'.'00011'.'00'.'1110'.$field2_nop,
    't2 = _sl',   '000'.'000'.'00011'.'00'.'1111'.$field2_nop
    
  );


$re_field1 = "(".join('|',keys %field1_ops).")";
$re_field1 =~ s/\[/\\\[/g;
$re_field1 =~ s/\]/\\\]/g;

%field2_ops = 
  ( 'add',    '001100',
    'adc',    '001101',
    'sub',    '001110',
    'sbb',    '001111',  
    
    'and',    '000100',
    'orl',    '000110',
    'not',    '000111',
    'xrl',    '000101',
    
    'rla',    '000000',
    'rra',    '000001',
    'rlca',   '000010',
    'rrca',   '000011',
    
    'aaa',    '111000',
    
    't1',     '010111',
    'rst',    '011111',
    'daa',    '101000',
    'cpc',    '101100',
    'sec',    '101101',
    'psw',    '110000'   
  );


$re_f2_ops = "(".join('|',keys %field2_ops).")";
$re_f2_ops =~ s/\[/\\\[/g;
$re_f2_ops =~ s/\]/\\\]/g;

# 'parse' command line flags into a string
$cmdline = join ':', @ARGV;

$num_line = 0;
$addr = 0;

%labels = ();                 # <label, address>
@label_uses = ();             # <label, [addresses in which it's used]>
@undefined_targets = ();      # array of <label, address in which it's used>
$num_errors = 0;

@bitfields = ();

@rom = ();
@asm = ();
@errors = ();
@num_lines = ();

%asm_to_uaddr = ();           # opcode asm -> uaddress
%uaddr_to_asm = ();           # uaddress -> opcode asm

%uaddr_to_pattern = ();       # uaddress -> pattern
%pattern_to_uaddr = ();       # pattern -> uaddress -- simulation, decoder

LINE: foreach $line (@lines) {

  $num_line++;
  
  $line =~ tr/A-Z/a-z/;
  $line =~ s/(--|\/\/).*//;
  $line =~ s/^\s*//g;
  $line =~ s/\s*\$//g;
  chomp($line);

  $uinst = {
    field_1 => '',
    src     => '',
    special => '',
    field_2 => '',
    field_0 => '000000',
    flags   => '',
    error   => '',
    asm     => $line
  };


  # if line is whitespace or comment (which has been changed to whitespace)
  # then skip to next line
  if($line eq ''){
    next;
  }

  # if $line is a label declaration, get it and skip to next line
  # note labels come alone in the line, unlike other assemblers
  # TODO it'd be simple to change this...
  if($line =~ /^\s*:(\w+)/){
    # subroutine label (labels are only used for jsrs)
    $labels{$1} = $addr;
    next;
  }

  # if line is a pragma, process it
  if($line =~ /^\s*__/){
    # TODO process pragmas __reset, __fetch, __int
    
    #if($line =~ /^\s*__code\s+"([0|1|s|d|p|a|r]+)"/){
      # we do nothing with the opcode byte; it's for reference only
      #printf "%04d # %s\n",$addr,$1;
    #}
    if($line =~ /^\s*__asm\s+(.*)/){      
      # save the start address for the CPU instruction
      # it will be used in the design of the decoder
      $asm_to_uaddr{$1} = $addr;
      $uaddr_to_asm{$addr} = $1;
    }
    
    if($line =~ /^\s*__code\s+"(.*)".*/){      
      # save the start address for the CPU instruction
      # it will be used in the design of the decoder
      $pattern_to_uaddr{$1} = $addr;
      $uaddr_to_pattern{$addr} = $1;
    }
    
    
    next;
  }

  # get flags field (all text following 1st '#' included)
  # remove it so we're left with 'field1 ; field2 [;]'
  $line = process_flags($line);  
  
  # break line in 1 or 2 fields
  @fields = split /;/, $line;

  # process 1st field...
  $done = process_field1($fields[0]);
  
  # ...and process 2nd field if there is one (depends on field1 format)
  # TODO check that there's no field2 when there shouldn't  
  if($done != 1){
    $done = process_field2($fields[1]);
  }  

  # finally, process extra flags produced by field1 assembly (jsr/tjsr)
  process_extra_flags();  

  # complete bitfield with flags...
  substr($uinst->{field1}, 0, 6) = $uinst->{field_0};

  # Now, we already have the bitfields.
  
  push(@rom, $uinst->{field1});
  push(@asm, substr($line,0,40));
  push(@num_lines, $num_line);
  if($uinst->{error} eq ''){
    push(@errors, '');
  }
  else{
    push(@errors, $uinst->{error});
  }  
  
  $addr++;  #addr++ even for error uinsts

}
continue {
}

# Line processing finished (1st pass). Start 2nd pass and do listings 
# if requested

# 2nd pass

# now we know the value of all labels, fill in address field of forward jumps
foreach $target (@undefined_targets){
  @item = @{$target};
  $value = to_bin($labels{$item[0]}, 8);
  $adr = $item[1]*1;
  
  substr($rom[$adr], 20,2, substr($value, 0,2));
  substr($rom[$adr], 26,6, substr($value, 2,6));
}

foreach $bf (@rom){
  push(@bitfields, $bf);
}

# listings

if($cmdline =~ /-lst/){
  $do_lst = 1;
}

$i = 0;
foreach $bf (@rom){
  if($do_lst){
    printf "%02x %32s :: %s\n", $i,  $bf, $asm[$i];
    if($errors[$i] ne ''){
      printf "     ERROR (%d): %s\n", $num_lines[$i], $errors[$i];
    }
  }
  
  $i++;
}

if($do_lst){
  # completion message
  printf "\nDone. %d uinsts, %d errors.\n", $addr, $num_errors;
}

# label listing
if($cmdline =~ /\-labels/){
  label_list();
}

# bitfield histogram
if($cmdline =~ /\-bitfields/){
  bitfield_histogram();
}

# show cpu instruction microcode addresses
if($cmdline =~ /\-instructions/){
  foreach $asm (sort {$asm_to_uaddr{$a} <=> $asm_to_uaddr{$b}}(keys %asm_to_uaddr)){
    $uaddress = $asm_to_uaddr{$asm};
    printf "%02x %s  %s\n", $uaddress, $uaddr_to_pattern{$uaddress}, $asm;
  }
}

if($cmdline =~ /\-rom_vhdl/){
  show_decoder_table('vhdl');
}

if($cmdline =~ /\-rom_bin/){
  show_decoder_table('bin');
}

# end of main program


################################################################################


sub show_decoder_table {
  
  my $fmat = shift(@_);
  
  # show decoder rom contents
  %decoder_hash = ();
  foreach $pat (keys %pattern_to_uaddr){
    $add = $pattern_to_uaddr{$pat};
    $pat =~ s/[a-z]/\[01\]/g;
    $decoder_hash{$pat} = $add;
  }
  
  @decoder_rom = ();
  for($i = 0; $i<256; $i++){
    $b = to_bin($i, 8);
    $val = 0;
    # We'll match the opcode to the pattern with the shortest length; that is,
    # the one with the less wildcards in it. Crude but effective in this case.
    $len_matched_pat = 1000;
    foreach $pat (keys %decoder_hash){
      if($b =~ /$pat/){
        if(length($pat) < $len_matched_pat){
          $val = $decoder_hash{$pat};
          $len_matched_pat = length($pat);
        }
        #last;
      }         
    }
    push @decoder_rom, $val;
  }

  if($fmat eq 'vhdl'){
    # print rom vhdl header...
    print "type t_rom is array (0 to 511) of std_logic_vector(31 downto 0);\n";
    print "signal rom : t_rom := (\n";
  } 

  # The 1st half of the uinst rom holds 256 uinstructions
  my $i=0;
  foreach $bf (@rom){
    if($fmat eq 'vhdl'){
      printf "\"%s\", -- %03x\n", $bf, $i;
    }
    else{
      printf "%s\n", $bf;
    }
    $i++;
  }
  # Fill remaining slots with ENDs 
  for(;$i<256;$i++){
    my $val = '00000100000000000000000000000000';
    if($fmat eq 'vhdl'){
      printf "\"%s\", -- %03x\n", $val, $i;
    }
    else{
       printf "%s\n", $val;
    }
  }

  # The 2nd half (upper 256 entries) of the ucode rom contains a jump table
  # with a jsr for each of the 256 opcodes, serving as cheap decoder:
  foreach $entry (@decoder_rom){
    my $val = to_bin($entry, 8);
    $val = '00001000000000000000'.substr($val,0,2).'0000'.substr($val,2,6);
    $i++;
    if($fmat eq 'vhdl'){
      printf "\"%s\"", $val;
      if($i<512){
        print ",";
      }
      else{
        print " ";
      }
      printf " -- %03x\n", ($i - 1);
    }
    else{
      printf "%s\n", $val;
    }
  }

  if($fmat eq 'vhdl'){
    # close vhdl declaration
    print "\n);\n";
  }

}

sub label_list {
  # label table listing 
  print "\nlabels:\n";
  print "---------------------------------\n";
  print "label                addr    uses\n";
  print "---------------------------------\n";
  
  %hist_labels;
  $hist_labels{$_}++ for @label_uses;
  
  foreach $label (keys %hist_labels){
    printf "%-20s %04x    %d\n", $label, $labels{$label}, $hist_labels{$label};
  }
}

sub bitfield_histogram {
  
  %hist_bitfields;
  $hist_bitfields{$_}++ for @bitfields;
  @unique_bitfields = keys %hist_bitfields;
  
  printf "\nbitfield usage (total: %d)\n", $#unique_bitfields;
  print "------------------------------------------------\n";
  print "bitfield                            uses\n";
  print "------------------------------------------------\n";
  
  foreach $bfield (sort sortFieldsByFrequency(keys %hist_bitfields)){
    printf "%-32s    %d\n", $bfield, $hist_bitfields{$bfield};
  }
}

sub sortFieldsByFrequency {
   $hist_bitfields{$b} <=> $hist_bitfields{$a};
}

sub process_extra_flags {
  
  $flags1 = '';
  $flags2 = '';

  
  # first, process flags produced by 1st field processing
  if($uinst->{flags} =~ /#jsr/){
    if($flags2 ne ''){$error = 'incompatible flags'};
    $flags2 = '010';
  }
  if($uinst->{flags} =~ /#tjsr/){
    if($flags2 ne ''){$error = 'incompatible flags'};
    $flags2 = '100';
  }
  
  $provisional_flags2 = substr($uinst->{field_0},3,3);
  if($flags2 ne ''){
    if($provisional_flags2 ne '000'){
      $error = "flags incompatible with jsr/tjsr operation: "
                                                      .$provisional_flags2;
      $num_errors++;                                                      
      $uinst->{error} = $error;
    }
    else{
      substr($uinst->{field_0},3,3) = $flags2;
    }
  }

  if($uinst->{flags} =~ /#ld_al/){
    substr($uinst->{field1},7,1) = '1';
  }
  if($uinst->{flags} =~ /#ld_addr/){
    substr($uinst->{field1},6,1) = '1';
  }

  if($uinst->{flags} =~ /#fp_c/){
    substr($uinst->{field1},22,2) = '01';
  }
  if($uinst->{flags} =~ /#fp_r/){
    substr($uinst->{field1},22,2) = '10';
  }
  if($uinst->{flags} =~ /#fp_rc/){
    substr($uinst->{field1},22,2) = '11';
  }
  if($uinst->{flags} =~ /#clr_acy/){
    substr($uinst->{field1},17,1) = '1';
  }
  
}

sub process_flags {

  my $line = shift(@_);  
  
  $line =~ s/#/##/;
  $line =~ /(.*)#(#.*)/;
  
  $flags1 = '';
  $flags2 = '';

  
  if($1 ne ''){
    $line_without_flags = $1;
    $flag_str = $2;
    
    @flags = split /,/, $flag_str;      
    $error = '';
    
    if($flag_str =~ /#end/){
      if($flags2 ne ''){$error = 'incompatible flags'};
      $flags2 = '001';
    }
    if($flag_str =~ /#ret/){
      if($flags2 ne ''){$error = 'incompatible flags'};
      $flags2 = '011';
    }
    if($flag_str =~ /#rd/){
      if($flags2 ne ''){$error = 'incompatible flags'};
      $flags2 = '101';
    }
    if($flag_str =~ /#wr/){
      if($flags2 ne ''){$error = 'incompatible flags'};
      $flags2 = '110';
    }
    if($flag_str =~ /#auxcy/){
      if($flags1 ne ''){$error = 'incompatible flags'};
      $flags1 = '101';
    }

    if($flag_str =~ /#decode/){
      if($flags1 ne ''){$error = 'incompatible flags'};
      $flags1 = '001';
    }
    if($flag_str =~ /#clrt1/){
      if($flags1 ne ''){$error = 'incompatible flags'};
      $flags1 = '110';
    }
    if($flag_str =~ /#halt/){
      if($flags1 ne ''){$error = 'incompatible flags'};
      $flags1 = '111';
    }
    if($flag_str =~ /#di/){
      if($flags1 ne ''){$error = 'incompatible flags'};
      $flags1 = '010';
    }
    if($flag_str =~ /#ei/){
      if($flags1 ne ''){$error = 'incompatible flags'};
      $flags1 = '011';
    }
    if($flag_str =~ /#io/){
      if($flags1 ne ''){$error = 'incompatible flags'};
      $flags1 = '100';
    }
    if($flag_str =~ /#setacy/){
      if($flags2 ne ''){$error = 'incompatible flags:'.$flags2};
      $flags2 = '111';
    }
    
    if($flags2 eq ''){ $flags2 = '000';};    
    if($flags1 eq ''){ $flags1 = '000';};
    
    $uinst->{field_0} = $flags1.$flags2;

    # Some of the flags must be processed after the rest of the uinst
    # has been assembled; save them into $uinst->{flags} for later.
    
    if($flag_str =~ /#ld_al/){
      $uinst->{flags} = $uinst->{flags}." #ld_al";
    }
    if($flag_str =~ /#ld_addr/){
      $uinst->{flags} = $uinst->{flags}." #ld_addr";
    }
    if($flag_str =~ /#fp_c/){
      $uinst->{flags} = $uinst->{flags}." #fp_c";
    }
    if($flag_str =~ /#fp_r/){
      $uinst->{flags} = $uinst->{flags}." #fp_r";
    }
    if($flag_str =~ /#fp_rc/){
      $uinst->{flags} = $uinst->{flags}." #fp_rc";
    }
    if($flag_str =~ /#clr_acy/){
      $uinst->{flags} = $uinst->{flags}." #clr_acy";
    }

    if($error ne ''){
      $num_errors++;
      $uinst->{error} = $error;
    };
    
    return $line_without_flags;
  }
 
  return $line;
}


sub process_field2 {
  my $field = shift(@_).";";

  $field =~ s/^\s*//g;
  $field =~ s/\s*;//g;
  $field =~ s/\s+/ /g;
  
  $field =~ s/A-Z/a-z/g;
  
  
  # check for special field2 formats: nop
  if($field =~ /(nop)/){
    # field2 is nop by default
    return 0;
  }
  
  
  if($field =~ /(_\w+|{p}0|{p}1|{d}|{s}|do) = (\w+|t1)/){
    
    #check that dst address is the same as field1's src address
    #(since they end up being the same physical bits)
    @parts = split /=/, $field;
    $dst = $parts[0];
    $dst =~ s/\s//g;
    if(($dst ne $uinst->{src}) 
       && ($dst ne 'do') 
       && ($uinst->{src} ne 'di') 
       && ($uinst->{src} ne '')){
      # field mismatch
      $num_errors++;
      $uinst->{error} = "field source/destination address mismatch";
      return 1;
    }
    else{
      # build bitfield for field2, including those bits that overlap
      # bits from field 1
      
      if($dst eq 'do'){
        substr($uinst->{field1}, 24, 1) = '1'; #ld_do
      }
      else{
        substr($uinst->{field1}, 25, 1) = '1'; #ld_reg
        
        if($dst eq '{p}0'){
          substr($uinst->{field1}, 11, 2) = '11';  
          substr($uinst->{field1}, 13, 4) = '0000';                    
        }
        elsif($dst eq '{p}1'){
          substr($uinst->{field1}, 11, 2) = '11';  
          substr($uinst->{field1}, 13, 4) = '0001';                    
        }
        elsif($dst eq '{d}'){
          substr($uinst->{field1}, 11, 2) = '10';  
          substr($uinst->{field1}, 13, 4) = '0000';                    
        }
        elsif($dst eq '{s}'){
          substr($uinst->{field1}, 11, 2) = '01';  
          substr($uinst->{field1}, 13, 4) = '0000';          
        }
        else{
          %regs = ( '_b',0, '_c',1, '_d',2, '_e',3,
                    '_h',4, '_l',5, '_f',6, '_a',7,
                    '_ph',8, '_pl',9, '_x',10, '_y',11,
                    '_z',12, '_w',13, '_sh',14, '_sl',15);
                    
          $val_reg = to_bin($regs{$dst},4);          
          substr($uinst->{field1}, 11, 2) = '00';  
          substr($uinst->{field1}, 13, 4) = $val_reg; # RD address; same as WR
        } 
        
      }
      
      # TODO deal with flag pattern 
      $parts[1] =~ s/\s//g;
      $src = $field2_ops{$parts[1]}.'';
      if($src eq ''){
        $num_errors++;
        $uinst->{error} = "field 2 operation unknown: [".$parts[1]."]";
        return 1;
      }
      else{
        substr($uinst->{field1},26,6) = $src;
        return 0;
      }
    }
    
  }
  elsif($field =~ /(sec|cpc)/){
    substr($uinst->{field1},26,6) = $field2_ops{$1};
  }
  else{
    # field2 empty or invalid
    $num_errors++;
    $uinst->{error} = "field 2 empty or invalid: ".$re_field2;
    return 1;
  }  
  
}



# return   !=0 when uinst is finished except for flags, 
#         0 when field2 has to be processed

sub process_field1 {
  
  my $field = shift(@_).";";

  $field =~ s/^\s*//g;
  $field =~ s/\s*;//g;
  $field =~ s/\s+/ /g;
  
  # look for special format uinsts: jsr, tjsr, nop
  if($field =~ /(jsr|tjsr)\s+([_\w]+)/){
    $opcode = $1;
    $target = $2;    
    # set flag 
    $uinst->{flags} = $uinst->{flags}." #".$opcode." ";
    
    # check that target is defined, otherwise tag it for 2nd pass
    $target_addr = $labels{$target};

    tag_label_use($target, $addr);    
    
    if($target_addr eq ''){
      push @undefined_targets, [$target, $addr];
      $code = $field1_ops{$opcode};
      $uinst->{field1} = $code;
    }
    else{
      # set up bitfield so we can fill the address in in 2nd pass
      $code = $field1_ops{$opcode};
      $a = to_bin($target_addr+0, 8);
      substr($code, 20,2, substr($a, 0,2));
      substr($code, 26,6, substr($a, 2,6));
      $uinst->{field1} = $code;
    }
    return 1;
  }
  
  if($field =~ /nop/){
    # TODO encode NOP as 1st field
    $uinst->{field1} = $field1_ops{'nop'};
    return 0;
  }

  # process regular field1 (register load): dst = src
  
  if($field =~ /$re_field1/){
    @parts = split /=/, $field;
    
    # if a src reg address literal is specified, it has to be the same 
    # address as for field2 dest; save it for later comparison.
    
    $src = $parts[1];
    $src =~ s/\s//g;    
    
    $d = $field1_ops{$field}.'';
    
    if($d eq ''){
      # unrecognized source that somehow matches pattern (e.g. _pl0)
      $error = "invalid source in uinst field 1";
      $uinst->{field1} = $field1_ops{'nop'};
      $uinst->{error} = $error;
      $num_errors++;
      $uinst->{src} = '?';
      return 1;
    }
    else{
      $uinst->{src} = $src;    
      $uinst->{field1} = $d;
    }
    return 0;
  }
  else{
    # field1 not recognized.
    $error = "uinst field 1 not recognized: '".$field."'";
    $uinst->{field1} = $field1_ops{'nop'};
    $uinst->{error} = $error;
    $num_errors++;
    return 1;
  }  
  
}

sub tag_label_use {
  
  my $label = shift(@_);
  my $address = shift(@_);
   
  push(@label_uses, $label); 

}

sub to_bin {
  my $number = shift(@_) * 1;
  my $length = shift(@_);
  
  $n = $number;
  $r = '';
  for( my $i=$length-1;$i>=0;$i--){
    $d = 2 ** $i;
    
    if($n >= $d){
      $r = $r.'1';
      $n = $n - $d;
    }
    else{
      $r = $r.'0';
    }
  }
  
  return $r;
}

# End of file