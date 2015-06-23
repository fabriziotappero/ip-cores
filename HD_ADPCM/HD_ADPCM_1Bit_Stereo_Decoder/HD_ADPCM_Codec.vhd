--ADPCM 1-Bit Stereo Decoder.
--On: Cyclone-II Starter Kit
--Author: Amir Shahram Hematian
--Date&Time: 2008/Feb/21  

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity HD_ADPCM_Codec is 
        port (
				CLOCK_IN      			: IN STD_LOGIC;
				S_SEVEN_SEGMENT_1_OUT 	: OUT STD_LOGIC_VECTOR (6 downto 0);
				S_SEVEN_SEGMENT_2_OUT 	: OUT STD_LOGIC_VECTOR (6 downto 0);
				S_SEVEN_SEGMENT_3_OUT 	: OUT STD_LOGIC_VECTOR (6 downto 0);
				S_SEVEN_SEGMENT_4_OUT 	: OUT STD_LOGIC_VECTOR (6 downto 0);
				S_RED_LEDS_OUT 			: OUT STD_LOGIC_VECTOR (9 downto 0);
				I2C_CLOCK_OUT    		: OUT STD_LOGIC;
				I2C_DATA_INOUT      	: INOUT STD_LOGIC;
				I2S_LEFT_RIGHT_CLOCK_OUT: OUT STD_LOGIC;
				I2S_CLOCK_OUT      		: OUT STD_LOGIC;
				I2S_DATA_INOUT      	: INOUT STD_LOGIC;
				I2S_CORE_CLOCK_OUT      : OUT STD_LOGIC;
				SWITCH_0				: IN STD_LOGIC;
				KEY_0					: IN STD_LOGIC;
				KEY_1					: IN STD_LOGIC;
				FLASH_MEMORY_ADDRESS_OUT: OUT STD_LOGIC_VECTOR (21 downto 0);
				FLASH_MEMORY_DATA_INOUT	: INOUT STD_LOGIC_VECTOR (7 downto 0);
				FLASH_MEMORY_nWE_OUT	: OUT STD_LOGIC;
				FLASH_MEMORY_nOE_OUT	: OUT STD_LOGIC;
				FLASH_MEMORY_nRESET_OUT	: OUT STD_LOGIC;
				FLASH_MEMORY_nCE_OUT	: OUT STD_LOGIC
				
			 );
end HD_ADPCM_Codec;


