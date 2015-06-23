library ieee, std, unisim;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use unisim.vcomponents.all;


entity fifo_sim32 is
generic
(
	filename	: string := "fifo32.log";
	log_time : integer := 1
);
port
(
	rst	: in std_logic;
	clk	: in std_logic;
	din	: in std_logic_vector(31 downto 0);
	we		: in std_logic;
	full	: out std_logic
);
end fifo_sim32;


architecture default of fifo_sim32 is

	file log_file	: text open write_mode is filename;

   function hstr(slv: std_logic_vector) return string is
       variable hexlen: integer;
       variable longslv : std_logic_vector(127 downto 0) := (others => '0');
       variable hex : string(1 to 32);
       variable fourbit : std_logic_vector(3 downto 0);
     begin
       hexlen := (slv'left+1)/4;
       if (slv'left+1) mod 4 /= 0 then
         hexlen := hexlen + 1;
       end if;
       longslv(slv'left downto 0) := slv;
       for i in (hexlen -1) downto 0 loop
         fourbit := longslv(((i*4)+3) downto (i*4));
         case fourbit is
           when "0000" => hex(hexlen -I) := '0';
           when "0001" => hex(hexlen -I) := '1';
           when "0010" => hex(hexlen -I) := '2';
           when "0011" => hex(hexlen -I) := '3';
           when "0100" => hex(hexlen -I) := '4';
           when "0101" => hex(hexlen -I) := '5';
           when "0110" => hex(hexlen -I) := '6';
           when "0111" => hex(hexlen -I) := '7';
           when "1000" => hex(hexlen -I) := '8';
           when "1001" => hex(hexlen -I) := '9';
           when "1010" => hex(hexlen -I) := 'a';
           when "1011" => hex(hexlen -I) := 'b';
           when "1100" => hex(hexlen -I) := 'c';
           when "1101" => hex(hexlen -I) := 'd';
           when "1110" => hex(hexlen -I) := 'e';
           when "1111" => hex(hexlen -I) := 'f';
           when "ZZZZ" => hex(hexlen -I) := 'z';
           when "UUUU" => hex(hexlen -I) := 'u';
           when "XXXX" => hex(hexlen -I) := 'x';
           when others => hex(hexlen -I) := '?';
         end case;
       end loop;
       return hex(1 to hexlen);
     end hstr;


begin

	full <= '0';

	process(clk)
		variable TheLine : line;
	begin
		if rising_edge(clk) then
			if we = '1' then

				if log_time = 1 then
					write(TheLine, now);
					while (TheLine'length < 13) loop
						write(TheLine, string'(" "));
					end loop;
				end if;

				write(TheLine, string'("0x" & hstr(din)));
				writeline(log_file, TheLine);

			end if;
		end if;
	end process;

end default;
