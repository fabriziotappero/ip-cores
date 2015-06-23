library verilog;
use verilog.vl_types.all;
entity wiegand_tx_top is
    port(
        one_o           : out    vl_logic;
        zero_o          : out    vl_logic;
        wb_clk_i        : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_cti_i        : in     vl_logic_vector(2 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector(5 downto 0);
        wb_ack_o        : out    vl_logic;
        wb_err_o        : out    vl_logic;
        wb_rty_o        : out    vl_logic
    );
end wiegand_tx_top;
