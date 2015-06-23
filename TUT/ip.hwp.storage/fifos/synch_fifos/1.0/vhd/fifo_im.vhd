-------------------------------------------------------------------------------
-- File        : fifo_im.vhdl
-- Description : Fifo buffer for hibi interface
-- Author      : Erno Salminen
-- Date        : 29.04.2002
-- Modified    : 30.04.2002 Vesa Lahtinen Optimized for synthesis
--
--              02.06 ES: default assignment Fifo_Buffer <= Fifo_Buffer
--                      smaller and faster implementation
--              Effect on synthesis is uncertain :
--              small fifos seem to gets smaller and faster, but big fifos
--              get bigger and slower. Strange.
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

architecture in_mux of fifo is

  type data_array is array (depth-1 downto 0) of std_logic_vector (width-1 downto 0);
  signal Fifo_Buffer : data_array;

  -- Registers
  signal Full_reg           : std_logic;
  signal Empty_reg          : std_logic;
  signal One_Data_Left_reg  : std_logic;
  signal One_Place_Left_reg : std_logic;
  --signal Data_Amount        : std_logic_vector (depth-1 downto 0);
  signal Data_Amount        : integer range 0 to depth-1;


begin  -- in_mux

  -- Continuous assignments
  -- Assigns register values to outputs
  Full           <= Full_reg;
  Empty          <= Empty_reg;
  One_Data_Left  <= One_Data_Left_reg;
  One_Place_Left <= One_Place_Left_reg;
  Data_Out       <= Fifo_Buffer (0);
  -- Note! There is some old value in data output when fifo is empty.

  
