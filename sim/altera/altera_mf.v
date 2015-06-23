// Copyright (C) 1991-2011 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.
// Quartus II 10.1 Build 197 11/29/2010


// VIRTUAL JTAG MODULE CONSTANTS

// the default bit length for time and value
`define DEFAULT_BIT_LENGTH 32

// the bit length for type
`define TYPE_BIT_LENGTH 4

// the bit length for delay time
`define TIME_BIT_LENGTH 64

// the number of selection bits + width of hub instructions(3)
`define NUM_SELECTION_BITS 4

// the states for the parser state machine
`define STARTSTATE    3'b000
`define LENGTHSTATE   3'b001
`define VALUESTATE    3'b011
`define TYPESTATE     3'b111
`define TIMESTATE     3'b101

`define V_DR_SCAN_TYPE 4'b0010
`define V_IR_SCAN_TYPE 4'b0001

// specify time scale, allowing JTAG to run at 1GHz against actual 10MHz
`define CLK_PERIOD 1000

`define DELAY_RESOLUTION 100

// the states for the tap controller state machine
`define TLR_ST  5'b00000
`define RTI_ST  5'b00001
`define DRS_ST  5'b00011
`define CDR_ST  5'b00111
`define SDR_ST  5'b01111
`define E1DR_ST 5'b01011
`define PDR_ST  5'b01101
`define E2DR_ST 5'b01000
`define UDR_ST  5'b01001
`define IRS_ST  5'b01100
`define CIR_ST  5'b01010
`define SIR_ST  5'b00101
`define E1IR_ST 5'b00100
`define PIR_ST  5'b00010
`define E2IR_ST 5'b00110
`define UIR_ST  5'b01110
`define INIT_ST 5'b10000

// usr1 instruction for tap controller
`define JTAG_USR1_INSTR 10'b0000001110


//START_MODULE_NAME------------------------------------------------------------
// Module Name         : signal_gen
//
// Description         : Simulates customizable actions on a JTAG input
//
// Limitation          : Zero is not a valid length and causes simulation to halt with
// an error message.
// Values with more bits than specified length will be truncated.
// Length for IR scans are ignored. They however should be factored in when
// calculating SLD_NODE_TOTAl_LENGTH.                  
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module signal_gen (tck,tms,tdi,jtag_usr1,tdo);

    
    // GLOBAL PARAMETER DECLARATION
    parameter sld_node_ir_width = 1;
    parameter sld_node_n_scan = 0;
    parameter sld_node_total_length = 0;
    parameter sld_node_sim_action = "()";

    // INPUT PORTS
    input     jtag_usr1;
    input     tdo;
    
    // OUTPUT PORTS
    output    tck;
    output    tms;
    output    tdi;
    
    // CONSTANT DECLARATIONS
`define DECODED_SCANS_LENGTH (sld_node_total_length + ((sld_node_n_scan * `DEFAULT_BIT_LENGTH) * 2) + (sld_node_n_scan * `TYPE_BIT_LENGTH) - 1)
`define DEFAULT_SCAN_LENGTH (sld_node_n_scan * `DEFAULT_BIT_LENGTH)
`define TYPE_SCAN_LENGTH (sld_node_n_scan * `TYPE_BIT_LENGTH) - 1
    
    // INTEGER DECLARATION
    integer   char_idx;       // character_loop index
    integer   value_idx;      // decoding value index
    integer   value_idx_old;  // previous decoding value index   
    integer   value_idx_cur;  // reading/outputing value index   
    integer   length_idx;     // decoding length index
    integer   length_idx_old; // previous decoding length index
    integer   length_idx_cur; // reading/outputing length index
    integer   last_length_idx;// decoding previous length index
    integer   type_idx;       // decoding type index
    integer   type_idx_old;   // previous decoding type index
    integer   type_idx_cur;   // reading/outputing type index
    integer   time_idx;       // decoding time index
    integer   time_idx_old;   // previous decoding time index
    integer   time_idx_cur;   // reading/outputing time index

    // REGISTERS         
    reg [ `DEFAULT_SCAN_LENGTH - 1 : 0 ]    scan_length;
    // register for the 32-bit length values
    reg [ sld_node_total_length  - 1 : 0 ]  scan_values;
    // register for values   
    reg [ `TYPE_SCAN_LENGTH : 0 ]           scan_type;
    // register for 4-bit type 
    reg [ `DEFAULT_SCAN_LENGTH - 1 : 0 ]    scan_time;
    // register to hold time values
    reg [15 : 0]                            two_character; 
    // two ascii characters. Used in decoding
    reg [2 : 0]                             c_state;
    // the current state register 
    reg [3 : 0]                             hex_value;
    // temporary value to hold hex value of ascii character
    reg [31 : 0]                             last_length;
    // register to hold the previous length value read
    reg                                     tms_reg;
    // register to hold tms value before its clocked
    reg                                     tdi_reg;
    // register to hold tdi vale before its clocked
    
    // OUTPUT REGISTERS
    reg    tms;
    reg    tck;
    reg    tdi;

    // input registers
    
    // LOCAL TIME DECLARATION
    
    // FUNCTION DECLARATION
    
    // hexToBits - takes in a hexadecimal character and 
    // returns the 4-bit value of the character.
    // Returns 0 if character is not a hexadeciaml character    
    function [3 : 0]  hexToBits;
        input [7 : 0] character;
        begin
            case ( character )
                "0" : hexToBits = 4'b0000;
                "1" : hexToBits = 4'b0001;
                "2" : hexToBits = 4'b0010;
                "3" : hexToBits = 4'b0011;
                "4" : hexToBits = 4'b0100;
                "5" : hexToBits = 4'b0101;
                "6" : hexToBits = 4'b0110;                    
                "7" : hexToBits = 4'b0111;
                "8" : hexToBits = 4'b1000;
                "9" : hexToBits = 4'b1001;
                "A" : hexToBits = 4'b1010;
                "a" : hexToBits = 4'b1010;
                "B" : hexToBits = 4'b1011;
                "b" : hexToBits = 4'b1011;
                "C" : hexToBits = 4'b1100;
                "c" : hexToBits = 4'b1100;          
                "D" : hexToBits = 4'b1101;
                "d" : hexToBits = 4'b1101;
                "E" : hexToBits = 4'b1110;
                "e" : hexToBits = 4'b1110;
                "F" : hexToBits = 4'b1111;
                "f" : hexToBits = 4'b1111;          
                default :
                    begin 
                        hexToBits = 4'b0000;
                        $display("%s is not a hexadecimal value",character);
                    end
            endcase        
        end
    endfunction
    
    // TASK DECLARATIONS
    
    // clocks tck 
    task clock_tck;
        input in_tms;
        input in_tdi;    
        begin : clock_tck_tsk
            #(`CLK_PERIOD/2) tck <= ~tck;
            tms <= in_tms;
            tdi <= in_tdi;        
            #(`CLK_PERIOD/2) tck <= ~tck;
        end // clock_tck_tsk
    endtask // clock_tck
    
    // move tap controller from dr/ir shift state to ir/dr update state    
    task goto_update_state;
        begin : goto_update_state_tsk
            // get into e1(i/d)r state 
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into u(i/d)r state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);        
        end // goto_update_state_tsk
    endtask // goto_update_state
    
    // resets the jtag TAP controller by holding tms high 
    // for 6 tck cycles
    task reset_jtag;    
        integer idx;    
        begin
            for (idx = 0; idx < 6; idx= idx + 1)
                begin
                    tms_reg = 1'b1;          
                    clock_tck(tms_reg,tdi_reg);
                end
            // get into rti state
            tms_reg = 1'b0;        
            clock_tck(tms_reg,tdi_reg);
            jtag_ir_usr1;        
        end
    endtask // reset_jtag
    
    // sends a jtag_usr0 intsruction
    task jtag_ir_usr0;
        integer i;    
        begin : jtag_ir_usr0_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into irs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // shift in data i.e usr0 instruction
            // usr1 = 0x0E = 0b00 0000 1100
            for ( i = 0; i < 2; i = i + 1)
                begin :ir_usr0_loop1          
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop1
            for ( i = 0; i < 2; i = i + 1)
                begin :ir_usr0_loop2          
                    tdi_reg = 1'b1;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop2
            // done with 1100
            for ( i = 0; i < 6; i = i + 1)
                begin :ir_usr0_loop3
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop3
            // done  with 00 0000
            // get into e1ir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);        
            // get into uir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);        
        end // jtag_ir_usr0_tsk
    endtask // jtag_ir_usr0

    // sends a jtag_usr1 intsruction
    task jtag_ir_usr1;
        integer i;    
        begin : jtag_ir_usr1_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into irs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // shift in data i.e usr1 instruction
            // usr1 = 0x0E = 0b00 0000 1110
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            for ( i = 0; i < 3; i = i + 1)
                begin :ir_usr1_loop1          
                    tdi_reg = 1'b1;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr1_loop1
            // done with 1110
            for ( i = 0; i < 5; i = i + 1)
                begin :ir_usr1_loop2
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_sur1_loop2
            tdi_reg = 1'b0;
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // done  with 00 0000
            // now in e1ir state
            // get into uir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
        end // jtag_ir_usr1_tsk
    endtask // jtag_ir_usr1
    
    // sends a force_ir_capture instruction to the node
    task send_force_ir_capture;
        integer i;    
        begin : send_force_ir_capture_tsk
            goto_dr_shift_state;
            // start shifting in the instruction
            tdi_reg = 1'b1;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            tdi_reg = 1'b1;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // done with 011
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // done with select bit
            // fill up with zeros up to ir_width
            for ( i = 0; i < sld_node_ir_width - 4; i = i + 1 )
                begin
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end
            goto_update_state;        
        end // send_force_ir_capture_tsk    
    endtask // send_forse_ir_capture
    
    // puts the JTAG tap controller in DR shift state
    task goto_dr_shift_state;
        begin : goto_dr_shift_state_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cdr state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sdr state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);        
        end // goto_dr_shift_state_tsk    
    endtask // goto_dr_shift_state
    
    // performs a virtual_ir_scan
    task v_ir_scan;
        input [`DEFAULT_BIT_LENGTH - 1 : 0] length;    
        integer i;    
        begin : v_ir_scan_tsk
            // if we are not in usr1 then go to usr1 state
            if (jtag_usr1 == 1'b0)      
                begin
                    jtag_ir_usr1;
                end
            // send force_ir_capture
            send_force_ir_capture;
            // shift in the ir value
            goto_dr_shift_state;
            value_idx_cur = value_idx_cur - length;        
            for ( i = 0; i < length; i = i + 1)
                begin
                    tms_reg = 1'b0;
                    tdi_reg = scan_values[value_idx_cur + i];        
                    clock_tck(tms_reg,tdi_reg);
                end
            // pad with zeros if necessary
            for(i = length; i < sld_node_ir_width; i = i + 1)
                begin : zero_padding
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);          
                end //zero_padding
            tdi_reg = 1'b1;
            goto_update_state;
        end // v_ir_scan_tsk 
    endtask // v_ir_scan

    // performs a virtual dr scan
    task v_dr_scan;
        input [`DEFAULT_BIT_LENGTH - 1 : 0] length;    
        integer                             i;    
        begin : v_dr_scan_tsk
            // if we are in usr1 then go to usr0 state
            if (jtag_usr1 == 1'b1)      
                begin
                    jtag_ir_usr0;
                end
            // shift in the dr value
            goto_dr_shift_state;
            value_idx_cur = value_idx_cur - length;        
            for ( i = 0; i < length - 1; i = i + 1)
                begin
                    tms_reg = 1'b0;
                    tdi_reg = scan_values[value_idx_cur + i];
                    clock_tck(tms_reg,tdi_reg);
                end
            // last bit is clocked together with state transition
            tdi_reg = scan_values[value_idx_cur + i];        
            goto_update_state;
        end // v_dr_scan_tsk
    endtask // v_dr_scan
    
    reg vj_sim_done;
    initial 
        begin : sim_model      
       	    vj_sim_done = 0;
            // initialize output registers
            tck = 1'b1;
            tms = 1'b0;
            tdi = 1'b0;      
            // initialize variables
            tms_reg = 1'b0;
            tdi_reg = 1'b0;      
            two_character = 'b0;
            last_length_idx = 0;      
            value_idx = 0;      
            value_idx_old = 0;      
            length_idx = 0;      
            length_idx_old = 0;
            type_idx = 0;
            type_idx_old = 0;
            time_idx = 0;
            time_idx_old = 0;      
            scan_length = 'b0;
            scan_values = 'b0;
            scan_type = 'b0;
            scan_time = 'b0;      
            last_length = 'b0;
            hex_value = 'b0;
            c_state = `STARTSTATE;      
            // initialize current indices
            value_idx_cur = sld_node_total_length;
            type_idx_cur = `TYPE_SCAN_LENGTH;
            time_idx_cur = `DEFAULT_SCAN_LENGTH;
            length_idx_cur = `DEFAULT_SCAN_LENGTH;      
            for(char_idx = 0;two_character != "((";char_idx = char_idx + 8)
                begin : character_loop
                    // convert two characters to equivalent 16-bit value
                    two_character[0]  = sld_node_sim_action[char_idx];
                    two_character[1]  = sld_node_sim_action[char_idx+1];
                    two_character[2]  = sld_node_sim_action[char_idx+2];
                    two_character[3]  = sld_node_sim_action[char_idx+3];
                    two_character[4]  = sld_node_sim_action[char_idx+4];
                    two_character[5]  = sld_node_sim_action[char_idx+5];
                    two_character[6]  = sld_node_sim_action[char_idx+6];
                    two_character[7]  = sld_node_sim_action[char_idx+7];
                    two_character[8]  = sld_node_sim_action[char_idx+8];
                    two_character[9]  = sld_node_sim_action[char_idx+9];
                    two_character[10] = sld_node_sim_action[char_idx+10];
                    two_character[11] = sld_node_sim_action[char_idx+11];
                    two_character[12] = sld_node_sim_action[char_idx+12];
                    two_character[13] = sld_node_sim_action[char_idx+13];
                    two_character[14] = sld_node_sim_action[char_idx+14];
                    two_character[15] = sld_node_sim_action[char_idx+15];        
                    // use state machine to decode
                    case (c_state)
                        `STARTSTATE :
                            begin 
                                if (two_character[15 : 8] != ")")
                                    begin 
                                        c_state = `LENGTHSTATE;
                                    end
                            end 
                        `LENGTHSTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        length_idx = length_idx_old + 32;              
                                        length_idx_old = length_idx;              
                                        c_state = `VALUESTATE;
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_length [ length_idx] = hex_value[0];
                                        scan_length [ length_idx + 1] = hex_value[1];
                                        scan_length [ length_idx + 2] = hex_value[2];
                                        scan_length [ length_idx + 3] = hex_value[3];              
                                        last_length [ last_length_idx] = hex_value[0];
                                        last_length [ last_length_idx + 1] = hex_value[1];
                                        last_length [ last_length_idx + 2] = hex_value[2];
                                        last_length [ last_length_idx + 3] = hex_value[3];              
                                        length_idx = length_idx + 4;
                                        last_length_idx = last_length_idx + 4;              
                                    end
                            end
                        `VALUESTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        value_idx = value_idx_old + last_length;
                                        value_idx_old = value_idx;              
                                        last_length = 'b0; // reset the last length value
                                        last_length_idx = 0; // reset index for length                
                                        c_state = `TYPESTATE;  
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_values [ value_idx] = hex_value[0];
                                        scan_values [ value_idx + 1] = hex_value[1];
                                        scan_values [ value_idx + 2] = hex_value[2];
                                        scan_values [ value_idx + 3] = hex_value[3];              
                                        value_idx = value_idx + 4;              
                                    end
                            end
                        `TYPESTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        type_idx = type_idx + 4;              
                                        c_state = `TIMESTATE;              
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_type [ type_idx] = hex_value[0];
                                        scan_type [ type_idx + 1] = hex_value[1];
                                        scan_type [ type_idx + 2] = hex_value[2];
                                        scan_type [ type_idx + 3] = hex_value[3];
                                    end
                            end
                        `TIMESTATE :
                            begin 
                                if (two_character[7 : 0] == "(")
                                    begin
                                        time_idx = time_idx_old + 32;
                                        time_idx_old = time_idx;              
                                        c_state = `STARTSTATE;
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_time [ time_idx] = hex_value[0];
                                        scan_time [ time_idx + 1] = hex_value[1];
                                        scan_time [ time_idx + 2] = hex_value[2];
                                        scan_time [ time_idx + 3] = hex_value[3];
                                        time_idx = time_idx + 4;              
                                    end
                            end
                        default :
                            c_state = `STARTSTATE;          
                    endcase
                end // block: character_loop             
            # (`CLK_PERIOD/2);
            begin : execute
                integer write_scan_idx;    
                integer tempLength_idx;          
                reg [`TYPE_BIT_LENGTH - 1 : 0] tempType;        
                reg [`DEFAULT_BIT_LENGTH - 1 : 0 ] tempLength;                    
                reg [`DEFAULT_BIT_LENGTH - 1 : 0 ] tempTime;
                reg [`TIME_BIT_LENGTH - 1 : 0 ] delayTime;                    
                reset_jtag;
                for (write_scan_idx = 0; write_scan_idx < sld_node_n_scan; write_scan_idx = write_scan_idx + 1)
                    begin : all_scans_loop
                        tempType[3] = scan_type[type_idx_cur];
                        tempType[2] = scan_type[type_idx_cur - 1];
                        tempType[1] = scan_type[type_idx_cur - 2];
                        tempType[0] = scan_type[type_idx_cur - 3];
                        time_idx_cur = time_idx_cur - `DEFAULT_BIT_LENGTH;            
                        length_idx_cur = length_idx_cur - `DEFAULT_BIT_LENGTH;
                        for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                            begin : get_scan_time
                                tempTime[tempLength_idx] = scan_time[time_idx_cur + tempLength_idx];                
                            end // get_scan_time
                            delayTime =(`DELAY_RESOLUTION * `CLK_PERIOD * tempTime);
                            # delayTime;            
                        if (tempType == `V_IR_SCAN_TYPE)
                            begin
                                for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                                    begin : ir_get_length
                                        tempLength[tempLength_idx] = scan_length[length_idx_cur + tempLength_idx];                
                                    end // ir_get_length
                                v_ir_scan(tempLength);
                            end 
                        else
                            begin
                                if (tempType == `V_DR_SCAN_TYPE)
                                    begin                
                                        for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                                            begin : dr_get_length
                                                tempLength[tempLength_idx] = scan_length[length_idx_cur + tempLength_idx];                
                                            end // dr_get_length
                                        v_dr_scan(tempLength);
                                    end
                                else
                                    begin
                                        $display("Invalid scan type");
                                    end
                            end
                        type_idx_cur = type_idx_cur - 4;
                    end // all_scans_loop            
                //get into tlr state
                for (tempLength_idx = 0; tempLength_idx < 6; tempLength_idx= tempLength_idx + 1)
                    begin
                        tms_reg = 1'b1;          
                        clock_tck(tms_reg,tdi_reg);
                    end
            end //execute 
       	    vj_sim_done = 1;
        end // block: sim_model     
