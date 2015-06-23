library verilog;
use verilog.vl_types.all;
entity fsm_ctl_reg_cls is
    port(
        fsm_ctl_i       : in     vl_logic_vector(2 downto 0);
        fsm_ctl_o       : out    vl_logic_vector(2 downto 0);
        clk             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end fsm_ctl_reg_cls;
