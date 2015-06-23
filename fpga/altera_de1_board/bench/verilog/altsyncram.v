// START_MODULE_NAME------------------------------------------------------------
//
// Module Name     : ALTSYNCRAM
//
// Description     : Synchronous ram model for Stratix series family
//
// Limitation      :
//
// END_MODULE_NAME--------------------------------------------------------------

`timescale 1 ps / 1 ps

// BEGINNING OF MODULE

// MODULE DECLARATION

module altsyncram   (
                    wren_a,
                    wren_b,
                    rden_a,
                    rden_b,
                    data_a,
                    data_b,
                    address_a,
                    address_b,
                    clock0,
                    clock1,
                    clocken0,
                    clocken1,
                    clocken2,
                    clocken3,
                    aclr0,
                    aclr1,
                    byteena_a,
                    byteena_b,
                    addressstall_a,
                    addressstall_b,
                    q_a,
                    q_b,
                    eccstatus
                    );

// GLOBAL PARAMETER DECLARATION

    // PORT A PARAMETERS
    parameter width_a          = 1;
    parameter widthad_a        = 1;
    parameter numwords_a       = 0;
    parameter outdata_reg_a    = "UNREGISTERED";
    parameter address_aclr_a   = "NONE";
    parameter outdata_aclr_a   = "NONE";
    parameter indata_aclr_a    = "NONE";
    parameter wrcontrol_aclr_a = "NONE";
    parameter byteena_aclr_a   = "NONE";
    parameter width_byteena_a  = 1;

    // PORT B PARAMETERS
    parameter width_b                   = 1;
    parameter widthad_b                 = 1;
    parameter numwords_b                = 0;
    parameter rdcontrol_reg_b           = "CLOCK1";
    parameter address_reg_b             = "CLOCK1";
    parameter outdata_reg_b             = "UNREGISTERED";
    parameter outdata_aclr_b            = "NONE";
    parameter rdcontrol_aclr_b          = "NONE";
    parameter indata_reg_b              = "CLOCK1";
    parameter wrcontrol_wraddress_reg_b = "CLOCK1";
    parameter byteena_reg_b             = "CLOCK1";
    parameter indata_aclr_b             = "NONE";
    parameter wrcontrol_aclr_b          = "NONE";
    parameter address_aclr_b            = "NONE";
    parameter byteena_aclr_b            = "NONE";
    parameter width_byteena_b           = 1;

    // STRATIX II RELATED PARAMETERS
    parameter clock_enable_input_a  = "NORMAL";
    parameter clock_enable_output_a = "NORMAL";
    parameter clock_enable_input_b  = "NORMAL";
    parameter clock_enable_output_b = "NORMAL";

    parameter clock_enable_core_a = "USE_INPUT_CLKEN";
    parameter clock_enable_core_b = "USE_INPUT_CLKEN";
    parameter read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ";
    parameter read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ";

    // ECC STATUS RELATED PARAMETERS
    parameter enable_ecc = "FALSE";

    // GLOBAL PARAMETERS
    parameter operation_mode                     = "BIDIR_DUAL_PORT";
    parameter byte_size                          = 0;
    parameter read_during_write_mode_mixed_ports = "DONT_CARE";
    parameter ram_block_type                     = "AUTO";
    parameter init_file                          = "UNUSED";
    parameter init_file_layout                   = "UNUSED";
    parameter maximum_depth                      = 0;
    parameter intended_device_family             = "Stratix";

    parameter lpm_hint                           = "UNUSED";
    parameter lpm_type                           = "altsyncram";

    parameter implement_in_les                 = "OFF";
    
    parameter power_up_uninitialized            = "FALSE";
    
    parameter sim_show_memory_data_in_port_b_layout  = "OFF";
    
    // Internal parameters
    
    parameter is_lutram = ((ram_block_type == "LUTRAM") || (ram_block_type == "MLAB"))? 1 : 0;
    
    parameter is_bidir_and_wrcontrol_addb_clk0 =    (((operation_mode == "BIDIR_DUAL_PORT") && (address_reg_b == "CLOCK0"))? 
                                                    1 : 0);

    parameter is_bidir_and_wrcontrol_addb_clk1 =    (((operation_mode == "BIDIR_DUAL_PORT") && (address_reg_b == "CLOCK1"))? 
                                                    1 : 0);

    parameter check_simultaneous_read_write =   (((operation_mode == "BIDIR_DUAL_PORT") || (operation_mode == "DUAL_PORT")) && 
                                                ((ram_block_type == "M-RAM") || 
                                                    (ram_block_type == "MEGARAM") || 
                                                    ((ram_block_type == "AUTO") && (read_during_write_mode_mixed_ports == "DONT_CARE")) ||
                                                    ((is_lutram == 1) && ((read_during_write_mode_mixed_ports != "OLD_DATA") || (outdata_reg_b == "UNREGISTERED")))))? 1 : 0;

    parameter dual_port_addreg_b_clk0 = (((operation_mode == "DUAL_PORT") && (address_reg_b == "CLOCK0"))? 1: 0);

    parameter dual_port_addreg_b_clk1 = (((operation_mode == "DUAL_PORT") && (address_reg_b == "CLOCK1"))? 1: 0);

    parameter i_byte_size_tmp = (width_byteena_a > 1)? width_a / width_byteena_a : 8;
    
    parameter i_lutram_read = (((is_lutram == 1) && (read_during_write_mode_port_a == "DONT_CARE")) ||
                                ((is_lutram == 1) && (outdata_reg_a == "UNREGISTERED") && (operation_mode == "SINGLE_PORT")))? 1 : 0;

    parameter enable_mem_data_b_reading =  (sim_show_memory_data_in_port_b_layout == "ON") &&
                                            ((operation_mode == "BIDIR_DUAL_PORT") || (operation_mode == "DUAL_PORT")) ? 1 : 0;



// INPUT PORT DECLARATION

    input  wren_a; // Port A write/read enable input
    input  wren_b; // Port B write enable input
    input  rden_a; // Port A read enable input
    input  rden_b; // Port B read enable input
    input  [width_a-1:0] data_a; // Port A data input
    input  [width_b-1:0] data_b; // Port B data input
    input  [widthad_a-1:0] address_a; // Port A address input
    input  [widthad_b-1:0] address_b; // Port B address input

    // clock inputs on both ports and here are their usage
    // Port A -- 1. all input registers must be clocked by clock0.
    //           2. output register can be clocked by either clock0, clock1 or none.
    // Port B -- 1. all input registered must be clocked by either clock0 or clock1.
    //           2. output register can be clocked by either clock0, clock1 or none.
    input  clock0;
    input  clock1;

    // clock enable inputs and here are their usage
    // clocken0 -- can only be used for enabling clock0.
    // clocken1 -- can only be used for enabling clock1.
    // clocken2 -- as an alternative for enabling clock0.
    // clocken3 -- as an alternative for enabling clock1.
    input  clocken0;
    input  clocken1;
    input  clocken2;
    input  clocken3;

    // clear inputs on both ports and here are their usage
    // Port A -- 1. all input registers can only be cleared by clear0 or none.
    //           2. output register can be cleared by either clear0, clear1 or none.
    // Port B -- 1. all input registers can be cleared by clear0, clear1 or none.
    //           2. output register can be cleared by either clear0, clear1 or none.
    input  aclr0;
    input  aclr1;

    input [width_byteena_a-1:0] byteena_a; // Port A byte enable input
    input [width_byteena_b-1:0] byteena_b; // Port B byte enable input

    // Stratix II related ports
    input addressstall_a;
    input addressstall_b;



// OUTPUT PORT DECLARATION

    output [width_a-1:0] q_a; // Port A output
    output [width_b-1:0] q_b; // Port B output

    output [2:0] eccstatus;   // ECC status flags

// INTERNAL REGISTERS DECLARATION

    reg [width_a-1:0] mem_data [0:(1<<widthad_a)-1];
    reg [width_b-1:0] mem_data_b [0:(1<<widthad_b)-1];
    reg [width_a-1:0] i_data_reg_a;
    reg [width_a-1:0] temp_wa;
    reg [width_a-1:0] temp_wa2;
    reg [width_a-1:0] temp_wa2b;
    reg [width_a-1:0] init_temp;
    reg [width_b-1:0] i_data_reg_b;
    reg [width_b-1:0] temp_wb;
    reg [width_b-1:0] temp_wb2;
    reg temp;
    reg [width_a-1:0] i_q_reg_a;
    reg [width_a-1:0] i_q_tmp_a;
    reg [width_a-1:0] i_q_tmp2_a;
    reg [width_b-1:0] i_q_reg_b;
    reg [width_b-1:0] i_q_tmp_b;
    reg [width_b-1:0] i_q_tmp2_b;
    reg [width_b-1:0] i_q_output_latch;
    reg [width_a-1:0] i_byteena_mask_reg_a;
    reg [width_b-1:0] i_byteena_mask_reg_b;
    reg [widthad_a-1:0] i_address_reg_a;
    reg [widthad_b-1:0] i_address_reg_b;

    reg [widthad_a-1:0] i_original_address_a;
    
    reg [width_a-1:0] i_byteena_mask_reg_a_tmp;
    reg [width_b-1:0] i_byteena_mask_reg_b_tmp;
    reg [width_a-1:0] i_byteena_mask_reg_a_out;
    reg [width_b-1:0] i_byteena_mask_reg_b_out;
    reg [width_a-1:0] i_byteena_mask_reg_a_x;
    reg [width_b-1:0] i_byteena_mask_reg_b_x;
    reg [width_a-1:0] i_byteena_mask_reg_a_out_b;
    reg [width_b-1:0] i_byteena_mask_reg_b_out_a;


    reg [8*256:1] ram_initf;
    reg i_wren_reg_a;
    reg i_wren_reg_b;
    reg i_rden_reg_a;
    reg i_rden_reg_b;
    reg i_read_flag_a;
    reg i_read_flag_b;
    reg i_write_flag_a;
    reg i_write_flag_b;
    reg good_to_go_a;
    reg good_to_go_b;
    reg [31:0] file_desc;
    reg init_file_b_port;
    reg i_nmram_write_a;
    reg i_nmram_write_b;

    reg [width_a - 1: 0] wa_mult_x;
    reg [width_a - 1: 0] wa_mult_x_ii;
    reg [width_a - 1: 0] wa_mult_x_iii;
    reg [widthad_a + width_a - 1:0] add_reg_a_mult_wa;
    reg [widthad_b + width_b -1:0] add_reg_b_mult_wb;
    reg [widthad_a + width_a - 1:0] add_reg_a_mult_wa_pl_wa;
    reg [widthad_b + width_b -1:0] add_reg_b_mult_wb_pl_wb;

    reg same_clock_pulse0;
    reg same_clock_pulse1;
    
    reg [width_b - 1 : 0] i_original_data_b;
    reg [width_a - 1 : 0] i_original_data_a;
    
    reg i_address_aclr_a_flag;
    reg i_address_aclr_a_prev;
    reg i_address_aclr_b_flag;
    reg i_address_aclr_b_prev;
    reg i_outdata_aclr_a_prev;
    reg i_outdata_aclr_b_prev;
    reg i_force_reread_a;
    reg i_force_reread_a1;
    reg i_force_reread_b;
    reg i_force_reread_b1;
    reg i_force_reread_a_signal;
    reg i_force_reread_b_signal;
    
// INTERNAL PARAMETER
    reg is_write_positive_edge_reg;
    reg [9*8:0] cread_during_write_mode_mixed_ports;
    reg i_lutram_single_port_fast_read;
    reg i_lutram_dual_port_fast_read;
    reg [7*8:0] i_ram_block_type;
    integer i_byte_size;
    
    wire i_good_to_write_a;
    wire i_good_to_write_b;
    reg i_good_to_write_a2;
    reg i_good_to_write_b2;

    reg i_core_clocken_a_reg;
    reg i_core_clocken0_b_reg;
    reg i_core_clocken1_b_reg;

    wire s3_address_aclr_a;
    wire s3_address_aclr_b;

// INTERNAL WIRE DECLARATIONS

    wire i_indata_aclr_a;
    wire i_address_aclr_a;
    wire i_address_aclr_family_a;
    wire i_wrcontrol_aclr_a;
    wire i_indata_aclr_b;
    wire i_address_aclr_b;
    wire i_address_aclr_family_b;
    wire i_wrcontrol_aclr_b;
    wire i_outdata_aclr_a;
    wire i_outdata_aclr_b;
    wire i_rdcontrol_aclr_b;
    wire i_byteena_aclr_a;
    wire i_byteena_aclr_b;
    wire i_outdata_clk_a;
    wire i_outdata_clken_a;
    wire i_outdata_clk_b;
    wire i_outdata_clken_b;
    wire i_clocken0;
    wire i_clocken1_b;
    wire i_clocken0_b;
    wire i_core_clocken_a;
    wire i_core_clocken_b;
    wire i_core_clocken0_b;
    wire i_core_clocken1_b;

// INTERNAL TRI DECLARATION

    tri0 wren_a;
    tri0 wren_b;
    tri1 rden_a;
    tri1 rden_b;
    tri1 clock0;
    tri1 clocken0;
    tri1 clocken1;
    tri1 clocken2;
    tri1 clocken3;
    tri0 aclr0;
    tri0 aclr1;
    tri0 addressstall_a;
    tri0 addressstall_b;
    tri1 [width_byteena_a-1:0] i_byteena_a;
    tri1 [width_byteena_b-1:0] i_byteena_b;


// LOCAL INTEGER DECLARATION

    integer i_numwords_a;
    integer i_numwords_b;
    integer i_aclr_flag_a;
    integer i_aclr_flag_b;
    integer i_q_tmp2_a_idx;

    // for loop iterators
    integer init_i;
    integer i;
    integer i2;
    integer i3;
    integer i4;
    integer i5;
    integer j;
    integer j2;
    integer j3;
    integer k;
    integer k2;
    integer k3;
    integer k4;
    
    // For temporary calculation
    integer i_div_wa;
    integer i_div_wb;
    integer j_plus_i2;
    integer j2_plus_i5;
    integer j3_plus_i5;
    integer j_plus_i2_div_a;
    integer j2_plus_i5_div_a;
    integer j3_plus_i5_div_a;
    integer j3_plus_i5_div_b;
    integer i_byteena_count;
    integer port_a_bit_count_low;
    integer port_a_bit_count_high;
    integer port_b_bit_count_low;
    integer port_b_bit_count_high;

    time i_data_write_time_a;

    // ------------------------
    // COMPONENT INSTANTIATIONS
    // ------------------------
    ALTERA_DEVICE_FAMILIES dev ();
    ALTERA_MF_MEMORY_INITIALIZATION mem ();

// INITIAL CONSTRUCT BLOCK

    initial
    begin
    

        i_numwords_a = (numwords_a != 0) ? numwords_a : (1 << widthad_a);
        i_numwords_b = (numwords_b != 0) ? numwords_b : (1 << widthad_b);
        
        if (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1)
        begin
            if ((ram_block_type == "M-RAM") || (ram_block_type == "MEGARAM"))
                i_ram_block_type = "M144K";
            else if ((((ram_block_type == "M144K") || (is_lutram == 1)) && (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1)) ||
                    (ram_block_type == "M9K"))
                i_ram_block_type = ram_block_type;
            else
                i_ram_block_type = "AUTO";
        end
        else
        begin
            if ((ram_block_type != "AUTO") &&
                (ram_block_type != "M-RAM") && (ram_block_type != "MEGARAM") &&
                (ram_block_type != "M512") &&
                (ram_block_type != "M4K"))
                i_ram_block_type = "AUTO";
            else
                i_ram_block_type = ram_block_type;
        end

        if (((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")) || (i_ram_block_type == "M9K") || (i_ram_block_type == "M144K") || 
            ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) && (i_ram_block_type == "AUTO")))
            is_write_positive_edge_reg = 1;
        else
            is_write_positive_edge_reg = 0;
            
        if ((dev.FEATURE_FAMILY_CYCLONE(intended_device_family) == 1) || (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 1))
            cread_during_write_mode_mixed_ports = "OLD_DATA";
        else if (read_during_write_mode_mixed_ports == "UNUSED")
            cread_during_write_mode_mixed_ports = "DONT_CARE";
        else
            cread_during_write_mode_mixed_ports = read_during_write_mode_mixed_ports;
            
        if ((is_lutram == 1) && 
            ((read_during_write_mode_port_a == "DONT_CARE") || (outdata_reg_a == "UNREGISTERED")) &&
            (operation_mode == "SINGLE_PORT"))
            i_lutram_single_port_fast_read = 1;
        else
            i_lutram_single_port_fast_read = 0;
            
        if ((is_lutram == 1) &&
            ((read_during_write_mode_mixed_ports == "NEW_DATA") ||
            (read_during_write_mode_mixed_ports == "DONT_CARE") ||
            ((read_during_write_mode_mixed_ports == "OLD_DATA") && (outdata_reg_b == "UNREGISTERED"))))
            i_lutram_dual_port_fast_read = 1;
        else
            i_lutram_dual_port_fast_read = 0;
            
        i_byte_size = (byte_size > 0) ? byte_size
                        : ((((dev.FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM(intended_device_family) == 1) || dev.FEATURE_FAMILY_CYCLONEIII(intended_device_family) == 1) && (i_byte_size_tmp != 8) && (i_byte_size_tmp != 9)) ||
                            (((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1) || (dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)) && (i_byte_size_tmp != 1) && (i_byte_size_tmp != 2) && (i_byte_size_tmp != 4) && (i_byte_size_tmp != 8) && (i_byte_size_tmp != 9)) ||
                            ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) && (i_byte_size_tmp != 5) && (i_byte_size_tmp !=10) && (i_byte_size_tmp != 8) && (i_byte_size_tmp != 9))) ?
                            8 : i_byte_size_tmp;
            
        // Parameter Checking
        if ((operation_mode != "BIDIR_DUAL_PORT") && (operation_mode != "SINGLE_PORT") &&
            (operation_mode != "DUAL_PORT") && (operation_mode != "ROM"))
        begin
            $display("Error: Not a valid operation mode.");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1) &&
            (ram_block_type != "M9K") && (ram_block_type != "M144K") && (is_lutram != 1) &&
            (ram_block_type != "AUTO") && (((ram_block_type == "M-RAM") || (ram_block_type == "MEGARAM")) != 1))
        begin
            $display("Warning: RAM_BLOCK_TYPE HAS AN INVALID VALUE. IT CAN ONLY BE M9K, M144K, LUTRAM OR AUTO for %s device family. This parameter will take AUTO as it's value", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if (i_ram_block_type != ram_block_type)
        begin
            $display("Warning: RAM block type is assumed as %s", i_ram_block_type);
            $display("Time: %0t  Instance: %m", $time);
        end


        if ((cread_during_write_mode_mixed_ports != "DONT_CARE") &&
            (cread_during_write_mode_mixed_ports != "OLD_DATA") && 
            (cread_during_write_mode_mixed_ports != "NEW_DATA"))
        begin
            $display("Error: Invalid value for read_during_write_mode_mixed_ports parameter. It has to be OLD_DATA or DONT_CARE or NEW_DATA");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if ((cread_during_write_mode_mixed_ports != read_during_write_mode_mixed_ports) && ((operation_mode != "SINGLE_PORT") && (operation_mode != "ROM")))
        begin
            $display("Warning: read_during_write_mode_mixed_ports is assumed as %s", cread_during_write_mode_mixed_ports);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if ((is_lutram != 1) && (cread_during_write_mode_mixed_ports == "NEW_DATA"))
        begin
            $display("Warning: read_during_write_mode_mixed_ports cannot be set to NEW_DATA for non-LUTRAM ram block type. This will cause incorrect simulation result.");
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")) && init_file != "UNUSED")
        begin
            $display("Error: M-RAM block type doesn't support the use of an initialization file");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((i_byte_size != 8) && (i_byte_size != 9) && (dev.FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM(intended_device_family) == 1))
        begin
            $display("Error: byte_size HAS TO BE EITHER 8 or 9");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((i_byte_size != 8) && (i_byte_size != 9) && (i_byte_size != 1) &&
            (i_byte_size != 2) && (i_byte_size != 4) && 
            ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1) || (dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)))
        begin
            $display("Error: byte_size has to be either 1, 2, 4, 8 or 9 for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((i_byte_size != 5) && (i_byte_size != 8) && (i_byte_size != 9) && (i_byte_size != 10) &&
            (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1))
        begin
            $display("Error: byte_size has to be either 5,8,9 or 10 for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (width_a <= 0)
        begin
            $display("Error: Invalid value for WIDTH_A parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((width_b <= 0) &&
            ((operation_mode != "SINGLE_PORT") || (operation_mode != "ROM")))
        begin
            $display("Error: Invalid value for WIDTH_B parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (widthad_a <= 0)
        begin
            $display("Error: Invalid value for WIDTHAD_A parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((width_b <= 0) &&
            ((operation_mode != "SINGLE_PORT") || (operation_mode != "ROM")))
        begin
            $display("Error: Invalid value for WIDTHAD_B parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((operation_mode == "ROM") &&
            ((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")))
        begin
            $display("Error: ROM mode does not support RAM_BLOCK_TYPE = M-RAM");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((wrcontrol_aclr_a != "NONE") && (wrcontrol_aclr_a != "UNUSED")) && (i_ram_block_type == "M512") && (operation_mode == "SINGLE_PORT"))
        begin
            $display("Error: Wren_a cannot have clear in single port mode for M512 block");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((operation_mode == "DUAL_PORT") && (i_numwords_a * width_a != i_numwords_b * width_b))
        begin
            $display("Error: Total number of bits of port A and port B should be the same for dual port mode");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((rdcontrol_aclr_b != "NONE") && (rdcontrol_aclr_b != "UNUSED")) && (i_ram_block_type == "M512") && (operation_mode == "DUAL_PORT"))
        begin
            $display("Error: rden_b cannot have clear in simple dual port mode for M512 block");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((operation_mode == "BIDIR_DUAL_PORT") && (i_numwords_a * width_a != i_numwords_b * width_b))
        begin
            $display("Error: Total number of bits of port A and port B should be the same for bidir dual port mode");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((operation_mode == "BIDIR_DUAL_PORT") && (i_ram_block_type == "M512"))
        begin
            $display("Error: M512 block type doesn't support bidir dual mode");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")) &&
            (cread_during_write_mode_mixed_ports == "OLD_DATA"))
        begin
            $display("Error: M-RAM doesn't support OLD_DATA value for READ_DURING_WRITE_MODE_MIXED_PORTS parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM(intended_device_family) == 1) &&
            (clock_enable_input_a == "BYPASS"))
        begin
            $display("Error: BYPASS value for CLOCK_ENABLE_INPUT_A is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM(intended_device_family) == 1) &&
            (clock_enable_output_a == "BYPASS"))
        begin
            $display("Error: BYPASS value for CLOCK_ENABLE_OUTPUT_A is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM(intended_device_family) == 1) &&
            (clock_enable_input_b == "BYPASS"))
        begin
            $display("Error: BYPASS value for CLOCK_ENABLE_INPUT_B is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM(intended_device_family) == 1) &&
            (clock_enable_output_b == "BYPASS"))
        begin
            $display("Error: BYPASS value for CLOCK_ENABLE_OUTPUT_B is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((implement_in_les != "OFF") && (implement_in_les != "ON"))
        begin
            $display("Error: Illegal value for implement_in_les parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (((dev.FEATURE_FAMILY_HAS_M512(intended_device_family)) == 0) && (i_ram_block_type == "M512"))
        begin
            $display("Error: M512 value for RAM_BLOCK_TYPE parameter is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (((dev.FEATURE_FAMILY_HAS_MEGARAM(intended_device_family)) == 0) && 
            ((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")))
        begin
            $display("Error: MEGARAM value for RAM_BLOCK_TYPE parameter is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (((init_file == "UNUSED") || (init_file == "")) &&
            (operation_mode == "ROM"))
        begin
            $display("Error! Altsyncram needs data file for memory initialization in ROM mode.");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1) || (dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)) &&
            (((indata_aclr_a != "UNUSED") && (indata_aclr_a != "NONE")) ||
            ((wrcontrol_aclr_a != "UNUSED") && (wrcontrol_aclr_a != "NONE")) ||
            ((byteena_aclr_a  != "UNUSED") && (byteena_aclr_a != "NONE")) ||
            ((address_aclr_a != "UNUSED") && (address_aclr_a != "NONE") && (operation_mode != "ROM")) ||
            ((indata_aclr_b != "UNUSED") && (indata_aclr_b != "NONE")) ||
            ((rdcontrol_aclr_b != "UNUSED") && (rdcontrol_aclr_b != "NONE")) ||
            ((wrcontrol_aclr_b != "UNUSED") && (wrcontrol_aclr_b != "NONE")) ||
            ((byteena_aclr_b != "UNUSED") && (byteena_aclr_b != "NONE")) ||
            ((address_aclr_b != "UNUSED") && (address_aclr_b != "NONE") && (operation_mode != "DUAL_PORT"))))
        begin
            $display("Warning: %s device family does not support aclr signal on input ports. The aclr to input ports will be ignored.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) &&
            (((indata_aclr_a != "UNUSED") && (indata_aclr_a != "NONE")) ||
            ((wrcontrol_aclr_a != "UNUSED") && (wrcontrol_aclr_a != "NONE")) ||
            ((byteena_aclr_a  != "UNUSED") && (byteena_aclr_a != "NONE")) ||
            ((address_aclr_a != "UNUSED") && (address_aclr_a != "NONE") && (operation_mode != "ROM")) ||
            ((indata_aclr_b != "UNUSED") && (indata_aclr_b != "NONE")) ||
            ((rdcontrol_aclr_b != "UNUSED") && (rdcontrol_aclr_b != "NONE")) ||
            ((wrcontrol_aclr_b != "UNUSED") && (wrcontrol_aclr_b != "NONE")) ||
            ((byteena_aclr_b != "UNUSED") && (byteena_aclr_b != "NONE")) ||
            ((address_aclr_b != "UNUSED") && (address_aclr_b != "NONE") && (operation_mode != "DUAL_PORT"))))
        begin
            $display("Warning: %s device family does not support aclr signal on input ports. The aclr to input ports will be ignored.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1)
            && (read_during_write_mode_port_a != "NEW_DATA_NO_NBE_READ"))
        begin
            $display("Warning: %s value for read_during_write_mode_port_a is not supported in %s device family, it might cause incorrect behavioural simulation result", read_during_write_mode_port_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1)
            && (read_during_write_mode_port_b != "NEW_DATA_NO_NBE_READ"))
        begin
            $display("Warning: %s value for read_during_write_mode_port_b is not supported in %s device family, it might cause incorrect behavioural simulation result", read_during_write_mode_port_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
// SPR 249576: Enable don't care as RDW setting in MegaFunctions - eliminates checking for ram_block_type = "AUTO"
        if (!((is_lutram == 1) || ((i_ram_block_type == "AUTO") && (dev.FEATURE_FAMILY_HAS_LUTRAM(intended_device_family) == 1)) || 
            ((i_ram_block_type != "AUTO") && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1))) && 
            (operation_mode != "SINGLE_PORT") && (read_during_write_mode_port_a == "DONT_CARE"))
        begin
            $display("Error: %s value for read_during_write_mode_port_a is not supported in %s device family for %s ram block type in %s operation_mode", 
                read_during_write_mode_port_a, intended_device_family, i_ram_block_type, operation_mode);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if ((is_lutram != 1) && (i_ram_block_type != "AUTO") && 
            (read_during_write_mode_mixed_ports == "NEW_DATA"))
        begin
            $display("Error: %s value for read_during_write_mode_mixed_ports is not supported in %s RAM block type", read_during_write_mode_mixed_ports, i_ram_block_type);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if ((operation_mode == "DUAL_PORT") && (outdata_reg_b != "CLOCK0") && (is_lutram == 1) && (read_during_write_mode_mixed_ports == "OLD_DATA"))
        begin
            $display("Warning: Value for read_during_write_mode_mixed_ports of instance is not honoured in DUAL PORT operation mode when output registers are not clocked by clock0 for LUTRAM.");
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((indata_aclr_a != "NONE") && (indata_aclr_a != "UNUSED")))
        begin
            $display("Warning: %s value for indata_aclr_a is not supported in %s device family. The aclr to data_a registers will be ignored.", indata_aclr_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((wrcontrol_aclr_a != "NONE") && (wrcontrol_aclr_a != "UNUSED")))
        begin
            $display("Warning: %s value for wrcontrol_aclr_a is not supported in %s device family. The aclr to write control registers of port A will be ignored.", wrcontrol_aclr_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((byteena_aclr_a != "NONE") && (byteena_aclr_a != "UNUSED")))
        begin
            $display("Warning: %s value for byteena_aclr_a is not supported in %s device family. The aclr to byteena_a registers will be ignored.", byteena_aclr_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((address_aclr_a != "NONE") && (address_aclr_a != "UNUSED")) && (operation_mode != "ROM"))
        begin
            $display("Warning: %s value for address_aclr_a is not supported for write port in %s device family. The aclr to address_a registers will be ignored.", byteena_aclr_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((indata_aclr_b != "NONE") && (indata_aclr_b != "UNUSED")))
        begin
            $display("Warning: %s value for indata_aclr_b is not supported in %s device family. The aclr to data_b registers will be ignored.", indata_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((rdcontrol_aclr_b != "NONE") && (rdcontrol_aclr_b != "UNUSED")))
        begin
            $display("Warning: %s value for rdcontrol_aclr_b is not supported in %s device family. The aclr to read control registers will be ignored.", rdcontrol_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((wrcontrol_aclr_b != "NONE") && (wrcontrol_aclr_b != "UNUSED")))
        begin
            $display("Warning: %s value for wrcontrol_aclr_b is not supported in %s device family. The aclr to write control registers will be ignored.", wrcontrol_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((byteena_aclr_b != "NONE") && (byteena_aclr_b != "UNUSED")))
        begin
            $display("Warning: %s value for byteena_aclr_b is not supported in %s device family. The aclr to byteena_a register will be ignored.", byteena_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) 
            && ((address_aclr_b != "NONE") && (address_aclr_b != "UNUSED")) && (operation_mode == "BIDIR_DUAL_PORT"))
        begin
            $display("Warning: %s value for address_aclr_b is not supported for write port in %s device family. The aclr to address_b registers will be ignored.", address_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
    
        if ((is_lutram == 1) && (read_during_write_mode_mixed_ports == "OLD_DATA")
            && ((address_aclr_b != "NONE") && (address_aclr_b != "UNUSED")) && (operation_mode == "DUAL_PORT"))
        begin
            $display("Warning : aclr signal for address_b is ignored for RAM block type %s when read_during_write_mode_mixed_ports is set to OLD_DATA", ram_block_type);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1))
            && ((clock_enable_core_a != clock_enable_input_a) && (clock_enable_core_a != "USE_INPUT_CLKEN")))
        begin
            $display("Warning: clock_enable_core_a value must be USE_INPUT_CLKEN or same as clock_enable_input_a in %s device family. It will be set to clock_enable_input_a value.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1))
            && ((clock_enable_core_b != clock_enable_input_b) && (clock_enable_core_b != "USE_INPUT_CLKEN")))
        begin
            $display("Warning: clock_enable_core_b must be USE_INPUT_CLKEN or same as clock_enable_input_b in %s device family. It will be set to clock_enable_input_b value.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1)
            && (clock_enable_input_a == "ALTERNATE"))
        begin
            $display("Error: %s value for clock_enable_input_a is not supported in %s device family.", clock_enable_input_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1)
            && (clock_enable_input_b == "ALTERNATE"))
        begin
            $display("Error: %s value for clock_enable_input_b is not supported in %s device family.", clock_enable_input_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((i_ram_block_type != "M144K") && ((enable_ecc != "FALSE") && (enable_ecc != "NONE")) && (operation_mode != "DUAL_PORT"))
        begin
            $display("Warning: %s value for enable_ecc is not supported in %s ram block type for %s device family in %s operation mode", enable_ecc, i_ram_block_type, intended_device_family, operation_mode);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if ((i_ram_block_type == "M144K") && (enable_ecc == "TRUE") && (read_during_write_mode_mixed_ports == "OLD_DATA"))
        begin
            $display("Error : ECC is not supported for read-before-write mode.");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (operation_mode != "DUAL_PORT")
        begin
            if ((outdata_reg_a != "CLOCK0") && (outdata_reg_a != "CLOCK1") && (outdata_reg_a != "UNUSED")  && (outdata_reg_a != "UNREGISTERED"))
            begin
                $display("Error: %s value for outdata_reg_a is not supported.", outdata_reg_a);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
        end

        if ((operation_mode == "BIDIR_DUAL_PORT") || (operation_mode == "DUAL_PORT"))
        begin
            if ((address_reg_b != "CLOCK0") && (address_reg_b != "CLOCK1") && (address_reg_b != "UNUSED"))
            begin
                $display("Error: %s value for address_reg_b is not supported.", address_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
    
            if ((outdata_reg_b != "CLOCK0") && (outdata_reg_b != "CLOCK1") && (outdata_reg_b != "UNUSED") && (outdata_reg_b != "UNREGISTERED"))
            begin
                $display("Error: %s value for outdata_reg_b is not supported.", outdata_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end

            if ((rdcontrol_reg_b != "CLOCK0") && (rdcontrol_reg_b != "CLOCK1") && (rdcontrol_reg_b != "UNUSED") && (operation_mode == "DUAL_PORT"))
            begin
                $display("Error: %s value for rdcontrol_reg_b is not supported.", rdcontrol_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
    
            if ((indata_reg_b != "CLOCK0") && (indata_reg_b != "CLOCK1") && (indata_reg_b != "UNUSED") && (operation_mode == "BIDIR_DUAL_PORT"))
            begin
                $display("Error: %s value for indata_reg_b is not supported.", indata_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
    
            if ((wrcontrol_wraddress_reg_b != "CLOCK0") && (wrcontrol_wraddress_reg_b != "CLOCK1") && (wrcontrol_wraddress_reg_b != "UNUSED") && (operation_mode == "BIDIR_DUAL_PORT"))
            begin
                $display("Error: %s value for wrcontrol_wraddress_reg_b is not supported.", wrcontrol_wraddress_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
    
            if ((byteena_reg_b != "CLOCK0") && (byteena_reg_b != "CLOCK1") && (byteena_reg_b != "UNUSED") && (operation_mode == "BIDIR_DUAL_PORT"))
            begin
                $display("Error: %s value for byteena_reg_b is not supported.", byteena_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
        end

        // *****************************************
        // legal operations for all operation modes:
        //      |  PORT A  |  PORT B  |
        //      |  RD  WR  |  RD  WR  |
        // BDP  |  x   x   |  x   x   |
        // DP   |      x   |  x       |
        // SP   |  x   x   |          |
        // ROM  |  x       |          |
        // *****************************************


        // Initialize mem_data

        if ((init_file == "UNUSED") || (init_file == ""))
        begin
            if ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) && (power_up_uninitialized != "TRUE"))
            begin
                wa_mult_x = {width_a{1'b0}};
                for (i = 0; i < (1 << widthad_a); i = i + 1)
                    mem_data[i] = wa_mult_x;
                    
                if (enable_mem_data_b_reading)
                begin
                    for (i = 0; i < (1 << widthad_b); i = i + 1)
                        mem_data_b[i] = {width_b{1'b0}};
                end

            end
            else if (((i_ram_block_type == "M-RAM") ||
                (i_ram_block_type == "MEGARAM") ||
                ((i_ram_block_type == "AUTO") && (cread_during_write_mode_mixed_ports == "DONT_CARE")) ||
                (dev.FEATURE_FAMILY_STRATIX_HC(intended_device_family) == 1) || 
                (dev.FEATURE_FAMILY_HARDCOPYII(intended_device_family) == 1) || 
                (power_up_uninitialized == "TRUE") ) && (implement_in_les == "OFF"))
            begin
                wa_mult_x = {width_a{1'bx}};
                for (i = 0; i < (1 << widthad_a); i = i + 1)
                    mem_data[i] = wa_mult_x;

                if (enable_mem_data_b_reading)
                begin
                    for (i = 0; i < (1 << widthad_b); i = i + 1)
                    mem_data_b[i] = {width_b{1'bx}};
                end
            end
            else
            begin
                wa_mult_x = {width_a{1'b0}};
                for (i = 0; i < (1 << widthad_a); i = i + 1)
                    mem_data[i] = wa_mult_x;
                    
                if (enable_mem_data_b_reading)
                begin
                    for (i = 0; i < (1 << widthad_b); i = i + 1)
                    mem_data_b[i] = {width_b{1'b0}};
                end
            end
        end

        else  // Memory initialization file is used
        begin

            wa_mult_x = {width_a{1'b0}};
            for (i = 0; i < (1 << widthad_a); i = i + 1)
                mem_data[i] = wa_mult_x;
                
            for (i = 0; i < (1 << widthad_b); i = i + 1)
                mem_data_b[i] = {width_b{1'b0}};

            init_file_b_port = 0;

            if ((init_file_layout != "PORT_A") &&
                (init_file_layout != "PORT_B"))
            begin
                if (operation_mode == "DUAL_PORT")
                    init_file_b_port = 1;
                else
                    init_file_b_port = 0;
            end
            else
            begin
                if (init_file_layout == "PORT_A")
                    init_file_b_port = 0;
                else if (init_file_layout == "PORT_B")
                    init_file_b_port = 1;
            end

            if (init_file_b_port)
            begin
                `ifdef NO_PLI
                    $readmemh(init_file, mem_data_b);
                `else
                    `ifdef USE_RIF
                        $readmemh(init_file, mem_data_b);
                    `else
                        mem.convert_to_ver_file(init_file, width_b, ram_initf);
                        $readmemh(ram_initf, mem_data_b);
                    `endif 
                `endif

                for (i = 0; i < (i_numwords_b * width_b); i = i + 1)
                begin
                    temp_wb = mem_data_b[i / width_b];
                    i_div_wa = i / width_a;
                    temp_wa = mem_data[i_div_wa];
                    temp_wa[i % width_a] = temp_wb[i % width_b];
                    mem_data[i_div_wa] = temp_wa;
                end
            end
            else
            begin
                `ifdef NO_PLI
                    $readmemh(init_file, mem_data);
                `else
                    `ifdef USE_RIF
                        $readmemh(init_file, mem_data);
                    `else
                        mem.convert_to_ver_file(init_file, width_a, ram_initf);
                        $readmemh(ram_initf, mem_data);
                    `endif
                `endif
                
                if (enable_mem_data_b_reading)
                begin                
                    for (i = 0; i < (i_numwords_a * width_a); i = i + 1)
                    begin
                        temp_wa = mem_data[i / width_a];
                        i_div_wb = i / width_b;
                        temp_wb = mem_data_b[i_div_wb];
                        temp_wb[i % width_b] = temp_wa[i % width_a];
                        mem_data_b[i_div_wb] = temp_wb;
                    end
                end
            end
        end
        i_nmram_write_a = 0;
        i_nmram_write_b = 0;

        i_aclr_flag_a = 0;
        i_aclr_flag_b = 0;

        i_outdata_aclr_a_prev = 0;
        i_outdata_aclr_b_prev = 0;
        i_address_aclr_a_prev = 0;
        i_address_aclr_b_prev = 0;
        
        i_force_reread_a = 0;
        i_force_reread_a1 = 0;
        i_force_reread_b = 0;
        i_force_reread_b1 = 0;
        i_force_reread_a_signal = 0;
        i_force_reread_b_signal = 0;
        
        // Initialize internal registers/signals
        i_data_reg_a = 0;
        i_data_reg_b = 0;
        i_address_reg_a = 0;
        i_address_reg_b = 0;
        i_original_address_a = 0;
        i_wren_reg_a = 0;
        i_wren_reg_b = 0;
        i_read_flag_a = 0;
        i_read_flag_b = 0;
        i_write_flag_a = 0;
        i_write_flag_b = 0;
        i_byteena_mask_reg_a = {width_a{1'b1}};
        i_byteena_mask_reg_b = {width_b{1'b1}};
        i_byteena_mask_reg_a_x = 0;
        i_byteena_mask_reg_b_x = 0;
        i_byteena_mask_reg_a_out = {width_a{1'b1}};
        i_byteena_mask_reg_b_out = {width_b{1'b1}};
        i_original_data_b = 0;
        i_original_data_a = 0;
        i_data_write_time_a = 0;
        i_core_clocken_a_reg = 0;
        i_core_clocken0_b_reg = 0;
        i_core_clocken1_b_reg = 0;

        if (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1)
        begin
            i_rden_reg_a = 0;
            i_rden_reg_b = 0;
        end
        else
        begin
            i_rden_reg_a = 1;
            i_rden_reg_b = 1;
        end
        


        if (((i_ram_block_type == "M-RAM") ||
                (i_ram_block_type == "MEGARAM") ||
                ((i_ram_block_type == "AUTO") && (cread_during_write_mode_mixed_ports == "DONT_CARE"))) && 
                dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1)
        begin
            i_q_tmp_a = {width_a{1'bx}};
            i_q_tmp_b = {width_b{1'bx}};
            i_q_tmp2_a = {width_a{1'bx}};
            i_q_tmp2_b = {width_b{1'bx}};
            i_q_reg_a = {width_a{1'bx}};
            i_q_reg_b = {width_b{1'bx}};
        end
        else
        begin
            if (is_lutram == 1) 
            begin
                i_q_tmp_a = mem_data[0];
                i_q_tmp2_a = mem_data[0];

                for (init_i = 0; init_i < width_b; init_i = init_i + 1)
                begin
                    init_temp = mem_data[init_i / width_a];
                    i_q_tmp_b[init_i] = init_temp[init_i % width_a];
                    i_q_tmp2_b[init_i] = init_temp[init_i % width_a];
                end

                i_q_reg_a = 0;
                i_q_reg_b = 0;
                i_q_output_latch = 0;
            end
            else
            begin
                i_q_tmp_a = 0;
                i_q_tmp_b = 0;
                i_q_tmp2_a = 0;
                i_q_tmp2_b = 0;
                i_q_reg_a = 0;
                i_q_reg_b = 0;
            end
        end

        good_to_go_a = 0;
        good_to_go_b = 0;

        same_clock_pulse0 = 1'b0;
        same_clock_pulse1 = 1'b0;

        i_byteena_count = 0;
        
        if (((dev.FEATURE_FAMILY_STRATIX_HC(intended_device_family) == 1) || (dev.FEATURE_FAMILY_HARDCOPYII(intended_device_family) == 1)) &&
            (ram_block_type == "M4K") && (operation_mode != "SINGLE_PORT"))
        begin
            i_good_to_write_a2 = 0;
            i_good_to_write_b2 = 0;
        end
        else
        begin
            i_good_to_write_a2 = 1;
            i_good_to_write_b2 = 1;
        end

    end


// SIGNAL ASSIGNMENT

    // Clock signal assignment

    // port a clock assignments:
    assign i_outdata_clk_a            = (outdata_reg_a == "CLOCK1") ?
                                        clock1 : ((outdata_reg_a == "CLOCK0") ?
                                        clock0 : 1'b0);
    // port b clock assignments:
    assign i_outdata_clk_b            = (outdata_reg_b == "CLOCK1") ?
                                        clock1 : ((outdata_reg_b == "CLOCK0") ?
                                        clock0 : 1'b0);

    // Clock enable signal assignment

    // port a clock enable assignments:
    assign i_outdata_clken_a              = (clock_enable_output_a == "BYPASS") ?
                                            1'b1 : ((clock_enable_output_a == "ALTERNATE") && (outdata_reg_a == "CLOCK1")) ?
                                            clocken3 : ((clock_enable_output_a == "ALTERNATE") && (outdata_reg_a == "CLOCK0")) ?
                                            clocken2 : (outdata_reg_a == "CLOCK1") ?
                                            clocken1 : (outdata_reg_a == "CLOCK0") ?
                                            clocken0 : 1'b1;
    // port b clock enable assignments:
    assign i_outdata_clken_b              = (clock_enable_output_b == "BYPASS") ?
                                            1'b1 : ((clock_enable_output_b == "ALTERNATE") && (outdata_reg_b == "CLOCK1")) ?
                                            clocken3 : ((clock_enable_output_b == "ALTERNATE") && (outdata_reg_b == "CLOCK0")) ?
                                            clocken2 : (outdata_reg_b == "CLOCK1") ?
                                            clocken1 : (outdata_reg_b == "CLOCK0") ?
                                            clocken0 : 1'b1;


    assign i_clocken0                     = (clock_enable_input_a == "BYPASS") ?
                                            1'b1 : (clock_enable_input_a == "NORMAL") ?
                                            clocken0 : clocken2;

    assign i_clocken0_b                   = (clock_enable_input_b == "BYPASS") ?
                                            1'b1 : (clock_enable_input_b == "NORMAL") ?
                                            clocken0 : clocken2;

    assign i_clocken1_b                   = (clock_enable_input_b == "BYPASS") ?
                                            1'b1 : (clock_enable_input_b == "NORMAL") ?
                                            clocken1 : clocken3;

    assign i_core_clocken_a              = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1)) ?
                                            i_clocken0 : ((clock_enable_core_a == "BYPASS") ?
                                            1'b1 : ((clock_enable_core_a == "USE_INPUT_CLKEN") ?
                                            i_clocken0 : ((clock_enable_core_a == "NORMAL") ?
                                            clocken0 : clocken2)));
    
    assign i_core_clocken0_b              = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1)) ?
                                            i_clocken0_b : ((clock_enable_core_b == "BYPASS") ?
                                            1'b1 : ((clock_enable_core_b == "USE_INPUT_CLKEN") ?
                                            i_clocken0_b : ((clock_enable_core_b == "NORMAL") ?
                                            clocken0 : clocken2)));

    assign i_core_clocken1_b              = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) != 1)) ?
                                            i_clocken1_b : ((clock_enable_core_b == "BYPASS") ?
                                            1'b1 : ((clock_enable_core_b == "USE_INPUT_CLKEN") ?
                                            i_clocken1_b : ((clock_enable_core_b == "NORMAL") ?
                                            clocken1 : clocken3)));

    assign i_core_clocken_b               = (address_reg_b == "CLOCK0") ?
                                            i_core_clocken0_b : i_core_clocken1_b;

    // Async clear signal assignment

    // port a clear assigments:

    assign i_indata_aclr_a    = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) ||
                                (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)) ? 
                                1'b0 : ((indata_aclr_a == "CLEAR0") ? aclr0 : 1'b0);
    assign i_address_aclr_a   = (address_aclr_a == "CLEAR0") ? aclr0 : 1'b0;
    assign i_wrcontrol_aclr_a = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) || 
                                (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1))?
                                1'b0 : ((wrcontrol_aclr_a == "CLEAR0") ? aclr0 : 1'b0);
    assign i_byteena_aclr_a   = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) ||
                                (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)) ?
                                1'b0 : ((byteena_aclr_a == "CLEAR0") ?
                                aclr0 : ((byteena_aclr_a == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_outdata_aclr_a   = (outdata_aclr_a == "CLEAR0") ?
                                aclr0 : ((outdata_aclr_a == "CLEAR1") ?
                                aclr1 : 1'b0);
    // port b clear assignments:
    assign i_indata_aclr_b    = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) ||
                                (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1))?
                                1'b0 : ((indata_aclr_b == "CLEAR0") ?
                                aclr0 : ((indata_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_address_aclr_b   = (address_aclr_b == "CLEAR0") ?
                                aclr0 : ((address_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0);
    assign i_wrcontrol_aclr_b = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) ||
                                (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1))?
                                1'b0 : ((wrcontrol_aclr_b == "CLEAR0") ?
                                aclr0 : ((wrcontrol_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_rdcontrol_aclr_b = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) ||
                                (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)) ?
                                1'b0 : ((rdcontrol_aclr_b == "CLEAR0") ?
                                aclr0 : ((rdcontrol_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_byteena_aclr_b   = ((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) ||
                                (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)) ?
                                1'b0 : ((byteena_aclr_b == "CLEAR0") ?
                                aclr0 : ((byteena_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_outdata_aclr_b   = (outdata_aclr_b == "CLEAR0") ?
                                aclr0 : ((outdata_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0);

    assign i_byteena_a = byteena_a;
    assign i_byteena_b = byteena_b;
    
    
    // Ready to write setting
    
    assign i_good_to_write_a = (((is_bidir_and_wrcontrol_addb_clk0 == 1) || (dual_port_addreg_b_clk0 == 1)) && (i_core_clocken0_b) && (~clock0)) ?
                                    1'b1 : (((is_bidir_and_wrcontrol_addb_clk1 == 1) || (dual_port_addreg_b_clk1 == 1)) && (i_core_clocken1_b) && (~clock1)) ?
                                    1'b1 : i_good_to_write_a2;
                                    
    assign i_good_to_write_b = ((i_core_clocken0_b) && (~clock0)) ? 1'b1 : i_good_to_write_b2;
    
    assign s3_address_aclr_a =  ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family)) && (is_lutram != 1) && (outdata_reg_a != "CLOCK0") && (outdata_reg_a != "CLOCK1")) ?
                                    1'b1 : 1'b0;

    assign s3_address_aclr_b =  ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family)) && (is_lutram != 1) && (outdata_reg_b != "CLOCK0") && (outdata_reg_b != "CLOCK1")) ?
                                    1'b1 : 1'b0;

    assign i_address_aclr_family_a =    (((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) && (operation_mode != "ROM")) ||
                                        (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)) ?
                                        1'b1 : 1'b0;
    
    assign i_address_aclr_family_b =    (((dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) && (operation_mode != "DUAL_PORT")) ||
                                        ((is_lutram == 1) && (operation_mode == "DUAL_PORT") && (read_during_write_mode_mixed_ports == "OLD_DATA")) ||
                                        (dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 1 || dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family) == 1)) ?
                                        1'b1 : 1'b0;

    always @(i_good_to_write_a)
    begin
        i_good_to_write_a2 = i_good_to_write_a;
    end
    
    always @(i_good_to_write_b)
    begin
        i_good_to_write_b2 = i_good_to_write_b;
    end
    
     
    // Port A inputs registered : indata, address, byeteena, wren
    // Aclr status flags get updated here for M-RAM ram_block_type

    always @(posedge clock0)
    begin
    
        if (i_force_reread_a)
        begin
            i_force_reread_a_signal <= ~ i_force_reread_a_signal;
            i_force_reread_a <= 0;
        end
        
        if (i_force_reread_b && ((is_bidir_and_wrcontrol_addb_clk0 == 1) || (dual_port_addreg_b_clk0 == 1)))
        begin
            i_force_reread_b_signal <= ~ i_force_reread_b_signal;
            i_force_reread_b <= 0;
        end

        if (clock1)
            same_clock_pulse0 <= 1'b1;
        else
            same_clock_pulse0 <= 1'b0;

        if (i_address_aclr_a && (~i_address_aclr_family_a))
            i_address_reg_a <= 0;

        i_core_clocken_a_reg <= i_core_clocken_a;
        i_core_clocken0_b_reg <= i_core_clocken0_b;

        if (i_core_clocken_a)
        begin

            if (i_force_reread_a1)
            begin
                i_force_reread_a_signal <= ~ i_force_reread_a_signal;
                i_force_reread_a1 <= 0;
            end
            i_read_flag_a <= ~ i_read_flag_a;
            if (i_force_reread_b1 && ((is_bidir_and_wrcontrol_addb_clk0 == 1) || (dual_port_addreg_b_clk0 == 1)))
            begin
                i_force_reread_b_signal <= ~ i_force_reread_b_signal;
                i_force_reread_b1 <= 0;
            end
            if (is_write_positive_edge_reg)
            begin
                if (i_wren_reg_a || wren_a)
                begin
                    i_write_flag_a <= ~ i_write_flag_a;
                end
                if (operation_mode != "ROM")
                    i_nmram_write_a <= 1'b0;
            end
            else
            begin
                if (operation_mode != "ROM")
                    i_nmram_write_a <= 1'b1;
            end

            if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1) && (is_lutram != 1))
            begin
                good_to_go_a <= 1;
                
                i_rden_reg_a <= rden_a;

                if (i_wrcontrol_aclr_a)
                    i_wren_reg_a <= 0;
                else
                begin
                    i_wren_reg_a <= wren_a;
                end
            end
        end
        else
            i_nmram_write_a <= 1'b0;

        if (i_core_clocken_b)    
            i_address_aclr_b_flag <= 0;

        if (is_lutram)
        begin
            if (i_wrcontrol_aclr_a)
                i_wren_reg_a <= 0;
            else if (i_core_clocken_a)
            begin
                i_wren_reg_a <= wren_a;
            end
        end

        if ((clock_enable_input_a == "BYPASS") ||
            ((clock_enable_input_a == "NORMAL") && clocken0) ||
            ((clock_enable_input_a == "ALTERNATE") && clocken2))
        begin

            // Port A inputs
            
            if (i_indata_aclr_a)
                i_data_reg_a <= 0;
            else
                i_data_reg_a <= data_a;

            if (i_address_aclr_a && (~i_address_aclr_family_a))
                i_address_reg_a <= 0;
            else if (!addressstall_a)
                i_address_reg_a <= address_a;

            if (i_byteena_aclr_a)
            begin
                i_byteena_mask_reg_a <= {width_a{1'b1}};
                i_byteena_mask_reg_a_out <= 0;
                i_byteena_mask_reg_a_x <= 0;
                i_byteena_mask_reg_a_out_b <= {width_a{1'bx}};
            end
            else
            begin
               
                if (width_byteena_a == 1)
                begin
                    i_byteena_mask_reg_a <= {width_a{i_byteena_a[0]}};
                    i_byteena_mask_reg_a_out <= (i_byteena_a[0])? {width_a{1'b0}} : {width_a{1'bx}};
                    i_byteena_mask_reg_a_out_b <= (i_byteena_a[0])? {width_a{1'bx}} : {width_a{1'b0}};
                    i_byteena_mask_reg_a_x <= ((i_byteena_a[0]) || (i_byteena_a[0] == 1'b0))? {width_a{1'b0}} : {width_a{1'bx}};
                end
                else
                    for (k = 0; k < width_a; k = k+1)
                    begin
                        i_byteena_mask_reg_a[k] <= i_byteena_a[k/i_byte_size];
                        i_byteena_mask_reg_a_out_b[k] <= (i_byteena_a[k/i_byte_size])? 1'bx: 1'b0;
                        i_byteena_mask_reg_a_out[k] <= (i_byteena_a[k/i_byte_size])? 1'b0: 1'bx;
                        i_byteena_mask_reg_a_x[k] <= ((i_byteena_a[k/i_byte_size]) || (i_byteena_a[k/i_byte_size] == 1'b0))? 1'b0: 1'bx;
                    end
               
            end

            if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) || 
                (is_lutram == 1))
            begin
                good_to_go_a <= 1;
            
                i_rden_reg_a <= rden_a;
                
                if (i_wrcontrol_aclr_a)
                    i_wren_reg_a <= 0;
                else
                begin
                    i_wren_reg_a <= wren_a;
                end
            end

        end
        
        
        if (i_indata_aclr_a)
            i_data_reg_a <= 0;

        if (i_address_aclr_a && (~i_address_aclr_family_a))
            i_address_reg_a <= 0;

        if (i_byteena_aclr_a)
        begin
            i_byteena_mask_reg_a <= {width_a{1'b1}};
            i_byteena_mask_reg_a_out <= 0;
            i_byteena_mask_reg_a_x <= 0;
            i_byteena_mask_reg_a_out_b <= {width_a{1'bx}};
        end
        
        
        // Port B

        if (is_bidir_and_wrcontrol_addb_clk0)
        begin

            if (i_core_clocken0_b)
            begin
                if (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1)
                begin
                    good_to_go_b <= 1;
                    
                    i_rden_reg_b <= rden_b;
    
                    if (i_wrcontrol_aclr_b)
                        i_wren_reg_b <= 0;
                    else
                    begin
                        i_wren_reg_b <= wren_b;
                    end
                end
                
                i_read_flag_b <= ~i_read_flag_b;
                    
                if (is_write_positive_edge_reg)
                begin
                    if (i_wren_reg_b || wren_b)
                    begin
                        i_write_flag_b <= ~ i_write_flag_b;
                    end
                    i_nmram_write_b <= 1'b0;
                end
                else
                    i_nmram_write_b <= 1'b1;
            
            end
            else
                i_nmram_write_b <= 1'b0;
                
                
            if ((clock_enable_input_b == "BYPASS") ||
                ((clock_enable_input_b == "NORMAL") && clocken0) ||
                ((clock_enable_input_b == "ALTERNATE") && clocken2))
            begin

                // Port B inputs

                if (i_indata_aclr_b)
                    i_data_reg_b <= 0;
                else
                    i_data_reg_b <= data_b;
        

                if (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0)
                begin
                    good_to_go_b <= 1;
                
                    i_rden_reg_b <= rden_b;
    
                    if (i_wrcontrol_aclr_b)
                        i_wren_reg_b <= 0;
                    else
                    begin
                        i_wren_reg_b <= wren_b;
                    end
                end

                if (i_address_aclr_b && (~i_address_aclr_family_b))
                    i_address_reg_b <= 0;
                else if (!addressstall_b)
                    i_address_reg_b <= address_b;

                if (i_byteena_aclr_b)
                begin
                    i_byteena_mask_reg_b <= {width_b{1'b1}};
                    i_byteena_mask_reg_b_out <= 0;
                    i_byteena_mask_reg_b_x <= 0;
                    i_byteena_mask_reg_b_out_a <= {width_b{1'bx}};
                end
                else
                begin
                   
                    if (width_byteena_b == 1)
                    begin
                        i_byteena_mask_reg_b <= {width_b{i_byteena_b[0]}};
                        i_byteena_mask_reg_b_out_a <= (i_byteena_b[0])? {width_b{1'bx}} : {width_b{1'b0}};
                        i_byteena_mask_reg_b_out <= (i_byteena_b[0])? {width_b{1'b0}} : {width_b{1'bx}};
                        i_byteena_mask_reg_b_x <= ((i_byteena_b[0]) || (i_byteena_b[0] == 1'b0))? {width_b{1'b0}} : {width_b{1'bx}};
                    end
                    else
                        for (k2 = 0; k2 < width_b; k2 = k2 + 1)
                        begin
                            i_byteena_mask_reg_b[k2] <= i_byteena_b[k2/i_byte_size];
                            i_byteena_mask_reg_b_out_a[k2] <= (i_byteena_b[k2/i_byte_size])? 1'bx : 1'b0;
                            i_byteena_mask_reg_b_out[k2] <= (i_byteena_b[k2/i_byte_size])? 1'b0 : 1'bx;
                            i_byteena_mask_reg_b_x[k2] <= ((i_byteena_b[k2/i_byte_size]) || (i_byteena_b[k2/i_byte_size] == 1'b0))? 1'b0 : 1'bx;
                        end
                    
                end

            end
            
            
            if (i_indata_aclr_b)
                i_data_reg_b <= 0;

            if (i_wrcontrol_aclr_b)
                i_wren_reg_b <= 0;

            if (i_address_aclr_b && (~i_address_aclr_family_b))
                i_address_reg_b <= 0;

            if (i_byteena_aclr_b)
            begin
                i_byteena_mask_reg_b <= {width_b{1'b1}};
                i_byteena_mask_reg_b_out <= 0;
                i_byteena_mask_reg_b_x <= 0;
                i_byteena_mask_reg_b_out_a <= {width_b{1'bx}};
            end
        end
            
        if (dual_port_addreg_b_clk0)
        begin
            if (i_address_aclr_b && (~i_address_aclr_family_b))
                i_address_reg_b <= 0;

            if (i_core_clocken0_b)
            begin
                if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1) && !is_lutram)
                begin
                    good_to_go_b <= 1;
                    
                    if (i_rdcontrol_aclr_b)
                        i_rden_reg_b <= 1'b1;
                    else
                        i_rden_reg_b <= rden_b;
                end
                
                i_read_flag_b <= ~ i_read_flag_b;
            end
            
            if ((clock_enable_input_b == "BYPASS") ||
                ((clock_enable_input_b == "NORMAL") && clocken0) ||
                ((clock_enable_input_b == "ALTERNATE") && clocken2))
            begin
                if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) || is_lutram)
                begin
                    good_to_go_b <= 1;
                
                    if (i_rdcontrol_aclr_b)
                        i_rden_reg_b <= 1'b1;
                    else
                        i_rden_reg_b <= rden_b;
                end

                if (i_address_aclr_b && (~i_address_aclr_family_b))
                    i_address_reg_b <= 0;
                else if (!addressstall_b)
                    i_address_reg_b <= address_b;

            end
            
            
            if (i_rdcontrol_aclr_b)
                i_rden_reg_b <= 1'b1;

            if (i_address_aclr_b && (~i_address_aclr_family_b))
                i_address_reg_b <= 0;

        end

    end


    always @(negedge clock0)
    begin
       
        if (clock1)
            same_clock_pulse0 <= 1'b0;

        if (!is_write_positive_edge_reg)
        begin
            if (i_nmram_write_a == 1'b1)
            begin
                i_write_flag_a <= ~ i_write_flag_a;
                
                if (is_lutram)
                    i_read_flag_a <= ~i_read_flag_a;
            end 

            
            if (is_bidir_and_wrcontrol_addb_clk0)
            begin
                if (i_nmram_write_b == 1'b1)
                    i_write_flag_b <= ~ i_write_flag_b;
            end
        end

        if (i_core_clocken0_b && i_lutram_dual_port_fast_read && (dual_port_addreg_b_clk0 == 1))
        begin
            i_read_flag_b <= ~i_read_flag_b;
        end

    end



    always @(posedge clock1)
    begin
        i_core_clocken1_b_reg <= i_core_clocken1_b;

        if (i_force_reread_b && ((is_bidir_and_wrcontrol_addb_clk1 == 1) || (dual_port_addreg_b_clk1 == 1)))
        begin
            i_force_reread_b_signal <= ~ i_force_reread_b_signal;
            i_force_reread_b <= 0;
        end
        
        if (clock0)
            same_clock_pulse1 <= 1'b1;
        else
            same_clock_pulse1 <= 1'b0;

        if (i_core_clocken_b)    
            i_address_aclr_b_flag <= 0;

        if (is_bidir_and_wrcontrol_addb_clk1)
        begin

            if (i_core_clocken1_b)
            begin
                i_read_flag_b <= ~i_read_flag_b;
    
                if (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1)
                begin
                    good_to_go_b <= 1;
                    
                    i_rden_reg_b <= rden_b;
    
                    if (i_wrcontrol_aclr_b)
                        i_wren_reg_b <= 0;
                    else
                    begin
                        i_wren_reg_b <= wren_b;
                    end
                end
                
                if (is_write_positive_edge_reg)
                begin
                    if (i_wren_reg_b || wren_b)
                    begin
                        i_write_flag_b <= ~ i_write_flag_b;
                    end
                    i_nmram_write_b <= 1'b0;
                end
                else
                    i_nmram_write_b <= 1'b1;
            end
            else
                i_nmram_write_b <= 1'b0;
                
        
            if ((clock_enable_input_b == "BYPASS") ||
                ((clock_enable_input_b == "NORMAL") && clocken1) ||
                ((clock_enable_input_b == "ALTERNATE") && clocken3))
            begin
                
                // Port B inputs
                
                if (address_reg_b == "CLOCK1")
                begin
                    if (i_indata_aclr_b)
                        i_data_reg_b <= 0;
                    else
                        i_data_reg_b <= data_b;
                end

                if (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0)
                begin
                    good_to_go_b <= 1;
    
                    i_rden_reg_b <= rden_b;
    
                    if (i_wrcontrol_aclr_b)
                        i_wren_reg_b <= 0;
                    else
                    begin
                        i_wren_reg_b <= wren_b;
                    end
                end

                if (i_address_aclr_b && (~i_address_aclr_family_b))
                    i_address_reg_b <= 0;
                else if (!addressstall_b)
                    i_address_reg_b <= address_b;

                if (i_byteena_aclr_b)
                begin
                    i_byteena_mask_reg_b <= {width_b{1'b1}};
                    i_byteena_mask_reg_b_out <= 0;
                    i_byteena_mask_reg_b_x <= 0;
                    i_byteena_mask_reg_b_out_a <= {width_b{1'bx}};
                end
                else
                begin
                    if (width_byteena_b == 1)
                    begin
                        i_byteena_mask_reg_b <= {width_b{i_byteena_b[0]}};
                        i_byteena_mask_reg_b_out_a <= (i_byteena_b[0])? {width_b{1'bx}} : {width_b{1'b0}};
                        i_byteena_mask_reg_b_out <= (i_byteena_b[0])? {width_b{1'b0}} : {width_b{1'bx}};
                        i_byteena_mask_reg_b_x <= ((i_byteena_b[0]) || (i_byteena_b[0] == 1'b0))? {width_b{1'b0}} : {width_b{1'bx}};
                    end
                    else
                        for (k2 = 0; k2 < width_b; k2 = k2 + 1)
                        begin
                            i_byteena_mask_reg_b[k2] <= i_byteena_b[k2/i_byte_size];
                            i_byteena_mask_reg_b_out_a[k2] <= (i_byteena_b[k2/i_byte_size])? 1'bx : 1'b0;
                            i_byteena_mask_reg_b_out[k2] <= (i_byteena_b[k2/i_byte_size])? 1'b0 : 1'bx;
                            i_byteena_mask_reg_b_x[k2] <= ((i_byteena_b[k2/i_byte_size]) || (i_byteena_b[k2/i_byte_size] == 1'b0))? 1'b0 : 1'bx;
                        end
                
                end

            end
            
            
            if (i_indata_aclr_b)
                i_data_reg_b <= 0;

            if (i_wrcontrol_aclr_b)
                i_wren_reg_b <= 0;

            if (i_address_aclr_b && (~i_address_aclr_family_b))
                i_address_reg_b <= 0;

            if (i_byteena_aclr_b)
            begin
                i_byteena_mask_reg_b <= {width_b{1'b1}};
                i_byteena_mask_reg_b_out <= 0;
                i_byteena_mask_reg_b_x <= 0;
                i_byteena_mask_reg_b_out_a <= {width_b{1'bx}};
            end
        end

        if (dual_port_addreg_b_clk1)
        begin
            if (i_address_aclr_b && (~i_address_aclr_family_b))
                i_address_reg_b <= 0;

            if (i_core_clocken1_b)
            begin
                if (i_force_reread_b1)
                begin
                    i_force_reread_b_signal <= ~ i_force_reread_b_signal;
                    i_force_reread_b1 <= 0;
                end
                if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1) && !is_lutram)
                begin
                    good_to_go_b <= 1;
                    
                    if (i_rdcontrol_aclr_b)
                    begin
                        i_rden_reg_b <= 1'b1;
                    end
                    else
                    begin
                        i_rden_reg_b <= rden_b;
                    end
                end

                i_read_flag_b <= ~i_read_flag_b;
            end
            
            if ((clock_enable_input_b == "BYPASS") ||
                ((clock_enable_input_b == "NORMAL") && clocken1) ||
                ((clock_enable_input_b == "ALTERNATE") && clocken3))
            begin
                if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) || is_lutram)
                begin
                    good_to_go_b <= 1;
                
                    if (i_rdcontrol_aclr_b)
                    begin
                        i_rden_reg_b <= 1'b1;
                    end
                    else
                    begin
                        i_rden_reg_b <= rden_b;
                    end
                end
    
                if (i_address_aclr_b && (~i_address_aclr_family_b))
                    i_address_reg_b <= 0;
                else if (!addressstall_b)
                    i_address_reg_b <= address_b;

            end
            
            
            if (i_rdcontrol_aclr_b)
                i_rden_reg_b <= 1'b1;

            if (i_address_aclr_b && (~i_address_aclr_family_b))
                i_address_reg_b <= 0;
                
        end

    end

    always @(negedge clock1)
    begin
       
        if (clock0)
            same_clock_pulse1 <= 1'b0;
            
        if (!is_write_positive_edge_reg)
        begin
           
            if (is_bidir_and_wrcontrol_addb_clk1)
            begin
                if (i_nmram_write_b == 1'b1)
                    i_write_flag_b <= ~ i_write_flag_b;
            end
        end

        if (i_core_clocken1_b && i_lutram_dual_port_fast_read && (dual_port_addreg_b_clk1 ==1))
        begin
            i_read_flag_b <= ~i_read_flag_b;
        end

    end
    
    always @(posedge i_address_aclr_b)
    begin
        if ((is_lutram == 1) && (operation_mode == "DUAL_PORT") && (~i_address_aclr_family_b))
            i_read_flag_b <= ~i_read_flag_b;
    end

    always @(posedge i_address_aclr_a)
    begin
        if ((is_lutram == 1) && (operation_mode == "ROM") && (~i_address_aclr_family_a))
            i_read_flag_a <= ~i_read_flag_a;
    end
    
    always @(posedge i_outdata_aclr_a)
    begin
        if ((dev.FEATURE_FAMILY_CYCLONEIII(intended_device_family) == 1) && 
            ((outdata_reg_a != "CLOCK0") && (outdata_reg_a != "CLOCK1")))
            i_read_flag_a <= ~i_read_flag_a;
    end

    always @(posedge i_outdata_aclr_b)
    begin
        if ((dev.FEATURE_FAMILY_CYCLONEIII(intended_device_family) == 1) && 
            ((outdata_reg_b != "CLOCK0") && (outdata_reg_b != "CLOCK1")))
            i_read_flag_b <= ~i_read_flag_b;
    end
    
    // Port A writting -------------------------------------------------------------

    always @(posedge i_write_flag_a or negedge i_write_flag_a)
    begin
        if ((operation_mode == "BIDIR_DUAL_PORT") ||
            (operation_mode == "DUAL_PORT") ||
            (operation_mode == "SINGLE_PORT"))
        begin

            if ((i_wren_reg_a) && (i_good_to_write_a))
            begin
                i_aclr_flag_a = 0;

                if (i_indata_aclr_a)
                begin
                    if (i_data_reg_a != 0)
                    begin
                        mem_data[i_address_reg_a] = {width_a{1'bx}};

                        if (enable_mem_data_b_reading)
                        begin
                            j3 = i_address_reg_a * width_a;
                            for (i5 = 0; i5 < width_a; i5 = i5+1)
                            begin
                                    j3_plus_i5 = j3 + i5;
                                    temp_wb = mem_data_b[j3_plus_i5 / width_b];
                                    temp_wb[j3_plus_i5 % width_b] = {1'bx};
                                    mem_data_b[j3_plus_i5 / width_b] = temp_wb;
                            end
                        end
                        i_aclr_flag_a = 1;
                    end
                end
                else if (i_byteena_aclr_a)
                begin
                    if (i_byteena_mask_reg_a != {width_a{1'b1}})
                    begin
                        mem_data[i_address_reg_a] = {width_a{1'bx}};
                        
                        if (enable_mem_data_b_reading)
                        begin
                            j3 = i_address_reg_a * width_a;
                            for (i5 = 0; i5 < width_a; i5 = i5+1)
                            begin
                                    j3_plus_i5 = j3 + i5;
                                    temp_wb = mem_data_b[j3_plus_i5 / width_b];
                                    temp_wb[j3_plus_i5 % width_b] = {1'bx};
                                    mem_data_b[j3_plus_i5 / width_b] = temp_wb;
                            end
                        end
                        i_aclr_flag_a = 1;
                    end
                end
                else if (i_address_aclr_a && (~i_address_aclr_family_a))
                begin
                    if (i_address_reg_a != 0)
                    begin
                        wa_mult_x_ii = {width_a{1'bx}};
                        for (i4 = 0; i4 < i_numwords_a; i4 = i4 + 1)
                            mem_data[i4] = wa_mult_x_ii;
                            
                        if (enable_mem_data_b_reading)
                        begin
                            for (i4 = 0; i4 < i_numwords_b; i4 = i4 + 1)
                                mem_data_b[i4] = {width_b{1'bx}};
                        end

                        i_aclr_flag_a = 1;
                    end
                end

                if (i_aclr_flag_a == 0)
                begin
                    i_original_data_a = mem_data[i_address_reg_a];
                    i_original_address_a = i_address_reg_a;
                    i_data_write_time_a = $time;
                    temp_wa = mem_data[i_address_reg_a];
                    
                    port_a_bit_count_low = i_address_reg_a * width_a;
                    port_b_bit_count_low = i_address_reg_b * width_b;
                    port_b_bit_count_high = port_b_bit_count_low + width_b;
                    
                    for (i5 = 0; i5 < width_a; i5 = i5 + 1)
                    begin
                        i_byteena_count = port_a_bit_count_low % width_b;

                        if ((port_a_bit_count_low >= port_b_bit_count_low) && (port_a_bit_count_low < port_b_bit_count_high) &&
                            ((i_core_clocken0_b_reg && (is_bidir_and_wrcontrol_addb_clk0 == 1)) || (i_core_clocken1_b_reg && (is_bidir_and_wrcontrol_addb_clk1 == 1))) && 
                            (i_wren_reg_b) && ((same_clock_pulse0 && same_clock_pulse1) || (address_reg_b == "CLOCK0")) &&
                            (i_byteena_mask_reg_b[i_byteena_count]) && (i_byteena_mask_reg_a[i5]))
                            temp_wa[i5] = {1'bx};
                        else if (i_byteena_mask_reg_a[i5])
                            temp_wa[i5] = i_data_reg_a[i5];

                        if (enable_mem_data_b_reading)
                        begin
                            temp_wb = mem_data_b[port_a_bit_count_low / width_b];
                            temp_wb[port_a_bit_count_low % width_b] = temp_wa[i5];
                            mem_data_b[port_a_bit_count_low / width_b] = temp_wb;
                        end

                        port_a_bit_count_low = port_a_bit_count_low + 1;
                    end

                    mem_data[i_address_reg_a] = temp_wa;

                    if (((cread_during_write_mode_mixed_ports == "OLD_DATA") && (is_write_positive_edge_reg) && (address_reg_b == "CLOCK0")) ||
                        ((i_lutram_dual_port_fast_read == 1) && (operation_mode == "DUAL_PORT")))
                        i_read_flag_b = ~i_read_flag_b;
                        
                    if ((read_during_write_mode_port_a == "OLD_DATA") ||
                        ((is_lutram == 1) && (read_during_write_mode_port_a == "DONT_CARE")))
                        i_read_flag_a = ~i_read_flag_a;
                end

            end
        end
    end    // Port A writting ----------------------------------------------------


    // Port B writting -----------------------------------------------------------

    always @(posedge i_write_flag_b or negedge i_write_flag_b)
    begin
        if (operation_mode == "BIDIR_DUAL_PORT")
        begin

            if ((i_wren_reg_b) && (i_good_to_write_b))
            begin
            
                i_aclr_flag_b = 0;

                // RAM content is following width_a
                // if Port B is of different width, need to make some adjustments

                if (i_indata_aclr_b)
                begin
                    if (i_data_reg_b != 0)
                    begin
                        if (enable_mem_data_b_reading)
                            mem_data_b[i_address_reg_b] = {width_b{1'bx}};
                       
                        if (width_a == width_b)
                            mem_data[i_address_reg_b] = {width_b{1'bx}};
                        else
                        begin
                            j = i_address_reg_b * width_b;
                            for (i2 = 0; i2 < width_b; i2 = i2+1)
                            begin
                                    j_plus_i2 = j + i2;
                                    temp_wa = mem_data[j_plus_i2 / width_a];
                                    temp_wa[j_plus_i2 % width_a] = {1'bx};
                                    mem_data[j_plus_i2 / width_a] = temp_wa;
                            end
                        end
                        i_aclr_flag_b = 1;
                    end
                end
                else if (i_byteena_aclr_b)
                begin
                    if (i_byteena_mask_reg_b != {width_b{1'b1}})
                    begin
                        if (enable_mem_data_b_reading)
                            mem_data_b[i_address_reg_b] = {width_b{1'bx}};
                        
                        if (width_a == width_b)
                            mem_data[i_address_reg_b] = {width_b{1'bx}};
                        else
                        begin
                            j = i_address_reg_b * width_b;
                            for (i2 = 0; i2 < width_b; i2 = i2+1)
                            begin
                                j_plus_i2 = j + i2;
                                j_plus_i2_div_a = j_plus_i2 / width_a;
                                temp_wa = mem_data[j_plus_i2_div_a];
                                temp_wa[j_plus_i2 % width_a] = {1'bx};
                                mem_data[j_plus_i2_div_a] = temp_wa;
                            end
                        end
                        i_aclr_flag_b = 1;
                    end
                end
                else if (i_address_aclr_b && (~i_address_aclr_family_b))
                begin
                    if (i_address_reg_b != 0)
                    begin
                        
                        if (enable_mem_data_b_reading)
                        begin
                            for (i2 = 0; i2 < i_numwords_b; i2 = i2 + 1)
                            begin
                                mem_data_b[i2] = {width_b{1'bx}};
                            end
                        end
                        
                        wa_mult_x_iii = {width_a{1'bx}};
                        for (i2 = 0; i2 < i_numwords_a; i2 = i2 + 1)
                        begin
                            mem_data[i2] = wa_mult_x_iii;
                        end
                        i_aclr_flag_b = 1;
                    end
                end

                if (i_aclr_flag_b == 0)
                begin
                        port_b_bit_count_low = i_address_reg_b * width_b;
                        port_a_bit_count_low = i_address_reg_a * width_a;
                        port_a_bit_count_high = port_a_bit_count_low + width_a;
                        
                        for (i2 = 0; i2 < width_b; i2 = i2 + 1)
                        begin
                            port_b_bit_count_high = port_b_bit_count_low + i2;
                            temp_wa = mem_data[port_b_bit_count_high / width_a];
                            i_original_data_b[i2] = temp_wa[port_b_bit_count_high % width_a];
                            
                            if ((port_b_bit_count_high >= port_a_bit_count_low) && (port_b_bit_count_high < port_a_bit_count_high) &&
                                ((same_clock_pulse0 && same_clock_pulse1) || (address_reg_b == "CLOCK0")) &&
                                (i_core_clocken_a_reg) && (i_wren_reg_a) &&
                                (i_byteena_mask_reg_a[port_b_bit_count_high % width_a]) && (i_byteena_mask_reg_b[i2]))
                                temp_wa[port_b_bit_count_high % width_a] = {1'bx};
                            else if (i_byteena_mask_reg_b[i2])
                                temp_wa[port_b_bit_count_high % width_a] = i_data_reg_b[i2];
                            
                            mem_data[port_b_bit_count_high / width_a] = temp_wa;
                            temp_wb[i2] = temp_wa[port_b_bit_count_high % width_a];
                        end

                        if (enable_mem_data_b_reading)
                            mem_data_b[i_address_reg_b] = temp_wb;

                    if ((read_during_write_mode_port_b == "OLD_DATA") && is_write_positive_edge_reg)
                        i_read_flag_b = ~i_read_flag_b;
                        
                    if ((cread_during_write_mode_mixed_ports == "OLD_DATA")&& (address_reg_b == "CLOCK0") && is_write_positive_edge_reg)
                        i_read_flag_a = ~i_read_flag_a;

                end

            end
            
        end
    end


    // Port A reading

    always @(posedge i_read_flag_a or negedge i_read_flag_a)
    begin
        if ((operation_mode == "BIDIR_DUAL_PORT") ||
            (operation_mode == "SINGLE_PORT") ||
            (operation_mode == "ROM"))
        begin
            if (~good_to_go_a && (is_lutram == 0))
            begin

                if (((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM") ||
                        ((i_ram_block_type == "AUTO") && (cread_during_write_mode_mixed_ports == "DONT_CARE"))) && 
                    (operation_mode != "ROM") &&
                    (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 0))
                    i_q_tmp2_a = {width_a{1'bx}};
                else
                    i_q_tmp2_a = 0;
            end
            else
            begin
                if (i_rden_reg_a)
                begin
                    // read from RAM content or flow through for write cycle
                    if (i_wren_reg_a)
                    begin
                        if (i_core_clocken_a)
                        begin
                            if (read_during_write_mode_port_a == "NEW_DATA_NO_NBE_READ")
                                if (is_lutram && clock0)
                                    i_q_tmp2_a = mem_data[i_address_reg_a];
                                else
                                    i_q_tmp2_a = ((i_data_reg_a & i_byteena_mask_reg_a) |
                                                ({width_a{1'bx}} & ~i_byteena_mask_reg_a));
                            else if (read_during_write_mode_port_a == "NEW_DATA_WITH_NBE_READ")
                                if (is_lutram && clock0)
                                    i_q_tmp2_a = mem_data[i_address_reg_a];
                                else
                                    i_q_tmp2_a = (i_data_reg_a & i_byteena_mask_reg_a) | (mem_data[i_address_reg_a] & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x;
                            else if (read_during_write_mode_port_a == "OLD_DATA")
                                i_q_tmp2_a = i_original_data_a;
                            else
                                if (!i_lutram_single_port_fast_read && (i_ram_block_type != "AUTO"))
                                begin
                                    if (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1)
                                        i_q_tmp2_a = {width_a{1'bx}};
                                    else
                                        i_q_tmp2_a = i_original_data_a;
                                end
                                else
                                    if (is_lutram)
                                        i_q_tmp2_a = mem_data[i_address_reg_a]; 
                                    else
                                        i_q_tmp2_a = i_data_reg_a ^ i_byteena_mask_reg_a_out;
                        end
                        else
                            i_q_tmp2_a = mem_data[i_address_reg_a];
                    end
                    else
                        i_q_tmp2_a = mem_data[i_address_reg_a];

                    if (is_write_positive_edge_reg)
                    begin

                        if (is_bidir_and_wrcontrol_addb_clk0 || (same_clock_pulse0 && same_clock_pulse1))
                        begin
                            // B write, A read
                        if ((i_wren_reg_b & ~i_wren_reg_a) & 
                            ((((is_bidir_and_wrcontrol_addb_clk0 & i_clocken0_b) || 
                            (is_bidir_and_wrcontrol_addb_clk1 & i_clocken1_b)) && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 0)) ||
                            (((is_bidir_and_wrcontrol_addb_clk0 & i_core_clocken0_b) || 
                            (is_bidir_and_wrcontrol_addb_clk1 & i_core_clocken1_b)) && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1))))
                            begin
                                add_reg_a_mult_wa = i_address_reg_a * width_a;
                                add_reg_b_mult_wb = i_address_reg_b * width_b;
                                add_reg_a_mult_wa_pl_wa = add_reg_a_mult_wa + width_a;
                                add_reg_b_mult_wb_pl_wb = add_reg_b_mult_wb + width_b;

                                if (
                                    ((add_reg_a_mult_wa >=
                                        add_reg_b_mult_wb) &&
                                    (add_reg_a_mult_wa <=
                                        (add_reg_b_mult_wb_pl_wb - 1)))

                                        ||

                                    (((add_reg_a_mult_wa_pl_wa - 1) >=
                                        add_reg_b_mult_wb) &&
                                    ((add_reg_a_mult_wa_pl_wa - 1) <=
                                        (add_reg_b_mult_wb_pl_wb - 1)))
                                    )
                                        for (i3 = add_reg_a_mult_wa;
                                                i3 < add_reg_a_mult_wa_pl_wa;
                                                i3 = i3 + 1)
                                        begin
                                            if ((i3 >= add_reg_b_mult_wb) &&
                                                (i3 <= (add_reg_b_mult_wb_pl_wb - 1)))
                                            begin
                                            
                                                if (read_during_write_mode_mixed_ports == "OLD_DATA")
                                                begin
                                                    i_byteena_count = i3 - add_reg_b_mult_wb;
                                                    i_q_tmp2_a_idx = (i3 - add_reg_a_mult_wa);
                                                    i_q_tmp2_a[i_q_tmp2_a_idx] = i_original_data_b[i_byteena_count];
                                                end
                                                else
                                                begin
                                                    i_byteena_count = i3 - add_reg_b_mult_wb;
                                                    i_q_tmp2_a_idx = (i3 - add_reg_a_mult_wa);
                                                    i_q_tmp2_a[i_q_tmp2_a_idx] = i_q_tmp2_a[i_q_tmp2_a_idx] ^ i_byteena_mask_reg_b_out_a[i_byteena_count];
                                                end
                                                
                                            end
                                        end
                            end
                        end
                    end
                end
                
                if ((is_lutram == 1) && i_address_aclr_a && (~i_address_aclr_family_a) && (operation_mode == "ROM"))
                    i_q_tmp2_a = mem_data[0];
                
                if ((dev.FEATURE_FAMILY_CYCLONEIII(intended_device_family) == 1) && 
                    (is_lutram != 1) &&
                    (i_outdata_aclr_a) &&
                    (outdata_reg_a != "CLOCK0") && (outdata_reg_a != "CLOCK1"))
                    i_q_tmp2_a = {width_a{1'b0}};
            end // end good_to_go_a
        end
    end


    // assigning the correct output values for i_q_tmp_a (non-registered output)
    always @(i_q_tmp2_a or i_wren_reg_a or i_data_reg_a or i_address_aclr_a or
            i_address_reg_a or i_byteena_mask_reg_a_out or i_numwords_a or i_outdata_aclr_a or i_force_reread_a_signal or i_original_data_a)
    begin
        if (i_address_reg_a >= i_numwords_a)
        begin
            if (i_wren_reg_a && i_core_clocken_a)
                i_q_tmp_a <= i_q_tmp2_a;
            else
                i_q_tmp_a <= {width_a{1'bx}};
            if (i_rden_reg_a == 1)
            begin
                $display("Warning : Address pointed at port A is out of bound!");
                $display("Time: %0t  Instance: %m", $time);
            end
        end
        else
            begin
                if (i_outdata_aclr_a_prev && ~ i_outdata_aclr_a && 
                    (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) &&
                    (is_lutram != 1))
                begin
                    i_outdata_aclr_a_prev = i_outdata_aclr_a;
                    i_force_reread_a <= 1;
                end
                else if (~i_address_aclr_a_prev && i_address_aclr_a && (~i_address_aclr_family_a) && s3_address_aclr_a)
                begin
                    if (i_rden_reg_a)
                        i_q_tmp_a <= {width_a{1'bx}};
                    i_force_reread_a1 <= 1;
                end
                else if ((i_force_reread_a1 == 0) && !(i_address_aclr_a_prev && ~i_address_aclr_a && (~i_address_aclr_family_a) && s3_address_aclr_a))
                begin
                    i_q_tmp_a <= i_q_tmp2_a;
                end
            end
            if ((i_outdata_aclr_a) && (s3_address_aclr_a))
            begin
                i_q_tmp_a <= {width_a{1'b0}};
                i_outdata_aclr_a_prev <= i_outdata_aclr_a;
            end
            i_address_aclr_a_prev <= i_address_aclr_a;
    end


    // Port A outdata output registered
    always @(posedge i_outdata_clk_a or posedge i_outdata_aclr_a)
    begin
        if (i_outdata_aclr_a)
            i_q_reg_a <= 0;
        else if (i_outdata_clken_a)
        begin           
            if ((i_address_aclr_a_flag == 1) &&
                (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family)) &&
                (outdata_reg_a == "CLOCK0") && (is_lutram != 1))
                i_q_reg_a <= 'bx;
            else
                i_q_reg_a <= i_q_tmp_a;
            if (i_core_clocken_a)
            i_address_aclr_a_flag <= 0;
        end
        else if (i_core_clocken_a)
            i_address_aclr_a_flag <= 0;
    end

    // Latch for address aclr till outclock enabled
    always @(posedge i_address_aclr_a or posedge i_outdata_aclr_a)
        if (i_outdata_aclr_a)
            i_address_aclr_a_flag <= 0;
        else
            if (i_rden_reg_a && (~i_address_aclr_family_a))
                i_address_aclr_a_flag <= 1;

    // Port A : assigning the correct output values for q_a
    assign q_a = (operation_mode == "DUAL_PORT") ?
                    {width_a{1'b0}} : (((outdata_reg_a == "CLOCK0") ||
                            (outdata_reg_a == "CLOCK1")) ?
                    i_q_reg_a : i_q_tmp_a);


    // Port B reading
    always @(posedge i_read_flag_b or negedge i_read_flag_b)
    begin
        if ((operation_mode == "BIDIR_DUAL_PORT") ||
            (operation_mode == "DUAL_PORT"))
        begin
            if (~good_to_go_b && (is_lutram == 0))
            begin
                
                if ((check_simultaneous_read_write == 1) &&
                    (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 0) &&
                    (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0))
                    i_q_tmp2_b = {width_b{1'bx}};
                else
                    i_q_tmp2_b = 0;
            end
            else
            begin
                if (i_rden_reg_b)
                begin
                    //If width_a is equal to b, no address calculation is needed
                    if (width_a == width_b)
                    begin

                        // read from memory or flow through for write cycle
                        if (i_wren_reg_b && (((is_bidir_and_wrcontrol_addb_clk0 == 1) && i_core_clocken0_b) || 
                            ((is_bidir_and_wrcontrol_addb_clk1 == 1) && i_core_clocken1_b)))
                        begin
                            if (read_during_write_mode_port_b == "NEW_DATA_NO_NBE_READ")
                                temp_wb = ((i_data_reg_b & i_byteena_mask_reg_b) |
                                            ({width_b{1'bx}} & ~i_byteena_mask_reg_b));
                            else if (read_during_write_mode_port_b == "NEW_DATA_WITH_NBE_READ")
                                temp_wb = (i_data_reg_b & i_byteena_mask_reg_b) | (mem_data[i_address_reg_b] & ~i_byteena_mask_reg_b) ^ i_byteena_mask_reg_b_x;
                            else if (read_during_write_mode_port_b == "OLD_DATA")
                                temp_wb = i_original_data_b; 
                            else 
                                temp_wb = {width_b{1'bx}};
                        end
                        else if ((i_data_write_time_a == $time) && (operation_mode == "DUAL_PORT")  &&
                            (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 0))
                        begin
                            // if A write to the same Ram address B is reading from
                            if ((i_address_reg_b == i_address_reg_a) && (i_original_address_a == i_address_reg_a))
                            begin
                                if (address_reg_b != "CLOCK0")
                                    temp_wb = mem_data[i_address_reg_b] ^ i_byteena_mask_reg_a_out_b;
                                else if (cread_during_write_mode_mixed_ports == "OLD_DATA")
                                begin
                                    if (mem_data[i_address_reg_b] == ((i_data_reg_a & i_byteena_mask_reg_a) | (mem_data[i_address_reg_a] & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x))
                                        temp_wb = i_original_data_a;
                                    else
                                        temp_wb = mem_data[i_address_reg_b];
                                end
                                else if (cread_during_write_mode_mixed_ports == "DONT_CARE")
                                    temp_wb = mem_data[i_address_reg_b] ^ i_byteena_mask_reg_a_out_b;
                                else
                                    temp_wb = mem_data[i_address_reg_b];
                            end
                            else
                                temp_wb = mem_data[i_address_reg_b];              
                        end
                        else
                            temp_wb = mem_data[i_address_reg_b];

                        if (is_write_positive_edge_reg)
                        begin
                            if ((dual_port_addreg_b_clk0 == 1) ||
                                (is_bidir_and_wrcontrol_addb_clk0 == 1) || (same_clock_pulse0 && same_clock_pulse1))
                            begin
                                // A write, B read
                                if ((i_wren_reg_a & ~i_wren_reg_b) && 
                                    ((i_clocken0 && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 0)) ||
                                    (i_core_clocken_a && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1))))
                                begin
                                    // if A write to the same Ram address B is reading from
                                    if (i_address_reg_b == i_address_reg_a)
                                    begin
                                        if (i_lutram_dual_port_fast_read)
                                            temp_wb = (i_data_reg_a & i_byteena_mask_reg_a) | (i_q_tmp2_a & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x;
                                        else
                                            if (cread_during_write_mode_mixed_ports == "OLD_DATA")
                                                if ((mem_data[i_address_reg_b] == ((i_data_reg_a & i_byteena_mask_reg_a) | (mem_data[i_address_reg_a] & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x))
                                                    && (i_data_write_time_a == $time))
                                                    temp_wb = i_original_data_a;
                                                else
                                                    temp_wb = mem_data[i_address_reg_b];
                                            else
                                                temp_wb = mem_data[i_address_reg_b] ^ i_byteena_mask_reg_a_out_b;
                                    end
                                end
                            end
                        end
                    end
                    else
                    begin
                        j2 = i_address_reg_b * width_b;

                        for (i5=0; i5<width_b; i5=i5+1)
                        begin
                            j2_plus_i5 = j2 + i5;
                            temp_wa2b = mem_data[j2_plus_i5 / width_a];
                            temp_wb[i5] = temp_wa2b[j2_plus_i5 % width_a];
                        end
                        
                        if (i_wren_reg_b && ((is_bidir_and_wrcontrol_addb_clk0 && i_core_clocken0_b) || 
                            (is_bidir_and_wrcontrol_addb_clk1 && i_core_clocken1_b)))
                        begin
                            if (read_during_write_mode_port_b == "NEW_DATA_NO_NBE_READ")
                                temp_wb = i_data_reg_b ^ i_byteena_mask_reg_b_out;
                            else if (read_during_write_mode_port_b == "NEW_DATA_WITH_NBE_READ")
                                temp_wb = (i_data_reg_b & i_byteena_mask_reg_b) | (temp_wb & ~i_byteena_mask_reg_b) ^ i_byteena_mask_reg_b_x;
                            else if (read_during_write_mode_port_b == "OLD_DATA")
                                temp_wb = i_original_data_b;
                            else 
                                temp_wb = {width_b{1'bx}};
                        end
                        else if ((i_data_write_time_a == $time) &&  (operation_mode == "DUAL_PORT") &&
                            (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 0))
                        begin
                            for (i5=0; i5<width_b; i5=i5+1)
                            begin
                                j2_plus_i5 = j2 + i5;
                                j2_plus_i5_div_a = j2_plus_i5 / width_a;

                                // if A write to the same Ram address B is reading from
                                if ((j2_plus_i5_div_a == i_address_reg_a) && (i_original_address_a == i_address_reg_a))
                                begin
                                    if (address_reg_b != "CLOCK0")
                                    begin
                                        temp_wa2b = mem_data[j2_plus_i5_div_a];
                                        temp_wa2b = temp_wa2b ^ i_byteena_mask_reg_a_out_b;
                                    end
                                    else if (cread_during_write_mode_mixed_ports == "OLD_DATA")
                                        temp_wa2b = i_original_data_a;
                                    else if (cread_during_write_mode_mixed_ports == "DONT_CARE")
                                    begin
                                        temp_wa2b = mem_data[j2_plus_i5_div_a];
                                        temp_wa2b = temp_wa2b ^ i_byteena_mask_reg_a_out_b;
                                    end
                                    else
                                        temp_wa2b = mem_data[j2_plus_i5_div_a];
                                end
                                else
                                    temp_wa2b = mem_data[j2_plus_i5_div_a];
              
                                temp_wb[i5] = temp_wa2b[j2_plus_i5 % width_a];
                            end
                        end

                        if (is_write_positive_edge_reg)
                        begin
                            if (((address_reg_b == "CLOCK0") & dual_port_addreg_b_clk0) ||
                                ((wrcontrol_wraddress_reg_b == "CLOCK0") & is_bidir_and_wrcontrol_addb_clk0) || (same_clock_pulse0 && same_clock_pulse1))
                            begin
                                // A write, B read
                                if ((i_wren_reg_a & ~i_wren_reg_b) && 
                                    ((i_clocken0 && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 0)) ||
                                    (i_core_clocken_a && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1))))
                                begin
                                
                                    for (i5=0; i5<width_b; i5=i5+1)
                                    begin
                                        j2_plus_i5 = j2 + i5;
                                        j2_plus_i5_div_a = j2_plus_i5 / width_a;
                                        
                                        // if A write to the same Ram address B is reading from
                                        if (j2_plus_i5_div_a == i_address_reg_a)
                                        begin
                                            if (i_lutram_single_port_fast_read)
                                                temp_wa2b = (i_data_reg_a & i_byteena_mask_reg_a) | (i_q_tmp2_a & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x;
                                            else
                                            begin
                                                if ((cread_during_write_mode_mixed_ports == "OLD_DATA") && (i_data_write_time_a == $time))
                                                    temp_wa2b = i_original_data_a;
                                                else
                                                begin
                                                    temp_wa2b = mem_data[j2_plus_i5_div_a];
                                                    temp_wa2b = temp_wa2b ^ i_byteena_mask_reg_a_out_b;
                                                end
                                            end
                                                
                                            temp_wb[i5] = temp_wa2b[j2_plus_i5 % width_a];
                                        end
                                            
                                    end
                                end
                            end
                        end
                    end 
                    //end of width_a != width_b
                    
                    i_q_tmp2_b = temp_wb;

                end
                
                if ((is_lutram == 1) && i_address_aclr_b && (~i_address_aclr_family_b) && (operation_mode == "DUAL_PORT"))
                begin
                    for (init_i = 0; init_i < width_b; init_i = init_i + 1)
                    begin
                        init_temp = mem_data[init_i / width_a];
                        i_q_tmp_b[init_i] = init_temp[init_i % width_a];
                        i_q_tmp2_b[init_i] = init_temp[init_i % width_a];
                    end
                end
                else if ((is_lutram == 1) && (operation_mode == "DUAL_PORT"))
                begin
                    j2 = i_address_reg_b * width_b;

                    for (i5=0; i5<width_b; i5=i5+1)
                    begin
                        j2_plus_i5 = j2 + i5;
                        temp_wa2b = mem_data[j2_plus_i5 / width_a];
                        i_q_tmp2_b[i5] = temp_wa2b[j2_plus_i5 % width_a];
                    end
                end
                
                if ((i_outdata_aclr_b) && 
                    (dev.FEATURE_FAMILY_CYCLONEIII(intended_device_family) == 1) &&
                    (is_lutram != 1) &&
                    (outdata_reg_b != "CLOCK0") && (outdata_reg_b != "CLOCK1"))
                    i_q_tmp2_b = {width_b{1'b0}};
            end
        end
    end


    // assigning the correct output values for i_q_tmp_b (non-registered output)
    always @(i_q_tmp2_b or i_wren_reg_b or i_data_reg_b or i_address_aclr_b or
                i_address_reg_b or i_byteena_mask_reg_b_out or i_rden_reg_b or
                i_numwords_b or i_outdata_aclr_b or i_force_reread_b_signal)
    begin
        if (i_address_reg_b >= i_numwords_b)
        begin
            if (i_wren_reg_b && ((i_core_clocken0_b && (is_bidir_and_wrcontrol_addb_clk0 == 1)) || (i_core_clocken1_b && (is_bidir_and_wrcontrol_addb_clk1 == 1))))
                i_q_tmp_b <= i_q_tmp2_b;
            else
                i_q_tmp_b <= {width_b{1'bx}};
            if (i_rden_reg_b == 1)
            begin
                $display("Warning : Address pointed at port B is out of bound!");
                $display("Time: %0t  Instance: %m", $time);
            end
        end
        else
            if (operation_mode == "BIDIR_DUAL_PORT")
            begin
            
                if (i_outdata_aclr_b_prev && ~ i_outdata_aclr_b && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) && (is_lutram != 1))
                begin
                    i_outdata_aclr_b_prev <= i_outdata_aclr_b;
                    i_force_reread_b <= 1;
                end
                else
                begin
                    i_q_tmp_b <= i_q_tmp2_b;
                end
            end
            else if (operation_mode == "DUAL_PORT")
            begin
                if (i_outdata_aclr_b_prev && ~ i_outdata_aclr_b && (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family) == 1) && (is_lutram != 1))
                begin
                    i_outdata_aclr_b_prev <= i_outdata_aclr_b;
                    i_force_reread_b <= 1;
                end
                else if (~i_address_aclr_b_prev && i_address_aclr_b && (~i_address_aclr_family_b) && s3_address_aclr_b)
                begin
                    if (i_rden_reg_b)
                        i_q_tmp_b <= {width_b{1'bx}};
                        i_force_reread_b1 <= 1;
                end
                else if ((i_force_reread_b1 == 0) && !(i_address_aclr_b_prev && ~i_address_aclr_b && (~i_address_aclr_family_b) && s3_address_aclr_b))
                begin
                    if (i_rden_reg_b || (is_lutram == 1))
                        i_q_tmp_b <= i_q_tmp2_b;
                end
            end
        
        if ((i_outdata_aclr_b) && (s3_address_aclr_b))
        begin
            i_q_tmp_b <= {width_b{1'b0}};
            i_outdata_aclr_b_prev <= i_outdata_aclr_b;
        end
        i_address_aclr_b_prev <= i_address_aclr_b;
    end

    // output latch for lutram (only used when read_during_write_mode_mixed_ports == "OLD_DATA")
    always @(negedge i_outdata_clk_b)
    begin
        if (i_core_clocken_a)
            i_q_output_latch <= i_q_tmp2_b;
    end

    // Port B outdata output registered
    always @(posedge i_outdata_clk_b or posedge i_outdata_aclr_b)
    begin
        if (i_outdata_aclr_b)
            i_q_reg_b <= 0;
        else if (i_outdata_clken_b)
        begin
            if ((is_lutram == 1) && (cread_during_write_mode_mixed_ports == "OLD_DATA") && (outdata_reg_b == "CLOCK0"))
                i_q_reg_b <= i_q_output_latch;
            else
            begin           
                if ((i_address_aclr_b_flag == 1) && (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family)) &&
                    (is_lutram != 1))
                    i_q_reg_b <= 'bx;
                else
                i_q_reg_b <= i_q_tmp_b;
            end
        end
    end

    // Latch for address aclr till outclock enabled
    always @(posedge i_address_aclr_b or posedge i_outdata_aclr_b)
        if (i_outdata_aclr_b)
            i_address_aclr_b_flag <= 0;
        else
        begin
            if (i_rden_reg_b)
                i_address_aclr_b_flag <= 1;
        end

    // Port B : assigning the correct output values for q_b
    assign q_b = ((operation_mode == "SINGLE_PORT") ||
                    (operation_mode == "ROM")) ?
                        {width_b{1'b0}} : (((outdata_reg_b == "CLOCK0") ||
                            (outdata_reg_b == "CLOCK1")) ?
                        i_q_reg_b : i_q_tmp_b);


    // ECC status
    assign eccstatus = {3'b000};

endmodule // ALTSYNCRAM

// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  ALTERA_DEVICE_FAMILIES
//
// Description     :  Common Altera device families comparison
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module ALTERA_DEVICE_FAMILIES;

function IS_FAMILY_ACEX1K;
    input[8*20:1] device;
    reg is_acex1k;
begin
    if ((device == "ACEX1K") || (device == "acex1k") || (device == "ACEX 1K") || (device == "acex 1k"))
        is_acex1k = 1;
    else
        is_acex1k = 0;

    IS_FAMILY_ACEX1K  = is_acex1k;
end
endfunction //IS_FAMILY_ACEX1K

function IS_FAMILY_APEX20K;
    input[8*20:1] device;
    reg is_apex20k;
begin
    if ((device == "APEX20K") || (device == "apex20k") || (device == "APEX 20K") || (device == "apex 20k") || (device == "RAPHAEL") || (device == "raphael"))
        is_apex20k = 1;
    else
        is_apex20k = 0;

    IS_FAMILY_APEX20K  = is_apex20k;
end
endfunction //IS_FAMILY_APEX20K

function IS_FAMILY_APEX20KC;
    input[8*20:1] device;
    reg is_apex20kc;
begin
    if ((device == "APEX20KC") || (device == "apex20kc") || (device == "APEX 20KC") || (device == "apex 20kc"))
        is_apex20kc = 1;
    else
        is_apex20kc = 0;

    IS_FAMILY_APEX20KC  = is_apex20kc;
end
endfunction //IS_FAMILY_APEX20KC

function IS_FAMILY_APEX20KE;
    input[8*20:1] device;
    reg is_apex20ke;
begin
    if ((device == "APEX20KE") || (device == "apex20ke") || (device == "APEX 20KE") || (device == "apex 20ke"))
        is_apex20ke = 1;
    else
        is_apex20ke = 0;

    IS_FAMILY_APEX20KE  = is_apex20ke;
end
endfunction //IS_FAMILY_APEX20KE

function IS_FAMILY_APEXII;
    input[8*20:1] device;
    reg is_apexii;
begin
    if ((device == "APEX II") || (device == "apex ii") || (device == "APEXII") || (device == "apexii") || (device == "APEX 20KF") || (device == "apex 20kf") || (device == "APEX20KF") || (device == "apex20kf"))
        is_apexii = 1;
    else
        is_apexii = 0;

    IS_FAMILY_APEXII  = is_apexii;
end
endfunction //IS_FAMILY_APEXII

function IS_FAMILY_EXCALIBUR_ARM;
    input[8*20:1] device;
    reg is_excalibur_arm;
begin
    if ((device == "EXCALIBUR_ARM") || (device == "excalibur_arm") || (device == "Excalibur ARM") || (device == "EXCALIBUR ARM") || (device == "excalibur arm") || (device == "ARM-BASED EXCALIBUR") || (device == "arm-based excalibur") || (device == "ARM_BASED_EXCALIBUR") || (device == "arm_based_excalibur"))
        is_excalibur_arm = 1;
    else
        is_excalibur_arm = 0;

    IS_FAMILY_EXCALIBUR_ARM  = is_excalibur_arm;
end
endfunction //IS_FAMILY_EXCALIBUR_ARM

function IS_FAMILY_FLEX10KE;
    input[8*20:1] device;
    reg is_flex10ke;
begin
    if ((device == "FLEX10KE") || (device == "flex10ke") || (device == "FLEX 10KE") || (device == "flex 10ke"))
        is_flex10ke = 1;
    else
        is_flex10ke = 0;

    IS_FAMILY_FLEX10KE  = is_flex10ke;
end
endfunction //IS_FAMILY_FLEX10KE

function IS_FAMILY_STRATIX;
    input[8*20:1] device;
    reg is_stratix;
begin
    if ((device == "Stratix") || (device == "STRATIX") || (device == "stratix") || (device == "Yeager") || (device == "YEAGER") || (device == "yeager"))
        is_stratix = 1;
    else
        is_stratix = 0;

    IS_FAMILY_STRATIX  = is_stratix;
end
endfunction //IS_FAMILY_STRATIX

function IS_FAMILY_STRATIXGX;
    input[8*20:1] device;
    reg is_stratixgx;
begin
    if ((device == "Stratix GX") || (device == "STRATIX GX") || (device == "stratix gx") || (device == "Stratix-GX") || (device == "STRATIX-GX") || (device == "stratix-gx") || (device == "StratixGX") || (device == "STRATIXGX") || (device == "stratixgx") || (device == "Aurora") || (device == "AURORA") || (device == "aurora"))
        is_stratixgx = 1;
    else
        is_stratixgx = 0;

    IS_FAMILY_STRATIXGX  = is_stratixgx;
end
endfunction //IS_FAMILY_STRATIXGX

function IS_FAMILY_CYCLONE;
    input[8*20:1] device;
    reg is_cyclone;
begin
    if ((device == "Cyclone") || (device == "CYCLONE") || (device == "cyclone") || (device == "ACEX2K") || (device == "acex2k") || (device == "ACEX 2K") || (device == "acex 2k") || (device == "Tornado") || (device == "TORNADO") || (device == "tornado"))
        is_cyclone = 1;
    else
        is_cyclone = 0;

    IS_FAMILY_CYCLONE  = is_cyclone;
end
endfunction //IS_FAMILY_CYCLONE

function IS_FAMILY_MAXII;
    input[8*20:1] device;
    reg is_maxii;
begin
    if ((device == "MAX II") || (device == "max ii") || (device == "MAXII") || (device == "maxii") || (device == "Tsunami") || (device == "TSUNAMI") || (device == "tsunami"))
        is_maxii = 1;
    else
        is_maxii = 0;

    IS_FAMILY_MAXII  = is_maxii;
end
endfunction //IS_FAMILY_MAXII

function IS_FAMILY_HARDCOPYSTRATIX;
    input[8*20:1] device;
    reg is_hardcopystratix;
begin
    if ((device == "HardCopy Stratix") || (device == "HARDCOPY STRATIX") || (device == "hardcopy stratix") || (device == "Stratix HC") || (device == "STRATIX HC") || (device == "stratix hc") || (device == "StratixHC") || (device == "STRATIXHC") || (device == "stratixhc") || (device == "HardcopyStratix") || (device == "HARDCOPYSTRATIX") || (device == "hardcopystratix"))
        is_hardcopystratix = 1;
    else
        is_hardcopystratix = 0;

    IS_FAMILY_HARDCOPYSTRATIX  = is_hardcopystratix;
end
endfunction //IS_FAMILY_HARDCOPYSTRATIX

function IS_FAMILY_STRATIXII;
    input[8*20:1] device;
    reg is_stratixii;
begin
    if ((device == "Stratix II") || (device == "STRATIX II") || (device == "stratix ii") || (device == "StratixII") || (device == "STRATIXII") || (device == "stratixii") || (device == "Armstrong") || (device == "ARMSTRONG") || (device == "armstrong"))
        is_stratixii = 1;
    else
        is_stratixii = 0;

    IS_FAMILY_STRATIXII  = is_stratixii;
end
endfunction //IS_FAMILY_STRATIXII

function IS_FAMILY_STRATIXIIGX;
    input[8*20:1] device;
    reg is_stratixiigx;
begin
    if ((device == "Stratix II GX") || (device == "STRATIX II GX") || (device == "stratix ii gx") || (device == "StratixIIGX") || (device == "STRATIXIIGX") || (device == "stratixiigx"))
        is_stratixiigx = 1;
    else
        is_stratixiigx = 0;

    IS_FAMILY_STRATIXIIGX  = is_stratixiigx;
end
endfunction //IS_FAMILY_STRATIXIIGX

function IS_FAMILY_ARRIAGX;
    input[8*20:1] device;
    reg is_arriagx;
begin
    if ((device == "Arria GX") || (device == "ARRIA GX") || (device == "arria gx") || (device == "ArriaGX") || (device == "ARRIAGX") || (device == "arriagx") || (device == "Stratix II GX Lite") || (device == "STRATIX II GX LITE") || (device == "stratix ii gx lite") || (device == "StratixIIGXLite") || (device == "STRATIXIIGXLITE") || (device == "stratixiigxlite"))
        is_arriagx = 1;
    else
        is_arriagx = 0;

    IS_FAMILY_ARRIAGX  = is_arriagx;
end
endfunction //IS_FAMILY_ARRIAGX

function IS_FAMILY_CYCLONEII;
    input[8*20:1] device;
    reg is_cycloneii;
begin
    if ((device == "Cyclone II") || (device == "CYCLONE II") || (device == "cyclone ii") || (device == "Cycloneii") || (device == "CYCLONEII") || (device == "cycloneii") || (device == "Magellan") || (device == "MAGELLAN") || (device == "magellan"))
        is_cycloneii = 1;
    else
        is_cycloneii = 0;

    IS_FAMILY_CYCLONEII  = is_cycloneii;
end
endfunction //IS_FAMILY_CYCLONEII

function IS_FAMILY_HARDCOPYII;
    input[8*20:1] device;
    reg is_hardcopyii;
begin
    if ((device == "HardCopy II") || (device == "HARDCOPY II") || (device == "hardcopy ii") || (device == "HardCopyII") || (device == "HARDCOPYII") || (device == "hardcopyii") || (device == "Fusion") || (device == "FUSION") || (device == "fusion"))
        is_hardcopyii = 1;
    else
        is_hardcopyii = 0;

    IS_FAMILY_HARDCOPYII  = is_hardcopyii;
end
endfunction //IS_FAMILY_HARDCOPYII

function IS_FAMILY_STRATIXIII;
    input[8*20:1] device;
    reg is_stratixiii;
begin
    if ((device == "Stratix III") || (device == "STRATIX III") || (device == "stratix iii") || (device == "StratixIII") || (device == "STRATIXIII") || (device == "stratixiii") || (device == "Titan") || (device == "TITAN") || (device == "titan") || (device == "SIII") || (device == "siii"))
        is_stratixiii = 1;
    else
        is_stratixiii = 0;

    IS_FAMILY_STRATIXIII  = is_stratixiii;
end
endfunction //IS_FAMILY_STRATIXIII

function IS_FAMILY_CYCLONEIII;
    input[8*20:1] device;
    reg is_cycloneiii;
begin
    if ((device == "Cyclone III") || (device == "CYCLONE III") || (device == "cyclone iii") || (device == "CycloneIII") || (device == "CYCLONEIII") || (device == "cycloneiii") || (device == "Barracuda") || (device == "BARRACUDA") || (device == "barracuda") || (device == "Cuda") || (device == "CUDA") || (device == "cuda") || (device == "CIII") || (device == "ciii"))
        is_cycloneiii = 1;
    else
        is_cycloneiii = 0;

    IS_FAMILY_CYCLONEIII  = is_cycloneiii;
end
endfunction //IS_FAMILY_CYCLONEIII

function IS_FAMILY_STRATIXIV;
    input[8*20:1] device;
    reg is_stratixiv;
begin
    if ((device == "Stratix IV") || (device == "STRATIX IV") || (device == "stratix iv") || (device == "TGX") || (device == "tgx") || (device == "StratixIV") || (device == "STRATIXIV") || (device == "stratixiv") || (device == "StratixIIIGX") || (device == "STRATIXIIIGX") || (device == "stratixiiigx") || (device == "Stratix IV (GT/GX/E)") || (device == "STRATIX IV (GT/GX/E)") || (device == "stratix iv (gt/gx/e)") || (device == "StratixIV(GT/GX/E)") || (device == "STRATIXIV(GT/GX/E)") || (device == "stratixiv(gt/gx/e)") || (device == "Stratix IV (GX/E)") || (device == "STRATIX IV (GX/E)") || (device == "stratix iv (gx/e)") || (device == "StratixIV(GX/E)") || (device == "STRATIXIV(GX/E)") || (device == "stratixiv(gx/e)"))
        is_stratixiv = 1;
    else
        is_stratixiv = 0;

    IS_FAMILY_STRATIXIV  = is_stratixiv;
end
endfunction //IS_FAMILY_STRATIXIV

function IS_FAMILY_ARRIAIIGXGX;
    input[8*20:1] device;
    reg is_arriaiigx;
begin
    if ((device == "Arria II GX") || (device == "ARRIA II GX") || (device == "arria ii gx") || (device == "ArriaIIGX") || (device == "ARRIAIIGX") || (device == "arriaiigx") || (device == "Arria IIGX") || (device == "ARRIA IIGX") || (device == "arria iigx") || (device == "ArriaII GX") || (device == "ARRIAII GX") || (device == "arriaii gx") || (device == "Arria II") || (device == "ARRIA II") || (device == "arria ii") || (device == "ArriaII") || (device == "ARRIAII") || (device == "arriaii") || (device == "Arria II (GX/E)") || (device == "ARRIA II (GX/E)") || (device == "arria ii (gx/e)") || (device == "ArriaII(GX/E)") || (device == "ARRIAII(GX/E)") || (device == "arriaii(gx/e)") || (device == "PIRANHA") || (device == "piranha"))
        is_arriaiigx = 1;
    else
        is_arriaiigx = 0;

    IS_FAMILY_ARRIAIIGXGX  = is_arriaiigx;
end
endfunction //IS_FAMILY_ARRIAIIGXGX

function IS_FAMILY_HARDCOPYIII;
    input[8*20:1] device;
    reg is_hardcopyiii;
begin
    if ((device == "HardCopy III") || (device == "HARDCOPY III") || (device == "hardcopy iii") || (device == "HardCopyIII") || (device == "HARDCOPYIII") || (device == "hardcopyiii") || (device == "HCX") || (device == "hcx"))
        is_hardcopyiii = 1;
    else
        is_hardcopyiii = 0;

    IS_FAMILY_HARDCOPYIII  = is_hardcopyiii;
end
endfunction //IS_FAMILY_HARDCOPYIII

function IS_FAMILY_HARDCOPYIV;
    input[8*20:1] device;
    reg is_hardcopyiv;
begin
    if ((device == "HardCopy IV") || (device == "HARDCOPY IV") || (device == "hardcopy iv") || (device == "HardCopyIV") || (device == "HARDCOPYIV") || (device == "hardcopyiv") || (device == "HCXIV") || (device == "hcxiv") || (device == "HardCopy IV (GX/E)") || (device == "HARDCOPY IV (GX/E)") || (device == "hardcopy iv (gx/e)") || (device == "HardCopyIV(GX/E)") || (device == "HARDCOPYIV(GX/E)") || (device == "hardcopyiv(gx/e)"))
        is_hardcopyiv = 1;
    else
        is_hardcopyiv = 0;

    IS_FAMILY_HARDCOPYIV  = is_hardcopyiv;
end
endfunction //IS_FAMILY_HARDCOPYIV

function IS_FAMILY_CYCLONEIIILS;
    input[8*20:1] device;
    reg is_cycloneiiils;
begin
    if ((device == "Cyclone III LS") || (device == "CYCLONE III LS") || (device == "cyclone iii ls") || (device == "CycloneIIILS") || (device == "CYCLONEIIILS") || (device == "cycloneiiils") || (device == "Cyclone III LPS") || (device == "CYCLONE III LPS") || (device == "cyclone iii lps") || (device == "Cyclone LPS") || (device == "CYCLONE LPS") || (device == "cyclone lps") || (device == "CycloneLPS") || (device == "CYCLONELPS") || (device == "cyclonelps") || (device == "Tarpon") || (device == "TARPON") || (device == "tarpon") || (device == "Cyclone IIIE") || (device == "CYCLONE IIIE") || (device == "cyclone iiie"))
        is_cycloneiiils = 1;
    else
        is_cycloneiiils = 0;

    IS_FAMILY_CYCLONEIIILS  = is_cycloneiiils;
end
endfunction //IS_FAMILY_CYCLONEIIILS

function FEATURE_FAMILY_FLEX10KE;
    input[8*20:1] device;
    reg var_family_flex10ke;
begin
    if (IS_FAMILY_FLEX10KE(device) || IS_FAMILY_ACEX1K(device) )
        var_family_flex10ke = 1;
    else
        var_family_flex10ke = 0;

    FEATURE_FAMILY_FLEX10KE  = var_family_flex10ke;
end
endfunction //FEATURE_FAMILY_FLEX10KE

function FEATURE_FAMILY_APEX20K;
    input[8*20:1] device;
    reg var_family_apex20k;
begin
    if (IS_FAMILY_APEX20K(device) )
        var_family_apex20k = 1;
    else
        var_family_apex20k = 0;

    FEATURE_FAMILY_APEX20K  = var_family_apex20k;
end
endfunction //FEATURE_FAMILY_APEX20K

function FEATURE_FAMILY_APEX20KE;
    input[8*20:1] device;
    reg var_family_apex20ke;
begin
    if (IS_FAMILY_APEX20KE(device) || IS_FAMILY_EXCALIBUR_ARM(device) || IS_FAMILY_APEX20KC(device) )
        var_family_apex20ke = 1;
    else
        var_family_apex20ke = 0;

    FEATURE_FAMILY_APEX20KE  = var_family_apex20ke;
end
endfunction //FEATURE_FAMILY_APEX20KE

function FEATURE_FAMILY_APEXII;
    input[8*20:1] device;
    reg var_family_apexii;
begin
    if (IS_FAMILY_APEXII(device) || IS_FAMILY_APEXII(device) )
        var_family_apexii = 1;
    else
        var_family_apexii = 0;

    FEATURE_FAMILY_APEXII  = var_family_apexii;
end
endfunction //FEATURE_FAMILY_APEXII

function FEATURE_FAMILY_STRATIXGX;
    input[8*20:1] device;
    reg var_family_stratixgx;
begin
    if (IS_FAMILY_STRATIXGX(device) )
        var_family_stratixgx = 1;
    else
        var_family_stratixgx = 0;

    FEATURE_FAMILY_STRATIXGX  = var_family_stratixgx;
end
endfunction //FEATURE_FAMILY_STRATIXGX

function FEATURE_FAMILY_CYCLONE;
    input[8*20:1] device;
    reg var_family_cyclone;
begin
    if (IS_FAMILY_CYCLONE(device) )
        var_family_cyclone = 1;
    else
        var_family_cyclone = 0;

    FEATURE_FAMILY_CYCLONE  = var_family_cyclone;
end
endfunction //FEATURE_FAMILY_CYCLONE

function FEATURE_FAMILY_STRATIXIIGX;
    input[8*20:1] device;
    reg var_family_stratixiigx;
begin
    if (IS_FAMILY_STRATIXIIGX(device) || IS_FAMILY_ARRIAGX(device) )
        var_family_stratixiigx = 1;
    else
        var_family_stratixiigx = 0;

    FEATURE_FAMILY_STRATIXIIGX  = var_family_stratixiigx;
end
endfunction //FEATURE_FAMILY_STRATIXIIGX

function FEATURE_FAMILY_STRATIXIII;
    input[8*20:1] device;
    reg var_family_stratixiii;
begin
    if (IS_FAMILY_STRATIXIII(device) || FEATURE_FAMILY_STRATIXIV(device) || IS_FAMILY_HARDCOPYIII(device) )
        var_family_stratixiii = 1;
    else
        var_family_stratixiii = 0;

    FEATURE_FAMILY_STRATIXIII  = var_family_stratixiii;
end
endfunction //FEATURE_FAMILY_STRATIXIII

function FEATURE_FAMILY_STRATIXII;
    input[8*20:1] device;
    reg var_family_stratixii;
begin
    if (IS_FAMILY_STRATIXII(device) || IS_FAMILY_HARDCOPYII(device) || FEATURE_FAMILY_STRATIXIIGX(device) || FEATURE_FAMILY_STRATIXIII(device) )
        var_family_stratixii = 1;
    else
        var_family_stratixii = 0;

    FEATURE_FAMILY_STRATIXII  = var_family_stratixii;
end
endfunction //FEATURE_FAMILY_STRATIXII

function FEATURE_FAMILY_CYCLONEIII;
    input[8*20:1] device;
    reg var_family_cycloneiii;
begin
    if (IS_FAMILY_CYCLONEIII(device) || IS_FAMILY_CYCLONEIIILS(device) )
        var_family_cycloneiii = 1;
    else
        var_family_cycloneiii = 0;

    FEATURE_FAMILY_CYCLONEIII  = var_family_cycloneiii;
end
endfunction //FEATURE_FAMILY_CYCLONEIII

function FEATURE_FAMILY_STRATIX_HC;
    input[8*20:1] device;
    reg var_family_stratix_hc;
begin
    if (IS_FAMILY_HARDCOPYSTRATIX(device) )
        var_family_stratix_hc = 1;
    else
        var_family_stratix_hc = 0;

    FEATURE_FAMILY_STRATIX_HC  = var_family_stratix_hc;
end
endfunction //FEATURE_FAMILY_STRATIX_HC

function FEATURE_FAMILY_HARDCOPYII;
    input[8*20:1] device;
    reg var_family_hardcopyii;
begin
    if (IS_FAMILY_HARDCOPYII(device) )
        var_family_hardcopyii = 1;
    else
        var_family_hardcopyii = 0;

    FEATURE_FAMILY_HARDCOPYII  = var_family_hardcopyii;
end
endfunction //FEATURE_FAMILY_HARDCOPYII

function FEATURE_FAMILY_STRATIX;
    input[8*20:1] device;
    reg var_family_stratix;
begin
    if (IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIX_HC(device) || FEATURE_FAMILY_STRATIXGX(device) || FEATURE_FAMILY_CYCLONE(device) || FEATURE_FAMILY_STRATIXII(device) || FEATURE_FAMILY_MAXII(device) || FEATURE_FAMILY_CYCLONEII(device) )
        var_family_stratix = 1;
    else
        var_family_stratix = 0;

    FEATURE_FAMILY_STRATIX  = var_family_stratix;
end
endfunction //FEATURE_FAMILY_STRATIX

function FEATURE_FAMILY_MAXII;
    input[8*20:1] device;
    reg var_family_maxii;
begin
    if (IS_FAMILY_MAXII(device) )
        var_family_maxii = 1;
    else
        var_family_maxii = 0;

    FEATURE_FAMILY_MAXII  = var_family_maxii;
end
endfunction //FEATURE_FAMILY_MAXII

function FEATURE_FAMILY_CYCLONEII;
    input[8*20:1] device;
    reg var_family_cycloneii;
begin
    if (IS_FAMILY_CYCLONEII(device) || FEATURE_FAMILY_CYCLONEIII(device) )
        var_family_cycloneii = 1;
    else
        var_family_cycloneii = 0;

    FEATURE_FAMILY_CYCLONEII  = var_family_cycloneii;
end
endfunction //FEATURE_FAMILY_CYCLONEII

function FEATURE_FAMILY_STRATIXIV;
    input[8*20:1] device;
    reg var_family_stratixiv;
begin
    if (IS_FAMILY_STRATIXIV(device) || IS_FAMILY_ARRIAIIGXGX(device) || IS_FAMILY_HARDCOPYIV(device) )
        var_family_stratixiv = 1;
    else
        var_family_stratixiv = 0;

    FEATURE_FAMILY_STRATIXIV  = var_family_stratixiv;
end
endfunction //FEATURE_FAMILY_STRATIXIV

function FEATURE_FAMILY_ARRIAIIGX;
    input[8*20:1] device;
    reg var_family_arriaiigx;
begin
    if (IS_FAMILY_ARRIAIIGXGX(device) )
        var_family_arriaiigx = 1;
    else
        var_family_arriaiigx = 0;

    FEATURE_FAMILY_ARRIAIIGX  = var_family_arriaiigx;
end
endfunction //FEATURE_FAMILY_ARRIAIIGX

function FEATURE_FAMILY_BASE_STRATIXII;
    input[8*20:1] device;
    reg var_family_base_stratixii;
begin
    if (IS_FAMILY_STRATIXII(device) || IS_FAMILY_HARDCOPYII(device) || FEATURE_FAMILY_STRATIXIIGX(device) )
        var_family_base_stratixii = 1;
    else
        var_family_base_stratixii = 0;

    FEATURE_FAMILY_BASE_STRATIXII  = var_family_base_stratixii;
end
endfunction //FEATURE_FAMILY_BASE_STRATIXII

function FEATURE_FAMILY_BASE_STRATIX;
    input[8*20:1] device;
    reg var_family_base_stratix;
begin
    if (IS_FAMILY_STRATIX(device) || IS_FAMILY_STRATIXGX(device) || IS_FAMILY_HARDCOPYSTRATIX(device) )
        var_family_base_stratix = 1;
    else
        var_family_base_stratix = 0;

    FEATURE_FAMILY_BASE_STRATIX  = var_family_base_stratix;
end
endfunction //FEATURE_FAMILY_BASE_STRATIX

function FEATURE_FAMILY_BASE_CYCLONEII;
    input[8*20:1] device;
    reg var_family_base_cycloneii;
begin
    if (IS_FAMILY_CYCLONEII(device) )
        var_family_base_cycloneii = 1;
    else
        var_family_base_cycloneii = 0;

    FEATURE_FAMILY_BASE_CYCLONEII  = var_family_base_cycloneii;
end
endfunction //FEATURE_FAMILY_BASE_CYCLONEII

function FEATURE_FAMILY_BASE_CYCLONE;
    input[8*20:1] device;
    reg var_family_base_cyclone;
begin
    if (IS_FAMILY_CYCLONE(device) )
        var_family_base_cyclone = 1;
    else
        var_family_base_cyclone = 0;

    FEATURE_FAMILY_BASE_CYCLONE  = var_family_base_cyclone;
end
endfunction //FEATURE_FAMILY_BASE_CYCLONE

function FEATURE_FAMILY_HAS_MEGARAM;
    input[8*20:1] device;
    reg var_family_has_megaram;
begin
    if (IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIX_HC(device) || IS_FAMILY_STRATIXGX(device) || FEATURE_FAMILY_STRATIXII(device) && ! FEATURE_FAMILY_ARRIAIIGX(device) )
        var_family_has_megaram = 1;
    else
        var_family_has_megaram = 0;

    FEATURE_FAMILY_HAS_MEGARAM  = var_family_has_megaram;
end
endfunction //FEATURE_FAMILY_HAS_MEGARAM

function FEATURE_FAMILY_HAS_M512;
    input[8*20:1] device;
    reg var_family_has_m512;
begin
    if (IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIX_HC(device) || IS_FAMILY_STRATIXGX(device) || IS_FAMILY_STRATIXII(device) || FEATURE_FAMILY_STRATIXIIGX(device) )
        var_family_has_m512 = 1;
    else
        var_family_has_m512 = 0;

    FEATURE_FAMILY_HAS_M512  = var_family_has_m512;
end
endfunction //FEATURE_FAMILY_HAS_M512

function FEATURE_FAMILY_HAS_LUTRAM;
    input[8*20:1] device;
    reg var_family_has_lutram;
begin
    if (FEATURE_FAMILY_STRATIXIII(device) )
        var_family_has_lutram = 1;
    else
        var_family_has_lutram = 0;

    FEATURE_FAMILY_HAS_LUTRAM  = var_family_has_lutram;
end
endfunction //FEATURE_FAMILY_HAS_LUTRAM

function FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM;
    input[8*20:1] device;
    reg var_family_has_stratixi_style_ram;
begin
    if (IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIX_HC(device) || FEATURE_FAMILY_STRATIXGX(device) || FEATURE_FAMILY_CYCLONE(device) )
        var_family_has_stratixi_style_ram = 1;
    else
        var_family_has_stratixi_style_ram = 0;

    FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM  = var_family_has_stratixi_style_ram;
end
endfunction //FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM

function FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM;
    input[8*20:1] device;
    reg var_family_has_stratixii_style_ram;
begin
    if (FEATURE_FAMILY_STRATIXII(device) || FEATURE_FAMILY_CYCLONEII(device) )
        var_family_has_stratixii_style_ram = 1;
    else
        var_family_has_stratixii_style_ram = 0;

    FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM  = var_family_has_stratixii_style_ram;
end
endfunction //FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM

function FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM;
    input[8*20:1] device;
    reg var_family_has_stratixiii_style_ram;
begin
    if (FEATURE_FAMILY_STRATIXIII(device) || FEATURE_FAMILY_CYCLONEIII(device) )
        var_family_has_stratixiii_style_ram = 1;
    else
        var_family_has_stratixiii_style_ram = 0;

    FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM  = var_family_has_stratixiii_style_ram;
end
endfunction //FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM

function FEATURE_FAMILY_HAS_STRATIX_STYLE_PLL;
    input[8*20:1] device;
    reg var_family_has_stratix_style_pll;
begin
    if (FEATURE_FAMILY_CYCLONE(device) || FEATURE_FAMILY_STRATIX_HC(device) || IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIXGX(device) )
        var_family_has_stratix_style_pll = 1;
    else
        var_family_has_stratix_style_pll = 0;

    FEATURE_FAMILY_HAS_STRATIX_STYLE_PLL  = var_family_has_stratix_style_pll;
end
endfunction //FEATURE_FAMILY_HAS_STRATIX_STYLE_PLL

function FEATURE_FAMILY_HAS_STRATIXII_STYLE_PLL;
    input[8*20:1] device;
    reg var_family_has_stratixii_style_pll;
begin
    if (FEATURE_FAMILY_STRATIXII(device) && ! FEATURE_FAMILY_STRATIXIII(device) || FEATURE_FAMILY_CYCLONEII(device) && ! FEATURE_FAMILY_CYCLONEIII(device) )
        var_family_has_stratixii_style_pll = 1;
    else
        var_family_has_stratixii_style_pll = 0;

    FEATURE_FAMILY_HAS_STRATIXII_STYLE_PLL  = var_family_has_stratixii_style_pll;
end
endfunction //FEATURE_FAMILY_HAS_STRATIXII_STYLE_PLL

function FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO;
    input[8*20:1] device;
    reg var_family_has_inverted_output_ddio;
begin
    if (FEATURE_FAMILY_CYCLONEII(device) )
        var_family_has_inverted_output_ddio = 1;
    else
        var_family_has_inverted_output_ddio = 0;

    FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO  = var_family_has_inverted_output_ddio;
end
endfunction //FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO

function IS_VALID_FAMILY;
    input[8*20:1] device;
    reg is_valid;
begin
    if (((device == "ACEX1K") || (device == "acex1k") || (device == "ACEX 1K") || (device == "acex 1k"))
    || ((device == "APEX20K") || (device == "apex20k") || (device == "APEX 20K") || (device == "apex 20k") || (device == "RAPHAEL") || (device == "raphael"))
    || ((device == "APEX20KC") || (device == "apex20kc") || (device == "APEX 20KC") || (device == "apex 20kc"))
    || ((device == "APEX20KE") || (device == "apex20ke") || (device == "APEX 20KE") || (device == "apex 20ke"))
    || ((device == "APEX II") || (device == "apex ii") || (device == "APEXII") || (device == "apexii") || (device == "APEX 20KF") || (device == "apex 20kf") || (device == "APEX20KF") || (device == "apex20kf"))
    || ((device == "EXCALIBUR_ARM") || (device == "excalibur_arm") || (device == "Excalibur ARM") || (device == "EXCALIBUR ARM") || (device == "excalibur arm") || (device == "ARM-BASED EXCALIBUR") || (device == "arm-based excalibur") || (device == "ARM_BASED_EXCALIBUR") || (device == "arm_based_excalibur"))
    || ((device == "FLEX10KE") || (device == "flex10ke") || (device == "FLEX 10KE") || (device == "flex 10ke"))
    || ((device == "FLEX10K") || (device == "flex10k") || (device == "FLEX 10K") || (device == "flex 10k"))
    || ((device == "FLEX10KA") || (device == "flex10ka") || (device == "FLEX 10KA") || (device == "flex 10ka"))
    || ((device == "FLEX6000") || (device == "flex6000") || (device == "FLEX 6000") || (device == "flex 6000") || (device == "FLEX6K") || (device == "flex6k"))
    || ((device == "MAX7000B") || (device == "max7000b") || (device == "MAX 7000B") || (device == "max 7000b"))
    || ((device == "MAX7000AE") || (device == "max7000ae") || (device == "MAX 7000AE") || (device == "max 7000ae"))
    || ((device == "MAX3000A") || (device == "max3000a") || (device == "MAX 3000A") || (device == "max 3000a"))
    || ((device == "MAX7000S") || (device == "max7000s") || (device == "MAX 7000S") || (device == "max 7000s"))
    || ((device == "MAX7000A") || (device == "max7000a") || (device == "MAX 7000A") || (device == "max 7000a"))
    || ((device == "Mercury") || (device == "MERCURY") || (device == "mercury") || (device == "DALI") || (device == "dali"))
    || ((device == "Stratix") || (device == "STRATIX") || (device == "stratix") || (device == "Yeager") || (device == "YEAGER") || (device == "yeager"))
    || ((device == "Stratix GX") || (device == "STRATIX GX") || (device == "stratix gx") || (device == "Stratix-GX") || (device == "STRATIX-GX") || (device == "stratix-gx") || (device == "StratixGX") || (device == "STRATIXGX") || (device == "stratixgx") || (device == "Aurora") || (device == "AURORA") || (device == "aurora"))
    || ((device == "Cyclone") || (device == "CYCLONE") || (device == "cyclone") || (device == "ACEX2K") || (device == "acex2k") || (device == "ACEX 2K") || (device == "acex 2k") || (device == "Tornado") || (device == "TORNADO") || (device == "tornado"))
    || ((device == "MAX II") || (device == "max ii") || (device == "MAXII") || (device == "maxii") || (device == "Tsunami") || (device == "TSUNAMI") || (device == "tsunami"))
    || ((device == "HardCopy Stratix") || (device == "HARDCOPY STRATIX") || (device == "hardcopy stratix") || (device == "Stratix HC") || (device == "STRATIX HC") || (device == "stratix hc") || (device == "StratixHC") || (device == "STRATIXHC") || (device == "stratixhc") || (device == "HardcopyStratix") || (device == "HARDCOPYSTRATIX") || (device == "hardcopystratix"))
    || ((device == "Stratix II") || (device == "STRATIX II") || (device == "stratix ii") || (device == "StratixII") || (device == "STRATIXII") || (device == "stratixii") || (device == "Armstrong") || (device == "ARMSTRONG") || (device == "armstrong"))
    || ((device == "Stratix II GX") || (device == "STRATIX II GX") || (device == "stratix ii gx") || (device == "StratixIIGX") || (device == "STRATIXIIGX") || (device == "stratixiigx"))
    || ((device == "Arria GX") || (device == "ARRIA GX") || (device == "arria gx") || (device == "ArriaGX") || (device == "ARRIAGX") || (device == "arriagx") || (device == "Stratix II GX Lite") || (device == "STRATIX II GX LITE") || (device == "stratix ii gx lite") || (device == "StratixIIGXLite") || (device == "STRATIXIIGXLITE") || (device == "stratixiigxlite"))
    || ((device == "Cyclone II") || (device == "CYCLONE II") || (device == "cyclone ii") || (device == "Cycloneii") || (device == "CYCLONEII") || (device == "cycloneii") || (device == "Magellan") || (device == "MAGELLAN") || (device == "magellan"))
    || ((device == "HardCopy II") || (device == "HARDCOPY II") || (device == "hardcopy ii") || (device == "HardCopyII") || (device == "HARDCOPYII") || (device == "hardcopyii") || (device == "Fusion") || (device == "FUSION") || (device == "fusion"))
    || ((device == "Stratix III") || (device == "STRATIX III") || (device == "stratix iii") || (device == "StratixIII") || (device == "STRATIXIII") || (device == "stratixiii") || (device == "Titan") || (device == "TITAN") || (device == "titan") || (device == "SIII") || (device == "siii"))
    || ((device == "Cyclone III") || (device == "CYCLONE III") || (device == "cyclone iii") || (device == "CycloneIII") || (device == "CYCLONEIII") || (device == "cycloneiii") || (device == "Barracuda") || (device == "BARRACUDA") || (device == "barracuda") || (device == "Cuda") || (device == "CUDA") || (device == "cuda") || (device == "CIII") || (device == "ciii"))
    || ((device == "Stratix IV") || (device == "STRATIX IV") || (device == "stratix iv") || (device == "TGX") || (device == "tgx") || (device == "StratixIV") || (device == "STRATIXIV") || (device == "stratixiv") || (device == "StratixIIIGX") || (device == "STRATIXIIIGX") || (device == "stratixiiigx") || (device == "Stratix IV (GT/GX/E)") || (device == "STRATIX IV (GT/GX/E)") || (device == "stratix iv (gt/gx/e)") || (device == "StratixIV(GT/GX/E)") || (device == "STRATIXIV(GT/GX/E)") || (device == "stratixiv(gt/gx/e)") || (device == "Stratix IV (GX/E)") || (device == "STRATIX IV (GX/E)") || (device == "stratix iv (gx/e)") || (device == "StratixIV(GX/E)") || (device == "STRATIXIV(GX/E)") || (device == "stratixiv(gx/e)"))
    || ((device == "Arria II GX") || (device == "ARRIA II GX") || (device == "arria ii gx") || (device == "ArriaIIGX") || (device == "ARRIAIIGX") || (device == "arriaiigx") || (device == "Arria IIGX") || (device == "ARRIA IIGX") || (device == "arria iigx") || (device == "ArriaII GX") || (device == "ARRIAII GX") || (device == "arriaii gx") || (device == "Arria II") || (device == "ARRIA II") || (device == "arria ii") || (device == "ArriaII") || (device == "ARRIAII") || (device == "arriaii") || (device == "Arria II (GX/E)") || (device == "ARRIA II (GX/E)") || (device == "arria ii (gx/e)") || (device == "ArriaII(GX/E)") || (device == "ARRIAII(GX/E)") || (device == "arriaii(gx/e)") || (device == "PIRANHA") || (device == "piranha"))
    || ((device == "HardCopy III") || (device == "HARDCOPY III") || (device == "hardcopy iii") || (device == "HardCopyIII") || (device == "HARDCOPYIII") || (device == "hardcopyiii") || (device == "HCX") || (device == "hcx"))
    || ((device == "HardCopy IV") || (device == "HARDCOPY IV") || (device == "hardcopy iv") || (device == "HardCopyIV") || (device == "HARDCOPYIV") || (device == "hardcopyiv") || (device == "HCXIV") || (device == "hcxiv") || (device == "HardCopy IV (GX/E)") || (device == "HARDCOPY IV (GX/E)") || (device == "hardcopy iv (gx/e)") || (device == "HardCopyIV(GX/E)") || (device == "HARDCOPYIV(GX/E)") || (device == "hardcopyiv(gx/e)"))
    || ((device == "Cyclone III LS") || (device == "CYCLONE III LS") || (device == "cyclone iii ls") || (device == "CycloneIIILS") || (device == "CYCLONEIIILS") || (device == "cycloneiiils") || (device == "Cyclone III LPS") || (device == "CYCLONE III LPS") || (device == "cyclone iii lps") || (device == "Cyclone LPS") || (device == "CYCLONE LPS") || (device == "cyclone lps") || (device == "CycloneLPS") || (device == "CYCLONELPS") || (device == "cyclonelps") || (device == "Tarpon") || (device == "TARPON") || (device == "tarpon") || (device == "Cyclone IIIE") || (device == "CYCLONE IIIE") || (device == "cyclone iiie")))
        is_valid = 1;
    else
        is_valid = 0;

    IS_VALID_FAMILY = is_valid;
end
endfunction // IS_VALID_FAMILY


endmodule // ALTERA_DEVICE_FAMILIES


// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

`define TRUE 1 
`define FALSE 0 
`define NULL 0
`define EOF -1
`define MAX_BUFFER_SZ   2048
`define MAX_NAME_SZ     256
`define MAX_WIDTH       256
`define COLON           ":"
`define DOT             "."
`define NEWLINE         "\n"
`define CARRIAGE_RETURN  8'h0D
`define SPACE           " "
`define TAB             "\t"
`define OPEN_BRACKET    "["
`define CLOSE_BRACKET   "]"
`define OFFSET          9
`define H10             8'h10
`define H10000          20'h10000
`define AWORD           8
`define MASK15          32'h000000FF
`define EXT_STR         "ver"
`define PERCENT         "%"
`define MINUS           "-"
`define SEMICOLON       ";"
`define EQUAL           "="

