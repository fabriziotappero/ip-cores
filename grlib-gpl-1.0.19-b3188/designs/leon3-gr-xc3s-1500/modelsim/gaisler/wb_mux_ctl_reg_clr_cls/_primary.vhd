library verilog;
use verilog.vl_types.all;
entity wb_mux_ctl_reg_clr_cls is
    port(
        wb_mux_ctl_i    : in     vl_logic_vector(0 downto 0);
        wb_mux_ctl_o    : out    vl_logic_vector(0 downto 0);
        clk             : in     vl_logic;
        clr             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end wb_mux_ctl_reg_clr_cls;
