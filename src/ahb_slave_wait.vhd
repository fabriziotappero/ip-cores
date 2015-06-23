
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.ahb_funct.all;
use work.ahb_package.all;
use work.ahb_configure.all;

entity ahb_slave_wait is
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
    slv_err: out std_logic;
    mst_running: in std_logic;
    prior_in: in std_logic;
    slv_running: out std_logic;
    s_wrap_out: out wrap_out_t;
    s_wrap_in: in wrap_in_t);
end ahb_slave_wait;


architecture rtl of ahb_slave_wait is

--parameters fixed for single-wait slave
constant num_slvs: integer:= 1;
constant num_ahb: integer:= 0;
constant def_slv: integer:= 0;
constant alg_number: integer range 0 to 2:= 0;


type slv_fsm is (data_cycle,error_cycle);			 
signal slv_state, s_slv_state: slv_fsm;

signal r_slv_in_v, s_slv_in_v: slv_in_v_t(num_slvs-1 downto 0);

signal hready_t, r_hready: std_logic;
signal hresp_t: std_logic_vector(1 downto 0);
signal dec_error: std_logic;

--***************************************************************
--arbitration signals
--***************************************************************
signal s_grant_slave, grant_slave: integer range 0 to num_slvs-1;
signal s_turn, turn: integer range 0 to num_slvs-1;
signal req_ored: std_logic;

signal slv_req: std_logic_vector(num_slvs-1 downto 0);	

signal addr_slv_matrix: addr_matrix_t(0 downto 0);

begin   
 
addr_slv_matrix(0)(num_slvs-1 downto 0) <= slv_matrix(0)(num_slv downto num_slv) when (remap='0') else slv_matrix(1)(num_slv downto num_slv);

--***************************
--******* slave state *******
--***************************	
process(slv_state, dec_error)
begin  
  s_slv_state <= slv_state;
  case slv_state is
    when data_cycle =>
      if (dec_error='1') then
        s_slv_state <= error_cycle;
      end if;
    when error_cycle =>
      s_slv_state <= data_cycle;
    when others =>
  end case;
end process;

process(hresetn, hclk)
begin
  if hresetn='0' then
    r_hready <= '1';
  elsif hclk'event and hclk='1' then
    r_hready <= hready_t after 1 ns;
  end if;
end process; 

process(hresetn, hclk)
begin
  if hresetn='0' then
    slv_state <= data_cycle;
  elsif hclk'event and hclk='1' then
    slv_state <= s_slv_state after 1 ns;
  end if;
end process; 


process(addr_slv_matrix, r_slv_in_v, grant_slave)
variable v_error: std_logic;
begin
  v_error:= '0';
  if (r_slv_in_v(grant_slave).hsel='1') then
    if (r_slv_in_v(grant_slave).hsize/=bits32) then
      v_error:= '1';
	end if;
    if (r_slv_in_v(grant_slave).haddr(1 downto 0)/="00") then
      v_error:= '1';
	end if;
    if (r_slv_in_v(grant_slave).haddr(31 downto 10)<conv_std_logic_vector(addr_slv_matrix(num_ahb)(grant_slave).low, 32)(31 downto 10)) then
      v_error:= '1';
	end if;
    if (r_slv_in_v(grant_slave).haddr(31 downto 10)>conv_std_logic_vector(addr_slv_matrix(num_ahb)(grant_slave).high, 32)(31 downto 10)) then
      v_error:= '1';
    end if;
  end if;
  dec_error <= v_error;
end process; 

--***************************
--********** hready *********
--***************************

hready_t <= '1' when 
(slv_state=error_cycle or
r_slv_in_v(grant_slave).htrans=idle or
r_slv_in_v(grant_slave).htrans=busy or
((r_slv_in_v(grant_slave).htrans=nonseq or r_slv_in_v(grant_slave).htrans=seq) and dec_error='0' and 
((r_slv_in_v(grant_slave).hwrite='1' and s_wrap_in.take_ok='1') or (r_slv_in_v(grant_slave).hwrite='0' and s_wrap_in.ask_ok='1')))) else '0';

--***************************
--********** hresp **********
--***************************

hresp_t <= error_resp when (dec_error='1' or slv_state=error_cycle) else ok_resp;	
slv_err <= '1' when (slv_state=error_cycle) else '0';
	
--***************************
--******* s_wrap_out ********
--***************************
process(r_slv_in_v, slv_in, slv_state, grant_slave, dec_error)
begin
  s_wrap_out.addr <= r_slv_in_v(grant_slave).haddr;--to improve for LOW POWER!!
  s_wrap_out.wdata <= slv_in.hwdata;--to improve for LOW POWER!!
  s_wrap_out.take <= '0';
  s_wrap_out.ask <= '0';	  
  if (slv_state=data_cycle and dec_error='0' and slv_in.htrans/=busy and r_slv_in_v(grant_slave).hsel='1' and (r_slv_in_v(grant_slave).htrans=nonseq or r_slv_in_v(grant_slave).htrans=seq)) then
    s_wrap_out.take <= r_slv_in_v(grant_slave).hwrite;
    s_wrap_out.ask <= not r_slv_in_v(grant_slave).hwrite;	  
  end if;