// MODULE DECLARATION
module ALTERA_MF_MEMORY_INITIALIZATION;

/****************************************************************/
/* convert uppercase character values to lowercase.             */
/****************************************************************/
function [8:1] tolower;
    input [8:1] given_character;
    reg [8:1] conv_char;

begin
    if ((given_character >= 65) && (given_character <= 90)) // ASCII number of 'A' is 65, 'Z' is 90
    begin
        conv_char = given_character + 32; // 32 is the difference in the position of 'A' and 'a' in the ASCII char set
        tolower = conv_char;
    end
    else
        tolower = given_character;    
end
endfunction
    
/****************************************************************/
/* Read in Altera-mif format data to verilog format data.       */
/****************************************************************/
task convert_mif2ver;
    input[`MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`MAX_NAME_SZ*8 : 1] out_file;
    reg [`MAX_NAME_SZ*8 : 1] in_file;
    reg [`MAX_NAME_SZ*8 : 1] out_file;
    reg [`MAX_NAME_SZ*8 : 1] buffer;
    reg [`MAX_WIDTH : 0] memory_data1, memory_data2;
    reg [8 : 1] c;
    reg [3 : 0] hex, tmp_char;
    reg [24 : 1] address_radix, data_radix;
    reg get_width;
    reg get_depth;
    reg get_data_radix;
    reg get_address_radix;
    reg width_found;
    reg depth_found;
    reg data_radix_found;
    reg address_radix_found;
    reg get_address_data_pairs;
    reg get_address;
    reg get_data;
    reg display_address;
    reg invalid_address;
    reg get_start_address;
    reg get_end_address;
    reg done;
    reg error_status;
    reg first_rec;
    reg last_rec;

    integer width;
    integer memory_width, memory_depth;
    integer value;
    integer ifp, ofp, r, r2;
    integer i, j, k, m, n;
    
    integer off_addr, nn, address, tt, cc, aah, aal, dd, sum ;
    integer start_address, end_address;
    integer line_no;
    integer character_count;
    integer comment_with_percent_found;
    integer comment_with_double_minus_found;

