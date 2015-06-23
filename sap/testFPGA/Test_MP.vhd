library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Test_MP is
	port (
			CLEAR 			: in  std_logic;
			CLOCK 			: in  std_logic;
			HALT 				: out std_logic;
			SCLOCK			: out std_ulogic;
			MP_Binary_Out 	: out std_logic_vector(7 downto 0)			
	);
end Test_MP;

architecture Behavioral of Test_MP is
component MP
   PORT( 
      clk : IN     std_logic;								--! Active high asynchronous clear
      clr : IN     std_logic;								--! Rising edge clock
      hlt : OUT    std_logic;								--! Halt signal to stop processing data
      q3  : OUT    std_logic_vector (7 DOWNTO 0)	--! 8-bit output
   );
end component;

component ClockDivider
    Port ( 
		  CLK_Divider_CLR 	 : in  std_logic;
        CLK_Divider_CLK	 	 : in  std_logic;
        CLK_Divider_Out		 : out std_logic
        );
end component;

signal slowclock : std_ulogic;

begin
SCLK: ClockDivider
	port map (
			CLK_Divider_CLR => CLEAR,
			CLK_Divider_CLK => CLOCK,
			CLK_Divider_Out => slowclock
	);

SCLOCk <= slowclock;
	
SAP: MP
	port map (
			clk => slowclock,
			clr => CLEAR,
			hlt => HALT,
			q3 => MP_Binary_Out
	);

end Behavioral;

