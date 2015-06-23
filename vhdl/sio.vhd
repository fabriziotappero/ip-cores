----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:41:22 11/11/2007 
-- Design Name: 
-- Module Name:    sio - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.Vcomponents.ALL;

use work.types.ALL;



entity mysio is
    Port ( gclk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
           rx : in  STD_LOGIC;
           tx : out  STD_LOGIC;
			  
			  lcd_rs : out std_logic;
			  lcd_rw : out std_logic;
			  lcd_e  : out std_logic;
			  lcd_d  : out std_logic_vector(3 downto 0);

			  button : in std_logic_vector(7 downto 0);

           strataflash_oe : out std_logic;
           strataflash_ce : out std_logic;
           strataflash_we : out std_logic;
			  
			  red  : out std_logic;
			  green  : out std_logic;
			  blue  : out std_logic;
 			  vs  : out std_logic;
			  hs  : out std_logic;

			  test : out std_logic_vector(7 downto 0)
			  );
end mysio;




architecture Behavioral of mysio is


component vga is
  port(reset  : in std_logic;
		 clk50_in  : in std_logic;
       red_out   : out std_logic;
       green_out : out std_logic;
       blue_out  : out std_logic;
       hs_out    : out std_logic;
       vs_out    : out std_logic;
		 
		 addrb     : in std_logic_VECTOR(12 downto 0);
		 dinb      : in std_logic_VECTOR(7 downto 0);
		 web       : in std_logic		 
	);
end component;


component sc_uart is
	generic (addr_bits : integer;
		clk_freq : integer;
		baud_rate : integer;
		txf_depth : integer; txf_thres : integer;
		rxf_depth : integer; rxf_thres : integer);
	port (
		clk		: in std_logic;
		reset	: in std_logic;
	
	-- SimpCon interface
	
		address		: in std_logic_vector(addr_bits-1 downto 0);
		wr_data		: in std_logic_vector(31 downto 0);
		rd, wr		: in std_logic;
		rd_data		: out std_logic_vector(31 downto 0);
	--	rdy_cnt		: out unsigned(1 downto 0);
	
		txd		: out std_logic;
		rxd		: in std_logic;
		ncts	: in std_logic;
		nrts	: out std_logic
	);
end component;





signal nreset : std_logic;


signal uwr_gen: std_logic;
signal urd_gen: std_logic;
signal urd_data: slv_32;
signal uwr_data: slv_32;
signal uaddr: std_logic_vector(0 downto 0);

signal pmem_addr_m: std_logic_VECTOR(9 downto 0);
signal pmem_din_m: slv_16;
signal pmem_we_m: std_logic;

signal vmem_addr_m: std_logic_VECTOR(12 downto 0);
signal vmem_din_m: slv_8;
signal vmem_we_m: std_logic;

signal lcd_rs_l : std_logic;
signal lcd_rw_l : std_logic;
signal lcd_e_l  : std_logic;
signal lcd_d_l  : std_logic_vector(3 downto 0);
			  
signal test_led : std_logic_vector(7 downto 0);



constant LAST_ADDR: std_logic_VECTOR(9 downto 0) := "0001111111";						



component pmem is
	port (
		addra: IN std_logic_VECTOR(9 downto 0);
		addrb: IN std_logic_VECTOR(9 downto 0);
		clka: IN std_logic;
		clkb: IN std_logic;
		dinb: IN std_logic_VECTOR(15 downto 0);
		douta: OUT std_logic_VECTOR(15 downto 0);
		web: IN std_logic
	);
end component;

component cpu is
    Port (	clk_in : in STD_LOGIC;

				reset_in : in STD_LOGIC;
			  
				paddr: out std_logic_VECTOR(9 downto 0);
				pdin: in std_logic_VECTOR(15 downto 0);
			  
				extrd: out std_logic;
				extwr: out std_logic;
				extaddr: out slv_16;			
				extdin: in slv_16;
				extdout: out slv_16				
			);
end component;



signal extaddr: 				slv_16;
signal extdin: 				slv_16;
signal extdout: 				slv_16;
signal extwr: 					std_logic;
signal extrd: 					std_logic;

signal was_uart:				std_logic;
signal was_button:			std_logic;



--
signal mem_addr_cpu: 		std_logic_VECTOR(9 downto 0);
signal mem_dout_cpu: 		slv_16;	

	
begin

  --
  --StrataFLASH must be disabled to prevent it conflicting with the LCD display 
  --
  strataflash_oe <= '1';
  strataflash_ce <= '1';
  strataflash_we <= '1';


