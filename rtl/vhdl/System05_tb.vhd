--===========================================================================--
--
--  S Y N T H E Z I A B L E    System05   System On a Chip
--
--  This core adheres to the GNU public license  
--
-- File name      : system05.vhd
--
-- Purpose        : Top level file for a 6805 compatible system on a chip
--                  Designed for the Burch ED B5-Spartan IIe board with
--                  X2S300e FPGA,
--                  128K x 16 Word SRAM module (B5-SRAM)
--                  CPU I/O module (B5-Peripheral-Connectors)
--                  Using mimiUart from open cores modified to look like a 6850
--                  
-- Dependencies   : ieee.Std_Logic_1164
--                  ieee.std_logic_unsigned
--                  ieee.std_logic_arith
--                  ieee.numeric_std
--
-- Uses           : cpu05.vhd  (6805 compatible CPU core)
--                  miniuart3.vhd, (6850 compatible UART)
--                    rxunit3.vhd, 
--                    txunit3.vhd
--                  timer.vhd  (timer module)
--                  ioport.vhd (parallel I/O port)
--
-- Author         : John E. Kent      
--
--===========================================================================----
--
-- Revision History:
--===========================================================================--
--
--	 Version   Date            Author     Notes
--  0.0       14th July 2001  John Kent  Started design
--  0.1       30th May 2004   John Kent  Initial Release
--
--
--
-------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use IEEE.STD_LOGIC_ARITH.ALL;
   use IEEE.STD_LOGIC_UNSIGNED.ALL;
   use ieee.numeric_std.all;

entity System05_tb is
  port(
    LED         : out std_logic;  -- Diagnostic LED Flasher

    -- Memory Interface signals
    ram_csn     : out Std_Logic;
    ram_wrun    : out Std_Logic;
    ram_wrln    : out Std_Logic;
    ram_addr    : out Std_Logic_Vector(16 downto 0);
    ram_data    : inout Std_Logic_Vector(15 downto 0);

	 -- Stuff on the peripheral board
--  aux_clock   : in  Std_Logic;  -- Extra clock
--	 buzzer      : out Std_Logic;

	 -- PS/2 Mouse interface
--	 mouse_clock : in  Std_Logic;
--	 mouse_data  : in  Std_Logic;

	 -- Uart Interface
    rxbit       : in  Std_Logic;
	 txbit       : out Std_Logic;
    rts_n       : out Std_Logic;
    cts_n       : in  Std_Logic;

	 -- Keyboard interface
--    kb_clock    : in  Std_Logic;
-- 	kb_data     : in  Std_Logic;

	 -- CRTC output signals
--	 v_drive     : out Std_Logic;
--    h_drive     : out Std_Logic;
--    blue_lo     : out std_logic;
--    blue_hi     : out std_logic;
--    green_lo    : out std_logic;
--    green_hi    : out std_logic;
--    red_lo      : out std_logic;
--    red_hi      : out std_logic;

    -- External Bus
    bus_addr     : out   std_logic_vector(15 downto 0);
	 bus_data     : inout std_logic_vector(7 downto 0);
	 bus_rw       : out   std_logic;
	 bus_cs       : out   std_logic;
	 bus_clk      : out   std_logic;
	 bus_reset    : out   std_logic;

    -- I/O Ports
    porta        : inout std_logic_vector(7 downto 0);
    portb        : inout std_logic_vector(7 downto 0);
    portc        : inout std_logic_vector(7 downto 0);
    portd        : inout std_logic_vector(7 downto 0);

    -- Timer I/O
--    timer0_in    : in std_logic;
	 timer0_out   : out std_logic;
--    timer1_in    : in std_logic;
	 timer1_out   : out std_logic
	);
end System05_tb;

