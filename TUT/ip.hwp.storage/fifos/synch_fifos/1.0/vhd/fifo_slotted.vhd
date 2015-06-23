-------------------------------------------------------------------------------
-- File        : fifo_shift.vhdl
-- Description : Fifo buffer for hibi interface
--
-- Author      : Erno Salminen
-- Date        : 29.10.2004
-- Modified    : 
-- 20.01.2005   ES Names changed
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fifo is

  generic (
    data_width_g :     integer := 32;
    depth_g      :     integer := 5
    );
  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    data_in      : in  std_logic_vector (data_width_g-1 downto 0);
    we_in        : in  std_logic;
    one_p_out    : out std_logic;
    full_out     : out std_logic;
    data_out     : out std_logic_vector (data_width_g-1 downto 0);
    re_in        : in  std_logic;
    empty_out    : out std_logic;
    one_d_out    : out std_logic
    );

end fifo;



architecture slotted_fifo_reg of fifo is

  component fifo_slot
    generic (
      width           :    integer := 0);
    port (
      clk             : in std_logic;
      rst_n           : in std_logic;
      Right_Valid_In  : in std_logic;
      Right_Enable_In : in std_logic;
      Right_data_in   : in std_logic_vector ( width-1 downto 0);

      Left_data_in  : in  std_logic_vector ( width-1 downto 0);
      Left_Valid_In : in  std_logic;
      Left_Enable   : in  std_logic;
      Valid_Out      : out std_logic;
      data_out       : out std_logic_vector ( width-1 downto 0)
      );

  end component; -- fifo_slot;



  type Fifo_slot_type is record
                           Valid : std_logic;
                           Data  : std_logic_vector ( data_width_g-1 downto 0);
                         end record;
  type slot_signal_array is array (depth_g downto 0) of Fifo_slot_type;
  signal intermediate_signal     : slot_signal_array;
  signal we                      : std_logic_vector ( depth_g-1 downto 0);
  signal re                      : std_logic_vector ( depth_g-1 downto 0);

  signal  tie_high : std_logic;


begin  -- slotted_fifo_reg



  -- Continuous assignments
  -- Assigns register values to outputs
  tie_high  <= '1';
  assert depth_g > 1 report "Fifo depth_g must be more than one!" severity WARNING;
  full_out  <= intermediate_signal (depth_g-1).Valid;  -- ylin paikka varattu
  empty_out <= not (intermediate_signal (0).Valid );   -- alin paikka tyhja



  -- Yksi data=alin taynna, toiseksi alin tyhja
  one_d_out <= not (intermediate_signal (1).Valid) and intermediate_signal (0).Valid;

  -- Yksi paikka=ylin tyhja, toiseksi ylin taynna
  one_p_out <= not (intermediate_signal (depth_g-1).Valid) and intermediate_signal (depth_g-2).Valid;

  data_out       <= intermediate_signal (0).Data;  --alin data ulostuloon
  -- Note! There is some old value in data output when fifo is empty.



  map_slots    : for i in 0 to depth_g-1 generate
    gen_slot_i : fifo_slot
      generic map (
        width           => data_width_g
        )
      port map (
        clk             => clk,
        rst_n           => rst_n,
        Right_data_in   => data_in,
        Right_Valid_In  => tie_high,
        Right_Enable_In => we (i),
        Left_Valid_In   => intermediate_signal (i+1).Valid,
        Left_data_in    => intermediate_signal (i+1).Data,
        Left_Enable     => re (i),
        Valid_Out       => intermediate_signal (i).Valid,
        data_out        => intermediate_signal (i).Data
        );
  end generate map_slots;

  intermediate_signal (depth_g).Data  <= (others => '0'); --'Z');
  intermediate_signal (depth_g).Valid <= '0';

  async_first_slot: process (intermediate_signal, we_in, re_in)
  begin  -- process async_first_slot
    -- Ohjataan ensimmaisen we-signaalia
    
    if we_in = '1' and re_in = '0' then
      -- Kirjoitus pelk‰st‰‰n
      re <= (others => '0');

        
      if intermediate_signal (depth_g-1).Valid = '1' then
        -- Ylin paikka taynna
        we <= (others => '0');

        
      else
        -- Kirjoitetaan uusi data 
        we <= (others => '0');

        if intermediate_signal(0).Valid = '0' then
          -- tyhj‰
          we(0) <= '1';
        else
          

           for i in 1 to depth_g-1 loop
             if intermediate_signal(i-1).Valid = '1'
               and intermediate_signal(i).Valid = '0'
             then
               we(i) <= '1';
             end if;
           end loop;  -- (i        
        end if;
      end if;


    elsif we_in = '0' and re_in = '1' then
      -- Luku pelk‰st‰‰n
      we <= (others => '0');
      re <= (others => '1');
   


    elsif we_in = '1' and re_in = '1' then
      --Luku ja kirjoitus yhta aikaa

      if intermediate_signal (depth_g-1).Valid = '1' then
        -- Ylin paikka taynna
        we <= (others => '0');
        re <= (others => '1');

      else
        -- Kirjoitetaan uusi data ja shiftataaan vanhoja
        we <= (others => '0');
        re <= (others => '1');
       

        if intermediate_signal(0).Valid = '0' then
          -- tyhj‰, ei shifatata
          we(0) <= '1';
          re    <= (others => '0');

        else

          for i in 1 to depth_g-1 loop
            if intermediate_signal(i-1).Valid = '1'
              and intermediate_signal(i).Valid = '0'
            then
              -- kirjoiteteaan juuri tyhjenev‰‰n paikkaan
              we (i-1) <= '1';
              re (i-1) <= '0';

            end if;
          end loop;  -- (i     

        end if; 
      end if;

      

    else
      -- Ei tehda mitaan
      we <= (others => '0'); --'Z');
      re <= (others => '0'); -- 'Z');

      
    end if;

    
  end process async_first_slot;



  check_we: process (we)
    variable one_bits : integer := 0;
  begin  -- process check_we
    one_bits := 0;

    for i in 0 to depth_g-1 loop
      if we(i)= '1' then
        one_bits := one_bits +1;
      end if;
    end loop;  -- i


    --    assert one_bits < 2 report "Too many write enables" severity WARNING;
  end process check_we;





  
end slotted_fifo_reg;                  --architecture
