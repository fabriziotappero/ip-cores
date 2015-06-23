library verilog;
use verilog.vl_types.all;
entity decode_pipe is
    port(
        clk             : in     vl_logic;
        id2ra_ctl_clr   : in     vl_logic;
        id2ra_ctl_cls   : in     vl_logic;
        size            : out    vl_logic_vector(1 downto 0);
        ra2ex_ctl_clr   : in     vl_logic;
        ins_i           : in     vl_logic_vector(31 downto 0);
        alu_func_o      : out    vl_logic_vector(4 downto 0);
        alu_we_o        : out    vl_logic_vector(0 downto 0);
        cmp_ctl_o       : out    vl_logic_vector(2 downto 0);
        dmem_ctl_ur_o   : out    vl_logic_vector(4 downto 0);
        ext_ctl_o       : out    vl_logic_vector(2 downto 0);
        fsm_dly         : out    vl_logic_vector(2 downto 0);
        muxa_ctl_o      : out    vl_logic_vector(1 downto 0);
        muxb_ctl_o      : out    vl_logic_vector(1 downto 0);
        pc_gen_ctl_o    : out    vl_logic_vector(2 downto 0);
        rd_sel_o        : out    vl_logic_vector(1 downto 0);
        wb_mux_ctl_o    : out    vl_logic_vector(0 downto 0);
        wb_we_o         : out    vl_logic_vector(0 downto 0);
        load            : in     vl_logic;
        rt1             : in     vl_logic_vector(4 downto 0);
        load_o          : out    vl_logic;
        hold            : in     vl_logic;
        asi             : out    vl_logic_vector(4 downto 0)
    );
end decode_pipe;
