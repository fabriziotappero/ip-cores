library verilog;
use verilog.vl_types.all;
entity muxa_ctl_reg is
    port(
        muxa_ctl_i      : in     vl_logic_vector(1 downto 0);
        muxa_ctl_o      : out    vl_logic_vector(1 downto 0);
        clk             : in     vl_logic;
        hold            : in     vl_logic
    );
end muxa_ctl_reg;
