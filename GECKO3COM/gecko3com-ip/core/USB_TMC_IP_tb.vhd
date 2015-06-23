--  GECKO3COM IP Core
--
--  Copyright (C) 2009 by
--   ___    ___   _   _
--  (  _ \ (  __)( ) ( )
--  | (_) )| (   | |_| |   Bern University of Applied Sciences
--  |  _ < |  _) |  _  |   School of Engineering and
--  | (_) )| |   | | | |   Information Technology
--  (____/ (_)   (_) (_)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details. 
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--  URL to the project description: 
--    http://labs.ti.bfh.ch/gecko/wiki/systems/gecko3com/start
----------------------------------------------------------------------------------
--
--  Author:  Andreas Habegger, Christoph Zimmermann
--  Date of creation: 8. April 2009
--  Description:
--   	F
--
--  Target Devices:	Xilinx Spartan3 FPGA's (usage of BlockRam in the Datapath)
--  Tool versions: 	11.1
--  Dependencies:
--
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library XilinxCoreLib;

library work;
use work.USB_TMC_IP_Defs.all;
use work.USB_TMC_cmp.all;

entity USB_TMC_IP_tb is
end USB_TMC_IP_tb;



architecture simulation of USB_TMC_IP_tb is

  -- components


component USB_TMC_IP
 port (
    i_nReset,
    i_IFCLK,									 -- GPIF CLK (is Master)
	 i_SYSCLK,									 -- FPGA System CLK
    i_WRU,                              -- write from GPIF
    i_RDYU 	  : in   	std_logic;        -- GPIF is ready
--	 i_ENAIP	  : in   	std_logic;  		 -- enable the IP core
--	 i_RDYD2IP : in   	std_logic;			 -- data RDY 2 the IP core   
--	 i_d2USB   : in   	std_logic_vector(SIZE_DBUS_FPGA-1 downto 0);  -- FPGA DBUS
--	 i_RxD 	  : in   	std_logic;
--	 o_TxD     : out		std_logic;
--	 i_Switches: in		std_logic_vector(NUMBER_OF_SW-1 downto 0);
    o_WRX,                              -- To write to GPIF
    o_RDYX    : out  	std_logic;      -- Core is ready
--	 o_RDYIP   : out  	std_logic; 		 -- IP ready FPGA site
--	 o_DAVIP   : out  	std_logic; 		 -- Data available for FPGA
	 o_LEDrx,                            -- controll LED rx __DEB_INFO__
	 o_LEDtx : out 	 	std_logic; 		 -- controll LED tx __DEB_INFO__
	 o_LEDrun  : out  	std_logic;      -- controll LED running signalisation __DEB_INFO__
--	 o_d2FPGA  : out  	std_logic_vector(SIZE_DBUS_FPGA-1 downto 0);  -- FPGA DBUS
    b_dbus 	  : inout	std_logic_vector(SIZE_DBUS_GPIF-1 downto 0));  -- bidirect data bus
end component USB_TMC_IP;



	-- simulation types
	type TsimSend is (finish, sending, waiting); 
  -- simulation constants

 --constant TIME_BASE  : time := 1 ns;

  constant CLK_PERIOD : time := 20 ns;

  constant DATA_BUS_SIZE  : integer                                     := SIZE_DBUS_GPIF;
  constant WORD_VALUE1    : std_logic_vector(DATA_BUS_SIZE-1 downto 0) := x"FF00";
  constant WORD_VALUE2    : std_logic_vector(DATA_BUS_SIZE-1 downto 0) := x"B030";
  constant WORD_VALUE3    : std_logic_vector(DATA_BUS_SIZE-1 downto 0) := x"50A0";
  -- signals

  signal sim_clk : std_logic;
  signal sim_rst : std_logic;

  signal s_LEDrun, s_LEDtx, s_LEDrx : std_logic;
  signal s_Switches : std_logic_vector(NUMBER_OF_SW-1 downto 0);
  
  
  signal sim_1      : boolean := false;
  
  signal send_data  : TsimSend := finish;


  signal WRU  : std_logic;
  signal RDYU : std_logic;

  signal WRX  : std_logic;
  signal RDYX : std_logic;


  signal data_bus : std_logic_vector(DATA_BUS_SIZE-1 downto 0);


begin  -- simulation

-------------------------------------------------------------------------------
-- Design maps
-------------------------------------------------------------------------------

DUT : USB_TMC_IP
  port map(
    i_nReset   => sim_rst,
    i_IFCLK    => sim_clk,									 -- GPIF CLK (is Master)
	 i_SYSCLK   => sim_clk,									 -- FPGA System CLK
    i_WRU      => WRU,                             -- write from GPIF
    i_RDYU 	   => RDYU,        -- GPIF is ready
--	 i_ENAIP	   => ,   		 -- enable the IP core
--	 i_RDYD2IP 	=> ,	 -- data RDY 2 the IP core   
--	 i_d2USB    => ,   -- FPGA DBUS
--	 i_RxD 	   => s_RxD, 
--	 o_TxD      => s_TxD,
--	 i_Switches => s_Switches,
    o_WRX      => WRX,                        -- To write to GPIF
    o_RDYX     => RDYX,   -- Core is ready
--	 o_RDYIP    => ,	 -- IP ready FPGA site
--	 o_DAVIP    => , 		 -- Data available for FPGA
	 o_LEDrx    => s_LEDrx, 		 -- controll LED rx
	 o_LEDtx    => s_LEDtx, 		 -- controll LED tx
	 o_LEDrun   => s_LEDrun,        -- controll LED running signalisation
--	 o_d2FPGA   => ,  -- FPGA DBUS
    b_dbus 	   => data_bus -- bidirect data bus
	);  
   
-------------------------------------------------------------------------------
-- monitoring FSM
------------------------------------------------------------------------------
 --state_monitor : entity work.state_monitor(tracing);
 
-- monitor: process (fsm_clk)
--  use std.textio.all;
--  file state_file : TEXT open WRITE_MODE is "FSM_STATES.txt";
--  
-- -- alias fsm_state is byte_com_tb.dut.pr_state;	
-- -- alias fsm_clk is DUT.i_IFCLK;
--	
--  begin  -- process monitor
--    if falling_edge(fsm_clk) then
--      report to_string(now) & ": " & to_string(fsm_state);
--    end if;
--  end process monitor;


-------------------------------------------------------------------------------
-- CLK process
-------------------------------------------------------------------------------
   clk_process: process
	begin
		sim_clk<='0';
		wait for CLK_PERIOD/2;
		sim_clk<='1';
		wait for CLK_PERIOD/2;
		if sim_1 then
			wait;
		end if;
	end process;
	
	
	
	rst_process: process
	begin
		sim_rst<='0';
		wait for CLK_PERIOD;
		sim_rst<='1';
		wait;
	end process;
	
	
	

  assert not(WRX = '1' and RDYX = '1') report "WRX and RDYX are high on the same time" severity warning;

  assert not(WRU = '1' and RDYU = '1') report "WRU and RDYU -> DATA delet" severity note;


  assert sim_rst = '0' report "system reset" severity note;

-------------------------------------------------------------------------------
-- Send Data
-------------------------------------------------------------------------------
   sendData: process(sim_clk)
		variable v_toggle : integer range 0 to 3 := 0;
	begin
		if rising_edge(sim_clk) then
			if send_data = sending then
				if v_toggle = 0 then
					v_toggle := 1;
					data_bus <= WORD_VALUE1;
				elsif v_toggle = 1 then
					v_toggle := 2;
					data_bus <= WORD_VALUE2;
				elsif v_toggle = 2 then
					v_toggle := 0;
					data_bus <= WORD_VALUE3;	
				end if;
			elsif send_data = finish then
				data_bus <= (others => 'Z');
				
			end if;
		end if;
	end process sendData;
-------------------------------------------------------------------------------
-- stimuli
-------------------------------------------------------------------------------

  

  stimuli : process
  begin
    WRU  <= '0';
    RDYU <= '0';
	 send_data <= finish;
	 
	 
    assert sim_rst = '1' report "system ready to start" severity note;
    
    wait for 10 ns;
    
    assert sim_1 report "Simulation started" severity note;
    
    wait for  2*CLK_PERIOD;
    

    WRU <= '1';

    wait for CLK_PERIOD;

    if(WRX = '1') then
      assert WRX = '1' report "WRX : busreservation during a GPIF reservation" severity warning;
	 else
	   assert WRX = '0' report "WRX : no buscolision" severity warning;
    end if;
	 
	 wait for CLK_PERIOD;
	 
	 send_data <= sending;
	 
	 wait for CLK_PERIOD;
    
	 if(RDYX = '0') then
		send_data <= waiting;
      assert RDYX = '0' report "RDYX : wait on IP ready ...." severity note;
      wait on RDYX until RDYX = '1';
		assert RDYX = '1' report "CORE is ready for data >>>" severity note;
    else
       assert RDYX = '1' report "CORE is ready for data >>>" severity note;
    end if;
	 
	 for i in 1 to 15 loop -- then wait for a few clock periods...
		if RDYX = '1' then
			send_data <= sending;
		else
			send_data <= waiting;
		end if;
		wait until rising_edge(sim_clk);
	 end loop;
	 
    WRU <= '0';
	 send_data <= finish;
    assert WRU = '0' report "DATA written" severity note;
    wait for CLK_PERIOD;

    assert WRU = '0' report "output Z" severity note;

    wait for CLK_PERIOD;


  --end process writeData;

    if(WRX = '0') then
      assert WRX = '0' report "WRX : Waiting on incoming MSG ...." severity note;
      wait on WRX until WRX= '1';
		wait for 7*CLK_PERIOD;
		RDYU <= '1';
		assert WRX = '1' report "CORE send data RQ >>>" severity note;
    else
	   wait for 7*CLK_PERIOD;
		RDYU <= '1';
		assert WRX = '1' report "CORE send data RQ >>>" severity note;
    end if;

      
		
		while WRX = '1' loop
			RDYU <= '1';
			send_data <= finish;
			assert WRX = '1' report "CORE sended Data >>>" severity note;
			wait until rising_edge(sim_clk);
		end loop;
		
		RDYU <= '0';

      wait for CLK_PERIOD;

      sim_1 <= false;

		assert sim_1 report "<<< End of simulation >>>" severity note;

  --  end process readData;
  end process stimuli;

end simulation;
