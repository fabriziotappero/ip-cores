------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Package: 	leon3
-- File:	leon3.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	LEON3 types and components
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;

package leon3 is

  constant LEON3_VERSION : integer := 0;

  type l3_irq_in_type is record
    irl   	: std_logic_vector(3 downto 0);
    rst   	: std_ulogic;
    run   	: std_ulogic;
    rstvec	: std_logic_vector(31 downto 12);
  end record;

  type l3_irq_out_type is record
    intack	: std_ulogic;
    irl		: std_logic_vector(3 downto 0);
    pwd         : std_ulogic;
  end record;

  type l3_debug_in_type is record
    dsuen   : std_ulogic;  -- DSU enable
    denable : std_ulogic;  -- diagnostic register access enable
    dbreak  : std_ulogic;  -- debug break-in
    step    : std_ulogic;  -- single step    
    halt    : std_ulogic;  -- halt processor
    reset   : std_ulogic;  -- reset processor
    dwrite  : std_ulogic;  -- read/write
    daddr   : std_logic_vector(23 downto 2); -- diagnostic address
    ddata   : std_logic_vector(31 downto 0); -- diagnostic data
    btrapa  : std_ulogic;	   -- break on IU trap
    btrape  : std_ulogic;	-- break on IU trap
    berror  : std_ulogic;	-- break on IU error mode
    bwatch  : std_ulogic;	-- break on IU watchpoint
    bsoft   : std_ulogic;	-- break on software breakpoint (TA 1)
    tenable : std_ulogic;
    timer   :  std_logic_vector(30 downto 0);                                                -- 
  end record;

  type l3_debug_out_type is record
    data    : std_logic_vector(31 downto 0);
    crdy    : std_ulogic;
    dsu     : std_ulogic;
    dsumode : std_ulogic;
    error   : std_ulogic;
    halt    : std_ulogic;
    pwd     : std_ulogic;
    idle    : std_ulogic;
    ipend   : std_ulogic;
    icnt    : std_ulogic;
  end record;

  type l3_debug_in_vector is array (natural range <>) of l3_debug_in_type;
  type l3_debug_out_vector is array (natural range <>) of l3_debug_out_type;
  
  component leon3s
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;    
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram     : integer range 0 to 1 := 0;
    ilramsize : integer range 1 to 512 := 1;
    ilramstart: integer range 0 to 255 := 16#8e#;
    dlram     : integer range 0 to 1 := 0;
    dlramsize : integer range 1 to 512 := 1;
    dlramstart: integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    tlb_rep   : integer range 0 to 1 := 0;
    lddel     : integer range 1 to 2 := 2;
    disas     : integer range 0 to 2 := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2 := 2;     -- power-down
    svt       : integer range 0 to 1 := 1;     -- single vector trapping
    rstaddr   : integer := 16#00000#;          -- reset vector address [31:12]
    smp       : integer range 0 to 15 := 0;    -- support SMP systems
    cached    : integer               := 0;     -- cacheability table
    scantest  : integer               := 0
  );
  port (
    clk    : in  std_ulogic;
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l3_debug_in_type;
    dbgo   : out l3_debug_out_type
  );
  end component; 

  component leon3cg
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;    
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram     : integer range 0 to 1 := 0;
    ilramsize : integer range 1 to 512 := 1;
    ilramstart: integer range 0 to 255 := 16#8e#;
    dlram     : integer range 0 to 1 := 0;
    dlramsize : integer range 1 to 512 := 1;
    dlramstart: integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    tlb_rep   : integer range 0 to 1 := 0;
    lddel     : integer range 1 to 2 := 2;
    disas     : integer range 0 to 2 := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2 := 2;     -- power-down
    svt       : integer range 0 to 1 := 1;     -- single vector trapping
    rstaddr   : integer := 16#00000#;          -- reset vector address [31:12]
    smp       : integer range 0 to 15 := 0;    -- support SMP systems
    cached    : integer               := 0;     -- cacheability table
    scantest  : integer               := 0
  );
  port (
    clk    : in  std_ulogic;
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l3_debug_in_type;
    dbgo   : out l3_debug_out_type;
    gclk   : in  std_ulogic
  );
  end component; 

  component leon3ft
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;    
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram     : integer range 0 to 1 := 0;
    ilramsize : integer range 1 to 512 := 1;
    ilramstart: integer range 0 to 255 := 16#8e#;
    dlram     : integer range 0 to 1 := 0;
    dlramsize : integer range 1 to 512 := 1;
    dlramstart: integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    tlb_rep   : integer range 0 to 1 := 0;
    lddel     : integer range 1 to 2 := 2;
    disas     : integer range 0 to 2 := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2 := 2;     -- power-down
    svt       : integer range 0 to 1 := 1;     -- single vector trapping
    rstaddr   : integer := 16#00000#;   -- reset vector address [31:12]
    smp       : integer range 0 to 15 := 0;    -- support SMP systems
    iuft      : integer range 0 to 4  := 0;
    fpft      : integer range 0 to 4  := 0;
    cmft      : integer range 0 to 1  := 0;
    iuinj     : integer               := 0;    
    ceinj     : integer range 0 to 3  := 0;   
    cached    : integer               := 0;     -- cacheability table
    netlist   : integer               := 0;     -- use netlist
    scantest  : integer               := 0      -- enable scan test support
  );
  port (
    clk    : in  std_ulogic;
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l3_debug_in_type;
    dbgo   : out l3_debug_out_type;
    gclk   : in  std_ulogic
  );
  end component; 

  component leon3s2x 
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2 := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 15 := 0;     -- support SMP systems
    cached    : integer               := 0;	-- cacheability table
    clk2x     : integer 	      := 1;
    scantest  : integer               := 0
  );
  port (
    clk    : in  std_ulogic;
    gclk2  : in  std_ulogic;    -- gated clock
    clk2   : in  std_ulogic;    -- continuous clock
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;    
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l3_debug_in_type;
    dbgo   : out l3_debug_out_type;
    clken : in std_ulogic
  );
  end component;

    -- GRFPU interface

  type fp_rf_in_type is record
    rd1addr 	: std_logic_vector(3 downto 0); -- read address 1
    rd2addr 	: std_logic_vector(3 downto 0); -- read address 2
    wraddr 	: std_logic_vector(3 downto 0); -- write address
    wrdata 	: std_logic_vector(31 downto 0);     -- write data
    ren1        : std_ulogic;			     -- read 1 enable
    ren2        : std_ulogic;			     -- read 2 enable
    wren        : std_ulogic;			     -- write enable
  end record;
 
  type fp_rf_out_type is record
    data1    	: std_logic_vector(31 downto 0); -- read data 1
    data2    	: std_logic_vector(31 downto 0); -- read data 2
  end record;  

  type fpc_pipeline_control_type is record
    pc    : std_logic_vector(31 downto 0);
    inst  : std_logic_vector(31 downto 0);
    cnt   : std_logic_vector(1 downto 0);
    trap  : std_ulogic;
    annul : std_ulogic;
    pv    : std_ulogic;
  end record;  

  type fpc_debug_in_type is record
    enable : std_ulogic;
    write  : std_ulogic;
    fsr    : std_ulogic;                            -- FSR access
    addr   : std_logic_vector(4 downto 0);
    data   : std_logic_vector(31 downto 0);
  end record;

  type fpc_debug_out_type is record
    data   : std_logic_vector(31 downto 0);
  end record;  

  type fpc_in_type is record
    flush  	: std_ulogic;			  -- pipeline flush
    exack    	: std_ulogic;			  -- FP exception acknowledge
    a_rs1  	: std_logic_vector(4 downto 0);
    d             : fpc_pipeline_control_type;
    a             : fpc_pipeline_control_type;
    e             : fpc_pipeline_control_type;
    m             : fpc_pipeline_control_type;
    x             : fpc_pipeline_control_type;    
    lddata        : std_logic_vector(31 downto 0);     -- load data
    dbg           : fpc_debug_in_type;               -- debug signals
  end record;

  type fpc_out_type is record
    data          : std_logic_vector(31 downto 0); -- store data
    exc  	        : std_logic;			 -- FP exception
    cc            : std_logic_vector(1 downto 0);  -- FP condition codes
    ccv  	        : std_ulogic;			 -- FP condition codes valid
    ldlock        : std_logic;			 -- FP pipeline hold
    holdn          : std_ulogic;
    dbg           : fpc_debug_out_type;             -- FP debug signals    
  end record;
  
  type grfpu_in_type is record
    start   : std_logic;
    nonstd  : std_logic;
    flop    : std_logic_vector(8 downto 0);
    op1     : std_logic_vector(63 downto 0);
    op2     : std_logic_vector(63 downto 0);
    opid    : std_logic_vector(7 downto 0);
    flush   : std_logic;
    flushid : std_logic_vector(5 downto 0);
    rndmode : std_logic_vector(1 downto 0);
    req     : std_logic;
  end record;
  
  type grfpu_out_type is record
    res     : std_logic_vector(63 downto 0);
    exc     : std_logic_vector(5 downto 0);
    allow   : std_logic_vector(2 downto 0);
    rdy     : std_logic;
    cc      : std_logic_vector(1 downto 0);
    idout   : std_logic_vector(7 downto 0);
  end record;

  type grfpu_out_vector_type is array (integer range 0 to 7) of grfpu_out_type;
  type grfpu_in_vector_type is array (integer range 0 to 7) of grfpu_in_type;

  component grfpushwx 
  generic (mul    : integer              := 0;
           nshare : integer range 0 to 8 := 0);
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;
    fpvi    : in  grfpu_in_vector_type;
    fpvo    : out grfpu_out_vector_type    
    );
  end component;
  
  component grfpwxsh
  generic (tech     : integer range 0 to NTECH := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 1 := 0;           
           disas    : integer range 0 to 2 := 0;
           id       : integer range 0 to 7 := 0);
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi    : in  fpc_in_type;
    cpo    : out fpc_out_type;
    fpui   : out grfpu_in_type;
    fpuo   : in  grfpu_out_type
    );
  end component;
  
  component leon3sh
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 15 := 0;     -- support SMP systems
    cached    : integer               := 0;	-- cacheability table
    scantest  : integer               := 0
  );
  port (
    clk    : in  std_ulogic;
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;    
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l3_debug_in_type;
    dbgo   : out l3_debug_out_type;
    fpui   : out grfpu_in_type;
    fpuo   : in  grfpu_out_type
  );
  end component;

  type dsu_in_type is record
    enable  : std_ulogic;
    break   : std_ulogic;
  end record;                        

  type dsu_out_type is record
    active          : std_ulogic;
    tstop           : std_ulogic;
    pwd             : std_logic_vector(15 downto 0);
  end record;

  component dsu3 
  generic (
    hindex  : integer := 0;
    haddr   : integer := 16#900#;
    hmask   : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dbgi   : in l3_debug_out_vector(0 to NCPU-1);
    dbgo   : out l3_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu_in_type;
    dsuo   : out dsu_out_type
  );
  end component;

  component dsu3_2x 
  generic (
    hindex  : integer := 0;
    haddr : integer := 16#900#;
    hmask : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    hclk   : in  std_ulogic;
    cpuclk : in std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dbgi   : in l3_debug_out_vector(0 to NCPU-1);
    dbgo   : out l3_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu_in_type;
    dsuo   : out dsu_out_type;
    hclken : in std_ulogic    
  );
  end component;


  component dsu3x 
  generic (
    hindex  : integer := 0;
    haddr : integer := 16#900#;
    hmask : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0;
    clk2x   : integer range 0 to 1 := 0
  );
  port (
    rst    : in  std_ulogic;
    hclk   : in  std_ulogic;
    cpuclk : in std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dbgi   : in l3_debug_out_vector(0 to NCPU-1);
    dbgo   : out l3_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu_in_type;
    dsuo   : out dsu_out_type;
    hclken : in std_ulogic
  );
  end component;
  
  type irq_in_vector  is array (Natural range <> ) of l3_irq_in_type;
  type irq_out_vector is array (Natural range <> ) of l3_irq_out_type;

  component irqmp
  generic (
    pindex  : integer := 0;
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    ncpu    : integer := 1;
    eirq    : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    irqi   : in  irq_out_vector(0 to ncpu-1);
    irqo   : out irq_in_vector(0 to ncpu-1)
  );
  end component; 

  component irqmp2x
  generic (
    pindex  : integer := 0;
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    ncpu    : integer := 1;
    eirq    : integer := 0;
    clkfact : integer := 2
  );
  port (
    rst    : in  std_ulogic;
    hclk    : in  std_ulogic;
    cpuclk : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    irqi   : in  irq_out_vector(0 to ncpu-1);
    irqo   : out irq_in_vector(0 to ncpu-1);
    hclken : in std_ulogic    
  );
  end component;

component leon3ftsh
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 15 := 0;    -- support SMP systems
    iuft      : integer range 0 to 4  := 0;
    fpft      : integer range 0 to 4  := 0;
    cmft      : integer range 0 to 1  := 0;
    iuinj     : integer               := 0;
    ceinj     : integer range 0 to 3  := 0;
    cached    : integer               := 0;
    netlist   : integer               := 0;
    scantest  : integer               := 0
  );
  port (
    clk    : in  std_ulogic;	-- free-running clock
    rstn   : in  std_ulogic;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;    
    irqi   : in  l3_irq_in_type;
    irqo   : out l3_irq_out_type;
    dbgi   : in  l3_debug_in_type;
    dbgo   : out l3_debug_out_type;
    gclk   : in  std_ulogic;	-- gated clock
    fpui   : out grfpu_in_type;
    fpuo   : in  grfpu_out_type
  );
end component; 

end;
