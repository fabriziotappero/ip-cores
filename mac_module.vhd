library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity mac_module is
	generic( CODE_BITS : integer := 10;
				ROW : natural := 480;
				ROW_BITS : natural := 9;
				COL : natural := 640;
				COL_BITS : natural := 10);
				
	port (
		code : in std_logic_vector(CODE_BITS-1 downto 0);
		pdata_in : in std_logic_vector(7 downto 0);			-- input greyvalue (0...255)
		fsync_in : in std_logic;
		rsync_in : in std_logic;
		Reset : in std_logic;
		pclk : in std_logic;
		selectspace	: in std_logic;
		tablePreset : in std_logic;
      compuCode : in  STD_LOGIC_VECTOR (9 downto 0);
		mergeEnable : in  STD_LOGIC;
		compute : in  STD_LOGIC;
		divready_out : out std_logic;
		x_cog : out  std_logic_vector(16 downto 0);
		y_cog : out  std_logic_vector (16 downto 0) 
	);
end mac_module;


architecture behavioral of mac_module is

signal compute_delay, divide_init, done_y, done_x: std_logic;					-- control signals for division
signal postx_numerator_stored,posty_numerator_stored,x_numerator_stored,y_numerator_stored,Sx_numerator,Tx_numerator,Sy_numerator,Ty_numerator: std_logic_vector(33 downto 0) :=  (others => '0');	
signal Sdenominator,Tdenominator : std_logic_vector(18 downto 0) :=  (others => '0');	--denominator
signal Sx_numerator_stored,Tx_numerator_stored,Sy_numerator_stored,Ty_numerator_stored: std_logic_vector(33 downto 0) :=  (others => '0');
signal Sdenominator_stored,Tdenominator_stored,denominator_stored,postdenominator_stored: std_logic_vector(18 downto 0):=  (others => '0');
signal merge_denom_input,denominator_input : std_logic_vector(18 downto 0) := (others => '0');
signal y_numerator_input,merge_ynum_input : std_logic_vector(33 downto 0) := (others => '0');
signal x_numerator_input,merge_xnum_input : std_logic_vector(33 downto 0) := (others => '0');
signal runPreset : std_logic;

signal c_count, c_count_delay : std_logic_vector(COL_BITS-1 downto 0) := (others => '0'); 
signal r_count : std_logic_vector(ROW_BITS-1 downto 0) := (others => '0'); 
signal rsync_delayed : std_logic;
signal pdata_delayed : std_logic_vector(7 downto 0);
signal prod_x : std_logic_vector(17 downto 0);
signal prod_y : std_logic_vector(16 downto 0);


signal SaddrR,SaddrW : std_logic_vector(9 downto 0) := (others => '0');	--adress vectors in RAM S
signal TaddrR,TaddrW,macaddrw,mergeaddrw : std_logic_vector(9 downto 0) := (others => '0');	--adress vectors in RAM T
signal readaddr,readaddr_delayed, preaddr : std_logic_vector(9 downto 0) := "0000000000";
signal Twe,Swe,setwe,mergewe,prewe: std_logic := '0';	--control signals for RAM access
signal mergereadaddr, compuCodeDelayed : std_logic_vector(9 downto 0);
signal xNumeratorDelayed, yNumeratorDelayed : std_logic_vector(33 downto 0);
signal denominatorDelayed : std_logic_vector(18 downto 0);
signal mergeEnableDelayed : std_logic;


--type ppstatetype is (startup1,startup2,startup3,startup4);
--signal ppstate : ppstatetype;




begin

	
	s_div_y : entity work.serial_div2 
--	generic map (	M_PP	=> 31, N_PP	=> 17, R_PP	=> 0, S_PP => 0, COUNT_WIDTH_PP => 5,
--a					HELD_OUTPUT_PP => 1	)
	PORT MAP(
		clk_i 		=> pclk,
		clk_en_i 	=> '1',
		rst_i 		=> reset,
		divide_i 	=> divide_init,
		dividend_i 	=> posty_numerator_stored,
		divisor_i 	=> postdenominator_stored,	
		done_o 		=> done_y,
		quotient_o	=> y_cog
		);	 
		
	s_div_x : entity work.serial_div2 
