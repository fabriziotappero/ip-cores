#!/usr/bin/perl

%sparc_cfg = (

# Synthesis options 

    CONFIG_CFG_NAME => "config",
    CFG_SYN_TARGET_TECH => "gen",
    CONFIG_SYN_INFER_PADS => 0,
    CONFIG_SYN_INFER_PCI_PADS => 0,
    CONFIG_SYN_INFER_RAM => 0,
    CONFIG_SYN_INFER_ROM => 0,
    CONFIG_SYN_INFER_REGF => 0,
    CONFIG_SYN_INFER_MULT => 0,
    CONFIG_SYN_RFTYPE => 1,
    CONFIG_TARGET_CLK => "gen",
    CONFIG_PLL_CLK_MUL => 1,
    CONFIG_PLL_CLK_DIV => 1,
    CONFIG_PCI_CLKDLL => 0,
    CONFIG_PCI_SYSCLK => 0,
    
# IU options 
    
    CONFIG_IU_NWINDOWS => 8,
    CFG_IU_MUL_TYPE => "none",
    CFG_IU_DIVIDER => "none",
    CONFIG_IU_MUL_MAC => 0,
    CONFIG_IU_MULPIPE => 0,
    CONFIG_IU_FASTJUMP => 0,
    CONFIG_IU_ICCHOLD => 0,
    CONFIG_IU_FASTDECODE => 0,
    CONFIG_IU_RFPOW => 0,
    CONFIG_IU_LDELAY => 1,
    CONFIG_IU_WATCHPOINTS => 0,
    CONFIG_IU_IMPL => 0,
    CONFIG_IU_VER => 0,
    
# FPU config 
    
    CONFIG_FPU_ENABLE => 0,
    CFG_FPU_CORE => "meiko",
    CFG_FPU_IF => "none",
    CONFIG_FPU_REGS => 32,
    CONFIG_FPU_VER => 0,
    
# CP config 
    
    CONFIG_CP_CFG => "cp_none",
    
# cache configuration */
    
    CFG_ICACHE_SZ => 2,
    CFG_ICACHE_LSZ => 16,
    CFG_ICACHE_ASSO => 1,
    CFG_ICACHE_ALGO => "rnd",
    CFG_ICACHE_LOCK => 0,
    CFG_DCACHE_SZ => 1,
    CFG_DCACHE_LSZ => 16,
    CFG_DCACHE_SNOOP => "none",
    CFG_DCACHE_ASSO => 1,
    CFG_DCACHE_ALGO => "rnd",
    CFG_DCACHE_LOCK => 0,
    CFG_DCACHE_RFAST => false,
    CFG_DCACHE_WFAST => false,
    CFG_DCACHE_LRAM  => false,
    CFG_DCACHE_LRSZ => 1,
    CFG_DCACHE_LRSTART => 0x143,
    
# MMU config 
    
    CFG_MMU_ENABLE => 0,
    CFG_MMU_TYPE => "combinedtlb",
    CFG_MMU_REP => "replruarray",
    CFG_MMU_I => 8,
    CFG_MMU_D => 8,
    CFG_MMU_DIAG => 0,
    
# Memory controller config
    
    CONFIG_MCTRL_8BIT => 0,
    CONFIG_MCTRL_16BIT => 0,
    CONFIG_MCTRL_5CS => 0,
    CONFIG_MCTRL_WFB => 0,
    CONFIG_MCTRL_SDRAM => 0,
    CONFIG_MCTRL_SDRAM_INVCLK => 0,
    
# Peripherals 
    CONFIG_PERI_LCONF => 0,
    CONFIG_PERI_AHBSTAT => 0,
    CONFIG_PERI_WPROT => 0,
    CONFIG_PERI_WDOG => 0,
    CONFIG_PERI_IRQ2 => 0,
    
# AHB 
    
    CONFIG_AHB_DEFMST => 0,
    CONFIG_AHB_SPLIT => 0,
    CONFIG_AHBRAM_ENABLE => 0,
    CFG_AHBRAM_SZ => 4,
    
# Debug 
    CONFIG_DEBUG_UART => 0,
    CONFIG_DEBUG_IURF => 0,
    CONFIG_DEBUG_FPURF => 0,
    CONFIG_DEBUG_NOHALT => 0,
    CFG_DEBUG_PCLOW =>  2,
    CONFIG_DEBUG_RFERR =>  0,
    CONFIG_DEBUG_CACHEMEMERR =>  0,
    
# DSU 
    CONFIG_DSU_ENABLE =>  0,
    CONFIG_DSU_TRACEBUF =>  0,
    CONFIG_DSU_MIXED_TRACE =>  0,
    CONFIG_SYN_TRACE_DPRAM =>  0,
    CFG_DSU_TRACE_SZ =>  64,
    
# Boot 
    CFG_BOOT_SOURCE =>  "memory",
    CONFIG_BOOT_RWS =>  0,
    CONFIG_BOOT_WWS =>  0,
    CONFIG_BOOT_SYSCLK =>  25000000,
    CONFIG_BOOT_BAUDRATE =>  19200,
    CONFIG_BOOT_EXTBAUD =>  0,
    CONFIG_BOOT_PROMABITS =>  11,
    
# Ethernet 
    CONFIG_ETH_ENABLE =>  0,
    CONFIG_ETH_TXFIFO =>  8,
    CONFIG_ETH_RXFIFO =>  8,
    CONFIG_ETH_BURST =>  4,
    
# PCI 
    
    CFG_PCI_CORE =>  "none",
    CONFIG_PCI_ENABLE =>  0,
    CONFIG_PCI_VENDORID =>  0,
    CONFIG_PCI_DEVICEID =>  0,
    CONFIG_PCI_SUBSYSID =>  0,
    CONFIG_PCI_REVID =>  0,
    CONFIG_PCI_CLASSCODE =>  0,
    CFG_PCI_FIFO =>  8,
    CONFIG_PCI_PMEPADS =>  0,
    CONFIG_PCI_P66PAD =>  0,
    CONFIG_PCI_RESETALL =>  0,
    CONFIG_PCI_ARBEN =>  0
);

