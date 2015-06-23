-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;

-- todo: remove
use work.leon_config.all;

use work.debug.all;
use work.core_comp.all;
use work.tbench_comp.all;
use work.tbenchmem_comp.all;
use STD.TEXTIO.all;

entity tbench_gen is
  generic (
    msg1      : string := "32 kbyte 32-bit rom, 0-ws";
    msg2      : string := "2x128 kbyte 32-bit ram, 0-ws";
    pcihost   : boolean := false;	-- be PCI host
    DISASS    : integer := 0;	        -- enable disassembly to stdout
    clkperiod : integer := 20;		-- system clock period
    romfile   : string := "soft/tbenchsoft/armrom.dat";  -- rom contents
    ramfile   : string := "soft/tbenchsoft/armram.dat";  -- ram contents
    sdramfile : string := "soft/tbenchsoft/sdram.dat";  -- sdram contents
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 13;		-- rom address depth
    romtacc   : integer := 10;		-- rom access time (ns)
    ramwidth  : integer := 32;		-- ram data width (8/16/32)
    ramdepth  : integer := 15;		-- ram address depth
    rambanks  : integer := 2;		-- number of ram banks
    bytewrite : boolean := true;	-- individual byte write strobes
    ramtacc   : integer := 10		-- ram access time (ns)
  );
  port ( 
    i       : in  tbench_gen_typ_in;
    o       : out tbench_gen_typ_out
    );
end tbench_gen;

architecture behav of tbench_gen is
  
  signal clk : std_logic := '0';
  signal Rst    : std_logic := '0';			-- Reset
  constant ct : integer := clkperiod/2;

  signal address  : std_logic_vector(27 downto 0);
  signal data     : std_logic_vector(31 downto 0);

  signal ramsn    : std_logic_vector(4 downto 0);
  signal ramoen   : std_logic_vector(4 downto 0);
  signal rwen     : std_logic_vector(3 downto 0);
  signal rwenx    : std_logic_vector(3 downto 0);
  signal romsn    : std_logic_vector(1 downto 0);
  signal iosn     : std_logic;
  signal oen      : std_logic;
  signal read     : std_logic;
  signal writen   : std_logic;
  signal brdyn    : std_logic;
  signal bexcn    : std_logic;
  signal wdog     : std_logic;
  signal dsuen, dsutx, dsurx, dsubre, dsuact : std_logic;
  signal test     : std_logic;
  signal error    : std_logic;
  signal pio	: std_logic_vector(15 downto 0);
  signal GND      : std_logic := '0';
  signal VCC      : std_logic := '1';
  signal NC       : std_logic := 'Z';
  signal clk2     : std_logic := '1';
    
  signal sdcke    : std_logic_vector ( 1 downto 0);  -- clk en
  signal sdcsn    : std_logic_vector ( 1 downto 0);  -- chip sel
  signal sdwen    : std_logic;                       -- write en
  signal sdrasn   : std_logic;                       -- row addr stb
  signal sdcasn   : std_logic;                       -- col addr stb
  signal sddqm    : std_logic_vector ( 3 downto 0);  -- data i/o mask
  signal sdclk    : std_logic;       
  signal plllock    : std_logic;       

  signal emdio   : std_logic;
  signal etx_clk : std_logic := '0';
  signal erx_clk : std_logic := '0';
  signal erxd    : std_logic_vector(3 downto 0);   
  signal erx_dv  : std_logic; 
  signal erx_er  : std_logic; 
  signal erx_col : std_logic;
  signal erx_crs : std_logic;
  signal etxd    : std_logic_vector(3 downto 0);   
  signal etx_en  : std_logic; 
  signal etx_er  : std_logic; 
  signal emdc    : std_logic;    
  signal emddis  : std_logic;    
  signal epwrdwn : std_logic;
  signal ereset  : std_logic;
  signal esleep  : std_logic;
  signal epause  : std_logic;

