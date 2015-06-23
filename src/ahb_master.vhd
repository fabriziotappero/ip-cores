
--*******************************************************************
--**                                                             ****
--**  AHB system generator                                       ****
--**                                                             ****
--**  Author: Federico Aglietti                                  ****
--**          federico.aglietti\@opencores.org                   ****
--**                                                             ****
--*******************************************************************
--**                                                             ****
--** Copyright (C) 2004 Federico Aglietti                        ****
--**                    federico.aglietti\@opencores.org         ****
--**                                                             ****
--** This source file may be used and distributed without        ****
--** restriction provided that this copyright statement is not   ****
--** removed from the file and that any derivative work contains ****
--** the original copyright notice and the associated disclaimer.****
--**                                                             ****
--**     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ****
--** EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ****
--** TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ****
--** FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ****
--** OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ****
--** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ****
--** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ****
--** GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ****
--** BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ****
--** LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ****
--** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ****
--** OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ****
--** POSSIBILITY OF SUCH DAMAGE.                                 ****
--**                                                             ****
--*******************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;

use work.ahb_funct.all;
use work.ahb_package.all;

entity ahb_master is
generic (
  fifohempty_level: in integer:= 2;
  fifohfull_level: in integer:= 6;
  fifo_length: in integer:= 8);
port (
  --***********************************************
  --master ahb amba signals
  --***********************************************	 
  hresetn: in std_logic;
  hclk: in std_logic;
  mst_in: in mst_in_t;
  mst_out: out mst_out_t;
 
  --***********************************************
  --master<=>core interface: conf registers
  --***********************************************
  dma_start: in start_type_t;	   
 
  --***********************************************
  --master<=>core interface: program/data memories 
  --***********************************************
  m_wrap_out: out wrap_out_t;
  m_wrap_in: in wrap_in_t;   

   --***********************************************
  --master/slave/core signals
  --***********************************************
  slv_running: in std_logic;
  mst_running: out std_logic;
  eot_int: out std_logic
  );
end ahb_master;

architecture rtl of ahb_master is

--***************************************************************
--component declaration 
--***************************************************************
component fifo
generic (
  fifohempty_level: in integer:= 1;
  fifohfull_level: in integer:= 7;
  fifo_length: in integer:= 8);
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


 
--***************************************************************
--configuration registers 
--***************************************************************
signal start_hprot: std_logic_vector(3 downto 0);
signal start_hsize: std_logic_Vector(2 downto 0);
signal start_hburst: std_logic_Vector(2 downto 0);
signal start_hwrite: std_logic;
signal start_hlocked: std_logic;
signal start_prior: std_logic;

signal hbusreq_t, hlock_t: std_logic;
--***************************************************************
--***************************************************************
signal r_mst_in, s_mst_in: mst_in_t;
signal r_mst_out, s_mst_out: mst_out_t;


type master_fsm is (
  idle_phase,
  wait_phase,   
  req_phase,
  addr,     --A
  addr_data,--A+D
  data,	    --D
  retry_phase, 
  error_phase,
  be_phase);
signal mst_state, s_mst_state: master_fsm;


signal fifo_full, fifo_hfull, fifo_empty, fifo_hempty: std_logic;
signal fifo_count: std_logic_vector(nb_bits(fifo_length)-1 downto 0);  
signal fifo_datain, fifo_dataout: std_logic_vector (31 downto 0);
signal fifo_hread, fifo_hwrite: std_logic;
signal fifo_read, fifo_write: std_logic;
signal fifo_reset: std_logic;
signal next_fifo_empty: std_logic;

signal dma_count: std_logic_vector (15 downto 0);
signal dma_count_s : std_logic_vector (15 downto 0);
signal right_count: std_logic_vector(15 downto 0);
signal data_trx: std_logic;  
signal tmp_htrans: std_logic_vector(1 downto 0);


signal next_fifo_full: std_logic;
signal next_fifo_he: std_logic;
signal next_fifo_hf: std_logic;

signal mst_running_t:std_logic;
signal dma_restart: std_logic;
signal mst_req: std_logic;
signal granted: std_logic;

signal eot_int_reg:std_logic;
signal prior_reg, prior_s: std_logic;

signal int_addr, int_addr_s, int_addr_t : std_logic_vector (31 downto 0);
signal int_mod, int_mod_s : std_logic_vector (15 downto 0);
signal int_page_fault: std_logic;
signal int_addr_incr: std_logic;

