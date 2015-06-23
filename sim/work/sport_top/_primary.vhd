library verilog;
use verilog.vl_types.all;
entity sport_top is
    port(
        DTxPRI          : out    vl_logic;
        DTxSEC          : out    vl_logic;
        TSCLKx          : out    vl_logic;
        TFSx            : out    vl_logic;
        DRxPRI          : in     vl_logic;
        DRxSEC          : in     vl_logic;
        RSCLKx          : out    vl_logic;
        RFSx            : out    vl_logic;
        rx_int          : out    vl_logic;
        rxclk           : in     vl_logic;
        txclk           : in     vl_logic;
        wb_clk_i        : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_we_i         : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector(5 downto 0);
        wb_ack_o        : out    vl_logic;
        wb_err_o        : out    vl_logic;
        wb_rty_o        : out    vl_logic
    );
end sport_top;
