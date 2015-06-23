-----------------------------------------------------------------------------
-- Wishbone GPIO ------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;

entity wb_gpio is
   port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      -- Wishbone bus
      wb_adr_i : in  std_logic_vector(31 downto 0);
      wb_dat_i : in  std_logic_vector(31 downto 0);
      wb_dat_o : out std_logic_vector(31 downto 0);
      wb_sel_i : in  std_logic_vector( 3 downto 0);
      wb_cyc_i : in  std_logic;
      wb_stb_i : in  std_logic;
      wb_ack_o : out std_logic;
      wb_we_i  : in  std_logic;
      -- I/O ports
      iport    : in  std_logic_vector(31 downto 0);
      oport    : out std_logic_vector(31 downto 0) );
end wb_gpio;

-----------------------------------------------------------------------------
-- Implementation -----------------------------------------------------------
architecture rtl of wb_gpio is

signal wbactive  : std_logic;

signal oport_reg : std_logic_vector(31 downto 0);
signal iport_reg : std_logic_vector(31 downto 0);

begin

oport <= oport_reg;

-- synchronize incoming signals (anti-meta-state)
syncproc: process(clk) is
begin
	if clk'event and clk='1' then
		iport_reg <= iport;
	end if;
end process;

-----------------------------------------------------------------------------
-- Wishbone handling --------------------------------------------------------

wb_ack_o <= wb_stb_i and wb_cyc_i;

wb_dat_o <= iport_reg when wb_stb_i='1' and wb_cyc_i='1' and wb_adr_i(3 downto 0)=x"0" else
            oport_reg when wb_stb_i='1' and wb_cyc_i='1' and wb_adr_i(3 downto 0)=x"4" else
            (others => '-');

writeproc: process (reset, clk) is
variable val : std_logic_vector(31 downto 0);
begin
	if reset='1' then 
		oport_reg <= (others => '0');
	elsif clk'event and clk='1' then
		if wb_stb_i='1' and wb_cyc_i='1' and wb_we_i='1' then 

			-- decode WB_SEL_I --
			if wb_sel_i(3)='1' then
				val(31 downto 24) := wb_dat_i(31 downto 24);
			end if;
			if wb_sel_i(2)='1' then
				val(23 downto 16) := wb_dat_i(23 downto 16);
			end if;
			if wb_sel_i(1)='1' then
				val(15 downto  8) := wb_dat_i(15 downto  8);
			end if;
			if wb_sel_i(0)='1' then
				val( 7 downto  0) := wb_dat_i( 7 downto  0);
			end if;

			-- decode WB_ADR_I --
			if wb_adr_i(3 downto 0)=x"4" then 
				oport_reg <= val;
			end if;

		end if;
	end if;
end process;

end rtl;

