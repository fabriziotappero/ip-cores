library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.cpu_types.ALL;

entity reg is
  port( clk, rst : IN std_logic;        -- high-active asynch rst
--        a_in : in d_bus; -- register a
--        b_in : in d_bus; -- register b
        result_in : d_bus;
        carry_in : IN std_logic;
        zero_in : in std_logic;
        a_out : out d_bus; -- register a
        b_out : out d_bus; -- register b
        carry_out : out std_logic;
        zero_out : out STD_LOGIC;
        control : IN opcode );          -- extend the control from the CU
end reg;
                  

architecture behavioral of reg is
begin
reg_p: process(clk,rst)
  BEGIN
    if rst='1' THEN
      a_out <= (OTHERS => '0');
      b_out <= (OTHERS => '0');
      zero_out <= '0';
      carry_out <= '0';
    ELSIF clk'EVENT AND clk='1' THEN
      CASE control IS
        WHEN neg_s | and_s | exor_s | or_s | sra_s | ror_s | add_s | addc_s =>
          zero_out <= zero_in;
          a_out <= result_in;
          carry_out <= carry_in;
        WHEN lda_const_2 | lda_addr_3 => zero_out <= zero_in;
                                         a_out <= result_in;
                                         carry_out <= carry_in;
        WHEN ldb_const_2 | ldb_addr_3 => zero_out <= zero_in;
                                         b_out <= result_in;
                                         carry_out <= carry_in;
        WHEN OTHERS => NULL;
      END CASE;
    END if;
end process;
end behavioral;
                                                                                                                                      
                                                                                                                                       
