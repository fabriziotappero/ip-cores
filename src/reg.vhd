library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.cpu_types.ALL;

entity reg is
  port( clk, rst : IN std_logic;        -- high-active asynch rst
--        a_in : in d_bus; -- register a
--        b_in : in d_bus; -- register b
        result_in : d_bus;
        rom_data_in : d_bus;
        carry_in : IN std_logic;
        zero_in : in std_logic;
        a_out : out d_bus; -- register a
        b_out : out d_bus; -- register b
        carry_out : out std_logic;
        zero_out : out STD_LOGIC;
        control : IN opcode );          -- extend the control from the CU
end reg;
                  

architecture behavioral of reg is
  signal rom_data_intern : d_bus;
begin

reg_rom: process(clk)
begin
  if clk'event and clk='1' then
    if rst='1' then
      rom_data_intern <= (others => '0');
    else 
      rom_data_intern <= rom_data_in;
    end if;
  end if;
end process;


reg_p: process(clk)
  BEGIN
    IF clk'EVENT AND clk='1' THEN
      if rst='1' THEN
        a_out <= (OTHERS => '0');
        b_out <= (OTHERS => '0');
        zero_out <= '0';
        carry_out <= '0';
      else                            
        CASE control IS
          WHEN neg_s | and_s | exor_s | or_s | sra_s | ror_s | add_s | addc_s =>
            zero_out <= zero_in;
            a_out <= result_in;
            carry_out <= carry_in;
 
          WHEN lda_const_2 => zero_out <= zero_in;
                              a_out <= rom_data_intern;
                              carry_out <= carry_in;
          when lda_const_1 => zero_out <= zero_in;
          WHEN ldb_const_2 => zero_out <= zero_in;
                              b_out <= rom_data_intern;
                              carry_out <= carry_in;
          WHEN lda_addr_2 =>  zero_out <= zero_in;
                              a_out <= result_in;
                              carry_out <= carry_in;
          WHEN ldb_addr_2 =>  zero_out <= zero_in;
                              b_out <= result_in;
                              carry_out <= carry_in;
          WHEN OTHERS => NULL;
        END CASE;
      END if;
    end if;
end process;
end behavioral;
                                                                                                                                      
                                                                                                                                       
