library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_baudgen is
	PORT(	CLK_I     : in  std_logic;
			RST_I     : in  std_logic;

			RD        : in  std_logic;
			WR        : in  std_logic;

			TX_DATA   : in  std_logic_vector(7 downto 0);
			TX_SEROUT : out std_logic;
			RX_SERIN  : in  std_logic;
			RX_DATA   : out std_logic_vector(7 downto 0);
			RX_READY  : out std_logic;
			TX_BUSY   : out std_logic
		);
end uart_baudgen;

architecture Behavioral of uart_baudgen is

	COMPONENT baudgen
	Generic(bg_clock_freq : integer; bg_baud_rate : integer);
	PORT(	CLK_I : IN std_logic;
			RST_I : IN std_logic;
			CE_16 : OUT std_logic
			);
	END COMPONENT;

	COMPONENT uart
	PORT(	CLK_I     : in std_logic;
			RST_I     : in std_logic;
			CE_16     : in std_logic;

			TX_DATA   : in std_logic_vector(7 downto 0);
			TX_FLAG   : in  std_logic;
			TX_SEROUT : out std_logic;
			TX_FLAGQ  : out std_logic;

			RX_SERIN  : in  std_logic;
			RX_DATA   : out std_logic_vector(7 downto 0);
			RX_FLAG   : out std_logic
		);
	END COMPONENT;

	signal CE_16       : std_logic;
	signal RX_FLAG     : std_logic;
	signal RX_OLD_FLAG : std_logic;
	signal TX_FLAG     : std_logic;
	signal TX_FLAGQ    : std_logic;
	signal LTX_DATA    : std_logic_vector(7 downto 0);
	signal LRX_READY   : std_logic;

begin

	RX_READY <= LRX_READY;
	TX_BUSY  <= TX_FLAG xor TX_FLAGQ;

	baud: baudgen
	GENERIC MAP(bg_clock_freq => 40000000, bg_baud_rate => 115200)
	PORT MAP(
		CLK_I => CLK_I,
		RST_I => RST_I,
		CE_16 => CE_16
	);

	urt: uart
	PORT MAP(	CLK_I     => CLK_I,
				RST_I     => RST_I,
				CE_16     => CE_16,
				TX_DATA   => LTX_DATA,
				TX_FLAG   => TX_FLAG,
				TX_SEROUT => TX_SEROUT,
				TX_FLAGQ  => TX_FLAGQ,
				RX_SERIN  => RX_SERIN,
				RX_DATA   => RX_DATA,
				RX_FLAG   => RX_FLAG
			);

	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				TX_FLAG <= '0';
				LTX_DATA <= X"33";
			else
				if (RD = '1') then			-- read Rx data
					LRX_READY    <= '0';
				end if;

				if (WR = '1') then			-- write Tx data
					TX_FLAG  <= not TX_FLAG;
					LTX_DATA <= TX_DATA;
				end if;

				if (RX_FLAG /= RX_OLD_FLAG) then
					LRX_READY <= '1';
				end if;

				RX_OLD_FLAG <= RX_FLAG;
			end if;
		end if;
	end process;

end Behavioral;
