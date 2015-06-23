library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga is
  port(reset	  : in std_logic;
		 clk50_in  : in std_logic;
       red_out   : out std_logic;
       green_out : out std_logic;
       blue_out  : out std_logic;
       hs_out    : out std_logic;
       vs_out    : out std_logic;
 
		 addrb: IN std_logic_VECTOR(12 downto 0);
		 dinb: IN std_logic_VECTOR(7 downto 0);
		 web: IN std_logic
		 );
end vga;

architecture Behavioral of vga is

component video_ram is
	port (
	addra: IN std_logic_VECTOR(12 downto 0);
	addrb: IN std_logic_VECTOR(12 downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(7 downto 0);
	douta: OUT std_logic_VECTOR(7 downto 0);
	web: IN std_logic
	);
end component;

signal clk25              : std_logic;

signal horizontal_counter : std_logic_vector (9 downto 0);
signal vertical_counter   : std_logic_vector (9 downto 0);
 
signal count : std_logic_vector (9 downto 0);

signal v_addr : std_logic_VECTOR(12 downto 0);
signal v_data : std_logic_VECTOR(7 downto 0);

signal pixel : std_logic_vector(3 downto 0);
signal pixel_buf : std_logic_vector(7 downto 0);


begin

video_ram_c: video_ram 
  port map(
		addra => v_addr,
		addrb => addrb,
		clka => clk50_in,
		clkb => clk50_in,
		dinb => dinb,
		douta => v_data,
		web => web
	);	

-- generate a 25Mhz clock
process (clk50_in, reset)
	variable temp: std_logic_vector(9 downto 0) := (others => '0');
begin
	if reset='0' then
	
		clk25 <= '1';
--		horizontal_counter <= (others => '0'); --"1101110000";
--		vertical_counter <= (others => '0'); --"1111011001";
		hs_out <= '1';
		vs_out <= '1';
		blue_out <= '0';
		red_out <= '0';
		green_out <= '0';
--		pixel_buf <= (others => '0');
--		pixel <= (others => '0');
		v_addr <= (others => '0');
	
	elsif rising_edge(clk50_in) then

    if (clk25 = '0') then ----------- 25mhz rising edge
  
		clk25 <= '1';
		
		if (horizontal_counter < "1010000000" ) -- 640
		and (vertical_counter < "0111100000" )  -- 480 
		and (horizontal_counter >= "0000000000" ) 
		and (vertical_counter >= "0000000000" ) then 
			red_out <= pixel(0);
			green_out <= pixel(1);
			blue_out <= pixel(2);
		else
			red_out <= '0';
			green_out <= '0';
			blue_out <= '0';		
		end if;
		if (horizontal_counter >    "1101110000" )
		and (horizontal_counter < "1111010001" ) then -- 96+1 
			hs_out <= '0';
		else
			hs_out <= '1';
		end if;
		if (vertical_counter >    "1111011001" )
		and (vertical_counter < "1111011100" ) then -- 2+1
			vs_out <= '0';
		else
			vs_out <= '1';
		end if;
		horizontal_counter <= horizontal_counter+"0000000001";
		if (horizontal_counter="1010010000") then              -- 800 - 144
			vertical_counter <= vertical_counter+"0000000001";
			horizontal_counter <= "1101110000";
		end if;
		if (vertical_counter="0111101110") then		           -- 521 - 39
			vertical_counter <= "1111011001";
		end if;

    else                 ----------- 25mhz falling edge

		clk25 <= '0';
	  
	   -- tile index:   0yyy xxxx
	   -- tile address: yyyVVV 1xxxxHH
	
		if horizontal_counter(0) = '0' then
			temp := horizontal_counter(9 downto 0) + "0000000010";
			v_addr <= vertical_counter(8 downto 3) & temp(9 downto 3); 
			pixel_buf <= v_data;
			pixel <= v_data(7 downto 4);
		elsif horizontal_counter(0) = '1' then
			temp := horizontal_counter(9 downto 0) + "0000000001";
			v_addr <= v_data(6 downto 4) & vertical_counter(2 downto 0) & "1" & v_data(3 downto 0) & temp(2 downto 1);
			pixel <= pixel_buf(3 downto 0);
		end if;
	 
	 end if;
	 
  end if;
end process;

-- 144 horizontal blank interval + 16 before incrementing vsync
-- 39 vertical blank interval + 2 before reseting


end Behavioral;
