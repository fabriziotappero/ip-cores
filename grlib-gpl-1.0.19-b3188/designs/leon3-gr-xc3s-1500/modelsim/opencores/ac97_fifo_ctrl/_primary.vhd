library verilog;
use verilog.vl_types.all;
entity ac97_fifo_ctrl is
    port(
        clk             : in     vl_logic;
        valid           : in     vl_logic;
        ch_en           : in     vl_logic;
        srs             : in     vl_logic;
        full_empty      : in     vl_logic;
        req             : in     vl_logic;
        crdy            : in     vl_logic;
        en_out          : out    vl_logic;
        en_out_l        : out    vl_logic
    );
end ac97_fifo_ctrl;
