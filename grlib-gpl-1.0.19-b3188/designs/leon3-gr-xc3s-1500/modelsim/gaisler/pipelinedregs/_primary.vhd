library verilog;
use verilog.vl_types.all;
entity pipelinedregs is
    port(
        clk             : in     vl_logic;
        id2ra_ctl_clr   : in     vl_logic;
        id2ra_ctl_cls   : in     vl_logic;
        ra2ex_ctl_clr   : in     vl_logic;
        alu_func_i      : in     vl_logic_vector(4 downto 0);
        alu_we_i        : in     vl_logic_vector(0 downto 0);
        cmp_ctl_i       : in     vl_logic_vector(2 downto 0);
        dmem_ctl_i      : in     vl_logic_vector(4 downto 0);
        ext_ctl_i       : in     vl_logic_vector(2 downto 0);
        muxa_ctl_i      : in     vl_logic_vector(1 downto 0);
        muxb_ctl_i      : in     vl_logic_vector(1 downto 0);
        pc_gen_ctl_i    : in     vl_logic_vector(2 downto 0);
        rd_sel_i        : in     vl_logic_vector(1 downto 0);
        wb_mux_ctl_i    : in     vl_logic_vector(0 downto 0);
        wb_we_i         : in     vl_logic_vector(0 downto 0);
        alu_func_o      : out    vl_logic_vector(4 downto 0);
        alu_we_o        : out    vl_logic_vector(0 downto 0);
        cmp_ctl_o       : out    vl_logic_vector(2 downto 0);
        dmem_ctl_ur_o   : out    vl_logic_vector(4 downto 0);
        ext_ctl         : out    vl_logic_vector(2 downto 0);
        muxa_ctl_o      : out    vl_logic_vector(1 downto 0);
        muxb_ctl_o      : out    vl_logic_vector(1 downto 0);
        pc_gen_ctl_o    : out    vl_logic_vector(2 downto 0);
        rd_sel_o        : out    vl_logic_vector(1 downto 0);
        wb_mux_ctl_o    : out    vl_logic_vector(0 downto 0);
        wb_we_o         : out    vl_logic_vector(0 downto 0);
        hold            : in     vl_logic
    );
end pipelinedregs;
