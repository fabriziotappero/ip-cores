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



architecture shift_reg of fifo is

  type Fifo_slot_type is record
                           Valid : std_logic;
                           Data  : std_logic_vector ( width-1 downto 0);
                         end record;

  type data_array is array (depth-1 downto 0) of Fifo_slot_type;
  signal Fifo_Buffer : data_array;

  -- Registers
  --signal Data_Amount        : integer range 0 to depth-1;

  signal WE_RE : std_logic_vector ( 1 downto 0);
  
begin  -- shift_reg



  -- Continuous assignments
  -- Assigns register values to outputs
  WE_RE <= Write_Enable & Read_Enable;  -- yhdistetaan case-lausetta varten
  
  assert depth > 1 report "Fifo depth must be more than one!" severity WARNING;
  Full           <= Fifo_Buffer (depth-1).Valid;  -- ylin paikka varattu
  Empty          <= not (Fifo_Buffer (0).Valid);  -- alin paikka tyhja

  -- Yksi data=alin taynna, toiseksi alin tyhja
  One_Data_Left  <= not (Fifo_Buffer (1).Valid) and Fifo_Buffer (0).Valid;

  -- Yksi paikka=ylin tyhja, toiseksi ylin taynna
  One_Place_Left <= not (Fifo_Buffer (depth-1).Valid) and Fifo_Buffer (depth-2).Valid;

  Data_Out       <= Fifo_Buffer (0).Data;  --alin data ulostuloon
  -- Note! There is some old value in data output when fifo is empty.





  
  Sync: process (Clk, Rst_n)
  begin  -- process Sync
    if Rst_n = '0' then                 -- asynchronous reset (active low)

      -- Reset all registers
      --Data_Amount             <= 0;
      for i in 0 to depth-1 loop
        Fifo_Buffer (i).Data  <= (others => '0');  --'Z');
        Fifo_Buffer (i).Valid <= '0';
      end loop;  -- i

      
    elsif Clk'event and Clk = '1' then  -- rising clock edge

      -- Vaihdetaan if-elsif-else case-lauseeksi
      case WE_RE is
        
        when "10" => 
          -- Kirjoitus
          if Fifo_Buffer (depth-1).Valid = '1' then
            -- Fifo taynna, kirjoitus ei onnistu
            Fifo_Buffer <= Fifo_Buffer;
            assert false report "Cannot write to full fifo" severity note;

          else
            -- Fifossa tilaa
            --30.05 
            -- !!! Huom jos tassa ei sijoita muihin paikkoihin vanhoja
            -- arvoja, max. viive kasvaa!!
            -- Esim. 50x1b (ilman sijoitusta) 1.5ns
            -- 50x1b (sijoituksen kanssa) 0.88ns
            -- be careful out there!
            Fifo_Buffer                 <= Fifo_Buffer;  --30.05
            Fifo_Buffer (depth-1).Valid <= '1';  --paikka kaytossa
            Fifo_Buffer (depth-1).Data  <= Data_In;
          end if;


        when "01" => 
          -- Luku
          -- Shiftaus (isoista indekseista kohti indeksia nolla)
          for i in 0 to depth-2 loop
            Fifo_Buffer (i)           <= Fifo_Buffer (i+1);
          end loop;  -- i
          --ylin paikka tyhjenee
          Fifo_Buffer (depth-1).Valid <= '0';              
          Fifo_Buffer (depth-1).Data  <= (others => '0');  --'Z');


        when "11" =>
          -- Seka kirjoitus etta luku

          if Fifo_Buffer (depth-1).Valid = '1' then
            -- Fifo taynna, kirjoitus ei onnistu mutta luku onnistuu
            -- Ylin (sisaantulo)paikka tyhjenee
            Fifo_Buffer (depth-1).Data  <= (others => '0');  --'Z';
            Fifo_Buffer (depth-1).Valid <= '0';  
          else
            -- Seka luku etta kirjoitus onnistuvat
            Fifo_Buffer (depth-1).Valid <= '1';  --paikka kaytossa
            Fifo_Buffer (depth-1).Data  <= Data_In;
          end if;

          -- Shiftataan joka tapauksessa (isoista indekseista kohti indeksia nolla)
          for i in 0 to depth-2 loop
            Fifo_Buffer (i) <= Fifo_Buffer (i+1);
          end loop;  -- i
          
        when others =>
          -- Ei tehda mitaan
          Fifo_Buffer <= Fifo_Buffer;          
      end case;
    end if;                             --rst/clk
  end process Sync;

end shift_reg;
