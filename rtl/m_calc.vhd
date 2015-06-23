----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:33:10 10/29/2009 
-- Design Name: 
-- Module Name:    m_calc - Behavioral 
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity m_calc is

  port(
    clk        : in  std_logic;
    reset      : in  std_logic;
    ab         : in  std_logic_vector (15 downto 0);
    t          : in  std_logic_vector (15 downto 0);
    n_cons     : in  std_logic_vector (15 downto 0);
    m          : out std_logic_vector (15 downto 0);
    mult_valid : in  std_logic;         -- indica que los datos de entrada son validos
    m_valid    : out std_logic);        -- la m calculada es valida
end m_calc;

architecture Behavioral of m_calc is



  signal sum_res, next_sum_res      : std_logic_vector(15 downto 0);
  signal mult_valid_1, mult_valid_2 : std_logic;  --delay del valido a lo largo del calculo
  signal mult                       : std_logic_vector(31 downto 0);
begin


  mult <= sum_res * n_cons;

  process(clk, reset)
  begin

    if(clk = '1' and clk'event) then

      if(reset = '1') then
        sum_res      <= (others => '0');
        mult_valid_1 <= '0';
        mult_valid_2 <= '0';
      else
        sum_res      <= next_sum_res;
        mult_valid_1 <= mult_valid;
        mult_valid_2 <= mult_valid_1;

      end if;

    end if;

  end process;

  process(ab, t, mult_valid_2)
  begin
    m            <= mult(15 downto 0);
    next_sum_res <= ab+t;
    m_valid      <= mult_valid_2;
  end process;

end Behavioral;