endmodule // signal_gen

// END OF MODULE



//START_MODULE_NAME------------------------------------------------------------
// Module Name         : jtag_tap_controller
//
// Description         : Behavioral model of JTAG tap controller with state signals
//
// Limitation          :  Can only decode USER1 and USER0 instructions
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module jtag_tap_controller (tck,tms,tdi,jtag_tdo,tdo,jtag_tck,jtag_tms,jtag_tdi,
                            jtag_state_tlr,jtag_state_rti,jtag_state_drs,jtag_state_cdr,
                            jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                            jtag_state_udr,jtag_state_irs,jtag_state_cir,jtag_state_sir,
                            jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                            jtag_usr1);


    // GLOBAL PARAMETER DECLARATION
    parameter ir_register_width = 16;

    // INPUT PORTS
    input     tck;  // tck signal from signal_gen
    input     tms;  // tms signal from signal_gen
    input     tdi;  // tdi signal from signal_gen
    input     jtag_tdo; // tdo signal from hub

    // OUTPUT PORTS
    output    tdo;  // tdo signal to signal_gen
    output    jtag_tck;  // tck signal from jtag
    output    jtag_tms;  // tms signal from jtag
    output    jtag_tdi;  // tdi signal from jtag
    output    jtag_state_tlr;   // tlr state
    output    jtag_state_rti;   // rti state
    output    jtag_state_drs;   // select dr scan state    
    output    jtag_state_cdr;   // capture dr state
    output    jtag_state_sdr;   // shift dr state    
    output    jtag_state_e1dr;  // exit1 dr state
    output    jtag_state_pdr;   // pause dr state
    output    jtag_state_e2dr;  // exit2 dr state 
    output    jtag_state_udr;   // update dr state
    output    jtag_state_irs;   // select ir scan state
    output    jtag_state_cir;   // capture ir state
    output    jtag_state_sir;   // shift ir state
    output    jtag_state_e1ir;  // exit1 ir state
    output    jtag_state_pir;   // pause ir state
    output    jtag_state_e2ir;  // exit2 ir state    
    output    jtag_state_uir;   // update ir state
    output    jtag_usr1;        // jtag has usr1 instruction

    // INTERNAL REGISTERS

    reg       tdo_reg;
    // temporary tdo output register
    reg       tdo_rom_reg;
    // temporary register used to generate 0101... during SIR_ST
    reg       jtag_usr1_reg;
    // temporary jtag_usr1 register
    reg       jtag_reset_i;
    // internal reset
    reg [ 4 : 0 ] cState;
    // register for current state
    reg [ 4 : 0 ] nState;
    // register for the next state signal
    reg [ ir_register_width - 1 : 0] ir_srl;
    // the ir shift register
    reg [ ir_register_width - 1 : 0] ir_srl_hold;
    // the ir shift register
    
    // INTERNAL WIRES
    wire [ 4 : 0 ] cState_tmp;
    wire [ ir_register_width - 1 : 0] ir_srl_tmp;


    // OUTPUT REGISTERS
    reg   jtag_state_tlr;   // tlr state
    reg   jtag_state_rti;   // rti state
    reg   jtag_state_drs;   // select dr scan state    
    reg   jtag_state_cdr;   // capture dr state
    reg   jtag_state_sdr;   // shift dr state    
    reg   jtag_state_e1dr;  // exit1 dr state
    reg   jtag_state_pdr;   // pause dr state
    reg   jtag_state_e2dr;  // exit2 dr state 
    reg   jtag_state_udr;   // update dr state
    reg   jtag_state_irs;   // select ir scan state
    reg   jtag_state_cir;   // capture ir state
    reg   jtag_state_sir;   // shift ir state
    reg   jtag_state_e1ir;  // exit1 ir state
    reg   jtag_state_pir;   // pause ir state
    reg   jtag_state_e2ir;  // exit2 ir state    
    reg   jtag_state_uir;   // update ir state
    

    // INITIAL STATEMENTS    
    initial
        begin
            // initialize state registers
            cState = `INIT_ST;
            nState = `TLR_ST;      
        end 

    // State Register block
    always @ (posedge tck or posedge jtag_reset_i)
        begin : stateReg
            if (jtag_reset_i)
                begin
                    cState <= `TLR_ST;
                    ir_srl <= 'b0;
                    tdo_reg <= 1'b0;
                    tdo_rom_reg <= 1'b0;
                    jtag_usr1_reg <= 1'b0;        
                end
            else
                begin
                    // in capture ir, set-up tdo_rom_reg
                    // to generate 010101...
                    if(cState_tmp == `CIR_ST)
                        begin                    
                            tdo_rom_reg <= 1'b0;
                        end
                    else
                        begin
                            // write to shift register else pipe
                            if (cState_tmp == `SIR_ST)
                                begin
                                    tdo_rom_reg <= ~tdo_rom_reg;
                                    tdo_reg <= tdo_rom_reg;              
                                    ir_srl <= ir_srl_tmp >> 1;
                                    ir_srl[ir_register_width - 1] <= tdi;
                                end
                            else
                                begin
                                    tdo_reg <= jtag_tdo;
                                end
                        end
                    // check if in usr1 state
                    if (cState_tmp == `UIR_ST)
                        begin
                            if (ir_srl_hold == `JTAG_USR1_INSTR)
                                begin
                                    jtag_usr1_reg <= 1'b1;                
                                end
                            else
                                begin
                                    jtag_usr1_reg <= 1'b0;
                                end              
                        end
                    cState <= nState;
                end
        end // stateReg               

    // hold register
    always @ (negedge tck or posedge jtag_reset_i)
        begin : holdReg
            if (jtag_reset_i)
                begin
                    ir_srl_hold <= 'b0;        
                end
            else
                begin
                    if (cState == `E1IR_ST)
                        begin
                            ir_srl_hold <= ir_srl;
                        end
                end
        end // holdReg               

    // next state logic
    always @(cState or tms)
        begin : stateTrans
            nState = cState;
            case (cState)
                `TLR_ST :
                    begin
                        if (tms == 1'b0)
                            begin
                                nState = `RTI_ST;
                                jtag_reset_i = 1'b0;
                            end
                        else
                            begin
                                jtag_reset_i = 1'b1;            
                            end
                    end
                `RTI_ST :
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end          
                    end
                `DRS_ST :
                    begin
                        if (tms)
                            begin
                                nState = `IRS_ST;
                            end
                        else
                            begin
                                nState = `CDR_ST;
                            end
                    end
                `CDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1DR_ST;
                            end
                        else
                            begin
                                nState = `SDR_ST;
                            end
                    end
                `SDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1DR_ST;
                            end
                    end
                `E1DR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UDR_ST;
                            end
                        else
                            begin
                                nState = `PDR_ST;
                            end
                    end
                `PDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E2DR_ST;
                            end
                    end
                `E2DR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UDR_ST;
                            end
                        else
                            begin
                                nState = `SDR_ST;
                            end
                    end
                `UDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end
                        else
                            begin
                                nState = `RTI_ST;
                            end
                    end          
                `IRS_ST :
                    begin
                        if (tms)
                            begin
                                nState = `TLR_ST;
                            end
                        else
                            begin
                                nState = `CIR_ST;
                            end
                    end
                `CIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1IR_ST;
                            end
                        else
                            begin
                                nState = `SIR_ST;
                            end
                    end
                `SIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1IR_ST;
                            end
                    end
                `E1IR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UIR_ST;
                            end
                        else
                            begin
                                nState = `PIR_ST;
                            end
                    end
                `PIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E2IR_ST;
                            end
                    end
                `E2IR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UIR_ST;
                            end
                        else
                            begin
                                nState = `SIR_ST;
                            end
                    end
                `UIR_ST : 
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end
                        else
                            begin
                                nState = `RTI_ST;
                            end
                    end
                `INIT_ST :
                    begin
                        nState = `TLR_ST;
                    end
                default :
                    begin
                        $display("Tap Controller State machine error");
                        $display ("Time: %0t  Instance: %m", $time);
                        nState = `TLR_ST;          
                    end
            endcase
        end // stateTrans

    // Output logic
    always @ (cState)
        begin : output_logic
            jtag_state_tlr <= 1'b0;  
            jtag_state_rti <= 1'b0;  
            jtag_state_drs <= 1'b0;  
            jtag_state_cdr <= 1'b0;  
            jtag_state_sdr <= 1'b0;  
            jtag_state_e1dr <= 1'b0; 
            jtag_state_pdr <= 1'b0;  
            jtag_state_e2dr <= 1'b0; 
            jtag_state_udr <= 1'b0;  
            jtag_state_irs <= 1'b0;  
            jtag_state_cir <= 1'b0;  
            jtag_state_sir <= 1'b0;  
            jtag_state_e1ir <= 1'b0; 
            jtag_state_pir <= 1'b0;  
            jtag_state_e2ir <= 1'b0; 
            jtag_state_uir <= 1'b0;  
            case (cState)
                `TLR_ST :
                    begin
                        jtag_state_tlr <= 1'b1;
                    end
                `RTI_ST :
                    begin
                        jtag_state_rti <= 1'b1;
                    end
                `DRS_ST :
                    begin
                        jtag_state_drs <= 1'b1;
                    end
                `CDR_ST :
                    begin
                        jtag_state_cdr <= 1'b1;
                    end
                `SDR_ST :
                    begin
                        jtag_state_sdr <= 1'b1;
                    end
                `E1DR_ST :
                    begin
                        jtag_state_e1dr <= 1'b1;
                    end
                `PDR_ST :
                    begin
                        jtag_state_pdr <= 1'b1;
                    end
                `E2DR_ST :
                    begin
                        jtag_state_e2dr <= 1'b1;
                    end
                `UDR_ST :
                    begin
                        jtag_state_udr <= 1'b1;
                    end
                `IRS_ST :
                    begin
                        jtag_state_irs <= 1'b1;
                    end
                `CIR_ST :
                    begin
                        jtag_state_cir <= 1'b1;
                    end
                `SIR_ST :
                    begin
                        jtag_state_sir <= 1'b1;
                    end
                `E1IR_ST :
                    begin
                        jtag_state_e1ir <= 1'b1;
                    end
                `PIR_ST :
                    begin
                        jtag_state_pir <= 1'b1;
                    end
                `E2IR_ST :
                    begin
                        jtag_state_e2ir <= 1'b1;
                    end
                `UIR_ST :
                    begin
                        jtag_state_uir <= 1'b1;
                    end
                default :
                    begin
                        $display("Tap Controller State machine output error");
                        $display ("Time: %0t  Instance: %m", $time);
                    end
            endcase
        end // output_logic
    // temporary values
    assign ir_srl_tmp = ir_srl;
    assign cState_tmp = cState;    

    // Pipe through signals
    assign tdo = tdo_reg;
    assign jtag_tck = tck;
    assign jtag_tdi = tdi;
    assign jtag_tms = tms;
    assign jtag_usr1 = jtag_usr1_reg;
    
