library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;

use std.textio.all;

use work.ahb_package.all;

entity mst_wrap is
generic (
--synopsys translate_off
dump_file: in string:= "mst_wrap.log";
dump_type: in integer:= dump_no;
--synopsys translate_on
ahb_max_addr: in integer:= 4;
--***************************************************************
--parameters for master access
--***************************************************************
m_const_lat_write: in integer:= 0;--0 latency states in write
m_const_lat_read: in integer:= 2;--2 cycles to get first data
m_write_burst: in integer := burst_support;--master accepts bursts in write!!!
m_read_burst: in integer := burst_support--master accepts bursts in read!!!
);
port (
  hresetn: in std_logic;
  clk: in std_logic;
  conf: in conf_type_t;
  dma_start: out start_type_t;
  m_wrap_in: in wrap_out_t;
  m_wrap_out: out wrap_in_t);
end mst_wrap;

architecture rtl of mst_wrap is


--synopsys translate_off
--***************************************************************
--**** DUMP OF MEMORY *******************************************
--***************************************************************
file file_descriptor : TEXT open WRITE_MODE is dump_file;

constant msg1: string(1 to 4):=	"MEM ";
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
signal hsize_reg: std_logic_Vector(2 downto 0);
signal priority_reg: std_logic;
signal hburst_reg: std_logic_Vector(2 downto 0);
signal hprot_reg: std_logic_Vector(3 downto 0);
signal trx_dir_reg: std_logic;
signal hlock_reg: std_logic;
signal extaddr: std_logic_Vector(31 downto 0);
signal intaddr: std_logic_Vector(15 downto 0);
signal intmod: std_logic_Vector(15 downto 0);
signal count_reg: std_logic_Vector(15 downto 0);
signal dma_go: std_logic;
--***************************************************************
--***************************************************************

type vect_32 is array (2**ahb_max_addr-1 downto 0) of std_logic_vector (31 downto 0);
signal mem : vect_32;


signal m_lat_write_ok, m_lat_read_ok: std_logic;
signal m_lat_write: integer range 0 to m_const_lat_write;
signal m_lat_read: integer range 0 to m_const_lat_read;
--***************************************************************
--***************************************************************


begin
 
	
--***************************************************************
--***************************************************************
--***************** master part *********************************
--***************************************************************
process(clk, hresetn)
begin
  if hresetn='0' then
    m_lat_write <= m_const_lat_write;
  elsif clk'event and clk='1' then
    if (m_wrap_in.take='1') then
      if (m_lat_write_ok='0') then
        m_lat_write <= m_lat_write-1 after 1 ns;
      elsif (m_write_burst=1) then--accepts bursts .....
        m_lat_write <= 0 after 1 ns;
      else
        m_lat_write <= m_const_lat_write after 1 ns;
      end if;	
    else
      m_lat_write <= m_const_lat_write after 1 ns;
    end if;	  
  end if;
end process;

m_lat_write_ok <= '1' when (m_lat_write=0) else '0';
m_wrap_out.take_ok <= '1' when (m_wrap_in.take='1' and m_lat_write_ok='1') else '0';
	
process(clk, hresetn)
begin
  if hresetn='0' then
    for i in 0 to 2**ahb_max_addr-1 loop
      mem(i) <= conv_std_logic_vector(i, 32);	
    end loop;--i
  elsif clk'event and clk='1' then
    if (m_wrap_in.take='1' and m_lat_write_ok='1') then
      mem(conv_integer(m_wrap_in.addr(2+ahb_max_addr-1 downto 2))) <= m_wrap_in.wdata after 1 ns;
--synopsys translate_off
if dump_type/=dump_no then Write_Message(msg1, conv_integer(m_wrap_in.addr(2+ahb_max_addr-1 downto 2)), msg3, conv_integer(m_wrap_in.wdata)); end if;
--synopsys translate_on
    end if;
  end if;
end process;

m_wrap_out.rdata <= mem(conv_integer(m_wrap_in.addr(2+ahb_max_addr-1 downto 2))) when (m_wrap_in.ask='1' and m_lat_read_ok='1') else (others => '-');
  
  
process(clk, hresetn)
begin
  if hresetn='0' then
    m_lat_read <= m_const_lat_read;
  elsif clk'event and clk='1' then
    if (m_wrap_in.ask='1') then
      if (m_lat_read_ok='0') then
	    m_lat_read <= m_lat_read-1  after 1 ns;
      elsif (m_read_burst=1) then--accepts bursts .....
	    m_lat_read <= 0  after 1 ns;
      else
	    m_lat_read <= m_const_lat_read  after 1 ns;
      end if;	
    else
      m_lat_read <= m_const_lat_read after 1 ns;
    end if;
  end if;
end process;

m_lat_read_ok <= '1' when (m_lat_read=0) else '0';
m_wrap_out.ask_ok <= '1' when (m_wrap_in.ask='1' and m_lat_read_ok='1') else '0';




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
