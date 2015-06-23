#!/usr/bin/perl

use Tk;
use Time::Local;

#
# usage perl wishbone_gui.pl [-nogui] [wishbone.defines]
#

#
# description: users manual
#

my $infile = "wishbone.defines";
my $outfile = wb;

my $a;
my $i=0;
my $j=0;

# default settings
my $syscon=syscon;
my $intercon=intercon;
my $target="generic";
my $hdl=vhdl;
my $ext=".vhd";
my $signal_groups=0;
my $comment="--";
my $dat_size=32;
my $adr_size=32;
my $tgd_bits=0;
my $tga_bits=2;
my $tgc_bits=3;
my $rename_tgc="cti";
my $rename_tga="bte";
my $rename_tgd="tgd";
my $classic="000";
my $endofburst="111";
my $interconnect="sharedbus";
my $mux_type="andor";
my $optimize="speed";
my $priority="0";

# keep track of implementation size
my $masters=0;
my $slaves=0;
my $rty_o=0;
my $rty_i=0;
my $err_o=0;
my $err_i=0;
my $tgc_o=0;
my $tgc_i=0;
my $tga_o=0;
my $tga_i=0;

# GUI FSM
my $state='WinGlobal';
my $next=0;
my $back=0;
my $amp=0;
my $asp=0;
my $del=0;
my $i;

# open input file
#if (open(FILE,"<$file")) {

# read in settings from infile

sub master_init {
  $masters += 1;
  $master[$masters]{"wbm"}=$_[0];
  $master[$masters]{"dat_size"}=$dat_size;
  $master[$masters]{"adr_size"}=$adr_size;
  $master[$masters]{"type"}="rw";
  $master[$masters]{"adr_o_hi"}=31;
  $master[$masters]{"adr_o_lo"}=0;
  $master[$masters]{"lock_o"}=0;
  $master[$masters]{"err_i"}=1;
  $master[$masters]{"rty_i"}=1;
  $master[$masters]{"tga_o"}=0;
  $master[$masters]{"tgd_o"}=0;
  $master[$masters]{"tgc_o"}=0;
  $master[$masters]{"priority"}=1;
};

sub slave_init {
  $slaves += 1;
  $slave[$slaves]{"wbs"}=$_[0];
  $slave[$slaves]{"dat_size"}=$dat_size;
  $slave[$slaves]{"type"}="rw";
  $slave[$slaves]{"sel_i"}=1;
  $slave[$slaves]{"adr_i_hi"}=31;
  $slave[$slaves]{"adr_i_lo"}=2;
  $slave[$slaves]{"lock_i"}=0;
  $slave[$slaves]{"tgd_i"}=0;
  $slave[$slaves]{"tga_i"}=0;
  $slave[$slaves]{"tgc_i"}=0;
  $slave[$slaves]{"err_o"}=0;
  $slave[$slaves]{"rty_o"}=0;
  $slave[$slaves]{"baseadr"}="00000000";
  $slave[$slaves]{"size"}="00100000";
  $slave[$slaves]{"baseadr1"}="00000000";
  $slave[$slaves]{"size1"}="ffffffff";
  $slave[$slaves]{"baseadr2"}="00000000";
  $slave[$slaves]{"size2"}="ffffffff";
  $slave[$slaves]{"baseadr3"}="00000000";
  $slave[$slaves]{"size3"}="ffffffff";
};

sub read_defines {
$priority=0;
$masters=0;
$slaves=0;
open(FILE,"<$_[0]") or die "could not read from $file";
while($a = <FILE>)
{
  if ($a =~ /^(syscon|intercon|filename)( *)(=)( *)([a-zA-Z0-9_\/\.]+)(;?)$/) {
    if($1 eq "syscon")   { $syscon = $5; }
    if($1 eq "intercon") { $intercon = $5; }
    if($1 eq "filename") { $outfile = $5; }
  }

  if ($a =~ /^(target)( *)(=)( *)(generic|xilinx|altera)(;?)$/) {
    $target = $5; };

  if ($a =~ /^(hdl)( *)(=)( *)(vhdl|verilog|perlilog);?$/) {
    $hdl = $5;
    if ($5 eq "vhdl") {
      $comment="--";
      $ext=".vhd";
    } else {
      $comment="//";
      $ext=".v";
    };
  };

  if ($a =~ /^(interconnect)( *)(=)( *)(crossbarswitch|sharedbus)(;?)$/) {
    $interconnect = $5; };

  if ($a =~ /^(signal_groups)( *)(=)( *)([0-1])(;?)($*)/) {
    $signal_groups = $5; };

  if ($a =~ /^(mux_type)( *)(=)( *)(mux|andor|tristate)(;?)$/) {
    $mux_type = $5; };

  if ($a =~ /^(optimize)( *)(=)( *)(speed|area);?$/) {
    $optimize = $5; };

  if ($a =~ /^(dat_size|adr_size|tgd_bits|tga_bits|tgc_bits)( *)(=)( *)([0-9]+)(;?)($*)/) {
    if ($1 eq "dat_size"){$dat_size = $5};
    if ($1 eq "adr_size"){$adr_size = $5};
    if ($1 eq "tgd_bits"){$tgd_bits = $5};
    if ($1 eq "tga_bits"){$tga_bits = $5};
    if ($1 eq "tgc_bits"){$tgc_bits = $5};
  };

  if ($a =~ /^(rename)(_)(tga|tgc|tgd)( *)(=)( *)([a-zA-Z_-]+)(;?)($*)/) {
    if ($3 eq "tga"){$rename_tga=$7};
    if ($3 eq "tgc"){$rename_tgc=$7};
    if ($3 eq "tgd"){$rename_tgd=$7};
  };

  # master port setup
  if ($a =~ /^(master)( *)([A-Za-z0-9_-]+)($*)/) {
    if($1 eq "master") {
      master_init($3);
    };
    $a = <FILE>;
    until ($a =~ /^(end master)($*)/) {
      if ($a =~ /^( *)(dat_size|adr_o_hi|adr_o_lo|lock_o|err_i|rty_i|tga_o|tgc_o|priority)( *)(=)( *)(0x)?([0-9a-fA-F]*)(;?)($*)/) {
        $master[$masters]{"$2"}=$7;
        if (($2 eq "rty_i") && ($7 eq 1)) {
          $rty_i++; };
        if (($2 eq "err_i") && ($7 eq 1)) {
          $err_i++; };
        if (($2 eq "tgc_o") && ($7 eq 1)) {
          $tgc_o++; };
        if (($2 eq "tga_o") && ($7 eq 1)) {
          $tga_o++; };
	# priority for shared bus system
	if ($2 eq "priority") {
          $priority += $7; };
      }; #end if
      if ($a =~ /^( *)(type)( *)(=)( *)(ro|wo|rw)(;?)($*)/) {
        $master[$masters]{"$2"}=$6; };
      # priority for crossbarswitch
      if ($a =~ /^( *)(priority)(_)([0-9a-zA-Z_]*)( *)(=)( *)([0-9]*)(;?)($*)/) {
        $master[$masters]{("priority_"."$4")}=$8; };
      $a = <FILE>;
    };
  };

  # slave port setup
  if ($a =~ /^(slave)( *)([A-Za-z0-9_-]+)($*)/) {
    if ($1 eq "slave") {
      slave_init($3);
    };
    $a = <FILE>;
    until ($a =~ /^(end slave)($*)/) {
      if ($a =~ /^( *)(dat_i|dat_o|sel_i|adr_i_hi|adr_i_lo|lock_i|tga_i|tgc_i|err_o|rty_o|baseadr|size|baseadr1|size1|baseadr2|size2|baseadr3|size3)( *)(=)( *)(0x)?([0-9a-fA-F]+)(;?)($*)/) {
        $slave[$slaves]{"$2"}=$7;
        if (($2 eq "rty_o") && ($7 eq 1)) {
          $rty_o++; };
        if (($2 eq "err_o") && ($7 eq 1)) {
          $err_o++; };
        if (($2 eq "tgc_i") && ($7 eq 1)) {
          $tgc_i++; };
        if (($2 eq "tga_i") && ($7 eq 1)) {
          $tga_i++; };
      }; #end if
      if ($a =~ /^( *)(type)( *)(=)( *)(ro|wo|rw)(;?)($*)/) {
        $slave[$slaves]{"$2"}=$6; };
      $a = <FILE>;
    };
  };
}; #end while
close($_[0]);
}; #end sub

################################################################################
# GUI

my $mw;

sub WinGlobalExit {
  $mw->destroy();
};

# global assignments
sub WinGlobal {
  $mw = MainWindow->new;
  $mw->title ("Wishbone generator");
  $frame=$mw->Frame(-label=>"Global definitions");
  # define file
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Define file:")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$infile)->pack(-side=>'right');
  # HDL file
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "HDL file   :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$outfile)->pack(-side=>'right');
  # intercon
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "intercon   :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$intercon)->pack(-side=>'right');
  # syscon
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "syscon     :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$syscon)->pack(-side=>'right');
  # target
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Target :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$target, -text => 'Generic', -value => 'generic')->pack(-side=>'left');
  $b = $frame->Radiobutton ( -variable => \$target, -text => 'XILINX', -value => 'xilinx')->pack(-side=>'left');
  $c = $frame->Radiobutton ( -variable => \$target, -text => 'ALTERA', -value => 'altera')->pack(-side=>'left');
  # interconnect
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Interconnection :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$interconnect, -text => 'Shared bus', -value => 'sharedbus')->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$interconnect, -text => 'Crossbar switch', -value => 'crossbarswitch' )->pack( -side=>'right');
  # mux
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Mux type :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$mux_type, -text => 'mux', -value => 'mux')->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$mux_type, -text => 'andor', -value => 'andor')->pack( -side=>'left');
  $c = $frame->Radiobutton ( -variable => \$mux_type, -text => 'tristate', -value => 'tristate' )->pack( -side=>'right');
  # hdl
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "HDL type :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$hdl, -text => 'VHDL', -value => 'vhdl')->pack(-side=>'left');
  $b = $frame->Radiobutton ( -variable => \$hdl, -text => 'Verilog', -value => 'verilog')->pack(-side=>'left');
  $c = $frame->Radiobutton ( -variable => \$hdl, -text => 'Perlilog', -value => 'perlilog')->pack(-side=>'left');
  # signalgroups
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Signal groups :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$signal_groups, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$signal_groups, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # dat size
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Data bus size :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$dat_size)->pack(-side=>'right');
  # adr size
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Adr bus size    :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$adr_size)->pack(-side=>'right');
  # tga
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tga bits           :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$tga_bits)->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tga rename     :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$rename_tga)->pack(-side=>'right');
  # tgc
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tgc bits           :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$tgc_bits)->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tgc rename     :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$rename_tgc)->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "classic           :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$classic)->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "end of burst   :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$endofburst)->pack(-side=>'right');
  # tgd
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tgd bits           :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$tgd_bits)->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tgd rename     :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$rename_tgd)->pack(-side=>'right');
  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(-side => 'right', -fill => 'y', -expand => 'y');
  $frame->Button(-text => "add master port", -command =>sub {WinGlobalExit(); $amp=1;})->pack (-side => 'left');
  $frame->Button(-text => "add slave  port", -command =>sub {WinGlobalExit(); $asp=1;})->pack (-side => 'left');
  if (($masters > 0) && ($slaves > 0)) {
    $frame->Button(-text => "set priority", -command =>sub {WinGlobalExit();})->pack (-side => 'left');
  };
  $frame->Button(-text => "next", -command =>sub {WinGlobalExit(); $next=1;})->pack (-side => 'right');
  MainLoop;
};

# add master port
sub WinAddMaster {
  master_init("wbm". ($masters+1));
  $mw = MainWindow->new;
  $mw->title ("Wishbone generator");
  $frame=$mw->Frame(-label=>"Add wishbone master port");
  # port name
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Master port name:")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$master[$masters]{"wbm"})->pack(-side=>'right');
  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(-side => 'right', -fill => 'y', -expand => 'y');
  $frame->Button(-text => "add master port", -command =>sub {WinGlobalExit(); $amp=1;})->pack ( -side => 'left');
  $frame->Button(-text => "next", -command =>sub {WinGlobalExit(); $next=1;})->pack ( -side => 'right');
  MainLoop;
};

