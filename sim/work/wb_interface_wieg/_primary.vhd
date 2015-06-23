library verilog;
use verilog.vl_types.all;
entity wb_interface_wieg is
    port(
        wb_rst_i        : in     vl_logic;
        wb_clk_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        wb_addr_i       : in     vl_logic_vector(5 downto 0);
        wb_we_i         : in     vl_logic;
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_cyc_i        : in     vl_logic;
        wb_cti_i        : in     vl_logic_vector(2 downto 0);
        wb_err_o        : out    vl_logic;
        wb_rty_o        : out    vl_logic;
        rst_o           : out    vl_logic;
        dat_o           : out    vl_logic_vector(31 downto 0);
        dat_i           : in     vl_logic_vector(31 downto 0);
        msgLength       : out    vl_logic_vector(6 downto 0);
        start_tx        : out    vl_logic;
        p2p             : out    vl_logic_vector(31 downto 0);
        pulsewidth      : out    vl_logic_vector(31 downto 0);
        clk_o           : out    vl_logic;
        full            : in     vl_logic;
        lock_cfg_i      : in     vl_logic;
        wb_wr_en        : out    vl_logic;
        rst_FIFO        : out    vl_logic;
        wb_rd_en        : out    vl_logic
    );
end wb_interface_wieg;
