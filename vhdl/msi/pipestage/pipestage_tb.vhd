----------------------------------------------------------------------------------------------------
-- (c) 2005.. Hoffmann RF & DSP   opencores@hoffmann-hochfrequenz.de
-- V1.0 published under BSD license
----------------------------------------------------------------------------------------------------
-- Design Name:     pipestage_tb.vhd
-- Tool versions:   Modelsim
-- Description:		  testbed for pipeline stage with variable width and depth

-- calls lib:       ieee standard
-- calls entities:  clk_rst, several flavours of pipestage.vhd
--
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library floatfixlib;
use floatfixlib.fixed_pkg.all;


entity pipestage_tb is begin end pipestage_tb;


architecture tb of pipestage_tb is

	signal rst, clk, ce: std_logic := '0';

  signal slv_src:                                        std_logic_vector(7 downto 0);
  signal signed_src:                                     signed(7 downto 0);
  signal unsigned_src:                                   unsigned(7 downto 0);
  signal bool_src:                                       boolean;
  signal sl_src:                                         std_logic;
  signal ufixed_src:                                     ufixed(4 downto -3);
  signal sfixed_src:                                     sfixed(4 downto -3);
  
	signal slv_0, slv_1, slv_2, slv_3:                     std_logic_vector(7 downto 0);
	signal signed_0, signed_1, signed_2, signed_3:         signed(7 downto 0);
	signal unsigned_0, unsigned_1, unsigned_2, unsigned_3: unsigned(7 downto 0);
  signal bool_0, bool_1, bool_2, bool_3:                 boolean;
	signal sl_0, sl_1, sl_2, sl_3:                         std_logic;
	signal ufixed_0, ufixed_1, ufixed_2, ufixed_3:         ufixed(3 downto -4);   -- warum zeigt der Modelsim Indizes von 4 bis -3 ?????
	signal sfixed_0, sfixed_1, sfixed_2, sfixed_3:         sfixed(3 downto -4);

-- floats and integers receive enough testing in the sine table module.
	
begin
   
u_clk_rst: entity work.clk_rst
generic  map(
  verbose           => false,
  clock_frequency   => 100.0e6,
  min_resetwidth    => 15 ns
)
port map( 
  clk               => clk,
  rst               => rst
);  


--p_mk_ce: process(clk) is begin
--	if rising_edge(clk) then
--		if rst='1' then
--			ce <= '1';
--		 else
--			ce <= not ce;
--		end if;
--	end if;
--end process;

ce <= '1';

p_stimulus: process(clk) is begin
	if rising_edge(clk) then
		if rst='1' then
			slv_src <= x"00";
      bool_src <= false;
		 else
			slv_src <= std_logic_vector(unsigned(slv_src) + 1);
      bool_src <= (slv_src(0)='0') and (slv_src(1)='0') and (slv_src(2)='0');
		end if;
	end if;
end process;

sl_src       <= slv_src(3);
signed_src   <= signed(slv_src);
unsigned_src <= unsigned(slv_src);

ufixed_src   <= to_ufixed(0,     ufixed_src), 
                to_ufixed(3.0,   ufixed_src) after 92 ns,
                to_ufixed(3.75,  ufixed_src) after 152 ns;              
                
sfixed_src   <= to_sfixed(0,     sfixed_src), 
                to_sfixed(3.0,   sfixed_src) after 92 ns,
                to_sfixed(-3.75, sfixed_src) after 152 ns;               

--------------------------------------------------------------------------------
-- std_logic_vector version

u_slv_0:	entity work.slv_pipestage
generic map (
  n_stages	=> 0
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => slv_src,
	o   => slv_0
);


u_slv_1:	entity work.slv_pipestage
generic map (
  n_stages	=> 1
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => slv_src,
  o   => slv_1
);


u_slv_2:	entity work.slv_pipestage
generic map (
  n_stages	=> 2
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => slv_src,
  o   => slv_2
);


u_slv_3:	entity work.slv_pipestage
generic map (
  n_stages	=> 3
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => slv_src,
  o   => slv_3
);


