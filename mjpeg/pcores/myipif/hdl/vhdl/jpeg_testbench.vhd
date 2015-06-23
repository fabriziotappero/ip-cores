library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use std.textio.all;


entity jpeg_testbench is
	generic (
		jpeg_file_name: string := "data/lena.jpg";
		log_file_name : string := "data/lena.log"
	);
end entity jpeg_testbench;


architecture test of jpeg_testbench is

	

	component jpeg is
	port (
    	Clk			:  in std_logic;
		data_i		:  in std_logic_vector(31 downto 0);
		reset_i		:  in std_logic;
		
		eoi_o			: out std_logic;
		error_o		: out std_logic;
		
		context_o	: out std_logic_vector (3 downto 0);	
		red_o			: out STD_LOGIC_VECTOR (7 downto 0);
		green_o		: out STD_LOGIC_VECTOR (7 downto 0);
		blue_o		: out STD_LOGIC_VECTOR (7 downto 0);
		width_o		: out std_logic_vector(15 downto 0);
		height_o		: out std_logic_vector(15 downto 0);	
	
--		-- debug
--      LEDs			: out std_logic_vector(3 downto 0);
--		BUTTONs		:  in std_logic_vector(4 downto 0); -- 0:left, 1:right, 2:up, 3:down, 4:center
--		SWITCHEs		:  in std_logic_vector(3 downto 0);

		-- flow controll
		datavalid_i :  in std_logic;
		datavalid_o : out std_logic;
		ready_i		:  in std_logic;
		ready_o		: out std_logic
	);
	end component jpeg;




	component fifo_sim32 is
	generic
	(
		filename	: string := "out.log";
		log_time : integer := 1
	);
	port
	(
		rst	: in std_logic;
		clk	: in std_logic;
		din	: in std_logic_vector(31 downto 0);
		we		: in std_logic;
		full	: out std_logic
	);
	end component fifo_sim32;



	signal data : std_logic_vector(31 downto 0) :=(others=>'0');
	signal ddr_address : std_logic_vector(31 downto 0) :=(others=>'0');
	signal wea : std_logic :='0';
	signal Clk, reset : std_logic :='1';
	signal ready : std_logic :='0';
	signal counter : std_logic_vector(31 downto 0) := (others=>'0'); 
 
	signal jpeg_ready, jpeg_eoi, jpeg_error : std_logic :='0';

	signal fifo_sim32_data : std_logic_vector(31 downto 0) :=(others=>'0');
	signal fifo_sim32_wea, fifo_sim32_full, fifo_sim32_notfull : std_logic :='0';
	
	type ByteT is (c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36,c37,c38,c39,c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,c51,c52,c53,c54,c55,c56,c57,c58,c59,c60,c61,c62,c63,c64,c65,c66,c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,c78,c79,c80,c81,c82,c83,c84,c85,c86,c87,c88,c89,c90,c91,c92,c93,c94,c95,c96,c97,c98,c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,c112,c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,c125,c126,c127,c128,c129,c130,c131,c132,c133,c134,c135,c136,c137,c138,c139,c140,c141,c142,c143,c144,c145,c146,c147,c148,c149,c150,c151,c152,c153,c154,c155,c156,c157,c158,c159,c160,c161,c162,c163,c164,c165,c166,c167,c168,c169,c170,c171,c172,c173,c174,c175,c176,c177,c178,c179,c180,c181,c182,c183,c184,c185,c186,c187,c188,c189,c190,c191,c192,c193,c194,c195,c196,c197,c198,c199,c200,c201,c202,c203,c204,c205,c206,c207,c208,c209,c210,c211,c212,c213,c214,c215,c216,c217,c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228,c229,c230,c231,c232,c233,c234,c235,c236,c237,c238,c239,c240,c241,c242,c243,c244,c245,c246,c247,c248,c249,c250,c251,c252,c253,c254,c255);
   subtype Byte is ByteT;
   type ByteFileType is file of Byte;
	file jpeg_file : ByteFileType;


   -- integer to bit_vector conversion
   function int2bit_vec(A: integer; SIZE: integer) return BIT_VECTOR is
   	variable RESULT: BIT_VECTOR(SIZE-1 downto 0);
   	variable TMP: integer;
   begin
   	TMP:=A;
   	for i in 0 to SIZE-1 loop
   		if TMP mod 2 = 1 then RESULT(i):='1';
   		else RESULT(i):='0';
   		end if;
   		TMP:=TMP / 2;
   	end loop;
   	return RESULT;
   end;



