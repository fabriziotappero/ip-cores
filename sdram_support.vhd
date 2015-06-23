----------------------------------------------------------------------------------
-- Company: OPL Aerospatiale AG
-- Engineer: Owen Lynn <lynn0p@hotmail.com>
-- 
-- Create Date:    15:35:09 08/18/2009 
-- Design Name: 
-- Module Name:    sdram_support - impl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: This contains all the dirty primitives used by all the other modules.
--  Anything that's small and would be considered plumbing goes in here.
--
-- Dependencies: Xilinx primitives
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--  Copyright (c) 2009 Owen Lynn <lynn0p@hotmail.com>
--  Released under the GNU Lesser General Public License, Version 3
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cmd_bank_addr_switch is
	port(
		sel      : in std_logic;
		cmd0_in  : in std_logic_vector(2 downto 0);
		bank0_in : in std_logic_vector(1 downto 0);
		addr0_in : in std_logic_vector(12 downto 0);
		cmd1_in  : in std_logic_vector(2 downto 0);
		bank1_in : in std_logic_vector(1 downto 0);
		addr1_in : in std_logic_vector(12 downto 0);
		cmd_out  : out std_logic_vector(2 downto 0);
		bank_out : out std_logic_vector(1 downto 0);
		addr_out : out std_logic_vector(12 downto 0)
	);
end cmd_bank_addr_switch;

architecture impl of cmd_bank_addr_switch is
begin

	cmd_out  <= cmd0_in  when sel = '0' else cmd1_in;
	bank_out <= bank0_in when sel = '0' else bank1_in;
	addr_out <= addr0_in when sel = '0' else addr1_in;

end impl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity wait_counter is
	generic(
		BITS : integer;
		CLKS : integer
	);
	port(
	    clk : in std_logic;
		 rst : in std_logic;
		done : out std_logic
	);
end wait_counter;

architecture impl of wait_counter is
	
	signal reg : std_logic_vector(BITS-1 downto 0);
	
begin

	process(clk,rst)
	begin
		if (rst = '1') then
			done <= '0';
			reg <= CONV_STD_LOGIC_VECTOR(CLKS, BITS);
		elsif (rising_edge(clk)) then
			if (reg > x"00") then
				done <= '0';
				reg <= reg - 1;
			else
				done <= '1';
			end if;
		end if;
	end process;
	
end architecture;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sdram_dcm is
	port(
	   reset           : in  std_logic;
		clk100mhz       : in  std_logic;
		locked          : out std_logic;
		dram_clkp       : out std_logic;
		dram_clkn       : out std_logic;
		clk_000         : out std_logic;
		clk_090         : out std_logic;
		clk_180         : out std_logic;
		clk_270         : out std_logic
	);
end sdram_dcm;

architecture impl of sdram_dcm is

	signal dcm1_reset       : std_logic;
	signal dcm1_locked      : std_logic;
	signal dcm1_clk_raw_000 : std_logic;
	signal dcm1_clk_raw_090 : std_logic;
	signal dcm1_clk_000     : std_logic;
	signal dcm1_clk_090     : std_logic;
	signal dcm1_clk_180     : std_logic;
	signal dcm1_clk_270     : std_logic;
	
