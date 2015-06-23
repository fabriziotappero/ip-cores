-----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.


-----------------------------------------------------------------------------
-- Entity:      tbgen
-- File:        tbgen.vhd
-- Author:      Jiri Gaisler - ESA/ESTEC
-- Description: Generic test bench for LEON. The test bench uses generate
--		statements to build a LEON system with the desired memory
--		size and data width.
------------------------------------------------------------------------------
-- Version control:
-- 11-08-1999:  First implemetation
-- 26-09-1999:  Release 1.0
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.config.all;
use work.iface.all;
use work.leonlib.all;
use work.debug.all;
use STD.TEXTIO.all;

entity tbgen is
  generic (

    msg1      : string := "32 kbyte 32-bit rom, 0-ws";
    msg2      : string := "2x128 kbyte 32-bit ram, 0-ws";
    pcihost   : boolean := false;	-- be PCI host
    DISASS    : integer := 0;	-- enable disassembly to stdout
    clkperiod : integer := 20;		-- system clock period
    romfile   : string := "tsource/rom.dat";  -- rom contents
    ramfile   : string := "tsource/ram.dat";  -- ram contents
    sdramfile : string := "tsource/sdram.rec";  -- sdram contents
    romwidth  : integer := 32;		-- rom data width (8/32)
    romdepth  : integer := 13;		-- rom address depth
    romtacc   : integer := 10;		-- rom access time (ns)
    ramwidth  : integer := 32;		-- ram data width (8/16/32)
    ramdepth  : integer := 15;		-- ram address depth
    rambanks  : integer := 2;		-- number of ram banks
    bytewrite : boolean := true;	-- individual byte write strobes
    ramtacc   : integer := 10		-- ram access time (ns)
  );
end; 

architecture behav of tbgen is


component iram
      generic (index : integer := 0;		-- Byte lane (0 - 3)
	       Abits: Positive := 10;		-- Default 10 address bits (1 Kbyte)
	       echk : integer := 0;		-- Generate EDAC checksum
	       tacc : integer := 10;		-- access time (ns)
	       fname : string := "ram.dat");	-- File to read from
      port (  
	A : in std_logic_vector;
        D : inout std_logic_vector(7 downto 0);
        CE1 : in std_logic;
        WE : in std_logic;
        OE : in std_logic

); end component;

component testmod
  port (
	clk   	: in   	 std_logic;
	dsurx 	: in   	 std_logic;
	dsutx  	: out    std_logic;
	error	: in   	 std_logic;
	iosn 	: in   	 std_logic;
	oen  	: in   	 std_logic;
	read 	: in   	 std_logic;
	writen	: in   	 std_logic;
	brdyn  	: out    std_logic;
	bexcn  	: out    std_logic;
	address : in     std_logic_vector(7 downto 0);
	data	: inout  std_logic_vector(31 downto 0);
	ioport  : out     std_logic_vector(15 downto 0)
	);
end component;

component mt48lc16m16a2
   generic (index : integer := 0;		-- Byte lane (0 - 3)
	    fname : string := "tsrouce/sdram.rec");	-- File to read from
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        Addr  : IN    STD_LOGIC_VECTOR (12 DOWNTO 0);
        Ba    : IN    STD_LOGIC_VECTOR (1 downto 0);
        Clk   : IN    STD_LOGIC;
        Cke   : IN    STD_LOGIC;
        Cs_n  : IN    STD_LOGIC;
        Ras_n : IN    STD_LOGIC;
        Cas_n : IN    STD_LOGIC;
        We_n  : IN    STD_LOGIC;
        Dqm   : IN    STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END component;

  function to_xlhz(i : std_logic) return std_logic is
  begin
    case to_X01Z(i) is
    when 'Z' => return('Z');
    when '0' => return('L');
    when '1' => return('H');
    when others => return('X');
    end case;
  end;

TYPE logic_xlhz_table IS ARRAY (std_logic'LOW TO std_logic'HIGH) OF std_logic;