Main : process (Clk, Rst_n)
begin  -- process Main
  if Rst_n = '0' then                   -- asynchronous reset (active low)

    -- Reset all registers
    -- Fifo is empty at first
    Full_reg           <= '0';
    Empty_reg          <= '1';
    One_Data_Left_reg  <= '0';
    Data_Amount        <= 0; 

    if depth =1 then                    -- 30.07
      One_Place_Left_reg <= '1';
    else
      One_Place_Left_reg <= '0';      
    end if;

    for i in 0 to depth-1 loop
      Fifo_Buffer (i)  <= (others => '0');
    end loop;  -- i

  elsif Clk'event and Clk = '1' then    -- rising clock edge


    -- 1) Write data to fifo
    if Write_Enable = '1' and Read_Enable = '0' then

      if Full_reg = '0' then
        Empty_reg                 <= '0';
        Data_Amount               <= Data_Amount +1;

        Fifo_Buffer               <= Fifo_Buffer;  --02.06
        Fifo_Buffer (Data_Amount) <= Data_In;

        -- Check if the fifo is getting full
        if Data_Amount + 2 = depth then
          Full_reg           <= '0';
          One_Place_Left_reg <= '1';
        elsif Data_Amount +1 = depth then
          Full_reg           <= '1';
          One_Place_Left_reg <= '0';
        else
          Full_reg           <= '0';
          One_Place_Left_reg <= '0';
        end if;

        
        -- If fifo was empty, it has now one data 
        if Empty_reg = '1' then
          One_Data_Left_reg <= '1';
        else
          One_Data_Left_reg <= '0';
        end if;

      else
        Full_reg           <= Full_reg;
        Empty_reg          <= Empty_reg;
        Fifo_Buffer        <= Fifo_Buffer;
        Data_Amount        <= Data_Amount;
        One_Data_Left_reg  <= One_Data_Left_reg;
        One_Place_Left_reg <= One_Place_Left_reg;
      end if;

      
    -- 2) Read data from fifo  
    elsif Write_Enable = '0' and Read_Enable = '1' then

      if Empty_reg = '0' then

        -- Shiftaus
        Fifo_Buffer               <= Fifo_Buffer;  --02.06
        for i in 0 to depth-2 loop
          Fifo_Buffer (i) <= Fifo_Buffer (i+1);
        end loop;  -- i

        Full_reg    <= '0';
        Data_Amount <= Data_Amount -1;

        -- Debug
        -- Fifo_Buffer (out_ptr) <= (others => '1');



        
        -- Check if the fifo is getting empty
        if Data_Amount = 2 then
          Empty_reg         <= '0';
          One_data_Left_reg <= '1';
        elsif Data_Amount = 1 then
          Empty_reg         <= '1';
          One_Data_Left_reg <= '0';
        else
          Empty_reg         <= '0';
          One_Data_Left_reg <= '0';
        end if;

        -- If fifo was full, it is no more 
        if Full_reg = '1' then
          One_Place_Left_reg <= '1';
        else
          One_Place_Left_reg <= '0';
        end if;

      else
        Full_reg           <= Full_reg;
        Empty_reg          <= Empty_reg;
        Fifo_Buffer        <= Fifo_Buffer;
        Data_Amount        <= Data_Amount;
        One_Data_Left_reg  <= One_Data_Left_reg;
        One_Place_Left_reg <= One_Place_Left_reg;
      end if;


    -- 3) Write and read at the same time  
    elsif Write_Enable = '1' and Read_Enable = '1' then
      

      if Full_reg = '0' and Empty_reg = '0' then
        Full_reg           <= '0';
        Empty_reg          <= '0';
        Data_Amount        <= Data_Amount;
        One_Data_Left_reg  <= One_Data_Left_reg;
        One_Place_Left_reg <= One_Place_Left_reg;

        Fifo_Buffer               <= Fifo_Buffer;  --02.06
        -- Shiftaus
        for i in 0 to depth-2 loop
          Fifo_Buffer (i) <= Fifo_Buffer (i+1);
        end loop;  -- i
        Fifo_Buffer (Data_Amount-1)  <= Data_In;  --vai amount-1 ?? koska pitaa
                                                --shiftata samalla

        -- Fifo_Buffer (out_ptr) <= (others => '1');  --debug


      elsif Full_reg = '1' and Empty_reg = '0' then
        -- Fifo is full, only reading is possible
        
        Full_reg              <= '0';
        One_Place_Left_reg    <= '1';
        --Fifo_Buffer (out_ptr) <= (others => '1');  -- Debug
        Data_Amount           <= Data_Amount -1;

        Fifo_Buffer               <= Fifo_Buffer;  --02.06
        -- Shiftaus
        for i in 0 to depth-2 loop
          Fifo_Buffer (i) <= Fifo_Buffer (i+1);
        end loop;  -- i

        -- Check if the fifo is getting empty
        if Data_Amount = 2 then
          Empty_reg         <= '0';
          One_data_Left_reg <= '1';
        elsif Data_Amount = 1 then
          Empty_reg         <= '1';
          One_Data_Left_reg <= '0';
        else
          Empty_reg         <= '0';
          One_Data_Left_reg <= '0';
        end if;
 

      elsif Full_reg = '0' and Empty_reg = '1' then
        -- Fifo is empty, only writing is possible
        Empty_reg                 <= '0';
        One_Data_Left_reg         <= '1';
        Fifo_Buffer               <= Fifo_Buffer;  --02.06
        Fifo_Buffer (Data_Amount) <= Data_In;  --Data_Amount =0
        Data_Amount               <= Data_Amount +1;

        -- Check if the fifo is getting full
        if Data_Amount + 2 = depth then
          Full_reg           <= '0';
          One_Place_Left_reg <= '1';
        elsif Data_Amount +1 = depth then
          Full_reg           <= '1';
          One_Place_Left_reg <= '0';
        else
          Full_reg           <= '0';
          One_Place_Left_reg <= '0';
        end if;


      else
        -- Fifo is full and empty at the same time => impossible
        Full_reg           <= Full_reg;
        Empty_reg          <= Empty_reg;
        Fifo_Buffer        <= Fifo_Buffer;
        Data_Amount        <= Data_Amount;
        One_Data_Left_reg  <= One_Data_Left_reg;
        One_Place_Left_reg <= One_Place_Left_reg;          
      end if;                           --Full_reg & Empty_reg

      
    -- 4) Do nothing, fifo remains idle 
    else

      Full_reg           <= Full_reg;
      Empty_reg          <= Empty_reg;
      Fifo_Buffer        <= Fifo_Buffer;
      Data_Amount        <= Data_Amount;
      One_Data_Left_reg  <= One_Data_Left_reg;
      One_Place_Left_reg <= One_Place_Left_reg;
    end if;

  end if;
end process Main;

end in_mux;
