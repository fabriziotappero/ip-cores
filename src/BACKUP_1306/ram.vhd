LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.cpu_types.ALL;

ENTITY ram IS
  GENERIC ( taa : time := 55 ns;        -- address to data valid
            tha : time := 2 NS );       -- address hold from write END
  port( addr : IN a_bus;
        data_in : in d_bus;
        data_out : OUT d_bus;
        ce_nwr : in STD_LOGIC ;
        ce_nrd : in STD_LOGIC );
END ram;

ARCHITECTURE behavioral OF ram IS
  SIGNAL memory : ram_memory;
BEGIN
ram_rd: process(addr, ce_nrd, memory)
  begin
    data_out <= (OTHERS => 'X');
    
    if ce_nrd='0' THEN
      data_out <= memory(to_integer(unsigned(addr))) AFTER taa;
    END if;
  END process;

ram_wr: process(addr, data_in, ce_nwr)    
  begin
    IF ce_nwr='0' THEN
      memory(to_integer(unsigned(addr))) <= data_in;
    END if;
  END process;

warn: process(addr, ce_nwr, ce_nrd)
  begin
--    if addr'EVENT and ce_nwr'LAST_EVENT < 2 NS THEN ERROR <= '1';
    if addr'EVENT THEN
      ASSERT ce_nwr'last_event >= 2 NS REPORT "2 ns RAM violation" SEVERITY warning;
    END if;

    if ce_nwr='0' then
      ASSERT ce_nrd='1' REPORT "Dual-port RAM /CE violation" SEVERITY warning;
    end if;
  END process;  
END behavioral;
