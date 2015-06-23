-----------------------------------------------------------------------------
-- Wishbone GPIO ------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity wb_gpio_08 is
   port (
		clk      : in  std_ulogic;
		reset    : in  std_ulogic;
		-- Wishbone bus
		wb_adr_i : in  std_ulogic_vector(7 downto 0);
		wb_dat_i : in  std_ulogic_vector(7 downto 0);
		wb_dat_o : out std_ulogic_vector(7 downto 0);
		wb_cyc_i : in  std_ulogic;
		wb_stb_i : in  std_ulogic;
		wb_ack_o : out std_ulogic;
		wb_we_i  : in  std_ulogic;
		-- I/O ports
		iport    : in  std_ulogic_vector(7 downto 0);
		oport    : out std_ulogic_vector(7 downto 0)
	);
end wb_gpio_08;

-----------------------------------------------------------------------------
-- Implementation -----------------------------------------------------------
architecture rtl of wb_gpio_08 is

	constant	OPORT_ADDR : std_ulogic_vector(7 downto 0) := x"04";
	constant	IPORT_ADDR : std_ulogic_vector(7 downto 0) := x"01";

	signal wbactive  : std_ulogic;
	
	signal oport_reg : std_ulogic_vector(7 downto 0);
	signal iport_reg : std_ulogic_vector(7 downto 0);

begin

	oport <= oport_reg;
	
	-- synchronize incoming signals (anti-meta-state)
	syncproc: process(clk) is
	begin
		if (rising_edge(clk)) then
			iport_reg <= iport;
		end if;
	end process;
	
	-----------------------------------------------------------------------------
	-- Wishbone handling --------------------------------------------------------
	
	wb_ack_o <= wb_stb_i and wb_cyc_i;
	
	wb_dat_o <= iport_reg when ( wb_stb_i='1' and wb_cyc_i='1' and wb_adr_i=IPORT_ADDR ) else
				oport_reg when ( wb_stb_i='1' and wb_cyc_i='1' and wb_adr_i=OPORT_ADDR ) else
				(others => '-');
	
	writeproc: process (reset, clk) is

	begin
		if (reset='0') then 
			oport_reg <= (others => '0');
		elsif ( rising_edge(clk)) then
			if (wb_stb_i='1' and wb_cyc_i='1' and wb_we_i='1') then 
	
				-- decode WB_ADR_I --
				if (wb_adr_i=OPORT_ADDR) then 
					oport_reg <= wb_dat_i;
				end if;
	
			end if;
		end if;
	end process;

end rtl;

