library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity temperature is
	PORT(	CLK_I			: in STD_LOGIC;
			RST_I			: in STD_LOGIC;
			DATA_OUT		: out STD_LOGIC_VECTOR(7 downto 0);
			TEMP_SPI		: out STD_LOGIC;
			TEMP_SPO		: in STD_LOGIC;
			TEMP_CE			: out STD_LOGIC;
			TEMP_SCLK		: out STD_LOGIC
    );
end temperature;

architecture behavioral of temperature is

	component DS1722
	PORT(	CLK_I			: in std_logic;
			RST_I			: in std_logic;
	
			DATA_IN			: in std_logic_vector(7 downto 0);	
			DATA_OUT		: out std_logic_vector(7 downto 0);	
			ADDRESS			: in std_logic_vector(7 downto 0);				

			START			: in std_logic;
			DONE			: out std_logic;
	
			TEMP_SPI		: out STD_LOGIC;
			TEMP_SPO		: in STD_LOGIC;
			TEMP_CE			: out STD_LOGIC;
			TEMP_SCLK		: out STD_LOGIC
		);
end component;	

	signal TEMP_DATA_IN		: STD_LOGIC_VECTOR (7 downto 0);
	signal TEMP_DATA_OUT	: STD_LOGIC_VECTOR (7 downto 0);
	signal TEMP_ADDRESS		: STD_LOGIC_VECTOR (7 downto 0);
	signal TEMP_START		: std_logic;
	signal TEMP_DONE		: std_logic;
	
	type TEMPERATURE_STATES is (TEMP_IDLE, TEMP_SETUP, TEMP_SETUP_COMPLETE,
								TEMP_GET_DATA, TEMP_GET_DATA_COMPLETE);
	signal TEMP_state	: TEMPERATURE_STATES;

begin

	tsensor: DS1722
	PORT MAP(	CLK_I 		=> CLK_I,
				RST_I 		=> RST_I,
				
				DATA_IN 	=> TEMP_DATA_IN,
				DATA_OUT	=> TEMP_DATA_OUT,
				ADDRESS 	=> TEMP_ADDRESS,
	
				START 		=> TEMP_START,
				DONE 		=> TEMP_DONE,

				TEMP_SPI 	=> TEMP_SPI,
				TEMP_SPO 	=> TEMP_SPO,
				TEMP_CE 	=> TEMP_CE,
				TEMP_SCLK 	=> TEMP_SCLK
			);
   
	-- State machine to step though the process of getting data
	-- from the Digital Thermometer.
	--
	process (CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				TEMP_state   <= TEMP_IDLE;
				TEMP_START   <= '0';
				TEMP_ADDRESS <= "00000000";
				TEMP_DATA_IN <= "00000000";
			else
				case TEMP_state is
					when TEMP_IDLE =>
						TEMP_START   <= '0';
						TEMP_ADDRESS <= "00000000";
						TEMP_DATA_IN <= "00000000";
						TEMP_state   <= TEMP_SETUP;

					when TEMP_SETUP =>
						TEMP_ADDRESS <= "10000000";
						TEMP_DATA_IN <= "11101000";
						if (TEMP_DONE = '1') then
							TEMP_state <= TEMP_SETUP_COMPLETE;	
							TEMP_START <= '0';
						else
							TEMP_state <= TEMP_SETUP;
							TEMP_START <= '1';
						end if;

					when TEMP_SETUP_COMPLETE =>
						TEMP_START <= '0';
	    			     if (TEMP_DONE = '1') then
							TEMP_state <= TEMP_SETUP_COMPLETE;	
						else
							TEMP_state <= TEMP_GET_DATA;
						end if;

					when TEMP_GET_DATA =>
						TEMP_ADDRESS <= "00000010";
						if (TEMP_DONE = '1') then
							TEMP_state <= TEMP_GET_DATA_COMPLETE;	
							DATA_OUT   <= TEMP_DATA_OUT;
							TEMP_START <= '0';
						else
							TEMP_state <= TEMP_GET_DATA;
							TEMP_START <= '1';
						end if;

					when TEMP_GET_DATA_COMPLETE =>
						TEMP_START <= '0';
	    		    	 if (TEMP_DONE = '1') then
							TEMP_state <= TEMP_GET_DATA_COMPLETE;	
						else
							TEMP_state <= TEMP_GET_DATA;
						end if;
				end case;
			end if;
		end if;
	end process;

end behavioral;
