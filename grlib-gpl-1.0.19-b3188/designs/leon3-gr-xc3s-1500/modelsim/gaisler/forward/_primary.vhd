library verilog;
use verilog.vl_types.all;
entity forward is
    port(
        alu_we          : in     vl_logic;
        clk             : in     vl_logic;
        mem_We          : in     vl_logic;
        fw_alu_rn       : in     vl_logic_vector(4 downto 0);
        fw_mem_rn       : in     vl_logic_vector(4 downto 0);
        rns_i           : in     vl_logic_vector(4 downto 0);
        rnt_i           : in     vl_logic_vector(4 downto 0);
        alu_rs_fw       : out    vl_logic_vector(2 downto 0);
        alu_rt_fw       : out    vl_logic_vector(2 downto 0);
        cmp_rs_fw       : out    vl_logic_vector(2 downto 0);
        cmp_rt_fw       : out    vl_logic_vector(2 downto 0);
        dmem_fw         : out    vl_logic_vector(2 downto 0);
        hold            : in     vl_logic
    );
end forward;
