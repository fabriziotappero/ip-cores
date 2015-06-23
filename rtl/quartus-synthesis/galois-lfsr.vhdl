/*
        This file is part of the Galois-type linear-feedback shift register 
        (galois_lfsr) project:
                http://www.opencores.org/project,galois_lfsr
        
        Description
        Synthesisable use case for Galois LFSR.
        This example is a CRC generator that uses a Galois LFSR.
	Example applications include:
        * serial or parallel PRBS generation.
        * CRC computation.
        * digital scramblers/descramblers.
        
        ToDo: 
        
        Author(s): 
        - Daniel C.K. Kho, daniel.kho@opencores.org | daniel.kho@tauhop.com
        
        Copyright (C) 2012-2013 Authors and OPENCORES.ORG
        
        This source file may be used and distributed without 
        restriction provided that this copyright statement is not 
        removed from the file and that any derivative work contains 
        the original copyright notice and the associated disclaimer.
        
        This source file is free software; you can redistribute it 
        and/or modify it under the terms of the GNU Lesser General 
        Public License as published by the Free Software Foundation; 
        either version 2.1 of the License, or (at your option) any 
        later version.
        
        This source is distributed in the hope that it will be 
        useful, but WITHOUT ANY WARRANTY; without even the implied 
        warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
        PURPOSE. See the GNU Lesser General Public License for more 
        details.
        
        You should have received a copy of the GNU Lesser General 
        Public License along with this source; if not, download it 
        from http://www.opencores.org/lgpl.shtml.
*/
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
/* Enable for synthesis; comment out for simulation.
	For this design, we just need boolean_vector. This is already included in Questa/ModelSim, 
	but Quartus doesn't yet support this.
*/
use work.types.all;

entity lfsr is generic(
		/* 
		 * Tap vector: a TRUE means that position is tapped, otherwise that position is untapped.
		 */
		taps:boolean_vector
	);

	port(nReset,clk:in std_ulogic:='0';
		load:in boolean;
		seed:in unsigned(taps'high downto 0);
		
		d:in std_ulogic;
		q:out unsigned(taps'high downto 0)
	);
end entity lfsr;

architecture rtl of lfsr is
	signal i_d,i_q:unsigned(taps'high downto 0);
	signal x:unsigned(taps'high-1 downto 0);
	
begin
--	/* [begin]: Simulation testbench stimuli. Do not remove.
--		TODO migrate to separate testbench when more testcases are developed.
--	*/
--	/* synthesis translate_off */
--	clk<=not clk after 1 ns;
--	/* synthesis translate_on */
--	/* [end]: simulation stimuli. */
	
	
	/* Receives a vector of taps; generates LFSR structure with correct XOR positionings. */
	tapGenr: for i in 0 to taps'high-1 generate
		i_d(i+1)<=x(i) when taps(i) else i_q(i);
		x(i)<=i_q(i) xor i_q(taps'high);
	end generate;
	
	process(nReset,load,seed,clk) is begin
		if nReset='0' then i_q<=(others=>'0');
		elsif load then i_q<=seed;
		elsif rising_edge(clk) then
			i_q<=i_d;
		end if;
	end process;
	
	i_d(0)<=d;
	q<=i_d;
	
end architecture rtl;
