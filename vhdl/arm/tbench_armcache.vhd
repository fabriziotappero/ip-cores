-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.int.all;
use work.memdef.all;
use work.corelib.all;
use work.arm_comp.all;
use work.armpctrl.all;
use work.cache_comp.all;
use work.gendc_lib.all;
use work.genic_lib.all;
use IEEE.std_logic_arith.all;
use IEEE.Std_Logic_unsigned.conv_integer;
use STD.TEXTIO.all;

entity tbench_armcache is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    clkn    : in  std_logic;
    hold    : in cli_hold;
    ici     : out genic_type_in;
    ico     : in genic_type_out;
    dci     : out gendc_type_in;
    dco     : in gendc_type_out;
    i       : in  armiu_typ_in;
    o       : out armiu_typ_out
    );
end tbench_armcache;

architecture rtl of tbench_armcache is


  type dcache_test is record
    addr : std_logic_vector(31 downto 0);
    data : std_logic_vector(31 downto 0);
    param : gdcl_param;
    annul : std_logic;
  end record;
  type icache_test is record
    addr : std_logic_vector(31 downto 0);
    bra : std_logic;
    annul : std_logic;
  end record;
  
  type dcache_test_a is array (natural range <>) of dcache_test;
  type icache_test_a is array (natural range <>) of icache_test;

  type armiu_itmp_type is record
    ici : genic_type_in;
  end record;
  type armiu_dtmp_type is record
    dci : gendc_type_in;
  end record;
  
  type armiu_ireg_type is record
    ici : icache_test_a(1 downto 0);
    ici_valid : std_logic_vector(1 downto 0);
  end record;
  type armiu_dreg_type is record
    dci : dcache_test_a(3 downto 0);
    dci_valid : std_logic_vector(3 downto 0);
  end record;
  type armiu_ddbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_dtmp_type;
     -- pragma translate_on
  end record;
  type armiu_idbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_itmp_type;
     -- pragma translate_on
  end record;
  signal dr, dc       : armiu_dreg_type;
  signal drdbg, dcdbg : armiu_ddbg_type;
  signal ir, ic       : armiu_ireg_type;
  signal irdbg, icdbg : armiu_idbg_type;
  signal din : dcache_test;
  signal iin : icache_test;
  signal iin_next, din_next : std_logic;
  
  procedure dstore(signal din : out dcache_test;
                  signal din_next : in std_logic;
                  addr : in integer;
                  data : in integer;
                  size : in lmd_memsize;
                  signed : in std_logic;
                  lock : in std_logic) is
    variable addr_vec : std_logic_vector(31 downto 0);
    variable data_vec : std_logic_vector(31 downto 0);
    variable lasttime : time;
  begin

    wait until falling_edge(clk) and din_next = '1';
    wait for 1 ns;
    
    addr_vec := std_logic_vector(conv_unsigned(addr, 32));
    data_vec := (others => 'U');
    din.addr <= addr_vec;
    din.data <= data_vec;
    din.annul <= '0';
    din.param.size <= size;
    din.param.signed <= signed;
    din.param.lock <= lock;
    din.param.read <= '0';
    din.param.addrin <= '1';
    din.param.writedata <= '0';
    
    wait until falling_edge(clk) and din_next = '1';
    wait for 1 ns;
    
    addr_vec := std_logic_vector(conv_unsigned(addr, 32));
    data_vec := std_logic_vector(conv_unsigned(data, 32));
    din.addr <= addr_vec;
    din.data <= data_vec;
    din.annul <= '0';
    din.param.size <= size;
    din.param.lock <= lock;
    din.param.signed <= signed;
    din.param.read <= '0';
    din.param.addrin <= '0';
    din.param.writedata <= '1';
        
  end;

    procedure dload(signal din : out dcache_test;
                  signal din_next : in std_logic;
                  addr : in integer;
                  size : in lmd_memsize;
                  signed : in std_logic;
                  lock : in std_logic) is
    variable addr_vec : std_logic_vector(31 downto 0);
    variable data_vec : std_logic_vector(31 downto 0);
    variable lasttime : time;
  begin

    wait until falling_edge(clk) and din_next = '1';
    wait for 1 ns;
    
    addr_vec := std_logic_vector(conv_unsigned(addr, 32));
    din.addr <= addr_vec;
    din.data <= (others => 'U');
    din.annul <= '0';
    din.param.size <= size;
    din.param.signed <= signed;
    din.param.lock <= lock;
    din.param.read <= '1';
    din.param.addrin <= '1';
    din.param.writedata <= '0';
        
  end;

    procedure iload(signal iin : out icache_test;
                    signal iin_next : in std_logic;
                    addr_start : in integer;
                    addr_end : in integer ) is
    variable addr_vec : std_logic_vector(31 downto 0);
    variable data_vec : std_logic_vector(31 downto 0);
    variable lasttime : time;
    variable bra : std_logic;
  begin
    bra := '1';
    iin.annul <= '0';
    for i in 0 to ((addr_end - addr_start)/4)-1 loop

      wait until falling_edge(clk) and iin_next = '1';
      wait for 1 ns;

      addr_vec := std_logic_vector(conv_unsigned(addr_start+(i*4), 32));
      iin.addr <= addr_vec;
      iin.bra <= bra;
      bra := '0';
    end loop;  -- i
    
  end;