signal page_attention: std_logic;
signal page_fault: std_logic;
signal pf_incr, pf_wrap4, pf_wrap8, pf_wrap16: std_logic;

signal haddr_t : std_logic_vector (31 downto 0);
signal haddr_incr: std_logic;

signal old_page_attention: std_logic;
signal old_addr_incr: std_logic;
signal old_addr, old_addr_s: std_logic_vector (31 downto 0);
signal old_hburst, old_hburst_s: std_logic_Vector(2 downto 0);

begin

--***************************************************************
--component instantiation 
--***************************************************************
fifo_inst: fifo
generic map(
  fifohempty_level => fifohempty_level,
  fifohfull_level => fifohfull_level,
  fifo_length => fifo_length)
port map(
  hresetn => hresetn,
  clk => hclk,
  fifo_reset =>	fifo_reset,
  fifo_write =>	fifo_write,
  fifo_read => fifo_read,
  fifo_count => fifo_count,
  fifo_full => fifo_full,
  fifo_hfull => fifo_hfull,
  fifo_empty => fifo_empty,
  fifo_hempty => fifo_hempty,
  fifo_datain => fifo_datain,
  fifo_dataout => fifo_dataout
  );
	
	
--***************************
--****** master state *******
--***************************	
master_pr:process(
mst_state,
mst_req,
slv_running,
prior_reg,
dma_count,
hbusreq_t,
fifo_empty,
page_fault,
r_mst_out,
mst_in
)
begin
  s_mst_state <= mst_state;	
  case mst_state is
    when idle_phase =>
      if (dma_count>0 and (slv_running='0' or prior_reg=master)) then
        s_mst_state <= wait_phase;
      end if;
    when wait_phase =>
      if mst_req='1' then
        s_mst_state <= req_phase;	
      end if;	
    when req_phase =>
      if (hbusreq_t='1' and mst_in.hgrant='1' and mst_in.hready='1') then--master take bus ownership
        s_mst_state <= addr;
      end if;
    when addr =>
      if (mst_in.hready='1') then
        if (page_fault='1' or mst_in.hgrant='0' or dma_count=1) then
          s_mst_state <= data;
        else
          s_mst_state <= addr_data;
        end if;
      end if;
    when addr_data =>
      --end of transfer: ready+ok+no_busy_reg+count=1(idle/preidle or burstend)
      --page fault:ready+ok+no_busy_reg+count>1	(page_fault)
      --no_grant:ready+ok+busy+no_grant (page_fault)
      --retry/split:no_ready+retry/split (retry)
      --error:no_ready+error (error)
      if (mst_in.hready='1') then
        if (mst_in.hresp=ok_resp) then 
          if (r_mst_out.htrans/=busy) then	
            if (dma_count=1) then
              if (r_mst_out.hwrite='1') then
                s_mst_state <= data;
              else --r_mst_out.hwrite='0', count>1
                s_mst_state <= data;--be_phase;
              end if; 
            elsif (page_fault='1' or mst_in.hgrant='0') then
              s_mst_state <= data;
            end if;
          else -- r_mst_out.htrans=busy
            if (mst_in.hgrant='0') then
	      assert false report "Protocol error: GRANT deasserted during BUSY!!!" severity error;
              s_mst_state <= data;
            end if;
          end if;
        end if;
      else--hready='0'	  
        case mst_in.hresp is
          when retry_resp|split_resp =>
            s_mst_state <= retry_phase;
          when error_resp =>
            s_mst_state <= error_phase;
          when others =>
            s_mst_state <= addr_data;
        end case;
      end if;
    when data=>
      if (mst_in.hready='1') then
        if (mst_in.hresp=ok_resp and r_mst_out.htrans/=busy) then
          if (dma_count=0) then
            if (r_mst_out.hwrite='1') then
              s_mst_state <= idle_phase;
            else --r_mst_out.hwrite='0', count>1
              s_mst_state <= be_phase;
            end if;
          else--collapse all this 'if-else'
            if (r_mst_out.hwrite='1') then
              s_mst_state <= idle_phase;
            else
              s_mst_state <= be_phase;
            end if;
          end if;				  
        end if;
      else	  
        case mst_in.hresp is
          when retry_resp|split_resp =>
            s_mst_state <= retry_phase;--pay attention: grant removed and retry issued!!!!!!
          when error_resp =>
            s_mst_state <= error_phase;
          when others =>
            s_mst_state <= data;
        end case;
      end if;	  
    when retry_phase =>
      if (mst_in.hready='1') then
          s_mst_state <= idle_phase;
      end if;
    when error_phase =>
      if mst_in.hready='1' then
        s_mst_state <= idle_phase;
      end if;
    when be_phase =>--one of more cycle to empty fifo, settling core internal state
      if (fifo_empty ='1') then
        s_mst_state <= idle_phase;
      end if;
    when others => null;
  end case;
