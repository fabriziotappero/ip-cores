-------------------------------------------------------------------------------
-- File        : tb_fifo2.vhdl
-- Description : Testbench for a Fifo buffer
-- Author      : Erno Salminen
-- Date        : 29.04.2002
-- Modified    : 02.05.2002 Vesa Lahtinen More tests added
--               18.06.2003 AK - direction for Rst_n signal
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tb_fifo2 is
end tb_fifo2;

architecture behavioral of tb_fifo2 is

component fifo

  generic (
    width : integer := 0;
    depth : integer := 0
    );

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


end component;


constant width  : integer := 16;
constant depth  : integer := 5;
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

signal Read_Data  : std_logic_vector (width-1 downto 0);
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
    Data_In <= conv_std_logic_vector (Data_To_Fifo, width);
    Write_Enable <= '1';
    if Full = '1' then
      --assert false report "Fifo full. Cannot write" severity note;
    end if;
    wait for PERIOD;
    --if wait_time > 0 then      
      Write_Enable <= '0';
      Data_In      <= (others => 'Z');
      wait for (wait_time)* PERIOD;
    --end if;

  end WriteToFifo;


  procedure ReadFifo (
    wait_time : in integer) is
  begin  --procedure
    Read_Enable <= '1';
    if Empty = '1' then
      --assert false report "Fifo empty. Cannot read" severity note;
    end if;
    wait for PERIOD;
    --if wait_time > 0 then      
      Read_Enable  <= '0';
      wait for (wait_time)* PERIOD;
    --end if;


  end ReadFifo;

  
  procedure WriteAndReadFifo (
    Data_To_Fifo : in integer;
    wait_time : in integer) is
  begin  --procedure
    Read_Enable <= '1';
    if Empty = '1' then
      --assert false report "Fifo empty. Cannot read" severity note;
    end if;
    Data_In <= conv_std_logic_vector (Data_To_Fifo, width);
    Write_Enable <= '1';
    if Full = '0' then
      --assert false report "Fifo full. Cannot write" severity note;
    end if;


    wait for PERIOD;
    --if wait_time > 0 then      
      Read_Enable  <= '0';
      Write_Enable <= '0';
      Data_In      <= (others => 'Z');
      wait for (wait_time)* PERIOD;
    --end if;


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

  -- Wait for reset
  Write_Enable <= '0';
  Read_Enable  <= '0';
  Data_In      <= (others => 'Z');
  Test_Phase   <= 0;
  wait for (6+2)*PERIOD;
  wait for PERIOD/2;
  wait for PERIOD/3;

  -- 0) At the beginning
  -- One_Place_Left = 0
  -- Empty          = 1
  -- Full           = 0
  -- One_Data_Left  = 0
  assert One_Data_Left = '0' report "0: One_Place_Left does not work" severity error;
  assert Empty         = '1' report "0: Empty does not work"          severity error;
  assert Full          = '0' report "0: Full does not work"           severity error;
  assert One_Data_Left = '0' report "0: One_Place_Left does not work" severity error;

  -- 1) Write one data to empty fifo
  -- Data_Out = 5
  -- One_Data_Left = 1
  -- Empty = 0
  Test_Phase   <= Test_Phase +1;
  WriteToFifo (5, 1);
  assert Data_Out = conv_std_logic_vector (5, width) report "1: data not stored correctly" severity error;
  assert One_Data_Left = '1' report "1: One_Place_Left does not work" severity error;
  assert Empty         = '0' report "1: Empty does not work"          severity error;

  ReadFifo (2);
  WriteToFifo (52, 1); 
  ReadFifo (2);

  -- 2) Fill up the empty fifo until there is only one place left
  -- One_Place_Left = 1
  -- Full = 0   
  Test_Phase   <= Test_Phase +1;
  WriteToFifo (10, 1);                  --to empty fifo
  assert Data_Out = conv_std_logic_vector (10, width) report "2: data not stored correctly" severity error;  
  WriteToFifo (11, 0);
  WriteToFifo (12, 0);
  WriteToFifo (13, 0);
  assert One_Place_Left = '1' report "2: One_Place_Left does not work" severity error;    
  assert Full           = '0' report "2: Full does not work"          severity error;

  --3) One data more => fifo becomes full
  --  Try to write two data (15 & 16) to full fifo
  -- One_Place_Left = 0
  -- Full = 1  
  Test_Phase   <= Test_Phase +1;
  WriteToFifo (14, 0);
  assert One_Place_Left = '0' report "3: One_Place_Left does not work" severity error;    
  assert Full           = '1' report "3: Full does not work"          severity error;      

  WriteToFifo (15, 0);
  WriteToFifo (16, 0);
  Write_Enable <= '0';
  Data_In      <= (others => 'Z');

  -- 4) Read one data from full fifo   
  Test_Phase   <= Test_Phase +1;
  ReadFifo (1);  -- fifo out: 10 => 11
  assert One_Place_Left = '1' report "4: One_Place_Left does not work" severity error;    
  assert Full           = '0' report "4: Full does not work"           severity error;      
  assert Data_Out = conv_std_logic_vector (11, width) report "4: data not stored correctly" severity error;
  
  ReadFifo (1); -- fifo out: 11 => 12
  ReadFifo (1); -- fifo out: 12 => 13
  WriteToFifo (17, 1);
  ReadFifo (1); -- fifo out: 13 => 14
  ReadFifo (1); -- fifo out: 14 => 17

  -- 5) Read the last data
  -- write one to empty fifo and read empty fifo at the same time
  Test_Phase   <= Test_Phase +1;
  assert Data_Out = conv_std_logic_vector (17, width) report "5: data not stored correctly" severity error;  
  ReadFifo (4); -- fifo out: 14 => empty (11)
  WriteAndReadFifo (67,2);
  wait for 5*PERIOD;
  ReadFifo (1);-- fifo out: 67 => empty 

  -- 6) Fill up the fifo with two (1 & 2) data
  -- Start reading fifo at the same as the latter data (2) is written
  Test_Phase   <= Test_Phase +1;
  WriteToFifo (1, 0);
  WriteAndReadFifo (2,0);
  assert Data_Out = conv_std_logic_vector (2, width) report "6: data not stored correctly" severity error;

  -- 7) Fill up the fifo
  Test_Phase   <= Test_Phase +1;
  WriteToFifo (3, 0);
  WriteToFifo (4, 0);
  WriteToFifo (5, 0);
  WriteToFifo (6, 0);
  Write_Enable <= '0';
  Data_In      <= (others => 'Z');
  -- Fifo now full
  assert Full = '1' report "8: Full does not work" severity error;      
  
  -- 8) Empty the fifo
  -- At first try to write one data (88) to full fifo and read fifo at the same
  -- time. Data 88 should not go to fifo
  Test_Phase   <= Test_Phase +1;
  WriteAndReadFifo(88,0);
  ReadFifo(0);
  ReadFifo(0);
  ReadFifo(0);
  ReadFifo(0);
  assert Data_Out /= conv_std_logic_vector (88, width) report "8: data not stored correctly" severity error;

  -- 9) Fifo should be empty
  Test_Phase   <= 9;
  assert Empty = '1' report "9: Empty does not work" severity error;        

  -- Test completd
  Test_Phase <= 0;
  wait;
end process Generate_input;



Read_Data_from_fifo : process (Clk, Rst_n)
begin  -- process Read_Data_from_fifo
  if Rst_n = '0' then                   -- asynchronous reset (active low)
    Read_Data <= (others => '0');
  elsif Clk'event and Clk = '1' then    -- rising clock edge
    if Read_Enable = '1' and Empty = '0'then
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


configuration basic_cfg of tb_fifo2 is
  
  for behavioral    
    for all : fifo
      --use entity work.fifo (inout_mux);
      --use entity work.fifo (in_mux);
      use entity work.fifo (shift_reg);
    end for;

  end for;

end basic_cfg;