sub WinMaster {
  $mw = MainWindow->new;
  $mw->title ("Wishbone generator");
  $frame=$mw->Frame(-label=>"Master port");
  # Master port
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Master port    :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$master[$i]{"wbm"})->pack(-side=>'right');
  # dat_size
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Data bus size :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$master[$i]{"dat_size"})->pack(-side=>'right');
  # adr size
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Adr bus size   :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$master[$i]{"adr_size"})->pack(-side=>'right');
  # type
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Master type   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$master[$i]{"type"}, -text => 'Read/Write', -value => 'rw')->pack(-side=>'left');
  $b = $frame->Radiobutton ( -variable => \$master[$i]{"type"}, -text => 'Read only', -value => 'ro')->pack(-side=>'left');
  $c = $frame->Radiobutton ( -variable => \$master[$i]{"type"}, -text => 'Write only', -value => 'wo')->pack(-side=>'left');
  # err_i
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "err_i   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$master[$i]{"err_i"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$master[$i]{"err_i"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # rty_i
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "rty_i   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$master[$i]{"rty_i"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$master[$i]{"rty_i"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # lock_o
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "lock_o :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$master[$i]{"lock_o"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$master[$i]{"lock_o"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # tga_o
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tga_o  :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$master[$i]{"tga_o"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$master[$i]{"tga_o"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # tgc_o
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tgc_o  :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$master[$i]{"tgc_o"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$master[$i]{"tgc_o"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # tgd_o
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tgd_o  :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$master[$i]{"tgd_o"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$master[$i]{"tgd_o"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(-side => 'right', -fill => 'y', -expand => 'y');
  if ($i == $masters) {
    $frame->Button(-text => "add slave port", -command =>sub {WinGlobalExit(); $am=1;})->pack (-side => 'left');
  };
  $frame->Button(-text => "delete", -command =>sub {WinGlobalExit(); $del=1;})->pack (-side => 'left');
  $frame->Button(-text => "back", -command =>sub {WinGlobalExit(); $back=1;})->pack (-side => 'left');
  $frame->Button(-text => "next", -command =>sub {WinGlobalExit(); $next=1;})->pack (-side => 'left');
  MainLoop;
};

# add slave port
sub WinAddSlave {
  slave_init("wbs" . ($slaves+1));
  $mw = MainWindow->new;
  $mw->title ("Wishbone generator");
  $frame=$mw->Frame(-label=>"Add wishbone slave port");
  # port name
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Slave port name:")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$slaves]{"wbs"})->pack(-side=>'right');
  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(-side => 'right', -fill => 'y', -expand => 'y');
  $frame->Button(-text => "add slave port", -command =>sub {WinGlobalExit(); $asp=1;})->pack ( -side => 'left');
  $frame->Button(-text => "next", -command =>sub {WinGlobalExit(); $next=1;})->pack ( -side => 'right');
  MainLoop;
};

# slave port
sub WinSlave {
  $mw = MainWindow->new;
  $mw->title ("Wishbone generator");
  $frame=$mw->Frame(-label=>"Slave port");
  # Slave port
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Slave port       :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"wbs"})->pack(-side=>'right');
  # dat_size
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Data bus size :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"dat_size"})->pack(-side=>'right');
  # adr
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "adr hi              :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"adr_i_hi"})->pack(-side=>'left');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "adr lo              :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"adr_i_lo"})->pack(-side=>'right');
  # type
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Slave type   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$slave[$i]{"type"}, -text => 'Read/Write', -value => 'rw')->pack(-side=>'left');
  $b = $frame->Radiobutton ( -variable => \$slave[$i]{"type"}, -text => 'Read only', -value => 'ro')->pack(-side=>'left');
  $c = $frame->Radiobutton ( -variable => \$slave[$i]{"type"}, -text => 'Write only', -value => 'wo')->pack(-side=>'left');
  # lock_i
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "lock_i   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$slave[$i]{"lock_i"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$slave[$i]{"lock_i"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # tga_i
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tga_i   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$slave[$i]{"tga_i"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$slave[$i]{"tga_i"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # tgc_i
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tgc_i   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$slave[$i]{"tgc_i"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$slave[$i]{"tgc_i"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # tgd_i
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "tgd_i   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$slave[$i]{"tgd_i"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$slave[$i]{"tgd_i"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # err_o
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "err_o   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$slave[$i]{"err_o"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$slave[$i]{"err_o"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # rty_o
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "rty_o   :")->pack(-side=>'left');
  $a = $frame->Radiobutton ( -variable => \$slave[$i]{"rty_o"}, -text => 'No', -value => 0)->pack( -side=>'left');
  $b = $frame->Radiobutton ( -variable => \$slave[$i]{"rty_o"}, -text => 'Yes', -value => 1 )->pack( -side=>'right');
  # ss
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Base_adr  :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"baseadr"})->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Size           :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"size"})->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Base_adr1 :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"baseadr1"})->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Size1          :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"size1"})->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Base_adr2 :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"baseadr2"})->pack(-side=>'right');
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
  $frame->Label(-text => "Size2          :")->pack(-side=>'left');
  $frame->Entry(-textvariable => \$slave[$i]{"size2"})->pack(-side=>'right');

  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(-side => 'right', -fill => 'y', -expand => 'y');
  $frame->Button(-text => "back", -command =>sub {WinGlobalExit(); $back=1;})->pack ( -side => 'left');
  $frame->Button(-text => "delete", -command =>sub {WinGlobalExit(); $del=1;})->pack ( -side => 'left');
  $frame->Button(-text => "next", -command =>sub {WinGlobalExit(); $next=1;})->pack ( -side => 'right');
  MainLoop;
};

# Prio shared bus
sub WinPrioshb {
  $mw = MainWindow->new;
  $mw->title ("Wishbone generator");
  $frame=$mw->Frame(-label=>"Priority for shared bus system")->pack();
  for ($i=1; $i le $masters; $i++) {
    $frame=$mw->Frame();
    $frame->pack(-side => 'top', -fill => 'y', -expand => 'y');
    $frame->Label(-text => $master[$i]{"wbm"})->pack(-side=>'left');
    $frame->Entry(-textvariable => \$master[$i]{"priority"})->pack(-side=>'right');
  };
  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(-side => 'right', -fill => 'y', -expand => 'y');
  $frame->Button(-text => "back", -command =>sub {WinGlobalExit(); $back=1;})->pack ( -side => 'left');
  $frame->Button(-text => "generate", -command =>sub {WinGlobalExit(); $next=1;})->pack ( -side => 'right');
  MainLoop;
};

# Prio cross bar switch
sub WinPriocbs {
  my $tmp="";
  $mw = MainWindow->new;
  $mw->title ("Wishbone generator");
  $frame=$mw->Frame(-label=>"Priority for crossbar switch bus system")->pack();
  $frame=$mw->Frame();
  $frame->pack(-side => 'top', -fill => 'x', -expand => 'y');
  $frame->Entry(-textvariable => \$tmp)->pack(-side=>'left');
  for ($j=1; $j le $slaves; $j++) {
    $frame->Entry(-textvariable => \$slave[$j]{"wbs"})->pack(-side=>'left');
  };
  for ($i=1; $i le $masters; $i++) {
    $frame=$mw->Frame();
    $frame->pack(-side => 'top', -fill => 'x', -expand => 'y');
    #$frame->Label(-text => $master[$i]{"wbm"})->pack(-side=>'left');
    $frame->Entry(-textvariable => \$master[$i]{"wbm"})->pack(-side=>'left');
    for ($j=1; $j le $slaves; $j++) {
      #$frame->Label(-text => $master[$i]{"priority_".($slave[$j]{"wbs"})})->pack(-side=>'left');
      $frame->Entry(-textvariable => \$master[$i]{"priority_".($slave[$j]{"wbs"})})->pack(-side=>'left');
    };
  };
  # exit
  $frame=$mw->Frame(-label=>"\n");
  $frame->pack(-side => 'right', -fill => 'y', -expand => 'y');
  $frame->Button(-text => "back", -command =>sub {WinGlobalExit(); $back=1;})->pack ( -side => 'left');
  $frame->Button(-text => "generate", -command =>sub {WinGlobalExit(); $next=1;})->pack ( -side => 'right');
  MainLoop;
};

# delete wishbone master
sub wbm_del {
  my $i;
  if ($_[0] != $masters) {
    for ($i=$_[0]; $i lt $masters; $i++) {
      $master[$i]=$master[$i+1];
    };
  };
  $masters--;
};

# delete wishbone slave
sub wbs_del {
  my $i;
  if ($_[0] != $slaves) {
    for ($i=$_[0]; $i lt $slaves; $i++) {
      $slave[$i]=$slave[$i+1];
    };
  };
  $slaves--;
};

# GUI FSM
sub gui_fsm {
$i=1;
until ($state eq "bye") {
  $amp=0; $asp=0; $back=0; $next=0; $del=0;
  if ($state eq 'WinGlobal') {
    WinGlobal;
    if ($amp == 1) {
      $state='WinAddMaster';
    } elsif ($asp == 1) {
      $state='WinAddSlave';
    } elsif ($next == 1) {
      $i=1;
      if ($masters == 0) {
        $state='WinAddMaster';
      } else {
        $state='WinMaster';
      };
    } else {
      $state='WinPrio';
    };
  } elsif ($state eq 'WinAddMaster') {
    WinAddMaster;
    if ($next == 1) {
      $i=1;
      $state='WinMaster';
    };
  } elsif ($state eq 'WinMaster') {
    WinMaster;
    if ($del == 1) {
      wbm_del($i);
      $state='WinGlobal';
      $i=1;
    } elsif ($asp == 1) {
      $state='WinAddSlave';
    } elsif ($next == 1) {
      if ($i == $masters) {
        $i=1;
        if ($slaves == 0) {
          $state='WinAddSlave';
        } else {
          $state='WinSlave';
        };
      } else {
        $i++
      };
    } else {
      if ($i == 1) {
        $state='WinGlobal';
      } else {
        $i--;
      }
    };
  } elsif ($state eq 'WinAddSlave') {
    WinAddSlave;
    if ($next == 1) {
      $i=1;
      $state='WinSlave';
    };
  } elsif ($state eq 'WinSlave') {
    WinSlave;
    if ($del == 1) {
      wbs_del($i);
      $i=1;
      $state='WinGlobal';
    } elsif ($next == 1) {
      if ($i eq $slaves) {
        $state='WinPrio';
      } else {
        $i++
      };
    } else {
      if ($i == 1) {
        $state='WinGlobal';
      } else {
        $i--;
      }
    };
  } elsif ($state eq 'WinPrio') {
    if ($interconnect eq "sharedbus") {
      WinPrioshb;
    } else {
      WinPriocbs;
    };
    if ($next == 1) {
      $state='bye';
    } else {
      $state='WinGlobal';
    };
  };
};
};

