-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.cache_config.all;
use work.tech_map.all;
use work.gencmem_lib.all;
use work.gendc_lib.all;
use work.genic_lib.all;
use work.cache_comp.all;

entity gencmem is
  port ( 
    rst    : in  std_logic; 
    clk    : in  std_logic;
    i  : in  gencmem_type_in;
    o  : out gencmem_type_out
    );
end gencmem;

architecture rtl of gencmem is

  type it_data_type_a is array (natural range <>) of std_logic_vector(GCML_IC_TL_BSZ -1 downto 0);
  type id_data_type_a is array (natural range <>) of std_logic_vector(GCML_IC_DL_BSZ -1 downto 0);
  type dt_data_type_a is array (natural range <>) of std_logic_vector(GCML_DC_TL_BSZ -1 downto 0);
  type dd_data_type_a is array (natural range <>) of std_logic_vector(GCML_DC_DL_BSZ -1 downto 0);
  type gencmem_tmp_type is record
    dummy : std_logic;
    o  : gencmem_type_out;
    
    -- icache tag
    it_addr : std_logic_vector(GCML_IC_TADDR_BSZ -1 downto 0);
    it_datain  : it_data_type_a(CFG_IC_SETS-1 downto 0);
    it_enable : std_logic;
    it_write : std_logic_vector(CFG_IC_SETS-1 downto 0);
    -- icache data
    id_addr : std_logic_vector(GCML_IC_DADDR_BSZ -1 downto 0);
    id_datain  : id_data_type_a(CFG_IC_SETS-1 downto 0);
    id_enable : std_logic;
    id_write : std_logic_vector(CFG_IC_SETS-1 downto 0);
    
    -- dcache tag
    dt_addr : std_logic_vector(GCML_DC_TADDR_BSZ -1 downto 0);
    dt_datain  : dt_data_type_a(CFG_DC_SETS-1 downto 0);
    dt_enable : std_logic;
    dt_write : std_logic_vector(CFG_DC_SETS-1 downto 0);
    -- icache data
    dd_addr : std_logic_vector(GCML_DC_DADDR_BSZ -1 downto 0);
    dd_datain  : dd_data_type_a(CFG_DC_SETS-1 downto 0);
    dd_enable : std_logic;
    dd_write : std_logic_vector(CFG_DC_SETS-1 downto 0);
    
  end record;
  type gencmem_reg_type is record
    dummy : std_logic;
  end record;
  type gencmem_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : gencmem_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : gencmem_reg_type;
  signal rdbg, cdbg : gencmem_dbg_type;

  -- icache tag
  signal it_addr : std_logic_vector(GCML_IC_TADDR_BSZ -1 downto 0);
  signal it_datain  : it_data_type_a(CFG_IC_SETS-1 downto 0);
  signal it_dataout : it_data_type_a(CFG_IC_SETS-1 downto 0);
  signal it_enable : std_logic;
  signal it_write : std_logic_vector(CFG_IC_SETS-1 downto 0);
  -- icache data
  signal id_addr : std_logic_vector(GCML_IC_DADDR_BSZ -1 downto 0);
  signal id_datain  : id_data_type_a(CFG_IC_SETS-1 downto 0);
  signal id_dataout : id_data_type_a(CFG_IC_SETS-1 downto 0);
  signal id_enable : std_logic;
  signal id_write : std_logic_vector(CFG_IC_SETS-1 downto 0);

  -- dcache tag
  signal dt_addr : std_logic_vector(GCML_DC_TADDR_BSZ -1 downto 0);
  signal dt_datain  : dt_data_type_a(CFG_DC_SETS-1 downto 0);
  signal dt_dataout : dt_data_type_a(CFG_DC_SETS-1 downto 0);
  signal dt_enable : std_logic;
  signal dt_write : std_logic_vector(CFG_DC_SETS-1 downto 0);
  -- dcache data
  signal dd_addr : std_logic_vector(GCML_DC_DADDR_BSZ -1 downto 0);
  signal dd_datain  : dd_data_type_a(CFG_DC_SETS-1 downto 0);
  signal dd_dataout : dd_data_type_a(CFG_DC_SETS-1 downto 0);
  signal dd_enable : std_logic;
  signal dd_write : std_logic_vector(CFG_DC_SETS-1 downto 0);

