library verilog;
use verilog.vl_types.all;
entity dmem_ctl_reg is
    port(
        dmem_ctl_i      : in     vl_logic_vector(4 downto 0);
        dmem_ctl_o      : out    vl_logic_vector(4 downto 0);
        clk             : in     vl_logic;
        hold            : in     vl_logic
    );
end dmem_ctl_reg;