sub generate_defines {
  open(OUTFILE,"> $_[0]") or die "could not open $infile for writing";
  printf OUTFILE "# Generated by PERL program wishbone.pl.\n";
  printf OUTFILE "# File used as input for wishbone arbiter generation\n";
  $tmp=localtime(time);
  printf OUTFILE "# Generated %s\n\n",$tmp;
  printf OUTFILE "filename=%s\n",$outfile;
  printf OUTFILE "intercon=%s\n",$intercon;
  printf OUTFILE "syscon=%s\n",$syscon;
  printf OUTFILE "target=%s\n",$target;
  printf OUTFILE "hdl=%s\n",$hdl;
  printf OUTFILE "signal_groups=%s\n",$signal_groups;
  printf OUTFILE "tga_bits=%s\n",$tga_bits;
  printf OUTFILE "tgc_bits=%s\n",$tgc_bits;
  printf OUTFILE "tgd_bits=%s\n",$tgd_bits;
  printf OUTFILE "rename_tga=%s\n",$rename_tga;
  printf OUTFILE "rename_tgc=%s\n",$rename_tgc;
  printf OUTFILE "rename_tgd=%s\n",$rename_tgd;
  printf OUTFILE "classic=%s\n",$classic;
  printf OUTFILE "endofburst=%s\n",$endofburst;
  printf OUTFILE "dat_size=%s\n",$dat_size;
  printf OUTFILE "adr_size=%s\n",$adr_size;
  printf OUTFILE "mux_type=%s\n",$mux_type;
  printf OUTFILE "interconnect=%s\n",$interconnect;
  for ($i=1; $i <= $masters; $i++) {
    printf OUTFILE "\nmaster %s\n",$master[$i]{"wbm"};
    printf OUTFILE "  type=%s\n",$master[$i]{"type"};
    printf OUTFILE "  lock_o=%s\n",$master[$i]{"lock_o"};
    printf OUTFILE "  tga_o=%s\n",$master[$i]{"tga_o"};
    printf OUTFILE "  tgc_o=%s\n",$master[$i]{"tgc_o"};
    printf OUTFILE "  tgd_o=%s\n",$master[$i]{"tgd_o"};
    printf OUTFILE "  err_i=%s\n",$master[$i]{"err_i"};
    printf OUTFILE "  rty_i=%s\n",$master[$i]{"rty_i"};
    if ($interconnect eq "sharedbus") {
      printf OUTFILE "  priority=%s\n",$master[$i]{"priority"};
    } else {
      for ($j=1; $j <= $slaves; $j++) {
        printf OUTFILE "  priority_%s=%s\n",$slave[$j]{"wbs"},$master[$i]{"priority_".($slave[$j]{"wbs"})};
      };
    };
    printf OUTFILE "end master %s\n",$master[$i]{"wbm"};
  };
  for ($i=1; $i <= $slaves; $i++) {
    printf OUTFILE "\nslave %s\n",$slave[$i]{"wbs"};
    printf OUTFILE "  type=%s\n",$slave[$i]{"type"};
    printf OUTFILE "  adr_i_hi=%s\n",$slave[$i]{"adr_i_hi"};
    printf OUTFILE "  adr_i_lo=%s\n",$slave[$i]{"adr_i_lo"};
    printf OUTFILE "  tga_i=%s\n",$slave[$i]{"tga_i"};
    printf OUTFILE "  tgc_i=%s\n",$slave[$i]{"tgc_i"};
    printf OUTFILE "  tgd_i=%s\n",$slave[$i]{"tgd_i"};
    printf OUTFILE "  lock_i=%s\n",$slave[$i]{"lock_i"};
    printf OUTFILE "  err_o=%s\n",$slave[$i]{"err_o"};
    printf OUTFILE "  rty_o=%s\n",$slave[$i]{"rty_o"};
    printf OUTFILE "  baseadr=0x%s\n",$slave[$i]{"baseadr"};
    printf OUTFILE "  size=0x%s\n",$slave[$i]{"size"};
    printf OUTFILE "  baseadr1=0x%s\n",$slave[$i]{"baseadr1"};
    printf OUTFILE "  size1=0x%s\n",$slave[$i]{"size1"};
    printf OUTFILE "  baseadr2=0x%s\n",$slave[$i]{"baseadr2"};
    printf OUTFILE "  size2=0x%s\n",$slave[$i]{"size2"};
    printf OUTFILE "end slave %s\n",$slave[$i]{"wbs"};
  };
  close(OUTFILE);
};

# print header
sub gen_header {
  printf OUTFILE "%s Generated by PERL program wishbone.pl. Do not edit this file.\n%s\n",$comment,$comment;
  printf OUTFILE "%s For defines see %s\n%s\n",$comment,$infile,$comment;
  $tmp=localtime(time);
  printf OUTFILE "%s Generated %s\n%s\n",$comment,$tmp,$comment;
  printf OUTFILE "%s Wishbone masters:\n",$comment;
  for ($i=1; $i <= $masters; $i++) {
    printf OUTFILE "%s   %s\n",$comment,$master[$i]{"wbm"}; };
  printf OUTFILE "%s\n%s Wishbone slaves:\n",$comment,$comment;
  for ($i=1; $i <= $slaves; $i++) {
    printf OUTFILE "%s   %s\n",$comment,$slave[$i]{"wbs"};
    if (hex($slave[$i]{"size"}) != hex(ffffffff)) {
      printf OUTFILE "%s     baseadr 0x%s - size 0x%s\n",$comment,$slave[$i]{"baseadr"},$slave[$i]{"size"}};
    if (hex($slave[$i]{"size1"}) != hex(ffffffff)) {
      printf OUTFILE "%s     baseadr 0x%s - size 0x%s\n",$comment,$slave[$i]{"baseadr1"},$slave[$i]{"size1"}};
    if (hex($slave[$i]{"size2"}) != hex(ffffffff)) {
      printf OUTFILE "%s     baseadr 0x%s - size 0x%s\n",$comment,$slave[$i]{"baseadr2"},$slave[$i]{"size2"}};
    if (hex($slave[$i]{"size3"}) != hex(ffffffff)) {
      printf OUTFILE "%s     baseadr 0x%s - size 0x%s\n",$comment,$slave[$i]{"baseadr3"},$slave[$i]{"size3"}};
  };
};

sub gen_vhdl_package {
  printf OUTFILE "-----------------------------------------------------------------------------------------\n";
  printf OUTFILE "library IEEE;\nuse IEEE.std_logic_1164.all;\n\n";
  printf OUTFILE "package %s_package is\n\n",$intercon;

  # records ?
  if ($signal_groups eq 1) {
    for ($i=1; $i <= $masters; $i++) {
      # input record
      printf OUTFILE "type %s_wbm_i_type is record\n",$master[$i]{"wbm"};
      if ($master[$i]{"type"} =~ /(ro|rw)/) { printf OUTFILE "  dat_i : std_logic_vector(%s downto 0);\n",$master[$i]{"dat_size"}-1;};
      if ($master[$i]{"err_i"} == 1) { printf OUTFILE "  err_i : std_logic;\n";};
      if ($master[$i]{"rty_i"} == 1) { printf OUTFILE "  rty_i : std_logic;\n";};
      printf OUTFILE "  ack_i : std_logic;\n";
      printf OUTFILE "end record;\n";
      # output record
      printf OUTFILE "type %s_wbm_o_type is record\n",$master[$i]{"wbm"};
      if ($master[$i]{"type"} =~ /(wo|rw)/) {
        printf OUTFILE "  dat_o : std_logic_vector(%s downto 0);\n",$master[$i]{"dat_size"}-1;
        printf OUTFILE "  we_o  : std_logic;\n"; };
      if ($dat_size == 8) {
        printf OUTFILE "  sel_o : std_logic;\n";
      } else {
        printf OUTFILE "  sel_o : std_logic_vector(%s downto 0);\n",$dat_size/8-1; };
      printf OUTFILE "  adr_o : std_logic_vector(%s downto 0);\n",$adr_size-1;
      if ($master[$i]{"lock_o"} == 1) { printf OUTFILE "  lock_o : std_logic;\n";};
      if ($master[$i]{"tga_o"} == 1) { printf OUTFILE "  %s_o : std_logic_vector(%s downto 0);\n",$rename_tga, $tga_bits-1;};
      if ($master[$i]{"tgc_o"} == 1) { printf OUTFILE "  %s_o : std_logic_vector(%s downto 0);\n",$rename_tgc, $tgc_bits-1;};
      printf OUTFILE "  cyc_o : std_logic;\n";
      printf OUTFILE "  stb_o : std_logic;\n";
      printf OUTFILE "end record;\n\n";
    }; #end for
    for ($i=1; $i <= $slaves; $i++) {
      # input record
      printf OUTFILE "type %s_wbs_i_type is record\n",$slave[$i]{"wbs"};
      if ($slave[$i]{"type"} ne "ro") {
        printf OUTFILE "  dat_i : std_logic_vector(%s downto 0);\n",$slave[$i]{"dat_size"}-1;
        printf OUTFILE "  we_i  : std_logic;\n"; };
      if ($dat_size == 8) {
        printf OUTFILE "  sel_i : std_logic;\n";
      } else {
        printf OUTFILE "  sel_i : std_logic_vector(%s downto 0);\n",$dat_size/8-1; };
      if ($slave[$i]{"adr_i_hi"} > 0) { printf OUTFILE "  adr_i : std_logic_vector(%s downto %s);\n",$slave[$i]{"adr_i_hi"},$slave[$i]{"adr_i_lo"};};
      if ($slave[$i]{"tga_i"} == 1) { printf OUTFILE "  %s_i : std_logic_vector(%s downto 0);\n",$rename_tga,$tga_bits-1; };
      if ($slave[$i]{"tgc_i"} == 1) { printf OUTFILE "  %s_i : std_logic_vector(%s downto 0);\n",$rename_tgc,$tgc_bits-1; };
      printf OUTFILE "  cyc_i : std_logic;\n";
      printf OUTFILE "  stb_i : std_logic;\n";
      printf OUTFILE "end record;\n";
      # output record
      printf OUTFILE "type %s_wbs_o_type is record\n",$slave[$i]{"wbs"};
      if ($slave[$i]{"type"} =~ /(ro|rw)/) { printf OUTFILE "  dat_o : std_logic_vector(%s downto 0);\n",$slave[$i]{"dat_size"}-1 };
      if ($slave[$i]{"rty_o"} == 1) { printf OUTFILE "  rty_o : std_logic;\n" };
      if ($slave[$i]{"err_o"} == 1) { printf OUTFILE "  err_o : std_logic;\n" };
      printf OUTFILE "  ack_o : std_logic;\n";
      printf OUTFILE "end record;\n";
    }; #end for
  }; #end if signal groups

  # overload of "and"
  printf OUTFILE "\nfunction \"and\" (\n  l : std_logic_vector;\n  r : std_logic)\nreturn std_logic_vector;\n";
  printf OUTFILE "end %s_package;\n",$intercon;
  printf OUTFILE "package body %s_package is\n",$intercon;
  printf OUTFILE "\nfunction \"and\" (\n  l : std_logic_vector;\n  r : std_logic)\nreturn std_logic_vector is\n";
  printf OUTFILE "  variable result : std_logic_vector(l'range);\n";
  printf OUTFILE "begin  -- \"and\"\n  for i in l'range loop\n  result(i) := l(i) and r;\nend loop;  -- i\nreturn result;\nend \"and\";\n";
  printf OUTFILE "end %s_package;\n",$intercon;
};

