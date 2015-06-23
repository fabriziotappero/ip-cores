-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.iface.all;
use work.target.all;
use work.armlib_iuiface.all;
use work.armlib_int.all;

entity armiu_imstg is
  port ( 
    rst     : in  std_logic;
    clk     : in  clk_type;
    imstgi  : in  aii_atyp_imstg_in;
    imstgo  : out aii_atyp_imstg_out
    );
end armiu_imstg;

architecture rtl of armiu_imstg is

  type imstg_tmp_type is record
    valid      : std_logic;
    addrvir_4  : std_logic_vector(31 downto 0); -- virtual pc+4
    addrphy    : std_logic_vector(31 downto 0); -- pc after translation
    imstgo     : aii_atyp_imstg_out;
  end record;
  type imstg_reg_type is record
    branch     : std_logic;
    valid      : std_logic;
    addrvir    : std_logic_vector(31 downto 0);  -- virtual pc
  end record;
  type imstg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : imstg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : imstg_reg_type;
  signal rdbg, cdbg : imstg_dbg_type;


begin  
    
  p0: process (clk, rst, r, imstgi  )
    variable v    : imstg_reg_type;
    variable t    : imstg_tmp_type;
    variable vdbg : imstg_dbg_type;
  begin 
    
    -- $(init(t:imstg_tmp_type))
    
    v := r;
         
    t.addrvir_4 := r.addrvir;
    t.valid := r.valid;
    
    ain_incdec(r.addrvir(31 downto 2),t.addrvir_4(31 downto 2),'1','1');

    if imstgi.pstate.holdn_r = '1' and imstgi.pstate.nextinsn_v = '1' then
      v.addrvir := t.addrvir_4;
    end if;

    if imstgi.flush_v = '1' then
      v.valid := '0';
      t.valid := '0';
    end if;
    
    if imstgi.branch_v = '1' then
      v.addrvir := imstgi.addrvir_v;
      v.valid := '1';
    end if;
    
    -- reset
    if ( rst = '0' ) then
      v.addrvir := (others => '0');
      v.valid := '1';
    end if;
    
    -- do some mmu translation later:    

    t.imstgo.toFE_addrphy_v := r.addrvir;
    t.imstgo.toFE_addrvir_v := r.addrvir;
    t.imstgo.toFE_branch_v := r.branch;
    t.imstgo.toFE_addrvalid_v := t.valid;
    
    c <= v;
    
    imstgo <= t.imstgo;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    cdbg <= vdbg;
    -- pragma translate_on  end process p0;
    
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
