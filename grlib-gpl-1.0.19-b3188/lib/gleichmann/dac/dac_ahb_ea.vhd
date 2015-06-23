-----------------------------------------------------------------------------------------
-- SIGMA DELTA DAC WITH AHB INTERFACE
-----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

entity dac_ahb is
  generic (
    length : integer := 16;
    hindex : integer := 0;
    haddr  : integer := 0;
    hmask  : integer := 16#fff#;
    tech   : integer := 0;
    kbytes : integer := 1); 
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    dac_out : out std_ulogic
    );
end;

architecture rtl of dac_ahb is

  component sigdelt
    generic (
      c_dacin_length : positive);
    port (
      reset   : in  std_logic;
      clock   : in  std_logic;
      dac_in  : in  std_logic_vector(c_dacin_length-1 downto 0);
      dac_out : out std_logic);
  end component;

  constant abits : integer := log2(kbytes) + 8;

  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_GLEICHMANN, GLEICHMANN_DAC, 0, 0, 0),
--    4      => ahb_membar(haddr, '1', '1', hmask), -- memory @ 0xA000_000
    4      => ahb_iobar(haddr, hmask),  -- I/O area @ 0xFFFA_0000
    others => zero32);

  type reg_type is
    record
      hwrite : std_ulogic;
      hready : std_ulogic;
      hsel   : std_ulogic;
      addr   : std_logic_vector(abits+1 downto 0);
      size   : std_logic_vector(1 downto 0);
    end record;

  signal r, c    : reg_type;
  signal ramsel  : std_ulogic;
  signal write   : std_logic_vector(3 downto 0);
  signal ramaddr : std_logic_vector(abits-1 downto 0);
  signal ramdata : std_logic_vector(31 downto 0);

  type   mem is array(0 to 15) of std_logic_vector(31 downto 0);
  signal memarr : mem;
  signal ra     : std_logic_vector(3 downto 0);

  signal rstp : std_ulogic;             -- high-active reset

begin

  rstp <= not rst;

  comb : process (ahbsi, r, rst, ramdata)
    variable bs    : std_logic_vector(3 downto 0);
    variable v     : reg_type;
    variable haddr : std_logic_vector(abits-1 downto 0);
  begin
    v                                              := r; v.hready := '1'; bs := (others => '0');
    if (r.hwrite or not r.hready) = '1' then haddr := r.addr(abits+1 downto 2);
    else
      haddr := ahbsi.haddr(abits+1 downto 2); bs := (others => '0');
    end if;

    if ahbsi.hready = '1' then
      v.hsel   := ahbsi.hsel(hindex) and ahbsi.htrans(1);
      v.hwrite := ahbsi.hwrite and v.hsel;
      v.addr   := ahbsi.haddr(abits+1 downto 0);
      v.size   := ahbsi.hsize(1 downto 0);
    end if;

    if r.hwrite = '1' then
      case r.size(1 downto 0) is
        when "00"   => bs (conv_integer(r.addr(1 downto 0))) := '1';
        when "01"   => bs                                    := r.addr(1) & r.addr(1) & not (r.addr(1) & r.addr(1));
        when others => bs                                    := (others => '1');
      end case;
      v.hready := not (v.hsel and not ahbsi.hwrite);
      v.hwrite := v.hwrite and v.hready;
    end if;

    if rst = '0' then v.hwrite := '0'; v.hready := '1'; end if;
    write                      <= bs; ramsel <= v.hsel or r.hwrite; ahbso.hready <= r.hready;
    ramaddr                    <= haddr; c <= v; ahbso.hrdata <= ramdata;

  end process;

  ahbso.hresp   <= "00";
  ahbso.hsplit  <= (others => '0');
  ahbso.hirq    <= (others => '0');
  ahbso.hcache  <= '1';
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;

--  ra : for i in 0 to 3 generate
--    aram : syncram generic map (tech, abits, 8) port map (
--      clk, ramaddr, ahbsi.hwdata(i*8+7 downto i*8),
--      ramdata(i*8+7 downto i*8), ramsel, write(3-i)); 
--  end generate;

  main : process(rst, clk)
  begin
    if rst = '0' then
      memarr <= (others => (others => '0'));
      ra <= (others => '0');
--    end if;
    elsif rising_edge(clk) then
      if r.hwrite = '1' then
        memarr(conv_integer(ramaddr)) <= ahbsi.hwdata;
      end if;
      ra <= ramaddr(3 downto 0);
    end if;
  end process;

  ramdata <= memarr(conv_integer(ra));

  sigdelt_1 : sigdelt
    generic map (
      c_dacin_length => length)
    port map (
      reset   => rstp,
      clock   => clk,
      dac_in  => memarr(0)(length-1 downto 0),
      dac_out => dac_out);

  reg : process (clk)
  begin
    if rising_edge(clk) then r <= c; end if;
  end process;

-- pragma translate_off
  bootmsg : report_version
    generic map ("dac_ahb" & tost(hindex) &
                 ": AHB DAC Module rev 0");
-- pragma translate_on
end;