begin  

  dip0: process
  begin
    wait for 1 ns;
    wait until rst = '1';
    dstore (din, din_next, 16#80000014#, 16#0081000f#, lmd_word, '0', '0');
    dstore (din, din_next, 16#80000000#, 16#04080300#, lmd_word, '0', '0');
    dstore (din, din_next, 16#80000004#, 16#d5384830#, lmd_word, '0', '0');
    dstore (din, din_next, 16#80000008#, 16#000f0000#, lmd_word, '0', '0');
    dstore (din, din_next, 16#8000000c#, 16#00000000#, lmd_word, '0', '0');
    dstore (din, din_next, 16#40000000#, 16#01020304#, lmd_word, '0', '0');
    dstore (din, din_next, 16#40000004#, 16#05060708#, lmd_word, '0', '0');
    dload  (din, din_next, 16#40000000#, lmd_word, '0', '0');
    dload  (din, din_next, 16#40000004#, lmd_word, '0', '0');
    dstore (din, din_next, 16#40004000#, 16#10111213#, lmd_byte, '0', '0');
    dload  (din, din_next, 16#40004000#, lmd_word, '0', '0');
    wait;
    
  end process dip0;
  
  iip0: process
    variable iv    : armiu_ireg_type;
    variable it    : armiu_itmp_type;
    variable ivdbg : armiu_idbg_type;
  begin
    wait for 1 ns;
    wait until rst = '1';
    iload (iin, iin_next, 16#00000000#, 16#00001000#);
    wait;
  end process iip0;
  
  ip0: process (clk, clkn, rst, ir, hold, i, ico, dco, iin )
    variable iv    : armiu_ireg_type;
    variable it    : armiu_itmp_type;
    variable ivdbg : armiu_idbg_type;
  begin 
    
    iv := ir;
    
    -- reset
    if ( rst = '0' ) then
      iv.ici_valid := (others => '0');
    end if;

    iin_next <= '0';
    if hold.hold = '0' then
      iv.ici(1) := iin;
      iv.ici(0) := ir.ici(1);
      iv.ici_valid(1) := '1';
      iv.ici_valid(0) := ir.ici_valid(1);
      iin_next <= '1';
    end if;
    
    it.ici.pc_r := ir.ici(0).addr;
    it.ici.pc_v := ir.ici(1).addr;
    it.ici.bra_r := ir.ici(0).bra;
    it.ici.bra_v := ir.ici(1).bra;
    it.ici.annul := ir.ici(0).annul or (not ir.ici_valid(0));
    it.ici.flush := '0';
    
    ic <= iv;
    ici <= it.ici;
    
    -- pragma translate_off
    ivdbg := irdbg;
    ivdbg.dbg := it;
    icdbg <= ivdbg;
    -- pragma translate_on  
    
  end process ip0;



  dp0: process (clk, clkn, rst, dr, hold, i, ico, dco, din )
    variable dv    : armiu_dreg_type;
    variable dt    : armiu_dtmp_type;
    variable dvdbg : armiu_ddbg_type;
  begin 
    
    dv := dr;

    -- reset
    if ( rst = '0' ) then
      dv.dci_valid := (others => '0');
    end if;
    
    din_next <= '0';
    if hold.hold = '0' then
      dv.dci(3) := din;
      dv.dci(2 downto 0) := dr.dci(3 downto 1);
      dv.dci_valid(3) := '1';
      dv.dci_valid(2 downto 0) := dr.dci_valid(3 downto 1);
      din_next <= '1';
    end if;
    
    dt.dci.addr_in := dr.dci(2).addr; 
    dt.dci.data_in := dr.dci(2).data; 
    dt.dci.addr_re := dr.dci(1).addr;
    dt.dci.data_re := dr.dci(1).data;
    dt.dci.addrin_re := dr.dci(1).param.addrin and dr.dci_valid(1);
    dt.dci.param_r := dr.dci(1).param;
    dt.dci.annul := dr.dci(1).annul;
    
    dc <= dv;
    dci <= dt.dci;
    
    -- pragma translate_off
    dvdbg := drdbg;
    dvdbg.dbg := dt;
    dcdbg <= dvdbg;
    -- pragma translate_on  
    
  end process dp0;

  pregs : process (clk, dc, ic)
  begin
    if rising_edge(clk) then
      ir <= ic;
      dr <= dc;
      -- pragma translate_off
      irdbg <= icdbg;
      drdbg <= dcdbg;
      -- pragma translate_on
    end if;
  end process;


end rtl;
