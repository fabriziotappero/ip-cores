-------------------------------------------------------------------------------
-- File        : shift_slot.vhdl
-- Description : One slot for shift register
--               Basically a Register(valid bit+data) and mux
-- Author      : Erno Salminen
-- Date        : 29.05.2003
-- Modified    : 
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity shift_slot is
  
  generic (
    width : integer := 0);

  port (
    Clk          : in  std_logic;
    Rst_n        : in  std_logic;
    Valid_In     : in  std_logic;
    Data_In      : in  std_logic_vector ( width-1 downto 0);
    Shift_Enable : in  std_logic;
    Valid_Out    : out std_logic;
    Data_Out     : out std_logic_vector ( width-1 downto 0)
    );

end shift_slot;



architecture rtl of shift_slot is

  type Shift_slot_type is record
                           Valid : std_logic;
                           Data  : std_logic_vector ( width-1 downto 0);
                         end record;

  signal Data_reg : Shift_slot_type;

  
begin  -- rtl


  -- CONC
  Data_Out  <= Data_reg.Data;
  Valid_Out <= Data_reg.Valid;

  -- PROC
  Sync : process (Clk, Rst_n)
  begin  -- process Sync
    if Rst_n = '0' then                 -- asynchronous reset (active low)
      Data_reg.Data  <= (others => '0');
      Data_reg.Valid <= '0';

    elsif Clk'event and Clk = '1' then  -- rising clock edge

      if Shift_Enable = '1' then
        Data_reg.Data  <= Data_In;
        Data_reg.Valid <= Valid_In;
      else
        Data_reg.Data  <= Data_reg.Data;
        Data_reg.Valid <= Data_reg.Valid;
      end if;

      
    end if;
  end process Sync;

end rtl;
