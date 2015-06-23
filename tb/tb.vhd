------------------------------------------------
--! @file tb.vhd
--! @brief RayTrac TestBench
--! @author Juli&aacute;n Andr&eacute;s Guar&iacute;n Reyes
--------------------------------------------------


-- RAYTRAC
-- Author Julian Andres Guarin
-- tb.vhd
-- This file is part of raytrac.
-- 
--     raytrac is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
-- 
--     raytrac is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
-- 
--     You should have received a copy of the GNU General Public License
--     along with raytrac.  If not, see <http://www.gnu.org/licenses/>

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use std.textio.all;
use work.arithpack.all;


entity tb is
	
end tb;


architecture tb_arch of tb is

	signal qa	: std_logic_vector (53 downto 0);
	signal qb	: std_logic_vector (53 downto 0);
	signal qc	: std_logic_vector (53 downto 0);
	signal qd	: std_logic_vector (53 downto 0);
	signal clock,rst,ena: std_logic;
	signal opcode,addcode:std_logic;
	signal dp0,dp1,cpx,cpy,cpz : std_logic_vector(31 downto 0);
	signal address: std_logic_vector (8 downto 0);
	signal opadd : std_logic_vector(1 downto 0);
	
begin
	
	--! Generador de clock.
	clk_inst: clock_gen
	port map (clock,rst); -- Instanciacion simple.

	--! Device Under Test
	dude: raytrac
	generic map ("YES","YES")	-- Test bench y Entrada registrada, pues la ROM no tiene salida registrada.
	port map(qa,qb,qc,qd,opadd(1),opadd(0),clock,rst,ena,cpx,cpy,cpz,dp0,dp1);
	
	--! Procedimiento para escribir los resultados del testbench
	sampleproc: process 
		variable buff : line;
		file rombuff : text open write_mode is "TRACE_rom_content.csv";
		variable stop : integer := 0;
	begin
		
		write(buff,string'("#ROM memories test benching"));
		writeline(rombuff, buff);
		write(buff,string'("#{Time} {AddressR} {Opc Adc} {Ax,Ay,Az} {Bx,By,Bz} {Cx,Cy,Cz} {Dx,Dy,Dz}"));
		writeline(rombuff, buff);
		
		wait for 5 ns; 
		wait until rst=not(rstMasterValue);
		wait until clock='1';
		wait for tclk2+tclk4; --! Garantizar la estabilidad de los datos que se van a observar en la salida.
		displayRom:
		loop
			write (buff,string'("{"));
			write (buff,now,unit =>ns);
			write (buff,string'("}{"));
			hexwrite_0 (buff,address(8 downto 0));
			write (buff,string'("}{"));
			hexwrite_0 (buff,opadd);
			write (buff,string'("} { "));
			hexwrite_0 (buff,qa(17 downto 0));
			write (buff,string'(","));
			hexwrite_0 (buff,qa(35 downto 18));
			write (buff,string'(","));
			hexwrite_0 (buff,qa(53 downto 36));
			write (buff,string'(" } "));
			write (buff,string'(" { "));
			hexwrite_0 (buff,qb(17 downto 0));
			write (buff,string'(","));
			hexwrite_0 (buff,qb(35 downto 18));
			write (buff,string'(","));
			hexwrite_0 (buff,qb(53 downto 36));
			write (buff,string'(" } "));
			write (buff,string'(" { "));
			hexwrite_0 (buff,qc(17 downto 0));
			write (buff,string'(","));
			hexwrite_0 (buff,qc(35 downto 18));
			write (buff,string'(","));
			hexwrite_0 (buff,qc(53 downto 36));
			write (buff,string'(" } "));
			write (buff,string'(" { "));
			hexwrite_0 (buff,qd(17 downto 0));
			write (buff,string'(","));
			hexwrite_0 (buff,qd(35 downto 18));
			write (buff,string'(","));
			hexwrite_0 (buff,qd(53 downto 36));
			write (buff,string'(" } "));
			writeline(rombuff,buff);
			wait for tclk;
			
			
			-- STOP FORREST!
			if opadd=X"2" and address=X"00"  then
				if stop=1 then
					wait;
				else 
					stop:=1;
				end if;
			end if;
			
		end loop displayRom;	
			
	end process sampleproc;
	
	
	
	--! Descripcion del test: 512 x (2/clock) productos punto y 1024 x (1/clock) productos cruz.
	thetest:
	process (clock,rst)
		variable buff : line;
		file rombuff : text open write_mode is "TRACE_state_content";
		variable tbs : tbState;
	begin

		if rst=rstMasterValue then
			
			opcode  <= '0';
			addcode <= '1';
			tbs := abcd;
			ena <= '1';
			address <= (others => '0');
		elsif clock'event and clock = '1' then
			
			opadd <= opcode & addcode;
			
			case tbs is
				when abcd  => 
					if address = X"1FF" then
						write (buff,now,unit => ns);
						write (buff,string'(" S: abcd => axb"));
						writeline (rombuff,buff);
						tbs := axb;
						opcode <= '1';
						addcode <= not(addcode);
					end if;
					address <= address + 1;
					
				when axb =>
					write (buff,now,unit => ns);
					write (buff,string'(" S: axb => cxd"));
					writeline (rombuff,buff);
						 
					tbs := cxd;
					addcode <= not(addcode);
				when cxd => 
					
					addcode <= not(addcode);
					if address=X"1FF" then 
						write (buff,now,unit => ns);
						write (buff,string'(" S: cxd => stop"));
						writeline (rombuff,buff);
						tbs := stop;
					else
						write (buff,now,unit => ns);
						write (buff,string'(" S: cxd => axb"));
						writeline (rombuff,buff);

						tbs := axb;				
					end if;
					address  <= address + 1;
				when others =>
					null;
			end case;		  
					
		end if;
	end process thetest;
	
	--! 512x18 rom con los componentes ax.
	AX : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "memax.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qa (17 downto 0)
	);

	--! 512x18 rom con los componentes ay.
	AY : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memay.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qa (35 downto 18) 
	);

	--! 512x18 rom con los componentes az.
	AZ : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memaz.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qa (53 downto 36) 
	);
	
	--! 512x18 rom con los componentes bx.
	BX : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\membx.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qb (17 downto 0)
	);

	--! 512x18 rom con los componentes by.
	BY : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memby.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qb (35 downto 18) 
	);

	--! 512x18 rom con los componentes bz.
	BZ : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\membz.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qb (53 downto 36) 
	);	

	--! 512x18 rom con los componentes cx.
	CX : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memcx.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qc (17 downto 0)
	);

	--! 512x18 rom con los componentes cy.
	CY : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memcy.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qc (35 downto 18) 
	);

	--! 512x18 rom con los componentes cz.
	CZ : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memcz.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qc (53 downto 36) 
	);
	
	--! 512x18 rom con los componentes dx.
	DX : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memdx.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qd (17 downto 0)
	);

	--! 512x18 rom con los componentes dy.
	DY : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memdy.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qd (35 downto 18) 
	);

	--! 512x18 rom con los componentes dz.
	DZ : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => ".\memdz.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 512,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		ram_block_type => "M9K",
		widthad_a => 9,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clock,
		address_a => address,
		q_a => qd (53 downto 36) 
	);	

end tb_arch;