$ahbmst = 1;
$pciahbmst = 0; 
$pciahbslv = 0; 
		



%sparc_map = 
   (
    CFG_SYN_TARGET_TECH => 
    [
	  CONFIG_SYN_GENERIC => "gen",
	  CONFIG_SYN_ATC35 => "atc35",
	  CONFIG_SYN_ATC25 => "atc25",
	  CONFIG_SYN_ATC18 => "atc18",
	  CONFIG_SYN_FS90 => "fs90",
	  CONFIG_SYN_UMC018 => "umc18",
	  CONFIG_SYN_TSMC025 => "tsmc25",
	  CONFIG_SYN_PROASIC => "proasic",
	  CONFIG_SYN_AXCEL => "axcel",
	  CONFIG_SYN_VIRTEX => "virtex",
	  CONFIG_SYN_VIRTEX2 => "virtex2"
    ],

    CONFIG_SYN_INFER_PADS => [ CONFIG_SYN_INFER_PADS => 1 ],
    CONFIG_SYN_INFER_PCI_PADS => [ CONFIG_SYN_INFER_PCI_PADS =>  1 ],
    CONFIG_SYN_INFER_RAM => [ CONFIG_SYN_INFER_RAM => 1 ],
    CONFIG_SYN_INFER_ROM => [ CONFIG_SYN_INFER_ROM => 1 ],
    CONFIG_SYN_INFER_REGF => [ CONFIG_SYN_INFER_REGF => 1 ],
    CONFIG_SYN_INFER_MULT => [ CONFIG_SYN_INFER_MULT => 1 ],
    CONFIG_SYN_RFTYPE => [ CONFIG_SYN_RFTYPE => 2 ],
    CONFIG_SYN_TRACE_DPRAM => [ CONFIG_SYN_TRACE_DPRAM => 1 ],
    CONFIG_TARGET_CLK => 
    [ 
	CONFIG_CLK_VIRTEX => "virtex",
	CONFIG_CLK_VIRTEX2 => "virtex2"
	],
    CONFIG_PLL_CLK_MUL =>
    [ 
	CONFIG_CLKDLL_1_2 => 1,
	CONFIG_CLKDLL_1_1 => 1,
	CONFIG_CLKDLL_2_1 => 2,
	CONFIG_DCM_2_3 => 2,
	CONFIG_DCM_3_4 => 3,
	CONFIG_DCM_4_5 => 4,
	CONFIG_DCM_1_1 => 2,
	CONFIG_DCM_5_4 => 5,
	CONFIG_DCM_4_3 => 4,
	CONFIG_DCM_3_2 => 3,
	CONFIG_DCM_5_3 => 5,
	CONFIG_DCM_2_1 => 2,
	CONFIG_DCM_3_1 => 3,
	CONFIG_DCM_4_1 => 4
	],
    CONFIG_PLL_CLK_DIV => 
    [
	CONFIG_CLKDLL_1_2 => 2,
	CONFIG_CLKDLL_1_1 => 1,
	CONFIG_CLKDLL_2_1 => 2,
	CONFIG_DCM_2_3 => 3,
	CONFIG_DCM_3_4 => 4,
	CONFIG_DCM_4_5 => 5,
	CONFIG_DCM_1_1 => 2,
	CONFIG_DCM_5_4 => 4,
	CONFIG_DCM_4_3 => 3,
	CONFIG_DCM_3_2 => 2,
	CONFIG_DCM_5_3 => 3,
	CONFIG_DCM_2_1 => 1,
	CONFIG_DCM_3_1 => 1,
	CONFIG_DCM_4_1 => 1
	],
    
    CONFIG_PCI_CLKDLL =>  [ CONFIG_PCI_DLL => 1 ],
    CONFIG_PCI_SYSCLK => [ CONFIG_PCI_SYSCLK => 1],
    
    CONFIG_IU_NWINDOWS => [ CONFIG_IU_NWINDOWS => sub { my ($v) = @_; if (($v > 32) || ($v < 1)) { $v = 8; } return $v;} ],   #check_nwin

    CFG_IU_DIVIDER => [ CONFIG_IU_V8MULDIV => "radix2" ],
    
    CFG_IU_MUL_TYPE => [
	CONFIG_IU_MUL_LATENCY_1 => "m32x32",
	CONFIG_IU_MUL_LATENCY_2 => "m32x16",
	CONFIG_IU_MUL_LATENCY_4 => "m16x16",
	CONFIG_IU_MUL_LATENCY_5 => "m16x16",
	CONFIG_IU_MUL_LATENCY_35 => "iterative",
	CONFIG_IU_MUL_MAC => "m16x16"
	],
    
    CONFIG_IU_MULPIPE => [ CONFIG_IU_MUL_LATENCY_5 => 1 ],
    CONFIG_IU_MUL_MAC => [CONFIG_IU_MUL_MAC => 1 ],
    
    
    CONFIG_IU_FASTJUMP => [CONFIG_IU_FASTJUMP => 1 ],
    
    CONFIG_IU_FASTDECODE => [CONFIG_IU_FASTDECODE => 1],
    CONFIG_IU_RFPOW => [CONFIG_IU_RFPOW => 1],
    CONFIG_IU_ICCHOLD =>  [CONFIG_IU_ICCHOLD => 1],
    
    CONFIG_IU_LDELAY => [CONFIG_IU_LDELAY => sub { my ($v) = @_; if (($v > 2) || ($v < 1)) { $v = 2; } return $v;} ],
    
    CONFIG_IU_WATCHPOINTS => [ CONFIG_IU_WATCHPOINTS => sub { my ($v) = @_; if (($v > 4) || ($v < 0)) { $v = 0; } return $v;} ],
    
    CONFIG_IU_IMPL => [ CONFIG_IU_IMPL => sub { my ($v) = @_; $v = hex ($v) & 0xf;  return $v;} ],
    CONFIG_IU_VER => [ CONFIG_IU_VER => sub { my ($v) = @_; $v = hex ($v) & 0xf;  return $v;}],
    
    CONFIG_FPU_ENABLE => [ CONFIG_FPU_ENABLE => 1 ],
    
    CONFIG_FPU_REGS => [ CONFIG_FPU_GRFPU => 0 ],
    CFG_FPU_IF => [ CONFIG_FPU_GRFPU => "parallel" ],
    CFG_FPU_CORE => [
	CONFIG_FPU_GRFPU => "grfpu",
	CONFIG_FPU_MEIKO => "meiko",
	CONFIG_FPU_LTH => "lth"
	],
    
    CONFIG_FPU_VER => [ CONFIG_FPU_VER => sub { my ($v) = @_; $v = hex ($v) & 0x7; return $v;}],
    
    # CP config
    CONFIG_CP_CFG => [CONFIG_CP_CFG => sub { my ($v) = @_; return $v;}],
    
    # cache config 
    CFG_ICACHE_ASSO => [
	CONFIG_ICACHE_ASSO1 => 1,
	CONFIG_ICACHE_ASSO2 => 2,
	CONFIG_ICACHE_ASSO3 => 3,
	CONFIG_ICACHE_ASSO4 => 4 
	],
    CFG_ICACHE_ALGO => [
	CONFIG_ICACHE_ALGORND => "rnd",
	CONFIG_ICACHE_ALGOLRR => "lrr",
	CONFIG_ICACHE_ALGOLRU => "lru"
	],
	
    CFG_ICACHE_LOCK => [ CONFIG_ICACHE_LOCK => 1],
    CFG_ICACHE_SZ => [ 
	CONFIG_ICACHE_SZ1 => 1,
	CONFIG_ICACHE_SZ2 => 2,
	CONFIG_ICACHE_SZ4 => 4,
	CONFIG_ICACHE_SZ8 => 8,
	CONFIG_ICACHE_SZ16 => 16,
	CONFIG_ICACHE_SZ32 => 32,
	CONFIG_ICACHE_SZ64 => 64 
	],
    CFG_ICACHE_LSZ => [ 
	CONFIG_ICACHE_LZ16 => 16,
	CONFIG_ICACHE_LZ32 => 32
	],

    CFG_DCACHE_SZ => [ 
	CONFIG_DCACHE_SZ1 => 1,
	CONFIG_DCACHE_SZ2 => 2,
	CONFIG_DCACHE_SZ4 => 4,
	CONFIG_DCACHE_SZ8 => 8,
	CONFIG_DCACHE_SZ16 => 16,
	CONFIG_DCACHE_SZ32 => 32,
	CONFIG_DCACHE_SZ64 => 64
	],

    CFG_DCACHE_LSZ => [
	CONFIG_DCACHE_LZ16 => 16,
	CONFIG_DCACHE_LZ32 => 32
	],
    
    CFG_DCACHE_SNOOP => [ 
	CONFIG_DCACHE_SNOOP_SLOW => "slow",
	CONFIG_DCACHE_SNOOP_FAST => "fast" 
	],

    CFG_DCACHE_ASSO => [ 
	CONFIG_DCACHE_ASSO1 => 1,
	CONFIG_DCACHE_ASSO2 => 2,
	CONFIG_DCACHE_ASSO3 => 3,
	CONFIG_DCACHE_ASSO4 => 4 
	],
		     
    CFG_DCACHE_ALGO => [ 
	CONFIG_DCACHE_ALGORND => "rnd",
	CONFIG_DCACHE_ALGOLRR => "lrr",
	CONFIG_DCACHE_ALGOLRU => "lru"
	],

    CFG_DCACHE_LOCK => [CONFIG_DCACHE_LOCK => 1 ],
    CFG_DCACHE_RFAST => [CONFIG_DCACHE_RFAST => 1],
    CFG_DCACHE_WFAST => [CONFIG_DCACHE_WFAST => 1],
    CFG_DCACHE_LRAM => [CONFIG_DCACHE_LRAM => 1],

    CFG_DCACHE_LRSZ => [
	CONFIG_DCACHE_LRAM_SZ1 => 1,
	CONFIG_DCACHE_LRAM_SZ2 => 2,
	CONFIG_DCACHE_LRAM_SZ4 => 4,
	CONFIG_DCACHE_LRAM_SZ8 => 8,
	CONFIG_DCACHE_LRAM_SZ16 => 16,
	CONFIG_DCACHE_LRAM_SZ32 => 32,
	CONFIG_DCACHE_LRAM_SZ64 => 64 
	],

    CFG_DCACHE_LRSTART => [ CONFIG_DCACHE_LRSTART => sub { my ($v) = @_; $v = hex ($v) & 0xff;  return $v;}],

    CFG_MMU_ENABLE => [CONFIG_MMU_ENABLE=>1],
    
    CFG_MMU_DIAG => [CONFIG_MMU_DIAG => 1],
    
    CFG_MMU_TYPE => [
	CONFIG_MMU_SPLIT => "splittlb",
	CONFIG_MMU_COMBINED => "combinedtlb"
	],

    CFG_MMU_REP => [ 
	CONFIG_MMU_REPARRAY => "replruarray",
	CONFIG_MMU_REPINCREMENT => "repincrement" 
	],

    CFG_MMU_I => [
	CONFIG_MMU_I1 => 1,
	CONFIG_MMU_I2 => 2,
	CONFIG_MMU_I4 => 4,
	CONFIG_MMU_I8 => 8,
	CONFIG_MMU_I16 => 16,
	CONFIG_MMU_I32 => 32 
	],
	      
    CFG_MMU_D => [
	CONFIG_MMU_D1 => 1,
	CONFIG_MMU_D2 => 2,
	CONFIG_MMU_D4 => 4,
	CONFIG_MMU_D8 => 8,
	CONFIG_MMU_D16 => 16,
	CONFIG_MMU_D32 => 32
	],
	      

    # Memory controller 
    CONFIG_MCTRL_8BIT => [CONFIG_MCTRL_8BIT => 1],
    CONFIG_MCTRL_16BIT => [CONFIG_MCTRL_16BIT => 1],
    CONFIG_MCTRL_5CS => [CONFIG_MCTRL_5CS => 1],
    CONFIG_MCTRL_WFB => [CONFIG_MCTRL_WFB => 1],
    CONFIG_MCTRL_SDRAM => [CONFIG_MCTRL_SDRAM => 1],
    CONFIG_MCTRL_SDRAM_INVCLK => [CONFIG_MCTRL_SDRAM_INVCLK => 1],
    
    # Peripherals 
    CONFIG_PERI_LCONF => [CONFIG_PERI_LCONF =>  1],
    CONFIG_PERI_AHBSTAT => [CONFIG_PERI_AHBSTAT => 1],
    CONFIG_PERI_WPROT => [CONFIG_PERI_WPROT => 1],
    CONFIG_PERI_WDOG => [CONFIG_PERI_WDOG => 1],
    CONFIG_PERI_IRQ2 => [CONFIG_PERI_IRQ2 => 1],
    
    # AHB 
    CONFIG_AHB_DEFMST => [CONFIG_AHB_DEFMST => sub { my ($v) = @_; return $v;}],
    CONFIG_AHB_SPLIT => [CONFIG_AHB_SPLIT => 1],
    CONFIG_AHBRAM_ENABLE => [CONFIG_AHBRAM_ENABLE => 1],
    CFG_AHBRAM_SZ => [
	CONFIG_AHBRAM_SZ1 => 1,
	CONFIG_AHBRAM_SZ2 => 2,
	CONFIG_AHBRAM_SZ4 => 3,
	CONFIG_AHBRAM_SZ8 => 4,
	CONFIG_AHBRAM_SZ16 => 5,
	CONFIG_AHBRAM_SZ32 => 6,
	CONFIG_AHBRAM_SZ64 => 7
	],
    
    
    # Debug 
    CONFIG_DEBUG_UART => [CONFIG_DEBUG_UART => 1],
    CONFIG_DEBUG_IURF => [CONFIG_DEBUG_IURF => 1],
    CONFIG_DEBUG_FPURF => [CONFIG_DEBUG_FPURF => 1],
    CONFIG_DEBUG_NOHALT => [CONFIG_DEBUG_NOHALT => 1],
    CFG_DEBUG_PCLOW => [CONFIG_DEBUG_PC32 => 0],
    CONFIG_DEBUG_RFERR => [CONFIG_DEBUG_RFERR => 1],
    CONFIG_DEBUG_CACHEMEMERR => [CONFIG_DEBUG_CACHEMEMERR => 1],
    
    # DSU 
    CONFIG_DSU_ENABLE => [CONFIG_DSU_ENABLE => sub { $ahbmst ++; return 1;} ] ,  ##; ahbmst ++;]
    
    CONFIG_DSU_TRACEBUF => [CONFIG_DSU_TRACEBUF => 1],
    CONFIG_DSU_MIXED_TRACE=> [CONFIG_DSU_MIXED_TRACE => 1],
    
    CFG_DSU_TRACE_SZ => [
	CONFIG_DSU_TRACESZ64 => 64,
	CONFIG_DSU_TRACESZ128 => 128,
	CONFIG_DSU_TRACESZ256 => 256,
	CONFIG_DSU_TRACESZ512 => 512,
	CONFIG_DSU_TRACESZ1024 => 1024
	],


    # Boot 
    CFG_BOOT_SOURCE => [
	CONFIG_BOOT_EXTPROM => "memory",
	CONFIG_BOOT_INTPROM => "prom",
	CONFIG_BOOT_MIXPROM => "dual" 
	],
    
    CONFIG_BOOT_RWS => [CONFIG_BOOT_RWS => sub { my ($v) = @_; $v = hex ($v) & 0x3;  return $v;} ],
    CONFIG_BOOT_WWS => [CONFIG_BOOT_WWS => sub { my ($v) = @_; $v = hex ($v) & 0x3;  return $v;} ],
    CONFIG_BOOT_SYSCLK => [CONFIG_BOOT_SYSCLK => sub { my ($v) = @_; return $v;} ],
    CONFIG_BOOT_BAUDRATE => [CONFIG_BOOT_BAUDRATE => sub { my ($v) = @_; $v = hex ($v) & 0x3fffff;  return $v;} ],
    CONFIG_BOOT_EXTBAUD => [CONFIG_BOOT_EXTBAUD => 1],
    CONFIG_BOOT_PROMABITS => [CONFIG_BOOT_PROMABITS => sub { my ($v) = @_; $v = hex ($v) & 0x3f;  return $v;} ],
    
    # Ethernet 
    CONFIG_ETH_ENABLE => [CONFIG_ETH_ENABLE => sub { $ahbmst++; return 1; } ], #; ahbmst++
    CONFIG_ETH_TXFIFO => [CONFIG_ETH_TXFIFO => sub { my ($v) = @_; $v = hex ($v) & 0xffff;  return $v;}],
    CONFIG_ETH_RXFIFO => [CONFIG_ETH_RXFIFO => sub { my ($v) = @_; $v = hex ($v) & 0xffff;  return $v;}],
    CONFIG_ETH_BURST  => [CONFIG_ETH_BURST => sub { my ($v) = @_; $v = hex ($v) & 0xffff;  return $v;}],



    # PCI 
    CONFIG_PCI_ENABLE => [CONFIG_PCI_ENABLE => 1],
    CFG_PCI_CORE => [
		     CONFIG_PCI_TARGET => sub { $ahbmst++; $pciahbmst = 1; $pciahbslv = 1; return "target_only"; },
		     CONFIG_PCI_OPENCORES => sub { $ahbmst++; $pciahbmst = 1; $pciahbslv = 1; return "opencores"; },
		     CONFIG_PCI_INSILICON => sub { $ahbmst+=2; $pciahbmst = 2; $pciahbslv = 1; return "insilicon"; }
		     ],
    
    CONFIG_PCI_VENDORID => [ CONFIG_PCI_VENDORID => sub { my ($v) = @_; $v = hex ($v) & 0xffff;  return $v;}],
    CONFIG_PCI_DEVICEID => [ CONFIG_PCI_DEVICEID => sub { my ($v) = @_; $v = hex ($v) & 0xffff;  return $v;}],
    CONFIG_PCI_SUBSYSID => [ CONFIG_PCI_SUBSYSID => sub { my ($v) = @_; $v = hex ($v) & 0xffff;  return $v;}],
    CONFIG_PCI_REVID    => [ CONFIG_PCI_REVID    => sub { my ($v) = @_; $v = hex ($v) & 0xff;  return $v;}],
    CONFIG_PCI_CLASSCODE => [ CONFIG_PCI_CLASSCODE => sub { my ($v) = @_; $v = hex ($v) & 0x0ffffff;  return $v;}],
    
    
    CFG_PCI_FIFO => [ CONFIG_PCI_FIFO2 => 1,
		      CONFIG_PCI_FIFO4 => 2,
		      CONFIG_PCI_FIFO8 => 3,
		      CONFIG_PCI_FIFO16 => 4,
		      CONFIG_PCI_FIFO32 => 5,
		      CONFIG_PCI_FIFO64 => 6,
		      CONFIG_PCI_FIFO128 => 7 ],
    
    CONFIG_PCI_PMEPADS => [ CONFIG_PCI_PMEPADS => 1 ],
    CONFIG_PCI_P66PAD => [ CONFIG_PCI_P66PAD => 1 ],
    CONFIG_PCI_RESETALL => [ CONFIG_PCI_RESETALL => 1 ],
    CONFIG_PCI_ARBEN => [ CONFIG_PCI_ARBEN => 1]

);		     

