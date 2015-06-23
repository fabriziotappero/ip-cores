-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pal is 
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
end pal;

architecture behaviour of pal is

component paltimer is
    Port ( 
		clk : in std_logic;
		clk15m : in std_logic;		
		reset : in std_logic;
		en_sync : out std_logic;
		en_schwarz : out std_logic;
		en_bild : out std_logic;
		en_vertbr : out std_logic;
		en_verteq : out std_logic;
		en_burst : out std_logic;
		phase : out std_logic;
		framereset : out std_logic;
		sync : out std_logic;
		readmem : out std_logic;
		austastung : out std_logic
	);
end component;

component dds is
    Port ( 
			clk : in std_logic;
			reset : in std_logic;
			phase : in std_logic_vector (1 downto 0);
			addi : out std_logic_vector (8 downto 0);
			data : out std_logic_vector (15 downto 0)
	);
end component;

component rgb2yuv is
    Port ( 
			clk : in std_logic;
			reset : in std_logic;
			in_r, in_g, in_b : in std_logic_vector (4 downto 0);
			out_y, out_u, out_v : out std_logic_vector (11 downto 0)
	);
end component;

component myfir is
	generic (
		TAPS : integer := 16
	);
	port (
		clk : in std_logic;
		reset : in std_logic;
		input : in std_logic_vector(11 downto 0);
		output : out std_logic_vector(11 downto 0)
	);
end component;

component delay is
	generic (
		TAPS : integer := 8 -- group-delay der FIR-Filter ist 500ns
	);
	port (
		clk : in std_logic;
		reset : in std_logic;
		input : in std_logic_vector(11 downto 0);
		output : out std_logic_vector(11 downto 0)
	);
end component;


signal cos_data : signed (15 downto 0);
signal sin_data : signed (15 downto 0);

signal pre_yuv_y : signed (11 downto 0);
signal pre_yuv_u : signed (11 downto 0);
signal pre_yuv_v : signed (11 downto 0);

signal pre_yuv_u2 : signed (11 downto 0);
signal pre_yuv_v2 : signed (11 downto 0);



signal yuv_y : signed (11 downto 0);
signal yuv_u : signed (11 downto 0);
signal yuv_v : signed (11 downto 0);


signal tmr_phase : std_logic;
signal tmr_sync : std_logic;
signal tmr_austastung : std_logic;
signal tmr_en_bild : std_logic;
signal tmr_en_burst : std_logic;

--signal prevideo : signed (16 downto 0);
--signal preout_u : signed (16 downto 0);
--signal preout_v : signed (16 downto 0);
--signal preout_y : signed (16 downto 0);

--pipelining wegen geschwindigkeit
signal modu : signed(27 downto 0);
signal modv : signed(27 downto 0);
signal mody : signed (11 downto 0);

signal modus : signed(28 downto 0);
signal modvs : signed(28 downto 0);
signal modys : signed(28 downto 0);


-- workaround für xilinx
signal input_fir1 : std_logic_vector (11 downto 0);
signal input_fir2 : std_logic_vector (11 downto 0);
signal input_delay : std_logic_vector (11 downto 0);

signal output_fir1 : std_logic_vector (11 downto 0);
signal output_fir2 : std_logic_vector (11 downto 0);
signal output_delay : std_logic_vector (11 downto 0);

signal dds1_data : std_logic_vector (15 downto 0);
signal dds2_data : std_logic_vector (15 downto 0);

signal rgb_out_v : std_logic_vector (11 downto 0);
signal rgb_out_u : std_logic_vector (11 downto 0);
signal rgb_out_y : std_logic_vector (11 downto 0);


begin
	input_fir1 <= std_logic_vector(pre_yuv_u);
	input_fir2 <= std_logic_vector(pre_yuv_v);
	input_delay <= std_logic_vector(pre_yuv_y);
		
	yuv_u <= signed(output_fir1);
	yuv_v <= signed(output_fir2);
	yuv_y <= signed(output_delay);

I_4: myfir port map (
	clk => clk15M,
	reset => reset,
	input => input_fir1,
	output => output_fir1
);

I_5: myfir port map (
	clk => clk15M,
	reset => reset,
	input => input_fir2,
	output => output_fir2
);