sub gen_trafic_ctrl {
  if ($hdl eq "vhdl") {
  if ($target eq "xilinx") {
    print OUTFILE <<EOP;

library IEEE;
use IEEE.std_logic_1164.all;

entity trafic_supervision is

  generic (
    priority     : integer := 1;
    tot_priority : integer := 2);

  port (
    bg           : in  std_logic;       -- bus grant
    ce           : in  std_logic;       -- clock enable
    trafic_limit : out std_logic;
    clk          : in  std_logic;
    reset        : in  std_logic);

end trafic_supervision;

architecture rtl of trafic_supervision is

  signal shreg : std_logic_vector(tot_priority-1 downto 0);
  signal cntr : integer range 0 to tot_priority;

begin  -- rtl

  -- purpose: holds information of usage of latest cycles
  -- type   : sequential
  -- inputs : clk, reset, ce, bg
  -- outputs: shreg('left)
  sh_reg: process (clk)
  begin  -- process shreg
    if clk'event and clk = '1' then  -- rising clock edge
      if ce='1' then
        shreg <= shreg(tot_priority-2 downto 0) & bg;
      end if;
    end if;
  end process sh_reg;

  -- purpose: keeps track of used cycles
  -- type   : sequential
  -- inputs : clk, reset, shreg('left), bg, ce
  -- outputs: trafic_limit
  counter: process (clk, reset)
  begin  -- process counter
    if reset = '1' then                 -- asynchronous reset (active hi)
      cntr <= 0;
      trafic_limit <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if ce='1' then
        if bg='1' and shreg(tot_priority-1)/='1' then
          cntr <= cntr + 1;
          if cntr=priority-1 then
            trafic_limit <= '1';
          end if;
        elsif bg='0' and shreg(tot_priority-1)='1' then
          cntr <= cntr - 1;
          if cntr=priority then
            trafic_limit <= '0';
          end if;
        end if;
      end if;
    end if;
  end process counter;

end rtl;
EOP
  } else {
    print OUTFILE<<EOP;
library IEEE;
use IEEE.std_logic_1164.all;

entity trafic_supervision is

  generic (
    priority     : integer := 1;
    tot_priority : integer := 2);

  port (
    bg           : in  std_logic;       -- bus grant
    ce           : in  std_logic;       -- clock enable
    trafic_limit : out std_logic;
    clk          : in  std_logic;
    reset        : in  std_logic);

end trafic_supervision;

architecture rtl of trafic_supervision is

  signal shreg : std_logic_vector(tot_priority-1 downto 0);
  signal cntr : integer range 0 to tot_priority;

begin  -- rtl

  -- purpose: holds information of usage of latest cycles
  -- type   : sequential
  -- inputs : clk, reset, ce, bg
  -- outputs: shreg('left)
  sh_reg: process (clk,reset)
  begin  -- process shreg
    if reset = '1' then                 -- asynchronous reset (active hi)
      shreg <= (others=>'0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if ce='1' then
        shreg <= shreg(tot_priority-2 downto 0) & bg;
      end if;
    end if;
  end process sh_reg;

  -- purpose: keeps track of used cycles
  -- type   : sequential
  -- inputs : clk, reset, shreg('left), bg, ce
  -- outputs: trafic_limit
  counter: process (clk, reset)
  begin  -- process counter
    if reset = '1' then                 -- asynchronous reset (active hi)
      cntr <= 0;
      trafic_limit <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if ce='1' then
        if bg='1' and shreg(tot_priority-1)='0' then
          cntr <= cntr + 1;
          if cntr=priority-1 then
            trafic_limit <= '1';
          end if;
        elsif bg='0' and shreg(tot_priority-1)='1' then
          cntr <= cntr - 1;
          if cntr=priority then
            trafic_limit <= '0';
          end if;
        end if;
      end if;
    end if;
  end process counter;

end rtl;
EOP
};
} else {

};
};

sub gen_entity {
  # library usage
  printf OUTFILE "\nlibrary IEEE;\nuse IEEE.std_logic_1164.all;\n";
  printf OUTFILE "use work.%s_package.all;\n",$intercon;

  # entity intercon
  printf OUTFILE "\nentity %s is\n  port (\n",$intercon;
  # records
  if ($signal_groups eq 1) {
    # master port(s)
    printf OUTFILE "  -- wishbone master port(s)\n";
    for ($i=1; $i <= $masters; $i++) {
 	    printf OUTFILE "  -- %s\n",$master[$i]{"wbm"};
      printf OUTFILE "  %s_wbm_i : out %s_wbm_i_type;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
      printf OUTFILE "  %s_wbm_o : in  %s_wbm_o_type;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
    }; #end for
    # slave port(s)
    printf OUTFILE "  -- wishbone slave port(s)\n";
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "  -- %s\n",$slave[$i]{"wbs"};
      printf OUTFILE "  %s_wbs_i : out %s_wbs_i_type;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
      printf OUTFILE "  %s_wbs_o : in %s_wbs_o_type;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
    };
  # separate signals
  } else {
    printf OUTFILE "  -- wishbone master port(s)\n";
    for ($i=1; $i <= $masters; $i++) {
      printf OUTFILE "  -- %s\n",$master[$i]{"wbm"};
      if ($master[$i]{"type"} ne "wo") {
        printf OUTFILE "  %s_dat_i : out std_logic_vector(%s downto 0);\n",$master[$i]{"wbm"},$dat_size-1; };
      printf OUTFILE "  %s_ack_i : out std_logic;\n",$master[$i]{"wbm"};
      if ($master[$i]{"err_i"} eq 1) {
        printf OUTFILE "  %s_err_i : out std_logic;\n",$master[$i]{"wbm"}; };
      if ($master[$i]{"rty_i"} eq 1) {
        printf OUTFILE "  %s_rty_i : out std_logic;\n",$master[$i]{"wbm"}; };
      if ($master[$i]{"type"} ne "ro") {
        printf OUTFILE "  %s_dat_o : in  std_logic_vector(%s downto 0);\n",$master[$i]{"wbm"},$dat_size-1;
        printf OUTFILE "  %s_we_o  : in  std_logic;\n",$master[$i]{"wbm"};
      };
      if ($dat_size >= 16) {
        printf OUTFILE "  %s_sel_o : in  std_logic_vector(%s downto 0);\n",$master[$i]{"wbm"},$dat_size/8-1; };
      printf OUTFILE "  %s_adr_o : in  std_logic_vector(%s downto 0);\n",$master[$i]{"wbm"},$adr_size-1;
      if ($master[$i]{"tgc_o"} eq 1) {
        printf OUTFILE "  %s_%s_o : in  std_logic_vector(%s downto 0);\n",$master[$i]{"wbm"},$rename_tgc,$tgc_bits-1; };
      if ($master[$i]{"tga_o"} eq 1) {
        printf OUTFILE "  %s_%s_o : in  std_logic_vector(%s downto 0);\n",$master[$i]{"wbm"},$rename_tga,$tga_bits-1; };
      printf OUTFILE "  %s_cyc_o : in  std_logic;\n",$master[$i]{"wbm"};
      printf OUTFILE "  %s_stb_o : in  std_logic;\n",$master[$i]{"wbm"};
    };
    printf OUTFILE "  -- wishbone slave port(s)\n";
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "  -- %s\n",$slave[$i]{"wbs"};
      if ($slave[$i]{"type"} ne "wo") {
        printf OUTFILE "  %s_dat_o : in  std_logic_vector(%s downto 0);\n",$slave[$i]{"wbs"},$dat_size-1; };
      printf OUTFILE "  %s_ack_o : in  std_logic;\n",$slave[$i]{"wbs"};
      if ($slave[$i]{"err_o"} eq 1) {
        printf OUTFILE "  %s_err_o : in  std_logic;\n",$slave[$i]{"wbs"}; };
      if ($slave[$i]{"rty_o"} eq 1) {
        printf OUTFILE "  %s_rty_o : in  std_logic;\n",$slave[$i]{"wbs"}; };
      if ($slave[$i]{"type"} ne "ro") {
        printf OUTFILE "  %s_dat_i : out std_logic_vector(%s downto 0);\n",$slave[$i]{"wbs"},$dat_size-1;
        printf OUTFILE "  %s_we_i  : out std_logic;\n",$slave[$i]{"wbs"};
      };
      if ($dat_size >= 16) {
        printf OUTFILE "  %s_sel_i : out std_logic_vector(%s downto 0);\n",$slave[$i]{"wbs"},$dat_size/8-1; };
      printf OUTFILE "  %s_adr_i : out std_logic_vector(%s downto %s);\n",$slave[$i]{"wbs"},$slave[$i]{"adr_i_hi"},$slave[$i]{"adr_i_lo"};
      if ($slave[$i]{"tgc_i"} eq 1) {
        printf OUTFILE "  %s_%s_i : out std_logic_vector(%s downto 0);\n",$slave[$i]{"wbs"},$rename_tgc,$tgc_bits-1; };
      if ($slave[$i]{"tga_i"} eq 1) {
        printf OUTFILE "  %s_%s_i : out std_logic_vector(%s downto 0);\n",$slave[$i]{"wbs"},$rename_tga,$tga_bits-1; };
      printf OUTFILE "  %s_cyc_i : out std_logic;\n",$slave[$i]{"wbs"};
      printf OUTFILE "  %s_stb_i : out std_logic;\n",$slave[$i]{"wbs"};
    };
  };
  # clock and reset
  printf OUTFILE "  -- clock and reset\n";
  printf OUTFILE "  clk   : in std_logic;\n";
  printf OUTFILE "  reset : in std_logic);\n";
  printf OUTFILE "end %s;\n",$intercon;
};


# generate signals for remapping (for records)
sub gen_sig_remap {
  sub gen_sig_dec {
    if ($_[1] > 0) {
      printf OUTFILE "  signal %s : std_logic_vector(%s downto %s);\n",$_[0],$_[1]-1,$_[2];
    } else {
      printf OUTFILE "  signal %s : std_logic;\n",$_[0];
    };
  };
    for ($i=1; $i <= $masters; $i++) {
      if ($master[$i]{"type"} ne "wo") {
        gen_sig_dec($master[$i]{"wbm"}.'_dat_i',$dat_size,0); };
      gen_sig_dec($master[$i]{"wbm"}.'_ack_i');
      if ($master[$i]{"err_i"} eq 1) {
        gen_sig_dec($master[$i]{"wbm"}.'_err_i'); };
      if ($master[$i]{"rty_i"} eq 1) {
        gen_sig_dec($master[$i]{"wbm"}.'_rty_i') };
      if ($master[$i]{"type"} ne "ro") {
        gen_sig_dec($master[$i]{"wbm"}.'_dat_o',$dat_size,0);
        gen_sig_dec($master[$i]{"wbm"}.'_we_o ');
      };
      if ($dat_size > 8) {
        gen_sig_dec($master[$i]{"wbm"}.'_sel_o',$dat_size/8,0); };
      gen_sig_dec($master[$i]{"wbm"}.'_adr_o',$adr_size,0);
      if ($master[$i]{"tga_o"} eq 1) {
        gen_sig_dec($master[$i]{"wbm"}.'_'.$rename_tga.'_o',$tga_bits,0); };
      if ($master[$i]{"tgc_o"} eq 1) {
        gen_sig_dec($master[$i]{"wbm"}.'_'.$rename_tgc.'_o',$tgc_bits,0); };
      if ($master[$i]{"tgd_o"} eq 1) {
        gen_sig_dec($master[$i]{"wbm"}.'_'.$rename_tgd.'_o',$tgd_bits,0); };
      gen_sig_dec($master[$i]{"wbm"}.'_cyc_o');
      gen_sig_dec($master[$i]{"wbm"}.'_stb_o');
    };
    for ($i=1; $i <= $slaves; $i++) {
      if ($slave[$i]{"type"} ne "wo") {
        gen_sig_dec($slave[$i]{"wbs"}.'_dat_o',$dat_size,0); };
      gen_sig_dec($slave[$i]{"wbs"}.'_ack_o');
      if ($slave[$i]{"err_o"} eq 1) {
        gen_sig_dec($slave[$i]{"wbs"}.'_err_o'); };
      if ($slave[$i]{"rty_o"} eq 1) {
        gen_sig_dec($slave[$i]{"wbs"}.'_rty_o'); };
      if ($slave[$i]{"type"} ne "ro") {
        gen_sig_dec($slave[$i]{"wbs"}.'_dat_i',$dat_size,0);
        gen_sig_dec($slave[$i]{"wbs"}.'_we_i ');
      };
      if ($dat_size > 8) {
        gen_sig_dec($slave[$i]{"wbs"}.'_sel_i',$dat_size/8,0); };
      gen_sig_dec($slave[$i]{"wbs"}.'_adr_i',$slave[$i]{"adr_i_hi"}+1,$slave[$i]{"adr_i_lo"});
      if ($slave[$i]{"tga_i"} eq 1) {
        gen_sig_dec($slave[$i]{"wbs"}.'_'.$rename_tga.'_i',$tga_bits,0); };
      if ($slave[$i]{"tgc_i"} eq 1) {
        gen_sig_dec($slave[$i]{"wbs"}.'_'.$rename_tgc.'_i',$tgc_bits,0); };
      if ($slave[$i]{"tgd_i"} eq 1) {
        gen_sig_dec($slave[$i]{"wbs"}.'_'.$rename_tgd.'_i',$tgd_bits,0); };
      gen_sig_dec($slave[$i]{"wbs"}.'_cyc_i');
      gen_sig_dec($slave[$i]{"wbs"}.'_stb_i');
    };
};

sub gen_global_signals {
  # single master
  if ($masters eq 1) {
    # slave select for generation of stb_i to slaves
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "  signal %s_ss : std_logic; -- slave select\n",$slave[$i]{"wbs"}; };
  # shared bus
  } elsif ($interconnect eq "sharedbus") {
    # bus grant
    for ($i=1; $i <= $masters; $i++) {
      printf OUTFILE "  signal %s_bg : std_logic; -- bus grant\n",$master[$i]{"wbm"}; };
    # slave select for generation of stb_i to slaves
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "  signal %s_ss : std_logic; -- slave select\n",$slave[$i]{"wbs"}; };
  # crossbarswitch
  } else {
    for ($i=1; $i <= $masters; $i++) {
      for ($j=1; $j <= $slaves; $j++) {
        if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
          printf OUTFILE "  signal %s_%s_ss : std_logic; -- slave select\n",$master[$i]{"wbm"},$slave[$j]{"wbs"};
          printf OUTFILE "  signal %s_%s_bg : std_logic; -- bus grant\n",$master[$i]{"wbm"},$slave[$j]{"wbs"};
        };
      };
    };
  };
};

