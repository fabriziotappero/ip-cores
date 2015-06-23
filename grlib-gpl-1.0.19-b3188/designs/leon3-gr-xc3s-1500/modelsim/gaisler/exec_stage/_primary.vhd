library verilog;
use verilog.vl_types.all;
entity exec_stage is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        spc_cls_i       : in     vl_logic;
        alu_func        : in     vl_logic_vector(4 downto 0);
        dmem_fw_ctl     : in     vl_logic_vector(2 downto 0);
        ext_i           : in     vl_logic_vector(31 downto 0);
        fw_alu          : in     vl_logic_vector(31 downto 0);
        fw_dmem         : in     vl_logic_vector(31 downto 0);
        muxa_ctl_i      : in     vl_logic_vector(1 downto 0);
        muxa_fw_ctl     : in     vl_logic_vector(2 downto 0);
        muxb_ctl_i      : in     vl_logic_vector(1 downto 0);
        muxb_fw_ctl     : in     vl_logic_vector(2 downto 0);
        pc_i            : in     vl_logic_vector(31 downto 0);
        rs_i            : in     vl_logic_vector(31 downto 0);
        rt_i            : in     vl_logic_vector(31 downto 0);
        alu_ur_o        : out    vl_logic_vector(31 downto 0);
        dmem_data_ur_o  : out    vl_logic_vector(31 downto 0);
        zz_spc_o        : out    vl_logic_vector(31 downto 0);
        hold            : in     vl_logic
    );
end exec_stage;