--	generic map (	M_PP	=> 31, N_PP	=> 17, R_PP	=> 0, S_PP => 0, COUNT_WIDTH_PP => 5,
--a					HELD_OUTPUT_PP => 1	)
	PORT MAP(
		clk_i 		=> pclk,
		clk_en_i 	=> '1',
		rst_i 		=> reset,
		divide_i 	=> divide_init,
		dividend_i 	=> postx_numerator_stored,
		divisor_i 	=> postdenominator_stored,	
		done_o 		=> done_x,
		quotient_o	=> x_cog
		);			


ram_xnumS : entity work.ram_num port map ( 
			  addrW => SaddrW,
           din => Sx_numerator,
           we => Swe,
           addrR => SaddrR,
           dout => Sx_numerator_stored,
           clk => pclk);
			  
ram_xnumT : entity work.ram_num port map ( 
			  addrW => TaddrW,
           din => Tx_numerator,
           we => Twe,
           addrR => TaddrR,
           dout => Tx_numerator_stored,
           clk => pclk);
			  
ram_ynumS : entity work.ram_num port map ( 
			  addrW => SaddrW,
           din => Sy_numerator,
           we => Swe,
           addrR => SaddrR,
           dout => Sy_numerator_stored,
           clk => pclk);

ram_ynumT : entity work.ram_num port map ( 
			  addrW => TaddrW,
           din => Ty_numerator,
           we => Twe,
           addrR => TaddrR,
           dout => Ty_numerator_stored,
           clk => pclk);
			  
ram_denomS : entity work.ram_denom port map ( 
			  addrW => SaddrW,
           din => Sdenominator,
           we => Swe,
           addrR => SaddrR,
           dout => Sdenominator_stored,
           clk => pclk);
			  
ram_denomT : entity work.ram_denom port map ( 
			  addrW => TaddrW,
           din => Tdenominator,
           we => Twe,
           addrR => TaddrR,
           dout => Tdenominator_stored,
           clk => pclk);
			  


--=============== Multiplexer statements for selecting memories for interlieving of table accesses =======
--=============== selectSpace is the signal that controls interlieveing per frames                 =======

----------  Memory inputs -----------------------------



	Swe 	  				<= Setwe when selectspace ='0' else 
								mergewe when runPreset = '0' else
								prewe;	
	Sdenominator 		<= denominator_input when selectspace ='0' else 
								merge_denom_input when runPreset = '0' else
								(others => '0');	
	Sx_numerator	  	<= x_numerator_input when selectspace='0' else
								merge_xnum_input  when runPreset = '0' else
								(others => '0');	
	Sy_numerator	  	<= y_numerator_input when selectspace='0' else 
								merge_ynum_input when runPreset = '0' else
								(others => '0');	
	SaddrR  				<= readaddr when selectspace='0' else 
								mergereadaddr;
	Saddrw				<= macaddrw when selectspace = '0' else
								mergeaddrw when runPreset = '0' else
								preaddr;

	Twe 	  				<= Setwe when selectspace='1' else 
								mergewe when runPreset = '0' else
								prewe;	
	Tdenominator 		<= denominator_input when selectspace='1' else 
								merge_denom_input when runPreset = '0' else
								(others => '0');	
	Tx_numerator	  	<= x_numerator_input when selectspace='1' else 
								merge_xnum_input when runPreset = '0' else
								(others => '0');	
	Ty_numerator	  	<= y_numerator_input when selectspace='1' else 
								merge_ynum_input when runPreset = '0' else
								(others => '0');	
	TaddrR  				<= readaddr when selectspace='1' else 
								mergereadaddr;
	Taddrw				<= macaddrw when selectspace = '1' else
								mergeaddrw when runPreset = '0' else
								preaddr;


-------------------------------------------------------
	
