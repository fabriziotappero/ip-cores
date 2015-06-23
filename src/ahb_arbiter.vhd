
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
--use work.ahb_matrix.all;

entity ahb_arbiter is
  generic(
    num_arb: in integer:= 2;
    num_arb_msts: in integer range 1 to 15:= 4;
    def_arb_mst: in integer range 0 to 15:= 2;
    num_slvs: in integer range 1 to 15:= 3;
    alg_number: in integer range 0 to 5:= 2);
  port(
    hresetn: in std_logic;
    hclk: in std_logic;
    remap: in std_logic;
    mst_in_v: in mst_out_v_t(num_arb_msts-1 downto 0);
    mst_out_v: out mst_in_v_t(num_arb_msts-1 downto 0);   
    slv_out_v: out slv_in_v_t(num_slvs-1 downto 0);
    slv_in_v: in slv_out_v_t(num_slvs-1 downto 0));
end;


architecture rtl of ahb_arbiter is

--*******************************************************************
--******************** SIGNAL DECLARATION ***************************
--*******************************************************************

signal s_grant_master, grant_master: integer range 0 to 15;
signal s_master_sel, master_sel: std_logic_vector(3 downto 0);	
signal s_r_master_sel, r_master_sel: std_logic_vector(3 downto 0);
signal r_master_busy: std_logic_vector(1 downto 0);

signal turn, s_turn: integer range 0 to num_arb_msts-1;
signal random: integer range 0 to 2**(nb_bits(num_arb_msts));
signal seed, s_seed: std_logic_vector(9 downto 0);

type vecran is array (2**(nb_bits(num_arb_msts)) downto 0) of integer;
signal vect_ran: vecran;
signal vect_ran_round: vecran;


signal haddr_page: std_logic_vector(31 downto 0);
signal htrans_reg: std_logic_vector(1 downto 0);--"00"|"01"|"10"
signal hsel: std_logic_vector(num_slvs-1 downto 0);


signal s_dec_hready: std_logic;
signal req_ored: std_logic;
signal hbusreq_msk: std_logic_vector(num_arb_msts-1 downto 0);

signal split_reg: std_logic_vector(num_arb_msts-1 downto 0);

signal r_slv_in_v: slv_in_v_t(num_slvs-1 downto 0);
signal mst_in_sel: slv_in_t;
signal slv_in_sel: mst_in_t;

--DEAFULT SLAVE BEHAVIOUR						  

signal r_def_slave_hsel, def_slave_hsel: std_logic;
signal def_slave_hready: std_logic;

signal addr_arb_matrix: addr_matrix_t(0 downto 0);

--*******************************************************************
--***************** END OF SIGNAL DECLARATION ************************
--*******************************************************************

begin 

addr_arb_matrix(0)(num_slvs-1 downto 0) <= arb_matrix(num_arb)(num_slvs-1 downto 0) when (remap='0') else rarb_matrix(num_arb)(num_slvs-1 downto 0);

req_ored_pr:process(hbusreq_msk)
variable v_req_ored: std_logic;
begin
  v_req_ored := '0';
  for i in 0 to num_arb_msts-1 loop
    v_req_ored := v_req_ored or hbusreq_msk(i);
  end loop;
  req_ored <= v_req_ored;
end process;

bus_req_mask_pr:process(split_reg, grant_master, mst_in_v)
begin
  for i in 0 to num_arb_msts-1 loop   		
    if (mst_in_v(i).htrans=busy or split_reg(i)='1' or (grant_master/=num_arb_msts and grant_master/=i and mst_in_v(grant_master).hlock='1')) then  
      hbusreq_msk(i) <= '0';
    else 
      hbusreq_msk(i) <= mst_in_v(i).hbusreq;
    end if;
  end loop;
end process;


--********************************************************
-- synchronization processes (flip flops)
--********************************************************
s_master_sel <= conv_std_logic_vector(s_grant_master, 4) when (s_dec_hready='1') else master_sel;
s_r_master_sel <= master_sel when (s_dec_hready='1' and htrans_reg/=busy) else r_master_sel;