sub gen_arbiter {
  # out: wbm_bg (bus grant)
  if ($masters eq 1) {
    # ack_i
    # cyc_i
    # printf OUTFILE "%s_bg <= %s_cyc_o;\n",$master[1]{"wbm"},$master[1]{"wbm"};
  # sharedbus
  } elsif ($interconnect eq "sharedbus") {
    printf OUTFILE "arbiter_sharedbus: block\n";
    for ($i=1; $i <= $masters; $i++) {
      printf OUTFILE "  signal %s_bg_1, %s_bg_2, %s_bg_q : std_logic;\n",$master[$i]{"wbm"},$master[$i]{"wbm"},$master[$i]{"wbm"}; };
    for ($i=1; $i <= $masters; $i++) {
      printf OUTFILE "  signal %s_trafic_ctrl_limit : std_logic;\n",$master[$i]{"wbm"}; };
    printf OUTFILE "  signal ack, ce, idle :std_logic;\n";
    printf OUTFILE "begin -- arbiter\n";
    printf OUTFILE "ack <= %s_ack_o",$slave[1]{"wbs"};
    for ($i=2; $i <= $slaves; $i++) {
      printf OUTFILE " or %s_ack_o",$slave[$i]{"wbs"}; };
    printf OUTFILE ";\n";
    # instantiate trafic_supervision(s)
    for ($i=1; $i <= $masters; $i++) {
      printf OUTFILE "\ntrafic_supervision_%s : entity work.trafic_supervision\n",$i;
      printf OUTFILE "generic map(\n";
      printf OUTFILE "  priority => %s,\n",$master[$i]{"priority"};
      printf OUTFILE "  tot_priority => %s)\n",$priority;
      printf OUTFILE "port map(\n";
      printf OUTFILE "  bg => %s_bg,\n",$master[$i]{"wbm"};
      printf OUTFILE "  ce => ce,\n";
      printf OUTFILE "  trafic_limit => %s_trafic_ctrl_limit,\n",$master[$i]{"wbm"};
      printf OUTFILE "  clk => clk,\n";
      printf OUTFILE "  reset => reset);\n"; };
    # _bg_q
    # bg eq 1 => set
    # end of cycle => reset
    for ($i=1; $i <= $masters; $i++) {
      printf OUTFILE "\nprocess(clk,reset)\nbegin\nif reset='1' then\n";
      printf OUTFILE "  %s_bg_q <= '0';\n",$master[$i]{"wbm"};
      printf OUTFILE "elsif clk'event and clk='1' then\n";
      printf OUTFILE "if %s_bg_q='0' then\n",$master[$i]{"wbm"};
      printf OUTFILE "  %s_bg_q <= %s_bg;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
      printf OUTFILE "elsif ack='1'";
      if ($master[$i]{"tgc_o"} == 1) {
        printf OUTFILE " and (%s_%s_o=\"%s\" or %s_%s_o=\"%s\")",$master[$i]{"wbm"},$rename_tgc,$classic,$master[$i]{"wbm"},$rename_tgc,$endofburst; };
      printf OUTFILE " then\n  %s_bg_q <= '0';\nend if;\nend if;\nend process;\n",$master[$i]{"wbm"};
    }; # end for
    # _bg
    printf OUTFILE "\nidle <= '1' when %s_bg_q='0'",$master[1]{"wbm"};
    for ($i=2; $i <= $masters; $i++) {
      printf OUTFILE " and %s_bg_q='0'",$master[$i]{"wbm"}; };
    printf OUTFILE " else '0';\n";
    printf OUTFILE "%s_bg_1 <= '1' when idle='1' and %s_cyc_o='1' and %s_trafic_ctrl_limit='0' else '0';\n",$master[1]{"wbm"},$master[1]{"wbm"},$master[1]{"wbm"};
    $depend = $master[1]{"wbm"}."_bg_1='0'";
    for ($i=2; $i <= $masters; $i++) {
      printf OUTFILE "%s_bg_1 <= '1' when idle='1' and %s_cyc_o='1' and %s_trafic_ctrl_limit='0' and (%s) else '0';\n",$master[$i]{"wbm"},$master[$i]{"wbm"},$master[$i]{"wbm"},$depend;
      $depend = $depend." and ".$master[$i]{"wbm"}."_bg_1='0'";
    };

    printf OUTFILE "%s_bg_2 <= '1' when idle='1' and (%s) and %s_cyc_o='1' else '0';\n",$master[1]{"wbm"},$depend,$master[1]{"wbm"};
    $depend = $depend." and ".$master[1]{"wbm"}."_bg_2='0'";
    for ($i=2; $i <= $masters; $i++) {
      printf OUTFILE "%s_bg_2 <= '1' when idle='1' and (%s) and %s_cyc_o='1' else '0';\n",$master[$i]{"wbm"},$depend,$master[$i]{"wbm"}; 
      $depend = $depend." and ".$master[$i]{"wbm"}."_bg_2='0'";
    };
    for ($i=1; $i <= $masters; $i++) {
      printf OUTFILE "%s_bg <= %s_bg_q or %s_bg_1 or %s_bg_2;\n",$master[$i]{"wbm"},$master[$i]{"wbm"},$master[$i]{"wbm"},$master[$i]{"wbm"}; };
    # ce
    printf OUTFILE "ce <= %s_cyc_o",$master[1]{"wbm"};
    for ($i=2; $i <= $masters; $i++) {
      printf OUTFILE " or %s_cyc_o",$master[$i]{"wbm"}; };
    printf OUTFILE " when idle='1' else '0';\n\n";
    # thats it
    printf OUTFILE "end block arbiter_sharedbus;\n\n";
  # interconnect crossbarswitch
  } else {
    for ($j=1; $j <= $slaves; $j++) {
      # single master ?
      $tmp=0;
      for ($l=1; $l <= $masters; $l++) {
        if ($master[$l]{("priority_".($slave[$j]{"wbs"}))} != 0) {
          $only_master = $l;
          $tmp++;
        };
      };
      if ($tmp == 1) {
        printf OUTFILE "%s_%s_bg <= %s_%s_ss and %s_cyc_o;\n",$master[$only_master]{"wbm"},$slave[$j]{"wbs"},$master[$only_master]{"wbm"},$slave[$j]{"wbs"},$master[$only_master]{"wbm"};
      } else {
        printf OUTFILE "arbiter_%s : block\n",$slave[$j]{"wbs"};
        for ($i=1; $i <= $masters; $i++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
            printf OUTFILE "  signal %s_bg, %s_bg_1, %s_bg_2, %s_bg_q : std_logic;\n",$master[$i]{"wbm"},$master[$i]{"wbm"},$master[$i]{"wbm"},$master[$i]{"wbm"};
            printf OUTFILE "  signal %s_trafic_limit : std_logic;\n",$master[$i]{"wbm"};
          };
        };
        printf OUTFILE "  signal ce, idle, ack : std_logic;\n";
        printf OUTFILE "begin\n";
        printf OUTFILE "ack <= %s_ack_o;\n",$slave[$j]{"wbs"};
        # instantiate trafic_supervision(s)
        # calc tot priority per slave
        $priority = 0;
        for ($i=1; $i <= $masters; $i++) {
          $priority += $master[$i]{("priority_".($slave[$j]{"wbs"}))}; };
        for ($i=1; $i <= $masters; $i++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
            printf OUTFILE "\ntrafic_supervision_%s : entity work.trafic_supervision\n",$i;
            printf OUTFILE "generic map(\n";
            printf OUTFILE "  priority => %s,\n",$master[$i]{("priority_".($slave[$j]{"wbs"}))};
            printf OUTFILE "  tot_priority => %s)\n",$priority;
            printf OUTFILE "port map(\n";
            printf OUTFILE "  bg => %s_%s_bg,\n",$master[$i]{"wbm"},$slave[$j]{"wbs"};
            printf OUTFILE "  ce => ce,\n";
            printf OUTFILE "  trafic_limit => %s_trafic_limit,\n",$master[$i]{"wbm"};
            printf OUTFILE "  clk => clk,\n";
            printf OUTFILE "  reset => reset);\n";
          };
        };
        # _bg_q
        # bg eq 1 => set
        # end of cycle => reset
        for ($i=1; $i <= $masters; $i++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
            printf OUTFILE "\nprocess(clk,reset)\nbegin\nif reset='1' then\n";
            printf OUTFILE "  %s_bg_q <= '0';\n",$master[$i]{"wbm"};
            printf OUTFILE "elsif clk'event and clk='1' then\n";
            printf OUTFILE "if %s_bg_q='0' then\n",$master[$i]{"wbm"};
            printf OUTFILE "  %s_bg_q <= %s_bg;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
            printf OUTFILE "elsif ack='1'";
            if ($master[$i]{"tgc_o"} == 1) {
              printf OUTFILE " and (%s_%s_o=\"%s\" or %s_%s_o=\"%s\")",$master[$i]{"wbm"},$rename_tgc,$classic,$master[$i]{"wbm"},$rename_tgc,$endofburst; };
            printf OUTFILE " then\n  %s_bg_q <= '0';\nend if;\nend if;\nend process;\n",$master[$i]{"wbm"};
          };
        }; # end for
        # _bg
	$depend = "";
        $tmp=1; until ($master[$tmp]{("priority_".($slave[$j]{"wbs"}))} != 0) {$tmp++};
        printf OUTFILE "\nidle <= '1' when %s_bg_q='0'",$master[$tmp]{"wbm"};
        for ($i=$tmp+1; $i <= $masters; $i++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
            printf OUTFILE " and %s_bg_q='0'",$master[$i]{"wbm"};
          };
        };
        printf OUTFILE " else '0';\n";
        printf OUTFILE "%s_bg_1 <= '1' when idle='1' and %s_cyc_o='1' and %s_%s_ss='1' and %s_trafic_limit='0' else '0';\n",$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$slave[$j]{"wbs"},$master[$tmp]{"wbm"};
	$depend = $master[$tmp]{"wbm"}."_bg_1='0'",;
        for ($i=$tmp+1; $i <= $masters; $i++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
	    printf OUTFILE "%s_bg_1 <= '1' when idle='1' and (%s) and %s_cyc_o='1' and %s_%s_ss='1' and %s_trafic_limit='0' else '0';\n",$master[$i]{"wbm"},$depend,$master[$i]{"wbm"},$master[$i]{"wbm"},$slave[$j]{"wbs"},$master[$i]{"wbm"},$slave[$j]{"wbs"},$master[$i]{"wbm"};;
	    $depend = $depend." and ".$master[$i]{"wbm"}."_bg_1='0'";
          };
        };
        printf OUTFILE "%s_bg_2 <= '1' when idle='1' and (%s) and %s_cyc_o='1' and %s_%s_ss='1' else '0';\n",$master[$tmp]{"wbm"},$depend,$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$slave[$j]{"wbs"};
        $depend = $depend." and ".$master[$tmp]{"wbm"}."_bg_2='0'";
        $tmp1 = $tmp;
        for ($i=$tmp+1; $i <= $masters; $i++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
            printf OUTFILE "%s_bg_2 <= '1' when idle='1' and (%s) and %s_cyc_o='1' and %s_%s_ss='1' else '0';\n",$master[$i]{"wbm"},$depend,$master[$i]{"wbm"},$master[$i]{"wbm"},$slave[$j]{"wbs"};
          $depend = $depend." and ".$master[$i]{"wbm"}."_bg_2='0'";
          };
        };
        for ($i=1; $i <= $masters; $i++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
            printf OUTFILE "%s_bg <= %s_bg_q or %s_bg_1 or %s_bg_2;\n",$master[$i]{"wbm"},$master[$i]{"wbm"},$master[$i]{"wbm"},$master[$i]{"wbm"};
          };
        };
        # ce
        $tmp=1; until ($master[$tmp]{("priority_".($slave[$j]{"wbs"}))} != 0) {$tmp++};
        printf OUTFILE "ce <= (%s_cyc_o and %s_%s_ss)",$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$slave[$j]{"wbs"};
          for ($i=$tmp+1; $i <= $masters; $i++) {
            if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
              printf OUTFILE " or (%s_cyc_o and %s_%s_ss)",$master[$i]{"wbm"},$master[$i]{"wbm"},$slave[$j]{"wbs"};
            };
          };
        printf OUTFILE " when idle='1' else '0';\n";
        # global bg
        for ($i=1; $i <= $masters; $i++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
            printf OUTFILE "%s_%s_bg <= %s_bg;\n",$master[$i]{"wbm"},$slave[$j]{"wbs"},$master[$i]{"wbm"};
          };
        };
        printf OUTFILE "end block arbiter_%s;\n",$slave[$j]{"wbs"};
      };
    };
  }; #end if
};

