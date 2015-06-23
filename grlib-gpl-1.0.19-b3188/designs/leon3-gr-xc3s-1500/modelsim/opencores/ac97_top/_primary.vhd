library verilog;
use verilog.vl_types.all;
entity ac97_top is
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        wb_data_i       : in     vl_logic_vector(31 downto 0);
        wb_data_o       : out    vl_logic_vector(31 downto 0);
        wb_addr_i       : in     vl_logic_vector(31 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        wb_err_o        : out    vl_logic;
        int_o           : out    vl_logic;
        dma_req_o       : out    vl_logic_vector(8 downto 0);
        dma_ack_i       : in     vl_logic_vector(8 downto 0);
        suspended_o     : out    vl_logic;
        bit_clk_pad_i   : in     vl_logic;
        sync_pad_o      : out    vl_logic;
        sdata_pad_o     : out    vl_logic;
        sdata_pad_i     : in     vl_logic;
        ac97_resetn_pad_o: out    vl_logic
    );
end ac97_top;
