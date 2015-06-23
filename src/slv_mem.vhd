library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;

use std.textio.all;

use work.ahb_package.all;

entity slv_mem is
generic (
--synopsys translate_off
dump_file: in string:= "slv_wrap.log";
dump_type: in integer:= dump_no;
--synopsys translate_on
ahb_max_addr: in integer:= 8;
--***************************************************************
--parameters for slave access
--***************************************************************
s_const_lat_write: in integer:= 1;--1 cycle to save data
s_const_lat_read: in integer:= 2;--2 cycles to retreave data
s_write_burst: in integer := no_burst_support;--slave doesn't accept bursts in write!!!
s_read_burst: in integer:= no_burst_support--slave doesn't accept bursts in read!!!
	);
port (
  hresetn: in std_logic;
  clk: in std_logic;
  conf: in conf_type_t;
  dma_start: out start_type_t;
  s_wrap_in: in wrap_out_t;
  s_wrap_out: out wrap_in_t);
end slv_mem;

architecture rtl of slv_mem is

--synopsys translate_off
--***************************************************************
--**** DUMP OF MEMORY *******************************************
--***************************************************************
file file_descriptor : TEXT open write_mode is dump_file;
constant msg1: string(1 to 4):=	"MEM ";
constant msg2: string(1 to 4):= "REG ";
constant msg3: string(1 to 5):= "DATA ";
			
