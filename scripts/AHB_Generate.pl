#!/usr/bin/perl  

use Tk;
use Time::Local;
#use strict;
#use strict 'subs';

#LOCAL VARIABLES
my $infile="./ahb_generate.conf";
my $conffile="./ahb_configure.vhd";
my $matfile="./ahb_matrix.vhd";
my $sysfile="./ahb_system.vhd";
my $tbfile="./ahb_tb.vhd";

my @master_list;
my @slave_list;

my @mst_list;
my @slv_list;
my @pslv_list;

my $inst_name;
my $entity;

my $num_arb;
my $num_arb_msts;
my $def_arb_mst;
my @arb_master_list;
my @arb_slave_list;

my $num_brg;
my $num_brg_slvs;
my $def_brg_slv;
my $brg_master;
my @brg_slave_list;

my $num_apb;
my $num_apb_slvs;
my $apb_max_addr;
my $apb_slave_id;
my @apb_slave_list;


my $alg_number;
my @alg_list = qw/"Fixed" "Round-Robin" "Pseudo-Random" "Locked-Fixed" "Locked-R-R" "Locked-P-R"/;

my @gen_signal;
my @gen_ahb_signal;
my @gen_conf;
my @gen_comp;
my @gen_tbcomp;
my @gen_uut;
my @ass_signal;

my $curr_line;
my $cnt;
my $item;

my $chk=0;
my @tmp_chk;
my @tmp_lst;
my $tmp;  


my $mat;
my @matrix;
# GUI SHAPING
my (@pt)=qw/-side top -fill both -anchor n -pady 10/;
my (@pc)=qw/-side top -fill both -anchor center -pady 10/;
my (@pw)=qw/-side left -fill both -anchor w -padx 10/;
my (@pe)=qw/-side right -fill both -anchor e -padx 10/;

# GUI FSM
my $state='WinGlobal';
my $i=0;
my $j;

my $a;
my $b;
my $c;
my $d;
my $e;
my $f;

my $mw;
my $frame;

my $done='disabled';

my $masters=-1;
my $slaves=-1;
my $pslaves=-1;
my $arbs=-1;
my $ahbs=-1;
my $apbs=-1;

my @master;
my @slave;
my @pslave;
my @arb;
my @ahb;
my @apb;
my @uut;

my @tmp_mat;
 

sub ResetConf

{
$state='WinGlobal';
$masters=-1;
$slaves=-1;
$pslaves=-1;
$arbs=-1;
$ahbs=-1;
$apbs=-1;
$#master=-1;
$#slave=-1;
$#pslave=-1;
$#arb=-1;
$#ahb=-1;
$#apb=-1;
}

