library verilog;
use verilog.vl_types.all;
entity branch_reg_whold is
    port(
        pc_i            : in     vl_logic_vector(31 downto 0);
        pc_o            : out    vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        branch          : in     vl_logic
    );
end branch_reg_whold;
