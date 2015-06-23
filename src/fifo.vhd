library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;

use work.ahb_funct.all;
use work.ahb_package.all;

entity fifo is
generic (
  fifohempty_level: in integer:= 1;
  fifohfull_level: in integer:= 3;
  fifo_length: in integer:= 4);
port (
  hresetn: in std_logic;
  clk: in std_logic;
  fifo_reset: in std_logic;
  fifo_write: in std_logic;
  fifo_read: in std_logic;
  fifo_count: out std_logic_vector(nb_bits(fifo_length)-1 downto 0);
  fifo_full: out std_logic;
  fifo_hfull: out std_logic;
  fifo_empty: out std_logic;
  fifo_hempty: out std_logic;
  fifo_datain: in std_logic_vector(31 downto 0);
  fifo_dataout: out std_logic_vector(31 downto 0)
  );
end fifo;

architecture rtl of fifo is



signal fifo_full_s, fifo_empty_s: std_logic;
signal fifo_count_s : std_logic_vector(nb_bits(fifo_length)-1 downto 0);--log2 fifo_length + 1
signal rptr, wptr: std_logic_vector(nb_bits(fifo_length)-1 downto 0);
type vect_fifo_32 is array (fifo_length-1 downto 0) of std_logic_vector (31 downto 0);
signal fifo : vect_fifo_32;


begin
	
fifo_wr_pr:process(clk, hresetn)
begin
  if hresetn='0' then
    wptr <= (others => '0');
  elsif clk'event and clk='1' then    
    if fifo_reset='1' then
      wptr <= (others => '0') after 1 ns;
    elsif (fifo_write='1') then
      fifo(conv_integer(wptr(wptr'length-2 downto 0))) <= fifo_datain after 1 ns;
      wptr <= wptr+1 after 1 ns;
    end if;
  end if;
end process;			  
  
fifo_rd_pr:process(clk, hresetn)
begin
  if hresetn='0' then
    rptr <= (others => '0');
  elsif clk'event and clk='1' then    
    if fifo_reset='1' then
      rptr <= (others => '0') after 1 ns;
    elsif (fifo_read='1') then
      rptr <= rptr+1 after 1 ns;
    end if;
  end if;
end process;
  
  
fifo_dataout <= fifo(conv_integer(rptr(rptr'length-2 downto 0)));--data from fifo visible 

fifo_count_s <= wptr(wptr'length-1 downto 0) - rptr(rptr'length-1 downto 0);
	
fifo_full_s	<= '1' when (fifo_count_s=fifo_length) else '0';--same value,/=msb
fifo_empty_s <= '1' when (fifo_count_s=0) else '0';--same value,==msb

fifo_hfull <= '1' when (fifo_count_s>=fifohfull_level) else '0';
fifo_hempty <= '1' when (fifo_count_s<=fifohempty_level) else '0';				
fifo_full <= fifo_full_s;
fifo_empty <= fifo_empty_s;
fifo_count <= fifo_count_s;

end rtl;