sub ReadConf
{

$state='WinGlobal';
seek(file1,0,0);
$masters=-1;
$slaves=-1;
$pslaves=-1;
$arbs=-1;
$ahbs=-1;
$apbs=-1;


while(defined($curr_line=<file1>)) {
    chop $curr_line;
    if($curr_line =~ /^#/) {
       print "# Comment skipped ...\n";
    } elsif($curr_line =~ /^(ahb_master),(\w+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)$/){
     $masters++;
     print "Reading AHB Master $masters...\n";
     $master[$masters]{"module"}=$1;
     $master[$masters]{"name"}=$2;
     $master[$masters]{"id"}=$masters;
     $master[$masters]{"fifo_ln"}=$3;
     $master[$masters]{"fifo_he"}=$4;
     $master[$masters]{"fifo_hf"}=$5;
     $master[$masters]{"num_bits_addr"}=$6;
     $master[$masters]{"write_burst"}=$7;
     $master[$masters]{"read_burst"}=$8;
     $master[$masters]{"write_lat"}=$9;
     $master[$masters]{"read_lat"}=$10;
	 $uut[$masters]{"base_addr"}=$11;
    } elsif($curr_line =~ /^(ahb_slave),(\w+),\((.*)\),(\w+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)$/){
     $slaves++;
     print "Reading AHB Slave $slaves...\n";
     $slave[$slaves]{"module"}=$1;
     $slave[$slaves]{"name"}=$2;
     foreach $item (split(',',$3)) {
       $slave[$slaves]{"list"} .= " $item";
       }
     $slave[$slaves]{"id"}=$slaves;
     $slave[$slaves]{"type"}=$4;
     $slave[$slaves]{"add_h"}=$5;
     $slave[$slaves]{"add_l"}=$6;
     $slave[$slaves]{"add_hh"}=$7;
     $slave[$slaves]{"add_ll"}=$8;
     $slave[$slaves]{"alg"}=$9;
     $slave[$slaves]{"fifo_ln"}=$10;
     $slave[$slaves]{"fifo_he"}=$11;
     $slave[$slaves]{"fifo_hf"}=$12;
     $slave[$slaves]{"num_bits_addr"}=$13;
     $slave[$slaves]{"write_burst"}=$14;
     $slave[$slaves]{"read_burst"}=$15;
     $slave[$slaves]{"write_lat"}=$16;
     $slave[$slaves]{"read_lat"}=$17;
    } elsif($curr_line =~ /^(apb_slave),(\w+),(\d+),(\d+),(\d+),(\d+),(\d+)$/){
     $pslaves++;
     print "Reading APB Slave $pslaves...\n";
     $pslave[$pslaves]{"module"}=$1;
     $pslave[$pslaves]{"name"}=$2;
     $pslave[$pslaves]{"id"}=$pslaves;
     $pslave[$pslaves]{"add_h"}=$3;
     $pslave[$pslaves]{"add_l"}=$4;
     $pslave[$pslaves]{"add_hh"}=$5;
     $pslave[$pslaves]{"add_ll"}=$6;
     $pslave[$pslaves]{"num_bits_addr"}=$7;
    } elsif($curr_line =~ /^(ahb_arbiter),(\w+),(\d+),\((.*)\),\((.*)\),(\d+)$/){
     $arbs++;
     print "Reading AHB Arbiter $arbs...\n";
     $arb[$arbs]{"module"}=$1;
     $arb[$arbs]{"name"}=$2;
     $arb[$arbs]{"id"}=$arbs;
     $arb[$arbs]{"def"}=$3;  
     foreach $item (split(',',$4)) {
       $arb[$arbs]{"m_list"} .= " $item";
       }
     foreach $item (split(',',$5)) {
       $arb[$arbs]{"s_list"} .= " $item";
       }
     $arb[$arbs]{"alg"}=$6;
    } elsif($curr_line =~ /^(ahb_bridge),(\w+),(\d+),(\d+),\((.*)\),(\d+)$/){
     $ahbs++;
     print "Reading AHB Bridge $ahbs...\n";
     $ahb[$ahbs]{"module"}=$1;
     $ahb[$ahbs]{"name"}=$2;
     $ahb[$ahbs]{"id"}=$ahbs;
     $ahb[$ahbs]{"alg"}=$3;
     $ahb[$ahbs]{"def"}=$4;  
     foreach $item (split(',',$5)) {
       $ahb[$ahbs]{"list"} .= " $item";
       }
     $ahb[$ahbs]{"mst"}=$6;  
    } elsif($curr_line =~ /^(apb_bridge),(\w+),(\d+),(\d+),\((.*)\)$/){
     $apbs++;
     print "Reading APB Bridge $apbs...\n";
     $apb[$apbs]{"module"}=$1;
     $apb[$apbs]{"name"}=$2;
     $apb[$apbs]{"id"}=$apbs;
     $apb[$apbs]{"num_bits_addr"}=$3;
     $apb[$apbs]{"slv"}=$4;  
     foreach $item (split(',',$5)) {
       $apb[$apbs]{"list"} .= " $item";
       }

    } else {
	print "#### wrong format!!!\n";
    }
#    close(file1);
}


sub SaveConf 
{

$state='WinGlobal';
open(file1,">$infile")|| die "Cannot write ahb configuration output file $infile\n";


$i=0;
while($i<=$masters) {
     print file1 "# ahb_master $i: module,name,fifo_length,fifo_he,fifo_hf,num_bits_adds,write_burst,read_burst,write_lat,read_lat,UUT_BaseAddr\n";
     print file1 "$master[$i]{\"module\"},";
     print file1 "$master[$i]{\"name\"},";
     print file1 "$master[$i]{\"fifo_ln\"},";
     print file1 "$master[$i]{\"fifo_he\"},";
     print file1 "$master[$i]{\"fifo_hf\"},";
     print file1 "$master[$i]{\"num_bits_addr\"},";
     print file1 "$master[$i]{\"write_burst\"},";
     print file1 "$master[$i]{\"read_burst\"},";
     print file1 "$master[$i]{\"write_lat\"},";
     print file1 "$master[$i]{\"read_lat\"},";
	 print file1 "$uut[$i]{\"base_addr\"}\n";
     $i++;
     }
     
$i=0;
while($i<=$slaves) {
     print file1 "# ahb_slave $i:
# module,name,NOT_USED,type,add_h,add_l,remap add_h,remap add_l,NOT_USED,fifo_le,fifo_he,fifo_hf,num_bits_adds,write_burst,read_burst,write_lat,read_lat\n";
     print file1 "$slave[$i]{\"module\"},";
     print file1 "$slave[$i]{\"name\"},";
     print file1 "(";
     $_=$slave[$i]{"list"};
     s/^[ ]+//g;
     s/[ ]+$//g;
     s/[ ]+/,/g;
     print file1 "$_),";
#     print file1 "$slave[$i]{\"id\"},";
     print file1 "$slave[$i]{\"type\"},";
     print file1 "$slave[$i]{\"add_h\"},";
     print file1 "$slave[$i]{\"add_l\"},";
     print file1 "$slave[$i]{\"add_hh\"},";
     print file1 "$slave[$i]{\"add_ll\"},";
     print file1 "$slave[$i]{\"alg\"},";
     print file1 "$slave[$i]{\"fifo_ln\"},";
     print file1 "$slave[$i]{\"fifo_he\"},";
     print file1 "$slave[$i]{\"fifo_hf\"},";
     print file1 "$slave[$i]{\"num_bits_addr\"},";
     print file1 "$slave[$i]{\"write_burst\"},";
     print file1 "$slave[$i]{\"read_burst\"},";
     print file1 "$slave[$i]{\"write_lat\"},";
     print file1 "$slave[$i]{\"read_lat\"}\n";
     $i++;
}     

$i=0;
while($i<=$pslaves) {
     print file1 "# apb_slave $i: module,name,add_h,add_l,remap add_h,remap add_l,num_bits_adds\n";
     print file1 "$pslave[$i]{\"module\"},";
     print file1 "$pslave[$i]{\"name\"},";
#     print file1 "$pslave[$i]{\"id\"},";
     print file1 "$pslave[$i]{\"add_h\"},";
     print file1 "$pslave[$i]{\"add_l\"},";
     print file1 "$pslave[$i]{\"add_hh\"},";
     print file1 "$pslave[$i]{\"add_ll\"},";
     print file1 "$pslave[$i]{\"num_bits_addr\"}\n";
     $i++;
 }

$i=0;
while($i<=$arbs) {
     print file1 "# ahb_arbiter $i: module,name,default master,master_list,slave_list,arbitration type\n";
     print file1 "$arb[$i]{\"module\"},";
     print file1 "$arb[$i]{\"name\"},";
#     print file1 "$arb[$i]{\"id\"},";
     print file1 "$arb[$i]{\"def\"},";
     print file1 "(";
     $_=$arb[$i]{"m_list"};
     s/^[ ]+//g;
     s/[ ]+$//g;
     s/[ ]+/,/g;
     print file1 "$_),";
     print file1 "(";
     $_=$arb[$i]{"s_list"};
     s/^[ ]+//g;
     s/[ ]+$//g;
     s/[ ]+/,/g;
     print file1 "$_),";
     print file1 "$arb[$i]{\"alg\"}\n";
     $i++;
}
     
$i=0;
while($i<=$ahbs) {
     print file1 "# ahb_bridge $i: module,name,arbitration type,default slave,slave_list,master\n";
     print file1 "$ahb[$i]{\"module\"},";
     print file1 "$ahb[$i]{\"name\"},";
#     print file1 "$ahb[$i]{\"id\"},";
     print file1 "$ahb[$i]{\"alg\"},";
     print file1 "$ahb[$i]{\"def\"},";  
     print file1 "(";
     $_=$ahb[$i]{"list"};
     s/^[ ]+//g;
     s/[ ]+$//g;
     s/[ ]+/,/g;
     print file1 "$_),";
     print file1 "$ahb[$ahbs]{\"mst\"}\n";  
     $i++;
}     
     
     
$i=0;
while($i<=$apbs) {
     print file1 "# apb_bridge $i: module,name,num_bits_adds,slave,periph list\n";
     print file1 "$apb[$i]{\"module\"},";
     print file1 "$apb[$i]{\"name\"},";
#     print file1 "$apb[$i]{\"id\"},";
     print file1 "$apb[$i]{\"num_bits_addr\"},";
     print file1 "$apb[$i]{\"slv\"},"; 
     print file1 "(";
     $_=$apb[$i]{"list"};
     s/^[ ]+//g;
     s/[ ]+$//g;
     s/[ ]+/,/g;
     print file1 "$_)\n";
     $i++;
 }

}


sub gen_master
{

    my $tmp_mst=shift(@_);
    
    @gen_tbcomp = (@gen_tbcomp, "
$tmp_mst->{\"name\"}: ahb_master
generic map(
	fifohempty_level => $tmp_mst->{\"fifo_he\"},
	fifohfull_level => $tmp_mst->{\"fifo_hf\"},
	fifo_length => $tmp_mst->{\"fifo_ln\"})
port map (
	hresetn => hresetn,
	hclk => hclk,	
	mst_in => ahb_mst_$tmp_mst->{\"id\"}_in,
	mst_out => ahb_mst_$tmp_mst->{\"id\"}_out,       
	dma_start => dma_start($tmp_mst->{\"id\"}),	
	m_wrap_out => m_wrap_out($tmp_mst->{\"id\"}),
	m_wrap_in => m_wrap_in($tmp_mst->{\"id\"}),
	eot_int => eot_int($tmp_mst->{\"id\"}),
	slv_running => zero,
	mst_running => open);		

$tmp_mst->{\"name\"}_wrap: mst_wrap
generic map(
--synopsys translate_off
dump_file => \"m$tmp_mst->{\"id\"}.log\",
dump_type => dump_all,
--synopsys translate_on
ahb_max_addr => $tmp_mst->{\"num_bits_addr\"},
m_const_lat_write => $tmp_mst->{\"write_lat\"},
m_const_lat_read => $tmp_mst->{\"read_lat\"},
m_write_burst => $tmp_mst->{\"write_burst\"},
m_read_burst => $tmp_mst->{\"read_burst\"})
port map(
	hresetn => hresetn,
	clk => hclk,	
	conf => conf($tmp_mst->{\"id\"}),
	dma_start => dma_start($tmp_mst->{\"id\"}),	
	m_wrap_in => m_wrap_out($tmp_mst->{\"id\"}),
	m_wrap_out => m_wrap_in($tmp_mst->{\"id\"}));
");


    @gen_uut = (@gen_uut, "
uut_stimulator_$tmp_mst->{\"id\"}: uut_stimulator 
generic map(
enable => 1,
stim_type => stim_$tmp_mst->{\"id\"},
eot_enable => 1)
port map(
	 hclk => hclk,
	 hresetn => hresetn,
	 amba_error => zero,
	 eot_int => eot_int($tmp_mst->{\"id\"}),
	 conf => conf($tmp_mst->{\"id\"}),
	 sim_end => sim_end($tmp_mst->{\"id\"}));

");


}

sub gen_slave {

my $tmp_slv=shift(@_);

#if ($tmp_slv->{"type"}=='wait') {
#@gen_tbcomp = (@gen_tbcomp, "
#$tmp_slv->{\"name\"}: ahb_single_slave");
#} else {
@gen_tbcomp = (@gen_tbcomp, "
$tmp_slv->{\"name\"}: ahb_slave_$tmp_slv->{\"type\"}");
#};

@gen_tbcomp = (@gen_tbcomp, "
generic map(
	num_slv => $tmp_slv->{\"id\"},
	fifohempty_level => $tmp_slv->{\"fifo_he\"},
	fifohfull_level => $tmp_slv->{\"fifo_hf\"},
	fifo_length => $tmp_slv->{\"fifo_ln\"})
port map (
	hresetn => hresetn,
	hclk => hclk,
	remap => remap,
	slv_in => ahb_slv_$tmp_slv->{\"id\"}_in,
	slv_out => ahb_slv_$tmp_slv->{\"id\"}_out,       
	s_wrap_out => s_wrap_out($tmp_slv->{\"id\"}),
	s_wrap_in => s_wrap_in($tmp_slv->{\"id\"}),
	mst_running => zero,
	prior_in => zero,
	slv_running => open,
	slv_err => open);		


$tmp_slv->{\"name\"}_wrap: slv_mem
generic map(
--synopsys translate_off
dump_file => \"s$tmp_slv->{\"id\"}.log\",
dump_type => dump_all,
--synopsys translate_on
ahb_max_addr => $tmp_slv->{\"num_bits_addr\"},
s_const_lat_write => $tmp_slv->{\"write_lat\"},
s_const_lat_read => $tmp_slv->{\"read_lat\"},
s_write_burst => $tmp_slv->{\"write_burst\"},
s_read_burst => $tmp_slv->{\"read_burst\"})
port map(
	hresetn => hresetn,
	clk => hclk,		
	conf => no_conf_s,
	dma_start => open,		
	s_wrap_in => s_wrap_out($tmp_slv->{\"id\"}),
	s_wrap_out => s_wrap_in($tmp_slv->{\"id\"}));

");


}



sub gen_pslave
{
my $tmp_pslv=shift(@_);    
@gen_tbcomp = (@gen_tbcomp, "
$tmp_pslv->{\"name\"}: apb_slave
generic map(
	--synopsys translate_off
	dump_file => \"p$tmp_pslv->{\"id\"}.log\",
	--synopsys translate_on
	apb_slv_addr => $tmp_pslv->{\"num_bits_addr\"})
port map (
	hresetn => hresetn,
	hclk => hclk,	
	apb_in => apb_slv_$tmp_pslv->{\"id\"}_in,
	apb_out => apb_slv_$tmp_pslv->{\"id\"}_out);
	
");


}



sub gen_arbiter
{
    my $tmp_arb=shift(@_);

    @arb_master_list = split(' ',$tmp_arb->{"m_list"});
    $def_arb_mst = $arb_master_list[0];
    $num_arb_msts = $#arb_master_list+1;
    @arb_slave_list = split(' ',$tmp_arb->{"s_list"});
 
    print "\nModule/ID: $tmp_arb->{\"module\"}, $tmp_arb->{\"id\"}";
    print "\nName: $tmp_arb->{\"name\"}";
    print "\nMasters'list:\n(@arb_master_list)";
    print "\nDefault master: $tmp_arb->{\"def\"}";
    print "\nType of arbitration: ".$alg_list[$tmp_arb->{"alg"}];
    print "\nSlaves'list:\n(@arb_slave_list)\n\n";  
  
    $cnt=0;
    foreach $item (@arb_master_list) {
      ++$mst_list[$item];
      if ($item==$tmp_arb->{"def"}) {$def_arb_mst=$cnt;}
      $cnt++;
      }
        
    foreach $item (@arb_slave_list) {++$slv_list[$item];}

    @gen_comp = (@gen_comp,"
$tmp_arb->{\"name\"}: $tmp_arb->{\"module\"} 
generic map(
num_arb => $tmp_arb->{\"id\"},
num_arb_msts => $num_arb_msts,
num_slvs => ".($#arb_slave_list+1).",
def_arb_mst => $def_arb_mst,
alg_number => $tmp_arb->{\"alg\"})
port map(
  hresetn => hresetn,
  hclk => hclk,
  remap => remap,
  mst_in_v => mst_in_arb_$tmp_arb->{\"id\"}_v(".($num_arb_msts-1)." downto 0),
  mst_out_v => mst_out_arb_$tmp_arb->{\"id\"}_v(".($num_arb_msts-1)." downto 0),
  slv_in_v => slv_in_arb_$tmp_arb->{\"id\"}_v($#arb_slave_list downto 0),
  slv_out_v => slv_out_arb_$tmp_arb->{\"id\"}_v($#arb_slave_list downto 0));

");
    
    @gen_signal = (@gen_signal,
"signal mst_out_arb_$tmp_arb->{\"id\"}_v: mst_in_v_t(".($num_arb_msts-1)." downto 0);
signal mst_in_arb_$tmp_arb->{\"id\"}_v: mst_out_v_t(".($num_arb_msts-1)." downto 0);
signal slv_out_arb_$tmp_arb->{\"id\"}_v: slv_in_v_t($#arb_slave_list downto 0);
signal slv_in_arb_$tmp_arb->{\"id\"}_v: slv_out_v_t($#arb_slave_list downto 0);
");
    
    $cnt = $#arb_master_list;			   
    foreach $item (@arb_master_list){
	@ass_signal = (@ass_signal, "ahb_mst_".$item."_in <= mst_out_arb_$tmp_arb->{\"id\"}_v($cnt);\n");
	@ass_signal = (@ass_signal, "mst_in_arb_$tmp_arb->{\"id\"}_v($cnt) <= ahb_mst_".$item."_out;\n");
	$cnt--;
    }
    
    $cnt = $#arb_slave_list;
    foreach $item (@arb_slave_list){
	@ass_signal = (@ass_signal, "ahb_slv_".$item."_in <= slv_out_arb_$tmp_arb->{\"id\"}_v($cnt);\n");
	@ass_signal = (@ass_signal, "slv_in_arb_$tmp_arb->{\"id\"}_v($cnt) <= ahb_slv_".$item."_out;\n");
	$cnt--;
    }
}


sub gen_bridge
{

    my $tmp_brg=shift(@_);

    @brg_slave_list = split(' ',$tmp_brg->{"list"});
    $def_brg_slv=$brg_slave_list[0];
    $num_brg_slvs = $#brg_slave_list+1;


    print "Module/ID: $tmp_brg->{\"module\"}, $tmp_brg->{\"id\"}";
    print "\nName: $tmp_brg->{\"name\"}";
    print "\nSlaves'list:\n(@brg_slave_list)";
    print "\nDefault slave: $tmp_brg->{\"def\"}";
    print "\nType of arbitration: ".$alg_list[$tmp_brg->{"alg"}];
    print "\nMaster: $tmp_brg->{\"mst\"}\n\n";
  
  
    --$mst_list[$tmp_brg->{"mst"}];
    @gen_signal = (@gen_signal, "signal ahb_mst_$tmp_brg->{\"mst\"}_in: mst_in_t;\n");
    @gen_signal = (@gen_signal, "signal ahb_mst_$tmp_brg->{\"mst\"}_out: mst_out_t;\n");
    
    
    $cnt = 0;
    foreach $item (@brg_slave_list) {
      --$slv_list[$item];
      @gen_signal = (@gen_signal, "signal ahb_slv_".$item."_in: slv_in_t;\n");
      @gen_signal = (@gen_signal, "signal ahb_slv_".$item."_out: slv_out_t;\n");
      if ($item==$tmp_brg->{"def"}) {$def_brg_slv=$cnt;}
      $cnt++;
      }
	

    @gen_comp = (@gen_comp, "\n$tmp_brg->{\"name\"}: $tmp_brg->{\"module\"}\n");
    @gen_comp = (@gen_comp, "generic map(\n");
    @gen_comp = (@gen_comp, "num_brg => $tmp_brg->{\"id\"},\n");
    @gen_comp = (@gen_comp, "num_brg_slvs => $num_brg_slvs,\n");
    @gen_comp = (@gen_comp, "def_brg_slv => $def_brg_slv,\n");
    @gen_comp = (@gen_comp, "alg_number => $tmp_brg->{\"alg\"})\n");
    @gen_comp = (@gen_comp, "port map(\n");
    @gen_comp = (@gen_comp, "  hresetn => hresetn,\n");
    @gen_comp = (@gen_comp, "  hclk => hclk,\n");
    @gen_comp = (@gen_comp, "  remap => remap,\n");
    @gen_comp = (@gen_comp, "  slv_in_v => slv_in_brg_$tmp_brg->{\"id\"}_v($#brg_slave_list downto 0),\n");
    @gen_comp = (@gen_comp, "  slv_out_v => slv_out_brg_$tmp_brg->{\"id\"}_v($#brg_slave_list downto 0),\n");
    @gen_comp = (@gen_comp, "  mst_in => mst_in_brg_$tmp_brg->{\"id\"},\n");
    @gen_comp = (@gen_comp, "  mst_out => mst_out_brg_$tmp_brg->{\"id\"},\n");
    @gen_comp = (@gen_comp, "  slv_err => open,\n");
    @gen_comp = (@gen_comp, "  mst_err => open);\n");
    @gen_comp = (@gen_comp, "\n\n");

    @gen_signal = (@gen_signal, "signal mst_out_brg_$tmp_brg->{\"id\"}: mst_out_t;\n");
    @gen_signal = (@gen_signal, "signal mst_in_brg_$tmp_brg->{\"id\"}: mst_in_t;\n");
    @gen_signal = (@gen_signal, "signal slv_out_brg_$tmp_brg->{\"id\"}_v: slv_out_v_t($#brg_slave_list downto 0);\n");
    @gen_signal = (@gen_signal, "signal slv_in_brg_$tmp_brg->{\"id\"}_v: slv_in_v_t($#brg_slave_list downto 0);\n");

    @ass_signal = (@ass_signal, "ahb_mst_$tmp_brg->{\"mst\"}_out <= mst_out_brg_$tmp_brg->{\"id\"};\n");
    @ass_signal = (@ass_signal, "mst_in_brg_$tmp_brg->{\"id\"} <= ahb_mst_$tmp_brg->{\"mst\"}_in;\n");

    $cnt = $#brg_slave_list;
    foreach $item (@brg_slave_list){
	@ass_signal = (@ass_signal, "ahb_slv_".$item."_out <= slv_out_brg_$tmp_brg->{\"id\"}_v($cnt);\n");
	@ass_signal = (@ass_signal, "slv_in_brg_$tmp_brg->{\"id\"}_v($cnt) <= ahb_slv_".$item."_in;\n");
	$cnt--;
    }  
    
}


sub gen_apb
{
    my $tmp_apb=shift(@_);

    @apb_slave_list = split(' ',$tmp_apb->{"list"});

    print "Module/ID: $tmp_apb->{\"module\"}, $tmp_apb->{\"id\"}";
    print "\nName: $tmp_apb->{\"name\"}";
    print "\nNumber of address bits to decode: $tmp_apb->{\"num_bits_addr\"}";
    print "\nAHB Slave: $tmp_apb->{\"slv\"}";
    print "\nSlaves'list:\n(@apb_slave_list)\n\n";


    --$slv_list[$tmp_apb->{"slv"}];
    @gen_signal = (@gen_signal, "signal ahb_slv_$tmp_apb->{\"slv\"}_in: slv_in_t;\n");
    @gen_signal = (@gen_signal, "signal ahb_slv_$tmp_apb->{\"slv\"}_out: slv_out_t;\n");


    @gen_comp = (@gen_comp, "$tmp_apb->{\"name\"}: $tmp_apb->{\"module\"}\n");
    @gen_comp = (@gen_comp, "generic map(\n");
    @gen_comp = (@gen_comp, "num_brg => $tmp_apb->{\"id\"},\n");
    @gen_comp = (@gen_comp, "num_brg_slvs => ".($#apb_slave_list+1).",\n");
    @gen_comp = (@gen_comp, "apb_max_addr => $tmp_apb->{\"num_bits_addr\"})\n");
    @gen_comp = (@gen_comp, "port map(\n");
    @gen_comp = (@gen_comp, "  hresetn => hresetn,\n");
    @gen_comp = (@gen_comp, "  hclk => hclk,\n");
    @gen_comp = (@gen_comp, "  remap => remap,\n");
    @gen_comp = (@gen_comp, "  slv_in => slv_in_apb_$tmp_apb->{\"id\"},\n");
    @gen_comp = (@gen_comp, "  slv_out => slv_out_apb_$tmp_apb->{\"id\"},\n");
    @gen_comp = (@gen_comp, "  apb_mst_in => apb_slv_$tmp_apb->{\"id\"}_out_v(".($#apb_slave_list)." downto 0),\n");
    @gen_comp = (@gen_comp, "  apb_mst_out => apb_slv_$tmp_apb->{\"id\"}_in_v(".($#apb_slave_list)." downto 0));\n");
    @gen_comp = (@gen_comp, "\n\n");

    @gen_signal = (@gen_signal, "signal slv_in_apb_$tmp_apb->{\"id\"}: slv_in_t;\n");
    @gen_signal = (@gen_signal, "signal slv_out_apb_$tmp_apb->{\"id\"}: slv_out_t;\n");
    @gen_signal = (@gen_signal, "signal apb_slv_$tmp_apb->{\"id\"}_out_v: apb_out_v_t($#apb_slave_list downto 0);\n");
    @gen_signal = (@gen_signal, "signal apb_slv_$tmp_apb->{\"id\"}_in_v: apb_in_v_t($#apb_slave_list downto 0);\n");

    @ass_signal = (@ass_signal, "slv_in_apb_$tmp_apb->{\"id\"} <= ahb_slv_$tmp_apb->{\"slv\"}_in;\n");
    @ass_signal = (@ass_signal, "ahb_slv_$tmp_apb->{\"slv\"}_out <= slv_out_apb_$tmp_apb->{\"id\"};\n");

    $cnt = $#apb_slave_list;
    foreach $item (@apb_slave_list){
	@ass_signal = (@ass_signal, "apb_slv_$tmp_apb->{\"id\"}_out_v($cnt) <= apb_slv_${item}_out;\n");
	@ass_signal = (@ass_signal, "apb_slv_${item}_in <= apb_slv_$tmp_apb->{\"id\"}_in_v($cnt);\n");
	++$pslv_list[$item];
	$cnt--;
    }
}

sub gen_lib()
{

print file3 (
"
--*******************************************************************
--**                                                             ****
--**  AHB system generator                                       ****
--**                                                             ****
--**  Author: Federico Aglietti                                  ****
--**          federico.aglietti\@opencores.org                   ****
--**                                                             ****
--*******************************************************************
--**                                                             ****
--** Copyright (C) 2004 Federico Aglietti                        ****
--**                    federico.aglietti\@opencores.org         ****
--**                                                             ****
--** This source file may be used and distributed without        ****
--** restriction provided that this copyright statement is not   ****
--** removed from the file and that any derivative work contains ****
--** the original copyright notice and the associated disclaimer.****
--**                                                             ****
--**     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ****
--** EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ****
--** TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ****
--** FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ****
--** OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ****
--** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ****
--** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ****
--** GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ****
--** BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ****
--** LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ****
--** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ****
--** OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ****
--** POSSIBILITY OF SUCH DAMAGE.                                 ****
--**                                                             ****
--*******************************************************************
library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

use work.ahb_package.all;
use work.ahb_configure.all;
use work.ahb_components.all;
");

print file4 (
"
--*******************************************************************
--**                                                             ****
--**  AHB system generator                                       ****
--**                                                             ****
--**  Author: Federico Aglietti                                  ****
--**          federico.aglietti\@opencores.org                   ****
--**                                                             ****
--*******************************************************************
--**                                                             ****
--** Copyright (C) 2004 Federico Aglietti                        ****
--**                    federico.aglietti\@opencores.org         ****
--**                                                             ****
--** This source file may be used and distributed without        ****
--** restriction provided that this copyright statement is not   ****
--** removed from the file and that any derivative work contains ****
--** the original copyright notice and the associated disclaimer.****
--**                                                             ****
--**     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ****
--** EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ****
--** TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ****
--** FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ****
--** OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ****
--** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ****
--** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ****
--** GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ****
--** BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ****
--** LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ****
--** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ****
--** OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ****
--** POSSIBILITY OF SUCH DAMAGE.                                 ****
--**                                                             ****
--*******************************************************************
library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use IEEE.std_logic_textio.all;

use work.ahb_package.all;
use work.ahb_configure.all;
use work.ahb_components.all;
");

print file5 (
"
--*******************************************************************
--**                                                             ****
--**  AHB system generator                                       ****
--**                                                             ****
--**  Author: Federico Aglietti                                  ****
--**          federico.aglietti\@opencores.org                   ****
--**                                                             ****
--*******************************************************************
--**                                                             ****
--** Copyright (C) 2004 Federico Aglietti                        ****
--**                    federico.aglietti\@opencores.org         ****
--**                                                             ****
--** This source file may be used and distributed without        ****
--** restriction provided that this copyright statement is not   ****
--** removed from the file and that any derivative work contains ****
--** the original copyright notice and the associated disclaimer.****
--**                                                             ****
--**     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ****
--** EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ****
--** TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ****
--** FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ****
--** OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ****
--** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ****
--** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ****
--** GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ****
--** BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ****
--** LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ****
--** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ****
--** OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ****
--** POSSIBILITY OF SUCH DAMAGE.                                 ****
--**                                                             ****
--*******************************************************************
library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use IEEE.std_logic_textio.all;

use work.ahb_package.all;
use work.ahb_configure.all;
use work.ahb_components.all;
");

}

sub gen_ent()
{
print file3 ("
entity ahb_matrix is
port(
hresetn: in std_logic;
hclk: in std_logic;	
");
$cnt=0;
foreach $item (@mst_list){
  if ($item > 0) {
print file3 ("
ahb_mst_${cnt}_out: in mst_out_t;
ahb_mst_${cnt}_in: out mst_in_t;
");
@gen_ahb_signal = (@gen_ahb_signal, "
signal ahb_mst_${cnt}_out: mst_out_t;
signal ahb_mst_${cnt}_in: mst_in_t;
");
	};
	$cnt++;
};
$cnt=0;
foreach $item (@slv_list){
  if ($item > 0) {
print file3 ("
ahb_slv_${cnt}_out: in slv_out_t;
ahb_slv_${cnt}_in: out slv_in_t;
");
@gen_ahb_signal = (@gen_ahb_signal, "
signal ahb_slv_${cnt}_out: slv_out_t;
signal ahb_slv_${cnt}_in: slv_in_t;
");
	};
	$cnt++;
};
$cnt=0;
foreach $item (@pslv_list){
  if ($item > 0) {
print file3 ("
apb_slv_${cnt}_out: in apb_out_t;
apb_slv_${cnt}_in: out apb_in_t;
");
@gen_ahb_signal = (@gen_ahb_signal, "
signal apb_slv_${cnt}_out: apb_out_t;
signal apb_slv_${cnt}_in: apb_in_t;
");
	};
	$cnt++;
};
print file3 ("
remap: in std_logic
	);
end;

architecture rtl of ahb_matrix is

");

print file4 ("
entity ahb_system is
port(
	hresetn: in std_logic;
	hclk: in std_logic;

	eot_int: out std_logic_vector($masters downto 0);
	conf: in conf_type_v($masters downto 0);

	remap: in std_logic
	);
end;

architecture rtl of ahb_system is


");

print file5 ("
entity ahb_tb is
end;

architecture rtl of ahb_tb is


");

}

sub gen_arrays {

@gen_conf = "
library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.ahb_package.all;

package ahb_configure is

--***************************************************************
-- definition of custom amba system parameters
--***************************************************************

--***************************************************************
-- AMBA SLAVES address configuration space
--***************************************************************
--For every slave define HIGH and LOW address, before and after (r)emap 

constant n_u: addr_t := (0, 0);\n\n";


#### PERIPHERAL SLAVES

  for $i (0 .. $pslaves) {@gen_conf = (@gen_conf, "constant  $pslave[$i]->{\"name\"}: addr_t := ($pslave[$i]->{\"add_h\"}, $pslave[$i]->{add_l});\n");} 
  for $i (0 .. $pslaves) {@gen_conf = (@gen_conf, "constant r$pslave[$i]->{\"name\"}: addr_t := ($pslave[$i]->{\"add_hh\"}, $pslave[$i]->{add_ll});\n");} 

#### PERIPHERAL SLAVES ARRAY

  for $i (0 .. 15) {
    if ($i <= $pslaves) {$tmp_mat[$i] = ("r$pslave[$i]->{\"name\"}");} else {$tmp_mat[$i] = ("n_u");};
  };

    @gen_conf = (@gen_conf, "\nconstant pslv_matrix: addr_matrix_t(1 downto 0) := (\n(");
    $i=15;
    while ($i > 0) {@gen_conf = (@gen_conf, "$tmp_mat[$i],");$i--;}
    @gen_conf = (@gen_conf, "$tmp_mat[0]),\n(");

  for $i (0 .. 15) {
    if ($i <= $pslaves) {$tmp_mat[$i] = ("$pslave[$i]->{\"name\"}");} else {$tmp_mat[$i] = ("n_u");};
  };

    $i=15;
    while ($i > 0) {@gen_conf = (@gen_conf, "$tmp_mat[$i],");$i--;}
    @gen_conf = (@gen_conf, "$tmp_mat[0]));\n\n");

#### SLAVES

  for $i (0 .. $slaves) {@gen_conf = (@gen_conf, "constant  $slave[$i]->{\"name\"}: addr_t := ($slave[$i]->{\"add_h\"}, $slave[$i]->{add_l});\n");} 
  for $i (0 .. $slaves) {@gen_conf = (@gen_conf, "constant r$slave[$i]->{\"name\"}: addr_t := ($slave[$i]->{\"add_hh\"}, $slave[$i]->{add_ll});\n");} 

#### SLAVES ARRAY

  for $i (0 .. 15) {
    if ($i <= $slaves) {
      $tmp_mat[$i] = ("r$slave[$i]->{\"name\"}");
    } else {
      $tmp_mat[$i] = ("n_u");
    };
  };

    @gen_conf = (@gen_conf, "\nconstant slv_matrix: addr_matrix_t(1 downto 0) := (\n(");
    $i=15;
    while ($i > 0) {@gen_conf = (@gen_conf, "$tmp_mat[$i],");$i--;}
    @gen_conf = (@gen_conf, "$tmp_mat[0]),\n(");

  for $i (0 .. 15) {
    if ($i <= $slaves) {
      $tmp_mat[$i] = ("$slave[$i]->{\"name\"}");
    } else {
      $tmp_mat[$i] = ("n_u");
    };
  };

    $i=15;
    while ($i > 0) {@gen_conf = (@gen_conf, "$tmp_mat[$i],");$i--;}
    @gen_conf = (@gen_conf, "$tmp_mat[0]));\n\n");


#### AHB ARBITERS ARRAY

  if ($arbs>0) {
    @gen_conf = (@gen_conf, "constant arb_matrix: addr_matrix_t($arbs downto 0):= (\n");
    @gen_signal = (@gen_signal, "signal addr_arb_matrix: addr_matrix_t($arbs downto 0);\n");
  } elsif ($arbs==0) {
    @gen_conf = (@gen_conf, "constant arb_matrix: addr_matrix_t(1 downto 0):= (\n");
    @gen_signal = (@gen_signal, "signal addr_arb_matrix: addr_matrix_t($arbs downto 0);\n");
  }


  if ($arbs==0) {
      @arb_slave_list = split(' ',$arb[$0]->{"s_list"});
      $j=15;
      while ($j>$#arb_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("ahb_slv".shift(@arb_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
      @gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}    
      @gen_conf = (@gen_conf, "$tmp_mat[$0]\)\);\n\n");
    
  } else {
  
    $i=$arbs;
    while ($i>=0) {
      @arb_slave_list = split(' ',$arb[$i]->{"s_list"});
      $j=15;
      while ($j>$#arb_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("ahb_slv".shift(@arb_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
    
      if ($i==0) {@gen_conf = (@gen_conf, "$tmp_mat[$0]));\n\n");}
      else {@gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");}
    
    $i--;  
    };
  };


  if ($arbs>0) {
    @gen_conf = (@gen_conf, "constant rarb_matrix: addr_matrix_t($arbs downto 0):= (\n");
  } elsif ($arbs==0) {
    @gen_conf = (@gen_conf, "constant rarb_matrix: addr_matrix_t(1 downto 0):= (\n");
  };


  if ($arbs==0) {
      @arb_slave_list = split(' ',$arb[$0]->{"s_list"});
      $j=15;
      while ($j>$#arb_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("rahb_slv".shift(@arb_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
      @gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}    
      @gen_conf = (@gen_conf, "$tmp_mat[$0]\)\);\n\n");
  
  } else {
  
    $i=$arbs;
    while ($i>=0) {

      @arb_slave_list = split(' ',$arb[$i]->{"s_list"});
      $j=15;
      while ($j>$#arb_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("rahb_slv".shift(@arb_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
     
      if ($i==0) {@gen_conf = (@gen_conf, "$tmp_mat[$0]));\n\n");}
      else {@gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");}
    
    $i--;  
    }
  }



#### AHB-AHB BRIDGES ARRAY

  if ($ahbs>0) {
    @gen_conf = (@gen_conf, "constant ahbbrg_matrix: addr_matrix_t($ahbs downto 0):= (\n");
    @gen_signal = (@gen_signal, "signal addr_ahbbrg_matrix: addr_matrix_t($ahbs downto 0);\n");
  } elsif ($ahbs==0) {
    @gen_conf = (@gen_conf, "constant ahbbrg_matrix: addr_matrix_t(1 downto 0):= (\n");
    @gen_signal = (@gen_signal, "signal addr_ahbbrg_matrix: addr_matrix_t(1 downto 0);\n");
  } else {
    @gen_conf = (@gen_conf,
"constant ahbbrg_matrix: addr_matrix_t(1 downto 0) := (
(n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u),
(n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u));

constant rahbbrg_matrix: addr_matrix_t(1 downto 0) := (
(n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u),
(n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u));

");
    @gen_signal = (@gen_signal, "signal addr_ahbbrg_matrix: addr_matrix_t(1 downto 0);\n");  
  }

  if ($ahbs==0) {
  
      @brg_slave_list = split(' ',$ahb[$0]->{"list"});
      $j=15;
      while ($j>$#brg_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("ahb_slv".shift(@brg_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
      @gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}    
      @gen_conf = (@gen_conf, "$tmp_mat[$0]\)\);\n\n");
      
  } else {
  
    $i=$ahbs;
    while ($i>=0) {

      @brg_slave_list = split(' ',$ahb[$i]->{"list"});
      $j=15;
      while ($j>$#brg_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("ahb_slv".shift(@brg_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
    
      if ($i==0) {@gen_conf = (@gen_conf, "$tmp_mat[$0]));\n\n");}
      else {@gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");}
    
    $i--;  
    };
  } 

  if ($ahbs>0) {
    @gen_conf = (@gen_conf, "constant rahbbrg_matrix: addr_matrix_t($ahbs downto 0):= (\n");
  } elsif ($ahbs==0) {
    @gen_conf = (@gen_conf, "constant rahbbrg_matrix: addr_matrix_t(1 downto 0):= (\n");
  };

  if ($ahbs==0) {
  
      @brg_slave_list = split(' ',$ahb[$0]->{"list"});
      $j=15;
      while ($j>$#brg_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("rahb_slv".shift(@brg_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
      @gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}    
      @gen_conf = (@gen_conf, "$tmp_mat[$0]\)\);\n\n");
      
  } else {
  
    $i=$ahbs;
    while ($i>=0) {

      @brg_slave_list = split(' ',$ahb[$i]->{"list"});
      $j=15;
      while ($j>$#brg_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("rahb_slv".shift(@brg_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
    
      if ($i==0) {@gen_conf = (@gen_conf, "$tmp_mat[$0]));\n\n");}
      else {@gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");}
    
    $i--;  
    };
  };

#### APB BRIDGES ARRAY

  if ($apbs>0) {
    @gen_conf = (@gen_conf, "constant apbbrg_matrix: addr_matrix_t($apbs downto 0):= (\n");
    @gen_signal = (@gen_signal, "signal addr_apbbrg_matrix: addr_matrix_t($apbs downto 0);\n");
  } elsif ($apbs==0) {
    @gen_conf = (@gen_conf, "constant apbbrg_matrix: addr_matrix_t(1 downto 0):= (\n");
    @gen_signal = (@gen_signal, "signal addr_apbbrg_matrix: addr_matrix_t(1 downto 0);\n");
  } else {
    @gen_conf = (@gen_conf,
"constant apbbrg_matrix: addr_matrix_t(1 downto 0) := (
(n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u),
(n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u));

constant rapbbrg_matrix: addr_matrix_t(1 downto 0) := (
(n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u),
(n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u,n_u));

");
    @gen_signal = (@gen_signal, "signal addr_apbbrg_matrix: addr_matrix_t(1 downto 0);\n");  
  };

  if ($apbs==0) {
  
      @apb_slave_list = split(' ',$apb[$0]->{"list"});
      $j=15;
      while ($j>$#apb_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("apb_slv".shift(@apb_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
      @gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}    
      @gen_conf = (@gen_conf, "$tmp_mat[$0]\)\);\n\n");
      
  } elsif ($apbs>0) {
  
    $i=$apbs;
    while ($i>=0) {

      @apb_slave_list = split(' ',$apb[$i]->{"list"});
      $j=15;
      while ($j>$#apb_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("apb_slv".shift(@apb_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
     
      if ($i==0) {@gen_conf = (@gen_conf, "$tmp_mat[$0]));\n\n");}
      else {@gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");}
    
    $i--;  
    };
  } else {
    ;
  };

  if ($apbs>0) {
    @gen_conf = (@gen_conf, "constant rapbbrg_matrix: addr_matrix_t($apbs downto 0):= (\n");
  } elsif ($apbs==0) {
    @gen_conf = (@gen_conf, "constant rapbbrg_matrix: addr_matrix_t(1 downto 0):= (\n");
  };

  if ($apbs==0) {
  
      @apb_slave_list = split(' ',$apb[$0]->{"list"});
      $j=15;
      while ($j>$#apb_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("rapb_slv".shift(@apb_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
      @gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}    
      @gen_conf = (@gen_conf, "$tmp_mat[$0]\)\);\n\n");
      
  } elsif ($apbs>0) {
  
    $i=$apbs;
    while ($i>=0) {

      @apb_slave_list = split(' ',$apb[$i]->{"list"});
      $j=15;
      while ($j>$#apb_slave_list) {$tmp_mat[$j] = ("n_u");$j--;}
      while ($j>=0) {$tmp_mat[$j] = ("rapb_slv".shift(@apb_slave_list));$j--;}
    
      $j=15;
      @gen_conf = (@gen_conf, "(");
      while ($j>0) {@gen_conf = (@gen_conf, "$tmp_mat[$j],");$j--;}
    
      if ($i==0) {@gen_conf = (@gen_conf, "$tmp_mat[$0]));\n\n");}
      else {@gen_conf = (@gen_conf, "$tmp_mat[$0]),\n");}
    
    $i--;  
    };
  } else {
    ;
  };
#### END OF FILE

@gen_conf = (@gen_conf,"

end;

package body ahb_configure is
end;

");

};

sub master_init {
  $masters += 1;
  $master[$masters]{"module"}='ahb_master';
  $master[$masters]{"name"}='ahb_mst'.$masters;
  $master[$masters]{"id"}=$masters;
  $master[$masters]{"fifo_ln"}='8';
  $master[$masters]{"fifo_he"}='1';
  $master[$masters]{"fifo_hf"}='7';
  $master[$masters]{"num_bits_addr"}='4';
  $master[$masters]{"write_burst"}='0';
  $master[$masters]{"read_burst"}='0';
  $master[$masters]{"write_lat"}='2';
  $master[$masters]{"read_lat"}='2';
  
  $uut[$masters]{"base_addr"}='2048';
};

sub slave_init {
  $slaves += 1;
  $slave[$slaves]{"module"}='ahb_slave';
  $slave[$slaves]{"name"}='ahb_slv'.$slaves;
  $slave[$slaves]{"list"}=('SLAVE_LIST');
  $slave[$slaves]{"id"}=$slaves;
  $slave[$slaves]{"type"}='wait';
  $slave[$slaves]{"add_h"}='0';
  $slave[$slaves]{"add_l"}='0';
  $slave[$slaves]{"add_hh"}='0';
  $slave[$slaves]{"add_ll"}='0';
  $slave[$slaves]{"alg"}=0;
  $slave[$slaves]{"fifo_ln"}='8';
  $slave[$slaves]{"fifo_he"}='1';
  $slave[$slaves]{"fifo_hf"}='7';
  $slave[$slaves]{"num_bits_addr"}='4';
  $slave[$slaves]{"write_burst"}='0';
  $slave[$slaves]{"read_burst"}='0';
  $slave[$slaves]{"write_lat"}='2';
  $slave[$slaves]{"read_lat"}='2';
};

sub pslave_init {
  $pslaves += 1;
  $pslave[$pslaves]{"module"}='apb_slave';
  $pslave[$pslaves]{"name"}='apb_slv'.$pslaves;
  $pslave[$pslaves]{"id"}=$pslaves;
  $pslave[$pslaves]{"add_h"}='0';
  $pslave[$pslaves]{"add_l"}='0';
  $pslave[$pslaves]{"add_hh"}='0';
  $pslave[$pslaves]{"add_ll"}='0';
  $pslave[$pslaves]{"num_bits_addr"}='4';
};

sub arb_init {
  $arbs += 1;
  $arb[$arbs]{"module"}='ahb_arbiter';
  $arb[$arbs]{"name"}='ahb_arb'.$arbs;
  $arb[$arbs]{"id"}=$arbs;
  $arb[$arbs]{"def"}='DEFAULT_MASTER';  
  $arb[$arbs]{"m_list"}=('MASTER_LIST');
  $arb[$arbs]{"s_list"}=('SLAVE_LIST');
  $arb[$arbs]{"alg"}=0;
  };

sub ahb_init {
  $ahbs += 1;
  $ahb[$ahbs]{"module"}='ahb_bridge';
  $ahb[$ahbs]{"name"}='ahb_brg'.$ahbs;
  $ahb[$ahbs]{"id"}=$ahbs;
  $ahb[$ahbs]{"alg"}=0;  
  $ahb[$ahbs]{"def"}='DEFAULT_SLAVE';  
  $ahb[$ahbs]{"list"}=('SLAVE_LIST');
  $ahb[$ahbs]{"mst"}='BRIDGE_MASTER';
  };

sub apb_init {
  $apbs += 1;
  $apb[$apbs]{"module"}='apb_bridge';
  $apb[$apbs]{"name"}='apb_brg'.$apbs;
  $apb[$apbs]{"id"}=$apbs;
  $apb[$apbs]{"num_bits_addr"}='4';
  $apb[$apbs]{"slv"}='BRIDGE_SLAVE';  
  $apb[$apbs]{"list"}=('SLAVE_LIST');
  };


# GUI FUNCTIONS

sub WinGlobalExit {
  $mw->destroy();
};


sub WinAddMaster {
  $state='WinGlobal';
  &master_init;
  
  $mw = MainWindow->new;
  
  $frame=$mw->Frame(-label=>"New AHB Master");
  # AHB Master 
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Master name: ")->pack(@pw);
  $frame->Entry(-textvariable => \$master[$masters]{"name"})->pack(@pe);
  
  # id
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Master number: ")->pack(@pw);
  $frame->Entry(-state => 'disabled', -textvariable => \$master[$masters]{"id"})->pack(@pe);

  $frame=$mw->Frame(-label=>"AHB Master internal fifo");
  # fifo length
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Fifo length: ")->pack(@pw);
  $frame->Entry(-textvariable => \$master[$masters]{"fifo_ln"})->pack(@pe);
  $frame=$mw->Frame();
  # fifo half empty
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Fifo half-empty level: ")->pack(@pw);
  $frame->Entry(-textvariable => \$master[$masters]{"fifo_he"})->pack(@pe);
  $frame=$mw->Frame();
  # fifo half full
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Fifo half-full level: ")->pack(@pw);
  $frame->Entry(-textvariable => \$master[$masters]{"fifo_hf"})->pack(@pe);
  $frame=$mw->Frame();
  
  # number of addressable bits
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Number of addr bits: ")->pack(@pw);
  $frame->Entry(-textvariable => \$master[$masters]{"num_bits_addr"})->pack(@pe);
  $frame=$mw->Frame();
  # burst capability in write 
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Write burst capability: ")->pack(@pw);
  $a = $frame->Radiobutton ( -variable => \$master[$masters]{"write_burst"}, -text => 'YES', -value => '1')->pack(@pw);
  $b = $frame->Radiobutton ( -variable => \$master[$masters]{"write_burst"}, -text => 'NO', -value => '0')->pack(@pe); 
  # burst capability in read
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Read burst capability: ")->pack(@pw);
  $c = $frame->Radiobutton ( -variable => \$master[$masters]{"read_burst"}, -text => 'YES', -value => '1')->pack(@pw);
  $d = $frame->Radiobutton ( -variable => \$master[$masters]{"read_burst"}, -text => 'NO', -value => '0')->pack(@pe); 
  # write latency
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Write access latency: ")->pack(@pw);
  $frame->Entry(-textvariable => \$master[$masters]{"write_lat"})->pack(@pe);
  $frame=$mw->Frame();
  # read latency
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Read access latency: ")->pack(@pw);
  $frame->Entry(-textvariable => \$master[$masters]{"read_lat"})->pack(@pe);
  $frame=$mw->Frame();
  # UUT base address
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "UUT Base Address: ")->pack(@pw);
  $frame->Entry(-textvariable => \$uut[$masters]{"base_addr"})->pack(@pe);
  $frame=$mw->Frame();

  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(-text => "cancel", -command =>sub {WinGlobalExit(); $state='WinGlobal'; $masters--;})->pack (@pw);
  $frame->Button(-text => "done", -command =>sub {WinGlobalExit(); $state='WinGlobal';})->pack (@pe);
  
  MainLoop;
};


sub WinAddSlave {
  $state='WinGlobal';
  &slave_init;
  
  $mw = MainWindow->new;
  
  $frame=$mw->Frame(-label=>"New AHB Slave");
  # AHB Slave 
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Slave name: ")->pack(@pw);
  $frame->Entry(-textvariable => \$slave[$slaves]{"name"})->pack(@pe);

  # type:multi/wait/retry/split
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Slave type: ")->pack(@pw);
  $a = $frame->Radiobutton (-state => 'disabled', -variable => \$slave[$slaves]{"type"}, -text => 'Multi slave', -value => 'multi')->pack(@pw);
  $b = $frame->Radiobutton ( -variable => \$slave[$slaves]{"type"}, -text => 'Single slave, wait', -value => 'wait')->pack(@pw);
  $c = $frame->Radiobutton (-state => 'disabled', -variable => \$slave[$slaves]{"type"}, -text => 'Single slave, retry', -value => 'retry')->pack(@pw);
  $d = $frame->Radiobutton (-state => 'disabled', -variable => \$slave[$slaves]{"type"}, -text => 'Single slave, split', -value => 'split')->pack(@pw);
  
  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(-text => "cancel", -command =>sub {WinGlobalExit(); $slaves--;})->pack (@pw);
  $frame->Button(-text => "done", -command =>sub {WinGlobalExit(); WinDefSlave(); })->pack (@pe);
  
  MainLoop;
}

  
sub WinDefSlave {

  $state='WinGlobal';

  $mw = MainWindow->new;
  
  if ($slave[$slaves]{"type"} eq 'multi') { 
  
  # slave list: first is default
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Slave list: ")->pack(@pw);
  $frame->Entry(-textvariable => \$slave[$slaves]{"list"})->pack(@pe);
  $frame=$mw->Frame();
  # algorithm number: 0,1,2
  $frame=$mw->Frame();
  
  $frame->pack(@pt);
  $frame->Label(-text => "Arbitration type: ")->pack(@pw);
  $a = $frame->Radiobutton ( -variable => \$slave[$slaves]{"alg"}, -text => 'Fixed        ', -value => '0')->pack(@pw);
  $b = $frame->Radiobutton ( -variable => \$slave[$slaves]{"alg"}, -text => 'Round Robin  ', -value => '1')->pack(@pw);
  $c = $frame->Radiobutton ( -variable => \$slave[$slaves]{"alg"}, -text => 'Pseudo Random', -value => '2')->pack(@pw);
  $frame=$mw->Frame();

  } else {
  
  # id
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Slave number: ")->pack(@pw);
  $frame->Entry(-state => 'disabled', -textvariable => \$slave[$slaves]{"id"})->pack(@pe);

  
  if (($slave[$slaves]{"type"} eq 'retry') or ($slave[$slaves]{"type"} eq 'split')) {

  # fifo length
  $frame=$mw->Frame(-label=>"AHB Slave internal fifo");
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Fifo length: ")->pack(@pw);
  $frame->Entry( -textvariable => \$slave[$slaves]{"fifo_ln"})->pack(@pe);
  $frame=$mw->Frame();
  # fifo half empty
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Fifo half-empty level: ")->pack(@pw);
  $frame->Entry( -textvariable => \$slave[$slaves]{"fifo_he"})->pack(@pe);
  $frame=$mw->Frame();
  # fifo half full
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Fifo half-full level: ")->pack(@pw);
  $frame->Entry( -textvariable => \$slave[$slaves]{"fifo_hf"})->pack(@pe);
  $frame=$mw->Frame();
  
  }

  # add before remap
  $frame=$mw->Frame(-label=>"ADDRESS before remap");
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Add high-low: ")->pack(@pt);
  $frame->Entry(-textvariable => \$slave[$slaves]{"add_h"})->pack(@pw);
  $frame->Entry(-textvariable => \$slave[$slaves]{"add_l"})->pack(@pe);

  # add after remap
  $frame=$mw->Frame(-label=>"ADDRESS after remap");
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Add high-low after remap: ")->pack(@pt);
  $frame->Entry(-textvariable => \$slave[$slaves]{"add_hh"})->pack(@pw);
  $frame->Entry(-textvariable => \$slave[$slaves]{"add_ll"})->pack(@pe);
  
  # number of addressable bits
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Number of addr bits: ")->pack(@pw);
  $frame->Entry(-textvariable => \$slave[$slaves]{"num_bits_addr"})->pack(@pe);
  $frame=$mw->Frame(); 
  # burst capability in write 
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Write burst capability: ")->pack(@pw);
  $a = $frame->Radiobutton ( -variable => \$slave[$slaves]{"write_burst"}, -text => 'YES', -value => '1')->pack(@pw);
  $b = $frame->Radiobutton ( -variable => \$slave[$slaves]{"write_burst"}, -text => 'NO', -value => '0')->pack(@pe); 
  # burst capability in read
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Read burst capability: ")->pack(@pw);
  $c = $frame->Radiobutton ( -variable => \$slave[$slaves]{"read_burst"}, -text => 'YES', -value => '1')->pack(@pw);
  $d = $frame->Radiobutton ( -variable => \$slave[$slaves]{"read_burst"}, -text => 'NO', -value => '0')->pack(@pe); 
  # write latency
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Write access latency: ")->pack(@pw);
  $frame->Entry(-textvariable => \$slave[$slaves]{"write_lat"})->pack(@pe);
  $frame=$mw->Frame();
  # read latency
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Read access latency: ")->pack(@pw);
  $frame->Entry(-textvariable => \$slave[$slaves]{"read_lat"})->pack(@pe);
  $frame=$mw->Frame();

  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(-text => "cancel", -command =>sub {WinGlobalExit(); $slaves--; WinAddSlave();})->pack (@pw);
  $frame->Button(-text => "done", -command =>sub {WinGlobalExit(); })->pack (@pe);
  
  MainLoop;
  }
  
};


sub WinAddPslave {

  $state='WinGlobal';
  &pslave_init;
  
  $mw = MainWindow->new;
  
  $frame=$mw->Frame(-label=>"New APB Slave");
  # APB Slave 
  $frame->pack(@pt);
  $frame->Label(-text => "APB Salve name: ")->pack(@pw);
  $frame->Entry(-textvariable => \$pslave[$pslaves]{"name"})->pack(@pe);

  # id
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "APB Slave number: ")->pack(@pw);
  $frame->Entry(-state => 'disabled', -textvariable => \$pslave[$pslaves]{"id"})->pack(@pe);

  # add before remap
  $frame=$mw->Frame(-label=>"ADDRESS before remap");
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Add high-low: ")->pack(@pt);
  $frame->Entry(-textvariable => \$pslave[$pslaves]{"add_h"})->pack(@pw);
  $frame->Entry(-textvariable => \$pslave[$pslaves]{"add_l"})->pack(@pe);

  # add after remap
  $frame=$mw->Frame(-label=>"ADDRESS after remap");
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Add high-low after remap: ")->pack(@pt);
  $frame->Entry(-textvariable => \$pslave[$pslaves]{"add_hh"})->pack(@pw);
  $frame->Entry(-textvariable => \$pslave[$pslaves]{"add_ll"})->pack(@pe);

  # number of addressable bits
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Number of addr bits: ")->pack(@pw);
  $frame->Entry(-textvariable => \$pslave[$pslaves]{"num_bits_addr"})->pack(@pe);
  $frame=$mw->Frame();

  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(-text => "cancel", -command =>sub {WinGlobalExit(); $pslaves--;})->pack (@pw);
  $frame->Button(-text => "done", -command =>sub {WinGlobalExit(); })->pack (@pe);
  
  MainLoop;
};


sub WinAddArbiter {
  $state='WinGlobal';
  &arb_init;
  
  $mw = MainWindow->new;
  
  $frame=$mw->Frame(-label=>"New AHB Arbiter");
  # AHB Arbiter
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Arbiter name: ")->pack(@pw);
  $frame->Entry(-textvariable => \$arb[$arbs]{"name"})->pack(@pe);

  # id
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Arbiter number: ")->pack(@pw);
  $frame->Entry(-state => 'disabled', -textvariable => \$arb[$arbs]{"id"})->pack(@pe);

  # Default master
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Default Master: ")->pack(@pw);
  $frame->Entry(-textvariable => \$arb[$arbs]{"def"})->pack(@pe);
  
  # master list: first is default
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Master list: ")->pack(@pw);
  $frame->Entry(-textvariable => \$arb[$arbs]{"m_list"})->pack(@pe);
  $frame=$mw->Frame();

  # algorithm number: 0,1,2,3,4,5
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Arbitration type: ")->pack(@pt);
  $a = $frame->Radiobutton ( -variable => \$arb[$arbs]{"alg"}, -text => 'Fixed        ', -value => '0')->pack(@pw);
  $b = $frame->Radiobutton ( -variable => \$arb[$arbs]{"alg"}, -text => 'Round Robin  ', -value => '1')->pack(@pw);
  $c = $frame->Radiobutton ( -variable => \$arb[$arbs]{"alg"}, -text => 'Pseudo Random', -value => '2')->pack(@pw);
  $d = $frame->Radiobutton ( -variable => \$arb[$arbs]{"alg"}, -text => 'Fixed Modif. ', -value => '3')->pack(@pe);
  $e = $frame->Radiobutton ( -variable => \$arb[$arbs]{"alg"}, -text => 'RR    Modif. ', -value => '4')->pack(@pe);
  $f = $frame->Radiobutton ( -variable => \$arb[$arbs]{"alg"}, -text => 'PR    Modif. ', -value => '5')->pack(@pe);
  $frame=$mw->Frame();

  # slave list
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Slave list: ")->pack(@pw);
  $frame->Entry(-textvariable => \$arb[$arbs]{"s_list"})->pack(@pe);
  $frame=$mw->Frame();

  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(-text => "cancel", -command =>sub {WinGlobalExit(); $arbs--;})->pack (@pw);
  $frame->Button(-text => "done", -command =>sub {WinGlobalExit(); })->pack (@pe);
  
  MainLoop;
};


sub WinAddAhb {
  $state='WinGlobal';
  &ahb_init;
  
  $mw = MainWindow->new;
  
  $frame=$mw->Frame(-label=>"New AHB Bridge");
  # AHB Bridge
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Bridge name: ")->pack(@pw);
  $frame->Entry(-textvariable => \$ahb[$ahbs]{"name"})->pack(@pe);

  # id
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Bridge number: ")->pack(@pw);
  $frame->Entry(-state => 'disabled', -textvariable => \$ahb[$ahbs]{"id"})->pack(@pe);

  # Default slave
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Default Slave: ")->pack(@pw);
  $frame->Entry(-textvariable => \$ahb[$ahbs]{"def"})->pack(@pe);
  
  # slave list
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Slave list: ")->pack(@pw);
  $frame->Entry(-textvariable => \$ahb[$ahbs]{"list"})->pack(@pe);
  $frame=$mw->Frame();

  # master
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Master: ")->pack(@pw);
  $frame->Entry(-textvariable => \$ahb[$ahbs]{"mst"})->pack(@pe);
  $frame=$mw->Frame();

  # algorithm number: 0,1,2
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Arbitration type: ")->pack(@pt);
  $a = $frame->Radiobutton ( -variable => \$ahb[$ahbs]{"alg"}, -text => 'Fixed        ', -value => '0')->pack(@pw);
  $b = $frame->Radiobutton ( -variable => \$ahb[$ahbs]{"alg"}, -text => 'Round Robin  ', -value => '1')->pack(@pw);
  $c = $frame->Radiobutton ( -variable => \$ahb[$ahbs]{"alg"}, -text => 'Pseudo Random', -value => '2')->pack(@pw);
  $frame=$mw->Frame();

  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(-text => "cancel", -command =>sub {WinGlobalExit(); $ahbs--;})->pack (@pw);
  $frame->Button(-text => "done", -command =>sub {WinGlobalExit(); })->pack (@pe);
  
  MainLoop;
};


sub WinAddApb {

  $state='WinGlobal';
  &apb_init;
  
  $mw = MainWindow->new;
  
  $frame=$mw->Frame(-label=>"New APB Bridge");
  # APB Bridge
  $frame->pack(@pt);
  $frame->Label(-text => "APB Bridge name: ")->pack(@pw);
  $frame->Entry(-textvariable => \$apb[$apbs]{"name"})->pack(@pe);

  # id
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Bridge number: ")->pack(@pw);
  $frame->Entry(-state => 'disabled', -textvariable => \$apb[$apbs]{"id"})->pack(@pe);

  # number of addressable bits
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "Number of addr bits: ")->pack(@pw);
  $frame->Entry(-textvariable => \$apb[$apbs]{"num_bits_addr"})->pack(@pe);
  $frame=$mw->Frame();

  # slave
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "AHB Slave: ")->pack(@pw);
  $frame->Entry(-textvariable => \$apb[$apbs]{"slv"})->pack(@pe);
  
  # slave list
  $frame=$mw->Frame();
  $frame->pack(@pt);
  $frame->Label(-text => "APB Slave list: ")->pack(@pw);
  $frame->Entry(-textvariable => \$apb[$apbs]{"list"})->pack(@pe);
  $frame=$mw->Frame();

  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(-text => "cancel", -command =>sub {WinGlobalExit(); $apbs--;})->pack (@pw);
  $frame->Button(-text => "done", -command =>sub {WinGlobalExit(); })->pack (@pe);
  
  MainLoop;
};


sub WinCheck {

  $mw = MainWindow->new;

  $state='WinGlobal';
  @gen_signal=();
  @ass_signal=();
  @gen_comp=();
  @gen_tbcomp=();
  @gen_uut=();
  $chk=0;		 
  @tmp_chk=();

  print "\n*******************************************\n*******************************************\n";
  # check for masters:
  if ($masters >= 0) {$chk++;for $j ( 0 .. $masters ) {&gen_master($master[$j]);}} else 
  {
      $frame=$mw->Frame();
      $frame->pack(@pt);
      $frame->Label(-text => "## ERROR: No AHB Masters")->pack(@pt);
  }
    
  # check for slaves:
  if ($slaves >= 0) {$chk++;} else 
  {
      $frame=$mw->Frame();
      $frame->pack(@pt);
      $frame->Label(-text => "## ERROR: No AHB Slaves")->pack(@pt);
  }

  # check for per slaves:
  if ($pslaves >= 0) {for $j ( 0 .. $pslaves ) {&gen_pslave($pslave[$j]);}} else {
      if ($apbs >= 0) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: No APB Peripherals")->pack(@pt);
      }
  }

  if ($arbs >= 0) {$chk++;for $j ( 0 .. $arbs ) {&gen_arbiter($arb[$j]);}} else
  {
      $frame=$mw->Frame();
      $frame->pack(@pt);
      $frame->Label(-text => "## ERROR: No AHB Arbiters")->pack(@pt);
  }
  
  # CONNECTION CHECKS:
  # Masters:
  for $i (0 .. $masters) {$tmp_chk[$i]=0};
  for $i (0 .. $ahbs) {$tmp_chk[$ahb[$i]{'mst'}]=0};
  
  for $i (0 .. $arbs) {
    @tmp_lst=split(' ',$arb[$i]{'m_list'});
    foreach (@tmp_lst) {
	  if ($_>$#tmp_chk) {
	    $chk--;
	    $frame=$mw->Frame();
	    $frame->pack(@pt);
	    $frame->Label(-text => "## ERROR: MASTER $_ used in ARBITER but not declared!")->pack(@pt);	
	  } else {
	    $tmp_chk[$_]++;
	  };
    };
  };
  for $i (0 .. $ahbs) {
      $tmp_chk[$ahb[$i]{'mst'}]+=10;
  };
  for $i (0 .. $#tmp_chk) {
      if ($tmp_chk[$i]==0) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: MASTER $i not connected to any AHB ARBITER!")->pack(@pt);	
      } elsif ($tmp_chk[$i]>1 and $tmp_chk[$i]<10 and $i<=$masters) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: MASTER $i connected to more than one AHB ARBITER!")->pack(@pt);		
      } elsif ($tmp_chk[$i]>=10 and $i<=$masters) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: MASTER $i cannot be used as AHB BRIDGE master!")->pack(@pt);		
      } elsif ($tmp_chk[$i]>=20 and $i>$masters) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: MASTER $i used more than one AHB BRIDGE!")->pack(@pt);		
      };
  };
  # Slaves:
  $#tmp_chk=-1;
  for $i (0 .. $slaves) {$tmp_chk[$i]=0};
  for $i (0 .. $arbs) {
    @tmp_lst=split(' ',$arb[$i]{'s_list'});
    foreach (@tmp_lst) {
	  if ($_>$slaves) {
	    $chk--;
	    $frame=$mw->Frame();
	    $frame->pack(@pt);
	    $frame->Label(-text => "## ERROR: SLAVE $_ still not declared!")->pack(@pt);	
      } else {
	    $tmp_chk[$_]++;
	  };
	};
  };
  for $i (0 .. $slaves) {
      if ($tmp_chk[$i]==0) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: SLAVE $i not connected to any AHB ARBITER!")->pack(@pt);	
      };
  };
  for $i (0 .. $slaves) {$tmp_chk[$i]=0};
  for $i (0 .. $ahbs) {
    @tmp_lst=split(' ',$ahb[$i]{'s_list'});
    foreach (@tmp_lst) {$tmp_chk[$_]++;}
  };
  for $i (0 .. $apbs) {
	  if ($i>$slaves) {
	    $chk--;
	    $frame=$mw->Frame();
	    $frame->pack(@pt);
	    $frame->Label(-text => "## ERROR: SLAVE $_ still not declared!")->pack(@pt);	
      } else {  
        $tmp_chk[$apb[$i]{'slv'}]++;
	  };
  };
  for $i (0 .. $slaves) {
      if ($tmp_chk[$i]>1) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: SLAVE $i cannot be connected to more than one BRIDGE!")->pack(@pt);	
      };
  };

  # APB Peripherals:
  $#tmp_chk=-1;
  for $i (0 .. $pslaves) {$tmp_chk[$i]=0};
  for $i (0 .. $apbs) {
    @tmp_lst=split(' ',$apb[$i]{'list'});
    foreach (@tmp_lst) {
	  if ($_>$pslaves) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: APB Peripheral $_ still not declared!")->pack(@pt);	
	  } else {
	  $tmp_chk[$_]++;
	  };
    };
  };
  for $i (0 .. $pslaves) {
    if ($tmp_chk[$i]==0) {
      $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: APB Peripheral $i not assigned to any APB master!")->pack(@pt);	
    } elsif ($tmp_chk[$i]>1) {
	  $chk--;
	  $frame=$mw->Frame();
	  $frame->pack(@pt);
	  $frame->Label(-text => "## ERROR: APB Peripheral $i connected more than once!")->pack(@pt);	
	};
  };

# WARNINGS on missing AHBAHB and AHBAPB BRIDGES
  if ($apbs >= 0) {
    for $j ( 0 .. $apbs ) {&gen_apb($apb[$j]);}
  } else {
    $frame=$mw->Frame();
    $frame->pack(@pt);
    $frame->Label(-text => "** WARNING: No APB Bridges")->pack(@pt);
  }

  if ($ahbs >= 0) {for $j ( 0 .. $ahbs ) {&gen_bridge($ahb[$j]);}} else
  {
      $frame=$mw->Frame();
      $frame->pack(@pt);
      $frame->Label(-text => "** WARNING: No AHB/AHB Bridges")->pack(@pt);    
  }
  

  # number '$chk' should indicate 'all checks OK!!'
  $done='disabled';
  if ($chk>=3) {
      $done='normal';
      $frame=$mw->Frame();
      $frame->pack(@pt);
      $frame->Label(-text => "**** CHECK PASSED ****")->pack(@pt);
  };
  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(-text => "done", -command =>sub {WinGlobalExit(); })->pack (@pt);
  
  MainLoop;
};


}






# global assignments
sub WinGlobal {
  $mw = MainWindow->new;
  
  $mw->title ("AHB system generator");
  $frame=$mw->Frame(-label=>"Main menu\n");
  $frame->pack(@pt);
  $frame->Button(
#  -default=>'normal',
#  -foreground=>'black',-background=>'grey',  
#  -state=>'active',-activeforeground=>'blue',-activebackground=>'white',
#  -disabledforeground=>'black',
  -text=>"add master",-command=>sub {WinGlobalExit(); $state='WinAddMaster';})->pack (@pw);
  
  $frame->Button(
  -text=>"add slave",-command=>sub {WinGlobalExit(); $state='WinAddSlave';})->pack (@pw);
  
  $frame->Button(
  -text=>"add arbiter",-command=>sub {WinGlobalExit(); $state='WinAddArbiter';})->pack (@pw);

  $frame->Button(-state=>'disabled',
  -text=>"add per. slave",-command=>sub {WinGlobalExit(); $state='WinAddPslave';})->pack (@pe);
  
  $frame->Button(-state=>'disabled',
  -text=>"add apb bridge",-command=>sub {WinGlobalExit(); $state='WinAddApb';})->pack (@pe);

  $frame->Button(-state=>'disabled',
  -text=>"add ahb bridge",-command=>sub {WinGlobalExit(); $state='WinAddAhb';})->pack (@pe);
  
  # $frame->Button(
  # -text=>"add per. slave",-command=>sub {WinGlobalExit(); $state='WinAddPslave';})->pack (@pe);
  
  # $frame->Button(
  # -text=>"add apb bridge",-command=>sub {WinGlobalExit(); $state='WinAddApb';})->pack (@pe);

  # $frame->Button(
  # -text=>"add ahb bridge",-command=>sub {WinGlobalExit(); $state='WinAddAhb';})->pack (@pe);

  
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(@pt);
  $frame->Button(
  -text=>"RESET conf",-command=>sub {WinGlobalExit(); $state='ResetConf';})->pack (@pt);

  $frame->Button(
  -text=>"READ conf",-command=>sub {WinGlobalExit(); $state='ReadConf';})->pack (@pt);

  $frame->Button(
  -text=>"SAVE conf",-command=>sub {WinGlobalExit(); $state='SaveConf';})->pack (@pt);
  
  # check and elaborate
  $frame->Button(
  -text=>"check/generate",-command=>sub {WinGlobalExit(); $state='WinCheck';})->pack (@pt);
  
  # exit
  $frame->Button(
  -state=>$done,-activeforeground=>'red',-activebackground=>'blue',
  -text=>"done",-command => sub {WinGlobalExit(); $state='quit';})->pack (@pt);
  
  MainLoop;
};



# GUI FSM

sub gui_fsm {
$i=1;
until ($state eq "quit") {
  if ($state eq 'WinGlobal') {
    &WinGlobal;
  } elsif ($state eq 'WinAddMaster') {
    &WinAddMaster;
  } elsif ($state eq 'WinAddSlave') {
    &WinAddSlave;
  } elsif ($state eq 'WinAddPslave') {
    &WinAddPslave;
  } elsif ($state eq 'WinAddArbiter') {
    &WinAddArbiter;
  } elsif ($state eq 'WinAddAhb') {
    &WinAddAhb;
  } elsif ($state eq 'WinAddApb') {
    &WinAddApb;
  } elsif ($state eq 'WinCheck') {
    &WinCheck;
  } elsif ($state eq 'SaveConf') {
    &SaveConf;
  } elsif ($state eq 'ReadConf') {
    &ReadConf;
  } elsif ($state eq 'ResetConf') {
    &ResetConf;
  } else {
    print "Bye!\n";
  };
 };
};


sub NoWinCheck {

  @gen_signal=();
  @ass_signal=();
  @gen_comp=();
  @gen_tbcomp=();
  @gen_uut=();
  $chk=0;		 
  @tmp_chk=();

  print "\n*******************************************\n*******************************************\n";
  # check for masters:
  if ($masters >= 0) {$chk++;for $j ( 0 .. $masters ) {&gen_master($master[$j]);}} else 
  {
    print "## ERROR: No AHB Masters\n\n";
  }
    
  # check for slaves:
  if ($slaves >= 0) {$chk++;} else 
  {
    print "## ERROR: No AHB Slaves\n\n";
  }

  # check for per slaves:
  if ($pslaves >= 0) {for $j ( 0 .. $pslaves ) {
    &gen_pslave($pslave[$j]);}
  } else {
      if ($apbs >= 0) {
	  	  $chk--;
		  print "## ERROR: No APB Peripheralss\n\n";
      }
  }

  if ($arbs >= 0) {$chk++;for $j ( 0 .. $arbs ) {&gen_arbiter($arb[$j]);}} else
  {
	 print "## ERROR: No AHB Arbiters\n\n";
  }
  
  # CONNECTION CHECKS:
  # Masters:
  for $i (0 .. $masters) {$tmp_chk[$i]=0};
  for $i (0 .. $ahbs) {$tmp_chk[$ahb[$i]{'mst'}]=0};
  
  for $i (0 .. $arbs) {
    @tmp_lst=split(' ',$arb[$i]{'m_list'});
    foreach (@tmp_lst) {
  	  if ($_>$#tmp_chk) {
	    $chk--;
	    print "## ERROR: MASTER $_ used in ARBITER but not declared!\n\n";	
	  } else {	
	    $tmp_chk[$_]++;
	  };
	};  
  };    
  for $i (0 .. $ahbs) {
      $tmp_chk[$ahb[$i]{'mst'}]+=10;
  };
  for $i (0 .. $#tmp_chk) {
      if ($tmp_chk[$i]==0) {
	  $chk--;
	  print "## ERROR: MASTER $i not connected to any AHB ARBITER!\n\n";	
      } elsif ($tmp_chk[$i]>1 and $tmp_chk[$i]<10 and $i<=$masters) {
	  $chk--;
	  print "## ERROR: MASTER $i connected to more than 1 AHB ARBITER!\n\n";		
      } elsif ($tmp_chk[$i]>=10 and $i<=$masters) {
	  $chk--;
	  print "## ERROR: MASTER $i cannot be used as AHB BRIDGE master!\n\n";		
      } elsif ($tmp_chk[$i]>=20 and $i>$masters) {
	  $chk--;
	  print "## ERROR: MASTER $i used in 2 or more AHB BRIDGE!\n\n";		
      };
  };
  # Slaves:
  $#tmp_chk=-1;
  for $i (0 .. $slaves) {$tmp_chk[$i]=0};
  for $i (0 .. $arbs) {
    @tmp_lst=split(' ',$arb[$i]{'s_list'});
    foreach (@tmp_lst) {
	  if ($_>$slaves) {
	    $chk--;
	    print "## ERROR: SLAVE $_ still not declared!\n\n";	
      } else {
	    $tmp_chk[$_]++;
	  };
	};
  };
  for $i (0 .. $slaves) {
      if ($tmp_chk[$i]==0) {
	  $chk--;
	  print "## ERROR: SLAVE $i not connected to any AHB ARBITER!\n\n";	
      };
  };
  for $i (0 .. $slaves) {$tmp_chk[$i]=0};
  for $i (0 .. $ahbs) {
    @tmp_lst=split(' ',$ahb[$i]{'s_list'});
    foreach (@tmp_lst) {$tmp_chk[$_]++;}
  };
  for $i (0 .. $apbs) {
	  if ($i>$slaves) {
	    $chk--;
	    print "## ERROR: SLAVE $_ still not declared!\n\n";	
      } else {  
        $tmp_chk[$apb[$i]{'slv'}]++;
	  };
  };
  for $i (0 .. $slaves) {
      if ($tmp_chk[$i]>1) {
	  $chk--;
	  print "## ERROR: SLAVE $i cannot be connected to more than 1 BRIDGE!\n\n";	
      };
  };

  # APB Peripherals:
  $#tmp_chk=-1;
  for $i (0 .. $pslaves) {$tmp_chk[$i]=0};
  for $i (0 .. $apbs) {
    @tmp_lst=split(' ',$apb[$i]{'list'});
    foreach (@tmp_lst) {
	  if ($_>$pslaves) {
	  $chk--;
	  print "## ERROR: APB Peripheral $_ still not declared!\n\n";	
	  } else {
	  $tmp_chk[$_]++;
	  };
    };
  };
  for $i (0 .. $pslaves) {
    if ($tmp_chk[$i]==0) {
      $chk--;
	  print "## ERROR: APB Peripheral $i not assigned to any APB master!\n\n";	
    } elsif ($tmp_chk[$i]>1) {
	  $chk--;
	  print "## ERROR: APB Peripheral $i connected 2 or more times!\n\n";	
	};
  };

# WARNINGS on missing AHBAHB and AHBAPB BRIDGES

  if ($apbs >= 0) {
    for $j ( 0 .. $apbs ) {&gen_apb($apb[$j]);}
  } else {
    print "** WARNING: No APB Bridges\n\n";
  }

  if ($ahbs >= 0) {for $j ( 0 .. $ahbs ) {&gen_bridge($ahb[$j]);}} else
  {
      print "** WARNING: No AHB/AHB Bridges\n\n";    
  }
  

  # number '$chk' should indicate 'all checks OK!!'
  if ($chk>=3) {
      print "**** CHECK PASSED ****\n\n";
  } else {
      print "#### CHECK NOT PASSED!!\n\n"
  };
};




print "\nAHB system generator version 1.0\n\n";

#if (!defined($ENV{DSN})) {
 # die "Env variable DSN should point to project home\n";
#}

#the ahb_system.vhd file is made of header, signal part, component
 open(file2,">$conffile");
 #|| die "Cannot open output file Now $conffile\n";
 open(file3,">$matfile");
 #|| die "Cannot open output file $matfile\n";
 open(file4,">$sysfile");
 #|| die "Cannot open output file $sysfile\n";
 open(file5,">$tbfile");
 #|| die "Cannot open output file $tbfile\n";


#USAGE: AHB_SYS_VERIF.pl [-nogui] [filename]
# if no file is specified "$DSN/scripts/ahb_generate.conf"
#open(file1,"<$infile")|| die "Cannot open ahb configuration input file $infile\n";
	 
$tmp=shift;
if ($tmp eq "-nogui") {
  $infile = shift;
  open(file1,"<$infile")|| die "Cannot open ahb configuration input file $infile\n";
  print "Reading configuration in $infile .....\n\n";
  &ReadConf;
  print "Generating configuration read by $infile .....\n\n";
  &NoWinCheck;
} else { 
  if ($tmp ne <undef>) {
    $infile=$tmp;
    open(file1,"<$infile")|| die "Cannot open ahb configuration input file $infile\n";
    print "Reading configuration in $infile .....\n\n";
	&ReadConf;
  } else {
    print "No configuration read; using ahb_generate.conf as output file\n"
  };
  &gui_fsm;
};

&gen_lib();
&gen_ent();
&gen_arrays();


##### GENERATION ON CONFIGURATION FILE
print file2 @gen_conf;


##### GENERATION ON AHB_MATRIX FILE
print file3 @gen_signal;
print file3 "\nbegin\n\n";
print file3 @ass_signal;
print file3 @gen_comp;
print file3 "\nend rtl;\n\n";



##### GENERATION ON SLAVE COMPONENTS (in @gen_tbcomp)
$cnt=0;
foreach $item (@slv_list){
  if ($item == 1) {&gen_slave($slave[$cnt]);}
  $cnt++;}
#####

##### GENERATION ON AHB_SYSTEM FILE
print file4 @gen_signal;
print file4 @gen_ahb_signal;
print file4 "
signal dma_start : start_type_v($masters downto 0);

signal m_wrap_out : wrap_out_v($masters downto 0);
signal m_wrap_in : wrap_in_v($masters downto 0);
signal s_wrap_out : wrap_out_v($slaves downto 0);
signal s_wrap_in : wrap_in_v($slaves downto 0);

signal zero : std_logic;
signal no_conf_s : conf_type_t;
constant no_conf_c: conf_type_t:= ('0',\"0000\",\"00000000000000000000000000000000\");

begin

zero <= '0';
no_conf_s <= no_conf_c;

";

print file4 @ass_signal;
print file4 @gen_comp;
print file4 @gen_tbcomp;
print file4 "\nend rtl;\n\n";


##### GENERATION ON AHB_TB FILE

print file5 @gen_signal;
print file5 @gen_ahb_signal;
print file5 "
signal conf : conf_type_v($masters downto 0);
signal dma_start : start_type_v($masters downto 0);
signal eot_int : std_logic_vector($masters downto 0);
signal sim_end : std_logic_vector($masters downto 0);

signal m_wrap_out : wrap_out_v($masters downto 0);
signal m_wrap_in : wrap_in_v($masters downto 0);
signal s_wrap_out : wrap_out_v($slaves downto 0);
signal s_wrap_in : wrap_in_v($slaves downto 0);

signal hresetn: std_logic;
signal hclk: std_logic;
signal remap: std_logic;

signal zero : std_logic;
signal no_conf_s : conf_type_t;
constant no_conf_c: conf_type_t:= ('0',\"0000\",\"00000000000000000000000000000000\");
";

for $i (0 .. $masters) {
print file5 "constant stim_$i: uut_params_t:= (bits32,retry,master,'0',single,2,4,hprot_posted,$uut[$i]{\"base_addr\"},1,0,'0');\n"
}

print file5 "
begin

zero <= '0';
no_conf_s <= no_conf_c;

";
print file5 @ass_signal;
print file5 @gen_comp;
print file5 @gen_tbcomp;
print file5 @gen_uut;

print file5 "
clock_pr:process
begin
  if hclk='1' then
    hclk <= '0';
    wait for 5 ns;
  else
    hclk <= '1';
    wait for 5 ns;
  end if;
end process;

reset_pr:process
begin
  hresetn<= '0';
  wait for 20 ns;
  hresetn <= '1';
  wait;
end process;

remap_pr:process
begin
  remap <= '0';
  wait for 2000 ns;
  remap <= '1';
  wait;
end process;

";

print file5 "assert (not(";
if ($masters >0) {
$i = $masters;
while ($i > 0) {print file5 "sim_end($i)='1' and ";$i--;}
}
print file5 "sim_end(0)='1')) report \"*** SIMULATION ENDED ***\" severity failure;\n";
print file5 "\nend rtl;\n\n";


exit;



