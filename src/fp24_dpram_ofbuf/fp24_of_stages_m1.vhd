-------------------------------------------------------------------------------
--
-- Title       : fp24_of_stages_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0 
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package	fp24_of_stages_m1_pkg is
	component fp24_of_stages_m1 is
		generic ( 
			stages			: integer:=10
			);
		port(
			addr_in 		: in std_logic_vector(stages-1 downto 0);
			din				: in std_logic_vector(31 downto 0);
			ena				: in std_logic;
			wr_en			: in std_logic;
			clk_in			: in std_logic;
			addr_out 		: in std_logic_vector(stages-2 downto 0);
			--dout			: out std_logic_vector(63 downto 0);
			re_even			: out std_logic_vector(15 downto 0);
			re_odd			: out std_logic_vector(15 downto 0);
			im_even			: out std_logic_vector(15 downto 0);
			im_odd			: out std_logic_vector(15 downto 0);			
			rd_en			: in std_logic;
			clk				: in std_logic;
			reset			: in std_logic
		);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all; 

entity fp24_of_stages_m1 is
	generic ( 
		stages			: integer:=10
		);	
	port(
		addr_in 		: in std_logic_vector(stages-1 downto 0);
		din				: in std_logic_vector(31 downto 0);
		ena				: in std_logic;
		wr_en			: in std_logic;
		clk_in			: in std_logic;
		addr_out 		: in std_logic_vector(stages-2 downto 0);
		--dout			: out std_logic_vector(63 downto 0);
		re_even			: out std_logic_vector(15 downto 0);
		re_odd			: out std_logic_vector(15 downto 0);
		im_even			: out std_logic_vector(15 downto 0);
		im_odd			: out std_logic_vector(15 downto 0);
		rd_en			: in std_logic;
		clk				: in std_logic;
		reset			: in std_logic
	);
end fp24_of_stages_m1;

architecture fp24_of_stages_m1 of fp24_of_stages_m1 is	

signal dob 				: std_logic_vector(63 downto 0);
signal rstn				: std_logic;   	 

constant Nram			: integer:=2**(stages-9);
constant Mram			: integer:=2**(stages-10);
constant Qram			: integer:=2**(15-stages);
constant Iram			: integer:=Qram/2;

signal d_re_even		: std_logic_vector(15 downto 0);
signal d_re_odd			: std_logic_vector(15 downto 0);
signal d_im_even		: std_logic_vector(15 downto 0);
signal d_im_odd			: std_logic_vector(15 downto 0);

signal din0, din1		: std_logic_vector(15 downto 0);
signal dob0, dob1		: std_logic_vector(31 downto 0);


begin
	
rstn <= not reset;

din0 <= din(15 downto 0);
din1 <= din(31 downto 16);

x_gen10: if stages = 10 generate
	gen_width: for ii in 0 to Mram-1 generate	
		ramb0 : RAMB16_S18_S36	
			generic	map(
				INIT_A => "0", -- Value of output RAM registers on Port A at startup
				INIT_B => "0", -- Value of output RAM registers on Port B at startup
				SRVAL_A => "0", -- Port A ouput value upon SSR assertion
				SRVAL_B => "0", -- Port B ouput value upon SSR assertion
			    WRITE_MODE_A => "READ_FIRST",
			    WRITE_MODE_B => "READ_FIRST"
			)
			port map(
				--doa 	=> doa,
				dob 	=> dob0(Qram*ii+Qram-1 downto Qram*ii),
				addra 	=> addr_in,
				addrb 	=> addr_out,
				clka 	=> clk_in,
				clkb 	=> clk,
				dia 	=> din0(Iram*ii+Iram-1 downto ii*Iram),
				dib 	=> x"00000000",
				dipa	=> "00",
				dipb	=> "0000",
				ena 	=> ena,
				enb 	=> rd_en,
				ssra 	=> rstn,
				ssrb 	=> rstn,
				wea 	=> wr_en,
				web 	=> '0'
			);
		ramb1 : RAMB16_S18_S36	
			generic	map(
				INIT_A => "0", -- Value of output RAM registers on Port A at startup
				INIT_B => "0", -- Value of output RAM registers on Port B at startup
				SRVAL_A => "0", -- Port A ouput value upon SSR assertion
				SRVAL_B => "0", -- Port B ouput value upon SSR assertion
			    WRITE_MODE_A => "READ_FIRST",
			    WRITE_MODE_B => "READ_FIRST"
			)
			port map(
				--doa 	=> doa,
				dob 	=> dob1(Qram*ii+Qram-1 downto Qram*ii),
				addra 	=> addr_in,
				addrb 	=> addr_out,
				clka 	=> clk_in,
				clkb 	=> clk,
				dia 	=> din1(Iram*ii+Iram-1 downto ii*Iram),
				dib 	=> x"00000000",
				dipa	=> "00",
				dipb	=> "0000",
				ena 	=> ena,
				enb 	=> rd_en,
				ssra 	=> rstn,
				ssrb 	=> rstn,
				wea 	=> wr_en,
				web 	=> '0'
			);			
	end generate;	
