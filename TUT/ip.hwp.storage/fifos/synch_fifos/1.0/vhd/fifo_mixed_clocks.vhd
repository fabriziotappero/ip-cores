-------------------------------------------------------------------------------
-- File        : fifo_mixed_clocks.vhdl
-- Description : Mixed Clocks fifo buffer for hibi interface
-- Author      : Ari Kulmala
-- Date        : 19.06.2003
-- Modified    : 
--
-- _almost_ works. Empty signal isn't behaving as expected when 
-- concurrent read and write occurs. It's probably just a little
-- human err somewhere. Also has to check that full really works, even though
-- testbench says it does.
--
--
-- !NOTE!
-- * Output is rubbish when empty. (doesn't speed this up if otherwise).
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity mixed_clocks_fifo is

  generic (
    width : integer := 0;
    depth : integer := 0);

  port (
    Clk_In       : in  std_logic;
    Clk_Out      : in  std_logic;
    Rst_n        : in  std_logic;       -- Active low
    Data_In      : in  std_logic_vector (width-1 downto 0);
    Write_Enable : in  std_logic;
-- One_Place_Left : out std_logic;
    Full         : out std_logic;
    Data_Out     : out std_logic_vector (width-1 downto 0);
    Read_Enable  : in  std_logic;
    Empty        : out std_logic
-- One_Data_Left : out std_logic
    );

end mixed_clocks_fifo;

architecture behavioral of mixed_clocks_fifo is
  type reg is array (depth-1 downto 0) of std_logic_vector
    (width-1 downto 0);
  signal Input_Buffer : reg;
  signal Full_reg   : std_logic;
  signal Empty_reg  : std_logic;
--  signal Full_register   : std_logic register;
--  signal Empty_register  : std_logic register;
  signal Write_token  : integer range 0 to depth-1;
  signal Read_token   : integer range 0 to depth-1;
  --  if write catches read (full)
  signal Write_Turned : std_logic;
  signal Read_got : std_logic;
  
begin  -- behavioral

  -- Continious assignments
 Full <= Full_reg;
 Empty <=  Empty_reg;
 Data_Out <=  Input_Buffer(Read_token);
  
  -- purpose: Read from the FIFO
  Read : process (Clk_Out, Rst_n)
  begin  -- process Read
    if Rst_n = '0' then                 -- asynchronous reset (active low)
      Read_token <= 0;
--      Empty_reg <=  '1';

    elsif Clk_Out'event and Clk_Out = '1' then  -- rising clock edge
      if Read_Enable = '1' then

        if Empty_reg = '0' then
 --         Full_reg <=  '0';
          if Read_token = depth-1 then
            Read_token <= 0;
          else
            Read_token <= Read_token+1;
          end if;

--            if Read_token = Write_token then
--              Empty_reg = '1';
--            else
--              Empty_reg = '0';
--           end if;

        else
          Read_token <= Read_token;
        end if;
      end if;

    else
      Read_token <= Read_token;
    end if;
  end process Read;

  -- purpose: Write to the FIFO
  -- type   : sequential
  Write : process (Clk_In, Rst_n)
  begin  -- process Write
    if Rst_n = '0' then                 -- asynchronous reset (active low)
      Write_token <= 0;
--      Full_reg <= '0';

    elsif Clk_In'event and Clk_In = '1' then  -- rising clock edge
      if Write_Enable = '1' then

        if Full_reg = '0' then
          Input_Buffer(Write_token) <= Data_In;  -- Write_token < depth
--          Empty_reg <=  '0';
          if Write_token = depth-1 then
            Write_token <= 0;
          else
            Write_token <= Write_token+1;
          end if;

--            if Write_token = Read_token then
-- --             Full_reg <= '1'
--             Write_Turned <= '1';
--            else
-- --             Full_reg <= '0':
--              Write_Turned <= '0';
--            end if;
        else
--          Write_Turned   <= Write_Turned;
          Input_Buffer   <= Input_Buffer;
          Write_token    <= Write_token;
        end if;
      end if;

    else
--      Write_Turned <= Write_Turned;
      Input_Buffer <= Input_Buffer;
      Write_token  <= Write_token;
    end if;

  end process Write;

RESET: process (Clk_In, Clk_Out, Rst_n)

  -- ONLY READ CAN PUT EMPTY HIGH
begin  -- process RESET
  if Rst_n = '0' then                   -- asynchronous reset (active low)
    Full_reg  <= '0';
    Empty_reg <= '1';
    Write_Turned <=  '0';
  elsif Clk_Out'event and Clk_Out = '1' then    -- rising clock edge

-- READ
    
    if Write_token = Read_token then
      if Read_Enable = '1' and Write_Enable = '1' then
        if Full_reg = '1' then
          Full_reg <=  '0';
          Write_Turned <=  '0';
 --         Empty_reg <=  '0';
--        elsif Empty_reg = '1' then
--          Full_reg <=  '0';
--          Empty_reg <=  '0';
        else
          Full_reg <=  Full_reg;
          Empty_reg <=  Empty_reg;
        end if;

--      elsif Write_Enable = '1' and Write_Turned = '0' then
--        Empty_reg <=  '0';
--        Full_reg <=  '0';
      elsif Read_Enable = '1' and Write_Turned = '1' then
--        Empty_reg <=  '0';
        Full_reg <=  '0';
        Write_Turned <=  '0';              
      else
        Full_reg <=  Full_reg;
        Empty_reg <= Empty_reg;
        Write_Turned <=  Write_Turned;
        
      end if;
  -- getting empty
    elsif (Write_token - Read_token = 1 or Write_token - Read_token = -depth+1)
           and Read_Enable = '1' then
      Full_reg  <= '0';
      Empty_reg <= '1';
--    elsif (Write_token - Read_token = -1 or Write_token - Read_token = depth-1)             and Write_Enable = '1' then
--      Full_reg <= '1';
--      Empty_reg <=  '0';
--      Write_Turned <=  '1';              

    else

--   Full_reg  <= '0';
   Empty_reg <= '0';
 end if;

-- ONLY WRITE CAN PUT FULL HIGH
   
  elsif Clk_In'event and Clk_In = '1' then    -- rising clock edge

    if Write_token = Read_token then
      if Read_Enable = '1' and Write_Enable = '1' then
        if Full_reg = '1' then
          Full_reg <=  Full_reg;
--          Empty_reg <=  '0';
 --       elsif Empty_reg = '1' then
 --         Full_reg <=  '0';
 --         Empty_reg <=  '0';
        else
          Full_reg <=  Full_reg;
          Empty_reg <=  Empty_reg;
        end if;

      elsif Write_Enable = '1' and Write_Turned = '0' then
        Empty_reg <=  '0';
        Full_reg <=  '0';
 --     elsif Read_Enable = '1' and Write_Turned = '1' then
 --       Empty_reg <=  '0';
 --       Full_reg <=  '0';
 --       Write_Turned <=  '0';              
      else
        Full_reg <=  Full_reg;
        Empty_reg <= Empty_reg;
        Write_Turned <=  Write_Turned;
      end if;

--    elsif (Write_token - Read_token = 1 or Write_token - Read_token = -depth+1)
--           and Read_Enable = '1' then
 --     Full_reg  <= '0';
--      Empty_reg <= '1';
    elsif (Write_token - Read_token = -1 or Write_token - Read_token = depth-1)             and Write_Enable = '1' then
      Full_reg <= '1';
--      Empty_reg <=  '0';
      Write_Turned <=  '1';              

    else

   Full_reg  <= '0';
   Empty_reg <= '0';
 end if;


--  if Write_token = Read_token then
--    if Write_Turned = '1' then
--      Full_reg  <= '1';
--      Empty_reg <= '0';
--    else


--      Full_reg  <= '0';
--      Empty_reg <= '1';
--    end if;

--  else

--    Full_reg  <= '0';
--    Empty_reg <= '0';
--  end if;

  end if;
end process RESET;



        
--   if Rst_n = '0' then
--     Full_reg  <= '0';
--     Empty_reg <= '1';
--   else
--     Full_reg <=  Full_reg;
--     Empty_reg <= Empty_reg;
--   end if;
-- end process Reset;
        
--   end process FULL_AND_EMPTY;

end behavioral;



 
