-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armdecode.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armcmd.all;
use work.armcmd_comp.all;

entity armcmd_cr is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_cr_typ_in;
    o       : out armcmd_cr_typ_out
    );
end armcmd_cr;

architecture rtl of armcmd_cr is

  type armcmd_cr_tmp_type is record
    o       : armcmd_cr_typ_out;
    off : std_logic_vector(23 downto 0);
  end record;
  type armcmd_cr_reg_type is record
    dummy      : std_logic;
  end record;
  type armcmd_cr_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_cr_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_cr_reg_type;
  signal rdbg, cdbg : armcmd_cr_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_cr_reg_type;
    variable t    : armcmd_cr_tmp_type;
    variable vdbg : armcmd_cr_dbg_type;
  begin 
    
    -- $(init(t:armcmd_cr_tmp_type))
    
    v := r;
    t.o.ctrlo := i.ctrli.ctrlo;
    t.o.ctrlo.nextinsn := '1';

    t.o.rd_src  := acm_rdnone;
    t.o.r1_src  := acm_none;

    if i.ctrli.insn.insn(ADE_MRC_MCR_C) = '1' then -- '1':MRC '0':MCR

      -- move coprocessor to arm:
      -- MRC{cond} <copro>,<opcode_1>,<rd>,<crn>,<crm>{,<opcode2>}
      -- MRC2      <copro>,<opcode_1>,<rd>,<crn>,<crm>{,<opcode2>}

      -- [frame:] 
      --
      --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
      --      --+-----------+-----------+-----------+-----------+-----------+----------+
      --        |           |           |           |           |           |
      --        |           |           |           |           |           |
      --        | (regread) |(regshieft)|  (aluop)  |  +(trans) |  (dcache) | +->(write)
      --        |           |           |           |           |           | |
      --        |  [copro]  |           |           |           |           | |
      --      --+-----+-----+-----------+-----------+-----------+-----------+-+--------+
      --              V                                                       |
      --         pctrl.data1 (as wrdata)  : o---------------------------------+          
      --

      t.o.rd_src  := acm_rdrrd;
    else
      
      -- move arm to coprocessor:
      -- MCR{cond} <copro>,<opcode_1>,<rd>,<crn>,<crm>{,<opcode2>}
      -- MCR2      <copro>,<opcode_1>,<rd>,<crn>,<crm>{,<opcode2>}

      -- [frame:] 
      --
      --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
      --      --+-----------+-----------+-----------+-----------+-----------+----------+
      --  <rd>--+-----+     |           |           |           |           |           
      --        |     |     |           |           |           |           |
      --        | (regread) |(regshieft)|  (aluop)  |   (trans) |  (dcache) | (write)
      --        |     |     |           |           |           |           | 
      --        |     |     |           |           |           |           | 
      --      --+-----+-----+-----------+-----------+-----------+-----------+----------+
      --              V                                                        
      --         pctrl.data1 (as wrdata)  : o--------------------------------->[copro]          
      
      t.o.r1_src  := acm_rrd;
    end if;
    
    if i.fromCP_busy = '1' then
      t.o.ctrlo.hold := '1';
    end if;
    
    -- reset
    if ( rst = '0' ) then
    end if;

    o <= t.o;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    cdbg <= vdbg;
    -- pragma translate_on  
    
  end process p0;
    
  pregs : process (clk, c)
  begin
    if rising_edge(clk) then
      r <= c;
      -- pragma translate_off
      rdbg <= cdbg;
      -- pragma translate_on
    end if;
  end process;
  
end rtl;
