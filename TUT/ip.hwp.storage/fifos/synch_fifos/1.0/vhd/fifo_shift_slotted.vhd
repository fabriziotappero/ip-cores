-------------------------------------------------------------------------------
-- File        : fifo_shift.vhdl
-- Description : Fifo buffer for hibi interface
--
-- Author      : Erno Salminen
-- Date        : 29.05.2003
-- Modified    : 
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fifo is
  
  generic (
    width : integer := 0;
    depth : integer := 0);

  port (
    Clk            : in  std_logic;
    Rst_n          : in  std_logic;
    Data_In        : in  std_logic_vector (width-1 downto 0);
    Write_Enable   : in  std_logic;
    One_Place_Left : out std_logic;
    Full           : out std_logic;
    Data_Out       : out std_logic_vector (width-1 downto 0);
    Read_Enable    : in  std_logic;
    Empty          : out std_logic;
    One_Data_Left  : out std_logic
    );

end fifo;



architecture slotted_shift_reg of fifo is

  component shift_slot  
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

  end component; -- shift_slot;



  type Fifo_slot_type is record
                           Valid : std_logic;
                           Data  : std_logic_vector ( width-1 downto 0);
                         end record;
  type slot_signal_array is array (depth downto 0) of Fifo_slot_type;
  signal intermediate_signal     : slot_signal_array;  
  signal Top_Slot_Write_Enable : std_logic;

begin  -- slotted_shift_reg



  -- Continuous assignments
  -- Assigns register values to outputs
  assert depth > 1 report "Fifo depth must be more than one!" severity WARNING;
  Full           <= intermediate_signal (depth-1).Valid;  -- ylin paikka varattu
  Empty          <= not (intermediate_signal (0).Valid );  -- alin paikka tyhja

  -- Yksi data=alin taynna, toiseksi alin tyhja
  One_Data_Left  <= not (intermediate_signal (1).Valid) and intermediate_signal (0).Valid;

  -- Yksi paikka=ylin tyhja, toiseksi ylin taynna
  One_Place_Left <= not (intermediate_signal (depth-1).Valid) and intermediate_signal (depth-2).Valid;

  Data_Out       <= intermediate_signal (0).Data;  --alin data ulostuloon
  -- Note! There is some old value in data output when fifo is empty.



  top_slot : shift_slot
    generic map (
      width        => width)
    port map (
      Clk          => Clk,
      Rst_n        => Rst_n,
      Valid_In     => intermediate_signal (depth).Valid,
      Data_In      => intermediate_signal (depth).Data,
      Shift_Enable => Top_Slot_Write_Enable,
      Valid_Out    => intermediate_signal(depth-1).Valid,
      Data_Out     => intermediate_signal(depth-1).Data
      );

  map_slots    : for i in 0 to depth-2 generate
    gen_slot_i : shift_slot
      generic map (
        width        => width)
      port map (
        Clk          => Clk,
        Rst_n        => Rst_n,
        Valid_In     => intermediate_signal (i+1).Valid,
        Data_In      => intermediate_signal (i+1).Data,
        Shift_Enable => Read_Enable,
        Valid_Out    => intermediate_signal (i).Valid,
        Data_Out     => intermediate_signal (i).Data
        );
  end generate map_slots;
  

  async_first_slot: process (intermediate_signal, Data_In, Write_Enable, Read_Enable)
  begin  -- process async_first_slot
    -- Ohjataan ensimmaisen (=kirjoitus-) paikan sisaanmenoja
    
    if Write_Enable = '1' and Read_Enable = '0' then
      -- Kirjoitus

      if intermediate_signal (depth-1).Valid = '1' then
        -- Ylin paikka taynna
        Top_Slot_Write_Enable             <= '0';
        intermediate_signal (depth).Data  <= (others => '0');  --'Z');
        intermediate_signal (depth).Valid <= '0';

      else
        -- Kirjoitetaan uusi data ylimpaan
        Top_Slot_Write_Enable             <= '1';
        intermediate_signal (depth).Data  <= Data_In;
        intermediate_signal (depth).Valid <= '1';
      end if;


    elsif Write_Enable = '0' and Read_Enable = '1' then
      -- Luku
      --Nollataan ylin paikka
      Top_Slot_Write_Enable             <= '1';
      intermediate_signal (depth).Data  <= (others => '0');  -- 'Z');
      intermediate_signal (depth).Valid <= '0';


    elsif Write_Enable = '1' and Read_Enable = '1' then
      --Luku ja kirjoitus yhta aikaa
      if intermediate_signal (depth-1).Valid = '1' then
        -- Ylin paikka taynna
        Top_Slot_Write_Enable             <= '0';
        intermediate_signal (depth).Data  <= (others => '0');  --'Z');
        intermediate_signal (depth).Valid <= '0';

      else
        -- Kirjoitetaan uusi data ylimpaan
        Top_Slot_Write_Enable             <= '1';
        intermediate_signal (depth).Data  <= Data_In;
        intermediate_signal (depth).Valid <= '1';
      end if;

      

    else
      -- Ei tehda mitaan
      -- Ylin paikka taynna
      Top_Slot_Write_Enable             <= '0';
      intermediate_signal (depth).Data  <= (others => '0');  --'Z');
      intermediate_signal (depth).Valid <= '0';

      
    end if;

    
  end process async_first_slot;
  
end slotted_shift_reg;                  --architecture
