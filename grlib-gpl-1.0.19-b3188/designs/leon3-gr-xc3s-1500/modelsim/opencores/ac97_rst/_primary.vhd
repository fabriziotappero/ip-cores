library verilog;
use verilog.vl_types.all;
entity ac97_rst is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        rst_force       : in     vl_logic;
        ps_ce           : out    vl_logic;
        \ac97_rst_\     : out    vl_logic
    );
end ac97_rst;