master_pr:process(hresetn, hclk)
begin
  if hresetn='0' then
    grant_master <= def_arb_mst; 
    master_sel <= conv_std_logic_vector(def_arb_mst, 4);
    r_master_sel <= conv_std_logic_vector(def_arb_mst, 4);
    turn <= 0;
    htrans_reg <= idle;
  elsif hclk'event and hclk='1' then
    grant_master <= s_grant_master after 1 ns;
    master_sel <= s_master_sel after 1 ns;
    r_master_sel <= s_r_master_sel after 1 ns;
    turn <= s_turn after 1 ns;
    if conv_integer(master_sel) /= num_arb_msts then
      htrans_reg <= mst_in_sel.htrans after 1 ns;
    else
      htrans_reg <= idle;
    end if;
  end if;
end process;

update_pr:process(
req_ored,
hbusreq_msk, 
grant_master,
mst_in_v,
htrans_reg,
mst_in_sel,
slv_in_sel,
split_reg,
turn,
random)
variable t_turn, t_grant_master: integer;
begin
  t_turn := turn;
  t_grant_master := grant_master;
  --nohready=> grant no change
  --hready&busy(real master)=> grant no change
  --hready&nobusy&req => arbitration
  --hready&nobusy&noreq&default master not splitted => default master							 
  --hready&nobusy&noreq&default master splitted => dummy master
  if (slv_in_sel.hready='1') then
    if ((grant_master/=num_arb_msts and mst_in_v(grant_master).htrans/=busy and htrans_reg/=busy) or (grant_master=num_arb_msts)) then 
      if (req_ored='1') then
        case alg_number is
          when 0 => --fixed 
            fixed_priority(t_turn, t_grant_master, hbusreq_msk, turn);
          when 1 => --round robin
            round_robin(def_arb_mst, t_turn, t_grant_master, hbusreq_msk, turn);
          when 2 => --random
            random_priority(def_arb_mst, t_turn, t_grant_master, random, hbusreq_msk, turn);
          when 3 => --fair1
            if (grant_master/=num_arb_msts and hbusreq_msk(grant_master)='0') or (grant_master=num_arb_msts) then
              fixed_priority(t_turn, t_grant_master, hbusreq_msk, turn);
            end if;  
          when 4 => --fair2
            if (grant_master/=num_arb_msts and hbusreq_msk(grant_master)='0') or (grant_master=num_arb_msts) then
              round_robin(def_arb_mst, t_turn, t_grant_master, hbusreq_msk, turn);
            end if;  
          when 5 => --fair3
            if (grant_master/=num_arb_msts and hbusreq_msk(grant_master)='0') or (grant_master=num_arb_msts) then
              random_priority(def_arb_mst, t_turn, t_grant_master, random, hbusreq_msk, turn);
            end if;  
          when others => --NOT IMPLEMENTED
            assert FALSE report "### NOT IMPLEMENTED!" severity FAILURE;
		end case;
      elsif (split_reg(def_arb_mst)='0') then--ready+no_busy+no_req=> default if not splitted!!
        t_grant_master := def_arb_mst;
	    t_turn := def_arb_mst;
      else--ready+no_busy+no_req+def_master splitted => dummy_master!!
        t_grant_master := num_arb_msts;
      end if;
    --else (busy) then SAME MASTER
    end if;
  --else (no_ready) then SAME MASTER
  end if;
  s_grant_master <= t_grant_master;
  s_turn <= t_turn;
end process;

s_seed_pr:process(seed)
begin
  for i in 9 downto 1 loop
    s_seed(i) <= seed(i-1);
  end loop;
  s_seed(0) <= not(seed(9) xor seed(6));
end process;	   	  

seed_pr:process(hresetn, hclk)
variable v_random: integer range 0 to 2**(nb_bits(num_arb_msts));
begin
  if hresetn='0' then
    seed <= (others => '0');--"1101010001";
    random <= 0;
    --synopsys translate_off
    for i in 0 to 2**(nb_bits(num_arb_msts)) loop
      vect_ran(i) <= 0;
      vect_ran_round(i) <= 0;
    end loop;
    --synopsys translate_on
  elsif hclk'event and hclk='1' then
    seed <= s_seed after 1 ns;
    v_random := conv_integer(seed(nb_bits(num_arb_msts)+3 downto 4));
    if v_random < num_arb_msts then
      random <= v_random after 1 ns; 
    else
      random <= turn after 1 ns;--(v_random - num_arb_msts);
    end if;
    --synopsys translate_off
    vect_ran(v_random) <= vect_ran(v_random) + 1;
    vect_ran_round(random) <= vect_ran_round(random) + 1;
    --synopsys translate_on
  end if;