----------  Memory outputs ----------------------------

	x_numerator_stored	<=	Sx_numerator_stored when selectSpace = '0' else
									Tx_numerator_stored; 
	y_numerator_stored	<=	Sy_numerator_stored when selectSpace = '0' else
									Ty_numerator_stored;
	denominator_stored	<=	Sdenominator_stored when selectSpace = '0' else
									Tdenominator_stored;
	postx_numerator_stored	<=	Sx_numerator_stored when selectSpace = '1' else
									Tx_numerator_stored; 
	posty_numerator_stored	<=	Sy_numerator_stored when selectSpace = '1' else
									Ty_numerator_stored;
	postdenominator_stored	<=	Sdenominator_stored when selectSpace = '1' else
									Tdenominator_stored;
	

-------------------------------------------------------
-- Signal mappings

	mergereadaddr <= compuCode;
	mergeaddrw <= compuCodeDelayed;
	mergewe <= mergeEnableDelayed;
	merge_denom_input <= postdenominator_stored + denominatorDelayed;
	merge_xnum_input <= postx_numerator_stored + xNumeratorDelayed;
	merge_ynum_input <= posty_numerator_stored + yNumeratorDelayed;


	divready_out <= done_x and done_y;
	--divide_init <= compute or compute_delay;
	divide_init <= compute_delay;


mac: process(pclk,Reset) 

begin
	if reset = '1' then	
		SetWe <= '0';
		y_numerator_input <= (others=>'0');
		denominator_input <= (others=>'0');
		x_numerator_input <= (others=>'0');
		c_count <= (others=>'0');
		r_count <= (others=>'0');
	elsif fsync_in = '1' then
		c_count <= (others => '0');
		r_count <= (others => '0');
	elsif pclk'event and pclk = '1' then	
	
		if rsync_in = '0' and rsync_delayed = '1' then
			c_count <= (others => '0');
			r_count <= r_count + 1;
		elsif rsync_in = '1' then
			c_count <= c_count + 1;		--increment coloumn counter
		end if;
		
		if readaddr_delayed = macaddrw then
			denominator_input <= denominator_input + pdata_delayed;
			x_numerator_input <= x_numerator_input + prod_x; 
			y_numerator_input <= y_numerator_input + prod_y; 
			
		else
			denominator_input <= denominator_stored + pdata_delayed;
			x_numerator_input <= x_numerator_stored + prod_x; 
			y_numerator_input <= y_numerator_stored + prod_y;
		end if;
		
		if readaddr_delayed = 0 then
			denominator_input <= (others=>'0');
			x_numerator_input <= (others=>'0');
			y_numerator_input <= (others=>'0');
			SetWe <= '0';
		else
			SetWe <= '1';
		end if;
		
		prod_x <= pdata_in * c_count_delay;
		prod_y <= pdata_in * r_count;
		
		rsync_delayed <= rsync_in;
		readaddr_delayed <= readaddr;
		macaddrw <= readaddr_delayed;
		pdata_delayed <= pdata_in;
		c_count_delay <= c_count;
		
	end if; -- pclk'event and pclk = '1'
	
end process mac;

readaddr <= code;


merge: process (pclk, reset)	
begin
	if reset = '1' then	

		compuCodeDelayed <= (others=>'0');
			
	elsif pclk'event and pclk = '1' then
		compuCodeDelayed <= compuCode;
		xNumeratorDelayed <= postx_numerator_stored;
		yNumeratorDelayed <= posty_numerator_stored;
		denominatorDelayed <= postdenominator_stored;	
		mergeEnableDelayed <= mergeEnable;
		compute_delay <= compute;
	end if;
	
end process merge;

preset : process (pclk, reset)
	begin
		if reset = '1' then	
			preaddr <= "0000000000";
			runPreset <= '1';
	
		elsif pclk'event and pclk = '1' then
			prewe <= '0';
			if tablePreset = '1' then
				preaddr <= (others => '0');
				runPreset <= '1';
				prewe <= '1';
			elsif preaddr = "1111111111" then
				preaddr <= "1111111111";
				runPreset <= '0';
			else
				prewe <= '1';
				preaddr <= preaddr +1;
			end if;
		end if;
	end process preset;
	
			
end behavioral;
	