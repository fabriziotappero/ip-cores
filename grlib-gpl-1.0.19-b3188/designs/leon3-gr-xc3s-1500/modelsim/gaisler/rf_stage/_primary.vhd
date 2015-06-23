library verilog;
use verilog.vl_types.all;
entity rf_stage is
    port(
        clk             : in     vl_logic;
        rst_i           : in     vl_logic;
        cmp_ctl_i       : in     vl_logic_vector(2 downto 0);
        ext_ctl_i       : in     vl_logic_vector(2 downto 0);
        fw_alu_i        : in     vl_logic_vector(31 downto 0);
        fw_cmp_rs       : in     vl_logic_vector(2 downto 0);
        fw_cmp_rt       : in     vl_logic_vector(2 downto 0);
        fw_mem_i        : in     vl_logic_vector(31 downto 0);
        id_cmd          : in     vl_logic_vector(2 downto 0);
        ins_i           : in     vl_logic_vector(31 downto 0);
        pc_gen_ctl      : in     vl_logic_vector(2 downto 0);
        pc_i            : in     vl_logic_vector(31 downto 0);
        rd_sel_i        : in     vl_logic_vector(1 downto 0);
        wb_din_i        : in     vl_logic_vector(31 downto 0);
        zz_spc_i        : in     vl_logic_vector(31 downto 0);
        iack_o          : out    vl_logic;
        id2ra_ctl_clr_o : out    vl_logic;
        id2ra_ctl_cls_o : out    vl_logic;
        ra2ex_ctl_clr_o : out    vl_logic;
        ext_o           : out    vl_logic_vector(31 downto 0);
        pc_next         : out    vl_logic_vector(31 downto 0);
        rd_index_o      : out    vl_logic_vector(4 downto 0);
        rs_n_o          : out    vl_logic_vector(4 downto 0);
        rs_o            : out    vl_logic_vector(31 downto 0);
        rt_n_o          : out    vl_logic_vector(4 downto 0);
        rt_o            : out    vl_logic_vector(31 downto 0);
        qa              : in     vl_logic_vector(31 downto 0);
        qb              : in     vl_logic_vector(31 downto 0);
        rdaddra1        : out    vl_logic_vector(4 downto 0);
        rdaddrb1        : out    vl_logic_vector(4 downto 0);
        branch          : out    vl_logic;
        hold            : in     vl_logic
    );
end rf_stage;
