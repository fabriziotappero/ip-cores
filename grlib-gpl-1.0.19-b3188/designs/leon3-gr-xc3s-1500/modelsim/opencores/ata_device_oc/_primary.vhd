library verilog;
use verilog.vl_types.all;
entity ata_device_oc is
    port(
        ata_rst_n       : in     vl_logic;
        ata_data        : inout  vl_logic_vector(15 downto 0);
        ata_da          : in     vl_logic_vector(2 downto 0);
        ata_cs0         : in     vl_logic;
        ata_cs1         : in     vl_logic;
        ata_dior_n      : in     vl_logic;
        ata_diow_n      : in     vl_logic;
        ata_iordy       : out    vl_logic;
        ata_intrq       : out    vl_logic
    );
end ata_device_oc;
