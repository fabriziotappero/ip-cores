library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_types.all;

entity ram_control is
  port( clk,rst : in std_logic;
        input_a : IN d_bus;
        input_rom : IN d_bus;
        input_ram : in d_bus;
        control : in opcode;
        ram_data_reg : out d_bus;
        addr : OUT d_bus;
        data : OUT d_bus;
        ce_nwr, ce_nrd : OUT STD_LOGIC );
end ram_control;


architecture behavioral of ram_control is
  signal pr_state, nxt_state : opcode;
--  signal ram_addr_reg : d_bus;
begin

--  addr <= ram_addr_reg;
  addr <= input_rom;
  data <= input_a;
  
wr_p: process(clk,control)
begin
  if control=sta_1 then
    ce_nwr <= clk;
  else
    ce_nwr <= '1';
  end if;
end process;


--rd_p: process(clk,control)
--begin
--  if control=lda_addr_1 or control=ldb_addr_1 then
--    ce_nrd <= clk;
--  else
--    ce_nrd <= '1';
--  end if;
--end process;


rd_p: process(clk)
BEGIN
  IF clk'EVENT AND clk='1' THEN
    IF control=lda_addr_1 OR control=ldb_addr_1 then
      ce_nrd <= '0';
    ELSE
      ce_nrd <= '1';
    END IF;
  END IF;
END process;

ram_data: process(clk)
begin
  if clk'event and clk='1' then
    if control=lda_addr_2 or control=ldb_addr_2 then
      ram_data_reg <= input_ram;
    end if;
  end if;
end process;

--ram_addr: process(clk)
--begin
--  if clk'event and clk='0' then
--    if rst='1' then
--      ram_addr_reg <= zero_bus;
--    else
--      if control=sta_1 then
--        ram_addr_reg <= input_rom;
--      end if;
--    end if;
--  end if;
--end process;
END behavioral;