-------------------------------------------------------------------------------
-- Architecture for memio Controller Unit
-------------------------------------------------------------------------------
architecture my_computer of System05_tb is
  signal SysClk      : Std_Logic;  -- System Clock input
  signal Reset_n     : Std_logic;  -- Master Reset input (active low)
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  -- BOOT ROM
  signal rom_data_out  : Std_Logic_Vector(7 downto 0);

  -- UART Interface signals
  signal uart_data_out : Std_Logic_Vector(7 downto 0);  
  signal uart_cs       : Std_Logic;
  signal uart_irq      : Std_Logic;
  signal dcd_n         : Std_Logic;

  -- I/O Port
  signal ioport_data_out : std_logic_vector(7 downto 0);
  signal ioport_cs       : std_logic;

  -- Timer I/O
  signal timer_data_out : std_logic_vector(7 downto 0);
  signal timer_cs       : std_logic;
  signal timer_irq      : Std_Logic;

  -- RAM
  signal ram_cs       : std_logic; -- memory chip select
  signal ram_wrl      : std_logic; -- memory write lower
  signal ram_wru      : std_logic; -- memory write upper
  signal ram_data_out : std_logic_vector(7 downto 0);

  -- Sequencer Interface signals
  signal cpu_reset   : Std_Logic;
  signal cpu_clk     : Std_Logic;
  signal cpu_rw      : std_logic;
  signal cpu_vma     : std_logic;
  signal cpu_addr    : Std_Logic_Vector(15 downto 0);
  signal cpu_data_in : Std_Logic_Vector(7 downto 0);
  signal cpu_data_out: Std_Logic_Vector(7 downto 0);

  -- External interrupt input
  signal ext_irq     : Std_Logic;

  -- Counter signals
  signal countL       : std_logic_vector(23 downto 0);
  signal BaudCount    : std_logic_vector(4 downto 0);
  signal baudclk      : Std_Logic;

-----------------------------------------------------------------
--
-- CPU Core
--
-----------------------------------------------------------------

component cpu05 is
  port (    
	 clk       : in  std_logic;
    rst       : in  std_logic;
    vma       : out std_logic;
    rw        : out std_logic;
    addr      : out std_logic_vector(15 downto 0);
    data_in   : in  std_logic_vector(7 downto 0);
	 data_out  : out std_logic_vector(7 downto 0);
	 irq_ext   : in  std_logic;
	 irq_timer : in  std_logic;
	 irq_uart  : in  std_logic
	 );
end component cpu05;

------------------------------------------
--
-- Program memory
--
------------------------------------------

component boot_rom is
  port (
    addr     : in  Std_Logic_Vector(5 downto 0);  -- 64 byte boot rom
	 data     : out Std_Logic_Vector(7 downto 0)
  );
end component boot_rom;

-----------------------------------------------------------------
--
-- Open Cores Mini UART
--
-----------------------------------------------------------------

component miniUART
  port (
     clk      : in  Std_Logic;  -- System Clock
     rst      : in  Std_Logic;  -- Reset input (active high)
     cs       : in  Std_Logic;  -- miniUART Chip Select
     rw       : in  Std_Logic;  -- Read / Not Write
     irq      : out Std_Logic;  -- Interrupt
     Addr     : in  Std_Logic;  -- Register Select
     DataIn   : in  Std_Logic_Vector(7 downto 0); -- Data Bus In 
     DataOut  : out Std_Logic_Vector(7 downto 0); -- Data Bus Out
     RxC      : in  Std_Logic;  -- Receive Baud Clock
     TxC      : in  Std_Logic;  -- Transmit Baud Clock
     RxD      : in  Std_Logic;  -- Receive Data
     TxD      : out Std_Logic;  -- Transmit Data
	  DCD_n    : in  Std_Logic;  -- Data Carrier Detect
     CTS_n    : in  Std_Logic;  -- Clear To Send
     RTS_n    : out Std_Logic );  -- Request To send
end component;


---------------------------------------
--
-- Three port parallel I/O
--
---------------------------------------

component ioport is
  port (
     clk      : in std_logic;
	  rst      : in std_logic;
	  cs       : in std_logic;
	  rw       : in std_logic;
	  addr     : in std_logic_vector(2 downto 0);
	  data_in  : in std_logic_vector(7 downto 0);
	  data_out : out std_logic_vector(7 downto 0);
	  porta_io : inout std_logic_vector(7 downto 0);
	  portb_io : inout std_logic_vector(7 downto 0);
	  portc_io : inout std_logic_vector(7 downto 0);
	  portd_io : inout std_logic_vector(7 downto 0)
	  );
end component;

----------------------------------------
--
-- Timer module
--
----------------------------------------

component timer is
  port (
     clk       : in std_logic;
	  rst       : in std_logic;
	  cs        : in std_logic;
	  rw        : in std_logic;
	  addr      : in std_logic_vector(2 downto 0);
	  data_in   : in std_logic_vector(7 downto 0);
	  data_out  : out std_logic_vector(7 downto 0);
	  irq_out   : out std_logic;
     tim0_in   : in std_logic;
	  tim0_out  : out std_logic;
     tim1_in   : in std_logic;
	  tim1_out  : out std_logic
	  );