end generate; 
	
x_gen11: if stages = 11 generate
	gen_width: for ii in 0 to Mram-1 generate	
		ramb0 : RAMB16_S9_S18	
			generic	map(
				INIT_A => "0", -- Value of output RAM registers on Port A at startup
				INIT_B => "0", -- Value of output RAM registers on Port B at startup
				SRVAL_A => "0", -- Port A ouput value upon SSR assertion
				SRVAL_B => "0", -- Port B ouput value upon SSR assertion
			    WRITE_MODE_A => "READ_FIRST",
			    WRITE_MODE_B => "READ_FIRST"
			)
			port map(
				--doa 	=> doa,
				dob 	=> dob0(Qram*ii+Qram-1 downto Qram*ii),
				addra 	=> addr_in,
				addrb 	=> addr_out,
				clka 	=> clk_in,
				clkb 	=> clk,
				dia 	=> din0(Iram*ii+Iram-1 downto ii*Iram),
				dib 	=> x"0000",
				dipa	=> "0",
				dipb	=> "00",
				ena 	=> ena,
				enb 	=> rd_en,
				ssra 	=> rstn,
				ssrb 	=> rstn,
				wea 	=> wr_en,
				web 	=> '0'
			);
		ramb1 : RAMB16_S9_S18	
			generic	map(
				INIT_A => "0", -- Value of output RAM registers on Port A at startup
				INIT_B => "0", -- Value of output RAM registers on Port B at startup
				SRVAL_A => "0", -- Port A ouput value upon SSR assertion
				SRVAL_B => "0", -- Port B ouput value upon SSR assertion
			    WRITE_MODE_A => "READ_FIRST",
			    WRITE_MODE_B => "READ_FIRST"
			)
			port map(
				--doa 	=> doa,
				dob 	=> dob1(Qram*ii+Qram-1 downto Qram*ii),
				addra 	=> addr_in,
				addrb 	=> addr_out,
				clka 	=> clk_in,
				clkb 	=> clk,
				dia 	=> din1(Iram*ii+Iram-1 downto ii*Iram),
				dib 	=> x"0000",
				dipa	=> "0",
				dipb	=> "00",
				ena 	=> ena,
				enb 	=> rd_en,
				ssra 	=> rstn,
				ssrb 	=> rstn,
				wea 	=> wr_en,
				web 	=> '0'
			);				
	end generate;
end generate; 