begin  
    
  p0: process ( clk, rst, r, i,
                it_dataout, id_dataout,
                dt_dataout, dd_dataout )
    variable v    : gencmem_reg_type;
    variable t    : gencmem_tmp_type;
    variable vdbg : gencmem_dbg_type;
  begin 
    
    -- $(init(t:gencmem_tmp_type))
    
    v := r;
    
    -- icache address
    t.it_addr := i.ic.addr(GICL_TADDR_U downto GICL_TADDR_D);
    t.id_addr := i.ic.addr(GICL_DADDR_U downto GICL_DADDR_D);

    -- icache inputs
    t.it_enable := '1';
    for j in 0 to CFG_IC_SETS-1 loop 
      t.it_datain(j) := gcml_icttostd(i.ic.tag_line);
      t.id_datain(j) := gcml_icdtostd(i.ic.dat_line);
      t.it_write(j) := i.ic.tag_write(j);
      t.id_write(j) := i.ic.dat_write(j);
    end loop;
    -- icache outputs
    for j in 0 to CFG_IC_SETS-1 loop 
      gcml_stdtoict(it_dataout(j),t.o.ic.tag_line(j));
      gcml_stdtoicd(id_dataout(j),t.o.ic.dat_line(j));
    end loop;
    
    -- dcache address
    t.dt_addr := i.dc.addr(GDCL_TADDR_U downto GDCL_TADDR_D);
    t.dd_addr := i.dc.addr(GDCL_DADDR_U downto GDCL_DADDR_D);
    
    -- dcache inputs
    t.dt_enable := '1';
    for j in 0 to CFG_DC_SETS-1 loop 
      t.dt_datain(j) := gcml_dcttostd(i.dc.tag_line);
      t.dd_datain(j) := gcml_dcdtostd(i.dc.dat_line);
      t.dt_write(j) := i.dc.tag_write(j);
      t.dd_write(j) := i.dc.dat_write(j);
    end loop;
    -- dcache outputs
    for j in 0 to CFG_DC_SETS-1 loop 
      gcml_stdtodct(dt_dataout(j),t.o.dc.tag_line(j));
      gcml_stdtodcd(dd_dataout(j),t.o.dc.dat_line(j));
    end loop;

    -- reset
    if ( rst = '0' ) then
    end if;
    
    c <= v;

    o <= t.o;
    
    it_addr <= t.it_addr;
    id_addr <= t.id_addr;
    it_enable <= t.it_enable;
    for j in 0 to CFG_IC_SETS-1 loop 
      it_datain(j) <= t.it_datain(j);
      id_datain(j) <= t.id_datain(j);
      it_write(j) <= t.it_write(j);
      id_write(j) <= t.id_write(j);
    end loop;

    dt_addr <= t.dt_addr;
    dd_addr <= t.dd_addr;
    dt_enable <= t.dt_enable;
    for j in 0 to CFG_DC_SETS-1 loop 
      dt_datain(j) <= t.dt_datain(j);
      dd_datain(j) <= t.dd_datain(j);
      dt_write(j) <= t.dt_write(j);
      dd_write(j) <= t.dd_write(j);
    end loop;

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
  
  -- icache <tag and data>
  icm0 : for i in 0 to CFG_IC_SETS-1 generate
    -- <icache tag>
    itags0 : syncram
      generic map (
        dbits => GCML_IC_TL_BSZ,
        abits => GCML_IC_TADDR_BSZ
      )
      port map (
        it_addr, clk,
        it_datain(i),
        it_dataout(i),
        it_enable,
        it_write(i)
      );
    -- <icache data>
    idata0 : syncram
      generic map (
        dbits => GCML_IC_DL_BSZ,
        abits => GCML_IC_DADDR_BSZ
      )
      port map (
        id_addr, clk,
        id_datain(i),
        id_dataout(i),
        id_enable,
        id_write(i)
      );
  end generate;

  -- dcache <tag and data>
  dcm0 : for i in 0 to CFG_DC_SETS-1 generate
    -- <dcache tag>
    dtags0 : syncram
      generic map (
        dbits => GCML_DC_TL_BSZ,
        abits => GCML_DC_TADDR_BSZ
      )
      port map (
        dt_addr, clk,
        dt_datain(i),
        dt_dataout(i),
        dt_enable,
        dt_write(i)
      );
    -- <dcache data>
    ddata0 : syncram
      generic map (
        dbits => GCML_DC_DL_BSZ,
        abits => GCML_DC_DADDR_BSZ
      )
      port map (
        dd_addr, clk,
        dd_datain(i),
        dd_dataout(i),
        dd_enable,
        dd_write(i)
      );
  end generate;

    
  
end rtl;

