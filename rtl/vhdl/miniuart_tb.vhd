--===========================================================================--
--
-- MiniUart3 Test Bench
--
--
-- John Kent 16th January 2004
--
--
-------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use IEEE.STD_LOGIC_ARITH.ALL;
   use IEEE.STD_LOGIC_UNSIGNED.ALL;
   use ieee.numeric_std.all;

entity miniuart3_testbench is
end miniuart3_testbench;

-------------------------------------------------------------------------------
-- Architecture for memio Controller Unit
-------------------------------------------------------------------------------
architecture behavior of miniuart3_testbench is
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  -- CPU Interface signals
  signal SysClk       : Std_Logic;
  signal uart_reset   : Std_Logic;
  signal uart_cs      : Std_Logic;
  signal uart_rw      : Std_Logic;
  signal uart_addr    : Std_Logic;
  signal uart_data_in : Std_Logic_Vector(7 downto 0);
  signal uart_data_out: Std_Logic_Vector(7 downto 0);
  signal uart_irq     : Std_Logic;
  signal rxclk        : Std_Logic;
  signal txclk        : Std_Logic;
  signal rxbit        : Std_Logic;
  signal txbit        : Std_Logic;
  signal dcd_n        : Std_Logic;
  signal cts_n        : Std_Logic;
  signal rts_n        : Std_Logic;

-----------------------------------------------------------------
--
-- Open Cores Mini UART
--
-----------------------------------------------------------------
component miniUART
  port (
     --
	  -- CPU signals
	  --
     clk      : in  Std_Logic;  -- System Clock
     rst      : in  Std_Logic;  -- Reset input (active high)
     cs       : in  Std_Logic;  -- miniUART Chip Select
     rw       : in  Std_Logic;  -- Read / Not Write
     irq      : out Std_Logic;  -- Interrupt
     Addr     : in  Std_Logic;  -- Register Select
     DataIn   : in  Std_Logic_Vector(7 downto 0); -- Data Bus In 
     DataOut  : out Std_Logic_Vector(7 downto 0); -- Data Bus Out
     --
	  -- Uart Signals
	  --
     RxC      : in  Std_Logic;  -- Receive Baud Clock
     TxC      : in  Std_Logic;  -- Transmit Baud Clock
     RxD      : in  Std_Logic;  -- Receive Data
     TxD      : out Std_Logic;  -- Transmit Data
	  DCD_n    : in  Std_Logic;  -- Data Carrier Detect
     CTS_n    : in  Std_Logic;  -- Clear To Send
     RTS_n    : out Std_Logic );  -- Request To send
end component; --================== End of entity ==============================--

begin

  -----------------------------------------------------------------------------
  -- Instantiation of internal components
  -----------------------------------------------------------------------------

my_uart  : miniUART port map (
    clk       => SysClk,
	 rst       => uart_reset,
    cs        => uart_cs,
	 rw        => uart_rw,
    Irq       => uart_irq,
    Addr      => uart_addr,
	 Datain    => uart_data_in,
	 DataOut   => uart_data_out,
	 RxC       => rxclk,
	 TxC       => txclk,
	 RxD       => rxbit,
	 TxD       => txbit,
	 DCD_n     => dcd_n,
	 CTS_n     => cts_n,
	 RTS_n     => rts_n
	 );


  -- *** Test Bench - User Defined Section ***
   tb : PROCESS
	variable count : integer;
   BEGIN

   cts_n <= '0';
	dcd_n <= '0';

		for count in 0 to 4096 loop
		   if (count mod 16) = 0 then
		     rxclk <= '1';
			  txclk <= '1'; 
		   elsif (count mod 16) = 8 then
		     rxclk <= '0';
			  txclk <= '0'; 
         end if;

			case count is
			when 0 =>
				uart_reset <= '1';
 		      uart_cs <= '0';
				uart_rw <= '1';
				uart_addr <= '0';
				uart_data_in <= "00000000";
				rxbit <= '1';
			when 1 =>
				uart_reset <= '0';
			when 3 =>
 		      uart_cs <= '1';
				uart_rw <= '0'; -- write control
				uart_addr <= '0';
				uart_data_in <= "00010001";
			when 4 =>
 		      uart_cs <= '0';
				uart_rw <= '1';
				uart_addr <= '0';
				uart_data_in <= "00000000";
			when 5 =>
 		      uart_cs <= '1';
				uart_rw <= '0'; -- write data
				uart_addr <= '1';
				uart_data_in <= "01010101";
			when 6 =>
 		      uart_cs <= '0';
				uart_rw <= '1';
				uart_addr <= '1';
				uart_data_in <= "00000000";
			when 256 =>
            rxbit <= '0'; -- start
			when 512 =>
			   rxbit <= '1'; -- bit 0
			when 768 =>
            rxbit <= '0'; -- bit 1
			when 1024 =>
			   rxbit <= '1'; -- bit 2
			when 1280 =>
            rxbit <= '1'; -- bit3
			when 1536 =>
			   rxbit <= '0'; -- bit 4
			when 1792 =>
            rxbit <= '0'; -- bit 5
			when 2048 =>
			   rxbit <= '1'; -- bit 6
			when 2304 =>
            rxbit <= '0'; -- bit 7
			when 2560 =>
			   rxbit <= '1'; -- stop 1
			when 2816 =>
			   rxbit <= '1'; -- stop 2
			when 3100 =>
 		      uart_cs <= '1';
				uart_rw <= '1'; -- read control
				uart_addr <= '0';
			when 3101 =>
 		      uart_cs <= '0';
				uart_rw <= '1';
				uart_addr <= '0';
			when 3102 =>
 		      uart_cs <= '1';
				uart_rw <= '1'; -- read data
				uart_addr <= '1';
			when 3103 =>
 		      uart_cs <= '0';
				uart_rw <= '1';
				uart_addr <= '1';
			when others =>
			   null;
			end case;
			SysClk <= '1';
			wait for 100 ns;
			SysClk <= '0';
			wait for 100 ns;
		end loop;

      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

end behavior; --===================== End of architecture =======================--