x_gen12: if stages = 12 generate
	gen_width: for ii in 0 to Mram-1 generate	
			ramb0 : RAMB16_S4_S9	
				generic	map(
					INIT_A => "0", -- Value of output RAM registers on Port A at startup
					INIT_B => "0", -- Value of output RAM registers on Port B at startup
					SRVAL_A => "0", -- Port A ouput value upon SSR assertion
					SRVAL_B => "0", -- Port B ouput value upon SSR assertion
				    WRITE_MODE_A => "READ_FIRST",
				    WRITE_MODE_B => "READ_FIRST"
				)
				port map(
					--doa 	=> doa,
					dob 	=> dob0(Qram*ii+Qram-1 downto Qram*ii),
					addra 	=> addr_in,
					addrb 	=> addr_out,
					clka 	=> clk_in,
					clkb 	=> clk,
					dia 	=> din0(Iram*ii+Iram-1 downto ii*Iram),
					dib 	=> x"00",
					--dipa	=> "0",
					dipb	=> "0",
					ena 	=> ena,
					enb 	=> rd_en,
					ssra 	=> rstn,
					ssrb 	=> rstn,
					wea 	=> wr_en,
					web 	=> '0'
				);	 
			ramb1 : RAMB16_S4_S9	
				generic	map(
					INIT_A => "0", -- Value of output RAM registers on Port A at startup
					INIT_B => "0", -- Value of output RAM registers on Port B at startup
					SRVAL_A => "0", -- Port A ouput value upon SSR assertion
					SRVAL_B => "0", -- Port B ouput value upon SSR assertion
				    WRITE_MODE_A => "READ_FIRST",
				    WRITE_MODE_B => "READ_FIRST"
				)
				port map(
					--doa 	=> doa,
					dob 	=> dob1(Qram*ii+Qram-1 downto Qram*ii),
					addra 	=> addr_in,
					addrb 	=> addr_out,
					clka 	=> clk_in,
					clkb 	=> clk,
					dia 	=> din1(Iram*ii+Iram-1 downto ii*Iram),
					dib 	=> x"00",
					--dipa	=> "0",
					dipb	=> "0",
					ena 	=> ena,
					enb 	=> rd_en,
					ssra 	=> rstn,
					ssrb 	=> rstn,
					wea 	=> wr_en,
					web 	=> '0'
				);	 				
		end generate;	
end generate; 

x_gen13: if stages = 13 generate
	gen_width: for ii in 0 to Mram-1 generate	
		ramb0 : RAMB16_S2_S4	
			generic	map(
				INIT_A => "0", -- Value of output RAM registers on Port A at startup
				INIT_B => "0", -- Value of output RAM registers on Port B at startup
				SRVAL_A => "0", -- Port A ouput value upon SSR assertion
				SRVAL_B => "0", -- Port B ouput value upon SSR assertion
			    WRITE_MODE_A => "READ_FIRST",
			    WRITE_MODE_B => "READ_FIRST"
			)
			port map(
				--doa 	=> doa,
				dob 	=> dob0(Qram*ii+Qram-1 downto Qram*ii),
				addra 	=> addr_in,
				addrb 	=> addr_out,
				clka 	=> clk_in,
				clkb 	=> clk,
				dia 	=> din0(Iram*ii+Iram-1 downto ii*Iram),
				dib 	=> x"0",
				--dipa	=> "0",
				--dipb	=> "0",
				ena 	=> ena,
				enb 	=> rd_en,
				ssra 	=> rstn,
				ssrb 	=> rstn,
				wea 	=> wr_en,
				web 	=> '0'
			);	
		ramb1 : RAMB16_S2_S4	
			generic	map(
				INIT_A => "0", -- Value of output RAM registers on Port A at startup
				INIT_B => "0", -- Value of output RAM registers on Port B at startup
				SRVAL_A => "0", -- Port A ouput value upon SSR assertion
				SRVAL_B => "0", -- Port B ouput value upon SSR assertion
			    WRITE_MODE_A => "READ_FIRST",
			    WRITE_MODE_B => "READ_FIRST"
			)
			port map(
				--doa 	=> doa,
				dob 	=> dob1(Qram*ii+Qram-1 downto Qram*ii),
				addra 	=> addr_in,
				addrb 	=> addr_out,
				clka 	=> clk_in,
				clkb 	=> clk,
				dia 	=> din1(Iram*ii+Iram-1 downto ii*Iram),
				dib 	=> x"0",
				--dipa	=> "0",
				--dipb	=> "0",
				ena 	=> ena,
				enb 	=> rd_en,
				ssra 	=> rstn,
				ssrb 	=> rstn,
				wea 	=> wr_en,
				web 	=> '0'
			);	 				
	end generate;	
