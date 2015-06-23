use STD.textio.all;--added for time and strings

library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use IEEE.std_logic_textio.all;--added for time and strings

-- Add your library and packages declaration here ...
use work.ahb_package.all;

entity uut_stimulator is
generic (
stim_type: in uut_params_t:= (bits32,retry,master,'0',single,2,4,hprot_posted,2048,1,0,'0');
enable: in integer:= 0;
eot_enable: in integer:= 0);
port(
  hclk : in std_logic;
  hresetn : in std_logic;
  amba_error: in std_logic;  
  eot_int: in std_logic;  
  conf: out conf_type_t;
  sim_end: out std_logic
);
end uut_stimulator;

--}} End of automatically maintained section

architecture rtl of uut_stimulator is
	  
signal cycle  : std_logic;
signal counter: integer range 0 to 127;

begin

process
begin
  if hresetn = '0' then
    counter <= 1;
  else
    if(counter > 15) then
      assert false report "* Simulator Exit.." severity warning;
      sim_end <= '1';
      wait;	  
    else
      sim_end <= '0';
      counter <= counter+1;
    end if;				
  end if;

  if (eot_enable/=1) then
    wait for 4000 ns;
  else
    wait until (eot_int='1' or amba_error='1');--write
    wait until (eot_int='1' or amba_error='1');--read
  end if;					
end process;

cycle_pr:process
begin
  if cycle/='1' then
    cycle <= '1';
    if (eot_enable/=1) then
      wait for 2000 ns;
    else
      wait until (eot_int='1' or amba_error='1');
    end if;					
  else
    cycle <= '0';
    if (eot_enable/=1) then
      wait for 2000 ns;
    else
      wait until (eot_int='1' or amba_error='1');
    end if;					
  end if;
end process;

process
variable hburst: std_logic_vector(2 downto 0);
begin
if (counter<=16) then

  conf.write <= '0';
  wait for 30 ns;
  conf.write <= '1';

  conf.addr <= dma_type_addr;
  
  case stim_type.hburst_cycle is
	  when '1' =>
	  	hburst := stim_type.hburst_tb;
	  when others =>
	  	hburst := conv_std_logic_vector(counter,3);
	  end case;
  conf.wdata <= "000000000000000000"&
  stim_type.split_tb&stim_type.prior_tb&stim_type.hsize_tb&hburst&stim_type.hprot_tb&cycle&stim_type.locked_request;
  wait for 10 ns;
		  
  conf.addr <= dma_extadd_addr;								 
  --conf.wdata(31 downto 12)<=stim_type.high_addr_tb;
  case stim_type.ext_addr_incr_tb is
	  when 1 =>--fixed ext addr
		conf.wdata(31 downto 0)<= conv_std_logic_vector(stim_type.base_tb ,32);
	  when 2 =>--increasing by 4, page fault if base near end of slave address space
		conf.wdata(31 downto 0)<= conv_std_logic_vector(stim_type.base_tb+(counter-1)*4 ,32);
	  when others =>--growing by incr_tb-4 (0,1,2,3,4,5, ETC.)
	  	conf.wdata(31 downto 0)<= conv_std_logic_vector(stim_type.base_tb+(counter-1)*(stim_type.ext_addr_incr_tb-4) ,32);
	  end case;
  wait for 10 ns;--external address

  conf.addr <= dma_intadd_addr;
  case stim_type.int_addr_incr_tb is
	  when 1 =>--fixed int addr
		conf.wdata(31 downto 0)<= conv_std_logic_vector(stim_type.int_base_tb,32);
	  when 2 =>--increasing by 4, page fault if base near end of slave address space
		conf.wdata(31 downto 0)<= conv_std_logic_vector(stim_type.int_base_tb+(counter-1)*4 ,32);
	  when others =>--growing by incr_tb-4 (0,1,2,3,4,5, ETC.)
	  	conf.wdata(31 downto 0)<= conv_std_logic_vector(stim_type.int_base_tb+(counter-1)*(stim_type.int_addr_incr_tb-4) ,32);
	  end case;
  wait for 10 ns;--internal address

  conf.addr <= dma_intmod_addr;
  conf.wdata <= conv_std_logic_vector(stim_type.intmod_tb ,32);
  wait for 10 ns;--modifier  

if enable=1 then
  conf.addr <= dma_count_addr;
  conf.wdata <= conv_std_logic_vector(counter,32);
  wait for 10 ns;--dma count
else
  wait for 10 ns;--dma count
end if;

  conf.write <= '0';
  conf.addr <= "0000";
  conf.wdata <= (others => '-');

  if (eot_enable/=1) then
	  wait until cycle'event;
  else
	  wait until (eot_int='1' or amba_error='1');
  end if;			  
else 
  wait;
end if;
--if counter=16 then wait; end if;
	
end process;
		
		
assert (amba_error/='1') report "###ERROR in AMBA operation!!!" severity error;		
		
end rtl;
