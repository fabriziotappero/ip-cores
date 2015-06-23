-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
--
--  clkin = 45MHz
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity miniga is
	generic (
		ADR_WIDTH : integer := 19; -- A0 bis A18
		DATA_WIDTH : integer := 16 -- D0 bis A15
	);
	port (
		clkin : in std_logic;
		reset : in std_logic;
	
-- das digitale video	
		pixelclock : out std_logic;
		digitalvideo : out std_logic_vector (9 downto 0);
		
		ram_adr : out std_logic_vector ((ADR_WIDTH-1) downto 0);
		ram_data: inout std_logic_vector ((DATA_WIDTH-1) downto 0);
		ram_rd : out std_logic;
		ram_wr : out std_logic;
		ram_cs : out std_logic;	
		
-- spi-interface
		spi_ss : in std_logic;
		spi_clk : in std_logic;
		spi_data : in std_logic;
		spi_cd : in std_logic
	);
end miniga;


architecture behaviour of miniga is
signal clk60M : std_logic;
signal clk15M : std_logic;
signal clk45M : std_logic;
signal sync : std_logic;

signal adr1 : std_logic_vector ((ADR_WIDTH-1) downto 0);
signal data1_in : std_logic_vector ((DATA_WIDTH-1) downto 0);
signal data1_out : std_logic_vector ((DATA_WIDTH-1) downto 0);
signal wr1 : std_logic;
		
signal adr2 : std_logic_vector ((ADR_WIDTH-1) downto 0);
signal data2_in : std_logic_vector ((DATA_WIDTH-1) downto 0);
signal data2_out : std_logic_vector ((DATA_WIDTH-1) downto 0);
signal rd2 : std_logic;

signal picdata : std_logic_vector (15 downto 0);

signal framereset : std_logic;
signal readmem : std_logic;

signal en_bild : std_logic;

signal dummy : std_logic_vector (5 downto 0);

signal testbild_r : std_logic_vector (4 downto 0);
signal testbild_g : std_logic_vector (4 downto 0);
signal testbild_b : std_logic_vector (4 downto 0);

signal testbild_data : std_logic_vector (15 downto 0);

signal memory_data : std_logic_vector (15 downto 0);

signal testbild_en : std_logic;

component clk is
	port (
		clkin : in std_logic;
		reset : in std_logic;
		clk60M : out std_logic;
		clk45M : out std_logic;
		clk15M : out std_logic;
		pixclk : out std_logic;		
		sync : out std_logic
	);
end component;

component csr is
	generic (
		ADR_WIDTH : integer := 19; -- A0 bis A18
		DATA_WIDTH : integer := 16 -- D0 bis D15
	);
	port (
		clk4x : in std_logic;
		reset : in std_logic;
		clk : in std_logic;
		sync : in std_logic;
		
		ram_adr : out std_logic_vector ((ADR_WIDTH-1) downto 0);
		ram_data: inout std_logic_vector ((DATA_WIDTH-1) downto 0);
		ram_rd : out std_logic;
		ram_wr : out std_logic;
		ram_cs : out std_logic;	-- insg. 2 SRAMs mit verschiedene CS!

		adr1 : in std_logic_vector ((ADR_WIDTH-1) downto 0);
		data1_in : in std_logic_vector ((DATA_WIDTH-1) downto 0);
		data1_out : out std_logic_vector ((DATA_WIDTH-1) downto 0);
		rd1 : in std_logic;
		wr1 : in std_logic;
		
		adr2 : in std_logic_vector ((ADR_WIDTH-1) downto 0);
		data2_in : in std_logic_vector ((DATA_WIDTH-1) downto 0);
		data2_out : out std_logic_vector ((DATA_WIDTH-1) downto 0);
		rd2 : in std_logic;
		wr2 : in std_logic
	);
end component;

component spi is
	port (
		clk : in std_logic;
		reset : in std_logic;
		spi_ss : in std_logic;
		spi_clk : in std_logic;
		spi_data : in std_logic;
		spi_cd : in std_logic;
		
		out_adr : out std_logic_vector (18 downto 0);
		out_data : out std_logic_vector (15 downto 0);
		out_wr : out std_logic;
		
		testbild_en : out std_logic
	);
end component;

component pal is 
	Port (
		clk : in std_logic;
		clk15M : in std_logic;
		reset : in std_logic;
		output : out std_logic_vector (15 downto 0);
		in_r : in std_logic_vector (4 downto 0);
		in_g : in std_logic_vector (4 downto 0);
		in_b : in std_logic_vector (4 downto 0);
		framereset : out std_logic;
		en_bild : out std_logic;
		readmem: out std_logic
	);
end component;


begin