begin
	
	SDRAM_DCM : DCM_SP
   generic map (
      CLKDV_DIVIDE => 2.0,                   --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                             --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE => 2,                     --  Can be any integer from 1 to 32 
      CLKFX_MULTIPLY => 2,                   --  Can be any integer from 1 to 32
      CLKIN_DIVIDE_BY_2 => FALSE,            --  TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD => 10.0,                  --  Specify period of input clock
      CLKOUT_PHASE_SHIFT => "NONE",          --  Specify phase shift of "NONE", "FIXED" or "VARIABLE" 
      CLK_FEEDBACK => "1X",                  --  Specify clock feedback of "NONE", "1X" or "2X" 
      DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                             --     an integer from 0 to 15
      DLL_FREQUENCY_MODE => "LOW",           -- "HIGH" or "LOW" frequency mode for DLL
      DUTY_CYCLE_CORRECTION => TRUE,         --  Duty cycle correction, TRUE or FALSE
      PHASE_SHIFT => 0,                      --  Amount of fixed phase shift from -255 to 255
      STARTUP_WAIT => FALSE)                 --  Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
   port map (
      CLK0     => dcm1_clk_raw_000,      -- 0 degree DCM CLK ouptput
      CLK90    => dcm1_clk_raw_090,      -- 90 degree DCM CLK output
      CLK180   => open,                  -- 180 degree DCM CLK output
      CLK270   => open,                  -- 270 degree DCM CLK output
      CLK2X    => open,                  -- 2X DCM CLK output
      CLK2X180 => open,                  -- 2X, 180 degree DCM CLK out
      CLKDV    => open,                  -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX    => open,                  -- DCM CLK synthesis out (M/D) 
      CLKFX180 => open,                  -- 180 degree CLK synthesis out
      LOCKED   => dcm1_locked,           -- DCM LOCK status output (means feedback is in phase with main clock)
      PSDONE   => open,                  -- Dynamic phase adjust done output
      STATUS   => open,                  -- 8-bit DCM status bits output
      CLKFB    => dcm1_clk_000,          -- DCM clock feedback
      CLKIN    => clk100mhz,             -- Clock input (from IBUFG, BUFG or DCM)
      PSCLK    => '0',                   -- Dynamic phase adjust clock input
      PSEN     => '0',                   -- Dynamic phase adjust enable input
      PSINCDEC => '0',                   -- Dynamic phase adjust increment/decrement
      RST      => dcm1_reset             -- DCM asynchronous reset input
   );
	dcm1_reset <= reset;
	
	BUFG_DCM1_000 : BUFG
   port map (
      O => dcm1_clk_000,      -- Clock buffer output
      I => dcm1_clk_raw_000   -- Clock buffer input
   );
	
	BUFG_DCM1_090 : BUFG
   port map (
      O => dcm1_clk_090,      -- Clock buffer output
      I => dcm1_clk_raw_090   -- Clock buffer input
   );
	
	dcm1_clk_180 <= not(dcm1_clk_000);
	dcm1_clk_270 <= not(dcm1_clk_090);
	
	ODDR2_DRAM_CLKP : ODDR2
	generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "SYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => dram_clkp,            -- 1-bit output data
      C0 => dcm1_clk_000,        -- 1-bit clock input
      C1 => dcm1_clk_180,        -- 1-bit clock input
      CE => '1',                 -- 1-bit clock enable input
      D0 => '1',                 -- 1-bit data input (associated with C0)
      D1 => '0',                 -- 1-bit data input (associated with C1)
      R => reset,                -- 1-bit reset input
      S => '0'                   -- 1-bit set input
   );	

	ODDR2_DRAM_CLKN : ODDR2
	generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "SYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => dram_clkn,            -- 1-bit output data
      C0 => dcm1_clk_000,        -- 1-bit clock input
      C1 => dcm1_clk_180,        -- 1-bit clock input
      CE => '1',                 -- 1-bit clock enable input
      D0 => '0',                 -- 1-bit data input (associated with C0)
      D1 => '1',                 -- 1-bit data input (associated with C1)
      R => reset,                -- 1-bit reset input
      S => '0'                   -- 1-bit set input
   );	
	
	locked <= dcm1_locked;
	
	clk_000 <= dcm1_clk_000;
	clk_090 <= dcm1_clk_090;
	clk_180 <= dcm1_clk_180;
	clk_270 <= dcm1_clk_270;
	
end impl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

-- just a 2 bit wide ODDR2
entity oddr2_2 is
	port( 
		Q  : out std_logic_vector(1 downto 0);
		C0 : in std_logic;
		C1 : in std_logic;
		CE : in std_logic;
		D0 : in std_logic_vector(1 downto 0);
		D1 : in std_logic_vector(1 downto 0);
		R  : in std_logic;
		S  : in std_logic );
end oddr2_2;

architecture impl of oddr2_2 is
begin
	ODDR2_0 : ODDR2
	generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "ASYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => Q(0),       -- 1-bit output data
      C0 => C0,        -- 1-bit clock input
      C1 => C1,        -- 1-bit clock input
      CE => CE,        -- 1-bit clock enable input
      D0 => D0(0),     -- 1-bit data input (associated with C0)
      D1 => D1(0),     -- 1-bit data input (associated with C1)
      R => R,          -- 1-bit reset input
      S => S           -- 1-bit set input
   );

  ODDR2_1 : ODDR2
  generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "ASYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => Q(1),       -- 1-bit output data
      C0 => C0,        -- 1-bit clock input
      C1 => C1,        -- 1-bit clock input
      CE => CE,        -- 1-bit clock enable input
      D0 => D0(1),     -- 1-bit data input (associated with C0)
      D1 => D1(1),     -- 1-bit data input (associated with C1)
      R => R,          -- 1-bit reset input
      S => S           -- 1-bit set input
   );