sub log2 {
    my ($x) = @_;
    my $i;

    $x--;
    for ($i=0; $x!=0; $i++) { $x >>= 1;}
    return $i;
}

sub sparc_config_file {
    
    my ($sparccfg) = @_;
    my %sparccfg = %{$sparccfg};
    my $fn = "vhdl/sparc/leon_device.vhd";
    my $fn_v = "vhdl/sparc/leon_device.v";
    
    $sparccfg{CONFIG_FPU_ENABLE_CONFIG_FPU_REGS} = $sparccfg{CONFIG_FPU_ENABLE}*$sparccfg{CONFIG_FPU_REGS};
    $sparccfg{CFG_ICACHE_LSZ_4} = int ($sparccfg{CFG_ICACHE_LSZ}/4);
    $sparccfg{CFG_DCACHE_LSZ_4} = int ($sparccfg{CFG_DCACHE_LSZ}/4);

    $sparccfg{CONFIG_AHB_DEFMST_ahbmst} = int ($sparccfg{CONFIG_AHB_DEFMST} % $ahbmst);
    $sparccfg{CFG_AHBRAM_SZ_7 } = 7 + $sparccfg{CFG_AHBRAM_SZ};

    $sparccfg{CONFIG_PCI_VENDORID_4} = sprintf ("%04X",$sparccfg{CONFIG_PCI_VENDORID});
    $sparccfg{CONFIG_PCI_DEVICEID_4} = sprintf ("%04X",$sparccfg{CONFIG_PCI_DEVICEID});
    $sparccfg{CONFIG_PCI_SUBSYSID_4} = sprintf ("%04X",$sparccfg{CONFIG_PCI_SUBSYSID});

    $sparccfg{CONFIG_PCI_REVID_2} = sprintf ("%02X",$sparccfg{CONFIG_PCI_REVID});
    $sparccfg{CONFIG_PCI_CLASSCODE_6} = sprintf ("%06X",$sparccfg{CONFIG_PCI_CLASSCODE});

    if ($sparccfg{CONFIG_AHBRAM_ENABLE} == 1) { $ahbram = 4; }  else { $ahbram = 0;}
    if ($sparccfg{CONFIG_DSU_ENABLE} == 1) {$dsuen = 2;} else {$dsuen = 7;}
    if ($sparccfg{CONFIG_PCI_ENABLE} == 1) {$pcien = 3;} else {$pcien = 7;}
    if ($sparccfg{CONFIG_ETH_ENABLE} == 1) {$ethen = 5;} else {$ethen = 7;}

    $sparccfg{CONFIG_ETH_TXFIFO_log2} =  log2($sparccfg{CONFIG_ETH_TXFIFO})+1;
    $sparccfg{CONFIG_ETH_RXFIFO_log2} = log2($sparccfg{CONFIG_ETH_RXFIFO})+1;
    $sparccfg{CONFIG_ETH_BURST_log2} = log2($sparccfg{CONFIG_ETH_BURST})+1;

    if (($sparccfg{CFG_ICACHE_ALGO} eq "lrr") && ($sparccfg{CFG_ICACHE_ASSO} > 2)) {
	$sparccfg{CFG_ICACHE_ALGO} = "rnd"; }
    if (($sparccfg{CFG_DCACHE_ALGO} eq "lrr") && ($sparccfg{CFG_DCACHE_ASSO} > 2)) {
	$sparccfg{CFG_DCACHE_ALGO} = "rnd"; }

    $sparccfg{ahbmst} = $ahbmst;
    $sparccfg{ahbram} = $ahbram;
    $sparccfg{dsuen} = $dsuen;
    $sparccfg{pcien} = $pcien;
    $sparccfg{ethen} = $ethen;
    $sparccfg{pciahbmst} = $pciahbmst;
    $sparccfg{pciahbslv} = $pciahbslv;
    
    if (-f $fn) {
	print STDERR ("Making backup of $fn\n");
	`cp $fn $fn.bck`;
    }
    if (-f $fn_v) {
	print STDERR ("Making backup of $fn_v\n");
	`cp $fn_v $fn_v.bck`;
    }
    
    foreach $k (keys %sparccfg) {
	$v = $sparccfg{$k};
	$sparc_config_file = cfg_replace ($k,$v,$sparc_config_file);
	$sparc_config_file_v = cfg_replace ($k,$v,$sparc_config_file_v);
	$sparc_config_file_v2 = cfg_replace ($k,$v,$sparc_config_file_v2);
	$sparc_config_file_v3 = cfg_replace ($k,$v,$sparc_config_file_v3);
    }

    if (($sparccfg{CONFIG_SYN_INFER_RAM} == 0) && (!(($sparccfg{CFG_SYN_TARGET_TECH} eq "virtex") && 
						     ($sparccfg{CFG_SYN_TARGET_TECH} eq "virtex2")))) {
	$sparc_config_file_v .= $sparc_config_file_v2;
    } else {
	$sparc_config_file_v .= $sparc_config_file_v3;
    }
    
    if (open(FILEH, ">$fn")) {
	print FILEH $sparc_config_file;
    } else {
	die ("opening \"$fn\": $!\n");
    }
    if (open(FILEH, ">$fn_v")) {
	print FILEH $sparc_config_file_v;
    } else {
	die ("opening \"$fn_v\": $!\n");
    }
}