nreset <= not reset;


vga_c: vga 
  port map(
		reset 	 => reset,
		clk50_in  => gclk,
      red_out   => red,
      green_out => green,
      blue_out  => blue,
      hs_out    => hs,
      vs_out    => vs,
		addrb     => vmem_addr_m,
		dinb      => vmem_din_m,
		web       => vmem_we_m
    );


sc_uartc: sc_uart
  generic map (1, 50000000, 115000, 1, 1, 1, 1)
  port map(
    clk => gclk,
	 reset => nreset,
	 txd => tx,
	 rxd => rx,
	 
	 address => uaddr,
	 rd_data => urd_data,
	 wr_data => uwr_data,
	 rd => urd_gen,
	 wr => uwr_gen,
	 
	 ncts => '0'
  );

  
pmemc: pmem
  port map(
		clka => gclk,
		clkb => gclk,
		addrb => pmem_addr_m,
		addra => mem_addr_cpu,
		dinb => pmem_din_m,
		douta => mem_dout_cpu,
		web => pmem_we_m
  );

  
diogenes_cpu: cpu
  port map(
		clk_in => gclk,

		reset_in => reset,
		  
		paddr => mem_addr_cpu,
		pdin => mem_dout_cpu,
		extaddr => extaddr,
		extwr => extwr,
		extrd => extrd,
		extdin => extdin,
		extdout => extdout
  );
  
  
	lcd_rs <= lcd_rs_l;
	lcd_rw <= lcd_rw_l;
	lcd_e  <= lcd_e_l;
	lcd_d  <= lcd_d_l;
	test <= test_led;
	
	
	-- connect uart asynchronous
	process (extaddr, urd_data, uwr_data, extdout, extrd, extwr, test_led)
	begin
		uaddr <= (others => '0');
		uaddr(0) <= extaddr(0);
		uwr_data <= (others => '0');
		uwr_data(7 downto 0) <= extdout(7 downto 0);
	
		--urd_gen <= '0';
		uwr_gen <= '0';
	   urd_gen <= extrd;

		if(extaddr(15)='0') then
			if (extaddr(7 downto 6) = "10") then
				uwr_gen <= extwr;
			end if;
		end if;

      if was_uart='1' then
			extdin <= urd_data(15 downto 0);
		elsif was_button='1' then
			extdin <= "00000000" & button;
      end if;

	end process;
	
	
	
	process (reset, gclk)
	begin
	
		if(reset='0') then
			lcd_rs_l <= '0';
			lcd_rw_l <= '0';
			lcd_e_l <= '0';
			lcd_d_l <= (others => '0');
			test_led <= (others => '0');
			
			vmem_addr_m <= (others => '0');
			vmem_din_m <= (others => '0');
			vmem_we_m <= '0';
			
			pmem_addr_m <= (others => '0');
			pmem_din_m <= (others => '0');
			pmem_we_m <= '0';

			was_uart <= '0';
		elsif rising_edge(gclk) then			
			
			if (extwr='1') then
				if (extaddr(15) = '0') then
					if extaddr(7 downto 6) = "11" then
						if extaddr(5 downto 4) = "00" then
							lcd_rs_l <= extdout(0);
						elsif extaddr(5 downto 4) = "01" then
							lcd_rw_l <= extdout(0);
						elsif extaddr(5 downto 4) = "10" then
							lcd_e_l <= extdout(0);
						elsif extaddr(5 downto 4) = "11" then
							lcd_d_l <= extdout(3 downto 0);
						end if;
					elsif extaddr(7 downto 6) = "00" then
						if(extwr='1') then
							test_led(7 downto 0) <= extdout(7 downto 0);
						end if;
					end if;
				elsif (extaddr(14) = '0') then
					pmem_addr_m <= extaddr(9 downto 0);
					pmem_din_m <= extdout(15 downto 0);
					pmem_we_m <= extwr;
				elsif (extaddr(14) = '1') then
					vmem_addr_m <= extaddr(12 downto 0);
					vmem_din_m <= extdout(7 downto 0);
					vmem_we_m <= extwr;
				end if;
			elsif (extrd='1') then
					was_uart <= '0';
					was_button <= '0';

					if (extaddr(15)='0') then
						if (extaddr(7 downto 6) = "10") then
							was_uart <= '1';
						elsif (extaddr(7 downto 6) = "00") then
							was_button <= '1';
						end if;
					end if;
			end if;
		end if;
	end process;
	
end Behavioral;

