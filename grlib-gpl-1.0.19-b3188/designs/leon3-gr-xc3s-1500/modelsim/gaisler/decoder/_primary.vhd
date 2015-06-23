library verilog;
use verilog.vl_types.all;
entity decoder is
    port(
        ins_i           : in     vl_logic_vector(31 downto 0);
        load            : in     vl_logic;
        rt1             : in     vl_logic_vector(4 downto 0);
        load_o          : out    vl_logic;
        read_rs         : out    vl_logic;
        read_rt         : out    vl_logic;
        size            : out    vl_logic_vector(1 downto 0);
        ext_ctl         : out    vl_logic_vector(2 downto 0);
        rd_sel          : out    vl_logic_vector(1 downto 0);
        cmp_ctl         : out    vl_logic_vector(2 downto 0);
        pc_gen_ctl      : out    vl_logic_vector(2 downto 0);
        fsm_dly         : out    vl_logic_vector(2 downto 0);
        muxa_ctl        : out    vl_logic_vector(1 downto 0);
        muxb_ctl        : out    vl_logic_vector(1 downto 0);
        alu_func        : out    vl_logic_vector(4 downto 0);
        dmem_ctl        : out    vl_logic_vector(4 downto 0);
        alu_we          : out    vl_logic_vector(0 downto 0);
        wb_mux          : out    vl_logic_vector(0 downto 0);
        wb_we           : out    vl_logic_vector(0 downto 0);
        asi             : out    vl_logic_vector(4 downto 0)
    );
end decoder;
