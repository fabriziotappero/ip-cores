library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.cpu_types.ALL;

entity alu is
  port( a : in d_bus; -- register a
        b : in d_bus; -- register b
        rom_data, ram_data : IN d_bus;
        control : IN opcode;
        carry, zero : IN std_logic;
        result : OUT d_bus;
        carry_out, zero_out,flagz,flagc : OUT STD_LOGIC );
end alu;
                  

architecture behavioral of alu is
begin
alu_p:	process(control,a,b,rom_data,ram_data,carry,zero)
  VARIABLE result_int, zero_temp : d_bus;
  VARIABLE add_result_int : STD_LOGIC_VECTOR(d_bus_width DOWNTO 0);  -- 9 bit
-- vector for add operation
  VARIABLE a_add_int, b_add_int : STD_LOGIC_VECTOR(d_bus_width DOWNTO 0);
begin
  a_add_int := '0' & a;
  b_add_int := '0' & b;
  flagz <= '0';
  flagc <= '0';
  
  case control is
    when neg_s => result_int := NOT a;
                  carry_out <= carry;
                  IF result_int=zero_bus then
                    zero_out <= '1';
                  ELSE
                    zero_out <= '0';
                  END IF;
                  flagz <= '1';
    WHEN and_s => result_int := a AND b;
                  carry_out <= carry;
                  IF result_int=ZERO_BUS THEN
                    zero_out <= '1';
                  ELSE
                    zero_out <= '0';
                  END IF;
                  flagz <= '1';
    WHEN exor_s => result_int := a xor b;
                   carry_out <= carry;
                   IF result_int=ZERO_BUS THEN
                     zero_out <= '1';
                   ELSE
                     zero_out <= '0';
                   END IF;
                   flagz <= '1';
    WHEN or_s => result_int := a or b;
                  carry_out <= carry;
                  IF result_int=ZERO_BUS THEN
                    zero_out <= '1';
                  ELSE
                    zero_out <= '0';
                  END IF;
                  flagz <= '1';
    WHEN sra_s => result_int := a(a'high-1 DOWNTO 0) & '0';
                  carry_out <= a(a'high);
                  IF result_int=ZERO_BUS THEN
                    zero_out <= '1';
                  ELSE
                    zero_out <= '0';
                  END IF;
                  flagz <= '1';
                  flagc <= '1';
    WHEN ror_s => result_int := a(a'high-1 DOWNTO 0) & carry;
                  carry_out <= a(a'high);
                  IF result_int=ZERO_BUS THEN
                    zero_out <= '1';
                  ELSE
                    zero_out <= '0';
                  END IF;
                  flagz <= '1';
                  flagc <= '1';
    WHEN add_s => add_result_int := std_logic_vector(unsigned(unsigned(a_add_int) + unsigned(b_add_int)));
                  carry_out <= add_result_int(add_result_int'high);
                  result_int := add_result_int(add_result_int'high-1 DOWNTO 0);
                  IF result_int=ZERO_BUS THEN
                    zero_out <= '1';
                  ELSE
                    zero_out <= '0';
                  END IF;
                  flagc <= '1';
                  flagz <= '1';
    WHEN addc_s => addc(a,b,carry,carry_out,result_int);
                   IF result_int=ZERO_BUS THEN
                     zero_out <= '1';
                   ELSE
                     zero_out <= '0';
                   END IF;     
                   flagz <= '1';
                   flagc <= '1';             
    WHEN nop | jnt | jmp_1 | jmp_2 | jmpc_1 | jmpc_2 | jmpz_1 | jmpz_2 | ldb_const_1 | sta_1 | sta_2 =>
      result_int := a;
      carry_out <= carry;
      zero_out <= zero;
    when lda_const_1 => result_int := a;
                        carry_out <= carry;
                        zero_temp := rom_data;
                        if zero_temp=ZERO_BUS then
                          zero_out <= '1';
                        else
                          zero_out <= '0';
                        end if; 
    WHEN lda_const_2 => result_int := rom_data;
                        carry_out <= carry;
                        zero_out <= zero;
                        flagz <= '1';
    when ldb_const_2 => result_int := rom_data;
                        carry_out <= carry;
                        zero_out <= zero;
    WHEN lda_addr_1 =>  result_int := rom_data;
                        carry_out <= carry;
                        zero_out <= zero;
    when ldb_addr_1 =>  result_int := rom_data;
                        carry_out <= carry;
                        zero_out <= zero;
    WHEN lda_addr_2 =>  result_int := ram_data;
                        carry_out <= carry;
                        IF result_int=ZERO_BUS THEN
                          zero_out <= '1';
                        ELSE
                          zero_out <= '0';
                        END IF;      
                        flagz <= '1';                              
    when ldb_addr_2 =>  result_int := ram_data;
                        carry_out <= carry;
                        zero_out <= zero;
    when others => 	result_int := a;
                        carry_out <= carry;
                        zero_out <= zero;
  end case;            
  result <= result_int;
end process;
end behavioral;
                                                                                                                                      
                                                                                                                                       
