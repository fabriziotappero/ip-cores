
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
			  
			  --baud_div1 : in STD_LOGIC_VECTOR(3 downto 0);
			  --period1 : in STD_LOGIC_VECTOR(3 downto 0)
			  
           --RX2 : out  STD_LOGIC;
           --TX2 : in  STD_LOGIC;
           --optic_out2 : out  STD_LOGIC;
           --optic_in2 : in  STD_LOGIC;
			  
			  --led1 : out  STD_LOGIC;
			  --led2 : out  STD_LOGIC;
			  --led3 : out  STD_LOGIC;
			  --led4 : out  STD_LOGIC
			  
			  );
end main;

architecture Behavioral of main is




COMPONENT TX_to_spdif_full
	PORT(
		iCLK : IN std_logic;          
		TX : IN std_logic;
		OPTIC_OUT : OUT std_logic;
		period01 : in STD_LOGIC_VECTOR(6 downto 0);
		periodA : in STD_LOGIC_VECTOR(6 downto 0);
		period10 : in STD_LOGIC_VECTOR(6 downto 0);
		period : in STD_LOGIC_VECTOR(6 downto 0);
		baud_div : in STD_LOGIC_VECTOR(6 downto 0)
	
		
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

--signal nled1 : STD_LOGIC_VECTOR(3 downto 0);

--constant period : STD_LOGIC_VECTOR(6 downto 0) := ('0','1','0','1','0','0','0'); --40
--constant baud_div : STD_LOGIC_VECTOR(6 downto 0) := ('0','0','0','1','0','0','0'); --1


signal period01 :STD_LOGIC_VECTOR(6 downto 0);
signal periodA :STD_LOGIC_VECTOR(6 downto 0);
signal period10 :STD_LOGIC_VECTOR(6 downto 0);

signal period : STD_LOGIC_VECTOR(6 downto 0);--normally 40
signal baud_div : STD_LOGIC_VECTOR(6 downto 0);--normally 1




begin
--led1<=not nled1(3);
--led2<=not nled1(2);
--led3<=not nled1(1);
--led4<=not nled1(0);

--period<=((6 downto 4=>'0')&period1);
--baud_div<=((6 downto 4=>'0')&baud_div1);
process


begin
	if(setting=('0','0'))then
	period<=('0','1','0','1','0','0','0');
	--period<=to_stdlogicvector("40");
	baud_div<=('0','0','0','0','0','0','1');
	
	elsif (setting=('0','0'))then
	period<=('0','1','0','0','0','0','1');
	baud_div<=('0','0','0','0','0','1','0');
	
	elsif (setting=('0','0'))then
	period<=('0','1','0','0','1','0','0');
	baud_div<=('0','0','1','0','0','0','0');

	else
	period<=('0','1','0','0','0','1','0');
	baud_div<=('0','0','0','1','1','1','0');

	end if;
	
	

end process;




 
q_period_inst:q_period
 Port map (period=>period,
				period01=>period01,
				periodA=>periodA,
				period10=>period10
				);

TX_to_spdif_full_inst:TX_to_spdif_full
    Port map ( iCLK=> iCLK,
              TX => TX,
				  optic_out => optic_out,
				  period01=>period01,
				  periodA=>periodA,
				  period10=>period10,
				  period=>period,
				  baud_div=>baud_div
				  );
spdif_to_RX_inst:spdif_to_RX
    Port map ( iCLK=>iCLK,
					optic_in => optic_in,
					RX => RX,
					periodA=>periodA,
					period10=>period10
					
					
				  );



end Behavioral;

