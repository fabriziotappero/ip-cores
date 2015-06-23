




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tinycpu.all;




entity alu is
        
  port(
    Op: in std_logic_vector(4 downto 0);
    DataIn1: in std_logic_vector(7 downto 0);
    DataIn2: in std_logic_vector(7 downto 0);
    DataOut: out std_logic_vector(7 downto 0);
    TR: out std_logic
   );
end alu;

architecture Behavioral of alu is
begin
  process(DataIn1, DataIn2, Op)
  begin
    TR <= '0';
    case Op is 
--bitwise operations
      when "00000" => --and
        DataOut <= DataIn1 and DataIn2;
      when "00001" => --or
        DataOut <= DataIn1 or DataIn2;
      when "00010" => --xor
        DataOut <= DataIn1 xor DataIn2;
      when "00011" => --not
        DataOut <= not DataIn2; --ignore DataIn1 here so that mapping these operations is as simple as possible
      when "00100" => --left shift (logical)
        DataOut <= std_logic_vector(shift_left(unsigned(DataIn1),to_integer(unsigned(DataIn2(2 downto 0)))));
      when "00101" => --right shift(logical)
        DataOut <= std_logic_vector(shift_right(unsigned(DataIn1),to_integer(unsigned(DataIn2(2 downto 0))))); 
      when "00110" => --left rotate
        DataOut <= std_logic_vector(rotate_left(unsigned(DataIn1),to_integer(unsigned(DataIn2(2 downto 0))))); 
      when "00111" => --right rotate
        DataOut <= std_logic_vector(rotate_right(unsigned(DataIn1),to_integer(unsigned(DataIn2(2 downto 0))))); 
--comparisons
      when "01000" => --greater than
        DataOut <= "00000000";
        if(to_integer(unsigned(DataIn1)) > to_integer(unsigned(DataIn2))) then
          TR <= '1';
        else
          TR <= '0';
        end if;
      when "01001" => --greater than or equal
        DataOut <= "00000000";
        if(to_integer(unsigned(DataIn1)) >= to_integer(unsigned(DataIn2))) then
          TR <= '1';
        else
          TR <= '0';
        end if;
      when "01010" => --less than
        DataOut <= "00000000";
        if(to_integer(unsigned(DataIn1)) < to_integer(unsigned(DataIn2))) then
          TR <= '1';
        else
          TR <= '0';
        end if;
      when "01011" => --less than or equal
        DataOut <= "00000000";
        if(to_integer(unsigned(DataIn1)) <= to_integer(unsigned(DataIn2))) then
          TR <= '1';
        else
          TR <= '0';
        end if;
      when "01100" => --equals to
        DataOut <= "00000000";
        if(to_integer(unsigned(DataIn1)) = to_integer(unsigned(DataIn2))) then
          TR <= '1';
        else
          TR <= '0';
        end if;
      when "01101" => --not equal
        DataOut <= "00000000";
        if(to_integer(unsigned(DataIn1)) /= to_integer(unsigned(DataIn2))) then
          TR <= '1';
        else
          TR <= '0';
        end if;
      when "01110" => --equal to 0
        DataOut <= "00000000";
        if(to_integer(unsigned(DataIn1)) = 0) then
          TR <= '1';
        else
          TR <= '0';
        end if;
      when "01111" => --not equal to 0
        DataOut <= "00000000";
        if(to_integer(unsigned(DataIn1)) /= 0) then
          TR <= '1';
        else
          TR <= '0';
        end if;
--other operations
      when "10000" => --set TR
        DataOut <= "00000000";
        TR <= '1';
      when "10001" => --reset TR
        DataOut <= "00000000";
        TR <= '0';
      when "10010" => --increment
        DataOut <= std_logic_vector(unsigned(DataIn1) + 1); 
      when "10011" => --decrement
        DataOut <= std_logic_vector(unsigned(DataIn1) - 1); 
      when "10100" => --add
        DataOut <= std_logic_vector(unsigned(DataIn1) + unsigned(DataIn2));
      when "10101" => --subtract
        DataOut <= std_logic_vector(unsigned(DataIn1) - unsigned(DataIn2)); 

      when others => 
        DataOut <= "00000000";
        TR <= '1';
    end case;
  end process;
end Behavioral;