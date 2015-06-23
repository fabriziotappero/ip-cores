-------------------------------------------------------------------------------
-- File        : tb_fifo1.vhdl
-- Description : Test bench for Fifo buffer, fifo length = 1!
-- Author      : Erno Salminen
-- Date        : 29.04.2002
-- Modified    : 02.05.2002 Vesa Lahtinen Tests added
--
-- 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tb_fifo1 is
end tb_fifo1;

architecture behavioral of tb_fifo1 is


component fifo

  generic (
    width : integer := 0;
    depth : integer := 0
    );

  port (
    Clk : in std_logic;
    Rst_n : std_logic;
    Data_In        : in  std_logic_vector (width-1 downto 0);
    Write_Enable   : in  std_logic;
    One_Place_Left : out std_logic;
    Full           : out std_logic;
    Data_Out       : out std_logic_vector (width-1 downto 0);
    Read_Enable    : in  std_logic;
    Empty          : out std_logic;
    One_Data_Left  : out std_logic
    );
end component;

constant width  : integer := 16;
constant depth  : integer := 1;         -- !!!
constant PERIOD : time    := 10 ns;

signal Clk            : std_logic;
signal Rst_n          : std_logic;
signal Data_In        : std_logic_vector (width-1 downto 0);
signal Data_Out       : std_logic_vector (width-1 downto 0);
signal Write_Enable   : std_logic;
signal Read_Enable    : std_logic;
signal Full           : std_logic;
signal One_Place_Left : std_logic;
signal Empty          : std_logic;
signal One_Data_Left  : std_logic;

signal Read_Data      : std_logic_vector (width-1 downto 0);

signal Test_Phase : integer range 0 to 20;

begin  -- behavioral


DUT : fifo
  generic map (
    width => width,
    depth => depth)
  port map (
    Clk            => Clk,
    Rst_n          => Rst_n,
    Data_In        => Data_In,
    Write_Enable   => Write_Enable,
    Full           => Full,
    One_Place_Left => One_Place_Left,
    Data_Out       => Data_Out,
    Read_Enable    => Read_Enable,
    Empty          => Empty,
    One_Data_Left  => One_Data_Left );

Generate_input : process

  -----------------------------------------------------------------------------
  -- Two procedures for writing to and for reading the fifo
  -----------------------------------------------------------------------------
  procedure WriteToFifo (
    Data_To_Fifo : in integer;
    wait_time : in integer) is      
  begin                               --procedure
    Read_Enable <= '0'; -- 24.05 es
    Data_In <= conv_std_logic_vector (Data_To_Fifo, width);
    Write_Enable <= '1';
    if Full = '1' then
      assert false report "Fifo full. Cannot write" severity note;
    end if;
    wait for PERIOD;
    Write_Enable <= '0';
    Data_In      <= (others => 'Z');
    wait for (wait_time)* PERIOD;
  end WriteToFifo;


  procedure ReadFifo (
    wait_time : in integer) is
  begin  --procedure
    Write_Enable <= '0'; -- 24.05 es
    Read_Enable <= '1';
    
    if Empty = '1' then
      assert false report "Fifo empty. Cannot read." severity note;
    end if;
    wait for PERIOD;
    Read_Enable   <= '0';
    wait for (wait_time)* PERIOD;

  end ReadFifo;

  procedure WriteAndReadFifo (
    Data_To_Fifo : in integer;
    wait_time : in integer) is
  begin  --procedure
    Read_Enable <= '1';
    if Empty = '1' then
      assert false report "Fifo empty. Cannot read. Writing possible." severity note;
    end if;
    
    Data_In <= conv_std_logic_vector (Data_To_Fifo, width);
    Write_Enable <= '1';
    if Full = '1' then
      assert false report "Fifo full. Cannot write. Reading possible." severity note;
    end if;


    wait for PERIOD;
    Read_Enable  <= '0';
    Write_Enable <= '0';
    Data_In      <= (others => 'Z');    -- 24.05 es
    wait for (wait_time)* PERIOD;

  end WriteAndReadFifo;
  -----------------------------------------------------------------------------



