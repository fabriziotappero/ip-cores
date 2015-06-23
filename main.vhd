----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:13:04 11/11/2013 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( iCLK : in  STD_LOGIC;
           RX : out  STD_LOGIC;
           TX : in  STD_LOGIC;
           optic_out : out  STD_LOGIC;
           optic_in : in  STD_LOGIC;
			  
           RX2 : out  STD_LOGIC;
           TX2 : in  STD_LOGIC;
           optic_out2 : out  STD_LOGIC;
           optic_in2 : in  STD_LOGIC;
			  
			  led1 : out  STD_LOGIC;
			  led2 : out  STD_LOGIC;
			  led3 : out  STD_LOGIC;
			  led4 : out  STD_LOGIC
			  
			  );
end main;

architecture Behavioral of main is


COMPONENT TX_to_spdif_full
	PORT(
		iCLK : IN std_logic;          
		TX : IN std_logic;
		OPTIC_OUT : OUT std_logic
		
		);
	END COMPONENT;
COMPONENT spdif_to_RX
	PORT(
		iCLK : IN std_logic;          
		OPTIC_IN : IN std_logic;
		RX : OUT std_logic;
		learn_out : OUT std_logic
		);
	END COMPONENT;

--signal nled1 : STD_LOGIC_VECTOR(3 downto 0);


begin
--led1<=not nled1(3);
--led2<=not nled1(2);
--led3<=not nled1(1);
--led4<=not nled1(0);


TX_to_spdif_full_inst:TX_to_spdif_full
    Port map ( iCLK=> iCLK,
              TX => TX,
				  optic_out => optic_out
				  );
spdif_to_RX_inst:spdif_to_RX
    Port map ( iCLK=>iCLK,
              optic_in => optic_in,
				  RX => RX,
				  learn_out=>open
				  );

TX_to_spdif_full_inst2:TX_to_spdif_full
    Port map ( iCLK=> iCLK,
              TX => TX2,
				  optic_out => optic_out2
				  );
spdif_to_RX_inst2:spdif_to_RX
    Port map ( iCLK=>iCLK,
              optic_in => optic_in2,
				  RX => RX2,
				  learn_out=>open
				  );



end Behavioral;

