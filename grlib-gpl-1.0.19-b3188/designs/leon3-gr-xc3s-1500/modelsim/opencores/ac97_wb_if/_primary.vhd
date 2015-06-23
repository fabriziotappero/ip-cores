library verilog;
use verilog.vl_types.all;
entity ac97_wb_if is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        wb_data_i       : in     vl_logic_vector(31 downto 0);
        wb_data_o       : out    vl_logic_vector(31 downto 0);
        wb_addr_i       : in     vl_logic_vector(31 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        wb_err_o        : out    vl_logic;
        adr             : out    vl_logic_vector(3 downto 0);
        dout            : out    vl_logic_vector(31 downto 0);
        rf_din          : in     vl_logic_vector(31 downto 0);
        i3_din          : in     vl_logic_vector(31 downto 0);
        i4_din          : in     vl_logic_vector(31 downto 0);
        i6_din          : in     vl_logic_vector(31 downto 0);
        rf_we           : out    vl_logic;
        rf_re           : out    vl_logic;
        o3_we           : out    vl_logic;
        o4_we           : out    vl_logic;
        o6_we           : out    vl_logic;
        o7_we           : out    vl_logic;
        o8_we           : out    vl_logic;
        o9_we           : out    vl_logic;
        i3_re           : out    vl_logic;
        i4_re           : out    vl_logic;
        i6_re           : out    vl_logic
    );
end ac97_wb_if;
