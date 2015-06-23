-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.bus_comp.all;
use work.corelib.all;
use work.cache_comp.all;
use work.genic_lib.all;
use work.gendc_lib.all;
use work.cache_comp.all;
use work.bus_comp.all;

entity armcache is
  port ( 
    rst    : in  std_logic;
    clk    : in  std_logic;
    hold   : in cli_hold;
    ici    : in genic_type_in;
    ico    : out genic_type_out;
    dci    : in gendc_type_in;
    dco    : out gendc_type_out;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type
    );
end armcache;

architecture rtl of armcache is

  type armcache_tmp_type is record
    dummy      : std_logic;
  end record;
  type armcache_reg_type is record
    genic_ctrl : gicl_ctrl;
    gendc_ctrl : gdcl_ctrl;
  end record;
  type armcache_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcache_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcache_reg_type;
  signal rdbg, cdbg : armcache_dbg_type;

  signal mi : ahbmst_mp_in_a(1 downto 0);
  signal mo : ahbmst_mp_out_a(1 downto 0);
  
  signal genic_i    : genic_type_in;
  signal genic_o    : genic_type_out;
  signal genic_ctrl : gicl_ctrl;
  signal genic_icmo : gencmem_type_ic_out;
  signal genic_icmi : gencmem_type_ic_in;
  signal genic_mcio : ahbmst_mp_out;
  signal genic_mcii : ahbmst_mp_in;
  
  signal gendc_i    : gendc_type_in;
  signal gendc_o    : gendc_type_out;
  signal gendc_ctrl : gdcl_ctrl;
  signal gendc_dcmo : gencmem_type_dc_out;
  signal gendc_dcmi : gencmem_type_dc_in;
  signal gendc_wbi  : genwb_type_in;
  signal gendc_wbo  : genwb_type_out;
  
  signal genwb_i     : genwb_type_in;
  signal genwb_o     : genwb_type_out;
  signal genwb_mcwbo : ahbmst_mp_out;
  signal genwb_mcwbi : ahbmst_mp_in;

  signal gencmem_i  : gencmem_type_in;
  signal gencmem_o  : gencmem_type_out;
  
begin  
    
  p0: process (clk, rst, r, apbi )
    variable v    : armcache_reg_type;
    variable t    : armcache_tmp_type;
    variable vdbg : armcache_dbg_type;
  begin 
    
    -- $(init(t:armcache_tmp_type))
    
    v := r;
    
    -- reset
    if ( rst = '0' ) then
      v.genic_ctrl.burst := '0';
      v.gendc_ctrl.writeback := '0';
      v.gendc_ctrl.allocateonstore := '0';
    end if;
    
    c <= v;
    
    genic_ctrl <= r.genic_ctrl;
    gendc_ctrl <= r.gendc_ctrl;
    
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


  ic0: genic port map ( rst, clk, hold, genic_i, genic_o, genic_ctrl, genic_icmo, genic_icmi,
                        genic_mcio, genic_mcii );
  genic_i <= ici;
  ico <= genic_o;
  genic_mcio <= mo(0);
  mi(0) <= genic_mcii;

  dc0: gendc port map ( rst, clk, hold, gendc_i, gendc_o, gendc_ctrl, gendc_dcmo, gendc_dcmi,
                        gendc_wbi, gendc_wbo );
  gendc_i <= dci;
  dco <= gendc_o;
  
  wb0: genwb port map ( rst, clk, genwb_i, genwb_o, genwb_mcwbo, genwb_mcwbi );
  genwb_i <= gendc_wbi;
  gendc_wbo <= genwb_o;
  genwb_mcwbo <= mo(1);
  mi(1) <= genwb_mcwbi;

  cm0: gencmem port map ( rst, clk, gencmem_i, gencmem_o);
  gencmem_i.ic <= genic_icmi;
  genic_icmo <= gencmem_o.ic;
  gencmem_i.dc <= gendc_dcmi;
  gendc_dcmo <= gencmem_o.dc;
  
  ahbmast0: ahbmst_mp generic map ( AHBMST_PORTS => 2)
                      port map ( rst, clk, mi, mo, ahbi, ahbo );

end rtl;
