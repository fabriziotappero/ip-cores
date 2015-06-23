-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armcmd.all;
use work.armpctrl.all;
use work.armdecode.all;
use work.armcmd_comp.all;

entity armcmd_al is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_al_typ_in;
    o       : out armcmd_al_typ_out
    );
end armcmd_al;

architecture rtl of armcmd_al is

  type armcmd_al_tmp_type is record
    o       : armcmd_al_typ_out;
    ismove : std_logic;
  end record;
  type armcmd_al_reg_type is record
    dummy      : std_logic;
  end record;
  type armcmd_al_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_al_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_al_reg_type;
  signal rdbg, cdbg : armcmd_al_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_al_reg_type;
    variable t    : armcmd_al_tmp_type;
    variable vdbg : armcmd_al_dbg_type;
  begin 
    
    -- $(init(t:armcmd_al_tmp_type))
    
    v := r;

    -- init o
    t.o.ctrlo := i.ctrli.ctrlo;
    t.o.r1_src  := acm_none;
    t.o.r2_src  := acm_none;
    t.o.rd_src  := acm_rdrrd;
    -- rssrg
    t.o.rsop_op1_src := apc_opsrc_through;
    t.o.rsop_op2_src := apc_opsrc_through;
    t.o.rsop_buf2_src := apc_bufsrc_none;
    
    t.ismove := '0';
    if (i.ctrli.insn.decinsn = type_arm_mov or 
        i.ctrli.insn.decinsn = type_arm_mvn) then
      t.ismove := '1';
    end if;
    
    -- addressing modes
    case i.ctrli.insn.am.DAPRAM_typ is
      when ade_DAPRAM_simm =>
        -- DP op2: Register                     : <rm>
        -- DP op2: Register <SDIR> by Immediate : <rm>, <SDIR> #<imm>
        -- DP op2: Register RRX                 : <rm>, RRX
        -- <SDIR>: {LSL}|{LSR}|{ASR}|{ROR}

        -- [ctrli.cnt = 0:] 
        --
        --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
        --      --+-----------+-----------+-----------+-----------+-----------+----------+
        -- <rn> ->+-----------+----------op1          |           |           |
        --(~move) |           |           | \         |           |           |
        --        |  (regread)| <imm>+    | +(aluop)  |  +(trans) |  (dcache) | +->(write)
        --        |           |      V    | /   |     |           |           | |
        -- <rm> ->+-----------+-(shift)--op2    |     |           |           | |
        --      --+-----------+-----------+-----+-----+-----------+-----------+-+--------+
        --                                      |                               |
        --         pctrl.data1 (as wrdata)  :   +-------------------------------+          
        
        t.o.r1_src  := acm_none;
        if t.ismove = '0' then
          t.o.r1_src  := acm_rrn;
        end if;
        t.o.r2_src  := acm_rrm;  -- NOTE: shiefter expects op in data2
      when ade_DAPRAM_sreg =>
        -- DP op2: Register <SDIR> by Register  : <rm>, <SDIR> <rs>
        -- <SDIR>: {LSL}|{LSR}|{ASR}|{ROR}
        case i.ctrli.cnt is  
          when ACM_CNT_ZERO =>
            
            -- [ctrli.cnt = 0:] 
            --
            --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
            --      --+-----------+-----------+-----------+-----------+-----------+----------+
            -- <rm> ->+-----------+-(shift)+(-op1.move...)|           |           |
            --        |           | /\     V  |           |           |           |
            --        |  (regread)| |   [buf2]|  (aluop)  |   (trans) |  (dcache) | (write)
            --        |           | |         |           |           |           | 
            -- <rs> ->+-----------+-+         |           |           |           | 
            --      --+-----------+-----------+-----------+-----------+-----------+----------+
            --                                       
            
            t.o.r1_src  := acm_rrm;
            t.o.r2_src  := acm_rrs;
            if t.ismove = '0' then
              t.o.ctrlo.nextinsn := '0';
              t.o.rsop_buf2_src := apc_bufsrc_through;
              t.o.rd_src  := acm_rdnone;
            end if; 
          when others  =>
            
            -- [ctrli.cnt = 1:] 
            --
            --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
            --      --+-----------+-----------+-----------+-----------+-----------+----------+
            -- <rn> ->+-----------+----------op1          |           |           |
            --(~move) |           |           | \         |           |           |
            --        | (regread) |           | +(aluop)  |   (trans) |  (dcache) | +->(write)
            --        |           |           | /   |     |           |           | |
            --        |           + [buf2]-->op2    |     |           |           | |
            --      --+-----------+-----------+-----+-----+-----------+-----------+-+--------+
            --                                      |                               |
            --         pctrl.data1 (as wrdata)  :   +-------------------------------+
                      
            t.o.r1_src  := acm_rrn;
            t.o.rsop_op2_src := apc_opsrc_buf;
        end case;
      when ade_DAPRAM_immrot =>
        -- DP op2: Immediate #<imm>
        
        -- [ctrli.cnt = 0:]
        -- todo: ad extra shiefter to rrstg , skip rsstg
        --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
        --      --+-----------+-----------+-----------+-----------+-----------+----------+
        -- <rn> ->+-----------+----------op1          |           |           |
        --(~move) |           |           | \         |           |           |
        --        |  (regread)| <imm>+    | +(aluop)  |  +(trans) |  (dcache) | +->(write)
        --        |           |      V    | /   |     |           |           | |
        --        |           | (shift)--op2    |     |           |           | |
        --      --+-----------+-----------+-----+-----+-----------+-----------+-+--------+
        --                                      |                               |
        --         pctrl.data1 (as wrdata)  :   +-------------------------------+
        
        if t.ismove = '0' then
          t.o.r1_src  := acm_rrn;
        end if;
      when others => null;
    end case;

    c <= v;
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
