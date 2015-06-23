library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.cpu_pack.ALL;

entity input_output is
    PORT (	CLK_I 			: in std_logic;
			ADR_I			: in  std_logic_vector( 7 downto 0);
			CYC_I			: in  std_logic;
			STB_I			: in  std_logic;
			ACK_O			: out std_logic;

			RST_O			: out STD_LOGIC;

			SWITCH			: in  STD_LOGIC_VECTOR (9 downto 0);

			HALT			: in  STD_LOGIC;
			SER_IN			: in  STD_LOGIC;
			SER_OUT			: out STD_LOGIC;

			-- temperature
			TEMP_SPO		: in  STD_LOGIC;
			TEMP_SPI		: out STD_LOGIC;
			TEMP_CE			: out STD_LOGIC;
			TEMP_SCLK		: out STD_LOGIC;

		    LED				: out STD_LOGIC_VECTOR (7 downto 0);

			-- input/output
			IO       : in  std_logic;
			WE_I     : in  std_logic;
			IO_RDAT  : out std_logic_vector( 7 downto 0);
			IO_WDAT  : in  std_logic_vector( 7 downto 0);
		    INT      : out STD_LOGIC
	);
end input_output;

architecture Behavioral of input_output is

	COMPONENT temperature
	PORT(	CLK_I     : IN std_logic;
			RST_I     : IN std_logic;
			TEMP_SPO  : IN std_logic;          
			DATA_OUT  : OUT std_logic_vector(7 downto 0);
			TEMP_SPI  : OUT std_logic;
			TEMP_CE   : OUT std_logic;
			TEMP_SCLK : OUT std_logic
		);
	END COMPONENT;

	COMPONENT uart_baudgen
	PORT(	CLK_I     : IN std_logic;
			RST_I     : IN std_logic;
			RD        : IN std_logic;
			WR        : IN std_logic;
			TX_DATA   : IN std_logic_vector(7 downto 0);
			RX_SERIN  : IN std_logic;          
			TX_SEROUT : OUT std_logic;
			RX_DATA   : OUT std_logic_vector(7 downto 0);
			RX_READY  : OUT std_logic;
			TX_BUSY   : OUT std_logic
		);
	END COMPONENT;

	signal IO_RD_SERIAL    : std_logic;
	signal IO_WR_SERIAL    : std_logic;
	signal RX_READY        : std_logic;
	signal TX_BUSY         : std_logic;
	signal RX_DATA         : std_logic_vector(7 downto 0);
	signal TEMP_DO         : std_logic_vector(7 downto 0);

	signal SERDAT          : std_logic;

	signal LCLR            : std_logic;
	signal C1_N, C2_N      : std_logic;		-- switch debounce, active low

	signal RX_INT_ENABLED  : std_logic;
	signal TX_INT_ENABLED  : std_logic;
	signal TIM_INT_ENABLED : std_logic;
	signal TIMER_INT       : std_logic;
	signal TIMER           : std_logic_vector(15 downto 0);
	signal CLK_COUNT       : std_logic_vector(16 downto 0);

	signal CLK_COUNT_EN    : std_logic;
	signal CLK_HALT_MSK    : std_logic;
	signal CLK_HALT_VAL    : std_logic;

begin

	tempr: temperature
	PORT MAP(	CLK_I     => CLK_I,
				RST_I     => LCLR,
				DATA_OUT  => TEMP_DO,
				TEMP_SPI  => TEMP_SPI,
				TEMP_SPO  => TEMP_SPO,
				TEMP_CE   => TEMP_CE,
				TEMP_SCLK => TEMP_SCLK
	);

	uart: uart_baudgen
	PORT MAP(	CLK_I     => CLK_I,
				RST_I     => LCLR,
				RD        => IO_RD_SERIAL,
				WR        => IO_WR_SERIAL,
				TX_DATA   => IO_WDAT,
				TX_SEROUT => SER_OUT,
				RX_SERIN  => SER_IN,
				RX_DATA   => RX_DATA,
				RX_READY  => RX_READY,
				TX_BUSY   => TX_BUSY
	);

	RST_O   <= LCLR;
	INT     <=     (RX_INT_ENABLED  and     RX_READY)
				or (TX_INT_ENABLED  and not TX_BUSY)
				or (TIM_INT_ENABLED and     TIMER_INT);

	SERDAT       <= (IO and CYC_I) when (ADR_I = X"00") else '0';
	IO_RD_SERIAL <= SERDAT and not WE_I;
	IO_WR_SERIAL <= SERDAT and WE_I;
	ACK_O        <= STB_I;

	-- IO read process
	--
	process(ADR_I, RX_DATA, TIM_INT_ENABLED, TIMER_INT, TX_INT_ENABLED, TX_BUSY,
			RX_INT_ENABLED,  RX_READY, TEMP_DO, SWITCH, CLK_COUNT)
	begin
		case ADR_I is
			when X"00"	=>	IO_RDAT <= RX_DATA;
			when X"01"	=>	IO_RDAT <= '0'
									 & (TIM_INT_ENABLED and  TIMER_INT)
									 & (TX_INT_ENABLED  and not TX_BUSY)
									 & (RX_INT_ENABLED  and RX_READY)
									 & '0'
									 & TIMER_INT
									 & TX_BUSY
									 & RX_READY;
			when X"02"	=> IO_RDAT  <= TEMP_DO;
			when X"03"	=> IO_RDAT  <= SWITCH(7 downto 0);
			when X"05"	=> IO_RDAT  <= CLK_COUNT(8 downto 1);
			when others	=> IO_RDAT  <= CLK_COUNT(16 downto 9);
		end case;
	end process;

	-- IO write and timer process
	--
	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (LCLR = '1') then
				LED             <= X"00";
				RX_INT_ENABLED  <= '0';
				TX_INT_ENABLED  <= '0';
				TIM_INT_ENABLED <= '0';
				TIMER_INT       <= '0';
				TIMER           <= X"0000";
			else
				if (IO = '1' and CYC_I = '1' and WE_I = '1') then
					case ADR_I is
						when X"00"  =>	-- handled by uart
						when X"01"  =>	-- handled by uart
						when X"02"  =>  LED             <= IO_WDAT;
						when X"03"  =>	RX_INT_ENABLED  <= IO_WDAT(0);
										TX_INT_ENABLED  <= IO_WDAT(1);
										TIM_INT_ENABLED <= IO_WDAT(2);
						when X"04"  =>	TIMER_INT       <= '0';
						when X"05"  =>	CLK_COUNT_EN    <= '1';
						                CLK_COUNT       <= '0' & X"0000";
										CLK_HALT_VAL    <= IO_WDAT(0);
										CLK_HALT_MSK    <= IO_WDAT(1);
						when X"06"  =>	CLK_COUNT_EN    <= '0';
						when others =>
					end case;
				end if;

				if (TIMER = 39999) then		-- 1 ms at 40 MHz
					TIMER_INT <= '1';
					TIMER     <= X"0000";
				else
					TIMER <= TIMER + 1;
				end if;

				if (CLK_COUNT_EN = '1' and
				    (HALT and CLK_HALT_MSK ) = CLK_HALT_VAL) then
					CLK_COUNT <= CLK_COUNT + 1;
				end if;
			end if;
		end if;
	end process;

	-- reset debounce process
	--
	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then			
			-- switch debounce
			if (SWITCH(8) = '1' or SWITCH(9) = '1') then
				LCLR <= '1';
				C2_N <= '0';
				C1_N <= '0';
			else
				LCLR <= not C2_N;
				C2_N   <= C1_N;
				C1_N   <= '1';
			end if;
		end if;
	end process;

end Behavioral;