sub gen_adr_decoder{
  printf OUTFILE "decoder:block\n";
  if ($interconnect eq "sharedbus") {
    printf OUTFILE "  signal adr : std_logic_vector(%s downto 0);\n",$adr_size-1;
    printf OUTFILE "begin\n";
    # adr
    printf OUTFILE "adr <= (%s_adr_o and %s_bg)",$master[1]{"wbm"},$master[1]{"wbm"};
    if ($masters > 1){
      for ($i=2; $i <= $masters; $i++) {
        printf OUTFILE " or (%s_adr_o and %s_bg)",$master[$i]{"wbm"},$master[$i]{"wbm"}; };
    };
    printf OUTFILE ";\n";
    # slave select
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "%s_ss <= '1' when adr(%s downto %s)=\"",$slave[$i]{"wbs"}, $adr_size-1,log(hex($slave[$i]{"size"}))/log(2);
      $slave[$i]{"baseadr"}=hex($slave[$i]{"baseadr"});
      for ($j=$adr_size-1; $j >= (log(hex($slave[$i]{"size"}))/log(2)); $j--) {
        if (($slave[$i]{"baseadr"}) >= (2**$j)) {
          $slave[$i]{"baseadr"} -= 2**$j;
          printf OUTFILE "1";
        } else {
          printf OUTFILE "0";
        };
      };
      printf OUTFILE "\"";
      # 1
      if (hex($slave[$i]{"size1"}) != hex("ffffffff")) {
        printf OUTFILE " else\n'1' when adr(%s downto %s)=\"",$adr_size-1,log(hex($slave[$i]{"size1"}))/log(2);
        $slave[$i]{"baseadr1"}=hex($slave[$i]{"baseadr1"});
        for ($j=$adr_size-1; $j >= (log(hex($slave[$i]{"size1"}))/log(2)); $j--) {
		      if (($slave[$i]{"baseadr1"}) >= (2**$j)) {
            $slave[$i]{"baseadr1"} -= 2**$j;
            printf OUTFILE "1";
		      } else {
		        printf OUTFILE "0";
		      }; # end if
        }; # end for
        printf OUTFILE "\"";
      };
      # 2
      if (hex($slave[$i]{"size2"}) != hex("ffffffff")) {
        printf OUTFILE " else\n'1' when adr(%s downto %s)=\"",$adr_size-1,log(hex($slave[$i]{"size2"}))/log(2);
        $slave[$i]{"baseadr2"}=hex($slave[$i]{"baseadr2"});
        for ($j=$adr_size-1; $j >= (log(hex($slave[$i]{"size2"}))/log(2)); $j--) {
		      if (($slave[$i]{"baseadr2"}) >= (2**$j)) {
		        $slave[$i]{"baseadr2"} -= 2**$j;
		        printf OUTFILE "1";
		      } else {
		        printf OUTFILE "0";
		      };
        };
        printf OUTFILE "\"";
      };
      # 3
      if (hex($slave[$i]{"size3"}) != hex("ffffffff")) {
        printf OUTFILE " else\n'1' when adr(%s downto %s)=\"",$adr_size-1,log(hex($slave[$i]{"size3"}))/log(2);
        $slave[$i]{"baseadr3"}=hex($slave[$i]{"baseadr3"});
        for ($j=$adr_size-1; $j >= (log(hex($slave[$i]{"size3"}))/log(2)); $j--) {
		      if (($slave[$i]{"baseadr3"}) >= (2**$j)) {
            $slave[$i]{"baseadr3"} -= 2**$j;
		        printf OUTFILE "1";
		      } else {
		        printf OUTFILE "0";
		      };
        };
        printf OUTFILE "\"";
      };
      printf OUTFILE " else\n'0';\n";
      # adr to slaves
    };
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "%s_adr_i <= adr(%s downto %s);\n",$slave[$i]{"wbs"},$slave[$i]{"adr_i_hi"},$slave[$i]{"adr_i_lo"}; };
  # crossbar switch
  } else {
    printf OUTFILE "begin\n";
    # master_slave_ss
#    $j=0;
    for ($i=1; $i <= $masters; $i++) {
      $slave[$j]{"baseadr"}=hex($slave[$j]{"baseadr"});
      for ($j=1; $j <= $slaves; $j++) {
        if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
        printf OUTFILE "%s_%s_ss <= '1' when %s_adr_o(%s downto %s)=\"",$master[$i]{"wbm"},$slave[$j]{"wbs"},$master[$i]{"wbm"},$adr_size-1,log(hex($slave[$j]{"size"}))/log(2);
        $tmp=hex($slave[$j]{"baseadr"});
        for ($k=$adr_size-1; $k >= (log(hex($slave[$j]{"size"}))/log(2)); $k--) {
          if ($tmp >= (2**$k)) {
            $tmp -= 2**$k;
            printf OUTFILE "1";
          } else {
            printf OUTFILE "0";
          };
        };
        printf OUTFILE "\"";
        # 2?
        if (hex($slave[$j]{"size1"}) != hex("ffffffff")) {
          printf OUTFILE " else\n'1' when %s_adr_o(%s downto %s)=\"",$master[$i]{"wbm"},$adr_size-1,log(hex($slave[$j]{"size1"}))/log(2);
          $tmp=hex($slave[$j]{"baseadr1"});
          for ($k=$adr_size-1; $k >= (log(hex($slave[$j]{"size1"}))/log(2)); $k--) {
		        if ($tmp >= (2**$k)) {
		          $tmp -= 2**$k;
		          printf OUTFILE "1";
		        } else {
		          printf OUTFILE "0";
		        };
          };
          printf OUTFILE "\"";
        };
        # 3?
        if (hex($slave[$j]{"size2"}) != hex("ffffffff")) {
          printf OUTFILE " else\n'1' when %s_adr_o(%s downto %s)=\"",$master[$i]{"wbm"},$adr_size-1,log(hex($slave[$j]{"size2"}))/log(2);
          $tmp=hex($slave[$j]{"baseadr2"});
          for ($k=$adr_size-1; $k >= (log(hex($slave[$j]{"size2"}))/log(2)); $k--) {
		        if ($tmp >= (2**$k)) {
		          $tmp -= 2**$k;
		          printf OUTFILE "1";
		        } else {
		          printf OUTFILE "0";
		        };
          };
          printf OUTFILE "\"";
        };
        printf OUTFILE " else \n'0';\n";
        }; #if
      };
    };
    # _adr_o
    for ($i=1; $i <= $slaves; $i++) {
      # mux ?
      $tmp=0;
      for ($l=1; $l <= $masters; $l++) {
        if ($master[$l]{("priority_".($slave[$i]{"wbs"}))} != 0) {
          $tmp++;
        };
      };
      if ($tmp eq 1) {
        $k=1; until ($master[$k]{("priority_".($slave[$i]{"wbs"}))} != 0) {$k++};
        printf OUTFILE "%s_adr_i <= %s_adr_o(%s downto %s);\n",$slave[$i]{"wbs"},$master[$k]{"wbm"},$slave[$i]{"adr_i_hi"},$slave[$i]{"adr_i_lo"};
      } else {
        $k=1; until ($master[$k]{("priority_".($slave[$i]{"wbs"}))} != 0) {$k++};
        printf OUTFILE "%s_adr_i <= (%s_adr_o(%s downto %s) and %s_%s_bg)",$slave[$i]{"wbs"},$master[$k]{"wbm"},$slave[$i]{"adr_i_hi"},$slave[$i]{"adr_i_lo"},$master[$k]{"wbm"},$slave[$i]{"wbs"};
        for ($j=$k+1; $j <= $masters; $j++) {
          if ($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) {
            printf OUTFILE " or (%s_adr_o(%s downto %s) and %s_%s_bg)",$master[$j]{"wbm"},$slave[$i]{"adr_i_hi"},$slave[$i]{"adr_i_lo"},$master[$j]{"wbm"},$slave[$i]{"wbs"};
          };
        };
        printf OUTFILE ";\n";
      };
    };
  };
  printf OUTFILE "end block decoder;\n\n";
};