endmodule
// END OF MODULE


    
//START_MODULE_NAME------------------------------------------------------------
// Module Name         : dummy_hub
//
// Description         : Acts as node and mux between the tap controller and
// user design. Generates hub signals
//
// Limitation          : Assumes only one node. Ignores user input on tdo and ir_out.
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION

module dummy_hub (jtag_tck,jtag_tdi,jtag_tms,jtag_usr1,jtag_state_tlr,jtag_state_rti,
                    jtag_state_drs,jtag_state_cdr,jtag_state_sdr,jtag_state_e1dr,
                    jtag_state_pdr,jtag_state_e2dr,jtag_state_udr,jtag_state_irs,
                    jtag_state_cir,jtag_state_sir,jtag_state_e1ir,jtag_state_pir,
                    jtag_state_e2ir,jtag_state_uir,dummy_tdo,virtual_ir_out,
                    jtag_tdo,dummy_tck,dummy_tdi,dummy_tms,dummy_state_tlr,
                    dummy_state_rti,dummy_state_drs,dummy_state_cdr,dummy_state_sdr,
                    dummy_state_e1dr,dummy_state_pdr,dummy_state_e2dr,dummy_state_udr,
                    dummy_state_irs,dummy_state_cir,dummy_state_sir,dummy_state_e1ir,
                    dummy_state_pir,dummy_state_e2ir,dummy_state_uir,virtual_state_cdr,
                    virtual_state_sdr,virtual_state_e1dr,virtual_state_pdr,virtual_state_e2dr,
                    virtual_state_udr,virtual_state_cir,virtual_state_uir,virtual_ir_in);


    // GLOBAL PARAMETER DECLARATION
    parameter sld_node_ir_width = 16;

    // INPUT PORTS
    
    input   jtag_tck;       // tck signal from tap controller
    input   jtag_tdi;       // tdi signal from tap controller
    input   jtag_tms;       // tms signal from tap controller
    input   jtag_usr1;      // usr1 signal from tap controller
    input   jtag_state_tlr; // tlr state signal from tap controller
    input   jtag_state_rti; // rti state signal from tap controller
    input   jtag_state_drs; // drs state signal from tap controller
    input   jtag_state_cdr; // cdr state signal from tap controller
    input   jtag_state_sdr; // sdr state signal from tap controller
    input   jtag_state_e1dr;// e1dr state signal from tap controller
    input   jtag_state_pdr; // pdr state signal from tap controller
    input   jtag_state_e2dr;// esdr state signal from tap controller
    input   jtag_state_udr; // udr state signal from tap controller
    input   jtag_state_irs; // irs state signal from tap controller
    input   jtag_state_cir; // cir state signals from tap controller
    input   jtag_state_sir; // sir state signal from tap controller
    input   jtag_state_e1ir;// e1ir state signal from tap controller
    input   jtag_state_pir; // pir state signals from tap controller
    input   jtag_state_e2ir;// e2ir state signal from tap controller
    input   jtag_state_uir; // uir state signal from tap controller
    input   dummy_tdo;      // tdo signal from world
    input [sld_node_ir_width - 1 : 0] virtual_ir_out; // captures parallel input from

    // OUTPUT PORTS
    output   jtag_tdo;             // tdo signal to tap controller
    output   dummy_tck;           // tck signal to world
    output   dummy_tdi;           // tdi signal to world
    output   dummy_tms;           // tms signal to world
    output   dummy_state_tlr;     // tlr state signal to world
    output   dummy_state_rti;     // rti state signal to world
    output   dummy_state_drs;     // drs state signal to world
    output   dummy_state_cdr;     // cdr state signal to world
    output   dummy_state_sdr;     // sdr state signal to world
    output   dummy_state_e1dr;    // e1dr state signal to the world
    output   dummy_state_pdr;     // pdr state signal to world
    output   dummy_state_e2dr;    // e2dr state signal to world
    output   dummy_state_udr;     // udr state signal to world
    output   dummy_state_irs;     // irs state signal to world
    output   dummy_state_cir;    // cir state signal to world
    output   dummy_state_sir;    // sir state signal to world
    output   dummy_state_e1ir;   // e1ir state signal to world
    output   dummy_state_pir;    // pir state signal to world
    output   dummy_state_e2ir;   // e2ir state signal to world
    output   dummy_state_uir;    // uir state signal to world
    output   virtual_state_cdr;  // virtual cdr state signal
    output   virtual_state_sdr;  // virtual sdr state signal
    output   virtual_state_e1dr; // virtual e1dr state signal 
    output   virtual_state_pdr;  // virtula pdr state signal 
    output   virtual_state_e2dr; // virtual e2dr state signal 
    output   virtual_state_udr;  // virtual udr state signal
    output   virtual_state_cir;  // virtual cir state signal 
    output   virtual_state_uir;  // virtual uir state signal
    output [sld_node_ir_width - 1 : 0] virtual_ir_in;      // parallel output to user design


