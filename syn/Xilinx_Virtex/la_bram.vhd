---- logic analyser internal BlockRAM  description
-- Only XST supports RAM inference
-- Infers Dual Port Block Ram 
 
-- remove this entity if you use a synthesis tool that cannot automaticaly detect dual port RAM
-- or if you use seperate clocks (generic: two_clocks>0 - Xilinx XST cannot automatically detect two clocks macro
-- then use a memory macro and remove this entity
 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- XST translate_off
library	Virtex;
-- XST translate_on 


entity la_bram is				  
  generic (data_width: integer:= 8; -- width of the data
    adr_width: integer:= 9; -- width of the address 
  	two_clocks: integer:= 0); -- =0 only one clock is used, =1 two seprrate clocks are used
  port (clka, wea: in std_logic;
    dia: in std_logic_vector(data_width-1 downto 0);
  	addra: in std_logic_vector(adr_width-1 downto 0);
	-- dual port interface (Wishbone interface)
	clkb: in std_logic; 
	dob: out std_logic_vector(data_width-1 downto 0);
	addrb: in std_logic_vector(adr_width-1 downto 0));
end la_bram;

architecture la_bram_arch of la_bram is
-- Xilinx Virtex BRAM declaration for dual port memory with two different clocks
  component ramb4_S16_S16
	  port (wea, ena, rsta, clka: in std_logic;
	  addra: in std_logic_vector(7 downto 0);
	  dia: in std_logic_vector(15 downto 0);
	  doa: out std_logic_vector(15 downto 0);
	  web, enb, rstb, clkb: in std_logic;
	  addrb: in std_logic_vector(7 downto 0);
	  dib: in std_logic_vector(15 downto 0);
	  dob: out std_logic_vector(15 downto 0));
    end component;
  component ramb4_S8_S8
	  port (wea, ena, rsta, clka: in std_logic;
	  addra: in std_logic_vector(8 downto 0);
	  dia: in std_logic_vector(7 downto 0);
	  doa: out std_logic_vector(7 downto 0);
	  web, enb, rstb, clkb: in std_logic;
	  addrb: in std_logic_vector(8 downto 0);
	  dib: in std_logic_vector(7 downto 0);
	  dob: out std_logic_vector(7 downto 0));
    end component;
  component ramb4_S4_S4
	  port (wea, ena, rsta, clka: in std_logic;
	  addra: in std_logic_vector(9 downto 0);
	  dia: in std_logic_vector(3 downto 0);
	  doa: out std_logic_vector(3 downto 0);
	  web, enb, rstb, clkb: in std_logic;
	  addrb: in std_logic_vector(9 downto 0);
	  dib: in std_logic_vector(3 downto 0);
	  dob: out std_logic_vector(3 downto 0));
    end component;
  component ramb4_S2_S2
	  port (wea, ena, rsta, clka: in std_logic;
	  addra: in std_logic_vector(10 downto 0);
	  dia: in std_logic_vector(1 downto 0);
	  doa: out std_logic_vector(1 downto 0);
	  web, enb, rstb, clkb: in std_logic;
	  addrb: in std_logic_vector(10 downto 0);
	  dib: in std_logic_vector(1 downto 0);
	  dob: out std_logic_vector(1 downto 0));
    end component;
  component ramb4_S1_S1
	  port (wea, ena, rsta, clka: in std_logic;
	  addra: in std_logic_vector(11 downto 0);
	  dia: in std_logic_vector(0 downto 0);
	  doa: out std_logic_vector(0 downto 0);
	  web, enb, rstb, clkb: in std_logic;
	  addrb: in std_logic_vector(11 downto 0);
	  dib: in std_logic_vector(0 downto 0);
	  dob: out std_logic_vector(0 downto 0));
  end component;

  
  type ram_type is array ((2**adr_width)-1 downto 0) of std_logic_vector (data_width-1 downto 0); 
  signal RAM : ram_type; 
  signal read_adr: std_logic_vector(adr_width-1 downto 0); -- mem address
  signal zero: std_logic_vector(data_width-1 downto 0);
begin 
----------------------------------------------
-- single clock section
g_clk0: if two_clocks=0 generate
 process (clkb) 
  begin 
 	if (clkb'event and clkb = '1') then  
 		if (wea = '1') then 
 			RAM(conv_integer(addra)) <= dia; 
 		end if; 
 		read_adr<= addrb;
 	end if; 
 end process; 
  dob <= RAM( conv_integer(read_adr) );
end generate;

---------------------------------------------
-- double clock section
 zero<= (others=> '0');

g16: if two_clocks>0 and data_width=16 generate
	  ram16: ramb4_S16_S16
	    port map (wea=>wea, ena=>'1', rsta=>'0', clka=>clka,
	  		addra=> addra, dia=>dia, doa=> open,
	        web=>'0', enb=>'1', rstb=>'0', clkb=>clkb,
	        addrb=> addrb, dib=> zero, dob=> dob);
  end generate;
g8: if two_clocks>0 and data_width=8 generate
	  ram8: ramb4_S8_S8
	    port map (wea=>wea, ena=>'1', rsta=>'0', clka=>clka,
	  		addra=> addra, dia=>dia, doa=> open,
	        web=>'0', enb=>'1', rstb=>'0', clkb=>clkb,
	        addrb=> addrb, dib=> zero, dob=> dob);
  end generate;
g4: if two_clocks>0 and data_width=4 generate
	  ram4: ramb4_S4_S4
	    port map (wea=>wea, ena=>'1', rsta=>'0', clka=>clka,
	  		addra=> addra, dia=>dia, doa=> open,
	        web=>'0', enb=>'1', rstb=>'0', clkb=>clkb,
	        addrb=> addrb, dib=> zero, dob=> dob);
  end generate;
g2: if two_clocks>0 and data_width=2 generate
	  ram8: ramb4_S2_S2
	    port map (wea=>wea, ena=>'1', rsta=>'0', clka=>clka,
	  		addra=> addra, dia=>dia, doa=> open,
	        web=>'0', enb=>'1', rstb=>'0', clkb=>clkb,
	        addrb=> addrb, dib=> zero, dob=> dob);
  end generate;
g1: if two_clocks>0 and data_width=1 generate
	  ram8: ramb4_S1_S1
	    port map (wea=>wea, ena=>'1', rsta=>'0', clka=>clka,
	  		addra=> addra, dia=>dia, doa=> open,
	        web=>'0', enb=>'1', rstb=>'0', clkb=>clkb,
	        addrb=> addrb, dib=> zero, dob=> dob);
  end generate;

 
end la_bram_arch;
