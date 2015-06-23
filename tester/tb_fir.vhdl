/* Synthesisable testbench/BiST for FIR Filter design.
	
	Copyright© 2012 Tauhop Solutions. All rights reserved.
	This core is free hardware design; you can redistribute it and/or
	modify it under the terms of the GNU Library General Public
	License as published by the Free Software Foundation; either
	version 2 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Library General Public License for more details.
	
	You should have received a copy of the GNU Library General Public
	License along with this library; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
	
	License: LGPL.
	
	@dependencies: 
	@designer(s):
		Daniel C.K. Kho [daniel.kho@gmail.com] | [daniel.kho@tauhop.com];
		Tan Hooi Jing [hooijingtan@gmail.com]
	@info: 
	Revision History: @see Mercurial log for full list of changes.
	
	This notice and disclaimer must be retained as part of this text at all times.
*/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir is generic(order:positive:=30);		--; width:positive:=16);
	port(
--		clk:in std_ulogic:='0';
--		nRst:in std_ulogic:='0';
		--u:in signed(16-1 downto 0);
		y:out signed(16-1 downto 0)
	);
end entity tb_fir;

architecture rtl of tb_fir is
	signal reset:std_ulogic:='0';
	signal u:signed(y'range);
	signal trig:std_logic;
	
	/* synthesis translate_off */
	signal clk:std_ulogic:='0';
	signal nRst:std_ulogic:='1';
	/* synthesis translate_on */
	
	signal count:unsigned(8 downto 0);
	signal pwrUpCnt:unsigned(3 downto 0):=(others=>'0');
	
	/* on-chip debugger */
	signal dbgSignals:std_ulogic_vector(127 downto 0):=(others=>'0');
	
	
	/* Explicitly define all multiplications with the "*" operator to use dedicated DSP hardware multipliers. */
	attribute multstyle:string; attribute multstyle of rtl:architecture is "dsp";	--altera:
--	attribute mult_style:string; attribute mult_style of fir:entity is "block";		--xilinx:

begin
	/* synthesis translate_off*/
	clk<=not clk after 10 ns;
	/* synthesis translate_on*/
	
	process(pwrUpCnt,nRst) is begin
		if pwrUpCnt<10 or nRst='0' then reset<='1';
		else reset<='0';
		end if;
	end process;
	
	process(reset,clk) is begin
		if reset='1' then count<=(others =>'0');
		elsif rising_edge(clk) then
			if count<300 then count<=count+1; end if;
		end if;
	end process;
	
	process(nRst,clk) is begin
		if nRst='0' then pwrUpCnt<=(others =>'0');
		elsif rising_edge(clk) then
			if pwrUpCnt<10 then pwrUpCnt<=pwrUpCnt+1; end if;
		end if;
	end process;
	
	/* Impulse generator for impulse response measurement. */
	u <= (0=>'1', others=>'0') when count=1 else (others=>'0');
	
	
	filter: entity work.fir(rtl)
		generic map(order=>order)		--, width=>width)
		port map(
			reset=>reset,
			clk=>clk,
			
			/* Filter ports. */
			u=>u,
			y=>y
	);
	
	
	/* Simulation only. */
	/* synthesis translate_off */
	reporter: process(clk) is begin
		if rising_edge(clk) then
			/* (u,y) pairs will be exported to CSV and Matlab for plotting.
				Results are then correlated to digital simulations and Matlab 
				simulations of the filter.
			*/
			report ";" & integer'image(to_integer(u)) & ";"
				& integer'image(to_integer(y));
		end if;
	end process reporter;
	
	process is begin
		assert now<5 us report "simulation stopped." severity failure;
		wait;
	end process;
	/* synthesis translate_on */
	
	
	/* Hardware debugger (SignalTap II embedded logic analyser). */
	
	trig<='1' when count<300 else '0';		-- Stop SignalTap Triggering after 300 counts, Total data=280
	
	/* SignalTap debugger. */
	dbgSignals(u'range)<=std_ulogic_vector(u);						-- u:16bits
	dbgSignals(u'length*2-1  downto u'length)<=std_ulogic_vector(y);				-- y:32bits						
	dbgSignals(8+u'length*2 downto u'length*2)<=std_ulogic_vector(count);		--9bits (300<512)
	
/*	debugger: entity work.stp(syn) port map(
		acq_clk=>clk,														
		acq_data_in=>std_logic_vector(dbgSignals), 		-- Type conversion: std_ulogic_vector --> std_logic_vector
		acq_trigger_in=>"1",
		trigger_in=>trig
	);
*/
end architecture rtl;
