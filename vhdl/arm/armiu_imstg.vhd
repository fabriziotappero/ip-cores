-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.int.all;
use work.arm_comp.all;

entity armiu_imstg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_imstg_typ_in;
    o       : out armiu_imstg_typ_out
    );
end armiu_imstg;

architecture rtl of armiu_imstg is

  type armiu_imstg_tmp_type is record
    o       : armiu_imstg_typ_out;
    valid      : std_logic;
    addrvir_4  : std_logic_vector(31 downto 0); -- virtual pc+4
    addrphy    : std_logic_vector(31 downto 0); -- pc after translation
  end record;
  type armiu_imstg_reg_type is record
    branch     : std_logic;
    valid      : std_logic;
    addrvir    : std_logic_vector(31 downto 0);  -- virtual pc
  end record;
  type armiu_imstg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_imstg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_imstg_reg_type;
  signal rdbg, cdbg : armiu_imstg_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armiu_imstg_reg_type;
    variable t    : armiu_imstg_tmp_type;
    variable vdbg : armiu_imstg_dbg_type;
  begin 
    
    -- $(init(t:armiu_imstg_tmp_type))
    
    v := r;

    t.addrvir_4 := r.addrvir;
    t.valid := r.valid;
    
    lin_incdec(r.addrvir(31 downto 2),t.addrvir_4(31 downto 2),'1','1');

    if i.pstate.hold_r.hold = '0' and i.pstate.nextinsn_v = '1' then
      v.addrvir := t.addrvir_4;
    end if;

    if i.flush_v = '1' then
      v.valid := '0';
      t.valid := '0';
    end if;
    
    if i.branch_v = '1' then
      v.addrvir := i.addrvir_v;
      v.valid := '1';
    end if;
    
    -- reset
    if ( rst = '0' ) then
      v.addrvir := (others => '0');
      v.valid := '1';
    end if;
    
    -- do some mmu translation later:    

    t.o.toFE_addrphy_v := r.addrvir;
    t.o.toFE_addrvir_v := r.addrvir;
    t.o.toFE_branch_v := r.branch;
    t.o.toFE_addrvalid_v := t.valid;
    t.o.toFE_trap_v := '0';
    
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