architecture HD_ADPCM_Codec_Function of HD_ADPCM_Codec is 
	component SevenSegments_Driver
        port (
				DIGIT_1_IN, DIGIT_2_IN, DIGIT_3_IN, DIGIT_4_IN : in integer range 0 to 15;
				SEVEN_SEGMENT_1_OUT, SEVEN_SEGMENT_2_OUT, SEVEN_SEGMENT_3_OUT, SEVEN_SEGMENT_4_OUT : out STD_LOGIC_VECTOR (6 downto 0)
			 );
	end component;

	component LEDs_Bar_Driver
        port (
				SAMPLE_VALUE 			: IN INTEGER RANGE 0 to 10;
				LEDS_OUT 				: OUT STD_LOGIC_VECTOR (9 downto 0)
			 );
	end component;

	component I2C_Driver
        port (
				CLOCK_IN						: IN STD_LOGIC;			 
				ACTIVE_IN						: IN STD_LOGIC;			 
				SLAVE_ADDRESS, REGISTER_ADDRESS : IN STD_LOGIC_VECTOR(7 downto 0);
				REGISTER_DATA 					: IN STD_LOGIC_VECTOR(7 downto 0);
				I2C_CLOCK 						: OUT STD_LOGIC;
				I2C_DATA 						: INOUT STD_LOGIC
			 );
	end component;



	component I2S_Driver
        port (
				CLOCK_IN							: IN STD_LOGIC;			 
				ACTIVE_IN							: IN STD_LOGIC;			 
				PCM_DATA_LEFT_IN, PCM_DATA_RIGHT_IN : IN STD_LOGIC_VECTOR(15 downto 0);
				I2S_LEFT_RIGHT_CLOCK_OUT			: OUT STD_LOGIC;
				I2S_CLOCK_OUT      					: OUT STD_LOGIC;
				I2S_DATA_INOUT      				: INOUT STD_LOGIC;
				I2S_PCM_DATA_ACCESS_OUT				: OUT STD_LOGIC
			 );
	end component;
	component Flash_Memory_Driver
        port (
				CLOCK_IN							: IN STD_LOGIC;			 
				ACTIVE_IN							: IN STD_LOGIC;
				FLASH_MEMORY_ADDRESS_IN				: IN STD_LOGIC_VECTOR (21 downto 0);
				FLASH_MEMORY_DATA_OUT				: OUT STD_LOGIC_VECTOR (7 downto 0);						 
				DATA_VALID							: OUT STD_LOGIC;
				FLASH_MEMORY_nWE					: OUT STD_LOGIC;
				FLASH_MEMORY_nOE					: OUT STD_LOGIC;
				FLASH_MEMORY_nRESET					: OUT STD_LOGIC;
				FLASH_MEMORY_nCE					: OUT STD_LOGIC;
				FLASH_MEMORY_ADDRESS				: OUT STD_LOGIC_VECTOR (21 downto 0);
				FLASH_MEMORY_DATA					: INOUT STD_LOGIC_VECTOR (7 downto 0)
			 );
	end component;
	
	component ADPCM_Decoder_1_Bit
        port (
				CLOCK_IN							: IN STD_LOGIC;			 
				ACTIVE_IN							: IN STD_LOGIC;			 
				ADPCM_DATA_IN 						: IN STD_LOGIC;
				PCM_DATA_OUT 						: OUT STD_LOGIC_VECTOR(15 downto 0)
			 );
	end component;
	

	signal Seven_Segment_Digit1      : integer range 0 to 15;
	signal Seven_Segment_Digit2      : integer range 0 to 15;
	signal Seven_Segment_Digit3      : integer range 0 to 15;
	signal Seven_Segment_Digit4      : integer range 0 to 15;
	
	signal Red_LEDs_Bar			     : integer range 0 to 10;

	constant CLOCK_FREQ 	: integer := 24000000;
	
	constant DIVISION_FREQ 	: integer := 8;
	constant COUNTER_MAX 	: integer := CLOCK_FREQ/DIVISION_FREQ-1;
	


	--Clock Divider
	signal Counter        				: unsigned(24 downto 0);
	
	signal Audio_Codec_Counter    		: unsigned(3 downto 0);
	signal PCM_Left_Data    			: STD_LOGIC_VECTOR(7 downto 0);

	
	signal	I2C_ACTIVE_IN			: STD_LOGIC := '0';
	signal	I2S_CORE_CLOCK			: STD_LOGIC := '0';
				 
	signal	I2C_SLAVE_ADDRESS		: STD_LOGIC_VECTOR(7 downto 0) := x"34";
	signal	I2C_REGISTER_ADDRESS 	: STD_LOGIC_VECTOR(7 downto 0) := x"12";
	signal	I2C_REGISTER_DATA 		: STD_LOGIC_VECTOR(7 downto 0) := x"01";
	signal  AUDIO_CODEC_VOLUME		: unsigned(6 downto 0)  := "1110000";


	type Stream is array(0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
	signal I2C_Data_Stream				: Stream := (	x"1A",--Line In
														x"7B",--Line Out 
														x"F8",--Analog Path 
														x"06",--Digital Path 
														x"00",--Power Down 
														x"21",--Digital Format 
														x"01",--Sampling Control 
														x"01" --Active Control
															);
	signal I2C_Register_Address_Stream	: Stream := (	x"01",
														x"05", 
														x"08", 
														x"0A", 
														x"0C", 
														x"0E", 
														x"10", 
														x"12" 
															);		

	signal	I2S_ACTIVE_IN			: STD_LOGIC := '0';			 
	signal	I2S_PCM_DATA_LEFT	 	: STD_LOGIC_VECTOR(15 downto 0) := x"0000";
	signal	I2S_PCM_DATA_RIGHT	 	: STD_LOGIC_VECTOR(15 downto 0) := x"0000";
	signal  I2S_PCM_DATA_ACCESS		: STD_LOGIC;	
	
	signal	FLASH_MEMORY_ACTIVE		: STD_LOGIC := '1';			 
	signal	FLASH_MEMORY_ADDRESS	: STD_LOGIC_VECTOR(21 downto 0);
	signal  FLASH_MEMORY_ADDRESS_22	: unsigned(21 downto 0)  := "0000000000000000000000";
	signal	FLASH_MEMORY_DATA	 	: STD_LOGIC_VECTOR(7 downto 0);
	signal  FLASH_MEMORY_DATA_VALID	: STD_LOGIC;
	
	signal	ADPCM_DECODER_ACTIVE		: STD_LOGIC := '0';			 
	signal	ADPCM_DECODER_PCM_DATA_LEFT	: STD_LOGIC_VECTOR(15 downto 0);
	signal	ADPCM_DECODER_PCM_DATA_RIGHT: STD_LOGIC_VECTOR(15 downto 0);
	signal	ADPCM_DECODER_DATA_LEFT	 	: STD_LOGIC;
	signal	ADPCM_DECODER_DATA_RIGHT 	: STD_LOGIC;

begin

	u0: SevenSegments_Driver port map ( Seven_Segment_Digit1, Seven_Segment_Digit2, Seven_Segment_Digit3, Seven_Segment_Digit4, S_SEVEN_SEGMENT_1_OUT, S_SEVEN_SEGMENT_2_OUT, S_SEVEN_SEGMENT_3_OUT, S_SEVEN_SEGMENT_4_OUT);
	u1: LEDs_Bar_Driver		 port map ( Red_LEDs_Bar, S_RED_LEDS_OUT);
	u2: I2C_Driver			 port map ( CLOCK_IN, I2C_ACTIVE_IN, I2C_SLAVE_ADDRESS, I2C_REGISTER_ADDRESS, I2C_REGISTER_DATA, I2C_CLOCK_OUT, I2C_DATA_INOUT);
	u3: I2S_Driver			 port map ( CLOCK_IN, I2S_ACTIVE_IN, I2S_PCM_DATA_LEFT, I2S_PCM_DATA_RIGHT, I2S_LEFT_RIGHT_CLOCK_OUT, I2S_CLOCK_OUT, I2S_DATA_INOUT, I2S_PCM_DATA_ACCESS);
	u4: Flash_Memory_Driver	 port map ( CLOCK_IN, FLASH_MEMORY_ACTIVE, FLASH_MEMORY_ADDRESS, FLASH_MEMORY_DATA, FLASH_MEMORY_DATA_VALID, FLASH_MEMORY_nWE_OUT, FLASH_MEMORY_nOE_OUT, FLASH_MEMORY_nRESET_OUT, FLASH_MEMORY_nCE_OUT, FLASH_MEMORY_ADDRESS_OUT, FLASH_MEMORY_DATA_INOUT);
	u5: ADPCM_Decoder_1_Bit	 port map ( CLOCK_IN, ADPCM_DECODER_ACTIVE, ADPCM_DECODER_DATA_LEFT, ADPCM_DECODER_PCM_DATA_LEFT);
	u6: ADPCM_Decoder_1_Bit	 port map ( CLOCK_IN, ADPCM_DECODER_ACTIVE, ADPCM_DECODER_DATA_RIGHT, ADPCM_DECODER_PCM_DATA_RIGHT);

				



	
	FLASH_MEMORY_ADDRESS(0) <= FLASH_MEMORY_ADDRESS_22(0);
	FLASH_MEMORY_ADDRESS(1) <= FLASH_MEMORY_ADDRESS_22(1);
	FLASH_MEMORY_ADDRESS(2) <= FLASH_MEMORY_ADDRESS_22(2);
	FLASH_MEMORY_ADDRESS(3) <= FLASH_MEMORY_ADDRESS_22(3);
	FLASH_MEMORY_ADDRESS(4) <= FLASH_MEMORY_ADDRESS_22(4);
	FLASH_MEMORY_ADDRESS(5) <= FLASH_MEMORY_ADDRESS_22(5);
	FLASH_MEMORY_ADDRESS(6) <= FLASH_MEMORY_ADDRESS_22(6);
	FLASH_MEMORY_ADDRESS(7) <= FLASH_MEMORY_ADDRESS_22(7);
	FLASH_MEMORY_ADDRESS(8) <= FLASH_MEMORY_ADDRESS_22(8);
	FLASH_MEMORY_ADDRESS(9) <= FLASH_MEMORY_ADDRESS_22(9);
	FLASH_MEMORY_ADDRESS(10) <= FLASH_MEMORY_ADDRESS_22(10);
	FLASH_MEMORY_ADDRESS(11) <= FLASH_MEMORY_ADDRESS_22(11);
	FLASH_MEMORY_ADDRESS(12) <= FLASH_MEMORY_ADDRESS_22(12);
	FLASH_MEMORY_ADDRESS(13) <= FLASH_MEMORY_ADDRESS_22(13);
	FLASH_MEMORY_ADDRESS(14) <= FLASH_MEMORY_ADDRESS_22(14);
	FLASH_MEMORY_ADDRESS(15) <= FLASH_MEMORY_ADDRESS_22(15);
	FLASH_MEMORY_ADDRESS(16) <= FLASH_MEMORY_ADDRESS_22(16);
	FLASH_MEMORY_ADDRESS(17) <= FLASH_MEMORY_ADDRESS_22(17);
	FLASH_MEMORY_ADDRESS(18) <= FLASH_MEMORY_ADDRESS_22(18);
	FLASH_MEMORY_ADDRESS(19) <= FLASH_MEMORY_ADDRESS_22(19);
	FLASH_MEMORY_ADDRESS(20) <= FLASH_MEMORY_ADDRESS_22(20);
	FLASH_MEMORY_ADDRESS(21) <= FLASH_MEMORY_ADDRESS_22(21);
	
	I2C_Data_Stream(1)(0) <= AUDIO_CODEC_VOLUME(0);
	I2C_Data_Stream(1)(1) <= AUDIO_CODEC_VOLUME(1);
	I2C_Data_Stream(1)(2) <= AUDIO_CODEC_VOLUME(2);
	I2C_Data_Stream(1)(3) <= AUDIO_CODEC_VOLUME(3);
	I2C_Data_Stream(1)(4) <= AUDIO_CODEC_VOLUME(4);
	I2C_Data_Stream(1)(5) <= AUDIO_CODEC_VOLUME(5);
	I2C_Data_Stream(1)(6) <= AUDIO_CODEC_VOLUME(6);


	I2S_CORE_CLOCK_OUT <= I2S_CORE_CLOCK;

	
    PCM_Left_Data(7)	<= ADPCM_DECODER_PCM_DATA_LEFT(15);
    PCM_Left_Data(6)	<= ADPCM_DECODER_PCM_DATA_LEFT(14);
    PCM_Left_Data(5)	<= ADPCM_DECODER_PCM_DATA_LEFT(13);
    PCM_Left_Data(4)	<= ADPCM_DECODER_PCM_DATA_LEFT(12);
    PCM_Left_Data(3)	<= ADPCM_DECODER_PCM_DATA_LEFT(11);
    PCM_Left_Data(2)	<= ADPCM_DECODER_PCM_DATA_LEFT(10);
    PCM_Left_Data(1)	<= ADPCM_DECODER_PCM_DATA_LEFT(9);
    PCM_Left_Data(0)	<= ADPCM_DECODER_PCM_DATA_LEFT(8);

	I2S_PCM_DATA_LEFT	<= ADPCM_DECODER_PCM_DATA_LEFT;
	I2S_PCM_DATA_RIGHT	<= ADPCM_DECODER_PCM_DATA_RIGHT;
	
   	process(CLOCK_IN, I2S_PCM_DATA_ACCESS)
		variable I2C_Stream_Counter		: integer range 0 to 7;
		variable ADPCM_Bit_Counter		: integer range 0 to 7 := 6;
		
    begin
		if rising_edge(I2S_PCM_DATA_ACCESS) then
		
			ADPCM_DECODER_DATA_LEFT 	<= FLASH_MEMORY_DATA(ADPCM_Bit_Counter+1);
			ADPCM_DECODER_DATA_RIGHT 	<= FLASH_MEMORY_DATA(ADPCM_Bit_Counter);
			ADPCM_DECODER_ACTIVE <= not ADPCM_DECODER_ACTIVE;
			
			if ADPCM_Bit_Counter = 0 then
				ADPCM_Bit_Counter := 6;
				FLASH_MEMORY_ADDRESS_22 <= FLASH_MEMORY_ADDRESS_22 + 1;
			else
				ADPCM_Bit_Counter := ADPCM_Bit_Counter - 2;
			end if;
				
			if PCM_Left_Data > 	  "11111000" then
				Red_LEDs_Bar <= 10;
			elsif PCM_Left_Data > "11110000" then
				Red_LEDs_Bar <= 9;
			elsif PCM_Left_Data > "11100000" then
				Red_LEDs_Bar <= 8;
			elsif PCM_Left_Data > "11000000" then
				Red_LEDs_Bar <= 7;
			elsif PCM_Left_Data > "10111000" then
				Red_LEDs_Bar <= 6;
			elsif PCM_Left_Data > "10110000" then
				Red_LEDs_Bar <= 5;
			elsif PCM_Left_Data > "10100000" then
				Red_LEDs_Bar <= 4;
			elsif PCM_Left_Data > "10011100" then
				Red_LEDs_Bar <= 3;
			elsif PCM_Left_Data > "10011000" then
				Red_LEDs_Bar <= 2;
			elsif PCM_Left_Data > "10001000" then
				Red_LEDs_Bar <= 1;
			else
				Red_LEDs_Bar <= 0;
			end if;
			
			
		
		end if;
		
		if rising_edge(CLOCK_IN) then
			if Counter = COUNTER_MAX then 
				Counter <= (others => '0');
				
				if KEY_0 = '0' then
					if AUDIO_CODEC_VOLUME = "1111111" then
					else
						AUDIO_CODEC_VOLUME <= AUDIO_CODEC_VOLUME + 1;
					end if;
				elsif KEY_1 = '0' then
					if AUDIO_CODEC_VOLUME = "000000" then
					else
						AUDIO_CODEC_VOLUME <= AUDIO_CODEC_VOLUME - 1;
					end if;
				end if;
				
				I2C_REGISTER_ADDRESS 	<= I2C_Register_Address_Stream(I2C_Stream_Counter);
				I2C_REGISTER_DATA		<= I2C_Data_Stream(I2C_Stream_Counter);
				if I2C_ACTIVE_IN = '0' then
					I2C_ACTIVE_IN <= '1';
				else
					I2C_ACTIVE_IN <= '0';
					if I2C_Stream_Counter = 7 then
						I2C_Stream_Counter := 0;
						I2S_ACTIVE_IN <= '1';
					else
						I2C_Stream_Counter := I2C_Stream_Counter + 1;
					end if;
				end if;
				
			else	
				Counter <= Counter + 1;		
			end if;			
			I2S_CORE_CLOCK <= not I2S_CORE_CLOCK;
		end if;
		
		
    end process;

end HD_ADPCM_Codec_Function;


------------------------7Segments Driver------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity SevenSegments_Driver is 
        port (
				DIGIT_1_IN, DIGIT_2_IN, DIGIT_3_IN, DIGIT_4_IN : in integer range 0 to 15;
				SEVEN_SEGMENT_1_OUT, SEVEN_SEGMENT_2_OUT, SEVEN_SEGMENT_3_OUT, SEVEN_SEGMENT_4_OUT : out STD_LOGIC_VECTOR (6 downto 0)
			 );
end SevenSegments_Driver;


architecture HD_ADPCM_Codec_Function of SevenSegments_Driver is
	type Stream is array(0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
	constant Seven_Segment_Data_Stream	: Stream := (	x"40",
														x"F9", 
														x"A4", 
														x"B0", 
														x"99", 
														x"92", 
														x"02", 
														x"F8", 
														x"00", 
														x"10", 
														x"08", 
														x"03", 
														x"46", 
														x"21", 
														x"06", 
														x"0E");
begin
	SEVEN_SEGMENT_1_OUT(0) 	<= Seven_Segment_Data_Stream(DIGIT_1_IN)(0); 
	SEVEN_SEGMENT_1_OUT(1) 	<= Seven_Segment_Data_Stream(DIGIT_1_IN)(1); 
	SEVEN_SEGMENT_1_OUT(2) 	<= Seven_Segment_Data_Stream(DIGIT_1_IN)(2); 
	SEVEN_SEGMENT_1_OUT(3) 	<= Seven_Segment_Data_Stream(DIGIT_1_IN)(3); 
	SEVEN_SEGMENT_1_OUT(4) 	<= Seven_Segment_Data_Stream(DIGIT_1_IN)(4); 
	SEVEN_SEGMENT_1_OUT(5) 	<= Seven_Segment_Data_Stream(DIGIT_1_IN)(5); 
	SEVEN_SEGMENT_1_OUT(6) 	<= Seven_Segment_Data_Stream(DIGIT_1_IN)(6); 

	SEVEN_SEGMENT_2_OUT(0) 	<= Seven_Segment_Data_Stream(DIGIT_2_IN)(0); 
	SEVEN_SEGMENT_2_OUT(1) 	<= Seven_Segment_Data_Stream(DIGIT_2_IN)(1); 
	SEVEN_SEGMENT_2_OUT(2) 	<= Seven_Segment_Data_Stream(DIGIT_2_IN)(2); 
	SEVEN_SEGMENT_2_OUT(3) 	<= Seven_Segment_Data_Stream(DIGIT_2_IN)(3); 
	SEVEN_SEGMENT_2_OUT(4) 	<= Seven_Segment_Data_Stream(DIGIT_2_IN)(4); 
	SEVEN_SEGMENT_2_OUT(5) 	<= Seven_Segment_Data_Stream(DIGIT_2_IN)(5); 
	SEVEN_SEGMENT_2_OUT(6) 	<= Seven_Segment_Data_Stream(DIGIT_2_IN)(6); 

	SEVEN_SEGMENT_3_OUT(0) 	<= Seven_Segment_Data_Stream(DIGIT_3_IN)(0); 
	SEVEN_SEGMENT_3_OUT(1) 	<= Seven_Segment_Data_Stream(DIGIT_3_IN)(1); 
	SEVEN_SEGMENT_3_OUT(2) 	<= Seven_Segment_Data_Stream(DIGIT_3_IN)(2); 
	SEVEN_SEGMENT_3_OUT(3) 	<= Seven_Segment_Data_Stream(DIGIT_3_IN)(3); 
	SEVEN_SEGMENT_3_OUT(4) 	<= Seven_Segment_Data_Stream(DIGIT_3_IN)(4); 
	SEVEN_SEGMENT_3_OUT(5) 	<= Seven_Segment_Data_Stream(DIGIT_3_IN)(5); 
	SEVEN_SEGMENT_3_OUT(6) 	<= Seven_Segment_Data_Stream(DIGIT_3_IN)(6); 

	SEVEN_SEGMENT_4_OUT(0) 	<= Seven_Segment_Data_Stream(DIGIT_4_IN)(0); 
	SEVEN_SEGMENT_4_OUT(1) 	<= Seven_Segment_Data_Stream(DIGIT_4_IN)(1); 
	SEVEN_SEGMENT_4_OUT(2) 	<= Seven_Segment_Data_Stream(DIGIT_4_IN)(2); 
	SEVEN_SEGMENT_4_OUT(3) 	<= Seven_Segment_Data_Stream(DIGIT_4_IN)(3); 
	SEVEN_SEGMENT_4_OUT(4) 	<= Seven_Segment_Data_Stream(DIGIT_4_IN)(4); 
	SEVEN_SEGMENT_4_OUT(5) 	<= Seven_Segment_Data_Stream(DIGIT_4_IN)(5); 
	SEVEN_SEGMENT_4_OUT(6) 	<= Seven_Segment_Data_Stream(DIGIT_4_IN)(6); 

end HD_ADPCM_Codec_Function;
------------------------7Segments Driver------------------------------




------------------------LEDs Bar Driver------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity LEDs_Bar_Driver is 
        port (
				SAMPLE_VALUE 			: IN INTEGER RANGE 0 to 10;
				LEDS_OUT 				: OUT STD_LOGIC_VECTOR (9 downto 0)
			 );
end LEDs_Bar_Driver;


architecture HD_ADPCM_Codec_Function of LEDs_Bar_Driver is
	type Stream is array(0 to 10) of STD_LOGIC_VECTOR(9 downto 0);
	constant LEDs_Data_Stream	: Stream := (			
												"0000000000",
												"0000000001",
												"0000000011",
												"0000000111",
												"0000001111",
												"0000011111",
												"0000111111",
												"0001111111",
												"0011111111",
												"0111111111",
												"1111111111");
begin
	LEDS_OUT(0) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(0); 
	LEDS_OUT(1) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(1); 
	LEDS_OUT(2) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(2); 
	LEDS_OUT(3) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(3); 
	LEDS_OUT(4) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(4); 
	LEDS_OUT(5) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(5); 
	LEDS_OUT(6) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(6); 
	LEDS_OUT(7) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(7); 
	LEDS_OUT(8) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(8); 
	LEDS_OUT(9) 	<= LEDs_Data_Stream(SAMPLE_VALUE)(9); 

end HD_ADPCM_Codec_Function;
------------------------7Segments Driver------------------------------



------------------------I2C Driver------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity I2C_Driver is 
        port (
				CLOCK_IN						: IN STD_LOGIC;			 
				ACTIVE_IN						: IN STD_LOGIC;			 
				SLAVE_ADDRESS, REGISTER_ADDRESS : IN STD_LOGIC_VECTOR(7 downto 0);
				REGISTER_DATA 					: IN STD_LOGIC_VECTOR(7 downto 0);
				I2C_CLOCK 						: OUT STD_LOGIC;
				I2C_DATA 						: INOUT STD_LOGIC
			 );
end I2C_Driver;


architecture HD_ADPCM_Codec_Function of I2C_Driver is

	type Stream is array(0 to 86) of STD_LOGIC;
	constant CLOCK_FREQ 	: integer := 24000000;
	constant DIVISION_FREQ 	: integer := 100000;--I2C Speed: 100Kbps
	constant COUNTER_MAX 	: integer := CLOCK_FREQ/(DIVISION_FREQ*3)-1;

	--Clock Divider
	signal Counter        				: unsigned(24 downto 0);
	signal I2C_Sent		   				: unsigned(0 downto 0);
	signal I2C_Data_Stream				: Stream := (	
														'1',
														'0',
														'0', 
														SLAVE_ADDRESS(7), 
														SLAVE_ADDRESS(7), 
														SLAVE_ADDRESS(7), 
														SLAVE_ADDRESS(6), 
														SLAVE_ADDRESS(6), 
														SLAVE_ADDRESS(6), 
														SLAVE_ADDRESS(5), 
														SLAVE_ADDRESS(5), 
														SLAVE_ADDRESS(5), 
														SLAVE_ADDRESS(4), 
														SLAVE_ADDRESS(4), 
														SLAVE_ADDRESS(4), 
														SLAVE_ADDRESS(3), 
														SLAVE_ADDRESS(3), 
														SLAVE_ADDRESS(3), 
														SLAVE_ADDRESS(2), 
														SLAVE_ADDRESS(2), 
														SLAVE_ADDRESS(2), 
														SLAVE_ADDRESS(1), 
														SLAVE_ADDRESS(1),
														SLAVE_ADDRESS(1),
														SLAVE_ADDRESS(0), 
														SLAVE_ADDRESS(0),
														SLAVE_ADDRESS(0),
														'1',--Ack
														'1',--Ack
														'1',--Ack
														REGISTER_ADDRESS(7), 
														REGISTER_ADDRESS(7), 
														REGISTER_ADDRESS(7), 
														REGISTER_ADDRESS(6), 
														REGISTER_ADDRESS(6), 
														REGISTER_ADDRESS(6), 
														REGISTER_ADDRESS(5), 
														REGISTER_ADDRESS(5), 
														REGISTER_ADDRESS(5), 
														REGISTER_ADDRESS(4), 
														REGISTER_ADDRESS(4), 
														REGISTER_ADDRESS(4), 
														REGISTER_ADDRESS(3), 
														REGISTER_ADDRESS(3), 
														REGISTER_ADDRESS(3), 
														REGISTER_ADDRESS(2), 
														REGISTER_ADDRESS(2), 
														REGISTER_ADDRESS(2), 
														REGISTER_ADDRESS(1), 
														REGISTER_ADDRESS(1),
														REGISTER_ADDRESS(1),
														REGISTER_ADDRESS(0), 
														REGISTER_ADDRESS(0),
														REGISTER_ADDRESS(0),
														'1',--Ack
														'1',--Ack
														'1',--Ack
														REGISTER_DATA(7), 
														REGISTER_DATA(7), 
														REGISTER_DATA(7), 
														REGISTER_DATA(6), 
														REGISTER_DATA(6), 
														REGISTER_DATA(6), 
														REGISTER_DATA(5), 
														REGISTER_DATA(5), 
														REGISTER_DATA(5), 
														REGISTER_DATA(4), 
														REGISTER_DATA(4), 
														REGISTER_DATA(4), 
														REGISTER_DATA(3), 
														REGISTER_DATA(3), 
														REGISTER_DATA(3), 
														REGISTER_DATA(2), 
														REGISTER_DATA(2), 
														REGISTER_DATA(2), 
														REGISTER_DATA(1), 
														REGISTER_DATA(1),
														REGISTER_DATA(1),
														REGISTER_DATA(0), 
														REGISTER_DATA(0),
														REGISTER_DATA(0),
														'1',--Ack
														'1',--Ack
														'1',--Ack
														'0',
														'0',
														'1');

	constant I2C_Clock_Stream		: Stream := (
														'1',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'0',
														'0',
														'1',
														'1'
														);

begin

   	process(CLOCK_IN, ACTIVE_IN)
		variable I2C_Stream_Counter		: integer range 0 to 86;
    begin
		if rising_edge(CLOCK_IN) then

			I2C_CLOCK <= I2C_Clock_Stream(I2C_Stream_Counter);
			I2C_DATA  <= I2C_Data_Stream(I2C_Stream_Counter);

			if Counter = COUNTER_MAX then 
				Counter <= (others => '0');
				
				if ACTIVE_IN = '1' then
					if I2C_Stream_Counter = 86 then
						--I2C_Stream_Counter := 0;
					else
						I2C_Stream_Counter := I2C_Stream_Counter + 1;
					end if;
				else
					I2C_Stream_Counter := 0;
				end if;
			else	
				Counter <= Counter + 1;		
			end if;
		end if;
    end process;
    
    

    

end HD_ADPCM_Codec_Function;
------------------------I2C Driver------------------------------



------------------------I2S Driver------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity I2S_Driver is 
        port (
				CLOCK_IN							: IN STD_LOGIC;			 
				ACTIVE_IN							: IN STD_LOGIC;			 
				PCM_DATA_LEFT_IN, PCM_DATA_RIGHT_IN : IN STD_LOGIC_VECTOR(15 downto 0);
				I2S_LEFT_RIGHT_CLOCK_OUT			: OUT STD_LOGIC;
				I2S_CLOCK_OUT      					: OUT STD_LOGIC;
				I2S_DATA_INOUT      				: INOUT STD_LOGIC;
				I2S_PCM_DATA_ACCESS_OUT				: OUT STD_LOGIC
			 );
end I2S_Driver;


architecture HD_ADPCM_Codec_Function of I2S_Driver is

	type Stream is array(0 to 37) of STD_LOGIC;
	constant CLOCK_FREQ 	: integer := 24000000;
	--constant DIVISION_FREQ 	: integer := 1824000;--I2S Speed: 48000Hz   48Khz * 38 I2S Bits 
	--constant COUNTER_MAX 	: integer := CLOCK_FREQ/(DIVISION_FREQ*2)-1;
	constant COUNTER_MAX 	: integer := 7;


	--Clock Divider
	signal Counter        				: unsigned(24 downto 0);
	signal Active_Module   				: unsigned(0 downto 0);
	signal I2S_Clock	   				: STD_LOGIC := '0';
	signal I2S_Data_Stream				: Stream := (	'0',
														PCM_DATA_LEFT_IN(15), 
														PCM_DATA_LEFT_IN(14), 
														PCM_DATA_LEFT_IN(13), 
														PCM_DATA_LEFT_IN(12), 
														PCM_DATA_LEFT_IN(11), 
														PCM_DATA_LEFT_IN(10), 
														PCM_DATA_LEFT_IN(9), 
														PCM_DATA_LEFT_IN(8), 
														PCM_DATA_LEFT_IN(7), 
														PCM_DATA_LEFT_IN(6), 
														PCM_DATA_LEFT_IN(5), 
														PCM_DATA_LEFT_IN(4), 
														PCM_DATA_LEFT_IN(3), 
														PCM_DATA_LEFT_IN(2),
														PCM_DATA_LEFT_IN(1), 
														PCM_DATA_LEFT_IN(0),
														'0',
														'0',
														'0',
														PCM_DATA_RIGHT_IN(15), 
														PCM_DATA_RIGHT_IN(14), 
														PCM_DATA_RIGHT_IN(13), 
														PCM_DATA_RIGHT_IN(12), 
														PCM_DATA_RIGHT_IN(11), 
														PCM_DATA_RIGHT_IN(10), 
														PCM_DATA_RIGHT_IN(9), 
														PCM_DATA_RIGHT_IN(8), 
														PCM_DATA_RIGHT_IN(7), 
														PCM_DATA_RIGHT_IN(6), 
														PCM_DATA_RIGHT_IN(5), 
														PCM_DATA_RIGHT_IN(4), 
														PCM_DATA_RIGHT_IN(3), 
														PCM_DATA_RIGHT_IN(2),
														PCM_DATA_RIGHT_IN(1), 
														PCM_DATA_RIGHT_IN(0),
														'0',
														'0');


begin

	I2S_CLOCK_OUT <= I2S_Clock;

   	process(CLOCK_IN, ACTIVE_IN)
    begin
		if rising_edge(CLOCK_IN) then
			if Counter = COUNTER_MAX then 
				Counter <= (others => '0');
				
				if Active_Module = "1" then
					I2S_Clock		<= not I2S_Clock;				
				end if;

			else	
				Counter <= Counter + 1;		
			end if;
		end if;
		if rising_edge(ACTIVE_IN) then
			Active_Module <= "1";
		end if;
		if ACTIVE_IN = '0' then
			Active_Module <= "0";
		end if;
    end process;
    
	process(I2S_Clock)
		variable I2S_Stream_Counter		: integer range 0 to 37;
	begin
		if falling_edge(I2S_Clock) then
		
			I2S_DATA_INOUT  <= I2S_Data_Stream(I2S_Stream_Counter);

			if I2S_Stream_Counter = 0 then
				I2S_LEFT_RIGHT_CLOCK_OUT <= '0';
			elsif I2S_Stream_Counter = 19 then
				I2S_LEFT_RIGHT_CLOCK_OUT <= '1';
			end if;
			
			if I2S_Stream_Counter = 37 then
				I2S_Stream_Counter := 0;
				I2S_PCM_DATA_ACCESS_OUT <= '1';
			else
				I2S_PCM_DATA_ACCESS_OUT <= '0';
				I2S_Stream_Counter := I2S_Stream_Counter + 1;
			end if;
		end if;
	end process;

end HD_ADPCM_Codec_Function;
------------------------I2S Driver------------------------------




------------------------Flash Memory Driver------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity Flash_Memory_Driver is 
        port (
				CLOCK_IN							: IN STD_LOGIC;			 
				ACTIVE_IN							: IN STD_LOGIC;
				FLASH_MEMORY_ADDRESS_IN				: IN STD_LOGIC_VECTOR (21 downto 0);
				FLASH_MEMORY_DATA_OUT				: OUT STD_LOGIC_VECTOR (7 downto 0);						 
				DATA_VALID							: OUT STD_LOGIC;
				FLASH_MEMORY_nWE					: OUT STD_LOGIC;
				FLASH_MEMORY_nOE					: OUT STD_LOGIC;
				FLASH_MEMORY_nRESET					: OUT STD_LOGIC;
				FLASH_MEMORY_nCE					: OUT STD_LOGIC;
				FLASH_MEMORY_ADDRESS				: OUT STD_LOGIC_VECTOR (21 downto 0);
				FLASH_MEMORY_DATA					: INOUT STD_LOGIC_VECTOR (7 downto 0)
			 );
end Flash_Memory_Driver;


architecture HD_ADPCM_Codec_Function of Flash_Memory_Driver is
	constant CLOCK_FREQ 	: integer := 24000000;
	constant DIVISION_FREQ 	: integer := 2000000;--Flash Memory Speed Clock. 
	constant COUNTER_MAX 	: integer := CLOCK_FREQ/(DIVISION_FREQ*2)-1;

	--Clock Divider
	signal Counter        				: unsigned(24 downto 0);
	signal Flash_Memory_Clock	   		: STD_LOGIC := '0';
	signal Flash_Memory_Data_Valid 		: STD_LOGIC := '0';
begin

	DATA_VALID <= Flash_Memory_Data_Valid;
   	process(CLOCK_IN)
    begin
		if rising_edge(CLOCK_IN) then
			if Counter = COUNTER_MAX then 
				Counter <= (others => '0');
				
				if ACTIVE_IN  = '1' then
					Flash_Memory_Clock	<= not Flash_Memory_Clock;				
				end if;

			else	
				Counter <= Counter + 1;		
			end if;
		end if;


    end process;
    
	process(Flash_Memory_Clock)
		variable Flash_Memory_Counter		: integer range 0 to 5;
	begin
		if falling_edge(Flash_Memory_Clock) then
			case Flash_Memory_Counter is
				when 0 =>
					Flash_Memory_Data_Valid <= '0';
					FLASH_MEMORY_nRESET 	<= '1';
					FLASH_MEMORY_nWE		<= '1';
					FLASH_MEMORY_nOE		<= '1';
					FLASH_MEMORY_nCE		<= '1';
				when 1 =>
					FLASH_MEMORY_ADDRESS 	<= FLASH_MEMORY_ADDRESS_IN;
				when 2 =>
					FLASH_MEMORY_nCE 		<= '0';
				when 3 =>
					FLASH_MEMORY_nOE 		<= '0';
				when 4 =>
					FLASH_MEMORY_DATA_OUT 	<= FLASH_MEMORY_DATA;
				when 5 =>
					FLASH_MEMORY_nCE 		<= '1';
					FLASH_MEMORY_nOE 		<= '1';
					Flash_Memory_Data_Valid <= '1';
				when others => null;
			end case;
			if Flash_Memory_Counter = 5 then
				Flash_Memory_Counter := 0;
			else
				Flash_Memory_Counter := Flash_Memory_Counter + 1;
			end if;
		end if;
	end process;
    
    
end HD_ADPCM_Codec_Function;
------------------------Flash Memory Driver------------------------------




------------------------ADPCM Decoder 1-Bit Driver------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity ADPCM_Decoder_1_Bit is 
        port (
				CLOCK_IN							: IN STD_LOGIC;			 
				ACTIVE_IN							: IN STD_LOGIC;			 
				ADPCM_DATA_IN 						: IN STD_LOGIC;
				PCM_DATA_OUT 						: OUT STD_LOGIC_VECTOR(15 downto 0)
			 );
end ADPCM_Decoder_1_Bit;


architecture HD_ADPCM_Codec_Function of ADPCM_Decoder_1_Bit is

	signal Active_Module   				: STD_LOGIC;
	signal Last_ADPCM_Data				: STD_LOGIC;
	type Stream is array(0 to 15) of integer;
	constant PCM_Data_Converter			: Stream := (			
														1,
														2,
														4,
														8,
														16,
														32,
														64,
														128,
														256,
														512,
														1024,
														2048,
														4096,
														8192,
														16384,
														32768);
	
begin

   	process(CLOCK_IN, ACTIVE_IN)
		variable Last_PCM_Data							: integer range -32767 to 32768;
		variable PCM_Data								: integer range 0 to 65535;
		variable PCM_Data_Difference					: integer range -32767 to 32768;
		variable ADPCM_Decoder_Step_Size_Table_Pointer	: integer range 0 to 1000;
		variable ADPCM_Decoder_State_Counter			: integer range 0 to 5;
    begin
		
		if rising_edge(CLOCK_IN) then
			if Active_Module = not ACTIVE_IN then
				case ADPCM_Decoder_State_Counter is
					when 0 =>
						PCM_Data_Difference	:= (ADPCM_Decoder_Step_Size_Table_Pointer * ADPCM_Decoder_Step_Size_Table_Pointer)/100;
					when 1 =>
						if Last_ADPCM_Data = ADPCM_DATA_IN then
							if ADPCM_Decoder_Step_Size_Table_Pointer < 1000 then
								ADPCM_Decoder_Step_Size_Table_Pointer := ADPCM_Decoder_Step_Size_Table_Pointer + 1;
							end if;
						else
							if ADPCM_Decoder_Step_Size_Table_Pointer > 0 then
								ADPCM_Decoder_Step_Size_Table_Pointer := ADPCM_Decoder_Step_Size_Table_Pointer - 1;
							end if;
						end if;
					when 2 =>
						Last_ADPCM_Data <= ADPCM_DATA_IN;
						if ADPCM_DATA_IN = '1' then
							Last_PCM_Data := Last_PCM_Data - PCM_Data_Difference;
						else
							Last_PCM_Data := Last_PCM_Data + PCM_Data_Difference;
						end if;
					when 3 =>
						PCM_Data := Last_PCM_Data;
					when 4 =>
						for i in 15 downto 0 loop
							if PCM_Data > PCM_Data_Converter(i) then
								PCM_Data := PCM_Data - PCM_Data_Converter(i);
								PCM_DATA_OUT(i) <= '1';
							else
								PCM_DATA_OUT(i) <= '0';
							end if;
						end loop;
					when others => null;
				end case;
				
				if ADPCM_Decoder_State_Counter = 5 then
					ADPCM_Decoder_State_Counter := 0;
					Active_Module <= ACTIVE_IN;
				else
					ADPCM_Decoder_State_Counter := ADPCM_Decoder_State_Counter + 1;
				end if;
			end if;
		end if;
    end process;
    

end HD_ADPCM_Codec_Function;
------------------------ADPCM Decoder 1-Bit Driver------------------------------