begin
`ifdef NO_PLI
`else
    `ifdef USE_RIF
    `else
        done = `FALSE;
        error_status = `FALSE;
        first_rec = `FALSE;
        last_rec = `FALSE;
        comment_with_percent_found = `FALSE;
        comment_with_double_minus_found = `FALSE;

        off_addr= 0;
        nn= 0;
        address = 0;
        start_address = 0;
        end_address = 0;
        tt= 0;
        cc= 0;
        aah= 0;
        aal= 0;
        dd= 0;
        sum = 0;
        line_no = 1;
        c = 0;
        hex = 0;
        value = 0;
        buffer = "";
        character_count = 0;
        memory_width = 0;
        memory_depth = 0;
        memory_data1 = {(`MAX_WIDTH+1) {1'b0}};
        memory_data2 = {(`MAX_WIDTH+1) {1'b0}};
        address_radix = "hex";
        data_radix = "hex";
        get_width = `FALSE;
        get_depth = `FALSE;
        get_data_radix = `FALSE;
        get_address_radix = `FALSE;
        width_found = `FALSE;
        depth_found = `FALSE;
        data_radix_found = `FALSE;
        address_radix_found = `FALSE;
        get_address_data_pairs = `FALSE;
        display_address = `FALSE;
        invalid_address = `FALSE;
        get_start_address = `FALSE;
        get_end_address = `FALSE;

        if((in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            out_file = in_file;
        else
        begin
            ifp = $fopen(in_file, "r");

            if (ifp == `NULL)
            begin
                $display("ERROR: cannot read %0s.", in_file);
                done = `TRUE;
            end
        
            out_file = in_file;
            
            if((out_file[4*8 : 1] == ".mif") || (out_file[4*8 : 1] == ".MIF"))
                out_file[3*8 : 1] = `EXT_STR;
            else
            begin
                $display("ERROR: Invalid input file name %0s. Expecting file with .mif extension and Altera-mif data format.", in_file);
                done = `TRUE;
            end

            if (!done)
            begin            
                ofp = $fopen(out_file, "w");

                if (ofp == `NULL)
                begin
                    $display("ERROR : cannot write %0s.", out_file);
                    done = `TRUE;
                end
            end
            
            while((!done) && (!error_status))
            begin : READER
 
                r = $fgetc(ifp);

                if (r == `EOF)
                begin
                // to do : add more checking on whether a particular assigment(width, depth, memory/address) are mising
                    if(!first_rec)
                    begin
                        error_status = `TRUE;
                        $display("WARNING: %0s, Intel-hex data file is empty.", in_file);
                    end
                    else if (!get_address_data_pairs)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                    end
                    else if(!last_rec)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Missing `end` statement.", in_file, line_no);
                    end
                    done = `TRUE;
                end
                else if ((r == `NEWLINE) || (r == `CARRIAGE_RETURN))
                begin                    
                    if ((buffer == "contentbegin") && (get_address_data_pairs == `FALSE))
                    begin
                        get_address_data_pairs = `TRUE;
                        get_address = `TRUE;
                        buffer = "";
                    end
                    else if (buffer == "content")
                    begin
                        // continue to next character
                    end
                    else
                    if (buffer != "")
                    begin
                        // found invalid syntax in the particular line.
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        disable READER;
                    end
                    line_no = line_no +1;
                    
                end
                else if ((r == `SPACE) || (r == `TAB))
                begin
                    // continue to next character;
                end
                else if (r == `PERCENT)
                begin
                    // Ignore all the characters which which is part of comment.
                    r = $fgetc(ifp);

                    while ((r != `PERCENT) && (r != `NEWLINE) && (r != `CARRIAGE_RETURN))
                    begin
                        r = $fgetc(ifp);                      
                    end

                    if ((r == `NEWLINE) || (r == `CARRIAGE_RETURN))
                    begin
                        line_no = line_no +1;

                        if ((buffer == "contentbegin") && (get_address_data_pairs == `FALSE))
                        begin
                            get_address_data_pairs = `TRUE;
                            get_address = `TRUE;
                            buffer = "";
                        end
                    end
                end
                else if (r == `MINUS)
                begin
                    r = $fgetc(ifp);
                    if (r == `MINUS)
                    begin
                        // Ignore all the characters which which is part of comment.
                        r = $fgetc(ifp);
    
                        while ((r != `NEWLINE) && (r != `CARRIAGE_RETURN))
                        begin
                            r = $fgetc(ifp);
                            
                        end
    
                        if ((r == `NEWLINE) || (r == `CARRIAGE_RETURN))
                        begin
                            line_no = line_no +1;

                            if ((buffer == "contentbegin") && (get_address_data_pairs == `FALSE))
                            begin
                                get_address_data_pairs = `TRUE;
                                get_address = `TRUE;
                                buffer = "";
                            end
                        end
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        done = `TRUE;
                        disable READER;
                    end
                end
                else if (r == `EQUAL)
                begin
                    if (buffer == "width")
                    begin
                        if (width_found == `FALSE)
                        begin
                            get_width = `TRUE;
                            buffer = "";
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Width has already been specified once.", in_file, line_no);
                        end
                    end
                    else if (buffer == "depth")
                    begin
                        get_depth = `TRUE;
                        buffer = ""; 
                    end
                    else if (buffer == "data_radix")
                    begin
                        get_data_radix = `TRUE;
                        buffer = "";
                    end
                    else if (buffer == "address_radix")
                    begin
                        get_address_radix = `TRUE;
                        buffer = "";
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Unknown setting (%0s).", in_file, line_no, buffer);
                    end
                end
                else if (r == `COLON)
                begin
                    if (!get_address_data_pairs)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                    end
                    else if (invalid_address == `TRUE)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                    end
                    begin
                        get_address = `FALSE;
                        get_data = `TRUE;
                        display_address = `TRUE;
                    end
                end
                else if (r == `DOT)
                begin
                    r = $fgetc(ifp);
                    if (r == `DOT)
                    begin
                        if (get_start_address == `TRUE)
                        begin
                            start_address = address;
                            address = 0; 
                            get_start_address = `FALSE;
                            get_end_address = `TRUE;
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        done = `TRUE;
                        disable READER;
                    end
                end
                else if (r == `OPEN_BRACKET)
                begin
                    get_start_address = `TRUE;
                end
                else if (r == `CLOSE_BRACKET)
                begin
                    if (get_end_address == `TRUE)
                    begin
                        end_address = address;
                        address = 0; 
                        get_end_address = `FALSE;
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        done = `TRUE;
                        disable READER;
                    end
                end                
                else if (r == `SEMICOLON)
                begin
                    if (get_width == `TRUE)
                    begin
                        width_found = `TRUE;
                        memory_width = value;
                        value = 0;
                        get_width = `FALSE;
                    end
                    else if (get_depth == `TRUE)
                    begin
                        depth_found = `TRUE;
                        memory_depth = value;
                        value = 0;
                        get_depth = `FALSE;
                    end
                    else if (get_data_radix == `TRUE)
                    begin
                        data_radix_found = `TRUE;
                        get_data_radix = `FALSE;

                        if ((buffer == "bin") || (buffer == "oct") || (buffer == "dec") || (buffer == "uns") ||
                            (buffer == "hex"))
                        begin
                            data_radix = buffer[24 : 1];
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid assignment (%0s) to data_radix.", in_file, line_no, buffer);
                        end
                        buffer = "";
                    end
                    else if (get_address_radix == `TRUE)
                    begin
                        address_radix_found = `TRUE;
                        get_address_radix = `FALSE;

                        if ((buffer == "bin") || (buffer == "oct") || (buffer == "dec") || (buffer == "uns") ||
                            (buffer == "hex"))
                        begin
                            address_radix = buffer[24 : 1];
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid assignment (%0s) to address radix.", in_file, line_no, buffer);
                        end
                        buffer = "";
                    end
                    else if (buffer == "end")
                    begin
                        if (get_address_data_pairs == `TRUE)
                        begin
                            last_rec = `TRUE;
                            buffer = "";
                        end
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                        end
                    end
                    else if (get_data == `TRUE)
                    begin
                        get_address = `TRUE;
                        get_data = `FALSE;
                        buffer = "";
                        character_count = 0;
                        
                        if (start_address != end_address)
                        begin
                            for (address = start_address; address <= end_address; address = address+1)
                            begin
                                $fdisplay(ofp,"@%0h", address);
                                
                                for (i = memory_width -1; i >= 0; i = i-1 )
                                begin
                                    hex[(i % 4)] =  memory_data1[i];
                                    
                                    if ((i % 4) == 0)
                                    begin
                                        $fwrite(ofp, "%0h", hex);
                                        hex = 0;
                                    end
                                end
        
                                $fwrite(ofp, "\n");
                            end
                            start_address = 0;
                            end_address = 0;
                            address = 0;
                            hex = 0;
                            memory_data1 = {(`MAX_WIDTH+1) {1'b0}};
                        end
                        else
                        begin
                            if (display_address == `TRUE)
                            begin
                                $fdisplay(ofp,"@%0h", address);
                                display_address = `FALSE;
                            end
                            
                            for (i = memory_width -1; i >= 0; i = i-1 )
                            begin
                                hex[(i % 4)] =  memory_data1[i];
                                
                                if ((i % 4) == 0)
                                begin
                                    $fwrite(ofp, "%0h", hex);
                                    hex = 0;
                                end
                            end
    
                            $fwrite(ofp, "\n");                      
                            address = 0;
                            hex = 0;
                            memory_data1 = {(`MAX_WIDTH+1) {1'b0}};
                        end
                    end
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid assigment.", in_file, line_no);
                    end
                end
                else if ((get_width == `TRUE) || (get_depth == `TRUE))
                begin
                    if ((r >= "0") && (r <= "9"))
                        value = (value * 10) + (r - 'h30);
                    else
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid assignment to width/depth.", in_file, line_no);
                    end
                end
                else if (get_address == `TRUE)
                begin
                    if (address_radix == "hex")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            value = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            value = 10 + (r - 'h61);
                        else
                        begin
                            invalid_address = `TRUE;
                        end
                            
                        address = (address * 16) + value;
                    end
                    else if ((address_radix == "dec"))
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `TRUE;
                        end
                            
                        address = (address * 10) + value;
                    end
                    else if (address_radix == "uns")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `TRUE;
                        end
                            
                        address = (address * 10) + value; 
                    end
                    else if (address_radix == "bin")
                    begin
                        if ((r >= "0") && (r <= "1"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `TRUE;
                        end
                            
                        address = (address * 2) + value;
                    end
                    else if (address_radix == "oct")
                    begin
                        if ((r >= "0") && (r <= "7"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `TRUE;
                        end
                            
                        address = (address * 8) + value;
                    end
                    
                    if ((r >= 65) && (r <= 90))
                        c = tolower(r); 
                    else
                        c = r;

                    {tmp_char,buffer} = {buffer, c};                    
                end
                else if (get_data == `TRUE)
                begin                    
                    character_count = character_count +1;

                    if (data_radix == "hex")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            value = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            value = 10 + (r - 'h61);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                            
                        memory_data1 = (memory_data1 * 16) + value;
                    end
                    else if ((data_radix == "dec"))
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                            
                        memory_data1 = (memory_data1 * 10) + value;
                    end
                    else if (data_radix == "uns")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                            
                        memory_data1 = (memory_data1 * 10) + value; 
                    end
                    else if (data_radix == "bin")
                    begin
                        if ((r >= "0") && (r <= "1"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                            
                        memory_data1 = (memory_data1 * 2) + value;
                    end
                    else if (data_radix == "oct")
                    begin
                        if ((r >= "0") && (r <= "7"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                            
                        memory_data1 = (memory_data1 * 8) + value;
                    end
                end
                else
                begin
                    first_rec = `TRUE;
                    
                    if ((r >= 65) && (r <= 90))
                        c = tolower(r); 
                    else
                        c = r;

                    {tmp_char,buffer} = {buffer, c};                    
                end
            end
            $fclose(ifp);
            $fclose(ofp);
        end
    `endif 
`endif    
end
endtask // convert_mif2ver

/****************************************************************/
/* Read in Intel-hex format data to verilog format data.        */
/*  Intel-hex format    :nnaaaaattddddcc                        */
/****************************************************************/
task convert_hex2ver;
    input[`MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`MAX_NAME_SZ*8 : 1] out_file;
    reg [`MAX_NAME_SZ*8 : 1] in_file;
    reg [`MAX_NAME_SZ*8 : 1] out_file;
    reg [8:1] c;
    reg [3:0] hex, tmp_char;
    reg done;
    reg error_status;
    reg first_rec;
    reg last_rec;
    reg first_normal_record;
    reg is_word_address_format;

    integer width;
    integer ifp, ofp, r, r2;
    integer i, j, k, m, n;
    
    integer off_addr, nn, aaaa, aaaa_pre, tt, cc, aah, aal, dd, sum ;
    integer line_no;
    integer divide_factor;

begin
`ifdef NO_PLI
`else
    `ifdef USE_RIF
    `else
        done = `FALSE;
        error_status = `FALSE;
        first_rec = `FALSE;
        last_rec = `FALSE;
        first_normal_record = `TRUE;
        is_word_address_format = `FALSE;
        off_addr= 0;
        nn= 0;
        aaaa= 0;
        aaaa_pre = 0;
        tt= 0;
        cc= 0;
        aah= 0;
        aal= 0;
        dd= 0;
        sum = 0;
        line_no = 1;
        c = 0;
        hex = 0;
        divide_factor = 1;

        if((in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            out_file = in_file;
        else
        begin
            ifp = $fopen(in_file, "r");
            if (ifp == `NULL)
            begin
                $display("ERROR: cannot read %0s.", in_file);
                done = `TRUE;
            end
        
            out_file = in_file;
            
            if((out_file[4*8 : 1] == ".hex") || (out_file[4*8 : 1] == ".HEX"))
                out_file[3*8 : 1] = `EXT_STR;
            else
            begin
                $display("ERROR: Invalid input file name %0s. Expecting file with .hex extension and Intel-hex data format.", in_file);
                done = `TRUE;
            end
            
            if (!done)
            begin            
                ofp = $fopen(out_file, "w");
                if (ofp == `NULL)
                begin
                    $display("ERROR : cannot write %0s.", out_file);
                    done = `TRUE;
                end
            end
            
            while((!done) && (!error_status))
            begin : READER
        
                r = $fgetc(ifp);
        
                if (r == `EOF)
                begin
                    if(!first_rec)
                    begin
                        error_status = `TRUE;
                        $display("WARNING: %0s, Intel-hex data file is empty.", in_file);
                    end
                    else if(!last_rec)
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Missing the last record.", in_file, line_no);
                    end
                end
                else if (r == `COLON)
                begin
                    first_rec = `TRUE;
                    nn= 0;
                    aaaa_pre = aaaa;
                    aaaa= 0;
                    tt= 0;
                    cc= 0;
                    aah= 0;
                    aal= 0;
                    dd= 0;
                    sum = 0;
        
                    // get record length bytes
                    for (i = 0; i < 2; i = i+1)
                    begin
                        r = $fgetc(ifp);
                        
                        if ((r >= "0") && (r <= "9"))
                            nn = (nn * 16) + (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            nn = (nn * 16) + 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            nn = (nn * 16) + 10 + (r - 'h61);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                    end
        
                    // get address bytes
                    for (i = 0; i < 4; i = i+1)
                    begin
                        r = $fgetc(ifp);
                        
                        if ((r >= "0") && (r <= "9"))
                            hex = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            hex = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            hex = 10 + (r - 'h61);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                        
                        aaaa = (aaaa * 16) + hex;
                        
                        if (i < 2)
                            aal = (aal * 16) + hex;
                        else
                            aah = (aah * 16) + hex;
                    end
                    
                    // get record type bytes   
                    for (i = 0; i < 2; i = i+1)
                    begin
                        r = $fgetc(ifp);
                        
                        if ((r >= "0") && (r <= "9"))
                            tt = (tt * 16) + (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            tt = (tt * 16) + 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            tt = (tt * 16) + 10 + (r - 'h61);
                        else
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            done = `TRUE;
                            disable READER;
                        end
                    end
        
                    if((tt == 2) && (nn != 2) )
                    begin
                        error_status = `TRUE;
                        $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                    end
                    else
                    begin
        
                        // get the sum of all the bytes for record length, address and record types
                        sum = nn + aah + aal + tt ; 
                   
                        // check the record type
                        case(tt)
                            // normal_record
                            8'h00 :
                            begin
                                first_rec = `TRUE;
                                i = 0;
                                k = width / `AWORD;
                                if ((width % `AWORD) != 0)
                                    k = k + 1; 
        
                                if ((first_normal_record == `FALSE) &&(aaaa != k))
                                    is_word_address_format = `TRUE;
                                
                                first_normal_record = `FALSE;

                                if ((aaaa == k) && (is_word_address_format == `FALSE))
                                    divide_factor = k;

                                // k = no. of bytes per entry.
                                while (i < nn)
                                begin
                                    $fdisplay(ofp,"@%0h", (aaaa + off_addr)/divide_factor);

                                    for (j = 1; j <= k; j = j +1)
                                    begin
                                        if ((k - j +1) > nn)
                                        begin
                                            for(m = 1; m <= 2; m= m+1)
                                            begin
                                                if((((k-j)*8) + ((3-m)*4) - width) < 4)
                                                    $fwrite(ofp, "0");
                                            end
                                        end
                                        else
                                        begin
                                            // get the data bytes
                                            for(m = 1; m <= 2; m= m+1)
                                            begin                    
                                                r = $fgetc(ifp);
                            
                                                if ((r >= "0") && (r <= "9"))
                                                    hex = (r - 'h30);
                                                else if ((r >= "A") && (r <= "F"))
                                                    hex = 10 + (r - 'h41);
                                                else if ((r >= "a") && (r <= "f"))
                                                    hex = 10 + (r - 'h61);
                                                else
                                                begin
                                                    error_status = `TRUE;
                                                    $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                                    done = `TRUE;
                                                    disable READER;
                                                end
            
                                                if((((k-j)*8) + ((3-m)*4) - width) < 4)
                                                    $fwrite(ofp, "%h", hex);
                                                dd = (dd * 16) + hex;
            
                                                if(m % 2 == 0)
                                                begin
                                                    sum = sum + dd;
                                                    dd = 0;
                                                end
                                            end
                                        end
                                    end
                                    $fwrite(ofp, "\n");
        
                                    i = i + k;
                                    aaaa = aaaa + 1;
                                end // end of while (i < nn)
                            end
                            // last record
                            8'h01: 
                            begin
                                last_rec = `TRUE;
                                done = `TRUE;
                            end
                            // address base record
                            8'h02:
                            begin
                                off_addr= 0;

                                // get the extended segment address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin                    
                                    r = $fgetc(ifp);
                
                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        done = `TRUE;
                                        disable READER;
                                    end
        
                                    off_addr = (off_addr * `H10) + hex;        
                                    dd = (dd * 16) + hex;
        
                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end
            
                                off_addr = off_addr * `H10;
                            end
                            // address base record
                            8'h03:
                                // get the start segment address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin                    
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        done = `TRUE;
                                        disable READER;
                                    end
                                    dd = (dd * 16) + hex;
        
                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end
                            // address base record
                            8'h04:
                            begin
                                off_addr= 0;

                                // get the extended linear address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin                    
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        done = `TRUE;
                                        disable READER;
                                    end
        
                                    off_addr = (off_addr * `H10) + hex;        
                                    dd = (dd * 16) + hex;
        
                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end
            
                                off_addr = off_addr * `H10000;
                            end
                            // address base record
                            8'h05:
                                // get the start linear address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin                    
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        done = `TRUE;
                                        disable READER;
                                    end
                                    dd = (dd * 16) + hex;
        
                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end
                            default:
                            begin
                                error_status = `TRUE;
                                $display("ERROR: %0s, line %0d, Unknown record type.", in_file, line_no);
                            end
                        endcase
                        
                        // get the checksum bytes
                        for (i = 0; i < 2; i = i+1)
                        begin
                            r = $fgetc(ifp);
                            
                            if ((r >= "0") && (r <= "9"))
                                cc = (cc * 16) + (r - 'h30);
                            else if ((r >= "A") && (r <= "F"))
                                cc = 10 + (cc * 16) + (r - 'h41);
                            else if ((r >= "a") && (r <= "f"))
                                cc = 10 + (cc * 16) + (r - 'h61);
                            else
                            begin
                                error_status = `TRUE;
                                $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                done = `TRUE;
                                disable READER;
                            end
                        end
                        
                        // Perform check sum.
                        if(((~sum+1)& `MASK15) != cc)
                        begin
                            error_status = `TRUE;
                            $display("ERROR: %0s, line %0d, Invalid checksum.", in_file, line_no);
                        end
                    end
                end
                else if ((r == `NEWLINE) || (r == `CARRIAGE_RETURN))
                begin
                    line_no = line_no +1;
                end
                else if (r == `SPACE)
                begin
                    // continue to next character;
                end
                else
                begin
                    error_status = `TRUE;
                    $display("ERROR:%0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                    done = `TRUE;
                end
            end
            $fclose(ifp);
            $fclose(ofp);
        end
    `endif 
`endif    
end
endtask // convert_hex2ver

task convert_to_ver_file;
    input[`MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`MAX_NAME_SZ*8 : 1] out_file;
    reg [`MAX_NAME_SZ*8 : 1] in_file;
    reg [`MAX_NAME_SZ*8 : 1] out_file;
    integer width;
begin    
           
        if((in_file[4*8 : 1] == ".hex") || (in_file[4*8 : 1] == ".HEX") ||
            (in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            convert_hex2ver(in_file, width, out_file);
        else if((in_file[4*8 : 1] == ".mif") || (in_file[4*8 : 1] == ".MIF"))
            convert_mif2ver(in_file, width, out_file);
        else
            $display("ERROR: Invalid input file name %0s. Expecting file with .hex extension (with Intel-hex data format) or .mif extension (with Altera-mif data format).", in_file);
end
endtask // convert_to_ver_file

endmodule // ALTERA_MF_MEMORY_INITIALIZATION
