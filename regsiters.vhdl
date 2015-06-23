-- 10/24/2005
-- General Purpose Register Bank

library ieee;
use ieee.std_logic_1164.all;

entity registers is port(
	d:	in std_logic_vector(15 downto 0);
	clk:	in std_logic;
	addr_a:	in std_logic_vector(2 downto 0);
	addr_b:	in std_logic_vector(2 downto 0);
	wr_en:	in std_logic;
	a_o:	out std_logic_vector(15 downto 0);
	b_o:	out std_logic_vector(15 downto 0)
);
end registers;

architecture regs_arch of registers is

component reg port(
	d:	in std_logic_vector(15 downto 0);
	clk:	in std_logic;
	wr_en:	in std_logic;
	q:	out std_logic_vector(15 downto 0)
);
end component;

component reg_dec port(
	addr:	in std_logic_vector(2 downto 0);
	en0:	out std_logic;
	en1:	out std_logic;
	en2:	out std_logic;
	en3:	out std_logic;
	en4:	out std_logic;
	en5:	out std_logic;
	en6:	out std_logic;
	en7:	out std_logic
);
end component;

component mux_8_1 port(
	a:	in std_logic_vector(15 downto 0);
	b:	in std_logic_vector(15 downto 0);
	c:	in std_logic_vector(15 downto 0);
	d:	in std_logic_vector(15 downto 0);
	e:	in std_logic_vector(15 downto 0);
	f:	in std_logic_vector(15 downto 0);
	g:	in std_logic_vector(15 downto 0);
	h:	in std_logic_vector(15 downto 0);
	sel:	in std_logic_vector(2 downto 0);
	o:	out std_logic_vector(15 downto 0)
);
end component;

signal w0, w1, w2, w3, w4, w5, w6, w7: std_logic;
signal q0, q1, q2, q3, q4, q5, q6, q7: std_logic_vector(15 downto 0);
signal wr_clk: std_logic;

begin
	wr_clk <= wr_en and clk;
	decode: reg_dec
		port map(addr_a, w0, w1, w2, w3, w4, w5, w6, w7);
	r0: reg
		port map(d, wr_clk, w0, q0);
	r1: reg
		port map(d, wr_clk, w1, q1);
	r2: reg
		port map(d, wr_clk, w2, q2);
	r3: reg
		port map(d, wr_clk, w3, q3);
	r4: reg
		port map(d, wr_clk, w4, q4);
	r5: reg
		port map(d, wr_clk, w5, q5);
	r6: reg
		port map(d, wr_clk, w6, q6);
	r7: reg
		port map(d, wr_clk, w7, q7);
	out_mux_a: mux_8_1
		port map(q0, q1, q2, q3, q4, q5, q6, q7, addr_a, a_o);
	out_mux_b: mux_8_1
		port map(q0, q1, q2, q3, q4, q5, q6, q7, addr_b, b_o);
end regs_arch;