end component;

------------------------------------------
--
-- Global clock buffer for debug
--
------------------------------------------

--component BUFG is 
--  port (
--     i: in std_logic;
--	  o: out std_logic
--  );
--end component;

begin

-----------------------------------------------------------------------------
-- Instantiation of internal components
-----------------------------------------------------------------------------

my_cpu : cpu05 port map (    
	 clk	     => cpu_clk, 
    rst       => cpu_reset,
    vma       => cpu_vma,
    rw	     => cpu_rw,
    addr      => cpu_addr(15 downto 0),
    data_in   => cpu_data_in,
	 data_out  => cpu_data_out,
	 irq_ext   => ext_irq,
	 irq_timer => timer_irq,
	 irq_uart  => uart_irq
	 );

rom : boot_rom port map (
	 addr       => cpu_addr(5 downto 0),
    data       => rom_data_out
	 );

my_uart  : miniUART port map (
	 clk	     => cpu_clk,
	 rst       => cpu_reset,
    cs        => uart_cs,
	 rw        => cpu_rw,
    irq       => uart_irq,
    Addr      => cpu_addr(0),
	 Datain    => cpu_data_out,
	 DataOut   => uart_data_out,
	 RxC       => baudclk,
	 TxC       => baudclk,
	 RxD       => rxbit,
	 TxD       => txbit,
	 DCD_n     => dcd_n,
	 CTS_n     => cts_n,
	 RTS_n     => rts_n
	 );

my_ioport  : ioport port map (
    clk       => cpu_clk,
	 rst       => cpu_reset,
    cs        => ioport_cs,
	 rw        => cpu_rw,
    addr      => cpu_addr(2 downto 0),
	 data_in   => cpu_data_out,
	 data_out  => ioport_data_out,
	 porta_io  => porta,
	 portb_io  => portb,
	 portc_io  => portc,
	 portd_io  => portd
    );

my_timer  : timer port map (
    clk       => cpu_clk,
	 rst       => cpu_reset,
    cs        => timer_cs,
	 rw        => cpu_rw,
    addr      => cpu_addr(2 downto 0),
	 data_in   => cpu_data_out,
	 data_out  => timer_data_out,
    irq_out   => timer_irq,
	 tim0_in   => CountL(4),
	 tim0_out  => timer0_out,
	 tim1_in   => CountL(6),
	 tim1_out  => timer1_out
    );



--bufginst: BUFG port map(
--    i => countL(0),
--	 o => cpu_clk
--	 );

-- bufginst: BUFG port map(i => SysClk, o => cpu_clk );	 
	 
----------------------------------------------------------------------
--
--  Processes to read and write memory based on bus signals
--
----------------------------------------------------------------------

memory_decode: process( Reset_n, cpu_clk,
                 cpu_addr, cpu_vma,
					  rom_data_out, ram_data_out,
					  ioport_data_out, timer_data_out, uart_data_out, bus_data )
begin
    case cpu_addr(15 downto 6) is
		when "1111111111" =>
 		   cpu_data_in <= rom_data_out;
			ram_cs      <= '0';
		   ioport_cs   <= '0';
		   timer_cs    <= '0';
			uart_cs     <= '0';
			bus_cs      <= '0';
		when "0000000000" =>
		   --
			-- Decode 64 bytes of I/O space here
			--
			ram_cs <= '0';
			case cpu_addr(5 downto 3) is
			   --
				-- I/O ports $0000 - $0007
				--  
			   when "000" =>
              cpu_data_in <= ioport_data_out;
				  ioport_cs   <= cpu_vma;
				  timer_cs    <= '0';
			     uart_cs     <= '0';
			     bus_cs      <= '0';
				--
				-- Timer $0008 - $000F
				--
				when "001" =>
				  cpu_data_in <= timer_data_out;
				  ioport_cs   <= '0';
				  timer_cs    <= cpu_vma;
			     uart_cs     <= '0';
			     bus_cs      <= '0';
            --
				-- ACIA $0010 - $0017
				--
			   when "010" =>
		        cpu_data_in <= uart_data_out;
				  ioport_cs   <= '0';
				  timer_cs    <= '0';
			     uart_cs     <= cpu_vma;
			     bus_cs      <= '0';
            --
				-- Reserved $0018 - $003F
				--
				when others =>
				  cpu_data_in <= bus_data;
				  ioport_cs   <= '0';
				  timer_cs    <= '0';
			     uart_cs     <= '0';
			     bus_cs      <= cpu_vma;
         end case;
		when others =>
		  cpu_data_in <= ram_data_out;
		  ram_cs      <= cpu_vma;
		  ioport_cs   <= '0';
		  timer_cs    <= '0';
		  uart_cs     <= '0';
		  bus_cs      <= '0';
	 end case;
