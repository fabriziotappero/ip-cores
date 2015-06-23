library verilog;
use verilog.vl_types.all;
entity wb_interface_sport is
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
        rxsampleCnt     : out    vl_logic_vector(4 downto 0);
        rxpacketCnt     : out    vl_logic_vector(9 downto 0);
        txsampleCnt     : out    vl_logic_vector(4 downto 0);
        txpacketCnt     : out    vl_logic_vector(9 downto 0);
        dat_i           : in     vl_logic_vector(31 downto 0);
        dat_o           : out    vl_logic_vector(31 downto 0);
        rxsecEn         : out    vl_logic;
        rxlateFS_earlyFSn: out    vl_logic;
        txsecEn         : out    vl_logic;
        txlateFS_earlyFSn: out    vl_logic;
        tx_actHi        : out    vl_logic;
        rx_actHi        : out    vl_logic;
        msbFirst        : out    vl_logic;
        tx_start        : out    vl_logic;
        rx_start        : out    vl_logic;
        rx_int          : out    vl_logic
    );
end wb_interface_sport;
