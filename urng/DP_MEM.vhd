library IEEE;
  use IEEE.Std_Logic_1164.all;
  use IEEE.Std_Logic_Arith.all;
  use IEEE.Std_Logic_Unsigned.all;

entity dp_mem is
  generic (
	Addr_Wdth : Natural := 9;
	Bit_Wdth  : Natural := 32
  );
           -- DO NOT USE more than 14 address bits
           -- Using more than 11 address bits may be inefficient for some data widths.
  port (Clock         : in  Std_Logic;
        Write_Enable  : in  Std_Logic;
        Write_Address : in  Std_Logic_Vector(Addr_Wdth-1 downto 0);
        Read_Enable   : in  Std_Logic;
        Read_Address  : in  Std_Logic_Vector(Addr_Wdth-1 downto 0);
        Data_In       : in  Std_Logic_Vector(Bit_Wdth-1 downto 0);
        Data_Out      : out Std_Logic_Vector(Bit_Wdth-1 downto 0)
        );
end dp_mem;

architecture rtl of dp_mem is
  Type T_Mem is array (0 to 311) of Std_Logic_Vector(Bit_Wdth-1 downto 0);
  signal Mem_Contents : T_Mem;
begin  -- rtl
  S_Write_Mem : process(Clock)
  begin
    -- Do not use write first
    if Clock'event and Clock = '1' then
      if Read_Enable = '1' then
        Data_Out <= Mem_Contents(conv_integer(Read_Address));
      end if;
      if Write_Enable = '1' then
        Mem_Contents(conv_integer(Write_Address)) <= Data_In;
      end if;
    end if;
  end process;
end rtl;