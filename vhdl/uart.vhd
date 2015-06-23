library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart is
	PORT(	CLK_I     : in std_logic;
			RST_I     : in std_logic;
			CE_16     : in std_logic;

			TX_DATA   : in std_logic_vector(7 downto 0);
			TX_FLAG   : in std_logic;
			TX_SEROUT : out std_logic;
			TX_FLAGQ  : out std_logic;

			RX_SERIN  : in  std_logic;
			RX_DATA   : out std_logic_vector(7 downto 0);
			RX_FLAG   : out std_logic
		);
end uart;

architecture Behavioral of uart is

	COMPONENT uart_tx
	PORT(	CLK_I      : IN  std_logic;
			RST_I      : IN  std_logic;
			CE_16      : IN  std_logic;
			DATA       : IN  std_logic_vector(7 downto 0);
			DATA_FLAG  : IN  std_logic;          
			SER_OUT    : OUT std_logic;
			DATA_FLAGQ : OUT std_logic
		);
	END COMPONENT;

	COMPONENT uart_rx
	PORT(	CLK_I     : IN std_logic;
			RST_I     : IN std_logic;
			CE_16     : IN std_logic;
			SER_IN    : IN std_logic;
          
			DATA      : OUT std_logic_vector(7 downto 0);
			DATA_FLAG : OUT std_logic
		);
	END COMPONENT;

begin

	tx: uart_tx
	PORT MAP(	CLK_I      => CLK_I,
				RST_I      => RST_I,
				CE_16      => CE_16,
				DATA       => TX_DATA,
				DATA_FLAG  => TX_FLAG,

				SER_OUT    => TX_SEROUT,
				DATA_FLAGQ => TX_FLAGQ
			);

	rx: uart_rx
	PORT MAP(	CLK_I     => CLK_I,
				RST_I     => RST_I,
				CE_16     => CE_16,
				DATA      => RX_DATA,
				SER_IN    => RX_SERIN,
				DATA_FLAG => RX_FLAG
			);

end Behavioral;
