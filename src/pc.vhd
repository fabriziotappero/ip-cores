library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.cpu_types.ALL;

entity pc is
  port( clk, rst : IN std_logic;        -- high-active asynch rst
        addr_in : in d_bus; -- new address
        control : IN opcode;          -- extend the control from the CU
        pc : OUT d_bus );
end pc;
                  

architecture behavioral of pc is
begin
pc_p: process(clk)
  VARIABLE pc_int : d_bus;
BEGIN	
  IF clk'EVENT AND clk='1' THEN
    if rst='1' then
      pc_int := zero_bus;
    else
      CASE control IS
--        WHEN  nop | neg_s | and_s | exor_s | or_s | sra_s | ror_s | add_s | addc_s | sta_1 => pc_int := pc_int + 1;
        WHEN jmp_2 | jmpc_2 | jmpz_2 => pc_int := addr_in;
--        WHEN lda_addr_2 | ldb_addr_2 => null;                                        
        WHEN jnt => pc_int := std_logic_vector(unsigned(unsigned(pc_int) + to_unsigned(2,d_bus_width))); -- jump not taken
        WHEN OTHERS => pc_int := std_logic_vector(unsigned(unsigned(pc_int) + to_unsigned(1,d_bus_width))); 
      END CASE;
    END IF;
  end if;
  pc <= pc_int;
END process;    
end behavioral;
                                                                                                                                      
                                                                                                                                       