begin 




------------------------------------------------------------
-- JPEG - Decoder
--------------------------------------------------------------
jpeg_decoder:jpeg
  port map
    (	Clk			=> Clk,
		data_i		=> data,
		reset_i		=> reset,
		
		eoi_o			=> jpeg_eoi,
		error_o		=> jpeg_error,
		
--		context_o	=>
		red_o		=> fifo_sim32_data(23 downto 16),
		green_o	=> fifo_sim32_data(15 downto 8),
		blue_o	=> fifo_sim32_data(7 downto 0),
--		width_o	=>	,
--		height_o	=> ,

		-- debug
--		LEDs			=> ,
--		BUTTONs		=> "11111",
--		SWITCHEs		=> "1111",

		datavalid_i => wea,
	   datavalid_o	=> fifo_sim32_wea,
		ready_i		=> ready,
		ready_o		=> jpeg_ready
    );
--------------------------------------------------------------



--------------------------------------------------------------
-- Output into file
--------------------------------------------------------------
fifo32_p : fifo_sim32
	generic map(
		filename => log_file_name
--		log_time => 0
	)
	port map(
		rst	=> reset,
		clk	=> Clk,
		din	=> fifo_sim32_data,
		we		=> fifo_sim32_wea,
		full	=> fifo_sim32_full
	);
fifo_sim32_data(31 downto 24) <= (others=>'0');
fifo_sim32_notfull <= not fifo_sim32_full;
--------------------------------------------------------------



-- **********************************************************************************************
-- * Wires
-- **********************************************************************************************

--wea	<= '0', '1' after 58 ns;
reset	<= '1', '0' after 13 ns; --, '1' after 50 us, '0' after 51 us; 



-- **********************************************************************************************
-- * Processes 
-- **********************************************************************************************


-- simulate a clock
clock_p: process
begin
	Clk <= '1';
	wait for 5 ns;
	Clk <= '0';
	wait for 5 ns;
end process;

ready <= '1';


---- counter
--counter_p: process
--begin
--	while true loop
--		wait until CLK='1';
--		counter <= counter +1;
--	end loop;
--end process;






file_input: process
	variable l: line;
	variable b1: Byte;
	variable b2: Byte;
	variable b3: Byte;
	variable b4: Byte;
begin
 	wea <= '0'; 
	wait for 20 ns;
 	
	-- read from file
	file_open(jpeg_file, jpeg_file_name, read_mode);
--	while true loop  
	while not(endfile(jpeg_file)) loop

--		-- reload image on eoi
--		if(endfile(jpeg_file)) then
--			wait until CLK='1';
--			wea <= '0';
--			file_close(jpeg_file);
--			wait until jpeg_eoi='1';
--			file_open(jpeg_file, jpeg_file_name, read_mode);
--			wait for 20 ns;
--		end if;		

		-- reload image on reset
--		if(reset='1') then
--			wea <= '0';
--			file_close(jpeg_file);
--			wait until reset='0';
--			file_open(jpeg_file, jpeg_file_name, read_mode);
--			wait for 20 ns;
--		end if;		

		if (jpeg_ready='1') then
			if not(endfile(jpeg_file)) then 
				read(jpeg_file,b1);
			 end if;
			if not(endfile(jpeg_file)) then 
				read(jpeg_file,b2);
			 end if;
			if not(endfile(jpeg_file)) then 
				read(jpeg_file,b3);
			 end if;
			if not(endfile(jpeg_file)) then 
				read(jpeg_file,b4);
			 end if;
		end if;

		wait for 8 ns;
	
		wea <= '1';
		data(31 downto 24) <= to_stdlogicvector(int2bit_vec(ByteT'pos(b1),8));
		data(23 downto 16) <= to_stdlogicvector(int2bit_vec(ByteT'pos(b2),8));
		data(15 downto 8 ) <= to_stdlogicvector(int2bit_vec(ByteT'pos(b3),8));
		data( 7 downto 0 ) <= to_stdlogicvector(int2bit_vec(ByteT'pos(b4),8));

		wait until CLK='1';

	end loop;

	wait;

end process;


end test;
