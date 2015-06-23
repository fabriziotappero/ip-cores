-----------------------------------------------------------------------------------------------
--
--	Keyboard controller entity
--
-- The controller scans the columns, cols, by making a different column logic-0
--	therefor the inputs have to be pull-up high. It processes the input, rows, and
--	the pressed key to a corresponding scancode and giving an interrupt
--
--	Author: Wouter Wiggers
-- Mail: w.a.wiggers@student.utwente.nl
--
------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	 

use work.Constants.all;
 
entity Keyboard_controller is
    
    port (reset, clk_in : in  std_logic;
       clk_out : out std_logic;
       cols : in col;
       rows : out row;
       scan : out scancode;
       interrupt : out std_logic
       );
end Keyboard_controller;

architecture structure of Keyboard_controller is
       
    component Strober
    port (reset, clk : in  std_logic;
       strobe : in std_logic;
       sample : in std_logic;
       env_col : in col;
       env_row : out row;
       sample_col : out col;
       sample_row_number : out row_number
       );
    end component;
    
    component Analyser
     port (reset, clk : in  std_logic;
       analyse : in std_logic;
       store : in std_logic;
		 debounced : out std_logic;
		 keychanged : out std_logic;
       released : out std_logic;
       sample_col: in col;
       sample_row_number : in row_number;
       conv_col : out col_number;
       conv_row : out row_number
       );
    end component;
    
    component Producer
    port (reset, clk: in  std_logic;
       produce : in std_logic;
       released : in std_logic;
       
       conv_col : in col_number;
       conv_row : in row_number;
       
       scanc : out scancode;
       interrupt : out std_logic
       );
    end component;
    
    component FSM
    port (reset, clk : in  std_logic;
       strobe : out std_logic;
       sample : out std_logic;
       analyse : out std_logic;
		 store : out std_logic;
		 produce : out std_logic;
		 release : out std_logic;
		 debounced : in std_logic;
       keychanged : in std_logic; --keychange found
       keyreleased : in std_logic
       );
    end component;
    

    signal stb: std_logic;
    signal str: std_logic;
    signal sam: std_logic;
    signal ana: std_logic;
	 signal pro: std_logic;
	 signal rel: std_logic;
    
    signal deb: std_logic;
    signal keyc: std_logic;
    signal keyr: std_logic;
        
    signal col_sample : col;
    signal row_sample_number : row_number;
    
    signal col_conv : col_number;
    signal row_conv : row_number;

	 signal clk : std_logic;
        
begin
	-- divide by 512
	clockdiv: process 
	variable count : std_logic_vector(8 downto 0);
	begin
	wait until rising_edge(clk_in);
		count := std_logic_vector(to_unsigned( (to_integer(unsigned(count)) + 1),9 ));
		clk <= count(8);
	end process;

	clk_out <= clk;
        
	strb: Strober port map (reset, clk, stb, sam, cols, rows,  col_sample, row_sample_number);

	analys: Analyser port map (reset, clk, ana, str, deb, keyc, keyr, col_sample, row_sample_number, col_conv, row_conv); 

	prod: Producer port map (reset, clk, pro, rel, col_conv, row_conv, scan, interrupt);

	finsm: FSM port map (reset, clk, stb, sam,  ana, str, pro,  rel , deb, keyc, keyr);

end structure;