sub cfg_replace {
    my ($k,$v,$l) = @_;
    my $type;
    if ($l =~ /%$k%\[(.)\]/) {
	$type = $1;
	if ($type eq "b") {
	    if ($v == 0) {
		$v = "false";
	    } else {
		$v = "true";
	    }
	    $l =~ s/%($k)%\[(.)\]/$v/gi;
	} else {
	    print STDERR ("Warning cound not resolve [$1] typedef\n");
	}
    }
    else {
	$l =~ s/%$k%/$v/gi;
    }
    return $l;
}


$sparc_config_file=<<SPARC_CONFIG_END;

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;

package leon_device is

-----------------------------------------------------------------------------
-- Automatically generated by vhdl/sparc/config.pl from of .config
-----------------------------------------------------------------------------


  
   constant syn_%CONFIG_CFG_NAME% : syn_config_type := ( 
    targettech => %CFG_SYN_TARGET_TECH%,infer_pads =>%CONFIG_SYN_INFER_PADS%[b],infer_pci=>%CONFIG_SYN_INFER_PCI_PADS%[b],
    infer_ram => %CONFIG_SYN_INFER_RAM%[b], infer_regf => %CONFIG_SYN_INFER_REGF%[b], infer_rom => %CONFIG_SYN_INFER_ROM%[b],
    infer_mult => %CONFIG_SYN_INFER_MULT%[b], rftype => %CONFIG_SYN_RFTYPE%, targetclk => %CONFIG_TARGET_CLK%,
    clk_mul => %CONFIG_PLL_CLK_MUL%, clk_div => %CONFIG_PLL_CLK_DIV%, pci_dll => %CONFIG_PCI_CLKDLL%[b], 
    pci_sysclk => %CONFIG_PCI_SYSCLK%[b] );

  constant iu_%CONFIG_CFG_NAME% : iu_config_type := (
    nwindows => %CONFIG_IU_NWINDOWS%, multiplier => %CFG_IU_MUL_TYPE%, mulpipe => %CONFIG_IU_MULPIPE%[b], 
    divider => %CFG_IU_DIVIDER%, mac => %CONFIG_IU_MUL_MAC%[b], fpuen => %CONFIG_FPU_ENABLE%, cpen => false, 
    fastjump => %CONFIG_IU_FASTJUMP%[b], icchold => %CONFIG_IU_ICCHOLD%[b], lddelay => %CONFIG_IU_LDELAY%, 
    fastdecode => %CONFIG_IU_FASTDECODE%[b], rflowpow => %CONFIG_IU_RFPOW%[b], watchpoints => %CONFIG_IU_WATCHPOINTS%, 
    impl => %CONFIG_IU_IMPL%, version => %CONFIG_IU_VER%);

  constant fpu_%CONFIG_CFG_NAME% : fpu_config_type := 
    (core => %CFG_FPU_CORE%, interface => %CFG_FPU_IF%, fregs => %CONFIG_FPU_ENABLE_CONFIG_FPU_REGS%, 
     version => %CONFIG_FPU_VER%);

  constant cache_%CONFIG_CFG_NAME% : cache_config_type := (
    isets => %CFG_ICACHE_ASSO%, isetsize => %CFG_ICACHE_SZ%, ilinesize => %CFG_ICACHE_LSZ_4%, 
    ireplace => %CFG_ICACHE_ALGO%, ilock => %CFG_ICACHE_LOCK%,
    dsets => %CFG_DCACHE_ASSO%, dsetsize => %CFG_DCACHE_SZ%, dlinesize => %CFG_DCACHE_LSZ_4%, 
    dreplace => %CFG_DCACHE_ALGO%, dlock => %CFG_DCACHE_LOCK%,
    dsnoop => %CFG_DCACHE_SNOOP%, drfast => %CFG_DCACHE_RFAST%[b], dwfast => %CFG_DCACHE_WFAST%[b], 
    dlram => %CFG_DCACHE_LRAM%[b], 
    dlramsize => %CFG_DCACHE_LRSZ%, dlramaddr => 16#%CFG_DCACHE_LRSTART%#);

  constant mmu_%CONFIG_CFG_NAME% : mmu_config_type := (
    enable => %CFG_MMU_ENABLE%, itlbnum => %CFG_MMU_I%, dtlbnum => %CFG_MMU_D%, tlb_type => %CFG_MMU_TYPE%, 
    tlb_rep => %CFG_MMU_REP%, tlb_diag => %CFG_MMU_DIAG%[b] );

  constant ahbrange_config  : ahbslv_addr_type := 
        (0,0,0,0,0,0,%ahbram%,0,1,%dsuen%,%pcien%,%ethen%,%pcien%,%pcien%,%pcien%,%pcien%);

  constant ahb_%CONFIG_CFG_NAME% : ahb_config_type := ( masters => %ahbmst%, defmst => %CONFIG_AHB_DEFMST_ahbmst%,
    split => %CONFIG_AHB_SPLIT%[b], testmod => false);

  constant mctrl_%CONFIG_CFG_NAME% : mctrl_config_type := (
    bus8en => %CONFIG_MCTRL_8BIT%[b], bus16en => %CONFIG_MCTRL_16BIT%[b], wendfb => %CONFIG_MCTRL_WFB%[b], 
    ramsel5 => %CONFIG_MCTRL_5CS%[b], sdramen => %CONFIG_MCTRL_SDRAM%[b], sdinvclk => %CONFIG_MCTRL_SDRAM_INVCLK%[b]);
   
  constant peri_%CONFIG_CFG_NAME% : peri_config_type := (
    cfgreg => %CONFIG_PERI_LCONF%[b], ahbstat => %CONFIG_PERI_AHBSTAT%[b], wprot => %CONFIG_PERI_WPROT%[b], 
    wdog => %CONFIG_PERI_WDOG%[b],  irq2en => %CONFIG_PERI_IRQ2%[b], ahbram => %CONFIG_AHBRAM_ENABLE%[b], 
    ahbrambits => %CFG_AHBRAM_SZ_7%, ethen => %CONFIG_ETH_ENABLE%[b] );

  constant debug_%CONFIG_CFG_NAME% : debug_config_type := ( enable => true, uart => %CONFIG_DEBUG_UART%[b],
    iureg => %CONFIG_DEBUG_IURF%[b], fpureg => %CONFIG_DEBUG_FPURF%[b], nohalt => %CONFIG_DEBUG_NOHALT%[b], 
    pclow => %CFG_DEBUG_PCLOW%,
    dsuenable => %CONFIG_DSU_ENABLE%[b], dsutrace => %CONFIG_DSU_TRACEBUF%[b], dsumixed => %CONFIG_DSU_MIXED_TRACE%[b],
    dsudpram => %CONFIG_SYN_TRACE_DPRAM%[b], tracelines => %CFG_DSU_TRACE_SZ%);

  constant boot_%CONFIG_CFG_NAME% : boot_config_type := (boot => %CFG_BOOT_SOURCE%, ramrws => %CONFIG_BOOT_RWS%,
    ramwws => %CONFIG_BOOT_WWS%, sysclk => %CONFIG_BOOT_SYSCLK%, baud => %CONFIG_BOOT_BAUDRATE%, 
    extbaud => %CONFIG_BOOT_EXTBAUD%[b], pabits => %CONFIG_BOOT_PROMABITS%);

  constant pci_%CONFIG_CFG_NAME% : pci_config_type := (
    pcicore => %CFG_PCI_CORE% , ahbmasters => %pciahbmst%, ahbslaves => %pciahbslv%,
    arbiter => %CONFIG_PCI_ARBEN%[b], fixpri => false, prilevels => 4, pcimasters => 4,
    vendorid => 16#%CONFIG_PCI_VENDORID_4%#, deviceid => 16#%CONFIG_PCI_DEVICEID_4%#, 
    subsysid => 16#%CONFIG_PCI_SUBSYSID%#,
    revisionid => 16#%CONFIG_PCI_REVID_2%#, classcode =>16#%CONFIG_PCI_CLASSCODE_6%#, pmepads => %CONFIG_PCI_PMEPADS%[b],
    p66pad => %CONFIG_PCI_P66PAD%[b], pcirstall => %CONFIG_PCI_RESETALL%[b]);

  constant irq2cfg : irq2type := irq2none;

-----------------------------------------------------------------------------
-- end of automatic configuration
-----------------------------------------------------------------------------

end leon_device;

SPARC_CONFIG_END

$sparc_config_file_v =<<SPARC_CONFIG_V_END;

`define HEADER_VENDOR_ID    16'h%CONFIG_PCI_VENDORID_4%
`define HEADER_DEVICE_ID    16'h%CONFIG_PCI_DEVICEID_4%
`define HEADER_REVISION_ID  8'h%CONFIG_PCI_REVID_2%

`define ETH_WISHBONE_B3

`define ETH_TX_FIFO_CNT_WIDTH  %CONFIG_ETH_TXFIFO%_log2%
`define ETH_TX_FIFO_DEPTH      %CONFIG_ETH_TXFIFO%

`define ETH_RX_FIFO_CNT_WIDTH  %CONFIG_ETH_RXFIFO_log2%
`define ETH_RX_FIFO_DEPTH      %CONFIG_ETH_RXFIFO%

`define ETH_BURST_CNT_WIDTH    %CONFIG_ETH_BURST_log2%
`define ETH_BURST_LENGTH       %CONFIG_ETH_BURST%

SPARC_CONFIG_V_END



$sparc_config_file_v2 =<<SPARC_CONFIG_V2_END;

`define FPGA
`define XILINX
`define WBW_ADDR_LENGTH 7
`define WBR_ADDR_LENGTH 7
`define PCIW_ADDR_LENGTH 7
`define PCIR_ADDR_LENGTH 7
`define PCI_FIFO_RAM_ADDR_LENGTH 8 
`define WB_FIFO_RAM_ADDR_LENGTH 8   


SPARC_CONFIG_V2_END

$sparc_config_file_v3 =<<SPARC_CONFIG_V3_END;

`define WB_RAM_DONT_SHARE
`define PCI_RAM_DONT_SHARE
`define WBW_ADDR_LENGTH %CFG_PCI_FIFO%
`define WBR_ADDR_LENGTH %CFG_PCI_FIFO%
`define PCIW_ADDR_LENGTH %CFG_PCI_FIFO%
`define PCIR_ADDR_LENGTH %CFG_PCI_FIFO%
`define PCI_FIFO_RAM_ADDR_LENGTH %CFG_PCI_FIFO% 
`define WB_FIFO_RAM_ADDR_LENGTH %CFG_PCI_FIFO%    

SPARC_CONFIG_V3_END


1;