CONSTANT cvt_to_xlhz : logic_xlhz_table := (
                         'Z',  -- 'U'
                         'Z',  -- 'X'
                         'L',  -- '0'
                         'H',  -- '1'
                         'Z',  -- 'Z'
                         'Z',  -- 'W'
                         'Z',  -- 'L'
                         'Z',  -- 'H'
                         'Z'   -- '-'
                        );
function buskeep (signal v : in std_logic_vector) return std_logic_vector is
variable res : std_logic_vector(v'range);
begin
  for i in v'range loop res(i) := cvt_to_xlhz(v(i)); end loop;
  return(res);
end;


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
    
signal pci_rst_n   : std_logic := '0';
signal pci_clk	   : std_logic := '0';
signal pci_gnt_in_n: std_logic := '0';
signal pci_ad 	   : std_logic_vector(31 downto 0);
signal pci_cbe_n   : std_logic_vector(3 downto 0);
signal pci_frame_n : std_logic;
signal pci_irdy_n  : std_logic;
signal pci_trdy_n  : std_logic;
signal pci_devsel_n: std_logic;
signal pci_stop_n  : std_logic;
signal pci_perr_n  : std_logic;
signal pci_par 	   : std_logic;    
signal pci_req_n   : std_logic;
signal pci_serr_n  : std_logic;
signal pci_idsel_in: std_logic;
signal pci_lock_n  : std_logic;
signal pci_host    : std_logic;
signal pci_arb_req_n   : std_logic_vector(0 to 3);
signal pci_arb_gnt_n   : std_logic_vector(0 to 3);
signal power_state : std_logic_vector(1 downto 0);
signal pci_66      : std_logic;
signal pme_enable  : std_logic;
signal pme_clear   : std_logic;
signal pme_status  : std_logic;

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

-- clock and reset

  clk <= not clk after ct * 1 ns;
  rst <= '0', '1' after clkperiod*10 * 1 ns;
  dsuen <= '1'; dsubre <= '0';

  etx_clk <= not etx_clk after 25 ns when ETHEN else '0';
  erx_clk <= not etx_clk after 25 ns when ETHEN else '0';
  emdio <= 'H'; erxd <= "0011"; erx_dv <= '0'; erx_er <= '0';
  erx_col <= '0';  erx_crs <= '0'; 

  pci_clk <= not pci_clk after 15 ns when PCIEN else '0';
  pci_rst_n <= '0', '1' after clkperiod*10 * 1 ns;
  pci_frame_n      <= 'H';
  pci_ad           <= (others => 'H');
  pci_cbe_n        <= (others => 'H');
  pci_par          <= 'H';
  pci_req_n        <= 'H';
  pci_idsel_in     <= 'H';
  pci_lock_n       <= 'H';
  pci_irdy_n       <= 'H';
  pci_trdy_n       <= 'H';
  pci_devsel_n     <= 'H';
  pci_stop_n       <= 'H';
  pci_perr_n       <= 'H';
  pci_serr_n   <= 'H';
  pci_host <= '1' when pcihost else '0';


-- processor (no PCI, no ethernet)
    p0 : if not PCIEN  and not ETHEN generate
      leon0 : leon port map (rst, clk, sdclk, plllock, 

		error, address, data, 

	ramsn, ramoen, rwenx, romsn, iosn, oen, read, writen, brdyn, 
	bexcn, sdcke, sdcsn, sdwen, sdrasn, sdcasn, sddqm, sdclk,
	pio, wdog, dsuen, dsutx, dsurx, dsubre, dsuact, test);

    end generate;

-- processor (PCI)
    p1 : if PCIEN and not ETHEN generate
          leon0 : leon_pci 
 	      port map (rst, clk, sdclk, plllock, 

		error, address, data, 

		ramsn, ramoen, rwenx, romsn, iosn, oen, read, writen, 
	        brdyn, bexcn, 
		sdcke, sdcsn, sdwen, sdrasn, sdcasn, sddqm, sdclk,
		pio, wdog, dsuen, dsutx, dsurx, dsubre, dsuact, test, 
        	pci_rst_n, pci_clk, pci_gnt_in_n, pci_idsel_in,
		pci_lock_n, pci_ad, pci_cbe_n, pci_frame_n, pci_irdy_n,
		pci_trdy_n, pci_devsel_n, pci_stop_n, pci_perr_n, pci_par,
		pci_req_n, pci_serr_n, pci_host, pci_66, pci_arb_req_n, 
	  	pci_arb_gnt_n, power_state, pme_enable, pme_clear, pme_status );

  end generate;

-- processor (PCI, ethernet)
    p2 : if PCIEN  and ETHEN generate
      leon0 : leon_eth_pci port map (rst, clk, sdclk, plllock, 

		error, address, data, 

	ramsn, ramoen, rwenx, romsn, iosn, oen, read, writen, brdyn, 
	bexcn, sdcke, sdcsn, sdwen, sdrasn, sdcasn, sddqm, sdclk,
	pio, wdog, dsuen, dsutx, dsurx, dsubre, dsuact, test, 
        pci_rst_n, pci_clk, pci_gnt_in_n, pci_idsel_in,
	pci_lock_n, pci_ad, pci_cbe_n, pci_frame_n, pci_irdy_n,
	pci_trdy_n, pci_devsel_n, pci_stop_n, pci_perr_n, pci_par,
	pci_req_n, pci_serr_n, pci_host, pci_66, pci_arb_req_n, 
	pci_arb_gnt_n, power_state, pme_enable, pme_clear, pme_status,
        emdio, etx_clk, erx_clk, erxd, erx_dv, erx_er, erx_col, erx_crs,
        etxd, etx_en, etx_er, emdc,
        emddis, epwrdwn, ereset, esleep, epause);

    end generate;
-- processor (no PCI, ethernet)
    p3 : if not PCIEN  and ETHEN generate
      leon0 : leon_eth port map (rst, clk, sdclk, plllock, 

		error, address, data, 

	ramsn, ramoen, rwenx, romsn, iosn, oen, read, writen, brdyn, 
	bexcn, sdcke, sdcsn, sdwen, sdrasn, sdcasn, sddqm, sdclk,
	pio, wdog, dsuen, dsutx, dsurx, dsubre, dsuact, 
        emdio, etx_clk, erx_clk, erxd, erx_dv, erx_er, erx_col, erx_crs,
        etxd, etx_en, etx_er, emdc,
        emddis, epwrdwn, ereset, esleep, epause, test);

    end generate;
-- write strobes

  rwen <= rwenx when bytewrite else (rwenx(0) & rwenx(0) & rwenx(0) & rwenx(0));
-- 8-bit rom 

  rom8d : if romwidth = 8 generate

    pio(1 downto 0) <= "LL";	  -- 8-bit data bus


      rom0 : iram 
        generic map (index => 0, abits => romdepth, echk => 2, tacc => romtacc,
		     fname => romfile)
        port map (A => address(romdepth-1 downto 0), D => data(31 downto 24),
                  CE1 => romsn(0), WE => VCC, OE => oen);


    rom2 : process (address, romsn, writen)
    begin
      if (writen and not romsn(1)) = '1' then
        case address(1 downto 0) is
	when "00" => data(31 downto 24) <= "00000001";
	when "01" => data(31 downto 24) <= "00100011";
	when "10" => data(31 downto 24) <= "01000101";
	when others => data(31 downto 24) <= "01100111";
        end case;
      else data(31 downto 24) <= (others => 'Z'); end if;
    end process;

  end generate;

-- 16-bit rom 

  rom16d : if romwidth = 16 generate

    pio(1 downto 0) <= "LH";	  -- 16-bit data bus

    romarr : for i in 0 to 1 generate
      rom0 : iram 
	generic map (index => i, abits => romdepth, echk => 4, tacc => romtacc,
		     fname => romfile)
        port map (A => address(romdepth downto 1), 
		  D => data((31 - i*8) downto (24-i*8)), CE1 => romsn(0),
		  WE => VCC, OE => oen);
    end generate;

    rom2 : process (address, romsn, writen)
    begin
      if (writen and not romsn(1)) = '1' then
        case address(1 downto 0) is
	when "00" => data(31 downto 16) <= "0000000100100011";
	when others => data(31 downto 16) <= "0100010101100111";
        end case;
      else data(31 downto 16) <= (others => 'Z'); end if;
    end process;

  end generate;

-- 32-bit rom 

  rom32d : if romwidth = 32 generate

    pio(1 downto 0) <= "HH";	  -- 32-bit data bus

    romarr : for i in 0 to 3 generate
      rom0 : iram 
	generic map (index => i, abits => romdepth, echk => 0, tacc => romtacc,
		     fname => romfile)
        port map (A => address(romdepth+1 downto 2), 
		  D => data((31 - i*8) downto (24-i*8)), CE1 => romsn(0),
		  WE => VCC, OE => oen);
    end generate;


    data(31 downto 0) <= "00000001001000110100010101100111" when (romsn(1) or not writen) = '0' 
    else (others => 'Z');
  end generate;

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
          port map (A => address(ramdepth downto 1),
		    D => data((31 - j*8) downto (24-j*8)), CE1 => ramsn(i), 
		    WE => rwen(j), OE => ramoen(i));
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
          port map (A => address(ramdepth+1 downto 2),
		    D => data((31 - j*8) downto (24-j*8)), CE1 => ramsn(i), 
		    WE => rwen(j), OE => ramoen(i));
      end generate;


    end generate;


  end generate;

-- boot message

    bootmsg : process(rst)
    begin
      if rst'event and (rst = '1') then --'
        print("LEON-2 generic testbench (leon2-"& LEON_VERSION & ")");
        print("Bug reports to Jiri Gaisler, jiri@gaisler.com");
	print("");
        print("Testbench configuration:");
        print(msg1); print(msg2); print("");
      end if;
    end process;

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

-- test module

  testmod0 : testmod port map (clk, dsutx, dsurx, error, iosn, oen, read, 
		writen, brdyn, bexcn, address(7 downto 0), data , pio);
  test <= '1' when DISASS > 0 else '0';

-- cross-strap UARTs

  pio(14) <= to_XLHZ(pio(11));	-- RX1 <- TX2
  pio(10) <= to_XLHZ(pio(15));	-- RX2 <- TX1
  pio(12) <= to_XLHZ(pio(9));	-- CTS1 <- RTS2
  pio(8) <= to_XLHZ(pio(13));	-- CTS2 <- RTS1

  pio(15) <= 'H';
  pio(13) <= 'H';
  pio(11) <= 'H';
  pio(9) <= 'H';

  pio(2) <= 'H' when not bytewrite else 'L';

  pio(3) <= wdog when WDOGEN else 'H'; -- WDOG output on IO3
--  pio(3) <= clk2;  		  -- clk/2 as uart clock
--  clk2 <= not clk2 when rising_edge(clk) else clk2;
  wdog <= 'H';			  -- WDOG pull-up
  error <= 'H';			  -- ERROR pull-up
  data <= (others => 'H');

  data <= buskeep(data) after 5 ns;


-- waitstates 

  wsgen : process
  begin
    if (romtacc < (2*clkperiod - 20)) then pio(5 downto 4) <= "LL";
    elsif (romtacc < (3*clkperiod - 20)) then pio(5 downto 4) <= "LH";
    elsif (romtacc < (4*clkperiod - 20)) then pio(5 downto 4) <= "HL";
    else pio(5 downto 4) <= "HH"; end if;
    if (ramtacc < (2*clkperiod - 20)) then pio(7 downto 6) <= "LL";
    elsif (ramtacc < (3*clkperiod - 20)) then pio(7 downto 6) <= "LH";
    elsif (ramtacc < (4*clkperiod - 20)) then pio(7 downto 6) <= "HL";
    else pio(7 downto 6) <= "HH"; end if;
    wait on rst;
  end process;

end ;