begin  

  clk <= not clk after ct * 1 ns;
  rst <= '0', '1' after clkperiod*10 * 1 ns;

  -- boot message
  bootmsg : process(rst)
  begin
    if rst'event and (rst = '1') then --'
      print("Core generic testbench ");
      print(msg1); print(msg2); print("");
    end if;
  end process;

  -------------------------------------------------------------------------------
  -- processor 
    c0 : core port map (rst, clk, sdclk, plllock, 
                        error, address, data, 
                        ramsn, ramoen, rwenx, romsn, iosn, oen, read, writen, brdyn, 
                        bexcn, sdcke, sdcsn, sdwen, sdrasn, sdcasn, sddqm, sdclk,
                        pio, wdog, dsuen, dsutx, dsurx, dsubre, dsuact, test);
  

  -------------------------------------------------------------------------------
  -- 8-bit ram
  ram8d : if ramwidth = 8 generate
    ram0 : iram 
      generic map (index => 0, abits => ramdepth, echk => 2, tacc => ramtacc,
                   fname => ramfile)
      port map (A => address(ramdepth-1 downto 0), D => data(31 downto 24),
                CE1 => ramsn(0), WE => rwen(0), OE => ramoen(0));
  end generate;

  -- 16-bit ram
  ram16d : if ramwidth = 16 generate
    rambnk : for i in 0 to rambanks-1 generate
      ramarr : for j in 0 to 1 generate
        ram0 : iram 
	  generic map (index => j, abits => ramdepth, echk => 4, 
		       tacc => ramtacc, fname => ramfile)
          port map (A => address(ramdepth downto 1), D => data((31 - j*8) downto (24-j*8)),
                    CE1 => ramsn(i), WE => rwen(j), OE => ramoen(i));
      end generate;
    end generate;
  end generate;

  -- 32-bit ram
  ram32d : if ramwidth = 32 generate
    rambnk : for i in 0 to rambanks-1 generate
      ramarr : for j in 0 to 3 generate
        ram0 : iram 
	  generic map (index => j, abits => ramdepth, echk => 0, 
		       tacc => ramtacc, fname => ramfile)
          port map (A => address(ramdepth+1 downto 2), D => data((31 - j*8) downto (24-j*8)),
                    CE1 => ramsn(i), WE => rwen(j), OE => ramoen(i));
      end generate;
    end generate;
  end generate;

  -------------------------------------------------------------------------------
  -- 8-bit rom 
  rom8d : if romwidth = 8 generate
    pio(1 downto 0) <= "LL";	  -- 8-bit data bus
    rom0 : iram 
      generic map (index => 0, abits => romdepth, echk => 2, tacc => romtacc, fname => romfile)
        port map (A => address(romdepth-1 downto 0), D => data(31 downto 24),
                  CE1 => romsn(0), WE => VCC, OE => oen);
  end generate;

  -- 16-bit rom 
  rom16d : if romwidth = 16 generate
    pio(1 downto 0) <= "LH";	  -- 16-bit data bus
    romarr : for i in 0 to 1 generate
      rom0 : iram 
	generic map (index => i, abits => romdepth, echk => 4, tacc => romtacc,
		     fname => romfile)
        port map (A => address(romdepth downto 1), D => data((31 - i*8) downto (24-i*8)),
                  CE1 => romsn(0), WE => VCC, OE => oen);
    end generate;
  end generate;

  -- 32-bit rom 
  rom32d : if romwidth = 32 generate
    pio(1 downto 0) <= "HH";	  -- 32-bit data bus
    romarr : for i in 0 to 3 generate
      rom0 : iram 
	generic map (index => i, abits => romdepth, echk => 0, tacc => romtacc,
		     fname => romfile)
        port map (A => address(romdepth+1 downto 2), D => data((31 - i*8) downto (24-i*8)),
                  CE1 => romsn(0), WE => VCC, OE => oen);
    end generate;
  end generate;

  -------------------------------------------------------------------------------
  -- optional sdram
  sdram : if SDRAMEN generate
    u0: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => data(31 downto 16), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u1: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => data(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
    u2: mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
	PORT MAP(
            Dq => data(31 downto 16), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(3 downto 2));
    u3: mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
	PORT MAP(
            Dq => data(15 downto 0), Addr => address(14 downto 2),
            Ba => address(16 downto 15), Clk => sdclk, Cke => sdcke(0),
            Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
            Dqm => sddqm(1 downto 0));
  end generate;

  -------------------------------------------------------------------------------
  -- write strobes
  rwen <= rwenx when bytewrite else (rwenx(0) & rwenx(0) & rwenx(0) & rwenx(0));

end behav;