procedure Write_Message(msg1:string; addr:in integer; msg2:string; value:in integer) is
variable STR : line;
  begin
    write(STR,now);
    write(STR,STRING'(" "));	 
    write (STR, msg1);
    write (STR, addr);
    write(STR,STRING'(" "));	 
    write (STR, msg2);
    write (STR, value);
    writeLine(file_descriptor, STR);
    writeLine(OUTPUT, STR);
end Write_Message;
--***************************************************************
--***************************************************************
--synopsys translate_on

--***************************************************************
--configuration registers 
--***************************************************************
signal start_hprot: std_logic_vector(3 downto 0);
signal start_hsize: std_logic_Vector(2 downto 0);
signal start_hburst: std_logic_Vector(2 downto 0);
signal start_hwrite: std_logic;
signal start_hlocked: std_logic;
signal start_prior: std_logic;
signal hsize_reg: std_logic_Vector(2 downto 0);
signal priority_reg: std_logic;
signal hburst_reg: std_logic_Vector(2 downto 0);
signal hprot_reg: std_logic_Vector(3 downto 0);
signal hlock_reg: std_logic;
signal trx_dir_reg: std_logic;
signal extaddr: std_logic_Vector(31 downto 0);
signal intaddr: std_logic_Vector(15 downto 0);
signal intmod: std_logic_Vector(15 downto 0);
signal count_reg: std_logic_Vector(15 downto 0);
signal dma_go: std_logic;
--***************************************************************
--***************************************************************

type vect_32 is array (2**ahb_max_addr-1 downto 0) of std_logic_vector (31 downto 0);
signal mem : vect_32;



signal s_lat_write_ok, s_lat_read_ok: std_logic;
signal s_lat_write: integer range 0 to s_const_lat_write;
signal s_lat_read: integer range 0 to s_const_lat_read;
--***************************************************************
--***************************************************************


begin
 

--***************************************************************
--***************************************************************
--** slave part: could be a memory, fifo or register bank *******
--** here it's only a configuration register bank ***************
--***************************************************************

process(clk, hresetn)
begin
  if hresetn='0' then
    for i in 0 to 2**ahb_max_addr-1 loop
      mem(i) <= conv_std_logic_vector(i, 32);	
    end loop;--i
  elsif clk'event and clk='1' then
    if (s_wrap_in.take='1' and s_lat_write_ok='1') then
      mem(conv_integer(s_wrap_in.addr(ahb_max_addr-1+2 downto 2))) <= s_wrap_in.wdata after 1 ns;
--synopsys translate_off
if dump_type/=dump_no then Write_Message(msg1, conv_integer(s_wrap_in.addr(ahb_max_addr-1+2 downto 2)), msg3, conv_integer(s_wrap_in.wdata)); end if;
--synopsys translate_on
    end if;
  end if;
end process;

s_wrap_out.rdata <= mem(conv_integer(s_wrap_in.addr(ahb_max_addr-1+2 downto 2))) when (s_wrap_in.ask='1' and s_lat_read_ok='1') else (others => '-');


process(clk, hresetn)
begin
  if hresetn='0' then
    s_lat_write <= s_const_lat_write;
  elsif clk'event and clk='1' then
    if (s_wrap_in.take='1') then
      if (s_lat_write_ok='0') then
        s_lat_write <= s_lat_write-1 after 1 ns;
      elsif (s_write_burst=1) then--accepts bursts .....
        s_lat_write <= 0 after 1 ns;
      else
        s_lat_write <= s_const_lat_write after 1 ns;
      end if;
    else
      s_lat_write <= s_const_lat_write after 1 ns;
    end if;
  end if;
end process;

s_lat_write_ok <= '1' when (s_lat_write=0) else '0';
s_wrap_out.take_ok <= '1' when (s_wrap_in.take='1' and s_lat_write_ok='1') else '0';  
	
process(clk, hresetn)
begin
  if hresetn='0' then
    s_lat_read <= s_const_lat_read;
  elsif clk'event and clk='1' then
    if (s_wrap_in.ask='1') then
      if (s_lat_read_ok='0') then
        s_lat_read <= s_lat_read-1  after 1 ns;
      elsif (s_read_burst=1) then--accepts bursts .....
        s_lat_read <= 0  after 1 ns;
      else
        s_lat_read <= s_const_lat_read  after 1 ns;
      end if;
    else
      s_lat_read <= s_const_lat_read after 1 ns;
    end if;
  end if;
end process;

s_lat_read_ok <= '1' when (s_lat_read=0) else '0';
s_wrap_out.ask_ok <= '1' when (s_wrap_in.ask='1' and s_lat_read_ok='1') else '0';

--**************************************************************************
-- configuration registers write
--**************************************************************************

conf_reg_pr:process(hresetn, clk)
variable addr: std_logic_Vector(3 downto 0);
begin
if hresetn='0' then
  hsize_reg <= bits32;
  priority_reg <= slave;
  hburst_reg <= incr;
  hprot_reg <= "0011";
  trx_dir_reg <= '0';
  hlock_reg <= locked;
  extaddr <= zeroes;
  intaddr <= zeroes(15 downto 0);
  intmod <= conv_std_logic_vector(4, intmod'length);--mod=+4(+1 word32)
  count_reg <= zeroes(15 downto 0);
  dma_go <= '0';
elsif clk'event and clk='1' then
  if (conf.write='1') then
    case conf.addr is
      when dma_extadd_addr =>
        extaddr <= conf.wdata;
      when dma_intadd_addr =>
        intaddr <= conf.wdata(15 downto 0);
      when dma_intmod_addr =>
        intmod <= conf.wdata(15 downto 0);
      when dma_type_addr =>
        priority_reg <= conf.wdata(12);
        hsize_reg <= conf.wdata(11 downto 9);
        hburst_reg <= conf.wdata(8 downto 6);
        hprot_reg <= conf.wdata(5 downto 2);
        trx_dir_reg <= conf.wdata(1);
        hlock_reg <= conf.wdata(0);
      when dma_count_addr => 
        count_reg <= conf.wdata(15 downto 0);	
      when others => null;
    end case;
  end if;
  if (conf.write='1' and conf.addr=dma_count_addr) then
    dma_go <= '1';
  else
    dma_go <= '0';
  end if;
end if;
end process;
--**************************************************************************
--**************************************************************************

--**************************************************************************
--**************************************************************************
  dma_start.extaddr <= extaddr;
  dma_start.intaddr <= intaddr;
  dma_start.intmod <= intmod;
  dma_start.hparams <= "000"&priority_reg&hsize_reg&hburst_reg&hprot_reg&trx_dir_reg&hlock_reg;
  dma_start.count <= count_reg;
  dma_start.start <= dma_go;

end rtl;
