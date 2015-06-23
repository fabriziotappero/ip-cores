library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.ahb_package.all;
use work.ahb_funct.all;
use work.ahb_configure.all;

package ahb_components is

component fifo
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
end component;

component ahb_master
generic (
 fifohempty_level: in integer;
 fifohfull_level: in integer;
 fifo_length: in integer);
port (
  hresetn: in std_logic;
  hclk: in std_logic;
  mst_in: in mst_in_t;
  mst_out: out mst_out_t;
  dma_start: in start_type_t;	   
  m_wrap_out: out wrap_out_t;
  m_wrap_in: in wrap_in_t;   
  slv_running: in std_logic;
  mst_running: out std_logic;
  eot_int: out std_logic);
end component;

component ahb_arbiter
  generic(
    num_arb: in integer;
    num_arb_msts: in integer range 1 to 15;
    def_arb_mst: in integer range 0 to 15;
    num_slvs: in integer range 1 to 15;
    alg_number: in integer range 0 to 5);
  port(
    hresetn: in std_logic;
    hclk: in std_logic;
    remap: in std_logic;
    mst_in_v: in mst_out_v_t(num_arb_msts-1 downto 0);
    mst_out_v: out mst_in_v_t(num_arb_msts-1 downto 0);   
    slv_out_v: out slv_in_v_t(num_slvs-1 downto 0);
    slv_in_v: in slv_out_v_t(num_slvs-1 downto 0));
end component;

component ahb_slave_wait
  generic (
    num_slv: in integer range 0 to 15:= 1;
    fifohempty_level: in integer:= 2;
    fifohfull_level: in integer:= 5;
    fifo_length: in integer:= 8);
  port(
    hresetn: in std_logic;
    hclk: in std_logic;
	remap: in std_logic;
    slv_in: in slv_in_t;    
    slv_out: out slv_out_t;
    mst_running: in std_logic;
    prior_in: in std_logic;
    slv_running: out std_logic;
    slv_err: out std_logic;
    s_wrap_out: out wrap_out_t;
    s_wrap_in: in wrap_in_t);
end component;

component mst_wrap
generic (
--synopsys translate_off
dump_file: in string:= "mst_wrap.log";
dump_type: in integer;
--synopsys translate_on
ahb_max_addr: in integer:= 4;
m_const_lat_write: in integer;
m_const_lat_read: in integer;
m_write_burst: in integer;
m_read_burst: in integer);
port (
  hresetn: in std_logic;
  clk: in std_logic;
  conf: in conf_type_t;
  dma_start: out start_type_t;
  m_wrap_in: in wrap_out_t;
  m_wrap_out: out wrap_in_t);
end component;

component slv_mem
generic (
--synopsys translate_off
dump_file: in string:= "slv_wrap.log";
dump_type: in integer;
--synopsys translate_on
ahb_max_addr: in integer:= 8;
s_const_lat_write: in integer;
s_const_lat_read: in integer;
s_write_burst: in integer;
s_read_burst: in integer);
port (
  hresetn: in std_logic;
  clk: in std_logic;
  conf: in conf_type_t;
  dma_start: out start_type_t;
  s_wrap_in: in wrap_out_t;
  s_wrap_out: out wrap_in_t
  );
end component;

component uut_stimulator
generic (
stim_type: in uut_params_t;
enable: in integer;
eot_enable: in integer);
port(
  hclk : in std_logic;
  hresetn : in std_logic;
  amba_error: in std_logic;  
  eot_int: in std_logic;  
  conf: out conf_type_t;
  sim_end: out std_logic);
end component;

end;

package body ahb_components is
end;