end process;

--------------------------------------------------------------
--
-- B5 SRAM interface
--
--------------------------------------------------------------
Ram_decode: process( Reset_n, cpu_clk,
                     cpu_addr, cpu_rw, cpu_vma, cpu_data_out,
                     ram_cs, ram_wrl, ram_wru, ram_data )
begin
    cpu_reset <= not Reset_n;
	 ram_wrl  <= (not cpu_rw) and cpu_addr(0);
    ram_wru  <= (not cpu_rw) and (not cpu_addr(0)); 
	 ram_wrln <= not ram_wrl;
	 ram_wrun <= not ram_wru;
    ram_csn  <= not( Reset_n and ram_cs and cpu_clk );
    ram_addr(16 downto 15) <= "00";
	 ram_addr(14 downto 0) <= cpu_addr(15 downto 1);

    if ram_cs = '1' then

		if ram_wrl = '1' then
		  ram_data(7 downto 0) <= cpu_data_out;
		else
        ram_data(7 downto 0)  <= "ZZZZZZZZ";
		end if;

		if ram_wru = '1' then
		  ram_data(15 downto 8) <= cpu_data_out;
		else
        ram_data(15 downto 8)  <= "ZZZZZZZZ";
		end if;

    else
      ram_data(7 downto 0)  <= "ZZZZZZZZ";
      ram_data(15 downto 8) <= "ZZZZZZZZ";
    end if;

    if cpu_addr(0) = '0' then
	   ram_data_out(7 downto 0) <= ram_data(15 downto 8);
	 else
	   ram_data_out(7 downto 0) <= ram_data(7 downto 0);
    end if;

end process;

--
-- CPU bus signals
--
my_bus : process( cpu_clk, cpu_reset, cpu_rw, cpu_addr, cpu_data_out )
begin
	bus_clk   <= cpu_clk;
   bus_reset <= cpu_reset;
	bus_rw    <= cpu_rw;
   bus_addr  <= cpu_addr;
	if( cpu_rw = '1' ) then
	   bus_data <= "ZZZZZZZZ";
   else
	   bus_data <= cpu_data_out;
   end if;
end process;

  --
  -- flash led to indicate code is working
  --
blink: process (SysClk, CountL )
begin
    if(SysClk'event and SysClk = '0') then
      countL <= countL + 1;			 
    end if;
	 LED <= countL(21);
end process;


--
-- 57.6 Kbaud * 16 divider for 25 MHz system clock
--
my_baud_clock: process( SysClk )
begin
    if(SysClk'event and SysClk = '0') then
		if( BaudCount = 26 )	then
		   BaudCount <= "00000";
		else
		   BaudCount <= BaudCount + 1;
		end if;			 
    end if;
    baudclk <= BaudCount(4);  -- 25MHz / 27  = 926,000 KHz = 57,870Bd * 16
	 dcd_n <= '0';
end process;

  --
  -- tie down inputs and outputs
  --
  -- CRTC output signals
  --
--	 v_drive     <= '0';
--    h_drive     <= '0';
--    blue_lo     <= '0';
--    blue_hi     <= '0';
--    green_lo    <= '0';
--    green_hi    <= '0';
--    red_lo      <= '0';
--    red_hi      <= '0';
--	 buzzer      <= '0';

  --
  -- tie down unused interrupts
  --
  ext_irq <= '0';
  cpu_clk <= SysClk;

-- *** Test Bench - User Defined Section ***
tb : PROCESS
	variable count : integer;
   BEGIN

	SysClk <= '0';
	Reset_n <= '0';

		for count in 0 to 512 loop
			SysClk <= '0';
			if count = 0 then
				Reset_n <= '0';
			elsif count = 1 then
				Reset_n <= '1';
			end if;
			wait for 100 ns;
			SysClk <= '1';
			wait for 100 ns;
		end loop;

      wait; -- will wait forever
   END PROCESS;
  
   
end my_computer; --===================== End of architecture =======================--