end impl;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

-- just a 3 bit wide ODDR2
entity oddr2_3 is
	port( 
		Q  : out std_logic_vector(2 downto 0);
		C0 : in std_logic;
		C1 : in std_logic;
		CE : in std_logic;
		D0 : in std_logic_vector(2 downto 0);
		D1 : in std_logic_vector(2 downto 0);
		R  : in std_logic;
		S  : in std_logic );
end oddr2_3;

architecture impl of oddr2_3 is
begin
	ODDR2_0 : ODDR2
	generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "ASYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => Q(0),       -- 1-bit output data
      C0 => C0,        -- 1-bit clock input
      C1 => C1,        -- 1-bit clock input
      CE => CE,        -- 1-bit clock enable input
      D0 => D0(0),     -- 1-bit data input (associated with C0)
      D1 => D1(0),     -- 1-bit data input (associated with C1)
      R => R,          -- 1-bit reset input
      S => S           -- 1-bit set input
   );

  ODDR2_1 : ODDR2
  generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "ASYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => Q(1),       -- 1-bit output data
      C0 => C0,        -- 1-bit clock input
      C1 => C1,        -- 1-bit clock input
      CE => CE,        -- 1-bit clock enable input
      D0 => D0(1),     -- 1-bit data input (associated with C0)
      D1 => D1(1),     -- 1-bit data input (associated with C1)
      R => R,          -- 1-bit reset input
      S => S           -- 1-bit set input
   );

  ODDR2_2 : ODDR2
  generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "ASYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => Q(2),       -- 1-bit output data
      C0 => C0,        -- 1-bit clock input
      C1 => C1,        -- 1-bit clock input
      CE => CE,        -- 1-bit clock enable input
      D0 => D0(2),     -- 1-bit data input (associated with C0)
      D1 => D1(2),     -- 1-bit data input (associated with C1)
      R => R,          -- 1-bit reset input
      S => S           -- 1-bit set input
   );
end impl;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

-- 2 oddr2_2's
entity oddr2_4 is
   port( Q  : out std_logic_vector(3 downto 0);
         C0 : in std_logic;
         C1 : in std_logic;
         CE : in std_logic;
         D0 : in std_logic_vector(3 downto 0);
         D1 : in std_logic_vector(3 downto 0);
         R  : in std_logic;
         S  : in std_logic );
end oddr2_4;

architecture impl of oddr2_4 is

	component oddr2_2 is
    port( 
		Q  : out std_logic_vector(1 downto 0);
		C0 : in std_logic;
		C1 : in std_logic;
		CE : in std_logic;
		D0 : in std_logic_vector(1 downto 0);
		D1 : in std_logic_vector(1 downto 0);
		R  : in std_logic;
		S  : in std_logic );
	end component;

begin
  ODDR2_0 : oddr2_2
  port map (
      Q => Q(1 downto 0),       -- 1-bit output data
      C0 => C0,                 -- 1-bit clock input
      C1 => C1,                 -- 1-bit clock input
      CE => CE,                 -- 1-bit clock enable input
      D0 => D0(1 downto 0),     -- 1-bit data input (associated with C0)
      D1 => D1(1 downto 0),     -- 1-bit data input (associated with C1)
      R => R,                   -- 1-bit reset input
      S => S                    -- 1-bit set input
   );

  ODDR2_1 : oddr2_2
   port map (
      Q => Q(3 downto 2),       -- 1-bit output data
      C0 => C0,                 -- 1-bit clock input
      C1 => C1,                 -- 1-bit clock input
      CE => CE,                 -- 1-bit clock enable input
      D0 => D0(3 downto 2),     -- 1-bit data input (associated with C0)
      D1 => D1(3 downto 2),     -- 1-bit data input (associated with C1)
      R => R,                   -- 1-bit reset input
      S => S                    -- 1-bit set input
   );
end impl;
	
	
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

-- one ODDR2 and 3 4-bit oddr2_4's
entity oddr2_13 is
   port( Q  : out std_logic_vector(12 downto 0);
         C0 : in std_logic;
         C1 : in std_logic;
         CE : in std_logic;
         D0 : in std_logic_vector(12 downto 0);
         D1 : in std_logic_vector(12 downto 0);
         R  : in std_logic;
         S  : in std_logic );
end oddr2_13;

