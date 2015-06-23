-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armpctrl.all;
use work.armdecode.all;
use work.armcmd.all;
use work.armcmd_comp.all;

entity armcmd_bl is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_bl_typ_in;
    o       : out armcmd_bl_typ_out
    );
end armcmd_bl;

architecture rtl of armcmd_bl is

  type armcmd_bl_tmp_type is record
    o       : armcmd_bl_typ_out;
    off : std_logic_vector(23 downto 0);
  end record;
  type armcmd_bl_reg_type is record
    dummy      : std_logic;
  end record;
  type armcmd_bl_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_bl_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_bl_reg_type;
  signal rdbg, cdbg : armcmd_bl_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_bl_reg_type;
    variable t    : armcmd_bl_tmp_type;
    variable vdbg : armcmd_bl_dbg_type;
  begin 
    
    -- $(init(t:armcmd_bl_tmp_type))
    
    v := r;
    t.o.ctrlo := i.ctrli.ctrlo;
    t.o.ctrlo.nextinsn := '1';
           
    t.off := i.ctrli.insn.insn(ADE_BROFF_U downto ADE_BROFF_D);
    
    t.o.r2_src := acm_none;
    t.o.data2 := (others => '0');
    t.o.rsop_op2_src := apc_opsrc_none;
      
    -- b{cond} addr
    -- bl{cond} addr
    case i.ctrli.cnt is
      when ACM_CNT_ZERO =>
        
        --                           (branch) <-+
        --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
        --      --+-----------+-----------+-----+-----+-----------+-----------+----------+
        --        | pctrl.(pc)+----------op1    |     |           |           |
        --        |           |           | \   |     |           |           |
        --        |  (regread)|           | +(aluop)  |  (trans)  |  (dcache) | (write)
        --        |           |           | /         |           |           | 
        --   <off>|-----------+----------op2          |           |           | 
        --      --+-----------+-----------+-----------+-----------+-----------+----------+
        
        -- write pc
        t.o.r1_src := acm_local;
        if t.off(23) = '0' then
          t.o.data2 := (others => '0');
        else
          t.o.data2 := (others => '1');
        end if;
        t.o.data2(23+2 downto 0) := t.off & "00";
        t.o.rd_src := acm_rdpc;
        
        if i.ctrli.insn.insn(ADE_BRLINK_C) = '1' then
          t.o.ctrlo.nextinsn := '0';
        end if;
        
      when others =>

        --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
        --      --+-----------+-----------+-----------+-----------+-----------+----------+
        --        | pctrl.(pc)+----------op1          |           |           |
        --        |           |           | \         |           |           |
        --        |  (regread)|           | +(aluop)  |  (trans)  |  (dcache) | +-><r14>(write)
        --        |           |           | /   |     |           |           | | 
        --   <0>  |-----------+----------op2    |     |           |           | |  
        --      --+-----------+-----------+-----+-----+-----------+-----------+-+--------+
        --                                      |                               |  
        --         pctrl.data1 (as wrdata)  :   +-------------------------------+
                 
        -- write link
        t.o.r1_src := acm_local;
        t.o.rd_src := acm_rdlink;
        
    end case;
    
    -- reset
    if ( rst = '0' ) then
    end if;

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
