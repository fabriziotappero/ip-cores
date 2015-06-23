----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Léo Germond
-- 
-- Create Date:    16:00:40 11/08/2009 
-- Design Name: 
-- Module Name:    mini_uP_x16 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.ALU_INT.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mini_uP_x16 is
    Port ( Code : in  STD_LOGIC_VECTOR (15 downto 0);
           PC : out  STD_LOGIC_VECTOR (15 downto 0);
           SR : out  STD_LOGIC_VECTOR (15 downto 0);
           MemBuffer : inout  STD_LOGIC_VECTOR (15 downto 0);
           MemAddress : out  STD_LOGIC_VECTOR (15 downto 0);
           MemState : in  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           sleep : in  STD_LOGIC;
           prev_uP : in  STD_LOGIC_VECTOR (7 downto 0);
           next_uP : out  STD_LOGIC_VECTOR (7 downto 0));
end mini_uP_x16;

architecture Behavioral of mini_uP_x16 is
	-- Data bus
	signal dataBus1, dataBus2: std_logic_vector(15 downto 0); -- For ALU data1 and data2
	signal mainDataBus: std_logic_vector(15 downto 0);
	
	-- ALU signals (driven by both the ALU and the identifier)
	signal accumulator: std_logic_vector(15 downto 0); 
	signal ALUoverflow: std_logic;
	signal opCode:  ALU_OPCODE;
	
	-- Control signals (driven by the controler)
	signal register_control:  std_logic_vector(7 downto 0); -- re1 we1 re2 we2 re3 we3 re4 we4
	signal stack_control :  std_logic_vector(1 downto 0); --push pop
	signal PC_control :  std_logic;
	signal inc_PC:  std_logic;
	
	-- Id signal (driven by the identifier)
	signal uP_id: std_logic_vector(7 downto 0);
	
	-- Watchdog (driven by both the watchdog and the controler)
	signal watchdog_left: std_logic_vector(15 downto 0);
	signal watchdog_rst_value: std_logic_vector(15 downto 0);
	signal watchdog_rst: std_logic;
	signal watchdog_control : std_logic_vector(1 downto 0);
	
	
	component decoder_controler_x16
		port (	clk: in std_logic;
					reset: in std_logic;
					code: in std_logic_vector(15 downto 0);
					opCode: out ALU_OPCODE;
					register_control: out std_logic_vector(7 downto 0); -- re1 we1 re2 we2 re3 we3 re4 we4
					stack_control : out std_logic_vector(1 downto 0); -- push pop
					PC_control : out std_logic;
					inc_PC: out std_logic;
					watchdog_reset: out std_logic;
					watchdog_control: out std_logic_vector(1 downto 0) -- re(reset_value) we(left)
					);
	end component;
	
	component binary_counter_x16
		port ( 	clk: in std_logic;
					set: in std_logic;
					set_value: in std_logic_vector(15 downto 0);
					inc: in std_logic;
					count: out std_logic_vector(15 downto 0));
					
	end component;
	
	component watchdog_identifier_x16
		port ( 	clk	: in std_logic;
					reset	: in std_logic;
					prevId: in std_logic_vector(7 downto 0);
					myId	: out std_logic_vector(7 downto 0);
					
					watchdog_left: out std_logic_vector(15 downto 0);
					watchdog_rst_value: in std_logic_vector(15 downto 0);
					watchdog_rst: in std_logic);
	end component;
	
	component bus_access_x16
		port (	en	: in std_logic;
					dataWrite: out std_logic_vector(15 downto 0);
					dataRead : in std_logic_vector(15 downto 0));
	end component;
	
	component bus_register_x16
		port (	clk: in std_logic;
					re: in std_logic; -- read enable
					we: in std_logic; -- write enable
					reset: in std_logic;
					dataport: inout std_logic_vector(15 downto 0));
	end component;
					
	component stack_x16
		generic ( STACK_SIZE : natural);
		port (	clk: in std_logic;
					reset: in std_logic;
					dataPort: inout std_logic_vector(15 downto 0);
					push: in std_logic;
					pop: in std_logic);
	end component;
	
	component ALU
   Port ( data1 : in  STD_LOGIC_VECTOR (15 downto 0);
          data2 : in  STD_LOGIC_VECTOR (15 downto 0);
          dataA : out  STD_LOGIC_VECTOR (15 downto 0);
          op : in  ALU_OPCODE;
			 overflow: out STD_LOGIC );
	end component;
begin
	-- The program counter
	program_counter: binary_counter_x16 
		port map( 	clk => clk,
						set => PC_control,
						inc => inc_PC,
						set_value => mainDataBus,
						count => PC);
	
	-- The watchdog and its access to the main databus
	watchdog_re: bus_access_x16
		port map (	en	=> watchdog_control(1),
						dataRead => mainDataBus,
						dataWrite => watchdog_rst_value);
					
	watchdog_we: bus_access_x16
		port map (	en	=> watchdog_control(0),
						dataRead => watchdog_left,
						dataWrite => mainDataBus);

	watchdog_id: watchdog_identifier_x16
		port map(	clk => clk,
						reset	=> reset,
						prevId => prev_uP,
						myId => uP_id,
						
						watchdog_left => watchdog_left,
						watchdog_rst_value => watchdog_rst_value,
						watchdog_rst => watchdog_rst);
						
	-- The stack
	stack: stack_x16
		generic map( STACK_SIZE => 8)
		port map(	clk => clk,
						reset => reset,
						dataPort => mainDataBus,
						push => stack_control(1), 
						pop => stack_control(0));
	
	-- The 4 Registers
	R1: bus_register_x16
		port map (	clk=>clk ,
						re=>register_control(0),
						we=>register_control(1),
						reset=>reset,
						dataport=> mainDataBus);
					
	R2: bus_register_x16
		port map (	clk=>clk ,
						re=>register_control(2),
						we=>register_control(3),
						reset=>reset,
						dataport=> mainDataBus);
					
	R3: bus_register_x16
		port map (	clk=>clk ,
						re=>register_control(4),
						we=>register_control(5),
						reset=>reset,
						dataport=> mainDataBus);
					
	R4: bus_register_x16
		port map (	clk=>clk ,
						re=>register_control(6),
						we=>register_control(7),
						reset=>reset,
						dataport=> mainDataBus);
					
	-- The ALU							
	arith_logic_unit : ALU
		port map(	data1 => dataBus1,
						data2 => dataBus2,
						dataA => accumulator,
						op => opCode,
						overflow => ALUoverflow);	
	
	-- Controler
	controler : decoder_controler_x16
		port map(	clk=> clk,
						reset=>  reset,
						code=>  code,
						opCode=>  opCode,
						register_control=> register_control, -- re1 we1 re2 we2 re3 we3 re4 we4
						stack_control => stack_control, -- push pop
						PC_control =>  PC_control,
						inc_PC=> inc_PC,
						watchdog_reset=> watchdog_rst,
						watchdog_control=> watchdog_control  -- re(reset_value) we(left)
						);
end Behavioral;