sub gen_muxshb{
    printf OUTFILE "mux: block\n";
    printf OUTFILE "  signal cyc, stb, we, ack : std_logic;\n";
    if (($rty_i > 0) && ($rty_o > 1)) {
      printf OUTFILE "  signal rty : std_logic;\n"; };
    if (($err_i > 0) && ($err_o > 1)) {
      printf OUTFILE "  signal err : std_logic;\n"; };
    if ($dat_size eq 8) {
      printf OUTFILE "  signal sel : std_logic;\n";
    } else {
      printf OUTFILE "  signal sel : std_logic_vector(%s downto 0);\n",$dat_size/8-1;
    };
    printf OUTFILE "  signal dat_m2s, dat_s2m : std_logic_vector(%s downto 0);\n",$dat_size-1;
    if (($tgc_o > 0) && ($tgc_i > 0)) {
      printf OUTFILE "  signal tgc : std_logic_vector(%s downto 0);\n",$tgc_bits-1; };
    if (($tga_o > 0) && ($tga_i > 0)) {
      printf OUTFILE "  signal tga : std_logic_vector(%s downto 0);\n",$tga_bits-1; };
    printf OUTFILE "begin\n";
    # cyc
    printf OUTFILE "cyc <= (%s_cyc_o and %s_bg)",$master[1]{"wbm"},$master[1]{"wbm"};
    if ($masters > 1) {
      for ($i=2; $i <= $masters; $i++) {
        printf OUTFILE " or (%s_cyc_o and %s_bg)",$master[$i]{"wbm"},$master[$i]{"wbm"}; };
    };
    printf OUTFILE ";\n";
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "%s_cyc_i <= %s_ss and cyc;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"}; };
    # stb
    printf OUTFILE "stb <= (%s_stb_o and %s_bg)",$master[1]{"wbm"},$master[1]{"wbm"};
    if ($masters > 1) {
      for ($i=2; $i <= $masters; $i++) {
        printf OUTFILE " or (%s_stb_o and %s_bg)",$master[$i]{"wbm"},$master[$i]{"wbm"}; };
    };
    printf OUTFILE ";\n";
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "%s_stb_i <= stb;\n",$slave[$i]{"wbs"}; };
    # we
    $i=1; until ($master[$i]{"type"} ne "ro") {$i++};
    printf OUTFILE "we <= (%s_we_o and %s_bg)",$master[$i]{"wbm"},$master[$i]{"wbm"};
    if ($i < $masters) {
      for ($j=$i+1; $j <= $masters; $j++) {
        if ($master[$j]{"type"} ne "ro") {
          printf OUTFILE " or (%s_we_o and %s_bg)",$master[$j]{"wbm"},$master[$j]{"wbm"};
        };
      };
    };
    printf OUTFILE ";\n";
    for ($i=1; $i <= $slaves; $i++) {
      if ($slave[$i]{"type"} ne "ro") {
        printf OUTFILE "%s_we_i <= we;\n",$slave[$i]{"wbs"};
      };
    };
    # ack
    printf OUTFILE "ack <= %s_ack_o",$slave[1]{"wbs"};
    for ($i=2; $i <= $slaves; $i++) {
      printf OUTFILE " or %s_ack_o",$slave[$i]{"wbs"}; };
    printf OUTFILE ";\n";
    for ($i=1; $i <= $masters; $i++) {
      printf OUTFILE "%s_ack_i <= ack and %s_bg;\n",$master[$i]{"wbm"},$master[$i]{"wbm"}; };
    # rty
    if (($rty_o == 0) && ($rty_i > 0)) {
      for ($i=1; $i <= $masters; $i++) {
        if ($master[$i]{"rty_i"} == 1) {
          printf OUTFILE "%s_rty_i <= '0';\n",$master[$i]{"wbm"};
        };
      };
    } elsif (($rty_o == 1) && ($rty_i > 0)) {
      $i=1; until ($slave[$i]{"rty_o"} == 1) {$i++};
      for ($j=1; $j <= $masters; $j++) {
        if ($master[$j]{"rty_i"} == 1) {
          printf OUTFILE "%s_rty_i <= %s_rty_o;\n",$master[$j]{"wbm"},$slave[$i]{"wbs"};
        };
      };
    } elsif (($rty_o > 1) && ($rty_i > 0)) {
      $i=1; until ($slave[$i]{"rty_o"} == 1) {$i++};
      printf OUTFILE "rty <= %s_rty_o",$slave[$i]{"wbs"};
      for ($j=$i+1; $j <= $slaves; $j++) {
        if ($slave[$j]{"rty_o"} == 1) {
          printf OUTFILE " or %s_rty_o",$slave[$j]{"wbs"};
        };
      };
      printf OUTFILE ";\n";
      for ($i=1; $i <= $masters; $i++) {
        if ($master[$i]{"rty_i"} == 1) {
          printf OUTFILE "%s_rty_i <= rty;\n",$master[$i]{"wbm"};
        };
      };
    };
    # err
    if (($err_o == 0) && ($err_i > 0)) {
      for ($i=1; $i <= $masters; $i++) {
        if ($master[$i]{"err_i"} == 1) {
          printf OUTFILE "%s_err_i <= '0';\n",$master[$i]{"wbm"};
        };
      };
    } elsif (($err_o == 1) && ($err_i > 0)) {
      $i=1; until ($slave[$i]{"err_o"} == 1) {$i++};
      for ($j=1; $j <= $masters; $j++) {
        if ($master[$j]{"err_i"} == 1) {
          printf OUTFILE "%s_err_i <= %s_err_o;\n",$master[$j]{"wbm"},$slave[$i]{"wbs"};
        };
      };
    } elsif (($err_o > 1) && ($err_i > 0)) {
      $i=1; until ($slave[$i]{"err_o"} == 1) {$i++};
      printf OUTFILE "err <= %s_err_o",$slave[$i]{"wbs"};
      for ($j=$i+1; $j <= $slaves; $j++) {
        if ($slave[$j]{"err_o"} == 1) {
          printf OUTFILE " or %s_err_o",$slave[$j]{"wbs"};
        };
      };
      printf OUTFILE ";\n";
      for ($i=1; $i <= $masters; $i++) {
        if ($master[$i]{"err_i"} == 1) {
          printf OUTFILE "%s_err_i <= err;\n",$master[$i]{"wbm"};
        };
      };
    };
    # sel
    printf OUTFILE "sel <= (%s_sel_o and %s_bg)",$master[1]{"wbm"},$master[1]{"wbm"};
    if ($masters > 1) {
      for ($i=2; $i <= $masters; $i++) {
        printf OUTFILE " or (%s_sel_o and %s_bg)",$master[$i]{"wbm"},$master[$i]{"wbm"};
      };
    };
    printf OUTFILE ";\n";
    for ($i=1; $i <= $slaves; $i++) {
      printf OUTFILE "%s_sel_i <= sel;\n",$slave[$i]{"wbs"}; };
    # data m2s
    $i=1; until ($master[$i]{"type"} ne "ro") {$i++};
    printf OUTFILE "dat_m2s <= (%s_dat_o and %s_bg)",$master[$i]{"wbm"},$master[$i]{"wbm"};
    if ($i < $masters) {
      for ($j=$i+1; $j <= $masters; $j++) {
        printf OUTFILE " or (%s_dat_o and %s_bg)",$master[$j]{"wbm"},$master[$j]{"wbm"};
      };
    };
    printf OUTFILE ";\n";
    for ($i=1; $i <= $slaves; $i++) {
      if ($slave[$i]{"type"} ne "ro") {
        printf OUTFILE "%s_dat_i <= dat_m2s;\n",$slave[$i]{"wbs"};
      };
    };
    # data s2m
    $i=1; until ($slave[$i]{"type"} ne "wo") {$i++};
    printf OUTFILE "dat_s2m <= (%s_dat_o and %s_ss)",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
    if ($i < $slaves) {
      for ($j=$i+1; $j <= $slaves; $j++) {
        printf OUTFILE " or (%s_dat_o and %s_ss)",$slave[$j]{"wbs"},$slave[$j]{"wbs"};
      };
    };
    printf OUTFILE ";\n";
    for ($i=1; $i <= $masters; $i++) {
      if ($master[$i]{"type"} ne "wo") {
        printf OUTFILE "%s_dat_i <= dat_s2m;\n",$master[$i]{"wbm"};
      };
    };
    # tgc
    if (($tgc_o == 0) && ($tgc_i > 0)) {
      for ($i=1; $i <= $slaves; $i++) {
        if ($slave[$i]{"tgc_i"} == 1) {
          printf OUTFILE "%s_%s_i <= %s;\n",$slave[$i]{"wbs"},$rename_tgc,$classic;
        };
      };
    } elsif (($tgc_o > 0) && ($tgc_i > 0)) {
      $i=1; until ($master[$i]{"tgc_o"} == 1) {$i++};
      printf OUTFILE "tgc <= (%s_%s_o and %s_bg)",$master[$i]{"wbm"},$rename_tgc,$master[$i]{"wbm"};
      for ($j=$i+1; $j <= $masters; $j++) {
        if ($master[$j]{"tgc_o"} == 1) {
          printf OUTFILE " or (%s_%s_o and %s_bg)",$master[$j]{"wbm"},$rename_tgc,$master[$j]{"wbm"};
        };
      };
      printf OUTFILE ";\n";
      for ($i=1; $i <= $slaves; $i++) {
        if ($slave[$i]{"tgc_i"} ==  1) {
          printf OUTFILE "%s_%s_i <= tgc;\n",$slave[$i]{"wbs"},$rename_tgc,$slave[$i]{"wbs"};
        };
      };
    };
    # tga
    if (($tga_o == 0) && ($tga_i > 0)) {
      for ($i=1; $i <= $slaves; $i++) {
        if ($slave[$i]{"tga_i"} == 1) {
          printf OUTFILE "%s_%s_i <= (others=>'0');\n",$slave[$i]{"wbs"},$rename_tga;
        };
      };
    } elsif (($tga_o > 0) && ($tga_i > 0)) {
      $i=1; until ($master[$i]{"tga_o"} == 1) {$i++};
      printf OUTFILE "tga <= (%s_%s_o and %s_bg)",$master[$i]{"wbm"},$rename_tga,$master[$i]{"wbm"};
      for ($j=$i+1; $j <= $masters; $j++) {
        if ($master[$j]{"tga_o"} == 1) {
          printf OUTFILE " or (%s_%s_o and %s_bg)",$master[$j]{"wbm"},$rename_tga,$master[$j]{"wbm"};
        };
      };
      printf OUTFILE ";\n";
      for ($i=1; $i <= $slaves; $i++) {
        if ($slave[$i]{"tga_i"} == 1) {
          printf OUTFILE "%s_%s_i <= tga;\n",$slave[$i]{"wbs"},$rename_tga,$slave[$i]{"wbs"};
        };
      };
    };
    # end block
    printf OUTFILE "end block mux;\n\n";
};