end process; 


--***************************
--********** output *********
--***************************
process(s_wrap_in, hready_t, hresp_t, grant_slave, r_slv_in_v)
begin
  for i in num_slvs-1 downto 0 loop
    slv_out.hsplit <= (others => '0');
    slv_out.hrdata <= s_wrap_in.rdata;
    slv_out.hresp <= ok_resp;		 
    slv_out.hready <= '1';
    if (i=grant_slave) then	
      slv_out.hresp <= hresp_t;
      slv_out.hready <= hready_t;
    --easiest behaviour: wait for granting!!
    elsif (r_slv_in_v(i).hsel='1' and r_slv_in_v(i).htrans/=idle and r_slv_in_v(i).htrans/=busy) then
      slv_out.hready <= '0';
    end if;	  
  end loop;
end process; 

--***************************
--********** input **********
--***************************
process(hresetn, hclk)
begin
  if hresetn='0' then
    for i in num_slvs-1 downto 0 loop
      r_slv_in_v(i).hsel <= '0';		 
      r_slv_in_v(i).hready <= '0';
      r_slv_in_v(i).haddr <= (others=>'0');
      r_slv_in_v(i).hwrite <= '0';
      r_slv_in_v(i).htrans <= idle;
      r_slv_in_v(i).hsize <= bits32;
      r_slv_in_v(i).hburst <= incr;
      r_slv_in_v(i).hprot <= "0011";
    end loop;
  elsif hclk'event and hclk='1' then
    for i in num_slvs-1 downto 0 loop	  
      r_slv_in_v(i).hready <= slv_in.hready after 1 ns;
      if (slv_in.hready='1') then-- and slv_in.hsel='1'
        r_slv_in_v(i).hsel <= slv_in.hsel after 1 ns;
        r_slv_in_v(i).hburst <= slv_in.hburst after 1 ns;
        r_slv_in_v(i).hprot <= slv_in.hprot after 1 ns;
        r_slv_in_v(i).hsize <= slv_in.hsize after 1 ns;
        r_slv_in_v(i).hwrite <= slv_in.hwrite after 1 ns;
      end if;	    
      if (slv_in.hready='1' and r_slv_in_v(i).htrans/=busy) then-- and slv_in.hsel='1'
        r_slv_in_v(i).haddr <= slv_in.haddr after 1 ns;
      end if;
      if (slv_in.hready='1') then-- and slv_in.hsel='1'
        r_slv_in_v(i).htrans <= slv_in.htrans after 1 ns;
      end if;
    end loop;
  end if;
end process; 

--------------------------------------------------------------------------
-- SLAVES RESPONSES AND ARBITRATION
--------------------------------------------------------------------------

process(r_slv_in_v)
begin
  for i in num_slvs-1 downto 0 loop
    slv_req(i) <= '0';
    if (r_slv_in_v(i).hsel='1' and (r_slv_in_v(i).htrans=nonseq or r_slv_in_v(i).htrans=seq)) then
      slv_req(i) <= '1';
    end if;
  end loop;
end process;

process(slv_req)
variable v_req_ored: std_logic;
begin
  v_req_ored := '0';
  for i in num_slvs-1 downto 0 loop
    v_req_ored := v_req_ored or slv_req(i);
  end loop;
  req_ored <= v_req_ored;
end process;

update_pr:process(turn, grant_slave, r_hready, req_ored, slv_req, r_slv_in_v)
variable t_turn, t_grant_slave: integer;
begin
  t_turn := turn;
  t_grant_slave := grant_slave;
  if (r_hready='1' and req_ored='1' and r_slv_in_v(grant_slave).htrans/=busy and not(slv_req(grant_slave) and r_slv_in_v(grant_slave).hmastlock)='1') then
    case alg_number is
      when 0 => --fixed 
        fixed_priority(t_turn, t_grant_slave, slv_req, turn);
--      when 1 => --round robin
--        round_robin(def_slv, t_turn, t_grant_slave, slv_req, turn);
      when others => --NOT IMPLEMENTED
        assert FALSE report "### NOT IMPLEMENTED!" severity FAILURE;
    end case;
  --else (no_ready) then SAME SLAVE
  end if;
  s_turn <= t_turn;
  s_grant_slave <= t_grant_slave;
end process;

process(hresetn, hclk)
begin
  if hresetn='0' then
    grant_slave <= 0;
    turn <= 0;
  elsif hclk'event and hclk='1' then	
    grant_slave <= s_grant_slave after 1 ns;
    turn <= s_turn after 1 ns;
  end if;
end process; 

end rtl;
	
	