end process;



--synopsys translate_off
  assert not (hclk'event and hclk='1' and master_sel=num_arb_msts) report "DUMMY MASTER selection!!!" severity WARNING;
  assert not (hclk'event and hclk='1' and master_sel=def_arb_mst) report "DEFAULT MASTER selection!!!" severity WARNING;
  assert not (hclk'event and hclk='1' and (master_sel>num_arb_msts or r_master_sel>num_arb_msts)) report "####ERROR in MASTER selection!!!" severity FAILURE;
--synopsys translate_on


--*********************************************************
-- MASTER MUXES
--*********************************************************

add_pr:process(master_sel, r_master_sel, mst_in_v)
variable def_addr: std_logic_vector(31 downto 0);
begin

  haddr_page(31 downto 10) <= mst_in_v(def_arb_mst).haddr(31 downto 10);

  mst_in_sel.hwdata <= mst_in_v(def_arb_mst).hwdata;
  mst_in_sel.haddr <= mst_in_v(def_arb_mst).haddr;
  mst_in_sel.hwrite <= mst_in_v(def_arb_mst).hwrite;
  mst_in_sel.hsize <= mst_in_v(def_arb_mst).hsize;
  mst_in_sel.hburst <= mst_in_v(def_arb_mst).hburst;
  mst_in_sel.hprot <= mst_in_v(def_arb_mst).hprot;
  mst_in_sel.htrans <= mst_in_v(def_arb_mst).htrans;
  for i in 0 to num_arb_msts-1 loop 
    if i=conv_integer(r_master_sel) then
      mst_in_sel.hwdata <= mst_in_v(i).hwdata;
    end if;
    if i=conv_integer(master_sel) then
      haddr_page(31 downto 10) <= mst_in_v(i).haddr(31 downto 10);
      mst_in_sel.haddr <= mst_in_v(i).haddr;
      mst_in_sel.hwrite <= mst_in_v(i).hwrite;
      mst_in_sel.hsize <= mst_in_v(i).hsize;
      mst_in_sel.hburst <= mst_in_v(i).hburst;
      mst_in_sel.hprot <= mst_in_v(i).hprot;
      mst_in_sel.htrans <= mst_in_v(i).htrans;
    end if;	
  end loop;
  if master_sel=num_arb_msts then
    mst_in_sel.htrans <= idle;
  end if;	  
end process;  

process(slv_in_sel, s_grant_master)--N.B.: Request=>Grant comb. path!
begin										   
  for i in 0 to num_arb_msts-1 loop 
    mst_out_v(i).hready <= slv_in_sel.hready;
    mst_out_v(i).hresp <= slv_in_sel.hresp;
    mst_out_v(i).hrdata <= slv_in_sel.hrdata;
    if (s_grant_master=i) then
      mst_out_v(i).hgrant <= '1';
    else
      mst_out_v(i).hgrant <= '0';
    end if;
  end loop;
end process;

--*********************************************************
-- SLAVE MUXES
--*********************************************************

process(hresetn, hclk)
variable v_hready: std_logic;
begin				 
  if hresetn='0' then
    for i in num_slvs-1 downto 0 loop
      r_slv_in_v(i).hsel <= '0';
    end loop;  
  elsif hclk='1' and hclk'event then
    if s_dec_hready='1' then
	  r_def_slave_hsel <= def_slave_hsel;
      for i in num_slvs-1 downto 0 loop
        r_slv_in_v(i).hsel <= hsel(i) after 1 ns;
      end loop;
    end if;
  end if;  
end process;

process(r_slv_in_v, slv_in_v, def_slave_hready)
begin
  s_dec_hready <= def_slave_hready;
  for i in num_slvs-1 downto 0 loop
    if(r_slv_in_v(i).hsel='1') then
      s_dec_hready <= slv_in_v(i).hready;
	end if;	  
  end loop;  
--  hready_t <= slv_in_v(num_slvs).hready;--ready ....
  slv_in_sel.hready <= def_slave_hready;	 
  slv_in_sel.hrdata <= (others => '-');--for LOW POWER!!!
  slv_in_sel.hresp <= error_resp;--.... and ERROR ....		
  for i in num_slvs-1 downto 0 loop
    if r_slv_in_v(i).hsel='1' then
--      hready_t <= slv_in_v(i).hready;
      slv_in_sel.hready <= slv_in_v(i).hready;	 
      slv_in_sel.hresp <= slv_in_v(i).hresp;
      slv_in_sel.hrdata <= slv_in_v(i).hrdata;
    end if;
  end loop;
end process;


--*********************************************************
-- SPLIT handling
--*********************************************************

process(hresetn, hclk)
variable v_split_reg: std_logic_vector(num_arb_msts-1 downto 0);
begin
  if hresetn='0' then
    split_reg <= (others => '0');  
  elsif hclk'event and hclk='1' then
    v_split_reg := split_reg;
    for j in num_slvs-1 downto 0 loop
      for i in num_arb_msts-1 downto 0 loop
        v_split_reg(i) := v_split_reg(i) and not slv_in_v(j).hsplit(i); 
      end loop;
      if (r_slv_in_v(j).hsel='1') then
        if (slv_in_v(j).hready='1' and slv_in_v(j).hresp=split_resp and master_sel/=num_arb_msts) then
          v_split_reg(conv_integer(master_sel)) := '1';
        end if;
      end if;
    end loop;
    split_reg <= v_split_reg after 1 ns;	
  end if;
end process;

--*********************************************************
-- AHB DECODER
--*********************************************************
-- min 1KB of address space for each slave:
process(haddr_page, master_sel, mst_in_v, mst_in_sel, s_dec_hready, addr_arb_matrix)
  variable addr_low_std : std_logic_vector(31 downto 0);
  variable addr_high_std : std_logic_vector(31 downto 0);
  variable v_hmastlock: std_logic;
begin
  v_hmastlock := '0';
  for i in num_arb_msts-1 downto 0 loop
    if (v_hmastlock='0' and master_sel=conv_std_logic_Vector(i,4) and mst_in_v(i).hlock='1') then
      v_hmastlock := '1';
    end if;
  end loop;
  def_slave_hsel <= '1'; --default slave selected
  for i in num_slvs-1 downto 0 loop
    slv_out_v(i).hmastlock <= v_hmastlock;
    slv_out_v(i).haddr <= mst_in_sel.haddr;
    slv_out_v(i).hmaster <= master_sel;
    slv_out_v(i).hready <= s_dec_hready;
    slv_out_v(i).hwrite <= mst_in_sel.hwrite;
    slv_out_v(i).hwdata <= mst_in_sel.hwdata;
    slv_out_v(i).hsize <= mst_in_sel.hsize;
    slv_out_v(i).hburst <= mst_in_sel.hburst;
    slv_out_v(i).hprot <= mst_in_sel.hprot;
    slv_out_v(i).htrans <= mst_in_sel.htrans;
    addr_low_std := conv_std_logic_vector(addr_arb_matrix(0)(i).low, 32);
    addr_high_std := conv_std_logic_vector(addr_arb_matrix(0)(i).high, 32);
    if (haddr_page(31 downto 10) >= addr_low_std(31 downto 10) and (haddr_page(31 downto 10) <= addr_high_std(31 downto 10))) then
      hsel(i) <= '1';
      def_slave_hsel <= '0';	
      slv_out_v(i).hsel <= '1';
    else
      hsel(i) <= '0';
      slv_out_v(i).hsel <= '0';
    end if;	 
  end loop;  
end process;  


--DEFAULT SLAVE BEHAVIOUR

process(hresetn, hclk)
begin		   
  if hresetn='0' then
    def_slave_hready <= '1';
  elsif hclk'event and hclk='1' then
    if (def_slave_hsel='1' and s_dec_hready='1' and mst_in_sel.htrans/=idle) then
      def_slave_hready <= '0' after 1 ns;
    else
      def_slave_hready <= '1' after 1 ns;
    end if;
  end if;
end process;	



--synopsys translate_off
 assert not(hclk'event and hclk='1' and r_def_slave_hsel='1') report "####ERROR: NO SLAVE SELECTED!!!" severity error;
--synopsys translate_on

end rtl;
	
	