sub gen_muxcbs{
    # cyc
    printf OUTFILE "-- cyc_i(s)\n";
    for ($i=1; $i <= $slaves; $i++) {
      $tmp=1; until ($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) {$tmp++};
      printf OUTFILE "%s_cyc_i <= (%s_cyc_o and %s_%s_bg)",$slave[$i]{"wbs"},$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$slave[$i]{"wbs"};
      for ($j=$tmp+1; $j <= $masters; $j++) {
        if ($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) {
          printf OUTFILE " or (%s_cyc_o and %s_%s_bg)",$master[$j]{"wbm"},$master[$j]{"wbm"},$slave[$i]{"wbs"};
        };
      };
      printf OUTFILE ";\n";
    };
    # stb
    printf OUTFILE "-- stb_i(s)\n";
    for ($i=1; $i <= $slaves; $i++) {
      $tmp=1; until ($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) {$tmp++};
      printf OUTFILE "%s_stb_i <= (%s_stb_o and %s_%s_bg)",$slave[$i]{"wbs"},$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$slave[$i]{"wbs"};
      for ($j=$tmp+1; $j <= $masters; $j++) {
        if ($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) {
          printf OUTFILE " or (%s_stb_o and %s_%s_bg)",$master[$j]{"wbm"},$master[$j]{"wbm"},$slave[$i]{"wbs"};
        };
      };
      printf OUTFILE ";\n";
    };
    # we
    printf OUTFILE "-- we_i(s)\n";
    for ($i=1; $i <= $slaves; $i++) {
      if ($slave[$i]{"type"} ne "ro") {
        $tmp=1; until (($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) && ($master[$tmp]{"type"} ne "ro")) {$tmp++};
        printf OUTFILE "%s_we_i <= (%s_we_o and %s_%s_bg)",$slave[$i]{"wbs"},$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$slave[$i]{"wbs"};
        for ($j=$tmp+1; $j <= $masters; $j++) {
          if (($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) && ($master[$j]{"type"} ne "ro")) {
            printf OUTFILE " or (%s_we_o and %s_%s_bg)",$master[$j]{"wbm"},$master[$j]{"wbm"},$slave[$i]{"wbs"};
          };
        };
        printf OUTFILE ";\n";
      };
    };
    # ack
    printf OUTFILE "-- ack_i(s)\n";
    for ($i=1; $i <= $masters; $i++) {
      $tmp=1; until ($master[$i]{("priority_".($slave[$tmp]{"wbs"}))} != 0) {$tmp++};
      printf OUTFILE "%s_ack_i <= (%s_ack_o and %s_%s_bg)",$master[$i]{"wbm"},$slave[$tmp]{"wbs"},$master[$i]{"wbm"},$slave[$tmp]{"wbs"};
      for ($j=$tmp+1; $j <= $slaves; $j++) {
        if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
          printf OUTFILE " or (%s_ack_o and %s_%s_bg)",$slave[$j]{"wbs"},$master[$i]{"wbm"},$slave[$j]{"wbs"};
        };
      };
      printf OUTFILE ";\n";
    };
    # rty
    printf OUTFILE "-- rty_i(s)\n";
    for ($i=1; $i <= $masters; $i++) {
      if ($master[$i]{"rty_i"} == 1) {
        $rty_o=0;
        for ($j=1; $j <= $masters; $j++) {
          if (($slave[$j]{"rty_o"} == 1) && ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0)) {
            $rty_o+=1;
          };
        };
        if ($rty_o == 0) {
          printf OUTFILE "%s_rty_i <= '0';\n",$master[$i]{"wbm"};
        } else {
          $tmp=1; until ($master[$i]{("priority_".($slave[$tmp]{"wbs"}))} != 0) {$tmp++};
          printf OUTFILE "%s_rty_i <= (%s_rty_o and %s_%s_bg)",$master[$i]{"wbm"},$slave[$tmp]{"wbs"},$master[$i]{"wbm"},$slave[$tmp]{"wbs"};
          for ($j=$tmp+1; $j <= $slaves; $j++) {
            if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
              printf OUTFILE " or (%s_rty_o and %s_%s_bg)",$slave[$j]{"wbs"},$master[$i]{"wbm"},$slave[$j]{"wbs"};
            };
          };
          printf OUTFILE ";\n";
        };
      };
    };
    # err
    printf OUTFILE "-- err_i(s)\n";
    for ($i=1; $i <= $masters; $i++) {
      if ($master[$i]{"err_i"} == 1) {
        $err_o=0;
        for ($j=1; $j <= $masters; $j++) {
          if (($slave[$j]{"err_o"} == 1) && ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0)) {
            $err_o+=1;
          };
        };
        if ($err_o == 0) {
          printf OUTFILE "%s_err_i <= '0';\n",$master[$i]{"wbm"};
        } else {
          $tmp=1; until ($master[$i]{("priority_".($slave[$tmp]{"wbs"}))} != 0) {$tmp++};
          printf OUTFILE "%s_err_i <= (%s_err_o and %s_%s_bg)",$master[$i]{"wbm"},$slave[$tmp]{"wbs"},$master[$i]{"wbm"},$slave[$tmp]{"wbs"};
          for ($j=$tmp+1; $j <= $slaves; $j++) {
            if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
              printf OUTFILE " or (%s_err_o and %s_%s_bg)",$slave[$j]{"wbs"},$master[$i]{"wbm"},$slave[$j]{"wbs"};
            };
          };
          printf OUTFILE ";\n";
        };
      };
    };
    # sel
    printf OUTFILE "-- sel_i(s)\n";
    for ($i=1; $i <= $slaves; $i++) {
      if ($dat_size >= 16) {
        $tmp=1; until ($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) {$tmp++};
        printf OUTFILE "%s_sel_i <= (%s_sel_o and %s_%s_bg)",$slave[$i]{"wbs"},$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$slave[$i]{"wbs"};
        for ($j=$tmp+1; $j <= $masters; $j++) {
          if ($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) {
            printf OUTFILE " or (%s_sel_o and %s_%s_bg)",$master[$j]{"wbm"},$master[$j]{"wbm"},$slave[$i]{"wbs"};
          };
        };
        printf OUTFILE ";\n";
      };
    };
    # dat
    printf OUTFILE "-- slave dat_i(s)\n";
    for ($i=1; $i <= $slaves; $i++) {
      if ($slave[$i]{"type"} ne "ro") {
        $tmp=0;
        for ($j=1; $j <= $masters; $j++) {
          if (($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) && ($master[$j]{"type"} ne "ro")) {
            $tmp+=1;
          };
        };
        if ($tmp == 1) {
          $j=1; until (($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) && ($master[$j]{"type"} ne "ro")) {$j++};
          printf OUTFILE "%s_dat_i <= %s_dat_o;\n",$slave[$i]{"wbs"},$master[$j]{"wbm"};
        } elsif ($tmp >= 1) {
          $tmp=1; until (($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) && ($master[$tmp]{"type"} ne "ro")) {$tmp++};
          printf OUTFILE "%s_dat_i <= (%s_dat_o and %s_%s_bg)",$slave[$i]{"wbs"},$master[$tmp]{"wbm"},$master[$tmp]{"wbm"},$slave[$i]{"wbs"};
          for ($j=$tmp+1; $j <= $masters; $j++) {
            if (($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) && ($master[$j]{"type"} ne "ro")) {
              printf OUTFILE " or (%s_dat_o and %s_%s_bg)",$master[$j]{"wbm"},$master[$j]{"wbm"},$slave[$i]{"wbs"};
            };
          };
          printf OUTFILE ";\n";
        };
      };
    };
    printf OUTFILE "-- master dat_i(s)\n";
    for ($i=1; $i <= $masters; $i++) {
      if ($master[$i]{"type"} ne "wo") {
        $tmp=0;
        for ($j=1; $j <= $slaves; $j++) {
          if ($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) {
            $tmp+=1;
          };
        };
        if ($tmp == 1) {
          $tmp=1; until ($master[$i]{("priority_".($slave[$tmp]{"wbs"}))} != 0) {$tmp++};
          printf OUTFILE "%s_dat_i <= %s_dat_o",$master[$i]{"wbm"},$slave[$tmp]{"wbs"};
        } else {
          $tmp=1; until ($master[$i]{("priority_".($slave[$tmp]{"wbs"}))} != 0) {$tmp++};
          printf OUTFILE "%s_dat_i <= (%s_dat_o and %s_%s_bg)",$master[$i]{"wbm"},$slave[$tmp]{"wbs"},$master[$i]{"wbm"},$slave[$tmp]{"wbs"};
          for ($j=$tmp+1; $j <= $slaves; $j++) {
            if (($master[$i]{("priority_".($slave[$j]{"wbs"}))} != 0) && ($master[$i]{"type"} ne "wo")) {
              printf OUTFILE " or (%s_dat_o and %s_%s_bg)",$slave[$j]{"wbs"},$master[$i]{"wbm"},$slave[$j]{"wbs"};
            };
          };
        };
        printf OUTFILE ";\n";
      };
    };
    # tgc
    printf OUTFILE "-- tgc_i\n";
    for ($i=1; $i <= $slaves; $i++) {
      if ($slave[$i]{"tgc_i"} == 1) {
        $tmp=0;
        for ($j=1; $j <= $masters; $j++) {
          if ($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) {
            $tmp+=1;
          };
        };
        if ($tmp == 1) {
          $tmp=1; until ($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) {$tmp++;};
          printf OUTFILE "%s_%s_i <= %s_%s_o",$slave[$i]{"wbs"},$rename_tgc,$master[$tmp]{"wbm"},$rename_tgc;
        } else {
          $tmp=1; until ($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) {$tmp++;};
          printf OUTFILE "%s_%s_i <= (%s_%s_o and %s_%s_bg)",$slave[$i]{"wbs"},$rename_tgc,$master[$tmp]{"wbm"},$rename_tgc,$master[$tmp]{"wbm"},$slave[$i]{"wbs"};
          for ($j=$tmp+1; $j <= $masters; $j++) {
            if ($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) {
	      if ($master[$j]{"tga_o"} == 1) {
                printf OUTFILE " or (%s_%s_o and %s_%s_bg)",$master[$j]{"wbm"},$rename_tgc,$master[$j]{"wbm"},$slave[$i]{"wbs"};
	      } else {
		if ($classic ne "000") {
		  printf OUTFILE " or \"%s\"",$classic;
	        };
	      };

            };
          };
        };
        printf OUTFILE ";\n";
      };
    };
    # tga
    printf OUTFILE "-- tga_i\n";
    for ($i=1; $i <= $slaves; $i++) {
      if ($slave[$i]{"tga_i"} == 1) {
        $tmp=0;
        for ($j=1; $j <= $masters; $j++) {
          if ($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) {
            $tmp+=1;
          };
        };
        if ($tmp == 1) {
          $tmp=1; until ($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) {$tmp++;};
          printf OUTFILE "%s_%s_i <= %s_%s_o",$slave[$i]{"wbs"},$rename_tga,$master[$tmp]{"wbm"},$rename_tga;
        } else {
          $tmp=1; until ($master[$tmp]{("priority_".($slave[$i]{"wbs"}))} != 0) {$tmp++;};
          printf OUTFILE "%s_%s_i <= (%s_%s_o and %s_%s_bg)",$slave[$i]{"wbs"},$rename_tga,$master[$tmp]{"wbm"},$rename_tga,$master[$tmp]{"wbm"},$slave[$i]{"wbs"};
          for ($j=$tmp+1; $j <= $masters; $j++) {
            if ($master[$j]{("priority_".($slave[$i]{"wbs"}))} != 0) {
	      if ($master[$j]{"tga_o"} == 1) {
                printf OUTFILE " or (%s_%s_o and %s_%s_bg)",$master[$j]{"wbm"},$rename_tga,$master[$j]{"wbm"},$slave[$i]{"wbs"};
	      };
            };
          };
        };
        printf OUTFILE ";\n";
      };
    };
};

sub gen_remap{
    for ($i=1; $i <= $masters; $i++) {
      if ($master[$i]{"type"} ne "wo") {
        printf OUTFILE "%s_wbm_i.dat_i <= %s_dat_i;\n",$master[$i]{"wbm"},$master[$i]{"wbm"}; };
      printf OUTFILE "%s_wbm_i.ack_i <= %s_ack_i ;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
      if ($master[$i]{"err_i"} == 1) {
        printf OUTFILE "%s_wbm_i.err_i <= %s_err_i;\n",$master[$i]{"wbm"},$master[$i]{"wbm"}; };
      if ($master[$i]{"rty_i"} == 1) {
        printf OUTFILE "%s_wbm_i.rty_i <= %s_rty_i;\n",$master[$i]{"wbm"},$master[$i]{"wbm"}; };
      if ($master[$i]{"type"} ne "ro") {
        printf OUTFILE "%s_dat_o <= %s_wbm_o.dat_o;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
        printf OUTFILE "%s_we_o  <= %s_wbm_o.we_o;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
      };
      printf OUTFILE "%s_sel_o <= %s_wbm_o.sel_o;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
      printf OUTFILE "%s_adr_o <= %s_wbm_o.adr_o;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
      if ($master[$i]{"tgc_o"} == 1) {
        printf OUTFILE "%s_%s_o <= %s_wbm_o.%s_o;\n",$master[$i]{"wbm"},$rename_tgc,$master[$i]{"wbm"},$rename_tgc; };
      if ($master[$i]{"tga_o"} == 1) {
        printf OUTFILE "%s_%s_o <= %s_wbm_o.%s_o;\n",$master[$i]{"wbm"},$rename_tga,$master[$i]{"wbm"},$rename_tga; };
      printf OUTFILE "%s_cyc_o <= %s_wbm_o.cyc_o;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
      printf OUTFILE "%s_stb_o <= %s_wbm_o.stb_o;\n",$master[$i]{"wbm"},$master[$i]{"wbm"};
    };
    for ($i=1; $i <= $slaves; $i++) {
      if ($slave[$i]{"type"} ne "wo") {
        printf OUTFILE "%s_dat_o <= %s_wbs_o.dat_o;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"}; };
      printf OUTFILE "%s_ack_o <= %s_wbs_o.ack_o;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
      if ($slave[$i]{"err_o"} == 1) {
        printf OUTFILE "%s_err_o <= %s_wbs_o.err_o;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"}; };
      if ($slave[$i]{"rty_o"} == 1) {
        printf OUTFILE "%s_rty_o <= %s_wbs_o.rty_o;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"}; };
      if ($slave[$i]{"type"} ne "ro") {
        printf OUTFILE "%s_wbs_i.dat_i <= %s_dat_i;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
        printf OUTFILE "%s_wbs_i.we_i  <= %s_we_i;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
      };
      printf OUTFILE "%s_wbs_i.sel_i <= %s_sel_i;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
      printf OUTFILE "%s_wbs_i.adr_i <= %s_adr_i;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
      if ($slave[$i]{"tgc_i"} == 1) {
        printf OUTFILE "%s_wbs_i.%s_i <= %s_%s_i;\n",$slave[$i]{"wbs"},$rename_tgc,$slave[$i]{"wbs"},$rename_tgc; };
      if ($slave[$i]{"tga_i"} == 1) {
        printf OUTFILE "%s_wbs_i.%s_i <= %s_%s_i;\n",$slave[$i]{"wbs"},$rename_tga,$slave[$i]{"wbs"},$rename_tga; };
      printf OUTFILE "%s_wbs_i.cyc_i <= %s_cyc_i;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
      printf OUTFILE "%s_wbs_i.stb_i <= %s_stb_i;\n",$slave[$i]{"wbs"},$slave[$i]{"wbs"};
    };
};

# GUI
$tmp=shift;
if ($tmp eq "-nogui") {
  $infile = shift;
  read_defines($infile);
} else {
  if ($tmp ne <undef>) {
    $infile=$tmp;
    read_defines($infile);
  };
  gui_fsm;
  generate_defines($infile);
  read_defines($infile);
};

# main
open(OUTFILE,">$outfile$ext") or die "could not write to $outfile$ext";
gen_header;
if ($hdl eq 'vhdl') {
  gen_vhdl_package;
  gen_trafic_ctrl;
  gen_entity;
  printf OUTFILE "architecture rtl of %s is\n",$intercon;
  if ($signal_groups == 1) { gen_sig_remap; };
  gen_global_signals;
  printf OUTFILE "begin  -- rtl\n";
  gen_arbiter;
  gen_adr_decoder;
  if ($interconnect eq 'sharedbus') {
    gen_muxshb;
  } else {
    gen_muxcbs;
  };
  if ($signal_groups == 1) { gen_remap; };
  printf OUTFILE "end rtl;";
} else {
  
};
close(OUTFILE);
