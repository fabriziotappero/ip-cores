-------------------------------------------------------------------------------
-- File        : fifo_slot.vhdl
-- Description : One slot for fifo register
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


entity fifo_slot is
  
  generic (
    width : integer := 0);

  port (
    Clk             : in std_logic;
    Rst_n           : in std_logic;
    Right_Valid_In  : in std_logic;
    Right_Enable_In : in std_logic;
    Right_Data_In   : in std_logic_vector ( width-1 downto 0);

    Left_Data_In  : in  std_logic_vector ( width-1 downto 0);
    Left_Valid_in : in  std_logic;
    Left_Enable   : in  std_logic;
    Valid_Out     : out std_logic;
    Data_Out      : out std_logic_vector ( width-1 downto 0)
    );

end fifo_slot;



architecture rtl of fifo_slot is

  type Fifo_slot_type is record
                           Valid : std_logic;
                           Data  : std_logic_vector ( width-1 downto 0);
                         end record;

  signal Data_reg : Fifo_slot_type;

  
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

      if Right_Enable_In = '1' and Left_Enable = '1' then 
        -- ctrl = "11" = 3
        -- keep old values
        Data_reg.Data  <= Data_reg.Data;
        Data_reg.Valid <= Data_reg.Valid;
        assert false report "Simultaneous read+write" severity note;

        
      elsif Right_Enable_In = '1' and Left_Enable = '0' then
        -- ctrl = "10" = 2
        Data_reg.Data  <= Right_Data_In;
        Data_reg.Valid <= Right_Valid_In; --'1';

      elsif Right_Enable_In = '0' and Left_Enable = '1'then
        -- ctrl = "01" = 1
        Data_reg.Data  <= Left_Data_In;
        Data_reg.Valid <= Left_Valid_in;

      else
        -- ctrl = "00" = 0
        Data_reg.Data  <= Data_reg.Data;
        Data_reg.Valid <= Data_reg.Valid;
      end if;

      
    end if;
  end process Sync;

end rtl;
