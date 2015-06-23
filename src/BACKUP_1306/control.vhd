library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_types.all;

entity control is
  port( clk, rst : in std_logic;
        carry, zero : IN std_logic;
        input : IN d_bus;
        output : OUT opcode );
end control;


architecture behavioral of control is
  signal pr_state, nxt_state : opcode;
begin

  output <= pr_state;
--  output <= nxt_state;
  
main_s_p: process(clk)
  begin
    if clk'event and clk='1' then
      IF rst='1' THEN
        pr_state <= nop;
      else
        pr_state <= nxt_state;
      end if;
    END if;
  end process;


main_c_p: process(pr_state,input, carry, zero)
begin

  case pr_state is
    WHEN nop | neg_s | and_s | exor_s | or_s | sra_s | ror_s | add_s | addc_s | jmp_2 | jmpc_2 | jmpz_2 | lda_const_2 | ldb_const_2 | lda_addr_3 | ldb_addr_3 | sta_2 => 
      CASE input(input'HIGH DOWNTO 5) IS
        WHEN "000" => nxt_state <= nop;
        WHEN "001" =>
          case input(3 DOWNTO 0) is
            WHEN "0100" => nxt_state <= neg_s;
            WHEN "0101" => nxt_state <= and_s;
            WHEN "0110" => nxt_state <= exor_s;
            WHEN "0111" => nxt_state <= or_s;
            WHEN "1000" => nxt_state <= sra_s;
            WHEN "1001" => nxt_state <= ror_s;
            WHEN OTHERS => nxt_state <= nop;
          END case;
        WHEN "010" =>
          case input(3 DOWNTO 0) is
            WHEN "0000" => nxt_state <= add_s;  
            WHEN "0001" => nxt_state <= addc_s;
            WHEN OTHERS => nxt_state <= nop;
          END case;
        WHEN "011" =>
          case input(3 DOWNTO 0) is
            WHEN "0011" => nxt_state <= jmp_1;
            WHEN "0010" => IF carry='1' THEN
                             nxt_state <= jmpc_1;
                           ELSE
                             nxt_state <= nop;
                           END IF;
            WHEN "0001" => IF zero='1' THEN
                             nxt_state <= jmpz_1;
                           ELSE
                             nxt_state <= nop;
                           END IF;
            WHEN OTHERS => nxt_state <= nop;
          END case;
        WHEN "100" =>
          CASE input(3 DOWNTO 0) IS
            WHEN "1101" => nxt_state <= lda_const_1;
            WHEN "1111" => nxt_state <= ldb_const_1;
            WHEN OTHERS => nxt_state <= nop;
          END case;
        WHEN "101" =>
          case input(3 DOWNTO 0) is
            WHEN "1101" => nxt_state <= lda_addr_1;  
            WHEN "1111" => nxt_state <= ldb_addr_1;  
            WHEN "1100" => nxt_state <= sta_1;                             
            WHEN OTHERS => nxt_state <= nop;
          END CASE;
        WHEN OTHERS => nxt_state <= nop;
      END case;
    WHEN jmp_1 => nxt_state <= jmp_2;
    WHEN jmpc_1 => nxt_state <= jmpc_2;
    WHEN jmpz_1 => nxt_state <= jmpz_2;                   
    WHEN lda_const_1 => nxt_state <= lda_const_2;
    WHEN ldb_const_1 => nxt_state <= ldb_const_2;
    WHEN lda_addr_1 => nxt_state <= lda_addr_2;                        
    WHEN lda_addr_2 => nxt_state <= lda_addr_3;
    WHEN ldb_addr_1 => nxt_state <= ldb_addr_2;                       
    WHEN ldb_addr_2 => nxt_state <= ldb_addr_3;
    WHEN sta_1 => nxt_state <= sta_2;                  
    WHEN OTHERS => nxt_state <= nop;                       
  END case;
END process;
END behavioral;
