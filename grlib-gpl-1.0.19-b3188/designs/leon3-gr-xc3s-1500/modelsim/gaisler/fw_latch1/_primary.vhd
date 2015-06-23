library verilog;
use verilog.vl_types.all;
entity fw_latch1 is
    port(
        clk             : in     vl_logic;
        d               : in     vl_logic;
        hold            : in     vl_logic;
        q               : out    vl_logic
    );
end fw_latch1;
