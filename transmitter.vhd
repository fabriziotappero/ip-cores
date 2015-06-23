-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica       
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     File name      : transmitter.vhd 
--
--     Description    : Tag transmitter.
--                      Currently is reduced to simple Parallel-Serial
--                      converter.
--
--     Author         : Erwing R. Sanchez Sanchez <erwing.sanchez@polito.it>
--            
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;
library work;
use work.epc_tag.all;

entity transmitter is
  
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    trm_cmd : in  std_logic_vector(2 downto 0);
    trm_buf : in  std_logic_vector(15 downto 0);
    tdo     : out std_logic);

end transmitter;


architecture trans of transmitter is

  constant buffer_depth : integer := 3;

  type   BuffBlock_t is array (buffer_depth-1 downto 0) of std_logic_vector(15 downto 0);
  signal buffblock : BuffBlock_t;
  signal sendflag  : std_logic_vector(buffer_depth-1 downto 0);

  signal buffout_busy : std_logic;
  signal buffout      : std_logic_vector(15 downto 0);

  signal counter : std_logic_vector(3 downto 0);
  
begin  -- trans

  buffer_shift : process (clk, rst_n)
  begin  -- process serial_conv
    if rst_n = '0' then                 -- asynchronous reset (active low)
      sendflag <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if trm_cmd /= trmcmd_Null then
        buffblock(buffer_depth-2 downto 0) <= buffblock(buffer_depth-1 downto 1);
        sendflag(buffer_depth-2 downto 0)  <= sendflag(buffer_depth-1 downto 1);
        buffblock(buffer_depth-1)          <= trm_buf;
        sendflag(buffer_depth-1)           <= '1';
      elsif buffout_busy = '0' then
        buffblock(buffer_depth-2 downto 0) <= buffblock(buffer_depth-1 downto 1);
        sendflag(buffer_depth-2 downto 0)  <= sendflag(buffer_depth-1 downto 1);
        buffblock(buffer_depth-1)          <= (others => '0');
        sendflag(buffer_depth-1)           <= '0';
      end if;
    end if;
  end process buffer_shift;


  buffout_shift : process (clk, rst_n)
  begin  -- process buffout_shift
    if rst_n = '0' then                 -- asynchronous reset (active low)
      buffout      <= (others => '0');
      buffout_busy <= '0';
      counter      <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if buffout_busy = '1' then
        if counter = X"F" then
          counter      <= (others => '0');
          buffout_busy <= '0';
        else
          counter <= counter + '1';
        end if;
        buffout(14 downto 0) <= buffout(15 downto 1);
        buffout(15)          <= '0';
      elsif sendflag(0) = '1' then
        buffout      <= buffblock(0);
        buffout_busy <= '1';
      end if;
    end if;
  end process buffout_shift;


  tdo <= buffout(0);
  

end trans;