I_6: delay port map (
	clk => clk15M,
	reset => reset,
	input => input_delay,
	output => output_delay

);

I_0:	paltimer 	port map (
			clk => clk, 
			clk15m => clk15m,
			reset => reset, 
			en_sync => open,
			en_schwarz => open,
			en_bild => tmr_en_bild,
			en_vertbr => open,
			en_verteq => open,
			en_burst => tmr_en_burst,
			phase => tmr_phase,
			sync => tmr_sync,
			austastung => tmr_austastung,
			framereset => framereset,
			readmem => readmem
		);

I_1:	dds	port map (
			clk => clk,
			reset => reset,
			phase => "01",	-- cosinus
			addi => open,
			data => dds1_data
		);
		
	cos_data <= signed(dds1_data);
	sin_data <= signed(dds2_data);

I_2:	dds	port map (
			clk => clk,
			reset => reset,
			phase => "00",	-- sinus
			addi => open,
			data => dds2_data
		);

I_3:	rgb2yuv	port map (
			clk => clk15m,
			reset => reset,
			in_r => in_r, 
			in_g => in_g,
			in_b => in_b,
			out_y => rgb_out_y,
			out_u => rgb_out_u,
			out_v => rgb_out_v
		);

pre_yuv_y <= signed(rgb_out_y);
pre_yuv_u2 <= signed(rgb_out_u);
pre_yuv_v2 <= signed(rgb_out_v);


en_bild <= tmr_en_bild;


process (tmr_en_burst, tmr_austastung, tmr_en_bild, pre_yuv_u2, pre_yuv_v2)
begin
	if tmr_austastung = '1' then
		if tmr_en_bild='1' then
			pre_yuv_u <= pre_yuv_u2;
			pre_yuv_v <= pre_yuv_v2;
		elsif tmr_en_burst = '1' then
			pre_yuv_u <= conv_signed(-171,12);
			pre_yuv_v <= conv_signed(171,12);
		else
			pre_yuv_u <= conv_signed(0,12);
			pre_yuv_v <= conv_signed(0,12);
		end if;
	else
		pre_yuv_u <= conv_signed(0,12);
		pre_yuv_v <= conv_signed(0,12);
	end if;
end process;

process (clk, reset)

variable skaleuv : signed(16 downto 0) := conv_signed(30000,17);--40000
variable skaley : signed(16 downto 0) := conv_signed(36408,17);
variable skaleburst : signed (11 downto 0) := conv_signed(240,12); 
variable psin : signed (15 downto 0);

variable preout_u : signed (16 downto 0);
variable preout_v : signed (16 downto 0);
variable preout_y : signed (16 downto 0);
variable prevideo : signed (16 downto 0);

variable bursts : signed (27 downto 0);

variable burstsin : signed (17 downto 0);
variable burstcos : signed (17 downto 0);
variable burst17 : signed (16 downto 0);

variable i_output : signed (16 downto 0);

begin

	if reset='0' then
	   output <= (others => '0');
	elsif clk'event and clk='1' then
		if tmr_phase='1' then
			psin := -sin_data;
		else
			psin := sin_data;
		end if;
	
-- u und v modulieren		
		modu <= cos_data * yuv_u;
		modv <= psin * yuv_v;
		mody <= yuv_y;

-- jetzt skalieren
		modus <= modu (26 downto 15) * skaleuv;
		modvs <= modv (26 downto 15) * skaleuv;		
		modys <= mody * skaley; -- yuv_y

		preout_u := modus (26 downto 10);
		preout_v := modvs (26 downto 10);	
		preout_y := modys (26 downto 10);

-- Y, U und V jetzt zum Signal zusammenbauen
		prevideo := preout_u + preout_v;

		if tmr_austastung = '1' and tmr_en_bild='1' then
			prevideo := prevideo + preout_y;
		end if;
		
		if tmr_sync ='0' then
			i_output := (others => '0');
		else
				i_output := conv_signed(14563,17) + prevideo;
		end if;
		
		output <= conv_std_logic_vector (i_output (15 downto 0),16);
		
	end if;
end process;

end behaviour;