architecture impl of oddr2_13 is

	component oddr2_4 is
		port( 
			Q  : out std_logic_vector(3 downto 0);
			C0 : in std_logic;
			C1 : in std_logic;
			CE : in std_logic;
			D0 : in std_logic_vector(3 downto 0);
			D1 : in std_logic_vector(3 downto 0);
			R  : in std_logic;
			S  : in std_logic );
  end component;

begin
  
  ODDR2_0 : ODDR2
  generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "ASYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => Q(0),       -- 1-bit output data
      C0 => C0,        -- 1-bit clock input
      C1 => C1,        -- 1-bit clock input
      CE => CE,        -- 1-bit clock enable input
      D0 => D0(0),     -- 1-bit data input (associated with C0)
      D1 => D1(0),     -- 1-bit data input (associated with C1)
      R => R,          -- 1-bit reset input
      S => S           -- 1-bit set input
   );
   
   ODDR2_1 : oddr2_4
   port map(
      Q => Q(4 downto 1),
      C0 => C0,        
      C1 => C1,        
      CE => CE,        
      D0 => D0(4 downto 1),
      D1 => D1(4 downto 1),
      R => R,
      S => S
   );

   ODDR2_2 : oddr2_4
   port map(
      Q => Q(8 downto 5),
      C0 => C0,        
      C1 => C1,        
      CE => CE,        
      D0 => D0(8 downto 5),
      D1 => D1(8 downto 5),
      R => R,
      S => S
   );

   ODDR2_3 : oddr2_4
   port map(
      Q => Q(12 downto 9),
      C0 => C0,        
      C1 => C1,        
      CE => CE,        
      D0 => D0(12 downto 9),
      D1 => D1(12 downto 9),
      R => R,
      S => S
   );
end impl;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

-- 4 4-bit oddr2_4's
entity oddr2_16 is
   port( Q  : out std_logic_vector(15 downto 0);
         C0 : in std_logic;
         C1 : in std_logic;
         CE : in std_logic;
         D0 : in std_logic_vector(15 downto 0);
         D1 : in std_logic_vector(15 downto 0);
         R  : in std_logic;
         S  : in std_logic );
end oddr2_16;

architecture impl of oddr2_16 is

	component oddr2_4 is
		port( 
			Q  : out std_logic_vector(3 downto 0);
			C0 : in std_logic;
			C1 : in std_logic;
			CE : in std_logic;
			D0 : in std_logic_vector(3 downto 0);
			D1 : in std_logic_vector(3 downto 0);
			R  : in std_logic;
			S  : in std_logic );
  end component;

begin
	ODDR2_0 : oddr2_4
	port map (
      Q => Q(3 downto 0),       
      C0 => C0,                
      C1 => C1,                
      CE => CE,                 
      D0 => D0(3 downto 0),    
      D1 => D1(3 downto 0),     
      R => R,                  
      S => S                    
   );

	ODDR2_1 : oddr2_4
	port map (
      Q => Q(7 downto 4),       
      C0 => C0,                 
      C1 => C1,                
      CE => CE,                 
      D0 => D0(7 downto 4),     
      D1 => D1(7 downto 4),    
      R => R,                   
      S => S                    
   );

	ODDR2_2 : oddr2_4
	port map (
      Q => Q(11 downto 8),       
      C0 => C0,                
      C1 => C1,        
      CE => CE,        
      D0 => D0(11 downto 8),    
      D1 => D1(11 downto 8),  
      R => R,         
      S => S           
   );

	ODDR2_3 : oddr2_4
	port map (
      Q => Q(15 downto 12),
      C0 => C0,
      C1 => C1,
      CE => CE,
      D0 => D0(15 downto 12),
      D1 => D1(15 downto 12),
      R => R,
      S => S
   );
end;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity inout_switch_2 is
	port (
		ioport : inout std_logic_vector(1 downto 0);
		   dir : in std_logic;
		data_i : in std_logic_vector(1 downto 0)
	);
end inout_switch_2;

architecture impl of inout_switch_2 is
begin
	ioport <= data_i when dir = '1' else "ZZ";
end impl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity inout_switch_16 is
	port (
		ioport : inout std_logic_vector(15 downto 0);
		   dir : in    std_logic;
		data_o : out   std_logic_vector(15 downto 0);
		data_i : in    std_logic_vector(15 downto 0)
	);
end inout_switch_16;

architecture impl of inout_switch_16 is
begin
	data_o <= ioport when dir = '0' else "ZZZZZZZZZZZZZZZZ";
	ioport <= data_i when dir = '1' else "ZZZZZZZZZZZZZZZZ";
end impl;


