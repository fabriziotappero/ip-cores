library verilog;
use verilog.vl_types.all;
entity M25LC256 is
    port(
        SI              : in     vl_logic;
        SO              : out    vl_logic;
        SCK             : in     vl_logic;
        CS_N            : in     vl_logic;
        WP_N            : in     vl_logic;
        HOLD_N          : in     vl_logic;
        RESET           : in     vl_logic
    );
end M25LC256;
