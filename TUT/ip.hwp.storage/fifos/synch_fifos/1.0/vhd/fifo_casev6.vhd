-------------------------------------------------------------------------------
-- File        : fifo_casev6.vhdl
-- Description : Fifo buffer for hibi interface
-- Author      : Ari Kulmala
-- Date        : 10.06.2003
-- Modified    : 18.06.2003 - Re-wrote the way output control signals are
--                            assigned
--                          - output value is not zero when empty
--
-- Detailed description:
-- -Input and Output always from the same register
--   -> input-buffer is shifted whenever write occurs
--   -> when read, a mux chooses which value to load to the output next
--      (the oldest)
--
-- !NOTE! isn't tested as one-length FIFO. doesn't probably work. (vector
-- length (1 downto 2) ...
--
-- !NOTE!
-- * Output stays in the old value when empty.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- To do: as in fifo_casev4: fifojen nollaus olisi syyta ehka poistaa myos
-- resetin yhteydesta, jos sita ei nollata myoskaan luettaessa viimeinen
-- samaten input_bufferin nollaus.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity fifo is

  generic (
    width : integer := 0;
    depth : integer := 0);

  port (
    Clk            : in  std_logic;
    Rst_n          : in  std_logic;     -- Active low
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

architecture behavioral of fifo is

  -- range is this so that one can use data_amount directly to indexing
  type reg is array (depth downto 2) of std_logic_vector
    (width-1 downto 0);
  signal input_buffer : reg;
  -- Registers
  signal Full_reg           : std_logic;
  signal Empty_reg          : std_logic;
  signal One_Data_Left_reg  : std_logic;
  signal One_Place_Left_reg : std_logic;

  signal Data_amount : integer range 0 to depth;


  signal WR : std_logic_vector ( 1 downto 0);
  
begin  -- behavioral

    -- Continuous assignments
  -- Assigns register values to outputs
  Full           <= Full_reg;
  Empty          <= Empty_reg;
  One_Data_Left  <= One_Data_Left_reg;
  One_Place_Left <= One_Place_Left_reg;
  -- Concurrent assignment
  WR <= Write_Enable & Read_Enable;
  


process (Clk, rst_n)
begin  -- process
  if rst_n = '0' then                   -- asynchronous reset (active low)
    --     for i in depth downto 2 loop
    --       input_buffer(i) <= (others => '0');
    --     end loop;                    -- i
    --    Data_out          <= (others => '0');
    Data_Amount        <= 0;
    Empty_reg          <= '1';
    One_Data_Left_reg  <= '0';
    One_Place_Left_reg <= '0';
    Full_reg           <= '0';

  elsif Clk'event and Clk = '1' then    -- rising clock edge

    case WR is
      when "01"                        =>
        -- Read data
        if Data_amount = 0 then
          -- empty
          Data_amount       <= Data_amount;
          Empty_reg         <= '1';
          One_Data_Left_reg <= '0';
        elsif Data_amount = 1 then         -- 1 data
          --          Data_out          <= (others => '0');
          Data_amount       <= Data_amount-1;
          Empty_reg         <= '1';
          One_Data_Left_reg <= '0';
        elsif Data_amount = 2 then
          Data_out          <= input_buffer(Data_amount);
          Data_amount       <= Data_amount-1;
          Empty_reg         <= '0';
          One_Data_Left_reg <= '1';
        else
          Data_out          <= input_buffer(Data_amount);
          Data_amount       <= Data_amount-1;
          One_Data_Left_reg <= '0';
          Empty_reg         <= '0';
        end if;

        if Data_amount = depth-1 then
          One_Place_Left_reg <= '0';
          Full_reg           <= '0';
        elsif Data_amount = depth then
          One_Place_Left_reg <= '1';
          Full_reg           <= '0';
        else
          One_Place_Left_reg <= '0';
          Full_reg           <= '0';
        end if;


      when "10" =>
        -- Write Data
        if Data_amount = 0 then
          Data_out            <= Data_In;
          Data_amount         <= Data_amount+1;
        elsif Data_amount = depth then
          input_buffer        <= input_buffer;
        else
          for i in depth-1 downto 2 loop
            input_buffer(i+1) <= input_buffer(i);
          end loop;  -- i
          input_buffer(2)     <= Data_In;
          Data_amount         <= Data_amount+1;
        end if;

        -- Define the control signals here    
        
        if Data_amount = 0 then
          Empty_reg          <= '0';
          One_Data_Left_reg  <= '1';
          Full_reg           <= '0';
          One_Place_Left_reg <= '0';
        elsif Data_amount = 1 then
          Empty_reg          <= '0';
          One_Data_Left_reg  <= '0';
          Full_reg           <= '0';
          One_Place_Left_reg <= '0';
        elsif Data_amount = depth-2 then
          Empty_reg          <= '0';
          One_Data_Left_reg  <= '0';
          Full_reg           <= '0';
          One_Place_Left_reg <= '1';
        elsif Data_amount = depth-1 then
          Empty_reg          <= '0';
          One_Data_Left_reg  <= '0';
          Full_reg           <= '1';
          One_Place_Left_reg <= '0';
        else
          Empty_reg          <= Empty_reg;
          One_Data_Left_reg  <= One_Data_Left_reg;
          Full_reg           <= Full_reg;
          One_Place_Left_reg <= One_Place_Left_reg;

        end if;

      when "11" =>
        -- Read and Write concurrently

        if Data_amount = 0 then
          -- can only write
          Data_out           <= Data_in;
          Empty_reg          <= '0';
          One_Data_Left_reg  <= '1';
          Full_reg           <= '0';
          One_Place_Left_reg <= '0';
          Data_amount <= Data_amount+1;

        elsif Data_amount = 1 then
          Data_out           <= Data_In;
          Empty_reg          <= '0';
          One_Data_Left_reg  <= '1';
          Full_reg           <= '0';
          One_Place_Left_reg <= '0';

        elsif Data_amount = depth then
          -- cannot write if full, just read
          Data_out            <= input_buffer (Data_amount);
          Data_amount         <= Data_amount-1;
          Empty_reg           <= '0';
          One_Data_Left_reg   <= '0';
          Full_reg            <= '0';
          One_Place_Left_reg  <= '1';
        else
          Data_out            <= input_buffer (Data_amount);
          for i in depth-1 downto 2 loop
            input_buffer(i+1) <= input_buffer(i);
          end loop;  -- i
          input_buffer(2)     <= Data_In;
          Empty_reg           <= Empty_reg;
          One_Data_Left_reg   <= One_Data_Left_reg;
          Full_reg            <= Full_reg;
          One_Place_Left_reg  <= One_Place_Left_reg;
        end if;
   
      when others =>
        -- Do nothing
        input_buffer       <= input_buffer;
        Data_amount        <= Data_amount;
        Empty_reg          <= Empty_reg;
        One_Data_Left_reg  <= One_Data_Left_reg;
        Full_reg           <= Full_reg;
        One_Place_Left_reg <= One_Place_Left_reg;

    end case;

  end if; --synchronous

  end process;
  
end behavioral;












