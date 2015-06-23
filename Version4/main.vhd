
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.std_logic_unsigned.all;
--use IEEE.NUMERIC_STD.ALL;


entity main is
    Port ( iCLK : in  STD_LOGIC;
           RX : out  STD_LOGIC;
           TX : in  STD_LOGIC;
           optic_out : out  STD_LOGIC;
           optic_in : in  STD_LOGIC;

			  setting : in  STD_LOGIC_VECTOR(1 downto 0)			  
		  
			  
			  );
end main;

architecture Behavioral of main is




COMPONENT TX_to_spdif
	PORT(
		iCLK : IN std_logic;          
		TX : IN std_logic;
		OPTIC_OUT : OUT std_logic;
		period01 : in STD_LOGIC_VECTOR(6 downto 0);
		periodA : in STD_LOGIC_VECTOR(6 downto 0);
		period10 : in STD_LOGIC_VECTOR(6 downto 0);
		period : in STD_LOGIC_VECTOR(6 downto 0);
		baud_div : in STD_LOGIC_VECTOR(6 downto 0);
		direct_mode : in STD_LOGIC
	
		
		);
	END COMPONENT;
COMPONENT spdif_to_RX
	PORT(
		iCLK : IN std_logic;          
		OPTIC_IN : IN std_logic;
		RX : OUT std_logic;
		
		periodA : in STD_LOGIC_VECTOR(6 downto 0);
		period10 : in STD_LOGIC_VECTOR(6 downto 0)
		
	  	
		
		);
	END COMPONENT;


COMPONENT q_period is
    PORT ( period : in  STD_LOGIC_VECTOR (6 downto 0);
           period01 : out  STD_LOGIC_VECTOR (6 downto 0);
           periodA : out  STD_LOGIC_VECTOR (6 downto 0);
           period10 : out  STD_LOGIC_VECTOR (6 downto 0)
			  );
END COMPONENT;


signal period01 :STD_LOGIC_VECTOR(6 downto 0);
signal periodA :STD_LOGIC_VECTOR(6 downto 0);
signal period10 :STD_LOGIC_VECTOR(6 downto 0);

signal period : STD_LOGIC_VECTOR(6 downto 0);
signal baud_div : STD_LOGIC_VECTOR(6 downto 0);
signal direct_mode : STD_LOGIC;




begin

process(setting)

begin

	if(setting(1 downto 0)="00")then--2.0Mb/s @ 50Mhz
	--period<=('0','0','1','1','0','0','1');--25
	period<=('0','0','1','0','1','0','0');--20
	--period<=('0','1','1','0','0','1','0');--50
	baud_div<=(0=>'1',others=>'0');--1
	direct_mode<='0';
	elsif(setting(1 downto 0)="01")then--1.25Mb/s
	period<=('0','0','1','0','1','0','0');--20
	baud_div<=(1=>'1',others=>'0');--2
	direct_mode<='0';
	else--115207 b/s
	period<=('0','0','1','0','1','0','0');--20
	baud_div<=(0=>'1',others=>'0');--1
	direct_mode<='1';
	--period<=('0','1','1','1','1','1','0');--62
	--baud_div<=('0','0','0','0','1','1','1');--7
	end if;
	
end process;




 
q_period_inst:q_period
 Port map (period=>period,
				period01=>period01,
				periodA=>periodA,
				period10=>period10
				);

TX_to_spdif_inst:TX_to_spdif
    Port map ( iCLK=> iCLK,
              TX => TX,
				  optic_out => optic_out,
				  period01=>period01,
				  periodA=>periodA,
				  period10=>period10,
				  period=>period,
				  baud_div=>baud_div,
				  direct_mode=>direct_mode
				  );
spdif_to_RX_inst:spdif_to_RX
    Port map ( iCLK=>iCLK,
					optic_in => optic_in,
					RX => RX,
					periodA=>periodA,
					period10=>period10
					
					
				  );



end Behavioral;

