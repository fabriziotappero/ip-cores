

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

package DW02_components is

  component DW02_mult_2_stage
  generic( A_width: POSITIVE;		-- multiplier wordlength
           B_width: POSITIVE);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        CLK : in std_logic;           -- clock for the stage registers.
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;
  

end DW02_components;

-- pragma translate_off

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
library grlib;
use grlib.stdlib.all;

entity DW02_mult_2_stage is
  generic( A_width: POSITIVE;		
           B_width: POSITIVE);		
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		
        CLK : in std_logic;          
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
end;


architecture behav of DW02_mult_2_stage is

  signal P_i : std_logic_vector(A_width+B_width-1 downto 0);
  
begin

  comb : process(A, B, TC)
  begin 
    if notx(A) and notx(B) then
      if TC = '1' then
        P_i <= signed(A) * signed(B);
      else
        P_i <= unsigned(A) * unsigned(B);
      end if;
    else
      P_i <= (others => 'X');
    end if;
  end process;
  
  reg : process(CLK)
  begin
    if rising_edge(CLK) then
      PRODUCT <= P_i;
    end if;
  end process;
  
end;

-- pragma translate_on