end process;

--synopsys translate_off
assert not (hclk'event and hclk='1' and (mst_state=addr_data or mst_state=data) and (mst_in.hready='1' and mst_in.hresp/=ok_resp)) 
report "####PROTOCOL ERROR: in addr_data error/retry/split&&ready!!!!!"
severity error;
--synopsys translate_on

process(hresetn, hclk)
begin
  if hresetn='0' then
    mst_state <= idle_phase;
  elsif hclk'event and hclk='1' then
    mst_state <= s_mst_state after 1 ns;
  end if;
end process;
	  

start_hlocked <= dma_start.hparams(0);
start_hwrite <= dma_start.hparams(1);
start_hprot <= dma_start.hparams(5 downto 2);
start_hburst <= dma_start.hparams(8 downto 6);
start_hsize <= dma_start.hparams(11 downto 9);
start_prior <= dma_start.hparams(12);

--***************************
--********** htrans *********
--***************************
--busy if:
--write:
--count>1 and fifo=1 and trans_reg/=busy and addr_data
--count=1 and fifo_empty and addr_data 
--read:
--fifo_hfull and addr_data
s_mst_out.htrans <=	tmp_htrans;

tmp_htrans <= 
--busy when (mst_state=addr_data and granted='1' and page_fault='0' and dma_count>=2 and ((next_fifo_he='1' and r_mst_out.hwrite='1') or (next_fifo_hf='1' and r_mst_out.hwrite='0'))) else
busy when (mst_state=addr_data and (
(dma_count>=2 and ((fifo_count<=1 and r_mst_out.hwrite='1') or (fifo_count>=fifo_length-1 and r_mst_out.hwrite='0'))) or
(dma_count=1 and ((fifo_count<=1 and r_mst_out.hwrite='1') or (fifo_count=fifo_length and r_mst_out.hwrite='0'))))) else
nonseq when (mst_state=addr) else
seq when (mst_state=addr_data) else
idle;							

--***************************
--******** granted bus ******
--***************************	
process(hclk, hresetn)
begin
  if hresetn='0' then
    granted <= '0';
  elsif hclk'event and hclk='1' then
    granted <= '0' after 1 ns;
    if (mst_in.hready='1' and mst_in.hgrant='1') then
      granted <= '1' after 1 ns;
    end if;
  end if;
end process;

next_fifo_empty <= '1' when ((fifo_count=0 and (fifo_write='0' or (fifo_write=fifo_read))) or (fifo_count=1 and fifo_read='1' and fifo_write='0')) else '0';
next_fifo_full <= '1'  when ((fifo_count=fifo_length and (fifo_read='0' or (fifo_write=fifo_read))) or (fifo_count=fifo_length-1 and fifo_read='0' and fifo_write='1')) else '0';
next_fifo_he <=  '1' when ((fifo_count<=1 and (fifo_write='0' or (fifo_write=fifo_read))) or (fifo_count=2 and fifo_read='1' and fifo_write='0')) else '0';
next_fifo_hf <= '1'  when ((fifo_count>=fifo_length-1 and (fifo_read='0' or (fifo_write=fifo_read))) or (fifo_count=fifo_length-2 and fifo_read='0' and fifo_write='1')) else '0';
--next_count_ge2 <= '1' when ((dma_count_ge2='1' and fifo_hwrite='0' and fifo_hread='0') or (dma_count_ge3='1' and (fifo_hwrite='1' or fifo_hread='1'))) else '0';	
							 
--***************************
--********* old_hburst ******
--***************************	
process(hclk, hresetn)
begin
  if hresetn='0' then
    old_hburst <= incr;
    prior_reg <= slave;
  elsif hclk'event and hclk='1' then
    old_hburst <= old_hburst_s after 1 ns;
    prior_reg <= prior_s after 1 ns;    
  end if;
end process;
old_hburst_s <= start_hburst when (dma_start.start='1') else old_hburst;
prior_s <= start_prior when (dma_start.start='1') else prior_reg;

--***************************
--***************************	
process(hclk,hresetn)
begin
  if hresetn='0' then
    r_mst_out.haddr <= (others => '0');
    r_mst_out.htrans <= "00";
    r_mst_out.hlock <= '0';
    r_mst_out.hwrite <= '0';
    r_mst_out.hsize <= bits32;
    r_mst_out.hburst <= incr;
    r_mst_out.hprot <= "0011";
  elsif hclk'event and hclk='1' then
    r_mst_out.haddr <= s_mst_out.haddr after 1 ns;
    r_mst_out.htrans <= s_mst_out.htrans after 1 ns;
    r_mst_out.hlock <= s_mst_out.hlock after 1 ns;
    r_mst_out.hwrite <= s_mst_out.hwrite after 1 ns;
    r_mst_out.hsize <= s_mst_out.hsize after 1 ns;
    r_mst_out.hburst <= s_mst_out.hburst after 1 ns;
    r_mst_out.hprot <= s_mst_out.hprot after 1 ns;
  end if;
end process;

	
s_mst_out.hlock <= start_hlocked when (dma_start.start='1') else r_mst_out.hlock;	
s_mst_out.hwrite <= start_hwrite when (dma_start.start='1') else r_mst_out.hwrite;	
s_mst_out.hsize <= start_hsize when (dma_start.start='1') else r_mst_out.hsize;
s_mst_out.hburst <= start_hburst when (dma_start.start='1') else incr when (dma_restart='1') else r_mst_out.hburst;
s_mst_out.hprot <= start_hprot when (dma_start.start='1') else r_mst_out.hprot;

mst_out.hlock <= hlock_t;
mst_out.hwrite <= r_mst_out.hwrite;
mst_out.hsize <= r_mst_out.hsize;	  
mst_out.hburst <= r_mst_out.hburst;
mst_out.hprot <= r_mst_out.hprot;

mst_out.haddr <= r_mst_out.haddr;
mst_out.hwdata <= fifo_dataout;--not retimed!
mst_out.hbusreq <= hbusreq_t;	  
mst_out.htrans <= s_mst_out.htrans;


--***************************
--********** haddr **********
--***************************					
old_addr_pr:process(hclk, hresetn)
begin
  if hresetn='0' then
    old_addr <= (others => '0');
  elsif hclk'event and hclk='1' then
    old_addr <= old_addr_s after 1 ns;
  end if;
end process;

old_addr_move:process(mst_state, mst_in, tmp_htrans, r_mst_out)
begin
  if ((mst_state=addr or mst_state=addr_data or mst_state=data) and mst_in.hready='1' and tmp_htrans/=busy and r_mst_out.htrans/=busy) then
    old_addr_incr <= '1';
  else
    old_addr_incr <= '0';
  end if;
end process;

old_addr_s <= r_mst_out.haddr when (old_addr_incr='1') else
dma_start.extaddr when (dma_start.start='1') else
old_addr;

page_fault <= '1' when (page_attention='1' and (pf_incr='1' or pf_wrap4='1' or pf_wrap8='1' or pf_wrap16='1')) else '0';

pf_incr <= '1' when (haddr_t(9 downto 2)=0) else '0';
pf_wrap4 <= '1' when (haddr_t(3 downto 2)=0 and old_hburst=wrap4) else '0';
pf_wrap8 <= '1' when (haddr_t(4 downto 2)=0 and old_hburst=wrap8) else '0';
pf_wrap16 <= '1' when (haddr_t(5 downto 2)=0 and old_hburst=wrap16) else '0';
	
with r_mst_out.hburst select
page_attention <=
'1' when incr|incr4|incr8|incr16,
'0' when others;

with old_hburst select
old_page_attention <=
'1' when incr|incr4|incr8|incr16,
'0' when others;

with r_mst_out.hburst select
haddr_t(9 downto 2) <=
r_mst_out.haddr(9 downto 2)+1 when incr|incr4|incr8|incr16,
r_mst_out.haddr(9 downto 4)&(r_mst_out.haddr(3 downto 2)+"01") when wrap4,
r_mst_out.haddr(9 downto 5)&(r_mst_out.haddr(4 downto 2)+"001") when wrap8,
r_mst_out.haddr(9 downto 6)&(r_mst_out.haddr(5 downto 2)+"0001") when wrap16,
r_mst_out.haddr(9 downto 2) when others;--"000",

--page increment if:
--page fault and incr/incr4/incr8/incr16 and old_burst incr/incr4/incr8/incr16
s_mst_out.haddr(31 downto 10) <=
dma_start.extaddr(31 downto 10) when (dma_start.start='1') else 
old_addr(31 downto 10) when (mst_state=retry_phase or mst_state=idle_phase) else
(r_mst_out.haddr(31 downto 10)+1) when (page_attention='1' and old_page_attention='1' and pf_incr='1' and haddr_incr='1') else
r_mst_out.haddr(31 downto 10);

s_mst_out.haddr(1 downto 0) <= dma_start.extaddr(1 downto 0) when (dma_start.start='1') else r_mst_out.haddr(1 downto 0);

s_mst_out.haddr(9 downto 2) <= 
dma_start.extaddr(9 downto 2) when (dma_start.start='1') else				
old_addr(9 downto 2) when (mst_state=retry_phase or mst_state=idle_phase) else
r_mst_out.haddr(9 downto 4)&"00" when (page_fault='1' and pf_wrap4='1' and haddr_incr='1') else
r_mst_out.haddr(9 downto 5)&"000" when (page_fault='1' and pf_wrap8='1' and haddr_incr='1') else			
r_mst_out.haddr(9 downto 6)&"0000" when (page_fault='1' and pf_wrap16='1' and haddr_incr='1') else		
haddr_t(9 downto 2) when (haddr_incr='1') else		
r_mst_out.haddr(9 downto 2);									
  
--haddr_incr_pr:process(mst_state, mst_in, tmp_htrans, r_mst_out)
--begin
--  if ((mst_state=addr or mst_state=addr_data) and mst_in.hready='1' and tmp_htrans/=busy and r_mst_out.htrans/=busy) then-- or mst_state=data 
--    haddr_incr <= '1';
--  else
--    haddr_incr <= '0';
--  end if;
--end process;

--haddr_incr <= '1' when
--(mst_in.hready='1' and 
--(tmp_htrans=nonseq or 
--((tmp_htrans=seq or tmp_htrans=busy) and r_mst_out.htrans/=busy))) else '0';
haddr_incr <= '1' when
(mst_in.hready='1' and (tmp_htrans=nonseq or tmp_htrans=seq or tmp_htrans=busy) and r_mst_out.htrans/=busy) else '0';

--***************************
--********* hbusreq *********
--***************************					

hbusreq_t <= '1' when
(
(dma_count>0 and mst_state=req_phase) or
(dma_count>1 and (mst_state=addr or mst_state=addr_data))
) else '0';

mst_req <= '1' when (r_mst_out.hwrite='0' or fifo_empty='0') else '0';				
--start new master if:
--read or
--write and fifo_count>=2 or
--write and fifo_count=1 and dma_count=1
	
--***************************
--********** hlock *********
--***************************					
hlock_t <= hbusreq_t and r_mst_out.hlock;--for hlock behaviour different wrt hbusreq change ONLY here!!


--***************************
--********* eot_int *********
--***************************					
int_gen:process(hclk, hresetn)
begin
  if hresetn='0' then
    eot_int_reg <= '0';
  elsif hclk'event and hclk='1' then
    if (mst_state=idle_phase) then
      eot_int_reg <= '0' after 1 ns;
    elsif 
      (s_mst_state=idle_phase and mst_running_t='1' and dma_count_s=0) then
      eot_int_reg <= '1' after 1 ns;
    end if;
  end if;
end process;

eot_int <= eot_int_reg;	  


--***************************
--****** mst_running *****
--***************************					
mst_running_t <= '0' when (mst_state=idle_phase or mst_state=wait_phase or mst_state=req_phase) else '1';
mst_running <= mst_running_t;


--***************************
--******** dma_count ********
--***************************					
dma_count_pr:process(hclk, hresetn)
begin
  if hresetn='0' then
    dma_count <= (others => '0');
  elsif hclk'event and hclk='1' then
    dma_count <= dma_count_s after 1 ns;
  end if;
end process;
  
process(dma_start, start_hburst)
begin
  if dma_start.start='1' then
    case start_hburst is
      when single =>
        right_count(15 downto 0) <= "0000000000000001";
      when incr =>
        right_count(15 downto 0) <= dma_start.count;
      when wrap4|incr4 =>
        right_count(15 downto 0) <= "0000000000000100";
      when wrap8|incr8 =>
        right_count(15 downto 0) <= "0000000000001000" ;
      when others =>--wrap16|incr16
        right_count(15 downto 0) <= "0000000000010000";
    end case;
  else
    right_count(15 downto 0) <= (others => '-');
  end if;
end process;

dma_count_s <= 
  (others=>'0') when fifo_reset='1' else 
--  dma_count-1 when (r_mst_out.hwrite='1' and fifo_hread='1') or (r_mst_out.hwrite='0' and fifo_hwrite='1') else
  dma_count-1 when ((mst_state=addr or mst_state=addr_data) and haddr_incr='1') else
  dma_count+1 when (mst_state=retry_phase and mst_in.hready='1') else 
  right_count when (dma_start.start='1') else 
  dma_count; 

dma_restart <= '1' when (mst_state=retry_phase or mst_state=data) else '0';

fifo_reset <= '1' when (
(mst_state=error_phase) or
(mst_in.hresp=ok_resp and r_mst_out.htrans/=busy and r_mst_out.hwrite='1' and mst_in.hready='1' and	mst_state=data and dma_count=0)
) else '0';
	
	
--***************************
--***** fifo interface ******
--***************************					
fifo_write <= fifo_hwrite or m_wrap_in.ask_ok;
fifo_read <= fifo_hread or m_wrap_in.take_ok;	   

fifo_datain <= mst_in.hrdata when (fifo_hwrite='1') else m_wrap_in.rdata;
m_wrap_out.wdata <= fifo_dataout;

--transfer master => fifo
fifo_hwrite <= '1' when (r_mst_out.hwrite='0' and  data_trx='1' and fifo_full='0') else '0';

--transfer fifo => master
fifo_hread <= '1' when (r_mst_out.hwrite='1' and data_trx='1' and fifo_empty='0') else '0';
	

data_trx <= '1' when (mst_in.hready='1' and mst_in.hresp=ok_resp and r_mst_out.htrans/=busy and (mst_state=addr_data or mst_state=data)) else '0';
	
--***********************************************
--master<=>core interface: program/data memories 
--***********************************************

--transfer fifo => core	
m_wrap_out.take <= '1' when (r_mst_out.hwrite='0' and fifo_empty='0') else '0';

--transfer core => fifo
m_wrap_out.ask <= '1' when (r_mst_out.hwrite='1' and fifo_full='0' and (mst_running_t='1' or dma_count/=0)) else '0';
	
m_wrap_out.addr <= int_addr;
	
    
process(hclk, hresetn)
begin
  if hresetn='0' then
    int_addr <= (others => '0');
    int_mod <= (others => '0');
  elsif hclk'event and hclk='1' then
    int_addr <= int_addr_s after 1 ns;
    int_mod <= int_mod_s after 1 ns;
  end if;
end process;

int_mod_s <= dma_start.intmod when (dma_start.start='1') else int_mod;	

int_page_fault <= '1' when (int_addr_t(9 downto 2)=0 and page_attention='1') else '0';
	
with r_mst_out.hburst select
int_addr_t(9 downto 2) <=
int_addr(9 downto 2)+int_mod(9 downto 2) when incr|incr4|incr8|incr16,
int_addr(9 downto 4)&(int_addr(3 downto 2)+"01") when wrap4,
int_addr(9 downto 5)&(int_addr(4 downto 2)+"001") when wrap8,
int_addr(9 downto 6)&(int_addr(5 downto 2)+"0001") when wrap16,
int_addr(9 downto 2) when others;--"000",

int_addr_incr <= '1' when ((r_mst_out.hwrite='0' and m_wrap_in.take_ok='1') or (r_mst_out.hwrite='1' and m_wrap_in.ask_ok='1')) else '0';

int_addr_s(31 downto 16) <= (others => '0');
int_addr_s(15 downto 10) <= (int_addr(15 downto 10)+1) when (int_page_fault='1' and int_addr_incr='1') else dma_start.intaddr(15 downto 10) when (dma_start.start='1') else int_addr(15 downto 10);
int_addr_s(1 downto 0) <= dma_start.intaddr(1 downto 0) when (dma_start.start='1') else int_addr(1 downto 0);
int_addr_s(9 downto 2) <= int_addr_t(9 downto 2) when (int_addr_incr='1') else dma_start.intaddr(9 downto 2) when (dma_start.start='1') else int_addr(9 downto 2);	
	

end rtl;