end generate; 

x_gen14: if stages = 14 generate
	gen_width: for ii in 0 to Mram-1 generate	
			ramb : RAMB16_S1_S2	
				generic	map(
					INIT_A => "0", -- Value of output RAM registers on Port A at startup
					INIT_B => "0", -- Value of output RAM registers on Port B at startup
					SRVAL_A => "0", -- Port A ouput value upon SSR assertion
					SRVAL_B => "0", -- Port B ouput value upon SSR assertion
				    WRITE_MODE_A => "READ_FIRST",
				    WRITE_MODE_B => "READ_FIRST"
				)
				port map(
					--doa 	=> doa,
					dob 	=> dob0(Qram*ii+Qram-1 downto Qram*ii),
					addra 	=> addr_in,
					addrb 	=> addr_out,
					clka 	=> clk_in,
					clkb 	=> clk,
					dia 	=> din0(Iram*ii+Iram-1 downto ii*Iram),
					dib 	=> "00",
					--dipa	=> "0",
					--dipb	=> "0",
					ena 	=> ena,
					enb 	=> rd_en,
					ssra 	=> rstn,
					ssrb 	=> rstn,
					wea 	=> wr_en,
					web 	=> '0'
				);	
			ramb1 : RAMB16_S1_S2	
				generic	map(
					INIT_A => "0", -- Value of output RAM registers on Port A at startup
					INIT_B => "0", -- Value of output RAM registers on Port B at startup
					SRVAL_A => "0", -- Port A ouput value upon SSR assertion
					SRVAL_B => "0", -- Port B ouput value upon SSR assertion
				    WRITE_MODE_A => "READ_FIRST",
				    WRITE_MODE_B => "READ_FIRST"
				)
				port map(
					--doa 	=> doa,
					dob 	=> dob1(Qram*ii+Qram-1 downto Qram*ii),
					addra 	=> addr_in,
					addrb 	=> addr_out,
					clka 	=> clk_in,
					clkb 	=> clk,
					dia 	=> din1(Iram*ii+Iram-1 downto ii*Iram),
					dib 	=> "00",
					--dipa	=> "0",
					--dipb	=> "0",
					ena 	=> ena,
					enb 	=> rd_en,
					ssra 	=> rstn,
					ssrb 	=> rstn,
					wea 	=> wr_en,
					web 	=> '0'
				);									
	end generate;	
end generate; 

x_genN: if ((stages > 9) and (stages < 14)) generate
	x_gen_out: for ii in 0 to Mram-1 generate
		d_re_even(ii*16/Mram+16/Mram-1 downto ii*16/Mram) <= dob0(ii*32/Mram+16/Mram-1 downto ii*32/Mram);
		d_im_even(ii*16/Mram+16/Mram-1 downto ii*16/Mram) <= dob1(ii*32/Mram+16/Mram-1 downto ii*32/Mram); 
		
		d_re_odd(ii*16/Mram+16/Mram-1 downto ii*16/Mram) <= dob0(ii*32/Mram+2*16/Mram-1 downto ii*32/Mram+16/Mram);
		d_im_odd(ii*16/Mram+16/Mram-1 downto ii*16/Mram) <= dob1(ii*32/Mram+2*16/Mram-1 downto ii*32/Mram+16/Mram); 	
	end generate;
end generate;

process(clk, rstn) is
begin
	if rstn = '1' then
		re_even <= (others => '0') after 1 ns;
		re_odd 	<= (others => '0') after 1 ns;
		im_even <= (others => '0') after 1 ns;
		im_odd 	<= (others => '0') after 1 ns;
	elsif rising_edge(clk) then
		re_even <= d_re_even after 1 ns;
		re_odd 	<= d_re_odd  after 1 ns;
		im_even <= d_im_even after 1 ns;
		im_odd 	<= d_im_odd  after 1 ns;
	end if;
end process;	

end fp24_of_stages_m1;