I3: pal port map (
	clk => clk45M,
	clk15M => clk15M,
	reset => reset,
	output (15 downto 6) => digitalvideo,
	output (5 downto 0) => dummy,
	in_r => picdata (15 downto 11),
	in_g => picdata (10 downto 6),
	in_b => picdata (4 downto 0),
	framereset => framereset,
	en_bild => en_bild,
	readmem => readmem

);

I0: clk port map (
	clkin => clkin,
	reset => reset,
	clk60M => clk60M,
	clk15M => clk15M,
	clk45M => clk45M,
	pixclk => pixelclock,
	sync => sync
);

I1: csr port map (
	clk4x => clk60M,
	clk => clk15M,
	reset => reset,
	sync => sync,
	
-- direkt mappen
	ram_data => ram_data,
	ram_cs => ram_cs,
-- die hier gehen erstmal über signale
	ram_adr => ram_adr,
	ram_rd => ram_rd,
	ram_wr => ram_wr,

-- spi
	adr1 => adr1,
	data1_in => data1_in,
	data1_out => data1_out,
	rd1 => '1',	-- wird nicht gelesen
	wr1 => wr1,
-- pixel lesen	
	adr2 => adr2,
	data2_in => data2_in,
	data2_out => data2_out,
	rd2 => rd2,
	wr2 => '1' -- wird nicht geschrieben
);

I2: spi port map (
	clk => clk15M,
	reset => reset,
	spi_ss => spi_ss,
	spi_clk => spi_clk,
	spi_data => spi_data,
	spi_cd => spi_cd,
	out_adr => adr1,
	out_data => data1_in,
	out_wr => wr1,
	testbild_en => testbild_en
	
);

testbild_data (15 downto 11) <= testbild_r;
testbild_data (10 downto 6) <= testbild_g;
testbild_data (4 downto 0) <= testbild_b;
testbild_data (5) <= '0';

with testbild_en select
   picdata <= testbild_data when '1', memory_data when others;
   

	process (clk15M, en_bild, reset)
	variable r2yctr : integer := 0;
	variable ctr2 : integer := 0;
	begin
		if en_bild='0' or reset='0' then
			r2yctr :=0 ;
			ctr2 := 0;
			testbild_r <= "00000";
			testbild_g <= "00000";
			testbild_b <= "00000";
		elsif clk15m'event and clk15m='1' then
			case r2yctr is
				when 0 => testbild_r <= "11111"; testbild_g <= "11111"; testbild_b <= "11111";
				when 1 => testbild_r <= "11111"; testbild_g <= "11111"; testbild_b <= "00000";
				when 2 => testbild_r <= "00000"; testbild_g <= "11111"; testbild_b <= "11111";
				when 3 => testbild_r <= "00000"; testbild_g <= "11111"; testbild_b <= "00000";
				when 4 => testbild_r <= "11111"; testbild_g <= "00000"; testbild_b <= "11111";
				when 5 => testbild_r <= "11111"; testbild_g <= "00000"; testbild_b <= "00000";
				when 6 => testbild_r <= "00000"; testbild_g <= "00000"; testbild_b <= "11111";
				when 7 => testbild_r <= "00000"; testbild_g <= "00000"; testbild_b <= "00000";
				when others => testbild_r <= "00000"; testbild_g <= "00000"; testbild_b <= "00000";
			end case;
			ctr2 := ctr2 + 1;
			if ctr2 = 90 then
				ctr2 := 0;
				r2yctr := r2yctr + 1;
				if (r2yctr = 8) then
					r2yctr := 0;
				end if;
			end if;
		end if;
	end process;

-- fpga adresse inkrementieren
process (clk15M, framereset, reset)
variable colctr, rowctr : integer;
variable adrctr : integer := 0;

begin
	if reset='0' or framereset='1' then
		adrctr := 0;
		rowctr := 0;
		colctr := 0;
		rd2 <='1';
	elsif clk15M'event and clk15M='1' then
		rd2 <='0';
		memory_data <= data2_out;
		if en_bild = '1' AND readmem = '1' then
			if colctr = 779 then
				adrctr := adrctr + 781;
				colctr := 0;
				rowctr := rowctr + 1;
			else
				adrctr := adrctr + 1;
				colctr := colctr + 1;
			end if;
			if rowctr = 288 then
				adrctr := 780;
				colctr := 0;
				rowctr := 289;
			elsif rowctr = 577 then
				adrctr := 0;
				colctr := 0;
				rowctr := 0;
			end if;
			adr2 <= conv_std_logic_vector(adrctr,19);
		else
			rd2 <= '1';
			adrctr := adrctr;
			memory_data <= (others => '0');
			adr2 <= (others => '0');
		end if;
	end if;
end process;

data2_in <= "0000000000000000";

end architecture;
