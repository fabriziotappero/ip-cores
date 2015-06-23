library ieee;
use ieee.std_logic_1164.all;

entity prog_rom is port (
  input:	in std_logic_vector(15 downto 0);
  output:	out std_logic_vector(15 downto 0)
  );
end;

architecture rom_arch of prog_rom is
begin
  process(input)
  begin
    case input is
      when "0000000000000000" =>        -- these are adds because otherwise
        output <= "0010000000000000";   -- it'll never get out of idle
      when "0000000000000001" =>
        output <= "0010000000000000";
      when "0000000000000010" =>
        output <= "0100000000001100";   --lli 6
      when "0000000000000011" =>
        output <= "0100000000000001";   -- lui 0
      when "0000000000000100" =>
        output <= "0100001000000100";   -- lli 2
      when "0000000000000101" =>
        output <= "0100001000000001";   -- lui 0
      when "0000000000000110" =>        
        output <= "0010010000001000";   -- add r2 <- r0 + r1
        --when "0000000000001000" =>
        --output <= "0011000001010011";
        --when "0000000000001001" =>
        --output <= "0011000001010100";
        --when "0000000000001010" =>
        --output <= "0011000001010101";
        --when "0000000000001011" =>
        --output <= "1000000001000000";
        --when "0000000000001100" =>
        --output <= "1001000001000000";
        --when "0000000000001101" =>
        --output <= "1010000001000000";
        --when "0000000000001110" =>
        --output <= "1010000001000001";
        --when "0000000000001111" =>
        --output <= "0101000000000000";
        --when "0000000000010000" =>
        --output <= "0101000000000001";
        --when "0000000000010001" =>
        --output <= "0101000000000010";
      when others =>
        output <= "1111000000000000";
    end case;
  end process;
end;