`define SLD_NODE_IR_WIDTH_I sld_node_ir_width + `NUM_SELECTION_BITS // internal ir width    
   
    // INTERNAL REGISTERS
    reg   capture_ir;    // signals force_ir_capture instruction
    reg   jtag_tdo_reg;  // register for jtag_tdo
    reg   dummy_tdi_reg; // register for dummy_tdi
    reg   dummy_tck_reg; // register for dummy_tck.
    reg  [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl; // ir shift register
    wire [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl_tmp; // ir shift register
    reg  [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl_hold; //hold register for ir shift register  

    // OUTPUT REGISTERS
    reg [sld_node_ir_width - 1 : 0]     virtual_ir_in;     
    
    // INITIAL STATEMENTS 
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : simulation_logic
            if (jtag_state_tlr) // asynchronous active high reset
                begin : active_hi_async_reset
                    ir_srl <= 'b0;
                    jtag_tdo_reg <= 1'b0;
                    dummy_tdi_reg <= 1'b0;        
                end  // active_hi_async_reset
            else
                begin : rising_edge_jtag_tck
                    // logic for shifting in data and piping data through        
                    // logic for muxing inputs to outputs and otherwise
                    if (jtag_usr1 && jtag_state_sdr)
                        begin : shift_in_out_usr1              
                            jtag_tdo_reg <= ir_srl_tmp[0];
                            ir_srl <= ir_srl_tmp >> 1;
                            ir_srl[`SLD_NODE_IR_WIDTH_I - 1] <= jtag_tdi;
                        end // shift_in_out_usr1
                    else
                        begin
                            if (capture_ir && jtag_state_cdr)
                                begin : capture_virtual_ir_out
                                    ir_srl[`SLD_NODE_IR_WIDTH_I - 2 : `NUM_SELECTION_BITS - 1] <= virtual_ir_out;
                                end // capture_virtual_ir_out
                            else
                                begin
                                    if (capture_ir && jtag_state_sdr)
                                        begin : shift_in_out_usr0                
                                            jtag_tdo_reg <= ir_srl_tmp[0];
                                            ir_srl <= ir_srl_tmp >> 1;
                                            ir_srl[`SLD_NODE_IR_WIDTH_I - 1] <= jtag_tdi;
                                        end // shift_in_out_usr0
                                    else
                                        begin
                                            if (jtag_state_sdr)
                                                begin : pipe_through
                                                    dummy_tdi_reg <= jtag_tdi;
                                                    jtag_tdo_reg <= dummy_tdo;
                                                end // pipe_through
                                        end
                                end
                        end                          
                end // rising_edge_jtag_tck
        end // simulation_logic

    // always block for writing to capture_ir
    // stops nlint from complaining.
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : capture_ir_logic
            if (jtag_state_tlr) // asynchronous active high reset
                begin : active_hi_async_reset
                    capture_ir <= 1'b0;
                end  // active_hi_async_reset
            else
                begin : rising_edge_jtag_tck
                    // should check for 011 instruction
                    // but we know that it is the only instruction ever sent to the
                    // hub. So all we have to do is check the selection bit and udr
                    // and usr1 state
                    // logic for capture_ir signal
                    if (jtag_state_udr && (ir_srl[`SLD_NODE_IR_WIDTH_I - 1] == 1'b0))
                        begin
                            capture_ir <= jtag_usr1;
                        end
                    else
                        begin
                            if (jtag_state_e1dr)
                                begin
                                    capture_ir <= 1'b0;
                                end
                        end
                end  // rising_edge_jtag_tck
        end // capture_ir_logic
    
    // outputs -  rising edge of clock  
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : parallel_ir_out
            if (jtag_state_tlr)
                begin : active_hi_async_reset
                    virtual_ir_in <= 'b0;
                end
            else
                begin : rising_edge_jtag_tck
                    virtual_ir_in <= ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 2 : `NUM_SELECTION_BITS - 1];
                end
        end
    
    // outputs -  falling edge of clock, separated for clarity
    always @ (negedge jtag_tck or posedge jtag_state_tlr)
        begin : shift_reg_hold
            if (jtag_state_tlr)
                begin : active_hi_async_reset
                    ir_srl_hold <= 'b0;
                end
            else
                begin
                    if (ir_srl[`SLD_NODE_IR_WIDTH_I - 1] && jtag_state_e1dr)
                        begin
                            ir_srl_hold <= ir_srl;
                        end
                end
        end // shift_reg_hold

    // generate tck in sync with tdi
    always @ (posedge jtag_tck or negedge jtag_tck)
        begin : gen_tck
            dummy_tck_reg <= jtag_tck;
        end // gen_tck
    // temporary signals    
    assign ir_srl_tmp = ir_srl;
    
    // Pipe through signals
    assign dummy_state_tlr    = jtag_state_tlr;
    assign dummy_state_rti    = jtag_state_rti;
    assign dummy_state_drs    = jtag_state_drs;
    assign dummy_state_cdr    = jtag_state_cdr;
    assign dummy_state_sdr    = jtag_state_sdr;
    assign dummy_state_e1dr   = jtag_state_e1dr;
    assign dummy_state_pdr    = jtag_state_pdr;
    assign dummy_state_e2dr   = jtag_state_e2dr;
    assign dummy_state_udr    = jtag_state_udr;
    assign dummy_state_irs    = jtag_state_irs;
    assign dummy_state_cir    = jtag_state_cir;
    assign dummy_state_sir    = jtag_state_sir;
    assign dummy_state_e1ir   = jtag_state_e1ir;
    assign dummy_state_pir    = jtag_state_pir;
    assign dummy_state_e2ir   = jtag_state_e2ir;
    assign dummy_state_uir    = jtag_state_uir;
    assign dummy_tms          = jtag_tms;


    // Virtual signals
    assign virtual_state_uir  = jtag_usr1 && jtag_state_udr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_cir  = jtag_usr1 && jtag_state_cdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_udr  = (! jtag_usr1) && jtag_state_udr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_e2dr = (! jtag_usr1) && jtag_state_e2dr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_pdr  = (! jtag_usr1) && jtag_state_pdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_e1dr = (! jtag_usr1) && jtag_state_e1dr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_sdr  = (! jtag_usr1) && jtag_state_sdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_cdr  = (! jtag_usr1) && jtag_state_cdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];

    // registered output
    assign jtag_tdo = jtag_tdo_reg;              
    assign dummy_tdi = dummy_tdi_reg;    
    assign dummy_tck = dummy_tck_reg;
    
endmodule
// END OF MODULE


//START_MODULE_NAME------------------------------------------------------------
// Module Name         : sld_virtual_jtag
//
// Description         : Simulation model for SLD_VIRTUAL_JTAG megafunction
//
// Limitation          : None
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps
`define IR_REGISTER_WIDTH 10;


// MODULE DECLARATION
module sld_virtual_jtag (tdo,ir_out,tck,tdi,ir_in,virtual_state_cdr,virtual_state_sdr,
                        virtual_state_e1dr,virtual_state_pdr,virtual_state_e2dr,
                        virtual_state_udr,virtual_state_cir,virtual_state_uir,
                        jtag_state_tlr,jtag_state_rti,jtag_state_sdrs,jtag_state_cdr,
                        jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                        jtag_state_udr,jtag_state_sirs,jtag_state_cir,jtag_state_sir,
                        jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                        tms);


    // GLOBAL PARAMETER DECLARATION    
    parameter lpm_type = "SLD_VIRTUAL_JTAG"; // required by coding standard
    parameter lpm_hint = "SLD_VIRTUAL_JTAG"; // required by coding standard
    parameter sld_auto_instance_index = "NO"; //Yes if auto index is desired and no otherwise
    parameter sld_instance_index = 0; // index to be used if SLD_AUTO_INDEX is no
    parameter sld_ir_width = 1; //the width of the IR register
    parameter sld_sim_n_scan = 0; // the number of scans in the simulatiom parameters
    parameter sld_sim_total_length = 0; // The total bit width of all scan values
    parameter sld_sim_action = ""; // the actions to be simulated

    // local parameter declaration
    defparam  user_input.sld_node_ir_width = sld_ir_width;
    defparam  user_input.sld_node_n_scan = sld_sim_n_scan;
    defparam  user_input.sld_node_total_length = sld_sim_total_length;
    defparam  user_input.sld_node_sim_action = sld_sim_action;
    defparam  jtag.ir_register_width = 10 ;  // compilation fails if defined constant is used
    defparam  hub.sld_node_ir_width = sld_ir_width;
    
    
    // INPUT PORTS DECLARATION
    input   tdo;  // tdo signal into megafunction
    input [sld_ir_width - 1 : 0] ir_out;// parallel ir data into megafunction

    // OUTPUT PORTS DECLARATION
    output   tck;  // tck signal from megafunction
    output   tdi;  // tdi signal from megafunction
    output   virtual_state_cdr; // cdr state signal of megafunction
    output   virtual_state_sdr; // sdr state signal of megafunction
    output   virtual_state_e1dr;//  e1dr state signal of megafunction
    output   virtual_state_pdr; // pdr state signal of megafunction
    output   virtual_state_e2dr;// e2dr state signal of megafunction
    output   virtual_state_udr; // udr state signal of megafunction
    output   virtual_state_cir; // cir state signal of megafunction
    output   virtual_state_uir; // uir state signal of megafunction
    output   jtag_state_tlr;    // Test, Logic, Reset state
    output   jtag_state_rti;    // Run, Test, Idle state 
    output   jtag_state_sdrs;   // Select DR scan state
    output   jtag_state_cdr;    // capture DR state
    output   jtag_state_sdr;    // Shift DR state 
    output   jtag_state_e1dr;   // exit 1 dr state
    output   jtag_state_pdr;    // pause dr state 
    output   jtag_state_e2dr;   // exit 2 dr state
    output   jtag_state_udr;    // update dr state 
    output   jtag_state_sirs;   // Select IR scan state
    output   jtag_state_cir;    // capture IR state
    output   jtag_state_sir;    // shift IR state 
    output   jtag_state_e1ir;   // exit 1 IR state
    output   jtag_state_pir;    // pause IR state
    output   jtag_state_e2ir;   // exit 2 IR state 
    output   jtag_state_uir;    // update IR state
    output   tms;               // tms signal
    output [sld_ir_width - 1 : 0] ir_in; // paraller ir data from megafunction    

    // connecting wires
    wire   tck_i;
    wire   tms_i;
    wire   tdi_i;
    wire   jtag_usr1_i;
    wire   tdo_i;
    wire   jtag_tdo_i;
    wire   jtag_tck_i;
    wire   jtag_tms_i;
    wire   jtag_tdi_i;
    wire   jtag_state_tlr_i;
    wire   jtag_state_rti_i;
    wire   jtag_state_drs_i;
    wire   jtag_state_cdr_i;
    wire   jtag_state_sdr_i;
    wire   jtag_state_e1dr_i;
    wire   jtag_state_pdr_i;
    wire   jtag_state_e2dr_i;
    wire   jtag_state_udr_i;
    wire   jtag_state_irs_i;
    wire   jtag_state_cir_i;
    wire   jtag_state_sir_i;
    wire   jtag_state_e1ir_i;
    wire   jtag_state_pir_i;
    wire   jtag_state_e2ir_i;
    wire   jtag_state_uir_i;
    
    
    // COMPONENT INSTANTIATIONS 
    // generates input to jtag controller
    signal_gen user_input (tck_i,tms_i,tdi_i,jtag_usr1_i,tdo_i);

    // the JTAG TAP controller
    jtag_tap_controller jtag (tck_i,tms_i,tdi_i,jtag_tdo_i,
                                tdo_i,jtag_tck_i,jtag_tms_i,jtag_tdi_i,
                                jtag_state_tlr_i,jtag_state_rti_i,
                                jtag_state_drs_i,jtag_state_cdr_i,
                                jtag_state_sdr_i,jtag_state_e1dr_i,
                                jtag_state_pdr_i,jtag_state_e2dr_i,
                                jtag_state_udr_i,jtag_state_irs_i,
                                jtag_state_cir_i,jtag_state_sir_i,
                                jtag_state_e1ir_i,jtag_state_pir_i,
                                jtag_state_e2ir_i,jtag_state_uir_i,
                                jtag_usr1_i);

    // the HUB 
    dummy_hub hub (jtag_tck_i,jtag_tdi_i,jtag_tms_i,jtag_usr1_i,
                    jtag_state_tlr_i,jtag_state_rti_i,jtag_state_drs_i,
                    jtag_state_cdr_i,jtag_state_sdr_i,jtag_state_e1dr_i,
                    jtag_state_pdr_i,jtag_state_e2dr_i,jtag_state_udr_i,
                    jtag_state_irs_i,jtag_state_cir_i,jtag_state_sir_i,
                    jtag_state_e1ir_i,jtag_state_pir_i,jtag_state_e2ir_i,
                    jtag_state_uir_i,tdo,ir_out,jtag_tdo_i,tck,tdi,tms,
                    jtag_state_tlr,jtag_state_rti,jtag_state_sdrs,jtag_state_cdr,
                    jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                    jtag_state_udr,jtag_state_sirs,jtag_state_cir,jtag_state_sir,
                    jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                    virtual_state_cdr,virtual_state_sdr,virtual_state_e1dr,
                    virtual_state_pdr,virtual_state_e2dr,virtual_state_udr,
                    virtual_state_cir,virtual_state_uir,ir_in);

endmodule
// END OF MODULE



//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  scfifo
//
// Description     :  Single Clock FIFO
//
// Limitation      :  
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module scfifo ( data, 
                clock, 
                wrreq, 
                rdreq, 
                aclr, 
                sclr,
                q, 
                usedw, 
                full, 
                empty, 
                almost_full, 
                almost_empty);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width               = 1;
    parameter lpm_widthu              = 1;
    parameter lpm_numwords            = 2;
    parameter lpm_showahead           = "OFF";
    parameter lpm_type                = "scfifo";
    parameter lpm_hint                = "USE_EAB=ON";
    parameter intended_device_family  = "Stratix";
    parameter underflow_checking      = "ON";
    parameter overflow_checking       = "ON";
    parameter allow_rwcycle_when_full = "OFF";
    parameter use_eab                 = "ON";
    parameter add_ram_output_register = "OFF";
    parameter almost_full_value       = 0;
    parameter almost_empty_value      = 0;
    parameter maximum_depth           = 0;    

// LOCAL_PARAMETERS_BEGIN

    parameter showahead_area          = ((lpm_showahead == "ON")  && (add_ram_output_register == "OFF"));
    parameter showahead_speed         = ((lpm_showahead == "ON")  && (add_ram_output_register == "ON"));
    parameter legacy_speed            = ((lpm_showahead == "OFF") && (add_ram_output_register == "ON"));

// LOCAL_PARAMETERS_END

// INPUT PORT DECLARATION
    input  [lpm_width-1:0] data;
    input  clock;
    input  wrreq;
    input  rdreq;
    input  aclr;
    input  sclr;

// OUTPUT PORT DECLARATION
    output [lpm_width-1:0] q;
    output [lpm_widthu-1:0] usedw;
    output full;
    output empty;
    output almost_full;
    output almost_empty;

// INTERNAL REGISTERS DECLARATION
    reg [lpm_width-1:0] mem_data [(1<<lpm_widthu):0];
    reg [lpm_widthu-1:0] count_id;
    reg [lpm_widthu-1:0] read_id;
    reg [lpm_widthu-1:0] write_id;
    
    wire valid_rreq;
    reg valid_wreq;
    reg write_flag;
    reg full_flag;
    reg empty_flag;
    reg almost_full_flag;
    reg almost_empty_flag;
    reg [lpm_width-1:0] tmp_q;
    reg stratix_family;
    reg set_q_to_x;
    reg set_q_to_x_by_empty;

    reg [lpm_widthu-1:0] write_latency1; 
    reg [lpm_widthu-1:0] write_latency2; 
    reg [lpm_widthu-1:0] write_latency3; 
    integer wrt_count;
        
    reg empty_latency1; 
    reg empty_latency2; 
    
    reg [(1<<lpm_widthu)-1:0] data_ready;
    reg [(1<<lpm_widthu)-1:0] data_shown;
    
// INTERNAL TRI DECLARATION
    tri0 aclr;

// LOCAL INTEGER DECLARATION
    integer i;

// COMPONENT INSTANTIATIONS
    ALTERA_DEVICE_FAMILIES dev ();

// INITIAL CONSTRUCT BLOCK
    initial
    begin

        stratix_family = (dev.FEATURE_FAMILY_STRATIX(intended_device_family));    
        if (lpm_width <= 0)
        begin
            $display ("Error! LPM_WIDTH must be greater than 0.");
            $display ("Time: %0t  Instance: %m", $time);
        end
        if ((lpm_widthu !=1) && (lpm_numwords > (1 << lpm_widthu)))
        begin
            $display ("Error! LPM_NUMWORDS must equal to the ceiling of log2(LPM_WIDTHU).");
            $display ("Time: %0t  Instance: %m", $time);
        end
        if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
        begin
            $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end
        if((add_ram_output_register != "ON") && (add_ram_output_register != "OFF"))
        begin
            $display ("Error! add_ram_output_register must be ON or OFF.");          
            $display ("Time: %0t  Instance: %m", $time);
        end         
        for (i = 0; i < (1<<lpm_widthu); i = i + 1)
        begin
            if (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family))
                mem_data[i] <= {lpm_width{1'b0}};
            else if (dev.FEATURE_FAMILY_STRATIX(intended_device_family))
            begin
                if ((add_ram_output_register == "ON") || (use_eab == "OFF"))
                    mem_data[i] <= {lpm_width{1'b0}};
                else
                    mem_data[i] <= {lpm_width{1'bx}};
            end
            else
                mem_data[i] <= {lpm_width{1'b0}};
        end

        if (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family))
            tmp_q <= {lpm_width{1'b0}};
        else if (dev.FEATURE_FAMILY_STRATIX(intended_device_family))
        begin
            if ((add_ram_output_register == "ON") || (use_eab == "OFF"))
                tmp_q <= {lpm_width{1'b0}};
            else    
                tmp_q <= {lpm_width{1'bx}};
        end
        else
            tmp_q <= {lpm_width{1'b0}};
            
        write_flag <= 1'b0;
        count_id <= 0;
        read_id <= 0;
        write_id <= 0;
        full_flag <= 1'b0;
        empty_flag <= 1'b1;
        empty_latency1 <= 1'b1; 
        empty_latency2 <= 1'b1;                 
        set_q_to_x <= 1'b0;
        set_q_to_x_by_empty <= 1'b0;
        wrt_count <= 0;        

        if (almost_full_value == 0)
            almost_full_flag <= 1'b1;
        else
            almost_full_flag <= 1'b0;

        if (almost_empty_value == 0)
            almost_empty_flag <= 1'b0;
        else
            almost_empty_flag <= 1'b1;
    end

    assign valid_rreq = (underflow_checking == "OFF")? rdreq : (rdreq && ~empty_flag);

    always @(wrreq or rdreq or full_flag)
    begin
        if (overflow_checking == "OFF")
            valid_wreq = wrreq;
        else if (allow_rwcycle_when_full == "ON")
                valid_wreq = wrreq && (!full_flag || rdreq);
        else
            valid_wreq = wrreq && !full_flag;
    end

    always @(posedge clock or posedge aclr)
    begin        
        if (aclr)
        begin
            if (add_ram_output_register == "ON")
                tmp_q <= {lpm_width{1'b0}};
            else if ((lpm_showahead == "ON") && (use_eab == "ON"))
            begin
                tmp_q <= {lpm_width{1'bX}};
            end
            else
            begin
                if (!stratix_family)
                begin
                    tmp_q <= {lpm_width{1'b0}};
                end
                else
                    tmp_q <= {lpm_width{1'bX}};
            end

            read_id <= 0;
            count_id <= 0;
            full_flag <= 1'b0;
            empty_flag <= 1'b1;
            empty_latency1 <= 1'b1; 
            empty_latency2 <= 1'b1;
            set_q_to_x <= 1'b0;
            set_q_to_x_by_empty <= 1'b0;
            wrt_count <= 0;
            
            if (almost_full_value > 0)
                almost_full_flag <= 1'b0;
            if (almost_empty_value > 0)
                almost_empty_flag <= 1'b1;

            write_id <= 0;
            
            if ((use_eab == "ON") && (stratix_family) && ((showahead_speed) || (showahead_area) || (legacy_speed)))
            begin
                write_latency1 <= 1'bx;
                write_latency2 <= 1'bx;
                data_shown <= {lpm_width{1'b0}};
                if (add_ram_output_register == "ON")
                    tmp_q <= {lpm_width{1'b0}};
                else
                    tmp_q <= {lpm_width{1'bX}};
            end            
        end
        else
        begin
            if (sclr)
            begin
                if (add_ram_output_register == "ON")
                    tmp_q <= {lpm_width{1'b0}};
                else
                    tmp_q <= {lpm_width{1'bX}};

                read_id <= 0;
                count_id <= 0;
                full_flag <= 1'b0;
                empty_flag <= 1'b1;
                empty_latency1 <= 1'b1; 
                empty_latency2 <= 1'b1;
                set_q_to_x <= 1'b0;
                set_q_to_x_by_empty <= 1'b0;
                wrt_count <= 0;

                if (almost_full_value > 0)
                    almost_full_flag <= 1'b0;
                if (almost_empty_value > 0)
                    almost_empty_flag <= 1'b1;

                if (!stratix_family)
                begin
                    if (valid_wreq)
                    begin
                        write_flag <= 1'b1;
                    end
                    else
                        write_id <= 0;
                end
                else
                begin
                    write_id <= 0;
                end

                if ((use_eab == "ON") && (stratix_family) && ((showahead_speed) || (showahead_area) || (legacy_speed)))
                begin
                    write_latency1 <= 1'bx;
                    write_latency2 <= 1'bx;
                    data_shown <= {lpm_width{1'b0}};                    
                    if (add_ram_output_register == "ON")
                        tmp_q <= {lpm_width{1'b0}};
                    else
                        tmp_q <= {lpm_width{1'bX}};
                end            
            end
            else 
            begin
                //READ operation    
                if (valid_rreq)
                begin
                    if (!(set_q_to_x || set_q_to_x_by_empty))
                    begin  
                        if (!valid_wreq)
                            wrt_count <= wrt_count - 1;

                        if (!valid_wreq)
                        begin
                            full_flag <= 1'b0;

                            if (count_id <= 0)
                                count_id <= {lpm_widthu{1'b1}};
                            else
                                count_id <= count_id - 1;
                        end                

                        if ((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area || legacy_speed))
                        begin
                            if ((wrt_count == 1 && valid_rreq && !valid_wreq) || ((wrt_count == 1 ) && valid_wreq && valid_rreq))
                            begin
                                empty_flag <= 1'b1;
                            end
                            else
                            begin
                                if (showahead_speed)
                                begin
                                    if (data_shown[write_latency2] == 1'b0)
                                    begin
                                        empty_flag <= 1'b1;
                                    end
                                end
                                else if (showahead_area || legacy_speed)
                                begin
                                    if (data_shown[write_latency1] == 1'b0)
                                    begin
                                        empty_flag <= 1'b1;
                                    end
                                end
                            end
                        end
                        else
                        begin
                            if (!valid_wreq)
                            begin
                                if ((count_id == 1) && !(full_flag))
                                    empty_flag <= 1'b1;
                            end
                        end

                        if (empty_flag)
                        begin
                            if (underflow_checking == "ON")
                            begin
                                if ((use_eab == "OFF") || (!stratix_family))
                                    tmp_q <= {lpm_width{1'b0}};
                            end
                            else
                            begin
                                set_q_to_x_by_empty <= 1'b1;
                                $display ("Warning : Underflow occurred! Fifo output is unknown until the next reset is asserted.");
                                $display ("Time: %0t  Instance: %m", $time);
                            end
                        end
                        else if (read_id >= ((1<<lpm_widthu) - 1))
                        begin
                            if (lpm_showahead == "ON")
                            begin
                                if ((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area))                        
                                begin
                                    if (showahead_speed)
                                    begin
                                        if ((write_latency2 == 0) || (data_ready[0] == 1'b1))
                                        begin
                                            if (data_shown[0] == 1'b1)
                                            begin
                                                tmp_q <= mem_data[0];
                                                data_shown[0] <= 1'b0;
                                                data_ready[0] <= 1'b0;
                                            end
                                        end
                                    end
                                    else
                                    begin
                                        if ((count_id == 1) && !(full_flag))
                                        begin
                                            if (underflow_checking == "ON")
                                            begin
                                                if ((use_eab == "OFF") || (!stratix_family))
                                                    tmp_q <= {lpm_width{1'b0}};
                                            end
                                            else
                                                tmp_q <= {lpm_width{1'bX}};
                                        end
                                        else if ((write_latency1 == 0) || (data_ready[0] == 1'b1))
                                        begin
                                            if (data_shown[0] == 1'b1)
                                            begin
                                                tmp_q <= mem_data[0];
                                                data_shown[0] <= 1'b0;
                                                data_ready[0] <= 1'b0;
                                            end
                                        end                            
                                    end
                                end
                                else
                                begin
                                    if ((count_id == 1) && !(full_flag))
                                    begin
                                        if (valid_wreq)
                                            tmp_q <= data;
                                        else
                                            if (underflow_checking == "ON")
                                            begin
                                                if ((use_eab == "OFF") || (!stratix_family))
                                                    tmp_q <= {lpm_width{1'b0}};
                                            end
                                            else
                                                tmp_q <= {lpm_width{1'bX}};
                                    end 
                                    else
                                        tmp_q <= mem_data[0];
                                end
                            end
                            else
                            begin
                                if ((use_eab == "ON") && stratix_family && legacy_speed)
                                begin
                                    if ((write_latency1 == read_id) || (data_ready[read_id] == 1'b1))
                                    begin
                                        if (data_shown[read_id] == 1'b1)
                                        begin
                                            tmp_q <= mem_data[read_id];
                                            data_shown[read_id] <= 1'b0;
                                            data_ready[read_id] <= 1'b0;
                                        end
                                    end
                                    else
                                    begin
                                        tmp_q <= {lpm_width{1'bX}};
                                    end                                  
                                end
                                else
                                    tmp_q <= mem_data[read_id];
                            end

                            read_id <= 0;
                        end // end if (read_id >= ((1<<lpm_widthu) - 1))
                        else
                        begin
                            if (lpm_showahead == "ON")
                            begin
                                if ((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area))
                                begin
                                    if (showahead_speed)
                                    begin
                                        if ((write_latency2 == read_id+1) || (data_ready[read_id+1] == 1'b1))
                                        begin
                                            if (data_shown[read_id+1] == 1'b1)
                                            begin
                                                tmp_q <= mem_data[read_id + 1];
                                                data_shown[read_id+1] <= 1'b0;
                                                data_ready[read_id+1] <= 1'b0;
                                            end
                                        end
                                    end
                                    else
                                    begin
                                        if ((count_id == 1) && !(full_flag))
                                        begin
                                            if (underflow_checking == "ON")
                                            begin
                                                if ((use_eab == "OFF") || (!stratix_family))
                                                    tmp_q <= {lpm_width{1'b0}};
                                            end
                                            else
                                                tmp_q <= {lpm_width{1'bX}};
                                        end
                                        else if ((write_latency1 == read_id+1) || (data_ready[read_id+1] == 1'b1))
                                        begin
                                            if (data_shown[read_id+1] == 1'b1)
                                            begin
                                                tmp_q <= mem_data[read_id + 1];
                                                data_shown[read_id+1] <= 1'b0;
                                                data_ready[read_id+1] <= 1'b0;
                                            end
                                        end
                                    end
                                end
                                else
                                begin
                                    if ((count_id == 1) && !(full_flag))
                                    begin
                                        if ((use_eab == "OFF") && stratix_family)
                                        begin
                                            if (valid_wreq)
                                            begin
                                                tmp_q <= data;
                                            end
                                            else
                                            begin
                                                if (underflow_checking == "ON")
                                                begin
                                                    if ((use_eab == "OFF") || (!stratix_family))
                                                        tmp_q <= {lpm_width{1'b0}};
                                                end
                                                else
                                                    tmp_q <= {lpm_width{1'bX}};
                                            end
                                        end
                                        else
                                        begin
                                            tmp_q <= {lpm_width{1'bX}};
                                        end
                                    end
                                    else
                                        tmp_q <= mem_data[read_id + 1];
                                end
                            end
                            else
                            begin
                                if ((use_eab == "ON") && stratix_family && legacy_speed)
                                begin
                                    if ((write_latency1 == read_id) || (data_ready[read_id] == 1'b1))
                                    begin
                                        if (data_shown[read_id] == 1'b1)
                                        begin
                                            tmp_q <= mem_data[read_id];
                                            data_shown[read_id] <= 1'b0;
                                            data_ready[read_id] <= 1'b0;
                                        end
                                    end
                                    else
                                    begin
                                        tmp_q <= {lpm_width{1'bX}};
                                    end                                
                                end
                                else
                                    tmp_q <= mem_data[read_id];
                            end

                            read_id <= read_id + 1;            
                        end
                    end
                end

                // WRITE operation
                if (valid_wreq)
                begin
                    if (!(set_q_to_x || set_q_to_x_by_empty))
                    begin
                        if (full_flag && (overflow_checking == "OFF"))
                        begin
                            set_q_to_x <= 1'b1;
                            $display ("Warning : Overflow occurred! Fifo output is unknown until the next reset is asserted.");
                            $display ("Time: %0t  Instance: %m", $time);
                        end
                        else
                        begin
                            mem_data[write_id] <= data;
                            write_flag <= 1'b1;
    
                            if (!((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area || legacy_speed)))
                            begin
                                empty_flag <= 1'b0;
                            end
                            else
                            begin
                                empty_latency1 <= 1'b0;
                            end
    
                            if (!valid_rreq)                
                                wrt_count <= wrt_count + 1;
    
                            if (!valid_rreq)
                            begin
                                if (count_id >= (1 << lpm_widthu) - 1)
                                    count_id <= 0;
                                else
                                    count_id <= count_id + 1;               
                            end
                            else
                            begin
                                if (allow_rwcycle_when_full == "OFF")
                                    full_flag <= 1'b0;
                            end
    
                            if (!(stratix_family) || (stratix_family && !(showahead_speed || showahead_area || legacy_speed)))
                            begin                
                                if (!valid_rreq)
                                    if ((count_id == lpm_numwords - 1) && (empty_flag == 1'b0))
                                        full_flag <= 1'b1;
                            end
                            else
                            begin   
                                if (!valid_rreq)
                                    if (count_id == lpm_numwords - 1)
                                        full_flag <= 1'b1;
                            end
    
                            if (lpm_showahead == "ON")
                            begin
                                if ((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area))
                                begin
                                    write_latency1 <= write_id;                    
                                    data_shown[write_id] <= 1'b1;
                                    data_ready[write_id] <= 1'bx;
                                end
                                else
                                begin 
                                    if ((use_eab == "OFF") && stratix_family && (count_id == 0) && (!full_flag))
                                    begin
                                        tmp_q <= data;
                                    end
                                    else
                                    begin
                                        if ((!empty_flag) && (!valid_rreq))
                                        begin
                                            tmp_q <= mem_data[read_id];
                                        end
                                    end
                                end
                            end
                            else
                            begin
                                if ((use_eab == "ON") && stratix_family && legacy_speed) 
                                begin
                                    write_latency1 <= write_id;                    
                                    data_shown[write_id] <= 1'b1;
                                    data_ready[write_id] <= 1'bx;
                                end
                            end
                        end
                    end   
                end    

                if (almost_full_value == 0)
                    almost_full_flag <= 1'b1;
                else if (lpm_numwords > almost_full_value)
                begin
                    if (almost_full_flag)
                    begin
                        if ((count_id == almost_full_value) && !wrreq && rdreq)
                            almost_full_flag <= 1'b0;
                    end
                    else
                    begin
                        if ((almost_full_value == 1) && (count_id == 0) && wrreq)
                            almost_full_flag <= 1'b1;
                        else if ((almost_full_value > 1) && (count_id == almost_full_value - 1)
                                && wrreq && !rdreq)
                            almost_full_flag <= 1'b1;
                    end
                end

                if (almost_empty_value == 0)
                    almost_empty_flag <= 1'b0;
                else if (lpm_numwords > almost_empty_value)
                begin
                    if (almost_empty_flag)
                    begin
                        if ((almost_empty_value == 1) && (count_id == 0) && wrreq)
                            almost_empty_flag <= 1'b0;
                        else if ((almost_empty_value > 1) && (count_id == almost_empty_value - 1)
                                && wrreq && !rdreq)
                            almost_empty_flag <= 1'b0;
                    end
                    else
                    begin
                        if ((count_id == almost_empty_value) && !wrreq && rdreq)
                            almost_empty_flag <= 1'b1;
                    end
                end
            end

            if ((use_eab == "ON") && stratix_family)
            begin
                if (showahead_speed)
                begin
                    write_latency2 <= write_latency1;
                    write_latency3 <= write_latency2;
                    if (write_latency3 !== write_latency2)
                        data_ready[write_latency2] <= 1'b1;
                                    
                    empty_latency2 <= empty_latency1;

                    if (data_shown[write_latency2]==1'b1)
                    begin
                        if ((read_id == write_latency2) || aclr || sclr)
                        begin
                            if (!(aclr === 1'b1) && !(sclr === 1'b1))                        
                            begin
                                if (write_latency2 !== 1'bx)
                                begin
                                    tmp_q <= mem_data[write_latency2];
                                    data_shown[write_latency2] <= 1'b0;
                                    data_ready[write_latency2] <= 1'b0;
    
                                    if (!valid_rreq)
                                        empty_flag <= empty_latency2;
                                end
                            end
                        end
                    end
                end
                else if (showahead_area)
                begin
                    write_latency2 <= write_latency1;
                    if (write_latency2 !== write_latency1)
                        data_ready[write_latency1] <= 1'b1;

                    if (data_shown[write_latency1]==1'b1)
                    begin
                        if ((read_id == write_latency1) || aclr || sclr)
                        begin
                            if (!(aclr === 1'b1) && !(sclr === 1'b1))
                            begin
                                if (write_latency1 !== 1'bx)
                                begin
                                    tmp_q <= mem_data[write_latency1];
                                    data_shown[write_latency1] <= 1'b0;
                                    data_ready[write_latency1] <= 1'b0;

                                    if (!valid_rreq)
                                    begin
                                        empty_flag <= empty_latency1;
                                    end
                                end
                            end
                        end
                    end                            
                end
                else
                begin
                    if (legacy_speed)
                    begin
                        write_latency2 <= write_latency1;
                        if (write_latency2 !== write_latency1)
                            data_ready[write_latency1] <= 1'b1;

                            empty_flag <= empty_latency1;

                        if ((wrt_count == 1 && !valid_wreq && valid_rreq) || aclr || sclr)
                        begin
                            empty_flag <= 1'b1;
                            empty_latency1 <= 1'b1;
                        end
                        else
                        begin
                            if ((wrt_count == 1) && valid_wreq && valid_rreq)
                            begin
                                empty_flag <= 1'b1;
                            end
                        end
                    end
                end
            end
        end
    end

    always @(negedge clock)
    begin
        if (write_flag)
        begin
            write_flag <= 1'b0;

            if (sclr || aclr || (write_id >= ((1 << lpm_widthu) - 1)))
                write_id <= 0;
            else
                write_id <= write_id + 1;
        end

        if (!(stratix_family))
        begin
            if (!empty)
            begin
                if ((lpm_showahead == "ON") && ($time > 0))
                    tmp_q <= mem_data[read_id];
            end
        end
    end

    always @(full_flag)
    begin
        if (lpm_numwords == almost_full_value)
            if (full_flag)
                almost_full_flag = 1'b1;
            else
                almost_full_flag = 1'b0;

        if (lpm_numwords == almost_empty_value)
            if (full_flag)
                almost_empty_flag = 1'b0;
            else
                almost_empty_flag = 1'b1;
    end

// CONTINOUS ASSIGNMENT   
    assign q = (set_q_to_x || set_q_to_x_by_empty)? {lpm_width{1'bX}} : tmp_q;
    assign full = (set_q_to_x || set_q_to_x_by_empty)? 1'bX : full_flag;
    assign empty = (set_q_to_x || set_q_to_x_by_empty)? 1'bX : empty_flag;
    assign usedw = (set_q_to_x || set_q_to_x_by_empty)? {lpm_widthu{1'bX}} : count_id;
    assign almost_full = (set_q_to_x || set_q_to_x_by_empty)? 1'bX : almost_full_flag;
    assign almost_empty = (set_q_to_x || set_q_to_x_by_empty)? 1'bX : almost_empty_flag;

endmodule // scfifo
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
    if ((device == "Stratix IV") || (device == "STRATIX IV") || (device == "stratix iv") || (device == "TGX") || (device == "tgx") || (device == "StratixIV") || (device == "STRATIXIV") || (device == "stratixiv") || (device == "Stratix IV (GT)") || (device == "STRATIX IV (GT)") || (device == "stratix iv (gt)") || (device == "Stratix IV (GX)") || (device == "STRATIX IV (GX)") || (device == "stratix iv (gx)") || (device == "Stratix IV (E)") || (device == "STRATIX IV (E)") || (device == "stratix iv (e)") || (device == "StratixIV(GT)") || (device == "STRATIXIV(GT)") || (device == "stratixiv(gt)") || (device == "StratixIV(GX)") || (device == "STRATIXIV(GX)") || (device == "stratixiv(gx)") || (device == "StratixIV(E)") || (device == "STRATIXIV(E)") || (device == "stratixiv(e)") || (device == "StratixIIIGX") || (device == "STRATIXIIIGX") || (device == "stratixiiigx") || (device == "Stratix IV (GT/GX/E)") || (device == "STRATIX IV (GT/GX/E)") || (device == "stratix iv (gt/gx/e)") || (device == "Stratix IV (GT/E/GX)") || (device == "STRATIX IV (GT/E/GX)") || (device == "stratix iv (gt/e/gx)") || (device == "Stratix IV (E/GT/GX)") || (device == "STRATIX IV (E/GT/GX)") || (device == "stratix iv (e/gt/gx)") || (device == "Stratix IV (E/GX/GT)") || (device == "STRATIX IV (E/GX/GT)") || (device == "stratix iv (e/gx/gt)") || (device == "StratixIV(GT/GX/E)") || (device == "STRATIXIV(GT/GX/E)") || (device == "stratixiv(gt/gx/e)") || (device == "StratixIV(GT/E/GX)") || (device == "STRATIXIV(GT/E/GX)") || (device == "stratixiv(gt/e/gx)") || (device == "StratixIV(E/GX/GT)") || (device == "STRATIXIV(E/GX/GT)") || (device == "stratixiv(e/gx/gt)") || (device == "StratixIV(E/GT/GX)") || (device == "STRATIXIV(E/GT/GX)") || (device == "stratixiv(e/gt/gx)") || (device == "Stratix IV (GX/E)") || (device == "STRATIX IV (GX/E)") || (device == "stratix iv (gx/e)") || (device == "StratixIV(GX/E)") || (device == "STRATIXIV(GX/E)") || (device == "stratixiv(gx/e)"))
        is_stratixiv = 1;
    else
        is_stratixiv = 0;

    IS_FAMILY_STRATIXIV  = is_stratixiv;
end
endfunction //IS_FAMILY_STRATIXIV

function IS_FAMILY_ARRIAIIGX;
    input[8*20:1] device;
    reg is_arriaiigx;
begin
    if ((device == "Arria II GX") || (device == "ARRIA II GX") || (device == "arria ii gx") || (device == "ArriaIIGX") || (device == "ARRIAIIGX") || (device == "arriaiigx") || (device == "Arria IIGX") || (device == "ARRIA IIGX") || (device == "arria iigx") || (device == "ArriaII GX") || (device == "ARRIAII GX") || (device == "arriaii gx") || (device == "Arria II") || (device == "ARRIA II") || (device == "arria ii") || (device == "ArriaII") || (device == "ARRIAII") || (device == "arriaii") || (device == "Arria II (GX/E)") || (device == "ARRIA II (GX/E)") || (device == "arria ii (gx/e)") || (device == "ArriaII(GX/E)") || (device == "ARRIAII(GX/E)") || (device == "arriaii(gx/e)") || (device == "PIRANHA") || (device == "piranha"))
        is_arriaiigx = 1;
    else
        is_arriaiigx = 0;

    IS_FAMILY_ARRIAIIGX  = is_arriaiigx;
end
endfunction //IS_FAMILY_ARRIAIIGX

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
    if ((device == "HardCopy IV") || (device == "HARDCOPY IV") || (device == "hardcopy iv") || (device == "HardCopyIV") || (device == "HARDCOPYIV") || (device == "hardcopyiv") || (device == "HardCopy IV (GX)") || (device == "HARDCOPY IV (GX)") || (device == "hardcopy iv (gx)") || (device == "HardCopy IV (E)") || (device == "HARDCOPY IV (E)") || (device == "hardcopy iv (e)") || (device == "HardCopyIV(GX)") || (device == "HARDCOPYIV(GX)") || (device == "hardcopyiv(gx)") || (device == "HardCopyIV(E)") || (device == "HARDCOPYIV(E)") || (device == "hardcopyiv(e)") || (device == "HCXIV") || (device == "hcxiv") || (device == "HardCopy IV (GX/E)") || (device == "HARDCOPY IV (GX/E)") || (device == "hardcopy iv (gx/e)") || (device == "HardCopy IV (E/GX)") || (device == "HARDCOPY IV (E/GX)") || (device == "hardcopy iv (e/gx)") || (device == "HardCopyIV(GX/E)") || (device == "HARDCOPYIV(GX/E)") || (device == "hardcopyiv(gx/e)") || (device == "HardCopyIV(E/GX)") || (device == "HARDCOPYIV(E/GX)") || (device == "hardcopyiv(e/gx)"))
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

function IS_FAMILY_CYCLONEIVGX;
    input[8*20:1] device;
    reg is_cycloneivgx;
begin
    if ((device == "Cyclone IV GX") || (device == "CYCLONE IV GX") || (device == "cyclone iv gx") || (device == "Cyclone IVGX") || (device == "CYCLONE IVGX") || (device == "cyclone ivgx") || (device == "CycloneIV GX") || (device == "CYCLONEIV GX") || (device == "cycloneiv gx") || (device == "CycloneIVGX") || (device == "CYCLONEIVGX") || (device == "cycloneivgx") || (device == "Cyclone IV") || (device == "CYCLONE IV") || (device == "cyclone iv") || (device == "CycloneIV") || (device == "CYCLONEIV") || (device == "cycloneiv") || (device == "Cyclone IV (GX)") || (device == "CYCLONE IV (GX)") || (device == "cyclone iv (gx)") || (device == "CycloneIV(GX)") || (device == "CYCLONEIV(GX)") || (device == "cycloneiv(gx)") || (device == "Cyclone III GX") || (device == "CYCLONE III GX") || (device == "cyclone iii gx") || (device == "CycloneIII GX") || (device == "CYCLONEIII GX") || (device == "cycloneiii gx") || (device == "Cyclone IIIGX") || (device == "CYCLONE IIIGX") || (device == "cyclone iiigx") || (device == "CycloneIIIGX") || (device == "CYCLONEIIIGX") || (device == "cycloneiiigx") || (device == "Cyclone III GL") || (device == "CYCLONE III GL") || (device == "cyclone iii gl") || (device == "CycloneIII GL") || (device == "CYCLONEIII GL") || (device == "cycloneiii gl") || (device == "Cyclone IIIGL") || (device == "CYCLONE IIIGL") || (device == "cyclone iiigl") || (device == "CycloneIIIGL") || (device == "CYCLONEIIIGL") || (device == "cycloneiiigl") || (device == "Stingray") || (device == "STINGRAY") || (device == "stingray"))
        is_cycloneivgx = 1;
    else
        is_cycloneivgx = 0;

    IS_FAMILY_CYCLONEIVGX  = is_cycloneivgx;
end
endfunction //IS_FAMILY_CYCLONEIVGX

function IS_FAMILY_CYCLONEIVE;
    input[8*20:1] device;
    reg is_cycloneive;
begin
    if ((device == "Cyclone IV E") || (device == "CYCLONE IV E") || (device == "cyclone iv e") || (device == "CycloneIV E") || (device == "CYCLONEIV E") || (device == "cycloneiv e") || (device == "Cyclone IVE") || (device == "CYCLONE IVE") || (device == "cyclone ive") || (device == "CycloneIVE") || (device == "CYCLONEIVE") || (device == "cycloneive"))
        is_cycloneive = 1;
    else
        is_cycloneive = 0;

    IS_FAMILY_CYCLONEIVE  = is_cycloneive;
end
endfunction //IS_FAMILY_CYCLONEIVE

function IS_FAMILY_STRATIXV;
    input[8*20:1] device;
    reg is_stratixv;
begin
    if ((device == "Stratix V") || (device == "STRATIX V") || (device == "stratix v") || (device == "StratixV") || (device == "STRATIXV") || (device == "stratixv") || (device == "Stratix V (GS)") || (device == "STRATIX V (GS)") || (device == "stratix v (gs)") || (device == "StratixV(GS)") || (device == "STRATIXV(GS)") || (device == "stratixv(gs)") || (device == "Stratix V (GX)") || (device == "STRATIX V (GX)") || (device == "stratix v (gx)") || (device == "StratixV(GX)") || (device == "STRATIXV(GX)") || (device == "stratixv(gx)") || (device == "Stratix V (GS/GX)") || (device == "STRATIX V (GS/GX)") || (device == "stratix v (gs/gx)") || (device == "StratixV(GS/GX)") || (device == "STRATIXV(GS/GX)") || (device == "stratixv(gs/gx)") || (device == "Stratix V (GX/GS)") || (device == "STRATIX V (GX/GS)") || (device == "stratix v (gx/gs)") || (device == "StratixV(GX/GS)") || (device == "STRATIXV(GX/GS)") || (device == "stratixv(gx/gs)"))
        is_stratixv = 1;
    else
        is_stratixv = 0;

    IS_FAMILY_STRATIXV  = is_stratixv;
end
endfunction //IS_FAMILY_STRATIXV

function IS_FAMILY_ARRIAIIGZ;
    input[8*20:1] device;
    reg is_arriaiigz;
begin
    if ((device == "Arria II GZ") || (device == "ARRIA II GZ") || (device == "arria ii gz") || (device == "ArriaII GZ") || (device == "ARRIAII GZ") || (device == "arriaii gz") || (device == "Arria IIGZ") || (device == "ARRIA IIGZ") || (device == "arria iigz") || (device == "ArriaIIGZ") || (device == "ARRIAIIGZ") || (device == "arriaiigz"))
        is_arriaiigz = 1;
    else
        is_arriaiigz = 0;

    IS_FAMILY_ARRIAIIGZ  = is_arriaiigz;
end
endfunction //IS_FAMILY_ARRIAIIGZ

function IS_FAMILY_MAXV;
    input[8*20:1] device;
    reg is_maxv;
begin
    if ((device == "MAX V") || (device == "max v") || (device == "MAXV") || (device == "maxv") || (device == "Jade") || (device == "JADE") || (device == "jade"))
        is_maxv = 1;
    else
        is_maxv = 0;

    IS_FAMILY_MAXV  = is_maxv;
end
endfunction //IS_FAMILY_MAXV

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

function FEATURE_FAMILY_STRATIXV;
    input[8*20:1] device;
    reg var_family_stratixv;
begin
    if (IS_FAMILY_STRATIXV(device) )
        var_family_stratixv = 1;
    else
        var_family_stratixv = 0;

    FEATURE_FAMILY_STRATIXV  = var_family_stratixv;
end
endfunction //FEATURE_FAMILY_STRATIXV

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

function FEATURE_FAMILY_CYCLONEIVGX;
    input[8*20:1] device;
    reg var_family_cycloneivgx;
begin
    if (IS_FAMILY_CYCLONEIVGX(device) || IS_FAMILY_CYCLONEIVGX(device) )
        var_family_cycloneivgx = 1;
    else
        var_family_cycloneivgx = 0;

    FEATURE_FAMILY_CYCLONEIVGX  = var_family_cycloneivgx;
end
endfunction //FEATURE_FAMILY_CYCLONEIVGX

function FEATURE_FAMILY_CYCLONEIVE;
    input[8*20:1] device;
    reg var_family_cycloneive;
begin
    if (IS_FAMILY_CYCLONEIVE(device) )
        var_family_cycloneive = 1;
    else
        var_family_cycloneive = 0;

    FEATURE_FAMILY_CYCLONEIVE  = var_family_cycloneive;
end
endfunction //FEATURE_FAMILY_CYCLONEIVE

function FEATURE_FAMILY_CYCLONEIII;
    input[8*20:1] device;
    reg var_family_cycloneiii;
begin
    if (IS_FAMILY_CYCLONEIII(device) || IS_FAMILY_CYCLONEIIILS(device) || FEATURE_FAMILY_CYCLONEIVGX(device) || FEATURE_FAMILY_CYCLONEIVE(device) )
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
    if ((device == "StratixHC") )
        var_family_stratix_hc = 1;
    else
        var_family_stratix_hc = 0;

    FEATURE_FAMILY_STRATIX_HC  = var_family_stratix_hc;
end
endfunction //FEATURE_FAMILY_STRATIX_HC

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
    if (IS_FAMILY_MAXII(device) || FEATURE_FAMILY_MAXV(device) )
        var_family_maxii = 1;
    else
        var_family_maxii = 0;

    FEATURE_FAMILY_MAXII  = var_family_maxii;
end
endfunction //FEATURE_FAMILY_MAXII

function FEATURE_FAMILY_MAXV;
    input[8*20:1] device;
    reg var_family_maxv;
begin
    if (IS_FAMILY_MAXV(device) )
        var_family_maxv = 1;
    else
        var_family_maxv = 0;

    FEATURE_FAMILY_MAXV  = var_family_maxv;
end
endfunction //FEATURE_FAMILY_MAXV

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
    if (IS_FAMILY_STRATIXIV(device) || IS_FAMILY_ARRIAIIGX(device) || IS_FAMILY_HARDCOPYIV(device) || FEATURE_FAMILY_STRATIXV(device) || FEATURE_FAMILY_ARRIAIIGZ(device) )
        var_family_stratixiv = 1;
    else
        var_family_stratixiv = 0;

    FEATURE_FAMILY_STRATIXIV  = var_family_stratixiv;
end
endfunction //FEATURE_FAMILY_STRATIXIV

function FEATURE_FAMILY_ARRIAIIGZ;
    input[8*20:1] device;
    reg var_family_arriaiigz;
begin
    if (IS_FAMILY_ARRIAIIGZ(device) )
        var_family_arriaiigz = 1;
    else
        var_family_arriaiigz = 0;

    FEATURE_FAMILY_ARRIAIIGZ  = var_family_arriaiigz;
end
endfunction //FEATURE_FAMILY_ARRIAIIGZ

function FEATURE_FAMILY_ARRIAIIGX;
    input[8*20:1] device;
    reg var_family_arriaiigx;
begin
    if (IS_FAMILY_ARRIAIIGX(device) )
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
    if (IS_FAMILY_STRATIX(device) || IS_FAMILY_STRATIXGX(device) )
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
    if (((device == "MAX7000B") || (device == "max7000b") || (device == "MAX 7000B") || (device == "max 7000b"))
    || ((device == "MAX7000AE") || (device == "max7000ae") || (device == "MAX 7000AE") || (device == "max 7000ae"))
    || ((device == "MAX3000A") || (device == "max3000a") || (device == "MAX 3000A") || (device == "max 3000a"))
    || ((device == "MAX7000S") || (device == "max7000s") || (device == "MAX 7000S") || (device == "max 7000s"))
    || ((device == "Stratix") || (device == "STRATIX") || (device == "stratix") || (device == "Yeager") || (device == "YEAGER") || (device == "yeager"))
    || ((device == "Stratix GX") || (device == "STRATIX GX") || (device == "stratix gx") || (device == "Stratix-GX") || (device == "STRATIX-GX") || (device == "stratix-gx") || (device == "StratixGX") || (device == "STRATIXGX") || (device == "stratixgx") || (device == "Aurora") || (device == "AURORA") || (device == "aurora"))
    || ((device == "Cyclone") || (device == "CYCLONE") || (device == "cyclone") || (device == "ACEX2K") || (device == "acex2k") || (device == "ACEX 2K") || (device == "acex 2k") || (device == "Tornado") || (device == "TORNADO") || (device == "tornado"))
    || ((device == "MAX II") || (device == "max ii") || (device == "MAXII") || (device == "maxii") || (device == "Tsunami") || (device == "TSUNAMI") || (device == "tsunami"))
    || ((device == "Stratix II") || (device == "STRATIX II") || (device == "stratix ii") || (device == "StratixII") || (device == "STRATIXII") || (device == "stratixii") || (device == "Armstrong") || (device == "ARMSTRONG") || (device == "armstrong"))
    || ((device == "Stratix II GX") || (device == "STRATIX II GX") || (device == "stratix ii gx") || (device == "StratixIIGX") || (device == "STRATIXIIGX") || (device == "stratixiigx"))
    || ((device == "Arria GX") || (device == "ARRIA GX") || (device == "arria gx") || (device == "ArriaGX") || (device == "ARRIAGX") || (device == "arriagx") || (device == "Stratix II GX Lite") || (device == "STRATIX II GX LITE") || (device == "stratix ii gx lite") || (device == "StratixIIGXLite") || (device == "STRATIXIIGXLITE") || (device == "stratixiigxlite"))
    || ((device == "Cyclone II") || (device == "CYCLONE II") || (device == "cyclone ii") || (device == "Cycloneii") || (device == "CYCLONEII") || (device == "cycloneii") || (device == "Magellan") || (device == "MAGELLAN") || (device == "magellan"))
    || ((device == "HardCopy II") || (device == "HARDCOPY II") || (device == "hardcopy ii") || (device == "HardCopyII") || (device == "HARDCOPYII") || (device == "hardcopyii") || (device == "Fusion") || (device == "FUSION") || (device == "fusion"))
    || ((device == "Stratix III") || (device == "STRATIX III") || (device == "stratix iii") || (device == "StratixIII") || (device == "STRATIXIII") || (device == "stratixiii") || (device == "Titan") || (device == "TITAN") || (device == "titan") || (device == "SIII") || (device == "siii"))
    || ((device == "Cyclone III") || (device == "CYCLONE III") || (device == "cyclone iii") || (device == "CycloneIII") || (device == "CYCLONEIII") || (device == "cycloneiii") || (device == "Barracuda") || (device == "BARRACUDA") || (device == "barracuda") || (device == "Cuda") || (device == "CUDA") || (device == "cuda") || (device == "CIII") || (device == "ciii"))
    || ((device == "BS") || (device == "bs"))
    || ((device == "Stratix IV") || (device == "STRATIX IV") || (device == "stratix iv") || (device == "TGX") || (device == "tgx") || (device == "StratixIV") || (device == "STRATIXIV") || (device == "stratixiv") || (device == "Stratix IV (GT)") || (device == "STRATIX IV (GT)") || (device == "stratix iv (gt)") || (device == "Stratix IV (GX)") || (device == "STRATIX IV (GX)") || (device == "stratix iv (gx)") || (device == "Stratix IV (E)") || (device == "STRATIX IV (E)") || (device == "stratix iv (e)") || (device == "StratixIV(GT)") || (device == "STRATIXIV(GT)") || (device == "stratixiv(gt)") || (device == "StratixIV(GX)") || (device == "STRATIXIV(GX)") || (device == "stratixiv(gx)") || (device == "StratixIV(E)") || (device == "STRATIXIV(E)") || (device == "stratixiv(e)") || (device == "StratixIIIGX") || (device == "STRATIXIIIGX") || (device == "stratixiiigx") || (device == "Stratix IV (GT/GX/E)") || (device == "STRATIX IV (GT/GX/E)") || (device == "stratix iv (gt/gx/e)") || (device == "Stratix IV (GT/E/GX)") || (device == "STRATIX IV (GT/E/GX)") || (device == "stratix iv (gt/e/gx)") || (device == "Stratix IV (E/GT/GX)") || (device == "STRATIX IV (E/GT/GX)") || (device == "stratix iv (e/gt/gx)") || (device == "Stratix IV (E/GX/GT)") || (device == "STRATIX IV (E/GX/GT)") || (device == "stratix iv (e/gx/gt)") || (device == "StratixIV(GT/GX/E)") || (device == "STRATIXIV(GT/GX/E)") || (device == "stratixiv(gt/gx/e)") || (device == "StratixIV(GT/E/GX)") || (device == "STRATIXIV(GT/E/GX)") || (device == "stratixiv(gt/e/gx)") || (device == "StratixIV(E/GX/GT)") || (device == "STRATIXIV(E/GX/GT)") || (device == "stratixiv(e/gx/gt)") || (device == "StratixIV(E/GT/GX)") || (device == "STRATIXIV(E/GT/GX)") || (device == "stratixiv(e/gt/gx)") || (device == "Stratix IV (GX/E)") || (device == "STRATIX IV (GX/E)") || (device == "stratix iv (gx/e)") || (device == "StratixIV(GX/E)") || (device == "STRATIXIV(GX/E)") || (device == "stratixiv(gx/e)"))
    || ((device == "tgx_commercial_v1_1") || (device == "TGX_COMMERCIAL_V1_1"))
    || ((device == "Arria II GX") || (device == "ARRIA II GX") || (device == "arria ii gx") || (device == "ArriaIIGX") || (device == "ARRIAIIGX") || (device == "arriaiigx") || (device == "Arria IIGX") || (device == "ARRIA IIGX") || (device == "arria iigx") || (device == "ArriaII GX") || (device == "ARRIAII GX") || (device == "arriaii gx") || (device == "Arria II") || (device == "ARRIA II") || (device == "arria ii") || (device == "ArriaII") || (device == "ARRIAII") || (device == "arriaii") || (device == "Arria II (GX/E)") || (device == "ARRIA II (GX/E)") || (device == "arria ii (gx/e)") || (device == "ArriaII(GX/E)") || (device == "ARRIAII(GX/E)") || (device == "arriaii(gx/e)") || (device == "PIRANHA") || (device == "piranha"))
    || ((device == "HardCopy III") || (device == "HARDCOPY III") || (device == "hardcopy iii") || (device == "HardCopyIII") || (device == "HARDCOPYIII") || (device == "hardcopyiii") || (device == "HCX") || (device == "hcx"))
    || ((device == "HardCopy IV") || (device == "HARDCOPY IV") || (device == "hardcopy iv") || (device == "HardCopyIV") || (device == "HARDCOPYIV") || (device == "hardcopyiv") || (device == "HardCopy IV (GX)") || (device == "HARDCOPY IV (GX)") || (device == "hardcopy iv (gx)") || (device == "HardCopy IV (E)") || (device == "HARDCOPY IV (E)") || (device == "hardcopy iv (e)") || (device == "HardCopyIV(GX)") || (device == "HARDCOPYIV(GX)") || (device == "hardcopyiv(gx)") || (device == "HardCopyIV(E)") || (device == "HARDCOPYIV(E)") || (device == "hardcopyiv(e)") || (device == "HCXIV") || (device == "hcxiv") || (device == "HardCopy IV (GX/E)") || (device == "HARDCOPY IV (GX/E)") || (device == "hardcopy iv (gx/e)") || (device == "HardCopy IV (E/GX)") || (device == "HARDCOPY IV (E/GX)") || (device == "hardcopy iv (e/gx)") || (device == "HardCopyIV(GX/E)") || (device == "HARDCOPYIV(GX/E)") || (device == "hardcopyiv(gx/e)") || (device == "HardCopyIV(E/GX)") || (device == "HARDCOPYIV(E/GX)") || (device == "hardcopyiv(e/gx)"))
    || ((device == "Cyclone III LS") || (device == "CYCLONE III LS") || (device == "cyclone iii ls") || (device == "CycloneIIILS") || (device == "CYCLONEIIILS") || (device == "cycloneiiils") || (device == "Cyclone III LPS") || (device == "CYCLONE III LPS") || (device == "cyclone iii lps") || (device == "Cyclone LPS") || (device == "CYCLONE LPS") || (device == "cyclone lps") || (device == "CycloneLPS") || (device == "CYCLONELPS") || (device == "cyclonelps") || (device == "Tarpon") || (device == "TARPON") || (device == "tarpon") || (device == "Cyclone IIIE") || (device == "CYCLONE IIIE") || (device == "cyclone iiie"))
    || ((device == "Cyclone IV GX") || (device == "CYCLONE IV GX") || (device == "cyclone iv gx") || (device == "Cyclone IVGX") || (device == "CYCLONE IVGX") || (device == "cyclone ivgx") || (device == "CycloneIV GX") || (device == "CYCLONEIV GX") || (device == "cycloneiv gx") || (device == "CycloneIVGX") || (device == "CYCLONEIVGX") || (device == "cycloneivgx") || (device == "Cyclone IV") || (device == "CYCLONE IV") || (device == "cyclone iv") || (device == "CycloneIV") || (device == "CYCLONEIV") || (device == "cycloneiv") || (device == "Cyclone IV (GX)") || (device == "CYCLONE IV (GX)") || (device == "cyclone iv (gx)") || (device == "CycloneIV(GX)") || (device == "CYCLONEIV(GX)") || (device == "cycloneiv(gx)") || (device == "Cyclone III GX") || (device == "CYCLONE III GX") || (device == "cyclone iii gx") || (device == "CycloneIII GX") || (device == "CYCLONEIII GX") || (device == "cycloneiii gx") || (device == "Cyclone IIIGX") || (device == "CYCLONE IIIGX") || (device == "cyclone iiigx") || (device == "CycloneIIIGX") || (device == "CYCLONEIIIGX") || (device == "cycloneiiigx") || (device == "Cyclone III GL") || (device == "CYCLONE III GL") || (device == "cyclone iii gl") || (device == "CycloneIII GL") || (device == "CYCLONEIII GL") || (device == "cycloneiii gl") || (device == "Cyclone IIIGL") || (device == "CYCLONE IIIGL") || (device == "cyclone iiigl") || (device == "CycloneIIIGL") || (device == "CYCLONEIIIGL") || (device == "cycloneiiigl") || (device == "Stingray") || (device == "STINGRAY") || (device == "stingray"))
    || ((device == "Cyclone IV E") || (device == "CYCLONE IV E") || (device == "cyclone iv e") || (device == "CycloneIV E") || (device == "CYCLONEIV E") || (device == "cycloneiv e") || (device == "Cyclone IVE") || (device == "CYCLONE IVE") || (device == "cyclone ive") || (device == "CycloneIVE") || (device == "CYCLONEIVE") || (device == "cycloneive"))
    || ((device == "Stratix V") || (device == "STRATIX V") || (device == "stratix v") || (device == "StratixV") || (device == "STRATIXV") || (device == "stratixv") || (device == "Stratix V (GS)") || (device == "STRATIX V (GS)") || (device == "stratix v (gs)") || (device == "StratixV(GS)") || (device == "STRATIXV(GS)") || (device == "stratixv(gs)") || (device == "Stratix V (GX)") || (device == "STRATIX V (GX)") || (device == "stratix v (gx)") || (device == "StratixV(GX)") || (device == "STRATIXV(GX)") || (device == "stratixv(gx)") || (device == "Stratix V (GS/GX)") || (device == "STRATIX V (GS/GX)") || (device == "stratix v (gs/gx)") || (device == "StratixV(GS/GX)") || (device == "STRATIXV(GS/GX)") || (device == "stratixv(gs/gx)") || (device == "Stratix V (GX/GS)") || (device == "STRATIX V (GX/GS)") || (device == "stratix v (gx/gs)") || (device == "StratixV(GX/GS)") || (device == "STRATIXV(GX/GS)") || (device == "stratixv(gx/gs)"))
    || ((device == "Arria II GZ") || (device == "ARRIA II GZ") || (device == "arria ii gz") || (device == "ArriaII GZ") || (device == "ARRIAII GZ") || (device == "arriaii gz") || (device == "Arria IIGZ") || (device == "ARRIA IIGZ") || (device == "arria iigz") || (device == "ArriaIIGZ") || (device == "ARRIAIIGZ") || (device == "arriaiigz"))
    || ((device == "arriaiigz_commercial_v1_1") || (device == "ARRIAIIGZ_COMMERCIAL_V1_1"))
    || ((device == "MAX V") || (device == "max v") || (device == "MAXV") || (device == "maxv") || (device == "Jade") || (device == "JADE") || (device == "jade"))
    || ((device == "ArriaV") || (device == "ARRIAV") || (device == "arriav") || (device == "Arria V") || (device == "ARRIA V") || (device == "arria v")))
        is_valid = 1;
    else
        is_valid = 0;

    IS_VALID_FAMILY = is_valid;
end
endfunction // IS_VALID_FAMILY


endmodule // ALTERA_DEVICE_FAMILIES

