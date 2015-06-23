library verilog;
use verilog.vl_types.all;
entity muxb_ctl_reg is
    port(
        muxb_ctl_i      : in     vl_logic_vector(1 downto 0);
        muxb_ctl_o      : out    vl_logic_vector(1 downto 0);
        clk             : in     vl_logic;
        hold            : in     vl_logic
    );
end muxb_ctl_reg;
