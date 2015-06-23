----==============================================================----
----                                                              ----
---- Filename: hw_loops5_top.vhd                                  ----
---- Module description: Top-level file for the hw_looping unit.  ----
----                     Also implements input and output         ----
----                     wrapping operations.                     ----
----                                                              ----
---- Author: Nikolaos Kavvadias                                   ----
----         nkavv@physics.auth.gr                                ----
----                                                              ----
----                                                              ----
---- Part of the hwlu OPENCORES project generated automatically   ----
---- with the use of the "gen_hw_looping" tool                    ----
----                                                              ----
---- To Do:                                                       ----
----         Considered stable for the time being                 ----
----                                                              ----
---- Author: Nikolaos Kavvadias                                   ----
----         nkavv@physics.auth.gr                                ----
----                                                              ----
----==============================================================----
----                                                              ----
---- Copyright (C) 2004-2010   Nikolaos Kavvadias                 ----
----                    nkavv@uop.gr                              ----
----                    nkavv@physics.auth.gr                     ----
----                    nikolaos.kavvadias@gmail.com              ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from <http://www.opencores.org/lgpl.shtml>                   ----
----                                                              ----
----==============================================================----
--
-- CVS Revision History
--

library IEEE;
use IEEE.std_logic_1164.all;

entity hw_looping is
	generic (
		NLP : integer := 5;
		DW  : integer := 8
	);
	port (
		clk            : in std_logic;
		reset          : in std_logic;
		task_loop5_end : in std_logic;
		loop1_count    : in std_logic_vector(DW-1 downto 0);
		loop2_count    : in std_logic_vector(DW-1 downto 0);
		loop3_count    : in std_logic_vector(DW-1 downto 0);
		loop4_count    : in std_logic_vector(DW-1 downto 0);
		loop5_count    : in std_logic_vector(DW-1 downto 0);
		index1         : out std_logic_vector(DW-1 downto 0);
		index2         : out std_logic_vector(DW-1 downto 0);
		index3         : out std_logic_vector(DW-1 downto 0);
		index4         : out std_logic_vector(DW-1 downto 0);
		index5         : out std_logic_vector(DW-1 downto 0);
		loops_end      : out std_logic
	);
end hw_looping;

architecture structural of hw_looping is
--
-- Component declarations
component cmpeq
	generic (
		DW : integer := 8
	);
	port (
		a      : in std_logic_vector(DW-1 downto 0);
		b      : in std_logic_vector(DW-1 downto 0);
		reset  : in std_logic;
		a_eq_b : out std_logic
	);
end component;
--
component index_inc
	generic (
		DW : integer := 8
	);
	port (
		clk            : in std_logic;
		reset          : in std_logic;
		inc_en         : in std_logic;
		index_plus_one : out std_logic_vector(DW-1 downto 0);
		index_out      : out std_logic_vector(DW-1 downto 0)
	);
end component;
--
component priority_encoder
	generic (
		NLP : integer := 5
	);
	port (
		flag           : in std_logic_vector(NLP-1 downto 0);
		task_loop5_end : in std_logic;
		incl           : out std_logic_vector(NLP-1 downto 0);
		reset_vct      : out std_logic_vector(NLP-1 downto 0);
		loops_end      : out std_logic
	);
end component;
--
-- Signal declarations
signal flag                : std_logic_vector(NLP-1 downto 0);
signal incl                : std_logic_vector(NLP-1 downto 0);
signal temp_loop_count     : std_logic_vector(NLP*DW-1 downto 0);
signal temp_index          : std_logic_vector(NLP*DW-1 downto 0);
signal temp_index_plus_one : std_logic_vector(NLP*DW-1 downto 0);
signal reset_vct_penc      : std_logic_vector(NLP-1 downto 0);
signal reset_vct_ix        : std_logic_vector(NLP-1 downto 0);
--
begin

	temp_loop_count( ((NLP-0)*DW-1) downto ((NLP-1)*DW) ) <= loop1_count;
	temp_loop_count( ((NLP-1)*DW-1) downto ((NLP-2)*DW) ) <= loop2_count;
	temp_loop_count( ((NLP-2)*DW-1) downto ((NLP-3)*DW) ) <= loop3_count;
	temp_loop_count( ((NLP-3)*DW-1) downto ((NLP-4)*DW) ) <= loop4_count;
	temp_loop_count( ((NLP-4)*DW-1) downto ((NLP-5)*DW) ) <= loop5_count;

	GEN_COMPARATORS: for i in 0 to NLP-1 generate
		U_cmp : cmpeq
			generic map (
				DW => DW
			)
			port map (
				a => temp_index_plus_one( ((i+1)*DW-1) downto (i*DW) ),
				b => temp_loop_count( ((i+1)*DW-1) downto (i*DW) ),
				reset => reset,
				a_eq_b => flag(i)
			);
	end generate GEN_COMPARATORS;

	U_priority_enc : priority_encoder
		generic map (
			NLP => NLP
		)
		port map (
			flag => flag,
			task_loop5_end => task_loop5_end,
			incl => incl,
			reset_vct => reset_vct_penc,
			loops_end => loops_end
		);

	GEN_RESET_SEL: for i in 0 to NLP-1 generate
		reset_vct_ix(i) <= reset_vct_penc(i) or reset;
	end generate GEN_RESET_SEL;

	GEN_INC_IX: for i in 0 to NLP-1 generate
		U_inc_ix1 : index_inc
			generic map (
				DW => DW
			)
			port map (
				clk => clk,
				reset => reset_vct_ix(i),
				inc_en => incl(i),
				index_plus_one => temp_index_plus_one( ((i+1)*DW-1) downto (i*DW) ),
				index_out => temp_index( ((i+1)*DW-1) downto (i*DW) )
			);
	end generate GEN_INC_IX;

	index1 <= temp_index( ((NLP-0)*DW-1) downto ((NLP-1)*DW) );
	index2 <= temp_index( ((NLP-1)*DW-1) downto ((NLP-2)*DW) );
	index3 <= temp_index( ((NLP-2)*DW-1) downto ((NLP-3)*DW) );
	index4 <= temp_index( ((NLP-3)*DW-1) downto ((NLP-4)*DW) );
	index5 <= temp_index( ((NLP-4)*DW-1) downto ((NLP-5)*DW) );

end structural;