--------------------------------------------------------------------------------
-- boolean version


u_bool_0:	entity work.bool_pipestage
generic map (
  n_stages	=> 0
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => bool_src,
	o   => bool_0
);


u_bool_1:	entity work.bool_pipestage
generic map (
  n_stages	=> 1
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => bool_src,
  o   => bool_1
);


u_bool_2:	entity work.bool_pipestage
generic map (
  n_stages	=> 2
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => bool_src,
  o   => bool_2
);


u_bool_3:	entity work.bool_pipestage
generic map (
  n_stages	=> 3
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => bool_src,
  o   => bool_3
);


--------------------------------------------------------------------------------
-- std_logic version

u_sl_0:	entity work.sl_pipestage
generic map (
  n_stages	=> 0
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => sl_src,
	o   => sl_0
);


u_sl_1:	entity work.sl_pipestage
generic map (
  n_stages	=> 1
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => sl_src,
  o   => sl_1
);


u_sl_2:	entity work.sl_pipestage
generic map (
  n_stages	=> 2
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => sl_src,
  o   => sl_2
);


u_sl_3:	entity work.sl_pipestage
generic map (
  n_stages	=> 3
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => sl_src,
  o   => sl_3
);


--------------------------------------------------------------------------------
-- signed version

u_signed_0:	entity work.signed_pipestage
generic map (
  n_stages	=> 0
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => signed_src,
  o   => signed_0
);


u_signed_1:	entity work.signed_pipestage
generic map (
  n_stages	=> 1
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => signed_src,
  o   => signed_1
);


u_signed_2:	entity work.signed_pipestage
generic map (
  n_stages	=> 2
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => signed_src,
  o   => signed_2
);


u_signed_3:	entity work.signed_pipestage
generic map (
  n_stages	=> 3
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => signed_src,
  o   => signed_3
);


--------------------------------------------------------------------------------
-- unsigned version

u_unsigned_0:	entity work.unsigned_pipestage
generic map (
  n_stages	=> 0
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => unsigned_src,
	o   => unsigned_0
);


u_unsigned_1:	entity work.unsigned_pipestage
generic map (
  n_stages	=> 1
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => unsigned_src,
  o   => unsigned_1
);


u_unsigned_2:	entity work.unsigned_pipestage
generic map (
  n_stages	=> 2
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => unsigned_src,
  o   => unsigned_2
);


u_unsigned_3:	entity work.unsigned_pipestage
generic map (
  n_stages	=> 3
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => unsigned_src,
  o   => unsigned_3
);

-- real and integer still missing  FIXME


--------------------------------------------------------------------------------
-- ufixed version

u_ufix_0:	entity work.ufixed_pipestage
generic map (
  n_stages	=> 0
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => ufixed_src,
	o   => ufixed_0
);


u_ufix_1:	entity work.ufixed_pipestage
generic map (
  n_stages	=> 1
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => ufixed_src,
  o   => ufixed_1
);


u_ufix_2:	entity work.ufixed_pipestage
generic map (
  n_stages	=> 2
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => ufixed_src,
  o   => ufixed_2
);


u_ufix_3:	entity work.ufixed_pipestage
generic map (
  n_stages	=> 3
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => ufixed_src,
  o   => ufixed_3
);



--------------------------------------------------------------------------------
-- sfixed version

u_sfix_0:	entity work.sfixed_pipestage
generic map (
  n_stages	=> 0
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => sfixed_src,
	o   => sfixed_0
);


u_sfix_1:	entity work.sfixed_pipestage
generic map (
  n_stages	=> 1
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => sfixed_src,
  o   => sfixed_1
);


u_sfix_2:	entity work.sfixed_pipestage
generic map (
  n_stages	=> 2
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => sfixed_src,
  o   => sfixed_2
);


u_sfix_3:	entity work.sfixed_pipestage
generic map (
  n_stages	=> 3
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,

  i   => sfixed_src,
  o   => sfixed_3
);


end tb;