begin  -- process Generate_input
  -- test sequence
  -- 0 wait for reset
  -- 1 write to empty fifo and read so that it is empty again
  -- 2 write to fifo until there is only one place left
  -- 3 write to fifo so that it becomes full
  -- 4 read from full fifo and continue until there is only one data left
  -- 5 read the last data
  --   write and read the empty fifo at the same time, only write is succesful!
  -- 6 write to fifo, write and read at the same time, both should be succesful!
  -- 7 write until fifo  is full
  -- 8 write and read full fifo, only reading succesful!
  --   read until fifo is empty
  -- 9 make sure fifo is empty


  -- 0 Wait for reset
  Write_Enable <= '0';
  Read_Enable  <= '0';
  Data_In      <= (others => 'Z');
  Test_Phase   <= 0;
  wait for (6+2)*PERIOD;
  wait for PERIOD/2;
  wait for PERIOD/3;


  -- At the beginning
  -- Full = 0
  -- Empty = 1
  -- One_Place_Left = 1
  -- One_Data_Left = 0
  -- NOTE! Empty = One_Place_Left and Full = One_Data_Left
  assert Full           = '0' report "0: Full not correct"           severity error;
  assert Empty          = '1' report "0: Empty not correct"          severity error;
  assert One_Data_Left  = '0' report "0: One_Data_Left not correct"  severity error;
  assert One_Place_Left = '1' report "0: One_Place_Left not correct" severity error;

  -- 1) Write to empty fifo
  Test_Phase   <= Test_Phase +1;
  WriteToFifo (5, 1);
  assert Full           = '1' report "1: Full not correct"           severity error;
  assert Empty          = '0' report "1: Empty not correct"          severity error;
  assert One_Data_Left  = '1' report "1: One_Data_Left not correct"  severity error;
  assert One_Place_Left = '0' report "1: One_Place_Left not correct" severity error;
  assert Data_Out = conv_std_logic_vector (5, width) report "1: data not stored correctly" severity error;

  -- 2 )write to full fifo
  Test_Phase   <=Test_Phase +1;
  WriteToFifo (10, 1);
  WriteToFifo (11, 1);
  WriteToFifo (12, 1);
  WriteToFifo (13, 1);
  assert Full           = '1' report "2: Full not correct"           severity error;
  assert Empty          = '0' report "2: Empty not correct"          severity error;
  assert One_Data_Left  = '1' report "2: One_Data_Left not correct"  severity error;
  assert One_Place_Left = '0' report "2: One_Place_Left not correct" severity error;
  assert Data_Out = conv_std_logic_vector (5, width) report "2: data not stored correctly" severity error;
  
  
  -- 3) write and read full fifo
  -- only read succesful
  Test_Phase   <= Test_Phase +1;
  WriteAndReadFifo (14,2);
  assert Full           = '0' report "3: Full not correct"           severity error;
  assert Empty          = '1' report "3: Empty not correct"          severity error;
  assert One_Data_Left  = '0' report "3: One_Data_Left not correct"  severity error;
  assert One_Place_Left = '1' report "3: One_Place_Left not correct" severity error;


  -- 4 read empty fifo
  Test_Phase   <= Test_Phase +1;
  ReadFifo (1);
  ReadFifo (1);
  ReadFifo (1);
  assert Full           = '0' report "4: Full not correct"           severity error;
  assert Empty          = '1' report "4: Empty not correct"          severity error;
  assert One_Data_Left  = '0' report "4: One_Data_Left not correct"  severity error;
  assert One_Place_Left = '1' report "4: One_Place_Left not correct" severity error;
  
  -- 5 write and read empty fifo
  Test_Phase   <= Test_Phase +1;
  WriteAndReadFifo (15,2);
  assert Full           = '1' report "5: Full not correct"           severity error;
  assert Empty          = '0' report "5: Empty not correct"          severity error;
  assert One_Data_Left  = '1' report "5: One_Data_Left not correct"  severity error;
  assert One_Place_Left = '0' report "5: One_Place_Left not correct" severity error;
  assert Data_Out = conv_std_logic_vector (15, width) report "5: data not stored correctly" severity error;
  
  -- 6 read full fifo
  Test_Phase   <= Test_Phase +1;
  ReadFifo (2);
  assert Full           = '0' report "6: Full not correct"           severity error;
  assert Empty          = '1' report "6: Empty not correct"          severity error;
  assert One_Data_Left  = '0' report "6: One_Data_Left not correct"  severity error;
  assert One_Place_Left = '1' report "6: One_Place_Left not correct" severity error;  

  -- 7 other shit
--   ReadFifo (2);
--   WriteToFifo (52, 1); 
--   ReadFifo (2);

--   WriteToFifo (14, 1);
--   WriteToFifo (15, 1);
--   WriteToFifo (16, 1);

--   WriteToFifo (17, 1);
--   ReadFifo (1);
--   ReadFifo (1);
--   ReadFifo (4);

--   WriteAndReadFifo (67,2);
--   wait for 5*PERIOD;
--   ReadFifo (1);
  
  -- Test completed
  Test_Phase <= 0;
  wait;
end process Generate_input;



Read_Data_from_fifo : process (Clk, Rst_n)
begin  -- process Read_Data_from_fifo
  if Rst_n = '0' then                   -- asynchronous reset (active low)
    Read_Data <= (others => '0');
  elsif Clk'event and Clk = '1' then    -- rising clock edge
    if Read_Enable = '1' then
      Read_Data <= Data_Out;
    else
      Read_Data <= Read_Data;
    end if;
  end if;
end process Read_Data_from_fifo;


    
  
 CLOCK1: process -- generate clock signal for design
   variable clktmp: std_logic := '0';
 begin
   wait for PERIOD/2;
   clktmp := not clktmp;
   Clk <= clktmp; 
 end process CLOCK1;

 RESET: process
 begin   
   Rst_n <= '0';        -- Reset the testsystem
   wait for 6*PERIOD; -- Wait 
   Rst_n <= '1';        -- de-assert reset
   wait;
 end process RESET;


  
end behavioral;





configuration basic_cfg of tb_fifo1 is
  
  for behavioral    
    for all : fifo
      --use entity work.fifo (inout_mux);
      use entity work.fifo (in_mux);
      --use entity work.fifo (shift_reg);
    end for;

  end for;


end basic_cfg;
