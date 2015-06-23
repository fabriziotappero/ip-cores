-------------------------------------------------------------------------------
-- File        : lifo_shift.vhdl
-- Description : Lifo buffer for hibi interface
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

entity lifo is
  
  generic (
    width : integer := 3;
    depth : integer := 30);

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

end lifo;



architecture slotted_lifo_reg of lifo is

  component fifo_slot
    generic (
      width          :     integer := 0);
    port (
      Clk            : in  std_logic;
      Rst_n          : in  std_logic;
      Right_Valid_In   : in  std_logic;
      Right_Enable_In  : in  std_logic;
      Right_Data_In    : in  std_logic_vector ( width-1 downto 0);

      Left_Data_In  : in  std_logic_vector ( width-1 downto 0);
      Left_Valid_In : in  std_logic;
      Left_Enable   : in  std_logic;
      Valid_Out      : out std_logic;
      Data_Out       : out std_logic_vector ( width-1 downto 0)
      );

  end component; -- fifo_slot;



  type Fifo_slot_type is record
                           Valid : std_logic;
                           Data  : std_logic_vector ( width-1 downto 0);
                         end record;
  type slot_signal_array is array (depth downto -1) of Fifo_slot_type;
  signal intermediate_signal     : slot_signal_array;
  signal we                      : std_logic_vector ( depth-1 downto 0);
  signal re                      : std_logic_vector ( depth-1 downto 0);

begin  -- slotted_lifo_reg


  -----------------------------------------------------------------------------
  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  -- LIFO!
  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ------------------------------------------------------------------------------

  -- Continuous assignments
  -- Assigns register values to outputs
  assert depth > 1 report "Lifo depth must be more than one!" severity WARNING;
  Full           <= intermediate_signal (depth-1).Valid;  -- ylin paikka varattu
  Empty          <= not (intermediate_signal (0).Valid );  -- alin paikka tyhja

  -- Yksi data=alin taynna, toiseksi alin tyhja
  One_Data_Left  <= not (intermediate_signal (1).Valid) and intermediate_signal (0).Valid;

  -- Yksi paikka=ylin tyhja, toiseksi ylin taynna
  One_Place_Left <= not (intermediate_signal (depth-1).Valid) and intermediate_signal (depth-2).Valid;

  Data_Out       <= intermediate_signal (0).Data;  --alin data ulostuloon
  -- Note! There is some old value in data output when lifo is empty.


  map_slots    : for i in 0 to depth-1 generate
    gen_slot_i : fifo_slot
      generic map (
        width           => width)
      port map (
        Clk             => Clk,
        Rst_n           => Rst_n,
        Right_Valid_In  => intermediate_signal (i-1).Valid,
        Right_Data_In   => intermediate_signal (i-1).Data,
        Right_Enable_In => we(i),
        Left_Valid_In   => intermediate_signal (i+1).Valid,
        Left_Data_In    => intermediate_signal (i+1).Data,
        Left_Enable     => re(i),
        Valid_Out       => intermediate_signal (i).Valid,
        Data_Out        => intermediate_signal (i).Data
        );
  end generate map_slots;

  intermediate_signal (depth).Data <= (others => '0'); --'Z');
  intermediate_signal (depth).Valid   <= '0';

  intermediate_signal (-1).Data  <= Data_In;
  intermediate_signal (-1).Valid <= '1';


  
  async_first_slot: process (intermediate_signal, Data_In, Write_Enable, Read_Enable)
  begin  -- process async_first_slot
    -- Ohjataan ensimmaisen we-signaalia
    
    if Write_Enable = '1' and Read_Enable = '0' then
      -- Kirjoitus pelk‰st‰‰n

      re <= (others => '0');
      
      if intermediate_signal (depth-1).Valid = '1' then
        -- Ylin paikka taynna
        we    <= (others => '0');
      else
        -- Kirjoitetaan uusi data 
        we    <= (others => '1');
      end if;

      
    elsif Write_Enable = '0' and Read_Enable = '1' then
      -- Luku pelk‰st‰‰n
      we <= (others => '0');
      re <= (others => '1');
   


    elsif Write_Enable = '1' and Read_Enable = '1' then
      --Luku ja kirjoitus yhta aikaa

      if intermediate_signal (depth-1).Valid = '1' then
        -- Ylin paikka taynna
        we    <= (others => '0');
        re    <= (others => '1');
        
      else
        -- Kirjoitetaan uusi data alinmpaan slottiiin
        -- muut pitv‰‰t vanahan arvonsa
        we    <= (others => '0');
        we(0) <= '1';
        re    <= (others => '0');

      end if;

      

    else
      -- Ei tehda mitaan
      we <= (others => '0'); --'Z');
      re <= (others => '0'); --'Z');

      
    end if;

    
  end process async_first_slot;

  
  -----------------------------------------------------------------------------
  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  -- LIFO!
  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ------------------------------------------------------------------------------


  check_we: process (we)
    variable one_bits : integer := 0;
  begin  -- process check_we
    one_bits := 0;

    for i in 0 to depth-1 loop
      if we(i)= '1' then
        one_bits := one_bits +1;
      end if;
    end loop;  -- i


--    assert one_bits < 2 report "Too many write enables" severity WARNING;
  end process check_we;





  
end slotted_lifo_reg;                  --architecture
