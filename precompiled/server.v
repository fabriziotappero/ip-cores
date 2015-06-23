//////////////////////////////////////////////////////////////////////////////
//name : server
//input : input_eth_rx:16
//input : input_socket:16
//output : output_socket:16
//output : output_eth_tx:16
//source_file : ../source/server.c
///======
///
///Created by C2CHIP

//////////////////////////////////////////////////////////////////////////////
// Register Allocation
// ===================
//         Register                 Name                   Size          
//            0             put_eth return address            2            
//            1                  variable i                 2            
//            2             put_socket return address            2            
//            3                  variable i                 2            
//            4             get_eth return address            2            
//            5             variable get_eth return value            2            
//            6             rdy_eth return address            2            
//            7             variable rdy_eth return value            2            
//            8             get_socket return address            2            
//            9             variable get_socket return value            2            
//            10                   array                    2            
//            11             variable checksum              4            
//            12            reset_checksum return address            2            
//            13            add_checksum return address            2            
//            14               variable data                2            
//            15            check_checksum return address            2            
//            16            variable check_checksum return value            2            
//            17            calc_ack return address            2            
//            18            variable calc_ack return value            2            
//            19                   array                    2            
//            20                   array                    2            
//            21              variable length               2            
//            22             variable new_ack_0             2            
//            23             variable new_ack_1             2            
//            24            variable return_value            2            
//            25            put_ethernet_packet return address            2            
//            26                   array                    2            
//            27            variable number_of_bytes            2            
//            28            variable destination_mac_address_hi            2            
//            29            variable destination_mac_address_med            2            
//            30            variable destination_mac_address_lo            2            
//            31             variable protocol              2            
//            32               variable byte                2            
//            33               variable index               2            
//            34            get_ethernet_packet return address            2            
//            35            variable get_ethernet_packet return value            2            
//            36                   array                    2            
//            37            variable number_of_bytes            2            
//            38               variable index               2            
//            39               variable byte                2            
//            40                   array                    2            
//            41                   array                    2            
//            42                   array                    2            
//            43                   array                    2            
//            44                   array                    2            
//            45            variable arp_pounsigneder            2            
//            46            get_arp_cache return address            2            
//            47            variable get_arp_cache return value            2            
//            48               variable ip_hi               2            
//            49               variable ip_lo               2            
//            50            variable number_of_bytes            2            
//            51               variable byte                2            
//            52                   array                    2            
//            53                 variable i                 2            
//            54            put_ip_packet return address            2            
//            55                   array                    2            
//            56            variable total_length            2            
//            57             variable protocol              2            
//            58               variable ip_hi               2            
//            59               variable ip_lo               2            
//            60            variable number_of_bytes            2            
//            61                 variable i                 2            
//            62             variable arp_cache             2            
//            63            get_ip_packet return address            2            
//            64            variable get_ip_packet return value            2            
//            65                   array                    2            
//            66            variable total_length            2            
//            67            variable header_length            2            
//            68            variable payload_start            2            
//            69            variable payload_length            2            
//            70                 variable i                 2            
//            71               variable from                2            
//            72                variable to                 2            
//            73            variable payload_end            2            
//            74            variable number_of_bytes            2            
//            75            variable remote_ip_hi            2            
//            76            variable remote_ip_lo            2            
//            77             variable tx_source             2            
//            78              variable tx_dest              2            
//            79                   array                    2            
//            80                   array                    2            
//            81                   array                    2            
//            82             variable tx_window             2            
//            83            variable tx_fin_flag            2            
//            84            variable tx_syn_flag            2            
//            85            variable tx_rst_flag            2            
//            86            variable tx_psh_flag            2            
//            87            variable tx_ack_flag            2            
//            88            variable tx_urg_flag            2            
//            89             variable rx_source             2            
//            90              variable rx_dest              2            
//            91                   array                    2            
//            92                   array                    2            
//            93            variable rx_fin_flag            2            
//            94            variable rx_syn_flag            2            
//            95            variable rx_rst_flag            2            
//            96            variable rx_ack_flag            2            
//            97            put_tcp_packet return address            2            
//            98                   array                    2            
//            99             variable tx_length             2            
//           100            variable payload_start            2            
//           101            variable packet_length            2            
//           102               variable index               2            
//           103                 variable i                 2            
//           104             variable rx_length             2            
//           105             variable rx_start              2            
//           106            get_tcp_packet return address            2            
//           107            variable get_tcp_packet return value            2            
//           108                   array                    2            
//           109            variable number_of_bytes            2            
//           110            variable header_length            2            
//           111            variable payload_start            2            
//           112            variable total_length            2            
//           113            variable payload_length            2            
//           114            variable tcp_header_length            2            
//           115            application_put_data return address            2            
//           116                   array                    2            
//           117               variable start               2            
//           118              variable length               2            
//           119                 variable i                 2            
//           120               variable index               2            
//           121            application_get_data return address            2            
//           122            variable application_get_data return value            2            
//           123                   array                    2            
//           124               variable start               2            
//           125                 variable i                 2            
//           126               variable index               2            
//           127              variable length               2            
//           128            server return address            2            
//           129                   array                    2            
//           130                   array                    2            
//           131             variable tx_start              2            
//           132             variable tx_length             2            
//           133              variable timeout              2            
//           134            variable resend_wait            2            
//           135               variable bytes               2            
//           136            variable last_state             2            
//           137            variable new_rx_data            2            
//           138               variable state               2            
//           139             temporary_register             2            
//           140             temporary_register             2            
//           141             temporary_register             2            
//           142             temporary_register             4            
//           143             temporary_register             4            
//           144             temporary_register             4            
//           145             temporary_register             2            
//           146             temporary_register             2            
//           147             temporary_register            1024          
//           148             temporary_register             2            
//           149             temporary_register             2            
//           150             temporary_register            2048          
module server(input_eth_rx,input_socket,input_eth_rx_stb,input_socket_stb,output_socket_ack,output_eth_tx_ack,clk,rst,output_socket,output_eth_tx,output_socket_stb,output_eth_tx_stb,input_eth_rx_ack,input_socket_ack);
  integer file_count;
  real fp_value;
  input [15:0] input_eth_rx;
  input [15:0] input_socket;
  input input_eth_rx_stb;
  input input_socket_stb;
  input output_socket_ack;
  input output_eth_tx_ack;
  input clk;
  input rst;
  output [15:0] output_socket;
  output [15:0] output_eth_tx;
  output output_socket_stb;
  output output_eth_tx_stb;
  output input_eth_rx_ack;
  output input_socket_ack;
  reg [15:0] timer;
  reg timer_enable;
  reg stage_0_enable;
  reg stage_1_enable;
  reg stage_2_enable;
  reg [11:0] program_counter;
  reg [11:0] program_counter_0;
  reg [53:0] instruction_0;
  reg [5:0] opcode_0;
  reg [7:0] dest_0;
  reg [7:0] src_0;
  reg [7:0] srcb_0;
  reg [31:0] literal_0;
  reg [11:0] program_counter_1;
  reg [5:0] opcode_1;
  reg [7:0] dest_1;
  reg [31:0] register_1;
  reg [31:0] registerb_1;
  reg [31:0] literal_1;
  reg [7:0] dest_2;
  reg [31:0] result_2;
  reg write_enable_2;
  reg [15:0] address_2;
  reg [15:0] data_out_2;
  reg [15:0] data_in_2;
  reg memory_enable_2;
  reg [15:0] address_4;
  reg [31:0] data_out_4;
  reg [31:0] data_in_4;
  reg memory_enable_4;
  reg [15:0] s_output_socket_stb;
  reg [15:0] s_output_eth_tx_stb;
  reg [15:0] s_output_socket;
  reg [15:0] s_output_eth_tx;
  reg [15:0] s_input_eth_rx_ack;
  reg [15:0] s_input_socket_ack;
  reg [15:0] memory_2 [2685:0];
  reg [53:0] instructions [3316:0];
  reg [31:0] registers [150:0];

  //////////////////////////////////////////////////////////////////////////////
  // INSTRUCTION INITIALIZATION                                                 
  //                                                                            
  // Initialise the contents of the instruction memory                          
  //
  // Intruction Set
  // ==============
  // 0 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'literal'}
  // 1 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'jmp_and_link'}
  // 2 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'stop'}
  // 3 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'move'}
  // 4 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'nop'}
  // 5 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'output': 'eth_tx', 'op': 'write'}
  // 6 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'jmp_to_reg'}
  // 7 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'output': 'socket', 'op': 'write'}
  // 8 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'input': 'eth_rx', 'op': 'read'}
  // 9 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'input': 'eth_rx', 'op': 'ready'}
  // 10 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'input': 'socket', 'op': 'read'}
  // 11 {'float': False, 'literal': False, 'right': False, 'unsigned': True, 'op': '+'}
  // 12 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '&'}
  // 13 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'jmp_if_false'}
  // 14 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '+'}
  // 15 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'goto'}
  // 16 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': '~'}
  // 17 {'right': False, 'element_size': 2, 'float': False, 'unsigned': False, 'literal': False, 'op': 'memory_read_request'}
  // 18 {'right': False, 'element_size': 2, 'float': False, 'unsigned': False, 'literal': False, 'op': 'memory_read_wait'}
  // 19 {'right': False, 'element_size': 2, 'float': False, 'unsigned': False, 'literal': False, 'op': 'memory_read'}
  // 20 {'float': False, 'literal': False, 'right': False, 'unsigned': True, 'op': '<'}
  // 21 {'float': False, 'literal': False, 'right': False, 'unsigned': True, 'op': '!='}
  // 22 {'float': False, 'literal': True, 'right': False, 'unsigned': False, 'op': 'jmp_if_true'}
  // 23 {'right': False, 'element_size': 2, 'float': False, 'unsigned': False, 'literal': False, 'op': 'memory_write'}
  // 24 {'right': False, 'float': False, 'unsigned': True, 'literal': False, 'file': '/media/sdb1/Projects/Chips-Demo/source/server.h', 'line': 107, 'op': 'report'}
  // 25 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '=='}
  // 26 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '!='}
  // 27 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': '+'}
  // 28 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '<'}
  // 29 {'float': False, 'literal': False, 'right': False, 'unsigned': True, 'op': '=='}
  // 30 {'float': False, 'literal': True, 'right': False, 'unsigned': True, 'op': '|'}
  // 31 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '<='}
  // 32 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '>>'}
  // 33 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '<<'}
  // 34 {'float': False, 'literal': False, 'right': False, 'unsigned': True, 'op': '-'}
  // 35 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '-'}
  // 36 {'float': False, 'literal': False, 'right': False, 'unsigned': True, 'op': '<='}
  // 37 {'float': False, 'literal': True, 'right': True, 'unsigned': True, 'op': '|'}
  // 38 {'right': False, 'float': False, 'unsigned': False, 'literal': False, 'input': 'socket', 'op': 'ready'}
  // 39 {'float': False, 'literal': True, 'right': True, 'unsigned': False, 'op': '=='}
  // 40 {'float': False, 'literal': False, 'right': False, 'unsigned': False, 'op': 'wait_clocks'}
  // Intructions
  // ===========
  
  initial
  begin
    instructions[0] = {6'd0, 8'd10, 8'd0, 32'd0};//{'dest': 10, 'literal': 0, 'op': 'literal'}
    instructions[1] = {6'd0, 8'd11, 8'd0, 32'd0};//{'dest': 11, 'literal': 0, 'size': 4, 'signed': 4, 'op': 'literal'}
    instructions[2] = {6'd0, 8'd40, 8'd0, 32'd520};//{'dest': 40, 'literal': 520, 'op': 'literal'}
    instructions[3] = {6'd0, 8'd41, 8'd0, 32'd536};//{'dest': 41, 'literal': 536, 'op': 'literal'}
    instructions[4] = {6'd0, 8'd42, 8'd0, 32'd552};//{'dest': 42, 'literal': 552, 'op': 'literal'}
    instructions[5] = {6'd0, 8'd43, 8'd0, 32'd568};//{'dest': 43, 'literal': 568, 'op': 'literal'}
    instructions[6] = {6'd0, 8'd44, 8'd0, 32'd584};//{'dest': 44, 'literal': 584, 'op': 'literal'}
    instructions[7] = {6'd0, 8'd45, 8'd0, 32'd0};//{'dest': 45, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[8] = {6'd0, 8'd75, 8'd0, 32'd0};//{'dest': 75, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[9] = {6'd0, 8'd76, 8'd0, 32'd0};//{'dest': 76, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[10] = {6'd0, 8'd77, 8'd0, 32'd0};//{'dest': 77, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[11] = {6'd0, 8'd78, 8'd0, 32'd0};//{'dest': 78, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[12] = {6'd0, 8'd79, 8'd0, 32'd620};//{'dest': 79, 'literal': 620, 'op': 'literal'}
    instructions[13] = {6'd0, 8'd80, 8'd0, 32'd622};//{'dest': 80, 'literal': 622, 'op': 'literal'}
    instructions[14] = {6'd0, 8'd81, 8'd0, 32'd624};//{'dest': 81, 'literal': 624, 'op': 'literal'}
    instructions[15] = {6'd0, 8'd82, 8'd0, 32'd1460};//{'dest': 82, 'literal': 1460, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[16] = {6'd0, 8'd83, 8'd0, 32'd0};//{'dest': 83, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[17] = {6'd0, 8'd84, 8'd0, 32'd0};//{'dest': 84, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[18] = {6'd0, 8'd85, 8'd0, 32'd0};//{'dest': 85, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[19] = {6'd0, 8'd86, 8'd0, 32'd0};//{'dest': 86, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[20] = {6'd0, 8'd87, 8'd0, 32'd0};//{'dest': 87, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[21] = {6'd0, 8'd88, 8'd0, 32'd0};//{'dest': 88, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[22] = {6'd0, 8'd89, 8'd0, 32'd0};//{'dest': 89, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[23] = {6'd0, 8'd90, 8'd0, 32'd0};//{'dest': 90, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[24] = {6'd0, 8'd91, 8'd0, 32'd626};//{'dest': 91, 'literal': 626, 'op': 'literal'}
    instructions[25] = {6'd0, 8'd92, 8'd0, 32'd628};//{'dest': 92, 'literal': 628, 'op': 'literal'}
    instructions[26] = {6'd0, 8'd93, 8'd0, 32'd0};//{'dest': 93, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[27] = {6'd0, 8'd94, 8'd0, 32'd0};//{'dest': 94, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[28] = {6'd0, 8'd95, 8'd0, 32'd0};//{'dest': 95, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[29] = {6'd0, 8'd96, 8'd0, 32'd0};//{'dest': 96, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[30] = {6'd0, 8'd104, 8'd0, 32'd0};//{'dest': 104, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[31] = {6'd0, 8'd105, 8'd0, 32'd0};//{'dest': 105, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[32] = {6'd1, 8'd128, 8'd0, 32'd2627};//{'dest': 128, 'label': 2627, 'op': 'jmp_and_link'}
    instructions[33] = {6'd2, 8'd0, 8'd0, 32'd0};//{'op': 'stop'}
    instructions[34] = {6'd3, 8'd139, 8'd1, 32'd0};//{'dest': 139, 'src': 1, 'op': 'move'}
    instructions[35] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[36] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[37] = {6'd5, 8'd0, 8'd139, 32'd0};//{'src': 139, 'output': 'eth_tx', 'op': 'write'}
    instructions[38] = {6'd6, 8'd0, 8'd0, 32'd0};//{'src': 0, 'op': 'jmp_to_reg'}
    instructions[39] = {6'd3, 8'd139, 8'd3, 32'd0};//{'dest': 139, 'src': 3, 'op': 'move'}
    instructions[40] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[41] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[42] = {6'd7, 8'd0, 8'd139, 32'd0};//{'src': 139, 'output': 'socket', 'op': 'write'}
    instructions[43] = {6'd6, 8'd0, 8'd2, 32'd0};//{'src': 2, 'op': 'jmp_to_reg'}
    instructions[44] = {6'd8, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'input': 'eth_rx', 'op': 'read'}
    instructions[45] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[46] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[47] = {6'd3, 8'd5, 8'd139, 32'd0};//{'dest': 5, 'src': 139, 'op': 'move'}
    instructions[48] = {6'd6, 8'd0, 8'd4, 32'd0};//{'src': 4, 'op': 'jmp_to_reg'}
    instructions[49] = {6'd9, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'input': 'eth_rx', 'op': 'ready'}
    instructions[50] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[51] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[52] = {6'd3, 8'd7, 8'd139, 32'd0};//{'dest': 7, 'src': 139, 'op': 'move'}
    instructions[53] = {6'd6, 8'd0, 8'd6, 32'd0};//{'src': 6, 'op': 'jmp_to_reg'}
    instructions[54] = {6'd10, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'input': 'socket', 'op': 'read'}
    instructions[55] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[56] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[57] = {6'd3, 8'd9, 8'd139, 32'd0};//{'dest': 9, 'src': 139, 'op': 'move'}
    instructions[58] = {6'd6, 8'd0, 8'd8, 32'd0};//{'src': 8, 'op': 'jmp_to_reg'}
    instructions[59] = {6'd0, 8'd142, 8'd0, 32'd0};//{'dest': 142, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[60] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[61] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[62] = {6'd3, 8'd11, 8'd142, 32'd0};//{'dest': 11, 'src': 142, 'op': 'move'}
    instructions[63] = {6'd6, 8'd0, 8'd12, 32'd0};//{'src': 12, 'op': 'jmp_to_reg'}
    instructions[64] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[65] = {6'd3, 8'd143, 8'd11, 32'd0};//{'dest': 143, 'src': 11, 'op': 'move'}
    instructions[66] = {6'd3, 8'd144, 8'd14, 32'd0};//{'dest': 144, 'src': 14, 'op': 'move'}
    instructions[67] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[68] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[69] = {6'd11, 8'd142, 8'd143, 32'd144};//{'srcb': 144, 'src': 143, 'dest': 142, 'signed': False, 'op': '+', 'type': 'int', 'size': 4}
    instructions[70] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[71] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[72] = {6'd3, 8'd11, 8'd142, 32'd0};//{'dest': 11, 'src': 142, 'op': 'move'}
    instructions[73] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[74] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[75] = {6'd3, 8'd143, 8'd11, 32'd0};//{'dest': 143, 'src': 11, 'op': 'move'}
    instructions[76] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[77] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[78] = {6'd12, 8'd142, 8'd143, 32'd65536};//{'src': 143, 'right': 65536, 'dest': 142, 'signed': False, 'op': '&', 'type': 'int', 'size': 4}
    instructions[79] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[80] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[81] = {6'd13, 8'd0, 8'd142, 32'd99};//{'src': 142, 'label': 99, 'op': 'jmp_if_false'}
    instructions[82] = {6'd3, 8'd143, 8'd11, 32'd0};//{'dest': 143, 'src': 11, 'op': 'move'}
    instructions[83] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[84] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[85] = {6'd12, 8'd142, 8'd143, 32'd65535};//{'src': 143, 'right': 65535, 'dest': 142, 'signed': False, 'op': '&', 'type': 'int', 'size': 4}
    instructions[86] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[87] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[88] = {6'd3, 8'd11, 8'd142, 32'd0};//{'dest': 11, 'src': 142, 'op': 'move'}
    instructions[89] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[90] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[91] = {6'd3, 8'd143, 8'd11, 32'd0};//{'dest': 143, 'src': 11, 'op': 'move'}
    instructions[92] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[93] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[94] = {6'd14, 8'd142, 8'd143, 32'd1};//{'src': 143, 'right': 1, 'dest': 142, 'signed': False, 'op': '+', 'type': 'int', 'size': 4}
    instructions[95] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[96] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[97] = {6'd3, 8'd11, 8'd142, 32'd0};//{'dest': 11, 'src': 142, 'op': 'move'}
    instructions[98] = {6'd15, 8'd0, 8'd0, 32'd99};//{'label': 99, 'op': 'goto'}
    instructions[99] = {6'd6, 8'd0, 8'd13, 32'd0};//{'src': 13, 'op': 'jmp_to_reg'}
    instructions[100] = {6'd3, 8'd142, 8'd11, 32'd0};//{'dest': 142, 'src': 11, 'op': 'move'}
    instructions[101] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[102] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[103] = {6'd16, 8'd139, 8'd142, 32'd0};//{'dest': 139, 'src': 142, 'op': '~'}
    instructions[104] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[105] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[106] = {6'd3, 8'd16, 8'd139, 32'd0};//{'dest': 16, 'src': 139, 'op': 'move'}
    instructions[107] = {6'd6, 8'd0, 8'd15, 32'd0};//{'src': 15, 'op': 'jmp_to_reg'}
    instructions[108] = {6'd0, 8'd22, 8'd0, 32'd0};//{'dest': 22, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[109] = {6'd0, 8'd23, 8'd0, 32'd0};//{'dest': 23, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[110] = {6'd0, 8'd24, 8'd0, 32'd0};//{'dest': 24, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[111] = {6'd0, 8'd141, 8'd0, 32'd0};//{'dest': 141, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[112] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[113] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[114] = {6'd11, 8'd145, 8'd141, 32'd20};//{'dest': 145, 'src': 141, 'srcb': 20, 'signed': False, 'op': '+'}
    instructions[115] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[116] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[117] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20357272, 'op': 'memory_read_request'}
    instructions[118] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[119] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20357272, 'op': 'memory_read_wait'}
    instructions[120] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20357272, 'element_size': 2, 'op': 'memory_read'}
    instructions[121] = {6'd3, 8'd141, 8'd21, 32'd0};//{'dest': 141, 'src': 21, 'op': 'move'}
    instructions[122] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[123] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[124] = {6'd11, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[125] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[126] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[127] = {6'd3, 8'd22, 8'd139, 32'd0};//{'dest': 22, 'src': 139, 'op': 'move'}
    instructions[128] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[129] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[130] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[131] = {6'd11, 8'd141, 8'd140, 32'd20};//{'dest': 141, 'src': 140, 'srcb': 20, 'signed': False, 'op': '+'}
    instructions[132] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[133] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[134] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20357776, 'op': 'memory_read_request'}
    instructions[135] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[136] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20357776, 'op': 'memory_read_wait'}
    instructions[137] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20357776, 'element_size': 2, 'op': 'memory_read'}
    instructions[138] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[139] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[140] = {6'd3, 8'd23, 8'd139, 32'd0};//{'dest': 23, 'src': 139, 'op': 'move'}
    instructions[141] = {6'd3, 8'd140, 8'd22, 32'd0};//{'dest': 140, 'src': 22, 'op': 'move'}
    instructions[142] = {6'd3, 8'd141, 8'd21, 32'd0};//{'dest': 141, 'src': 21, 'op': 'move'}
    instructions[143] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[144] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[145] = {6'd20, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[146] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[147] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[148] = {6'd13, 8'd0, 8'd139, 32'd157};//{'src': 139, 'label': 157, 'op': 'jmp_if_false'}
    instructions[149] = {6'd3, 8'd140, 8'd23, 32'd0};//{'dest': 140, 'src': 23, 'op': 'move'}
    instructions[150] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[151] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[152] = {6'd14, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[153] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[154] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[155] = {6'd3, 8'd23, 8'd139, 32'd0};//{'dest': 23, 'src': 139, 'op': 'move'}
    instructions[156] = {6'd15, 8'd0, 8'd0, 32'd157};//{'label': 157, 'op': 'goto'}
    instructions[157] = {6'd3, 8'd140, 8'd22, 32'd0};//{'dest': 140, 'src': 22, 'op': 'move'}
    instructions[158] = {6'd0, 8'd145, 8'd0, 32'd0};//{'dest': 145, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[159] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[160] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[161] = {6'd11, 8'd146, 8'd145, 32'd19};//{'dest': 146, 'src': 145, 'srcb': 19, 'signed': False, 'op': '+'}
    instructions[162] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[163] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[164] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20363168, 'op': 'memory_read_request'}
    instructions[165] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[166] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20363168, 'op': 'memory_read_wait'}
    instructions[167] = {6'd19, 8'd141, 8'd146, 32'd0};//{'dest': 141, 'src': 146, 'sequence': 20363168, 'element_size': 2, 'op': 'memory_read'}
    instructions[168] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[169] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[170] = {6'd21, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[171] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[172] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[173] = {6'd22, 8'd0, 8'd139, 32'd188};//{'src': 139, 'label': 188, 'op': 'jmp_if_true'}
    instructions[174] = {6'd3, 8'd140, 8'd23, 32'd0};//{'dest': 140, 'src': 23, 'op': 'move'}
    instructions[175] = {6'd0, 8'd145, 8'd0, 32'd1};//{'dest': 145, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[176] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[177] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[178] = {6'd11, 8'd146, 8'd145, 32'd19};//{'dest': 146, 'src': 145, 'srcb': 19, 'signed': False, 'op': '+'}
    instructions[179] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[180] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[181] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20363456, 'op': 'memory_read_request'}
    instructions[182] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[183] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20363456, 'op': 'memory_read_wait'}
    instructions[184] = {6'd19, 8'd141, 8'd146, 32'd0};//{'dest': 141, 'src': 146, 'sequence': 20363456, 'element_size': 2, 'op': 'memory_read'}
    instructions[185] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[186] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[187] = {6'd21, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[188] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[189] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[190] = {6'd13, 8'd0, 8'd139, 32'd212};//{'src': 139, 'label': 212, 'op': 'jmp_if_false'}
    instructions[191] = {6'd3, 8'd139, 8'd22, 32'd0};//{'dest': 139, 'src': 22, 'op': 'move'}
    instructions[192] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[193] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[194] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[195] = {6'd11, 8'd141, 8'd140, 32'd19};//{'dest': 141, 'src': 140, 'srcb': 19, 'signed': False, 'op': '+'}
    instructions[196] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[197] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[198] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[199] = {6'd3, 8'd139, 8'd23, 32'd0};//{'dest': 139, 'src': 23, 'op': 'move'}
    instructions[200] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[201] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[202] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[203] = {6'd11, 8'd141, 8'd140, 32'd19};//{'dest': 141, 'src': 140, 'srcb': 19, 'signed': False, 'op': '+'}
    instructions[204] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[205] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[206] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[207] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[208] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[209] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[210] = {6'd3, 8'd24, 8'd139, 32'd0};//{'dest': 24, 'src': 139, 'op': 'move'}
    instructions[211] = {6'd15, 8'd0, 8'd0, 32'd212};//{'label': 212, 'op': 'goto'}
    instructions[212] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[213] = {6'd3, 8'd139, 8'd24, 32'd0};//{'dest': 139, 'src': 24, 'op': 'move'}
    instructions[214] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[215] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[216] = {6'd3, 8'd18, 8'd139, 32'd0};//{'dest': 18, 'src': 139, 'op': 'move'}
    instructions[217] = {6'd6, 8'd0, 8'd17, 32'd0};//{'src': 17, 'op': 'jmp_to_reg'}
    instructions[218] = {6'd0, 8'd32, 8'd0, 32'd0};//{'dest': 32, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[219] = {6'd0, 8'd33, 8'd0, 32'd0};//{'dest': 33, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[220] = {6'd3, 8'd139, 8'd27, 32'd0};//{'dest': 139, 'src': 27, 'op': 'move'}
    instructions[221] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[222] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[223] = {6'd24, 8'd0, 8'd139, 32'd0};//{'src': 139, 'signed': False, 'file': '/media/sdb1/Projects/Chips-Demo/source/server.h', 'line': 107, 'type': 'int', 'op': 'report'}
    instructions[224] = {6'd3, 8'd139, 8'd28, 32'd0};//{'dest': 139, 'src': 28, 'op': 'move'}
    instructions[225] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[226] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[227] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[228] = {6'd11, 8'd141, 8'd140, 32'd26};//{'dest': 141, 'src': 140, 'srcb': 26, 'signed': False, 'op': '+'}
    instructions[229] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[230] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[231] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[232] = {6'd3, 8'd139, 8'd29, 32'd0};//{'dest': 139, 'src': 29, 'op': 'move'}
    instructions[233] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[234] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[235] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[236] = {6'd11, 8'd141, 8'd140, 32'd26};//{'dest': 141, 'src': 140, 'srcb': 26, 'signed': False, 'op': '+'}
    instructions[237] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[238] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[239] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[240] = {6'd3, 8'd139, 8'd30, 32'd0};//{'dest': 139, 'src': 30, 'op': 'move'}
    instructions[241] = {6'd0, 8'd140, 8'd0, 32'd2};//{'dest': 140, 'literal': 2, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[242] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[243] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[244] = {6'd11, 8'd141, 8'd140, 32'd26};//{'dest': 141, 'src': 140, 'srcb': 26, 'signed': False, 'op': '+'}
    instructions[245] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[246] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[247] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[248] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[249] = {6'd0, 8'd140, 8'd0, 32'd3};//{'dest': 140, 'literal': 3, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[250] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[251] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[252] = {6'd11, 8'd141, 8'd140, 32'd26};//{'dest': 141, 'src': 140, 'srcb': 26, 'signed': False, 'op': '+'}
    instructions[253] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[254] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[255] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[256] = {6'd0, 8'd139, 8'd0, 32'd515};//{'dest': 139, 'literal': 515, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[257] = {6'd0, 8'd140, 8'd0, 32'd4};//{'dest': 140, 'literal': 4, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[258] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[259] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[260] = {6'd11, 8'd141, 8'd140, 32'd26};//{'dest': 141, 'src': 140, 'srcb': 26, 'signed': False, 'op': '+'}
    instructions[261] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[262] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[263] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[264] = {6'd0, 8'd139, 8'd0, 32'd1029};//{'dest': 139, 'literal': 1029, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[265] = {6'd0, 8'd140, 8'd0, 32'd5};//{'dest': 140, 'literal': 5, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[266] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[267] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[268] = {6'd11, 8'd141, 8'd140, 32'd26};//{'dest': 141, 'src': 140, 'srcb': 26, 'signed': False, 'op': '+'}
    instructions[269] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[270] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[271] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[272] = {6'd3, 8'd139, 8'd31, 32'd0};//{'dest': 139, 'src': 31, 'op': 'move'}
    instructions[273] = {6'd0, 8'd140, 8'd0, 32'd6};//{'dest': 140, 'literal': 6, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[274] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[275] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[276] = {6'd11, 8'd141, 8'd140, 32'd26};//{'dest': 141, 'src': 140, 'srcb': 26, 'signed': False, 'op': '+'}
    instructions[277] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[278] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[279] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[280] = {6'd3, 8'd140, 8'd27, 32'd0};//{'dest': 140, 'src': 27, 'op': 'move'}
    instructions[281] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[282] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[283] = {6'd3, 8'd1, 8'd140, 32'd0};//{'dest': 1, 'src': 140, 'op': 'move'}
    instructions[284] = {6'd1, 8'd0, 8'd0, 32'd34};//{'dest': 0, 'label': 34, 'op': 'jmp_and_link'}
    instructions[285] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[286] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[287] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[288] = {6'd3, 8'd33, 8'd139, 32'd0};//{'dest': 33, 'src': 139, 'op': 'move'}
    instructions[289] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[290] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[291] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[292] = {6'd3, 8'd32, 8'd139, 32'd0};//{'dest': 32, 'src': 139, 'op': 'move'}
    instructions[293] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[294] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[295] = {6'd3, 8'd140, 8'd32, 32'd0};//{'dest': 140, 'src': 32, 'op': 'move'}
    instructions[296] = {6'd3, 8'd141, 8'd27, 32'd0};//{'dest': 141, 'src': 27, 'op': 'move'}
    instructions[297] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[298] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[299] = {6'd20, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[300] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[301] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[302] = {6'd13, 8'd0, 8'd139, 32'd327};//{'src': 139, 'label': 327, 'op': 'jmp_if_false'}
    instructions[303] = {6'd3, 8'd141, 8'd33, 32'd0};//{'dest': 141, 'src': 33, 'op': 'move'}
    instructions[304] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[305] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[306] = {6'd11, 8'd145, 8'd141, 32'd26};//{'dest': 145, 'src': 141, 'srcb': 26, 'signed': False, 'op': '+'}
    instructions[307] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[308] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[309] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20371072, 'op': 'memory_read_request'}
    instructions[310] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[311] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20371072, 'op': 'memory_read_wait'}
    instructions[312] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20371072, 'element_size': 2, 'op': 'memory_read'}
    instructions[313] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[314] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[315] = {6'd3, 8'd1, 8'd140, 32'd0};//{'dest': 1, 'src': 140, 'op': 'move'}
    instructions[316] = {6'd1, 8'd0, 8'd0, 32'd34};//{'dest': 0, 'label': 34, 'op': 'jmp_and_link'}
    instructions[317] = {6'd3, 8'd139, 8'd33, 32'd0};//{'dest': 139, 'src': 33, 'op': 'move'}
    instructions[318] = {6'd14, 8'd33, 8'd33, 32'd1};//{'src': 33, 'right': 1, 'dest': 33, 'signed': False, 'op': '+', 'size': 2}
    instructions[319] = {6'd3, 8'd140, 8'd32, 32'd0};//{'dest': 140, 'src': 32, 'op': 'move'}
    instructions[320] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[321] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[322] = {6'd14, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[323] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[324] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[325] = {6'd3, 8'd32, 8'd139, 32'd0};//{'dest': 32, 'src': 139, 'op': 'move'}
    instructions[326] = {6'd15, 8'd0, 8'd0, 32'd293};//{'label': 293, 'op': 'goto'}
    instructions[327] = {6'd6, 8'd0, 8'd25, 32'd0};//{'src': 25, 'op': 'jmp_to_reg'}
    instructions[328] = {6'd0, 8'd37, 8'd0, 32'd0};//{'dest': 37, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[329] = {6'd0, 8'd38, 8'd0, 32'd0};//{'dest': 38, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[330] = {6'd0, 8'd39, 8'd0, 32'd0};//{'dest': 39, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[331] = {6'd1, 8'd6, 8'd0, 32'd49};//{'dest': 6, 'label': 49, 'op': 'jmp_and_link'}
    instructions[332] = {6'd3, 8'd140, 8'd7, 32'd0};//{'dest': 140, 'src': 7, 'op': 'move'}
    instructions[333] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[334] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[335] = {6'd25, 8'd139, 8'd140, 32'd0};//{'src': 140, 'right': 0, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[336] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[337] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[338] = {6'd13, 8'd0, 8'd139, 32'd345};//{'src': 139, 'label': 345, 'op': 'jmp_if_false'}
    instructions[339] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[340] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[341] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[342] = {6'd3, 8'd35, 8'd139, 32'd0};//{'dest': 35, 'src': 139, 'op': 'move'}
    instructions[343] = {6'd6, 8'd0, 8'd34, 32'd0};//{'src': 34, 'op': 'jmp_to_reg'}
    instructions[344] = {6'd15, 8'd0, 8'd0, 32'd345};//{'label': 345, 'op': 'goto'}
    instructions[345] = {6'd1, 8'd4, 8'd0, 32'd44};//{'dest': 4, 'label': 44, 'op': 'jmp_and_link'}
    instructions[346] = {6'd3, 8'd139, 8'd5, 32'd0};//{'dest': 139, 'src': 5, 'op': 'move'}
    instructions[347] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[348] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[349] = {6'd3, 8'd37, 8'd139, 32'd0};//{'dest': 37, 'src': 139, 'op': 'move'}
    instructions[350] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[351] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[352] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[353] = {6'd3, 8'd38, 8'd139, 32'd0};//{'dest': 38, 'src': 139, 'op': 'move'}
    instructions[354] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[355] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[356] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[357] = {6'd3, 8'd39, 8'd139, 32'd0};//{'dest': 39, 'src': 139, 'op': 'move'}
    instructions[358] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[359] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[360] = {6'd3, 8'd140, 8'd39, 32'd0};//{'dest': 140, 'src': 39, 'op': 'move'}
    instructions[361] = {6'd3, 8'd141, 8'd37, 32'd0};//{'dest': 141, 'src': 37, 'op': 'move'}
    instructions[362] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[363] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[364] = {6'd20, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[365] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[366] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[367] = {6'd13, 8'd0, 8'd139, 32'd387};//{'src': 139, 'label': 387, 'op': 'jmp_if_false'}
    instructions[368] = {6'd1, 8'd4, 8'd0, 32'd44};//{'dest': 4, 'label': 44, 'op': 'jmp_and_link'}
    instructions[369] = {6'd3, 8'd139, 8'd5, 32'd0};//{'dest': 139, 'src': 5, 'op': 'move'}
    instructions[370] = {6'd3, 8'd140, 8'd38, 32'd0};//{'dest': 140, 'src': 38, 'op': 'move'}
    instructions[371] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[372] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[373] = {6'd11, 8'd141, 8'd140, 32'd36};//{'dest': 141, 'src': 140, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[374] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[375] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[376] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[377] = {6'd3, 8'd139, 8'd38, 32'd0};//{'dest': 139, 'src': 38, 'op': 'move'}
    instructions[378] = {6'd14, 8'd38, 8'd38, 32'd1};//{'src': 38, 'right': 1, 'dest': 38, 'signed': False, 'op': '+', 'size': 2}
    instructions[379] = {6'd3, 8'd140, 8'd39, 32'd0};//{'dest': 140, 'src': 39, 'op': 'move'}
    instructions[380] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[381] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[382] = {6'd14, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[383] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[384] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[385] = {6'd3, 8'd39, 8'd139, 32'd0};//{'dest': 39, 'src': 139, 'op': 'move'}
    instructions[386] = {6'd15, 8'd0, 8'd0, 32'd358};//{'label': 358, 'op': 'goto'}
    instructions[387] = {6'd0, 8'd141, 8'd0, 32'd0};//{'dest': 141, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[388] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[389] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[390] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[391] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[392] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[393] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20372080, 'op': 'memory_read_request'}
    instructions[394] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[395] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20372080, 'op': 'memory_read_wait'}
    instructions[396] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20372080, 'element_size': 2, 'op': 'memory_read'}
    instructions[397] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[398] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[399] = {6'd26, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[400] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[401] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[402] = {6'd13, 8'd0, 8'd139, 32'd416};//{'src': 139, 'label': 416, 'op': 'jmp_if_false'}
    instructions[403] = {6'd0, 8'd141, 8'd0, 32'd0};//{'dest': 141, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[404] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[405] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[406] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[407] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[408] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[409] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20372368, 'op': 'memory_read_request'}
    instructions[410] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[411] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20372368, 'op': 'memory_read_wait'}
    instructions[412] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20372368, 'element_size': 2, 'op': 'memory_read'}
    instructions[413] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[414] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[415] = {6'd26, 8'd139, 8'd140, 32'd65535};//{'src': 140, 'right': 65535, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[416] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[417] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[418] = {6'd13, 8'd0, 8'd139, 32'd425};//{'src': 139, 'label': 425, 'op': 'jmp_if_false'}
    instructions[419] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[420] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[421] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[422] = {6'd3, 8'd35, 8'd139, 32'd0};//{'dest': 35, 'src': 139, 'op': 'move'}
    instructions[423] = {6'd6, 8'd0, 8'd34, 32'd0};//{'src': 34, 'op': 'jmp_to_reg'}
    instructions[424] = {6'd15, 8'd0, 8'd0, 32'd425};//{'label': 425, 'op': 'goto'}
    instructions[425] = {6'd0, 8'd141, 8'd0, 32'd1};//{'dest': 141, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[426] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[427] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[428] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[429] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[430] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[431] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20372944, 'op': 'memory_read_request'}
    instructions[432] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[433] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20372944, 'op': 'memory_read_wait'}
    instructions[434] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20372944, 'element_size': 2, 'op': 'memory_read'}
    instructions[435] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[436] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[437] = {6'd26, 8'd139, 8'd140, 32'd515};//{'src': 140, 'right': 515, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[438] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[439] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[440] = {6'd13, 8'd0, 8'd139, 32'd454};//{'src': 139, 'label': 454, 'op': 'jmp_if_false'}
    instructions[441] = {6'd0, 8'd141, 8'd0, 32'd1};//{'dest': 141, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[442] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[443] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[444] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[445] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[446] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[447] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20373232, 'op': 'memory_read_request'}
    instructions[448] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[449] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20373232, 'op': 'memory_read_wait'}
    instructions[450] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20373232, 'element_size': 2, 'op': 'memory_read'}
    instructions[451] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[452] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[453] = {6'd26, 8'd139, 8'd140, 32'd65535};//{'src': 140, 'right': 65535, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[454] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[455] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[456] = {6'd13, 8'd0, 8'd139, 32'd463};//{'src': 139, 'label': 463, 'op': 'jmp_if_false'}
    instructions[457] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[458] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[459] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[460] = {6'd3, 8'd35, 8'd139, 32'd0};//{'dest': 35, 'src': 139, 'op': 'move'}
    instructions[461] = {6'd6, 8'd0, 8'd34, 32'd0};//{'src': 34, 'op': 'jmp_to_reg'}
    instructions[462] = {6'd15, 8'd0, 8'd0, 32'd463};//{'label': 463, 'op': 'goto'}
    instructions[463] = {6'd0, 8'd141, 8'd0, 32'd2};//{'dest': 141, 'literal': 2, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[464] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[465] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[466] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[467] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[468] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[469] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20373872, 'op': 'memory_read_request'}
    instructions[470] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[471] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20373872, 'op': 'memory_read_wait'}
    instructions[472] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20373872, 'element_size': 2, 'op': 'memory_read'}
    instructions[473] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[474] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[475] = {6'd26, 8'd139, 8'd140, 32'd1029};//{'src': 140, 'right': 1029, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[476] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[477] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[478] = {6'd13, 8'd0, 8'd139, 32'd492};//{'src': 139, 'label': 492, 'op': 'jmp_if_false'}
    instructions[479] = {6'd0, 8'd141, 8'd0, 32'd2};//{'dest': 141, 'literal': 2, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[480] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[481] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[482] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[483] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[484] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[485] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20374160, 'op': 'memory_read_request'}
    instructions[486] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[487] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20374160, 'op': 'memory_read_wait'}
    instructions[488] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20374160, 'element_size': 2, 'op': 'memory_read'}
    instructions[489] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[490] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[491] = {6'd26, 8'd139, 8'd140, 32'd65535};//{'src': 140, 'right': 65535, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[492] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[493] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[494] = {6'd13, 8'd0, 8'd139, 32'd501};//{'src': 139, 'label': 501, 'op': 'jmp_if_false'}
    instructions[495] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[496] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[497] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[498] = {6'd3, 8'd35, 8'd139, 32'd0};//{'dest': 35, 'src': 139, 'op': 'move'}
    instructions[499] = {6'd6, 8'd0, 8'd34, 32'd0};//{'src': 34, 'op': 'jmp_to_reg'}
    instructions[500] = {6'd15, 8'd0, 8'd0, 32'd501};//{'label': 501, 'op': 'goto'}
    instructions[501] = {6'd0, 8'd141, 8'd0, 32'd6};//{'dest': 141, 'literal': 6, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[502] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[503] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[504] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[505] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[506] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[507] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20374736, 'op': 'memory_read_request'}
    instructions[508] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[509] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20374736, 'op': 'memory_read_wait'}
    instructions[510] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20374736, 'element_size': 2, 'op': 'memory_read'}
    instructions[511] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[512] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[513] = {6'd25, 8'd139, 8'd140, 32'd2054};//{'src': 140, 'right': 2054, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[514] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[515] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[516] = {6'd13, 8'd0, 8'd139, 32'd749};//{'src': 139, 'label': 749, 'op': 'jmp_if_false'}
    instructions[517] = {6'd0, 8'd141, 8'd0, 32'd10};//{'dest': 141, 'literal': 10, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[518] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[519] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[520] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[521] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[522] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[523] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20375240, 'op': 'memory_read_request'}
    instructions[524] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[525] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20375240, 'op': 'memory_read_wait'}
    instructions[526] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20375240, 'element_size': 2, 'op': 'memory_read'}
    instructions[527] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[528] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[529] = {6'd25, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[530] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[531] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[532] = {6'd13, 8'd0, 8'd139, 32'd743};//{'src': 139, 'label': 743, 'op': 'jmp_if_false'}
    instructions[533] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[534] = {6'd0, 8'd140, 8'd0, 32'd7};//{'dest': 140, 'literal': 7, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[535] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[536] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[537] = {6'd27, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': True, 'op': '+'}
    instructions[538] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[539] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[540] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[541] = {6'd0, 8'd139, 8'd0, 32'd2048};//{'dest': 139, 'literal': 2048, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[542] = {6'd0, 8'd140, 8'd0, 32'd8};//{'dest': 140, 'literal': 8, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[543] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[544] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[545] = {6'd27, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': True, 'op': '+'}
    instructions[546] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[547] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[548] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[549] = {6'd0, 8'd139, 8'd0, 32'd1540};//{'dest': 139, 'literal': 1540, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[550] = {6'd0, 8'd140, 8'd0, 32'd9};//{'dest': 140, 'literal': 9, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[551] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[552] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[553] = {6'd27, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': True, 'op': '+'}
    instructions[554] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[555] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[556] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[557] = {6'd0, 8'd139, 8'd0, 32'd2};//{'dest': 139, 'literal': 2, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[558] = {6'd0, 8'd140, 8'd0, 32'd10};//{'dest': 140, 'literal': 10, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[559] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[560] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[561] = {6'd27, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': True, 'op': '+'}
    instructions[562] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[563] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[564] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[565] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[566] = {6'd0, 8'd140, 8'd0, 32'd11};//{'dest': 140, 'literal': 11, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[567] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[568] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[569] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[570] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[571] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[572] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[573] = {6'd0, 8'd139, 8'd0, 32'd515};//{'dest': 139, 'literal': 515, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[574] = {6'd0, 8'd140, 8'd0, 32'd12};//{'dest': 140, 'literal': 12, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[575] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[576] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[577] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[578] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[579] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[580] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[581] = {6'd0, 8'd139, 8'd0, 32'd1029};//{'dest': 139, 'literal': 1029, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[582] = {6'd0, 8'd140, 8'd0, 32'd13};//{'dest': 140, 'literal': 13, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[583] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[584] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[585] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[586] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[587] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[588] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[589] = {6'd0, 8'd139, 8'd0, 32'd49320};//{'dest': 139, 'literal': 49320, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[590] = {6'd0, 8'd140, 8'd0, 32'd14};//{'dest': 140, 'literal': 14, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[591] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[592] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[593] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[594] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[595] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[596] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[597] = {6'd0, 8'd139, 8'd0, 32'd257};//{'dest': 139, 'literal': 257, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[598] = {6'd0, 8'd140, 8'd0, 32'd15};//{'dest': 140, 'literal': 15, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[599] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[600] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[601] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[602] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[603] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[604] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[605] = {6'd0, 8'd145, 8'd0, 32'd11};//{'dest': 145, 'literal': 11, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[606] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[607] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[608] = {6'd11, 8'd146, 8'd145, 32'd36};//{'dest': 146, 'src': 145, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[609] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[610] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[611] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20379120, 'op': 'memory_read_request'}
    instructions[612] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[613] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20379120, 'op': 'memory_read_wait'}
    instructions[614] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20379120, 'element_size': 2, 'op': 'memory_read'}
    instructions[615] = {6'd0, 8'd140, 8'd0, 32'd16};//{'dest': 140, 'literal': 16, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[616] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[617] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[618] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[619] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[620] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[621] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[622] = {6'd0, 8'd145, 8'd0, 32'd12};//{'dest': 145, 'literal': 12, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[623] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[624] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[625] = {6'd11, 8'd146, 8'd145, 32'd36};//{'dest': 146, 'src': 145, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[626] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[627] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[628] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20379552, 'op': 'memory_read_request'}
    instructions[629] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[630] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20379552, 'op': 'memory_read_wait'}
    instructions[631] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20379552, 'element_size': 2, 'op': 'memory_read'}
    instructions[632] = {6'd0, 8'd140, 8'd0, 32'd17};//{'dest': 140, 'literal': 17, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[633] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[634] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[635] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[636] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[637] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[638] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[639] = {6'd0, 8'd145, 8'd0, 32'd13};//{'dest': 145, 'literal': 13, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[640] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[641] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[642] = {6'd11, 8'd146, 8'd145, 32'd36};//{'dest': 146, 'src': 145, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[643] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[644] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[645] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20379984, 'op': 'memory_read_request'}
    instructions[646] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[647] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20379984, 'op': 'memory_read_wait'}
    instructions[648] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20379984, 'element_size': 2, 'op': 'memory_read'}
    instructions[649] = {6'd0, 8'd140, 8'd0, 32'd18};//{'dest': 140, 'literal': 18, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[650] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[651] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[652] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[653] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[654] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[655] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[656] = {6'd0, 8'd145, 8'd0, 32'd14};//{'dest': 145, 'literal': 14, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[657] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[658] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[659] = {6'd11, 8'd146, 8'd145, 32'd36};//{'dest': 146, 'src': 145, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[660] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[661] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[662] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20380416, 'op': 'memory_read_request'}
    instructions[663] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[664] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20380416, 'op': 'memory_read_wait'}
    instructions[665] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20380416, 'element_size': 2, 'op': 'memory_read'}
    instructions[666] = {6'd0, 8'd140, 8'd0, 32'd19};//{'dest': 140, 'literal': 19, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[667] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[668] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[669] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[670] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[671] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[672] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[673] = {6'd0, 8'd145, 8'd0, 32'd15};//{'dest': 145, 'literal': 15, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[674] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[675] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[676] = {6'd11, 8'd146, 8'd145, 32'd36};//{'dest': 146, 'src': 145, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[677] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[678] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[679] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20380848, 'op': 'memory_read_request'}
    instructions[680] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[681] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20380848, 'op': 'memory_read_wait'}
    instructions[682] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20380848, 'element_size': 2, 'op': 'memory_read'}
    instructions[683] = {6'd0, 8'd140, 8'd0, 32'd20};//{'dest': 140, 'literal': 20, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[684] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[685] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[686] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[687] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[688] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[689] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[690] = {6'd3, 8'd147, 8'd10, 32'd0};//{'dest': 147, 'src': 10, 'op': 'move'}
    instructions[691] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[692] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[693] = {6'd3, 8'd26, 8'd147, 32'd0};//{'dest': 26, 'src': 147, 'op': 'move'}
    instructions[694] = {6'd0, 8'd140, 8'd0, 32'd64};//{'dest': 140, 'literal': 64, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[695] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[696] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[697] = {6'd3, 8'd27, 8'd140, 32'd0};//{'dest': 27, 'src': 140, 'op': 'move'}
    instructions[698] = {6'd0, 8'd141, 8'd0, 32'd11};//{'dest': 141, 'literal': 11, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[699] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[700] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[701] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[702] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[703] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[704] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20385736, 'op': 'memory_read_request'}
    instructions[705] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[706] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20385736, 'op': 'memory_read_wait'}
    instructions[707] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20385736, 'element_size': 2, 'op': 'memory_read'}
    instructions[708] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[709] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[710] = {6'd3, 8'd28, 8'd140, 32'd0};//{'dest': 28, 'src': 140, 'op': 'move'}
    instructions[711] = {6'd0, 8'd141, 8'd0, 32'd12};//{'dest': 141, 'literal': 12, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[712] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[713] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[714] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[715] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[716] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[717] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20385944, 'op': 'memory_read_request'}
    instructions[718] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[719] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20385944, 'op': 'memory_read_wait'}
    instructions[720] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20385944, 'element_size': 2, 'op': 'memory_read'}
    instructions[721] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[722] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[723] = {6'd3, 8'd29, 8'd140, 32'd0};//{'dest': 29, 'src': 140, 'op': 'move'}
    instructions[724] = {6'd0, 8'd141, 8'd0, 32'd13};//{'dest': 141, 'literal': 13, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[725] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[726] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[727] = {6'd11, 8'd145, 8'd141, 32'd36};//{'dest': 145, 'src': 141, 'srcb': 36, 'signed': False, 'op': '+'}
    instructions[728] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[729] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[730] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20386088, 'op': 'memory_read_request'}
    instructions[731] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[732] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20386088, 'op': 'memory_read_wait'}
    instructions[733] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20386088, 'element_size': 2, 'op': 'memory_read'}
    instructions[734] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[735] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[736] = {6'd3, 8'd30, 8'd140, 32'd0};//{'dest': 30, 'src': 140, 'op': 'move'}
    instructions[737] = {6'd0, 8'd140, 8'd0, 32'd2054};//{'dest': 140, 'literal': 2054, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[738] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[739] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[740] = {6'd3, 8'd31, 8'd140, 32'd0};//{'dest': 31, 'src': 140, 'op': 'move'}
    instructions[741] = {6'd1, 8'd25, 8'd0, 32'd218};//{'dest': 25, 'label': 218, 'op': 'jmp_and_link'}
    instructions[742] = {6'd15, 8'd0, 8'd0, 32'd743};//{'label': 743, 'op': 'goto'}
    instructions[743] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[744] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[745] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[746] = {6'd3, 8'd35, 8'd139, 32'd0};//{'dest': 35, 'src': 139, 'op': 'move'}
    instructions[747] = {6'd6, 8'd0, 8'd34, 32'd0};//{'src': 34, 'op': 'jmp_to_reg'}
    instructions[748] = {6'd15, 8'd0, 8'd0, 32'd749};//{'label': 749, 'op': 'goto'}
    instructions[749] = {6'd3, 8'd139, 8'd37, 32'd0};//{'dest': 139, 'src': 37, 'op': 'move'}
    instructions[750] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[751] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[752] = {6'd3, 8'd35, 8'd139, 32'd0};//{'dest': 35, 'src': 139, 'op': 'move'}
    instructions[753] = {6'd6, 8'd0, 8'd34, 32'd0};//{'src': 34, 'op': 'jmp_to_reg'}
    instructions[754] = {6'd0, 8'd50, 8'd0, 32'd0};//{'dest': 50, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[755] = {6'd0, 8'd51, 8'd0, 32'd0};//{'dest': 51, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[756] = {6'd0, 8'd52, 8'd0, 32'd600};//{'dest': 52, 'literal': 600, 'op': 'literal'}
    instructions[757] = {6'd0, 8'd53, 8'd0, 32'd0};//{'dest': 53, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[758] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[759] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[760] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[761] = {6'd3, 8'd53, 8'd139, 32'd0};//{'dest': 53, 'src': 139, 'op': 'move'}
    instructions[762] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[763] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[764] = {6'd3, 8'd140, 8'd53, 32'd0};//{'dest': 140, 'src': 53, 'op': 'move'}
    instructions[765] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[766] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[767] = {6'd28, 8'd139, 8'd140, 32'd16};//{'src': 140, 'right': 16, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[768] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[769] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[770] = {6'd13, 8'd0, 8'd139, 32'd814};//{'src': 139, 'label': 814, 'op': 'jmp_if_false'}
    instructions[771] = {6'd3, 8'd141, 8'd53, 32'd0};//{'dest': 141, 'src': 53, 'op': 'move'}
    instructions[772] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[773] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[774] = {6'd11, 8'd145, 8'd141, 32'd40};//{'dest': 145, 'src': 141, 'srcb': 40, 'signed': False, 'op': '+'}
    instructions[775] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[776] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[777] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20386448, 'op': 'memory_read_request'}
    instructions[778] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[779] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20386448, 'op': 'memory_read_wait'}
    instructions[780] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20386448, 'element_size': 2, 'op': 'memory_read'}
    instructions[781] = {6'd3, 8'd141, 8'd48, 32'd0};//{'dest': 141, 'src': 48, 'op': 'move'}
    instructions[782] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[783] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[784] = {6'd29, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[785] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[786] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[787] = {6'd13, 8'd0, 8'd139, 32'd802};//{'src': 139, 'label': 802, 'op': 'jmp_if_false'}
    instructions[788] = {6'd3, 8'd141, 8'd53, 32'd0};//{'dest': 141, 'src': 53, 'op': 'move'}
    instructions[789] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[790] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[791] = {6'd11, 8'd145, 8'd141, 32'd41};//{'dest': 145, 'src': 141, 'srcb': 41, 'signed': False, 'op': '+'}
    instructions[792] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[793] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[794] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20386736, 'op': 'memory_read_request'}
    instructions[795] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[796] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20386736, 'op': 'memory_read_wait'}
    instructions[797] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20386736, 'element_size': 2, 'op': 'memory_read'}
    instructions[798] = {6'd3, 8'd141, 8'd49, 32'd0};//{'dest': 141, 'src': 49, 'op': 'move'}
    instructions[799] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[800] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[801] = {6'd29, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[802] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[803] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[804] = {6'd13, 8'd0, 8'd139, 32'd811};//{'src': 139, 'label': 811, 'op': 'jmp_if_false'}
    instructions[805] = {6'd3, 8'd139, 8'd53, 32'd0};//{'dest': 139, 'src': 53, 'op': 'move'}
    instructions[806] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[807] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[808] = {6'd3, 8'd47, 8'd139, 32'd0};//{'dest': 47, 'src': 139, 'op': 'move'}
    instructions[809] = {6'd6, 8'd0, 8'd46, 32'd0};//{'src': 46, 'op': 'jmp_to_reg'}
    instructions[810] = {6'd15, 8'd0, 8'd0, 32'd811};//{'label': 811, 'op': 'goto'}
    instructions[811] = {6'd3, 8'd139, 8'd53, 32'd0};//{'dest': 139, 'src': 53, 'op': 'move'}
    instructions[812] = {6'd14, 8'd53, 8'd53, 32'd1};//{'src': 53, 'right': 1, 'dest': 53, 'signed': False, 'op': '+', 'size': 2}
    instructions[813] = {6'd15, 8'd0, 8'd0, 32'd762};//{'label': 762, 'op': 'goto'}
    instructions[814] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[815] = {6'd0, 8'd140, 8'd0, 32'd7};//{'dest': 140, 'literal': 7, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[816] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[817] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[818] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[819] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[820] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[821] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[822] = {6'd0, 8'd139, 8'd0, 32'd2048};//{'dest': 139, 'literal': 2048, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[823] = {6'd0, 8'd140, 8'd0, 32'd8};//{'dest': 140, 'literal': 8, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[824] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[825] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[826] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[827] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[828] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[829] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[830] = {6'd0, 8'd139, 8'd0, 32'd1540};//{'dest': 139, 'literal': 1540, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[831] = {6'd0, 8'd140, 8'd0, 32'd9};//{'dest': 140, 'literal': 9, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[832] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[833] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[834] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[835] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[836] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[837] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[838] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[839] = {6'd0, 8'd140, 8'd0, 32'd10};//{'dest': 140, 'literal': 10, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[840] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[841] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[842] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[843] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[844] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[845] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[846] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[847] = {6'd0, 8'd140, 8'd0, 32'd11};//{'dest': 140, 'literal': 11, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[848] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[849] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[850] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[851] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[852] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[853] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[854] = {6'd0, 8'd139, 8'd0, 32'd515};//{'dest': 139, 'literal': 515, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[855] = {6'd0, 8'd140, 8'd0, 32'd12};//{'dest': 140, 'literal': 12, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[856] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[857] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[858] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[859] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[860] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[861] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[862] = {6'd0, 8'd139, 8'd0, 32'd1029};//{'dest': 139, 'literal': 1029, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[863] = {6'd0, 8'd140, 8'd0, 32'd13};//{'dest': 140, 'literal': 13, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[864] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[865] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[866] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[867] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[868] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[869] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[870] = {6'd0, 8'd139, 8'd0, 32'd49320};//{'dest': 139, 'literal': 49320, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[871] = {6'd0, 8'd140, 8'd0, 32'd14};//{'dest': 140, 'literal': 14, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[872] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[873] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[874] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[875] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[876] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[877] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[878] = {6'd0, 8'd139, 8'd0, 32'd257};//{'dest': 139, 'literal': 257, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[879] = {6'd0, 8'd140, 8'd0, 32'd15};//{'dest': 140, 'literal': 15, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[880] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[881] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[882] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[883] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[884] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[885] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[886] = {6'd3, 8'd139, 8'd48, 32'd0};//{'dest': 139, 'src': 48, 'op': 'move'}
    instructions[887] = {6'd0, 8'd140, 8'd0, 32'd19};//{'dest': 140, 'literal': 19, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[888] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[889] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[890] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[891] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[892] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[893] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[894] = {6'd3, 8'd139, 8'd49, 32'd0};//{'dest': 139, 'src': 49, 'op': 'move'}
    instructions[895] = {6'd0, 8'd140, 8'd0, 32'd20};//{'dest': 140, 'literal': 20, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[896] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[897] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[898] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[899] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[900] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[901] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[902] = {6'd3, 8'd147, 8'd10, 32'd0};//{'dest': 147, 'src': 10, 'op': 'move'}
    instructions[903] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[904] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[905] = {6'd3, 8'd26, 8'd147, 32'd0};//{'dest': 26, 'src': 147, 'op': 'move'}
    instructions[906] = {6'd0, 8'd140, 8'd0, 32'd64};//{'dest': 140, 'literal': 64, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[907] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[908] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[909] = {6'd3, 8'd27, 8'd140, 32'd0};//{'dest': 27, 'src': 140, 'op': 'move'}
    instructions[910] = {6'd0, 8'd140, 8'd0, 32'd65535};//{'dest': 140, 'literal': 65535, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[911] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[912] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[913] = {6'd3, 8'd28, 8'd140, 32'd0};//{'dest': 28, 'src': 140, 'op': 'move'}
    instructions[914] = {6'd0, 8'd140, 8'd0, 32'd65535};//{'dest': 140, 'literal': 65535, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[915] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[916] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[917] = {6'd3, 8'd29, 8'd140, 32'd0};//{'dest': 29, 'src': 140, 'op': 'move'}
    instructions[918] = {6'd0, 8'd140, 8'd0, 32'd65535};//{'dest': 140, 'literal': 65535, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[919] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[920] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[921] = {6'd3, 8'd30, 8'd140, 32'd0};//{'dest': 30, 'src': 140, 'op': 'move'}
    instructions[922] = {6'd0, 8'd140, 8'd0, 32'd2054};//{'dest': 140, 'literal': 2054, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[923] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[924] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[925] = {6'd3, 8'd31, 8'd140, 32'd0};//{'dest': 31, 'src': 140, 'op': 'move'}
    instructions[926] = {6'd1, 8'd25, 8'd0, 32'd218};//{'dest': 25, 'label': 218, 'op': 'jmp_and_link'}
    instructions[927] = {6'd1, 8'd4, 8'd0, 32'd44};//{'dest': 4, 'label': 44, 'op': 'jmp_and_link'}
    instructions[928] = {6'd3, 8'd139, 8'd5, 32'd0};//{'dest': 139, 'src': 5, 'op': 'move'}
    instructions[929] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[930] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[931] = {6'd3, 8'd50, 8'd139, 32'd0};//{'dest': 50, 'src': 139, 'op': 'move'}
    instructions[932] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[933] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[934] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[935] = {6'd3, 8'd53, 8'd139, 32'd0};//{'dest': 53, 'src': 139, 'op': 'move'}
    instructions[936] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[937] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[938] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[939] = {6'd3, 8'd51, 8'd139, 32'd0};//{'dest': 51, 'src': 139, 'op': 'move'}
    instructions[940] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[941] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[942] = {6'd3, 8'd140, 8'd51, 32'd0};//{'dest': 140, 'src': 51, 'op': 'move'}
    instructions[943] = {6'd3, 8'd141, 8'd50, 32'd0};//{'dest': 141, 'src': 50, 'op': 'move'}
    instructions[944] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[945] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[946] = {6'd20, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[947] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[948] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[949] = {6'd13, 8'd0, 8'd139, 32'd979};//{'src': 139, 'label': 979, 'op': 'jmp_if_false'}
    instructions[950] = {6'd3, 8'd140, 8'd53, 32'd0};//{'dest': 140, 'src': 53, 'op': 'move'}
    instructions[951] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[952] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[953] = {6'd28, 8'd139, 8'd140, 32'd16};//{'src': 140, 'right': 16, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[954] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[955] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[956] = {6'd13, 8'd0, 8'd139, 32'd967};//{'src': 139, 'label': 967, 'op': 'jmp_if_false'}
    instructions[957] = {6'd1, 8'd4, 8'd0, 32'd44};//{'dest': 4, 'label': 44, 'op': 'jmp_and_link'}
    instructions[958] = {6'd3, 8'd139, 8'd5, 32'd0};//{'dest': 139, 'src': 5, 'op': 'move'}
    instructions[959] = {6'd3, 8'd140, 8'd53, 32'd0};//{'dest': 140, 'src': 53, 'op': 'move'}
    instructions[960] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[961] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[962] = {6'd11, 8'd141, 8'd140, 32'd52};//{'dest': 141, 'src': 140, 'srcb': 52, 'signed': False, 'op': '+'}
    instructions[963] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[964] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[965] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[966] = {6'd15, 8'd0, 8'd0, 32'd969};//{'label': 969, 'op': 'goto'}
    instructions[967] = {6'd1, 8'd4, 8'd0, 32'd44};//{'dest': 4, 'label': 44, 'op': 'jmp_and_link'}
    instructions[968] = {6'd3, 8'd139, 8'd5, 32'd0};//{'dest': 139, 'src': 5, 'op': 'move'}
    instructions[969] = {6'd3, 8'd139, 8'd53, 32'd0};//{'dest': 139, 'src': 53, 'op': 'move'}
    instructions[970] = {6'd14, 8'd53, 8'd53, 32'd1};//{'src': 53, 'right': 1, 'dest': 53, 'signed': False, 'op': '+', 'size': 2}
    instructions[971] = {6'd3, 8'd140, 8'd51, 32'd0};//{'dest': 140, 'src': 51, 'op': 'move'}
    instructions[972] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[973] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[974] = {6'd14, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[975] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[976] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[977] = {6'd3, 8'd51, 8'd139, 32'd0};//{'dest': 51, 'src': 139, 'op': 'move'}
    instructions[978] = {6'd15, 8'd0, 8'd0, 32'd940};//{'label': 940, 'op': 'goto'}
    instructions[979] = {6'd0, 8'd141, 8'd0, 32'd6};//{'dest': 141, 'literal': 6, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[980] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[981] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[982] = {6'd11, 8'd145, 8'd141, 32'd52};//{'dest': 145, 'src': 141, 'srcb': 52, 'signed': False, 'op': '+'}
    instructions[983] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[984] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[985] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20395936, 'op': 'memory_read_request'}
    instructions[986] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[987] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20395936, 'op': 'memory_read_wait'}
    instructions[988] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20395936, 'element_size': 2, 'op': 'memory_read'}
    instructions[989] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[990] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[991] = {6'd25, 8'd139, 8'd140, 32'd2054};//{'src': 140, 'right': 2054, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[992] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[993] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[994] = {6'd13, 8'd0, 8'd139, 32'd1008};//{'src': 139, 'label': 1008, 'op': 'jmp_if_false'}
    instructions[995] = {6'd0, 8'd141, 8'd0, 32'd10};//{'dest': 141, 'literal': 10, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[996] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[997] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[998] = {6'd11, 8'd145, 8'd141, 32'd52};//{'dest': 145, 'src': 141, 'srcb': 52, 'signed': False, 'op': '+'}
    instructions[999] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1000] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1001] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20396224, 'op': 'memory_read_request'}
    instructions[1002] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1003] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20396224, 'op': 'memory_read_wait'}
    instructions[1004] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20396224, 'element_size': 2, 'op': 'memory_read'}
    instructions[1005] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1006] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1007] = {6'd25, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[1008] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1009] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1010] = {6'd13, 8'd0, 8'd139, 32'd1139};//{'src': 139, 'label': 1139, 'op': 'jmp_if_false'}
    instructions[1011] = {6'd0, 8'd141, 8'd0, 32'd14};//{'dest': 141, 'literal': 14, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1012] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1013] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1014] = {6'd11, 8'd145, 8'd141, 32'd52};//{'dest': 145, 'src': 141, 'srcb': 52, 'signed': False, 'op': '+'}
    instructions[1015] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1016] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1017] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20396800, 'op': 'memory_read_request'}
    instructions[1018] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1019] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20396800, 'op': 'memory_read_wait'}
    instructions[1020] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20396800, 'element_size': 2, 'op': 'memory_read'}
    instructions[1021] = {6'd3, 8'd141, 8'd48, 32'd0};//{'dest': 141, 'src': 48, 'op': 'move'}
    instructions[1022] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1023] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1024] = {6'd29, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[1025] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1026] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1027] = {6'd13, 8'd0, 8'd139, 32'd1042};//{'src': 139, 'label': 1042, 'op': 'jmp_if_false'}
    instructions[1028] = {6'd0, 8'd141, 8'd0, 32'd15};//{'dest': 141, 'literal': 15, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1029] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1030] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1031] = {6'd11, 8'd145, 8'd141, 32'd52};//{'dest': 145, 'src': 141, 'srcb': 52, 'signed': False, 'op': '+'}
    instructions[1032] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1033] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1034] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20397088, 'op': 'memory_read_request'}
    instructions[1035] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1036] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20397088, 'op': 'memory_read_wait'}
    instructions[1037] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20397088, 'element_size': 2, 'op': 'memory_read'}
    instructions[1038] = {6'd3, 8'd141, 8'd49, 32'd0};//{'dest': 141, 'src': 49, 'op': 'move'}
    instructions[1039] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1040] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1041] = {6'd29, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[1042] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1043] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1044] = {6'd13, 8'd0, 8'd139, 32'd1138};//{'src': 139, 'label': 1138, 'op': 'jmp_if_false'}
    instructions[1045] = {6'd3, 8'd139, 8'd48, 32'd0};//{'dest': 139, 'src': 48, 'op': 'move'}
    instructions[1046] = {6'd3, 8'd140, 8'd45, 32'd0};//{'dest': 140, 'src': 45, 'op': 'move'}
    instructions[1047] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1048] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1049] = {6'd11, 8'd141, 8'd140, 32'd40};//{'dest': 141, 'src': 140, 'srcb': 40, 'signed': False, 'op': '+'}
    instructions[1050] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1051] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1052] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1053] = {6'd3, 8'd139, 8'd49, 32'd0};//{'dest': 139, 'src': 49, 'op': 'move'}
    instructions[1054] = {6'd3, 8'd140, 8'd45, 32'd0};//{'dest': 140, 'src': 45, 'op': 'move'}
    instructions[1055] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1056] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1057] = {6'd11, 8'd141, 8'd140, 32'd41};//{'dest': 141, 'src': 140, 'srcb': 41, 'signed': False, 'op': '+'}
    instructions[1058] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1059] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1060] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1061] = {6'd0, 8'd145, 8'd0, 32'd11};//{'dest': 145, 'literal': 11, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1062] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1063] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1064] = {6'd11, 8'd146, 8'd145, 32'd52};//{'dest': 146, 'src': 145, 'srcb': 52, 'signed': False, 'op': '+'}
    instructions[1065] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1066] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1067] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20398520, 'op': 'memory_read_request'}
    instructions[1068] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1069] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20398520, 'op': 'memory_read_wait'}
    instructions[1070] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20398520, 'element_size': 2, 'op': 'memory_read'}
    instructions[1071] = {6'd3, 8'd140, 8'd45, 32'd0};//{'dest': 140, 'src': 45, 'op': 'move'}
    instructions[1072] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1073] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1074] = {6'd11, 8'd141, 8'd140, 32'd42};//{'dest': 141, 'src': 140, 'srcb': 42, 'signed': False, 'op': '+'}
    instructions[1075] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1076] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1077] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1078] = {6'd0, 8'd145, 8'd0, 32'd12};//{'dest': 145, 'literal': 12, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1079] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1080] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1081] = {6'd11, 8'd146, 8'd145, 32'd52};//{'dest': 146, 'src': 145, 'srcb': 52, 'signed': False, 'op': '+'}
    instructions[1082] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1083] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1084] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20398952, 'op': 'memory_read_request'}
    instructions[1085] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1086] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20398952, 'op': 'memory_read_wait'}
    instructions[1087] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20398952, 'element_size': 2, 'op': 'memory_read'}
    instructions[1088] = {6'd3, 8'd140, 8'd45, 32'd0};//{'dest': 140, 'src': 45, 'op': 'move'}
    instructions[1089] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1090] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1091] = {6'd11, 8'd141, 8'd140, 32'd43};//{'dest': 141, 'src': 140, 'srcb': 43, 'signed': False, 'op': '+'}
    instructions[1092] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1093] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1094] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1095] = {6'd0, 8'd145, 8'd0, 32'd13};//{'dest': 145, 'literal': 13, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1096] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1097] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1098] = {6'd11, 8'd146, 8'd145, 32'd52};//{'dest': 146, 'src': 145, 'srcb': 52, 'signed': False, 'op': '+'}
    instructions[1099] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1100] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1101] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20399384, 'op': 'memory_read_request'}
    instructions[1102] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1103] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20399384, 'op': 'memory_read_wait'}
    instructions[1104] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20399384, 'element_size': 2, 'op': 'memory_read'}
    instructions[1105] = {6'd3, 8'd140, 8'd45, 32'd0};//{'dest': 140, 'src': 45, 'op': 'move'}
    instructions[1106] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1107] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1108] = {6'd11, 8'd141, 8'd140, 32'd44};//{'dest': 141, 'src': 140, 'srcb': 44, 'signed': False, 'op': '+'}
    instructions[1109] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1110] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1111] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1112] = {6'd3, 8'd139, 8'd45, 32'd0};//{'dest': 139, 'src': 45, 'op': 'move'}
    instructions[1113] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1114] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1115] = {6'd3, 8'd53, 8'd139, 32'd0};//{'dest': 53, 'src': 139, 'op': 'move'}
    instructions[1116] = {6'd3, 8'd139, 8'd45, 32'd0};//{'dest': 139, 'src': 45, 'op': 'move'}
    instructions[1117] = {6'd14, 8'd45, 8'd45, 32'd1};//{'src': 45, 'right': 1, 'dest': 45, 'signed': False, 'op': '+', 'size': 2}
    instructions[1118] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1119] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1120] = {6'd3, 8'd140, 8'd45, 32'd0};//{'dest': 140, 'src': 45, 'op': 'move'}
    instructions[1121] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1122] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1123] = {6'd25, 8'd139, 8'd140, 32'd16};//{'src': 140, 'right': 16, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[1124] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1125] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1126] = {6'd13, 8'd0, 8'd139, 32'd1132};//{'src': 139, 'label': 1132, 'op': 'jmp_if_false'}
    instructions[1127] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1128] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1129] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1130] = {6'd3, 8'd45, 8'd139, 32'd0};//{'dest': 45, 'src': 139, 'op': 'move'}
    instructions[1131] = {6'd15, 8'd0, 8'd0, 32'd1132};//{'label': 1132, 'op': 'goto'}
    instructions[1132] = {6'd3, 8'd139, 8'd53, 32'd0};//{'dest': 139, 'src': 53, 'op': 'move'}
    instructions[1133] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1134] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1135] = {6'd3, 8'd47, 8'd139, 32'd0};//{'dest': 47, 'src': 139, 'op': 'move'}
    instructions[1136] = {6'd6, 8'd0, 8'd46, 32'd0};//{'src': 46, 'op': 'jmp_to_reg'}
    instructions[1137] = {6'd15, 8'd0, 8'd0, 32'd1138};//{'label': 1138, 'op': 'goto'}
    instructions[1138] = {6'd15, 8'd0, 8'd0, 32'd1139};//{'label': 1139, 'op': 'goto'}
    instructions[1139] = {6'd15, 8'd0, 8'd0, 32'd927};//{'label': 927, 'op': 'goto'}
    instructions[1140] = {6'd0, 8'd60, 8'd0, 32'd0};//{'dest': 60, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1141] = {6'd0, 8'd61, 8'd0, 32'd0};//{'dest': 61, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1142] = {6'd0, 8'd62, 8'd0, 32'd0};//{'dest': 62, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1143] = {6'd3, 8'd140, 8'd58, 32'd0};//{'dest': 140, 'src': 58, 'op': 'move'}
    instructions[1144] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1145] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1146] = {6'd3, 8'd48, 8'd140, 32'd0};//{'dest': 48, 'src': 140, 'op': 'move'}
    instructions[1147] = {6'd3, 8'd140, 8'd59, 32'd0};//{'dest': 140, 'src': 59, 'op': 'move'}
    instructions[1148] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1149] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1150] = {6'd3, 8'd49, 8'd140, 32'd0};//{'dest': 49, 'src': 140, 'op': 'move'}
    instructions[1151] = {6'd1, 8'd46, 8'd0, 32'd754};//{'dest': 46, 'label': 754, 'op': 'jmp_and_link'}
    instructions[1152] = {6'd3, 8'd139, 8'd47, 32'd0};//{'dest': 139, 'src': 47, 'op': 'move'}
    instructions[1153] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1154] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1155] = {6'd3, 8'd62, 8'd139, 32'd0};//{'dest': 62, 'src': 139, 'op': 'move'}
    instructions[1156] = {6'd0, 8'd139, 8'd0, 32'd17664};//{'dest': 139, 'literal': 17664, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1157] = {6'd0, 8'd140, 8'd0, 32'd7};//{'dest': 140, 'literal': 7, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1158] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1159] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1160] = {6'd27, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': True, 'op': '+'}
    instructions[1161] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1162] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1163] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1164] = {6'd3, 8'd139, 8'd56, 32'd0};//{'dest': 139, 'src': 56, 'op': 'move'}
    instructions[1165] = {6'd0, 8'd140, 8'd0, 32'd8};//{'dest': 140, 'literal': 8, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1166] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1167] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1168] = {6'd11, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': False, 'op': '+'}
    instructions[1169] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1170] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1171] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1172] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1173] = {6'd0, 8'd140, 8'd0, 32'd9};//{'dest': 140, 'literal': 9, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1174] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1175] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1176] = {6'd27, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': True, 'op': '+'}
    instructions[1177] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1178] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1179] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1180] = {6'd0, 8'd139, 8'd0, 32'd16384};//{'dest': 139, 'literal': 16384, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1181] = {6'd0, 8'd140, 8'd0, 32'd10};//{'dest': 140, 'literal': 10, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1182] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1183] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1184] = {6'd27, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': True, 'op': '+'}
    instructions[1185] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1186] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1187] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1188] = {6'd3, 8'd145, 8'd57, 32'd0};//{'dest': 145, 'src': 57, 'op': 'move'}
    instructions[1189] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1190] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1191] = {6'd30, 8'd139, 8'd145, 32'd65280};//{'src': 145, 'dest': 139, 'signed': False, 'op': '|', 'size': 2, 'type': 'int', 'left': 65280}
    instructions[1192] = {6'd0, 8'd140, 8'd0, 32'd11};//{'dest': 140, 'literal': 11, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1193] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1194] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1195] = {6'd11, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': False, 'op': '+'}
    instructions[1196] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1197] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1198] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1199] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1200] = {6'd0, 8'd140, 8'd0, 32'd12};//{'dest': 140, 'literal': 12, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1201] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1202] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1203] = {6'd27, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': True, 'op': '+'}
    instructions[1204] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1205] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1206] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1207] = {6'd0, 8'd139, 8'd0, 32'd49320};//{'dest': 139, 'literal': 49320, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1208] = {6'd0, 8'd140, 8'd0, 32'd13};//{'dest': 140, 'literal': 13, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1209] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1210] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1211] = {6'd11, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': False, 'op': '+'}
    instructions[1212] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1213] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1214] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1215] = {6'd0, 8'd139, 8'd0, 32'd257};//{'dest': 139, 'literal': 257, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1216] = {6'd0, 8'd140, 8'd0, 32'd14};//{'dest': 140, 'literal': 14, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1217] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1218] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1219] = {6'd11, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': False, 'op': '+'}
    instructions[1220] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1221] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1222] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1223] = {6'd3, 8'd139, 8'd58, 32'd0};//{'dest': 139, 'src': 58, 'op': 'move'}
    instructions[1224] = {6'd0, 8'd140, 8'd0, 32'd15};//{'dest': 140, 'literal': 15, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1225] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1226] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1227] = {6'd11, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': False, 'op': '+'}
    instructions[1228] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1229] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1230] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1231] = {6'd3, 8'd139, 8'd59, 32'd0};//{'dest': 139, 'src': 59, 'op': 'move'}
    instructions[1232] = {6'd0, 8'd140, 8'd0, 32'd16};//{'dest': 140, 'literal': 16, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1233] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1234] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1235] = {6'd11, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': False, 'op': '+'}
    instructions[1236] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1237] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1238] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1239] = {6'd3, 8'd140, 8'd56, 32'd0};//{'dest': 140, 'src': 56, 'op': 'move'}
    instructions[1240] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1241] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1242] = {6'd14, 8'd139, 8'd140, 32'd14};//{'src': 140, 'right': 14, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1243] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1244] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1245] = {6'd3, 8'd60, 8'd139, 32'd0};//{'dest': 60, 'src': 139, 'op': 'move'}
    instructions[1246] = {6'd1, 8'd12, 8'd0, 32'd59};//{'dest': 12, 'label': 59, 'op': 'jmp_and_link'}
    instructions[1247] = {6'd0, 8'd139, 8'd0, 32'd7};//{'dest': 139, 'literal': 7, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1248] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1249] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1250] = {6'd3, 8'd61, 8'd139, 32'd0};//{'dest': 61, 'src': 139, 'op': 'move'}
    instructions[1251] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1252] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1253] = {6'd3, 8'd140, 8'd61, 32'd0};//{'dest': 140, 'src': 61, 'op': 'move'}
    instructions[1254] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1255] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1256] = {6'd31, 8'd139, 8'd140, 32'd16};//{'src': 140, 'right': 16, 'dest': 139, 'signed': False, 'op': '<=', 'type': 'int', 'size': 2}
    instructions[1257] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1258] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1259] = {6'd13, 8'd0, 8'd139, 32'd1277};//{'src': 139, 'label': 1277, 'op': 'jmp_if_false'}
    instructions[1260] = {6'd3, 8'd141, 8'd61, 32'd0};//{'dest': 141, 'src': 61, 'op': 'move'}
    instructions[1261] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1262] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1263] = {6'd11, 8'd145, 8'd141, 32'd55};//{'dest': 145, 'src': 141, 'srcb': 55, 'signed': False, 'op': '+'}
    instructions[1264] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1265] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1266] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20412680, 'op': 'memory_read_request'}
    instructions[1267] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1268] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20412680, 'op': 'memory_read_wait'}
    instructions[1269] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20412680, 'element_size': 2, 'op': 'memory_read'}
    instructions[1270] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1271] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1272] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[1273] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[1274] = {6'd3, 8'd139, 8'd61, 32'd0};//{'dest': 139, 'src': 61, 'op': 'move'}
    instructions[1275] = {6'd14, 8'd61, 8'd61, 32'd1};//{'src': 61, 'right': 1, 'dest': 61, 'signed': False, 'op': '+', 'size': 2}
    instructions[1276] = {6'd15, 8'd0, 8'd0, 32'd1251};//{'label': 1251, 'op': 'goto'}
    instructions[1277] = {6'd1, 8'd15, 8'd0, 32'd100};//{'dest': 15, 'label': 100, 'op': 'jmp_and_link'}
    instructions[1278] = {6'd3, 8'd139, 8'd16, 32'd0};//{'dest': 139, 'src': 16, 'op': 'move'}
    instructions[1279] = {6'd0, 8'd140, 8'd0, 32'd12};//{'dest': 140, 'literal': 12, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1280] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1281] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1282] = {6'd11, 8'd141, 8'd140, 32'd55};//{'dest': 141, 'src': 140, 'srcb': 55, 'signed': False, 'op': '+'}
    instructions[1283] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1284] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1285] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1286] = {6'd3, 8'd140, 8'd60, 32'd0};//{'dest': 140, 'src': 60, 'op': 'move'}
    instructions[1287] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1288] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1289] = {6'd28, 8'd139, 8'd140, 32'd64};//{'src': 140, 'right': 64, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[1290] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1291] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1292] = {6'd13, 8'd0, 8'd139, 32'd1298};//{'src': 139, 'label': 1298, 'op': 'jmp_if_false'}
    instructions[1293] = {6'd0, 8'd139, 8'd0, 32'd64};//{'dest': 139, 'literal': 64, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1294] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1295] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1296] = {6'd3, 8'd60, 8'd139, 32'd0};//{'dest': 60, 'src': 139, 'op': 'move'}
    instructions[1297] = {6'd15, 8'd0, 8'd0, 32'd1298};//{'label': 1298, 'op': 'goto'}
    instructions[1298] = {6'd3, 8'd142, 8'd55, 32'd0};//{'dest': 142, 'src': 55, 'op': 'move'}
    instructions[1299] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1300] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1301] = {6'd3, 8'd26, 8'd142, 32'd0};//{'dest': 26, 'src': 142, 'op': 'move'}
    instructions[1302] = {6'd3, 8'd140, 8'd60, 32'd0};//{'dest': 140, 'src': 60, 'op': 'move'}
    instructions[1303] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1304] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1305] = {6'd3, 8'd27, 8'd140, 32'd0};//{'dest': 27, 'src': 140, 'op': 'move'}
    instructions[1306] = {6'd3, 8'd141, 8'd62, 32'd0};//{'dest': 141, 'src': 62, 'op': 'move'}
    instructions[1307] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1308] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1309] = {6'd11, 8'd145, 8'd141, 32'd42};//{'dest': 145, 'src': 141, 'srcb': 42, 'signed': False, 'op': '+'}
    instructions[1310] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1311] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1312] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20414336, 'op': 'memory_read_request'}
    instructions[1313] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1314] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20414336, 'op': 'memory_read_wait'}
    instructions[1315] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20414336, 'element_size': 2, 'op': 'memory_read'}
    instructions[1316] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1317] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1318] = {6'd3, 8'd28, 8'd140, 32'd0};//{'dest': 28, 'src': 140, 'op': 'move'}
    instructions[1319] = {6'd3, 8'd141, 8'd62, 32'd0};//{'dest': 141, 'src': 62, 'op': 'move'}
    instructions[1320] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1321] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1322] = {6'd11, 8'd145, 8'd141, 32'd43};//{'dest': 145, 'src': 141, 'srcb': 43, 'signed': False, 'op': '+'}
    instructions[1323] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1324] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1325] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20414408, 'op': 'memory_read_request'}
    instructions[1326] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1327] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20414408, 'op': 'memory_read_wait'}
    instructions[1328] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20414408, 'element_size': 2, 'op': 'memory_read'}
    instructions[1329] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1330] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1331] = {6'd3, 8'd29, 8'd140, 32'd0};//{'dest': 29, 'src': 140, 'op': 'move'}
    instructions[1332] = {6'd3, 8'd141, 8'd62, 32'd0};//{'dest': 141, 'src': 62, 'op': 'move'}
    instructions[1333] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1334] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1335] = {6'd11, 8'd145, 8'd141, 32'd44};//{'dest': 145, 'src': 141, 'srcb': 44, 'signed': False, 'op': '+'}
    instructions[1336] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1337] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1338] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20414688, 'op': 'memory_read_request'}
    instructions[1339] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1340] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20414688, 'op': 'memory_read_wait'}
    instructions[1341] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20414688, 'element_size': 2, 'op': 'memory_read'}
    instructions[1342] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1343] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1344] = {6'd3, 8'd30, 8'd140, 32'd0};//{'dest': 30, 'src': 140, 'op': 'move'}
    instructions[1345] = {6'd0, 8'd140, 8'd0, 32'd2048};//{'dest': 140, 'literal': 2048, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1346] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1347] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1348] = {6'd3, 8'd31, 8'd140, 32'd0};//{'dest': 31, 'src': 140, 'op': 'move'}
    instructions[1349] = {6'd1, 8'd25, 8'd0, 32'd218};//{'dest': 25, 'label': 218, 'op': 'jmp_and_link'}
    instructions[1350] = {6'd6, 8'd0, 8'd54, 32'd0};//{'src': 54, 'op': 'jmp_to_reg'}
    instructions[1351] = {6'd0, 8'd66, 8'd0, 32'd0};//{'dest': 66, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1352] = {6'd0, 8'd67, 8'd0, 32'd0};//{'dest': 67, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1353] = {6'd0, 8'd68, 8'd0, 32'd0};//{'dest': 68, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1354] = {6'd0, 8'd69, 8'd0, 32'd0};//{'dest': 69, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1355] = {6'd0, 8'd70, 8'd0, 32'd0};//{'dest': 70, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1356] = {6'd0, 8'd71, 8'd0, 32'd0};//{'dest': 71, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1357] = {6'd0, 8'd72, 8'd0, 32'd0};//{'dest': 72, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1358] = {6'd0, 8'd73, 8'd0, 32'd0};//{'dest': 73, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1359] = {6'd0, 8'd74, 8'd0, 32'd0};//{'dest': 74, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1360] = {6'd3, 8'd142, 8'd65, 32'd0};//{'dest': 142, 'src': 65, 'op': 'move'}
    instructions[1361] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1362] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1363] = {6'd3, 8'd36, 8'd142, 32'd0};//{'dest': 36, 'src': 142, 'op': 'move'}
    instructions[1364] = {6'd1, 8'd34, 8'd0, 32'd328};//{'dest': 34, 'label': 328, 'op': 'jmp_and_link'}
    instructions[1365] = {6'd3, 8'd139, 8'd35, 32'd0};//{'dest': 139, 'src': 35, 'op': 'move'}
    instructions[1366] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1367] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1368] = {6'd3, 8'd74, 8'd139, 32'd0};//{'dest': 74, 'src': 139, 'op': 'move'}
    instructions[1369] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1370] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1371] = {6'd3, 8'd140, 8'd74, 32'd0};//{'dest': 140, 'src': 74, 'op': 'move'}
    instructions[1372] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1373] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1374] = {6'd25, 8'd139, 8'd140, 32'd0};//{'src': 140, 'right': 0, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[1375] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1376] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1377] = {6'd13, 8'd0, 8'd139, 32'd1384};//{'src': 139, 'label': 1384, 'op': 'jmp_if_false'}
    instructions[1378] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1379] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1380] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1381] = {6'd3, 8'd64, 8'd139, 32'd0};//{'dest': 64, 'src': 139, 'op': 'move'}
    instructions[1382] = {6'd6, 8'd0, 8'd63, 32'd0};//{'src': 63, 'op': 'jmp_to_reg'}
    instructions[1383] = {6'd15, 8'd0, 8'd0, 32'd1384};//{'label': 1384, 'op': 'goto'}
    instructions[1384] = {6'd0, 8'd141, 8'd0, 32'd6};//{'dest': 141, 'literal': 6, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1385] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1386] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1387] = {6'd11, 8'd145, 8'd141, 32'd65};//{'dest': 145, 'src': 141, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1388] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1389] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1390] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20415408, 'op': 'memory_read_request'}
    instructions[1391] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1392] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20415408, 'op': 'memory_read_wait'}
    instructions[1393] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20415408, 'element_size': 2, 'op': 'memory_read'}
    instructions[1394] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1395] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1396] = {6'd26, 8'd139, 8'd140, 32'd2048};//{'src': 140, 'right': 2048, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[1397] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1398] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1399] = {6'd13, 8'd0, 8'd139, 32'd1406};//{'src': 139, 'label': 1406, 'op': 'jmp_if_false'}
    instructions[1400] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1401] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1402] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1403] = {6'd3, 8'd64, 8'd139, 32'd0};//{'dest': 64, 'src': 139, 'op': 'move'}
    instructions[1404] = {6'd6, 8'd0, 8'd63, 32'd0};//{'src': 63, 'op': 'jmp_to_reg'}
    instructions[1405] = {6'd15, 8'd0, 8'd0, 32'd1406};//{'label': 1406, 'op': 'goto'}
    instructions[1406] = {6'd0, 8'd141, 8'd0, 32'd15};//{'dest': 141, 'literal': 15, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1407] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1408] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1409] = {6'd11, 8'd145, 8'd141, 32'd65};//{'dest': 145, 'src': 141, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1410] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1411] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1412] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20415912, 'op': 'memory_read_request'}
    instructions[1413] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1414] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20415912, 'op': 'memory_read_wait'}
    instructions[1415] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20415912, 'element_size': 2, 'op': 'memory_read'}
    instructions[1416] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1417] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1418] = {6'd26, 8'd139, 8'd140, 32'd49320};//{'src': 140, 'right': 49320, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[1419] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1420] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1421] = {6'd13, 8'd0, 8'd139, 32'd1428};//{'src': 139, 'label': 1428, 'op': 'jmp_if_false'}
    instructions[1422] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1423] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1424] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1425] = {6'd3, 8'd64, 8'd139, 32'd0};//{'dest': 64, 'src': 139, 'op': 'move'}
    instructions[1426] = {6'd6, 8'd0, 8'd63, 32'd0};//{'src': 63, 'op': 'jmp_to_reg'}
    instructions[1427] = {6'd15, 8'd0, 8'd0, 32'd1428};//{'label': 1428, 'op': 'goto'}
    instructions[1428] = {6'd0, 8'd141, 8'd0, 32'd16};//{'dest': 141, 'literal': 16, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1429] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1430] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1431] = {6'd11, 8'd145, 8'd141, 32'd65};//{'dest': 145, 'src': 141, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1432] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1433] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1434] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20416416, 'op': 'memory_read_request'}
    instructions[1435] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1436] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20416416, 'op': 'memory_read_wait'}
    instructions[1437] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20416416, 'element_size': 2, 'op': 'memory_read'}
    instructions[1438] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1439] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1440] = {6'd26, 8'd139, 8'd140, 32'd257};//{'src': 140, 'right': 257, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[1441] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1442] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1443] = {6'd13, 8'd0, 8'd139, 32'd1450};//{'src': 139, 'label': 1450, 'op': 'jmp_if_false'}
    instructions[1444] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1445] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1446] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1447] = {6'd3, 8'd64, 8'd139, 32'd0};//{'dest': 64, 'src': 139, 'op': 'move'}
    instructions[1448] = {6'd6, 8'd0, 8'd63, 32'd0};//{'src': 63, 'op': 'jmp_to_reg'}
    instructions[1449] = {6'd15, 8'd0, 8'd0, 32'd1450};//{'label': 1450, 'op': 'goto'}
    instructions[1450] = {6'd0, 8'd145, 8'd0, 32'd11};//{'dest': 145, 'literal': 11, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1451] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1452] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1453] = {6'd11, 8'd146, 8'd145, 32'd65};//{'dest': 146, 'src': 145, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1454] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1455] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1456] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20040232, 'op': 'memory_read_request'}
    instructions[1457] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1458] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20040232, 'op': 'memory_read_wait'}
    instructions[1459] = {6'd19, 8'd141, 8'd146, 32'd0};//{'dest': 141, 'src': 146, 'sequence': 20040232, 'element_size': 2, 'op': 'memory_read'}
    instructions[1460] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1461] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1462] = {6'd12, 8'd140, 8'd141, 32'd255};//{'src': 141, 'right': 255, 'dest': 140, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[1463] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1464] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1465] = {6'd25, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[1466] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1467] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1468] = {6'd13, 8'd0, 8'd139, 32'd1675};//{'src': 139, 'label': 1675, 'op': 'jmp_if_false'}
    instructions[1469] = {6'd0, 8'd146, 8'd0, 32'd7};//{'dest': 146, 'literal': 7, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1470] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1471] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1472] = {6'd11, 8'd148, 8'd146, 32'd65};//{'dest': 148, 'src': 146, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1473] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1474] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1475] = {6'd17, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20045120, 'op': 'memory_read_request'}
    instructions[1476] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1477] = {6'd18, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20045120, 'op': 'memory_read_wait'}
    instructions[1478] = {6'd19, 8'd145, 8'd148, 32'd0};//{'dest': 145, 'src': 148, 'sequence': 20045120, 'element_size': 2, 'op': 'memory_read'}
    instructions[1479] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1480] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1481] = {6'd32, 8'd141, 8'd145, 32'd8};//{'src': 145, 'right': 8, 'dest': 141, 'signed': False, 'op': '>>', 'type': 'int', 'size': 2}
    instructions[1482] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1483] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1484] = {6'd12, 8'd140, 8'd141, 32'd15};//{'src': 141, 'right': 15, 'dest': 140, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[1485] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1486] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1487] = {6'd33, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '<<', 'type': 'int', 'size': 2}
    instructions[1488] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1489] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1490] = {6'd3, 8'd67, 8'd139, 32'd0};//{'dest': 67, 'src': 139, 'op': 'move'}
    instructions[1491] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1492] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1493] = {6'd3, 8'd140, 8'd67, 32'd0};//{'dest': 140, 'src': 67, 'op': 'move'}
    instructions[1494] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1495] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1496] = {6'd14, 8'd139, 8'd140, 32'd7};//{'src': 140, 'right': 7, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1497] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1498] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1499] = {6'd3, 8'd68, 8'd139, 32'd0};//{'dest': 68, 'src': 139, 'op': 'move'}
    instructions[1500] = {6'd0, 8'd140, 8'd0, 32'd8};//{'dest': 140, 'literal': 8, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1501] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1502] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1503] = {6'd11, 8'd141, 8'd140, 32'd65};//{'dest': 141, 'src': 140, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1504] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1505] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1506] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20414904, 'op': 'memory_read_request'}
    instructions[1507] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1508] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20414904, 'op': 'memory_read_wait'}
    instructions[1509] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20414904, 'element_size': 2, 'op': 'memory_read'}
    instructions[1510] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1511] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1512] = {6'd3, 8'd66, 8'd139, 32'd0};//{'dest': 66, 'src': 139, 'op': 'move'}
    instructions[1513] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1514] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1515] = {6'd3, 8'd145, 8'd66, 32'd0};//{'dest': 145, 'src': 66, 'op': 'move'}
    instructions[1516] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1517] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1518] = {6'd14, 8'd141, 8'd145, 32'd1};//{'src': 145, 'right': 1, 'dest': 141, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1519] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1520] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1521] = {6'd32, 8'd140, 8'd141, 32'd1};//{'src': 141, 'right': 1, 'dest': 140, 'signed': False, 'op': '>>', 'type': 'int', 'size': 2}
    instructions[1522] = {6'd3, 8'd141, 8'd67, 32'd0};//{'dest': 141, 'src': 67, 'op': 'move'}
    instructions[1523] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1524] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1525] = {6'd34, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '-', 'type': 'int', 'size': 2}
    instructions[1526] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1527] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1528] = {6'd3, 8'd69, 8'd139, 32'd0};//{'dest': 69, 'src': 139, 'op': 'move'}
    instructions[1529] = {6'd3, 8'd141, 8'd68, 32'd0};//{'dest': 141, 'src': 68, 'op': 'move'}
    instructions[1530] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1531] = {6'd3, 8'd145, 8'd69, 32'd0};//{'dest': 145, 'src': 69, 'op': 'move'}
    instructions[1532] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1533] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1534] = {6'd11, 8'd140, 8'd141, 32'd145};//{'srcb': 145, 'src': 141, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1535] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1536] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1537] = {6'd35, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '-', 'type': 'int', 'size': 2}
    instructions[1538] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1539] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1540] = {6'd3, 8'd73, 8'd139, 32'd0};//{'dest': 73, 'src': 139, 'op': 'move'}
    instructions[1541] = {6'd3, 8'd141, 8'd68, 32'd0};//{'dest': 141, 'src': 68, 'op': 'move'}
    instructions[1542] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1543] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1544] = {6'd11, 8'd145, 8'd141, 32'd65};//{'dest': 145, 'src': 141, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1545] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1546] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1547] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20041312, 'op': 'memory_read_request'}
    instructions[1548] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1549] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20041312, 'op': 'memory_read_wait'}
    instructions[1550] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20041312, 'element_size': 2, 'op': 'memory_read'}
    instructions[1551] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1552] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1553] = {6'd25, 8'd139, 8'd140, 32'd2048};//{'src': 140, 'right': 2048, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[1554] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1555] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1556] = {6'd13, 8'd0, 8'd139, 32'd1669};//{'src': 139, 'label': 1669, 'op': 'jmp_if_false'}
    instructions[1557] = {6'd0, 8'd139, 8'd0, 32'd19};//{'dest': 139, 'literal': 19, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1558] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1559] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1560] = {6'd3, 8'd72, 8'd139, 32'd0};//{'dest': 72, 'src': 139, 'op': 'move'}
    instructions[1561] = {6'd1, 8'd12, 8'd0, 32'd59};//{'dest': 12, 'label': 59, 'op': 'jmp_and_link'}
    instructions[1562] = {6'd3, 8'd140, 8'd68, 32'd0};//{'dest': 140, 'src': 68, 'op': 'move'}
    instructions[1563] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1564] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1565] = {6'd14, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1566] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1567] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1568] = {6'd3, 8'd71, 8'd139, 32'd0};//{'dest': 71, 'src': 139, 'op': 'move'}
    instructions[1569] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1570] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1571] = {6'd3, 8'd140, 8'd71, 32'd0};//{'dest': 140, 'src': 71, 'op': 'move'}
    instructions[1572] = {6'd3, 8'd141, 8'd73, 32'd0};//{'dest': 141, 'src': 73, 'op': 'move'}
    instructions[1573] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1574] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1575] = {6'd36, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '<=', 'type': 'int', 'size': 2}
    instructions[1576] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1577] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1578] = {6'd13, 8'd0, 8'd139, 32'd1612};//{'src': 139, 'label': 1612, 'op': 'jmp_if_false'}
    instructions[1579] = {6'd3, 8'd140, 8'd71, 32'd0};//{'dest': 140, 'src': 71, 'op': 'move'}
    instructions[1580] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1581] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1582] = {6'd11, 8'd141, 8'd140, 32'd65};//{'dest': 141, 'src': 140, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1583] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1584] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1585] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20409376, 'op': 'memory_read_request'}
    instructions[1586] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1587] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20409376, 'op': 'memory_read_wait'}
    instructions[1588] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20409376, 'element_size': 2, 'op': 'memory_read'}
    instructions[1589] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1590] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1591] = {6'd3, 8'd70, 8'd139, 32'd0};//{'dest': 70, 'src': 139, 'op': 'move'}
    instructions[1592] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1593] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1594] = {6'd3, 8'd140, 8'd70, 32'd0};//{'dest': 140, 'src': 70, 'op': 'move'}
    instructions[1595] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1596] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1597] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[1598] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[1599] = {6'd3, 8'd139, 8'd70, 32'd0};//{'dest': 139, 'src': 70, 'op': 'move'}
    instructions[1600] = {6'd3, 8'd140, 8'd72, 32'd0};//{'dest': 140, 'src': 72, 'op': 'move'}
    instructions[1601] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1602] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1603] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[1604] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1605] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1606] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1607] = {6'd3, 8'd139, 8'd72, 32'd0};//{'dest': 139, 'src': 72, 'op': 'move'}
    instructions[1608] = {6'd14, 8'd72, 8'd72, 32'd1};//{'src': 72, 'right': 1, 'dest': 72, 'signed': False, 'op': '+', 'size': 2}
    instructions[1609] = {6'd3, 8'd139, 8'd71, 32'd0};//{'dest': 139, 'src': 71, 'op': 'move'}
    instructions[1610] = {6'd14, 8'd71, 8'd71, 32'd1};//{'src': 71, 'right': 1, 'dest': 71, 'signed': False, 'op': '+', 'size': 2}
    instructions[1611] = {6'd15, 8'd0, 8'd0, 32'd1569};//{'label': 1569, 'op': 'goto'}
    instructions[1612] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1613] = {6'd0, 8'd140, 8'd0, 32'd17};//{'dest': 140, 'literal': 17, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1614] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1615] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1616] = {6'd27, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': True, 'op': '+'}
    instructions[1617] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1618] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1619] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1620] = {6'd1, 8'd15, 8'd0, 32'd100};//{'dest': 15, 'label': 100, 'op': 'jmp_and_link'}
    instructions[1621] = {6'd3, 8'd139, 8'd16, 32'd0};//{'dest': 139, 'src': 16, 'op': 'move'}
    instructions[1622] = {6'd0, 8'd140, 8'd0, 32'd18};//{'dest': 140, 'literal': 18, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1623] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1624] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1625] = {6'd11, 8'd141, 8'd140, 32'd10};//{'dest': 141, 'src': 140, 'srcb': 10, 'signed': False, 'op': '+'}
    instructions[1626] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1627] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1628] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1629] = {6'd3, 8'd147, 8'd10, 32'd0};//{'dest': 147, 'src': 10, 'op': 'move'}
    instructions[1630] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1631] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1632] = {6'd3, 8'd55, 8'd147, 32'd0};//{'dest': 55, 'src': 147, 'op': 'move'}
    instructions[1633] = {6'd3, 8'd140, 8'd66, 32'd0};//{'dest': 140, 'src': 66, 'op': 'move'}
    instructions[1634] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1635] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1636] = {6'd3, 8'd56, 8'd140, 32'd0};//{'dest': 56, 'src': 140, 'op': 'move'}
    instructions[1637] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1638] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1639] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1640] = {6'd3, 8'd57, 8'd140, 32'd0};//{'dest': 57, 'src': 140, 'op': 'move'}
    instructions[1641] = {6'd0, 8'd141, 8'd0, 32'd13};//{'dest': 141, 'literal': 13, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1642] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1643] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1644] = {6'd11, 8'd145, 8'd141, 32'd65};//{'dest': 145, 'src': 141, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1645] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1646] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1647] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20052448, 'op': 'memory_read_request'}
    instructions[1648] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1649] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20052448, 'op': 'memory_read_wait'}
    instructions[1650] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20052448, 'element_size': 2, 'op': 'memory_read'}
    instructions[1651] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1652] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1653] = {6'd3, 8'd58, 8'd140, 32'd0};//{'dest': 58, 'src': 140, 'op': 'move'}
    instructions[1654] = {6'd0, 8'd141, 8'd0, 32'd14};//{'dest': 141, 'literal': 14, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1655] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1656] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1657] = {6'd11, 8'd145, 8'd141, 32'd65};//{'dest': 145, 'src': 141, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1658] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1659] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1660] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20052592, 'op': 'memory_read_request'}
    instructions[1661] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1662] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20052592, 'op': 'memory_read_wait'}
    instructions[1663] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20052592, 'element_size': 2, 'op': 'memory_read'}
    instructions[1664] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1665] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1666] = {6'd3, 8'd59, 8'd140, 32'd0};//{'dest': 59, 'src': 140, 'op': 'move'}
    instructions[1667] = {6'd1, 8'd54, 8'd0, 32'd1140};//{'dest': 54, 'label': 1140, 'op': 'jmp_and_link'}
    instructions[1668] = {6'd15, 8'd0, 8'd0, 32'd1669};//{'label': 1669, 'op': 'goto'}
    instructions[1669] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1670] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1671] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1672] = {6'd3, 8'd64, 8'd139, 32'd0};//{'dest': 64, 'src': 139, 'op': 'move'}
    instructions[1673] = {6'd6, 8'd0, 8'd63, 32'd0};//{'src': 63, 'op': 'jmp_to_reg'}
    instructions[1674] = {6'd15, 8'd0, 8'd0, 32'd1675};//{'label': 1675, 'op': 'goto'}
    instructions[1675] = {6'd0, 8'd145, 8'd0, 32'd11};//{'dest': 145, 'literal': 11, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1676] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1677] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1678] = {6'd11, 8'd146, 8'd145, 32'd65};//{'dest': 146, 'src': 145, 'srcb': 65, 'signed': False, 'op': '+'}
    instructions[1679] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1680] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1681] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20053024, 'op': 'memory_read_request'}
    instructions[1682] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1683] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20053024, 'op': 'memory_read_wait'}
    instructions[1684] = {6'd19, 8'd141, 8'd146, 32'd0};//{'dest': 141, 'src': 146, 'sequence': 20053024, 'element_size': 2, 'op': 'memory_read'}
    instructions[1685] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1686] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1687] = {6'd12, 8'd140, 8'd141, 32'd255};//{'src': 141, 'right': 255, 'dest': 140, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[1688] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1689] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1690] = {6'd26, 8'd139, 8'd140, 32'd6};//{'src': 140, 'right': 6, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[1691] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1692] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1693] = {6'd13, 8'd0, 8'd139, 32'd1700};//{'src': 139, 'label': 1700, 'op': 'jmp_if_false'}
    instructions[1694] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1695] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1696] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1697] = {6'd3, 8'd64, 8'd139, 32'd0};//{'dest': 64, 'src': 139, 'op': 'move'}
    instructions[1698] = {6'd6, 8'd0, 8'd63, 32'd0};//{'src': 63, 'op': 'jmp_to_reg'}
    instructions[1699] = {6'd15, 8'd0, 8'd0, 32'd1700};//{'label': 1700, 'op': 'goto'}
    instructions[1700] = {6'd3, 8'd139, 8'd74, 32'd0};//{'dest': 139, 'src': 74, 'op': 'move'}
    instructions[1701] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1702] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1703] = {6'd3, 8'd64, 8'd139, 32'd0};//{'dest': 64, 'src': 139, 'op': 'move'}
    instructions[1704] = {6'd6, 8'd0, 8'd63, 32'd0};//{'src': 63, 'op': 'jmp_to_reg'}
    instructions[1705] = {6'd0, 8'd100, 8'd0, 32'd17};//{'dest': 100, 'literal': 17, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1706] = {6'd0, 8'd101, 8'd0, 32'd0};//{'dest': 101, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1707] = {6'd0, 8'd102, 8'd0, 32'd0};//{'dest': 102, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1708] = {6'd0, 8'd103, 8'd0, 32'd0};//{'dest': 103, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1709] = {6'd3, 8'd139, 8'd77, 32'd0};//{'dest': 139, 'src': 77, 'op': 'move'}
    instructions[1710] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1711] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1712] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1713] = {6'd14, 8'd140, 8'd145, 32'd0};//{'src': 145, 'right': 0, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1714] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1715] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1716] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1717] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1718] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1719] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1720] = {6'd3, 8'd139, 8'd78, 32'd0};//{'dest': 139, 'src': 78, 'op': 'move'}
    instructions[1721] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1722] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1723] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1724] = {6'd14, 8'd140, 8'd145, 32'd1};//{'src': 145, 'right': 1, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1725] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1726] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1727] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1728] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1729] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1730] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1731] = {6'd0, 8'd145, 8'd0, 32'd1};//{'dest': 145, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1732] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1733] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1734] = {6'd11, 8'd146, 8'd145, 32'd79};//{'dest': 146, 'src': 145, 'srcb': 79, 'signed': False, 'op': '+'}
    instructions[1735] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1736] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1737] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20068688, 'op': 'memory_read_request'}
    instructions[1738] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1739] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20068688, 'op': 'memory_read_wait'}
    instructions[1740] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20068688, 'element_size': 2, 'op': 'memory_read'}
    instructions[1741] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1742] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1743] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1744] = {6'd14, 8'd140, 8'd145, 32'd2};//{'src': 145, 'right': 2, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1745] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1746] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1747] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1748] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1749] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1750] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1751] = {6'd0, 8'd145, 8'd0, 32'd0};//{'dest': 145, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1752] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1753] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1754] = {6'd11, 8'd146, 8'd145, 32'd79};//{'dest': 146, 'src': 145, 'srcb': 79, 'signed': False, 'op': '+'}
    instructions[1755] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1756] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1757] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20069264, 'op': 'memory_read_request'}
    instructions[1758] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1759] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20069264, 'op': 'memory_read_wait'}
    instructions[1760] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20069264, 'element_size': 2, 'op': 'memory_read'}
    instructions[1761] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1762] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1763] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1764] = {6'd14, 8'd140, 8'd145, 32'd3};//{'src': 145, 'right': 3, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1765] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1766] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1767] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1768] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1769] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1770] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1771] = {6'd0, 8'd145, 8'd0, 32'd1};//{'dest': 145, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1772] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1773] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1774] = {6'd11, 8'd146, 8'd145, 32'd81};//{'dest': 146, 'src': 145, 'srcb': 81, 'signed': False, 'op': '+'}
    instructions[1775] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1776] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1777] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20069840, 'op': 'memory_read_request'}
    instructions[1778] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1779] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20069840, 'op': 'memory_read_wait'}
    instructions[1780] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20069840, 'element_size': 2, 'op': 'memory_read'}
    instructions[1781] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1782] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1783] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1784] = {6'd14, 8'd140, 8'd145, 32'd4};//{'src': 145, 'right': 4, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1785] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1786] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1787] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1788] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1789] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1790] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1791] = {6'd0, 8'd145, 8'd0, 32'd0};//{'dest': 145, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1792] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1793] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1794] = {6'd11, 8'd146, 8'd145, 32'd81};//{'dest': 146, 'src': 145, 'srcb': 81, 'signed': False, 'op': '+'}
    instructions[1795] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1796] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1797] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20074720, 'op': 'memory_read_request'}
    instructions[1798] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1799] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20074720, 'op': 'memory_read_wait'}
    instructions[1800] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20074720, 'element_size': 2, 'op': 'memory_read'}
    instructions[1801] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1802] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1803] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1804] = {6'd14, 8'd140, 8'd145, 32'd5};//{'src': 145, 'right': 5, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1805] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1806] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1807] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1808] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1809] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1810] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1811] = {6'd0, 8'd139, 8'd0, 32'd20480};//{'dest': 139, 'literal': 20480, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1812] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1813] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1814] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1815] = {6'd14, 8'd140, 8'd145, 32'd6};//{'src': 145, 'right': 6, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1816] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1817] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1818] = {6'd27, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': True, 'op': '+'}
    instructions[1819] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1820] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1821] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1822] = {6'd3, 8'd139, 8'd82, 32'd0};//{'dest': 139, 'src': 82, 'op': 'move'}
    instructions[1823] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1824] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1825] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1826] = {6'd14, 8'd140, 8'd145, 32'd7};//{'src': 145, 'right': 7, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1827] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1828] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1829] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1830] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1831] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1832] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1833] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1834] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1835] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1836] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1837] = {6'd14, 8'd140, 8'd145, 32'd8};//{'src': 145, 'right': 8, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1838] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1839] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1840] = {6'd27, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': True, 'op': '+'}
    instructions[1841] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1842] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1843] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1844] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[1845] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1846] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1847] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1848] = {6'd14, 8'd140, 8'd145, 32'd9};//{'src': 145, 'right': 9, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1849] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1850] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1851] = {6'd27, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': True, 'op': '+'}
    instructions[1852] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1853] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1854] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1855] = {6'd3, 8'd139, 8'd83, 32'd0};//{'dest': 139, 'src': 83, 'op': 'move'}
    instructions[1856] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1857] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1858] = {6'd13, 8'd0, 8'd139, 32'd1886};//{'src': 139, 'label': 1886, 'op': 'jmp_if_false'}
    instructions[1859] = {6'd3, 8'd149, 8'd100, 32'd0};//{'dest': 149, 'src': 100, 'op': 'move'}
    instructions[1860] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1861] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1862] = {6'd14, 8'd146, 8'd149, 32'd6};//{'src': 149, 'right': 6, 'dest': 146, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1863] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1864] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1865] = {6'd11, 8'd148, 8'd146, 32'd98};//{'dest': 148, 'src': 146, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1866] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1867] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1868] = {6'd17, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20077456, 'op': 'memory_read_request'}
    instructions[1869] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1870] = {6'd18, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20077456, 'op': 'memory_read_wait'}
    instructions[1871] = {6'd19, 8'd145, 8'd148, 32'd0};//{'dest': 145, 'src': 148, 'sequence': 20077456, 'element_size': 2, 'op': 'memory_read'}
    instructions[1872] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1873] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1874] = {6'd37, 8'd139, 8'd145, 32'd1};//{'src': 145, 'right': 1, 'dest': 139, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[1875] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1876] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1877] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1878] = {6'd14, 8'd140, 8'd145, 32'd6};//{'src': 145, 'right': 6, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1879] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1880] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1881] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1882] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1883] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1884] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1885] = {6'd15, 8'd0, 8'd0, 32'd1886};//{'label': 1886, 'op': 'goto'}
    instructions[1886] = {6'd3, 8'd139, 8'd84, 32'd0};//{'dest': 139, 'src': 84, 'op': 'move'}
    instructions[1887] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1888] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1889] = {6'd13, 8'd0, 8'd139, 32'd1917};//{'src': 139, 'label': 1917, 'op': 'jmp_if_false'}
    instructions[1890] = {6'd3, 8'd149, 8'd100, 32'd0};//{'dest': 149, 'src': 100, 'op': 'move'}
    instructions[1891] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1892] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1893] = {6'd14, 8'd146, 8'd149, 32'd6};//{'src': 149, 'right': 6, 'dest': 146, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1894] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1895] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1896] = {6'd11, 8'd148, 8'd146, 32'd98};//{'dest': 148, 'src': 146, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1897] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1898] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1899] = {6'd17, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20078176, 'op': 'memory_read_request'}
    instructions[1900] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1901] = {6'd18, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20078176, 'op': 'memory_read_wait'}
    instructions[1902] = {6'd19, 8'd145, 8'd148, 32'd0};//{'dest': 145, 'src': 148, 'sequence': 20078176, 'element_size': 2, 'op': 'memory_read'}
    instructions[1903] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1904] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1905] = {6'd37, 8'd139, 8'd145, 32'd2};//{'src': 145, 'right': 2, 'dest': 139, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[1906] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1907] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1908] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1909] = {6'd14, 8'd140, 8'd145, 32'd6};//{'src': 145, 'right': 6, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1910] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1911] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1912] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1913] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1914] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1915] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1916] = {6'd15, 8'd0, 8'd0, 32'd1917};//{'label': 1917, 'op': 'goto'}
    instructions[1917] = {6'd3, 8'd139, 8'd85, 32'd0};//{'dest': 139, 'src': 85, 'op': 'move'}
    instructions[1918] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1919] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1920] = {6'd13, 8'd0, 8'd139, 32'd1948};//{'src': 139, 'label': 1948, 'op': 'jmp_if_false'}
    instructions[1921] = {6'd3, 8'd149, 8'd100, 32'd0};//{'dest': 149, 'src': 100, 'op': 'move'}
    instructions[1922] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1923] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1924] = {6'd14, 8'd146, 8'd149, 32'd6};//{'src': 149, 'right': 6, 'dest': 146, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1925] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1926] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1927] = {6'd11, 8'd148, 8'd146, 32'd98};//{'dest': 148, 'src': 146, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1928] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1929] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1930] = {6'd17, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20087152, 'op': 'memory_read_request'}
    instructions[1931] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1932] = {6'd18, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20087152, 'op': 'memory_read_wait'}
    instructions[1933] = {6'd19, 8'd145, 8'd148, 32'd0};//{'dest': 145, 'src': 148, 'sequence': 20087152, 'element_size': 2, 'op': 'memory_read'}
    instructions[1934] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1935] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1936] = {6'd37, 8'd139, 8'd145, 32'd4};//{'src': 145, 'right': 4, 'dest': 139, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[1937] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1938] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1939] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1940] = {6'd14, 8'd140, 8'd145, 32'd6};//{'src': 145, 'right': 6, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1941] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1942] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1943] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1944] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1945] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1946] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1947] = {6'd15, 8'd0, 8'd0, 32'd1948};//{'label': 1948, 'op': 'goto'}
    instructions[1948] = {6'd3, 8'd139, 8'd86, 32'd0};//{'dest': 139, 'src': 86, 'op': 'move'}
    instructions[1949] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1950] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1951] = {6'd13, 8'd0, 8'd139, 32'd1979};//{'src': 139, 'label': 1979, 'op': 'jmp_if_false'}
    instructions[1952] = {6'd3, 8'd149, 8'd100, 32'd0};//{'dest': 149, 'src': 100, 'op': 'move'}
    instructions[1953] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1954] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1955] = {6'd14, 8'd146, 8'd149, 32'd6};//{'src': 149, 'right': 6, 'dest': 146, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1956] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1957] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1958] = {6'd11, 8'd148, 8'd146, 32'd98};//{'dest': 148, 'src': 146, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1959] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1960] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1961] = {6'd17, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20087872, 'op': 'memory_read_request'}
    instructions[1962] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1963] = {6'd18, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20087872, 'op': 'memory_read_wait'}
    instructions[1964] = {6'd19, 8'd145, 8'd148, 32'd0};//{'dest': 145, 'src': 148, 'sequence': 20087872, 'element_size': 2, 'op': 'memory_read'}
    instructions[1965] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1966] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1967] = {6'd37, 8'd139, 8'd145, 32'd8};//{'src': 145, 'right': 8, 'dest': 139, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[1968] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[1969] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1970] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1971] = {6'd14, 8'd140, 8'd145, 32'd6};//{'src': 145, 'right': 6, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1972] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1973] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1974] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1975] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1976] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1977] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[1978] = {6'd15, 8'd0, 8'd0, 32'd1979};//{'label': 1979, 'op': 'goto'}
    instructions[1979] = {6'd3, 8'd139, 8'd87, 32'd0};//{'dest': 139, 'src': 87, 'op': 'move'}
    instructions[1980] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1981] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1982] = {6'd13, 8'd0, 8'd139, 32'd2010};//{'src': 139, 'label': 2010, 'op': 'jmp_if_false'}
    instructions[1983] = {6'd3, 8'd149, 8'd100, 32'd0};//{'dest': 149, 'src': 100, 'op': 'move'}
    instructions[1984] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1985] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1986] = {6'd14, 8'd146, 8'd149, 32'd6};//{'src': 149, 'right': 6, 'dest': 146, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[1987] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1988] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1989] = {6'd11, 8'd148, 8'd146, 32'd98};//{'dest': 148, 'src': 146, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[1990] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1991] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1992] = {6'd17, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20088592, 'op': 'memory_read_request'}
    instructions[1993] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1994] = {6'd18, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20088592, 'op': 'memory_read_wait'}
    instructions[1995] = {6'd19, 8'd145, 8'd148, 32'd0};//{'dest': 145, 'src': 148, 'sequence': 20088592, 'element_size': 2, 'op': 'memory_read'}
    instructions[1996] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1997] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[1998] = {6'd37, 8'd139, 8'd145, 32'd16};//{'src': 145, 'right': 16, 'dest': 139, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[1999] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[2000] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2001] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2002] = {6'd14, 8'd140, 8'd145, 32'd6};//{'src': 145, 'right': 6, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2003] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2004] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2005] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[2006] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2007] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2008] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2009] = {6'd15, 8'd0, 8'd0, 32'd2010};//{'label': 2010, 'op': 'goto'}
    instructions[2010] = {6'd3, 8'd139, 8'd88, 32'd0};//{'dest': 139, 'src': 88, 'op': 'move'}
    instructions[2011] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2012] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2013] = {6'd13, 8'd0, 8'd139, 32'd2041};//{'src': 139, 'label': 2041, 'op': 'jmp_if_false'}
    instructions[2014] = {6'd3, 8'd149, 8'd100, 32'd0};//{'dest': 149, 'src': 100, 'op': 'move'}
    instructions[2015] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2016] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2017] = {6'd14, 8'd146, 8'd149, 32'd6};//{'src': 149, 'right': 6, 'dest': 146, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2018] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2019] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2020] = {6'd11, 8'd148, 8'd146, 32'd98};//{'dest': 148, 'src': 146, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[2021] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2022] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2023] = {6'd17, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20089312, 'op': 'memory_read_request'}
    instructions[2024] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2025] = {6'd18, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20089312, 'op': 'memory_read_wait'}
    instructions[2026] = {6'd19, 8'd145, 8'd148, 32'd0};//{'dest': 145, 'src': 148, 'sequence': 20089312, 'element_size': 2, 'op': 'memory_read'}
    instructions[2027] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2028] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2029] = {6'd37, 8'd139, 8'd145, 32'd32};//{'src': 145, 'right': 32, 'dest': 139, 'signed': False, 'op': '|', 'type': 'int', 'size': 2}
    instructions[2030] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[2031] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2032] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2033] = {6'd14, 8'd140, 8'd145, 32'd6};//{'src': 145, 'right': 6, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2034] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2035] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2036] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[2037] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2038] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2039] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2040] = {6'd15, 8'd0, 8'd0, 32'd2041};//{'label': 2041, 'op': 'goto'}
    instructions[2041] = {6'd1, 8'd12, 8'd0, 32'd59};//{'dest': 12, 'label': 59, 'op': 'jmp_and_link'}
    instructions[2042] = {6'd0, 8'd140, 8'd0, 32'd49320};//{'dest': 140, 'literal': 49320, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2043] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2044] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2045] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[2046] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[2047] = {6'd0, 8'd140, 8'd0, 32'd257};//{'dest': 140, 'literal': 257, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2048] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2049] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2050] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[2051] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[2052] = {6'd3, 8'd140, 8'd75, 32'd0};//{'dest': 140, 'src': 75, 'op': 'move'}
    instructions[2053] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2054] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2055] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[2056] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[2057] = {6'd3, 8'd140, 8'd76, 32'd0};//{'dest': 140, 'src': 76, 'op': 'move'}
    instructions[2058] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2059] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2060] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[2061] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[2062] = {6'd0, 8'd140, 8'd0, 32'd6};//{'dest': 140, 'literal': 6, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2063] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2064] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2065] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[2066] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[2067] = {6'd3, 8'd141, 8'd99, 32'd0};//{'dest': 141, 'src': 99, 'op': 'move'}
    instructions[2068] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2069] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2070] = {6'd14, 8'd140, 8'd141, 32'd20};//{'src': 141, 'right': 20, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2071] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2072] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2073] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[2074] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[2075] = {6'd3, 8'd145, 8'd99, 32'd0};//{'dest': 145, 'src': 99, 'op': 'move'}
    instructions[2076] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2077] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2078] = {6'd14, 8'd141, 8'd145, 32'd20};//{'src': 145, 'right': 20, 'dest': 141, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2079] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2080] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2081] = {6'd14, 8'd140, 8'd141, 32'd1};//{'src': 141, 'right': 1, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2082] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2083] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2084] = {6'd32, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '>>', 'type': 'int', 'size': 2}
    instructions[2085] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2086] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2087] = {6'd3, 8'd101, 8'd139, 32'd0};//{'dest': 101, 'src': 139, 'op': 'move'}
    instructions[2088] = {6'd3, 8'd139, 8'd100, 32'd0};//{'dest': 139, 'src': 100, 'op': 'move'}
    instructions[2089] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2090] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2091] = {6'd3, 8'd102, 8'd139, 32'd0};//{'dest': 102, 'src': 139, 'op': 'move'}
    instructions[2092] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2093] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2094] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2095] = {6'd3, 8'd103, 8'd139, 32'd0};//{'dest': 103, 'src': 139, 'op': 'move'}
    instructions[2096] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2097] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2098] = {6'd3, 8'd140, 8'd103, 32'd0};//{'dest': 140, 'src': 103, 'op': 'move'}
    instructions[2099] = {6'd3, 8'd141, 8'd101, 32'd0};//{'dest': 141, 'src': 101, 'op': 'move'}
    instructions[2100] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2101] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2102] = {6'd20, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[2103] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2104] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2105] = {6'd13, 8'd0, 8'd139, 32'd2125};//{'src': 139, 'label': 2125, 'op': 'jmp_if_false'}
    instructions[2106] = {6'd3, 8'd141, 8'd102, 32'd0};//{'dest': 141, 'src': 102, 'op': 'move'}
    instructions[2107] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2108] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2109] = {6'd11, 8'd145, 8'd141, 32'd98};//{'dest': 145, 'src': 141, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[2110] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2111] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2112] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20106056, 'op': 'memory_read_request'}
    instructions[2113] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2114] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20106056, 'op': 'memory_read_wait'}
    instructions[2115] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20106056, 'element_size': 2, 'op': 'memory_read'}
    instructions[2116] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2117] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2118] = {6'd3, 8'd14, 8'd140, 32'd0};//{'dest': 14, 'src': 140, 'op': 'move'}
    instructions[2119] = {6'd1, 8'd13, 8'd0, 32'd64};//{'dest': 13, 'label': 64, 'op': 'jmp_and_link'}
    instructions[2120] = {6'd3, 8'd139, 8'd102, 32'd0};//{'dest': 139, 'src': 102, 'op': 'move'}
    instructions[2121] = {6'd14, 8'd102, 8'd102, 32'd1};//{'src': 102, 'right': 1, 'dest': 102, 'signed': False, 'op': '+', 'size': 2}
    instructions[2122] = {6'd3, 8'd139, 8'd103, 32'd0};//{'dest': 139, 'src': 103, 'op': 'move'}
    instructions[2123] = {6'd14, 8'd103, 8'd103, 32'd1};//{'src': 103, 'right': 1, 'dest': 103, 'signed': False, 'op': '+', 'size': 2}
    instructions[2124] = {6'd15, 8'd0, 8'd0, 32'd2096};//{'label': 2096, 'op': 'goto'}
    instructions[2125] = {6'd1, 8'd15, 8'd0, 32'd100};//{'dest': 15, 'label': 100, 'op': 'jmp_and_link'}
    instructions[2126] = {6'd3, 8'd139, 8'd16, 32'd0};//{'dest': 139, 'src': 16, 'op': 'move'}
    instructions[2127] = {6'd3, 8'd145, 8'd100, 32'd0};//{'dest': 145, 'src': 100, 'op': 'move'}
    instructions[2128] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2129] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2130] = {6'd14, 8'd140, 8'd145, 32'd8};//{'src': 145, 'right': 8, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2131] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2132] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2133] = {6'd11, 8'd141, 8'd140, 32'd98};//{'dest': 141, 'src': 140, 'srcb': 98, 'signed': False, 'op': '+'}
    instructions[2134] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2135] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2136] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2137] = {6'd3, 8'd142, 8'd98, 32'd0};//{'dest': 142, 'src': 98, 'op': 'move'}
    instructions[2138] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2139] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2140] = {6'd3, 8'd55, 8'd142, 32'd0};//{'dest': 55, 'src': 142, 'op': 'move'}
    instructions[2141] = {6'd3, 8'd141, 8'd99, 32'd0};//{'dest': 141, 'src': 99, 'op': 'move'}
    instructions[2142] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2143] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2144] = {6'd14, 8'd140, 8'd141, 32'd40};//{'src': 141, 'right': 40, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2145] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2146] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2147] = {6'd3, 8'd56, 8'd140, 32'd0};//{'dest': 56, 'src': 140, 'op': 'move'}
    instructions[2148] = {6'd0, 8'd140, 8'd0, 32'd6};//{'dest': 140, 'literal': 6, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2149] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2150] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2151] = {6'd3, 8'd57, 8'd140, 32'd0};//{'dest': 57, 'src': 140, 'op': 'move'}
    instructions[2152] = {6'd3, 8'd140, 8'd75, 32'd0};//{'dest': 140, 'src': 75, 'op': 'move'}
    instructions[2153] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2154] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2155] = {6'd3, 8'd58, 8'd140, 32'd0};//{'dest': 58, 'src': 140, 'op': 'move'}
    instructions[2156] = {6'd3, 8'd140, 8'd76, 32'd0};//{'dest': 140, 'src': 76, 'op': 'move'}
    instructions[2157] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2158] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2159] = {6'd3, 8'd59, 8'd140, 32'd0};//{'dest': 59, 'src': 140, 'op': 'move'}
    instructions[2160] = {6'd1, 8'd54, 8'd0, 32'd1140};//{'dest': 54, 'label': 1140, 'op': 'jmp_and_link'}
    instructions[2161] = {6'd6, 8'd0, 8'd97, 32'd0};//{'src': 97, 'op': 'jmp_to_reg'}
    instructions[2162] = {6'd0, 8'd109, 8'd0, 32'd0};//{'dest': 109, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2163] = {6'd0, 8'd110, 8'd0, 32'd0};//{'dest': 110, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2164] = {6'd0, 8'd111, 8'd0, 32'd0};//{'dest': 111, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2165] = {6'd0, 8'd112, 8'd0, 32'd0};//{'dest': 112, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2166] = {6'd0, 8'd113, 8'd0, 32'd0};//{'dest': 113, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2167] = {6'd0, 8'd114, 8'd0, 32'd0};//{'dest': 114, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2168] = {6'd3, 8'd142, 8'd108, 32'd0};//{'dest': 142, 'src': 108, 'op': 'move'}
    instructions[2169] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2170] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2171] = {6'd3, 8'd65, 8'd142, 32'd0};//{'dest': 65, 'src': 142, 'op': 'move'}
    instructions[2172] = {6'd1, 8'd63, 8'd0, 32'd1351};//{'dest': 63, 'label': 1351, 'op': 'jmp_and_link'}
    instructions[2173] = {6'd3, 8'd139, 8'd64, 32'd0};//{'dest': 139, 'src': 64, 'op': 'move'}
    instructions[2174] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2175] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2176] = {6'd3, 8'd109, 8'd139, 32'd0};//{'dest': 109, 'src': 139, 'op': 'move'}
    instructions[2177] = {6'd0, 8'd146, 8'd0, 32'd7};//{'dest': 146, 'literal': 7, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2178] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2179] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2180] = {6'd11, 8'd148, 8'd146, 32'd108};//{'dest': 148, 'src': 146, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2181] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2182] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2183] = {6'd17, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20058768, 'op': 'memory_read_request'}
    instructions[2184] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2185] = {6'd18, 8'd0, 8'd148, 32'd0};//{'element_size': 2, 'src': 148, 'sequence': 20058768, 'op': 'memory_read_wait'}
    instructions[2186] = {6'd19, 8'd145, 8'd148, 32'd0};//{'dest': 145, 'src': 148, 'sequence': 20058768, 'element_size': 2, 'op': 'memory_read'}
    instructions[2187] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2188] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2189] = {6'd32, 8'd141, 8'd145, 32'd8};//{'src': 145, 'right': 8, 'dest': 141, 'signed': False, 'op': '>>', 'type': 'int', 'size': 2}
    instructions[2190] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2191] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2192] = {6'd12, 8'd140, 8'd141, 32'd15};//{'src': 141, 'right': 15, 'dest': 140, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[2193] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2194] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2195] = {6'd33, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '<<', 'type': 'int', 'size': 2}
    instructions[2196] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2197] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2198] = {6'd3, 8'd110, 8'd139, 32'd0};//{'dest': 110, 'src': 139, 'op': 'move'}
    instructions[2199] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2200] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2201] = {6'd3, 8'd140, 8'd110, 32'd0};//{'dest': 140, 'src': 110, 'op': 'move'}
    instructions[2202] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2203] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2204] = {6'd14, 8'd139, 8'd140, 32'd7};//{'src': 140, 'right': 7, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2205] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2206] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2207] = {6'd3, 8'd111, 8'd139, 32'd0};//{'dest': 111, 'src': 139, 'op': 'move'}
    instructions[2208] = {6'd0, 8'd140, 8'd0, 32'd8};//{'dest': 140, 'literal': 8, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2209] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2210] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2211] = {6'd11, 8'd141, 8'd140, 32'd108};//{'dest': 141, 'src': 140, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2212] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2213] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2214] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20093768, 'op': 'memory_read_request'}
    instructions[2215] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2216] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20093768, 'op': 'memory_read_wait'}
    instructions[2217] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20093768, 'element_size': 2, 'op': 'memory_read'}
    instructions[2218] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2219] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2220] = {6'd3, 8'd112, 8'd139, 32'd0};//{'dest': 112, 'src': 139, 'op': 'move'}
    instructions[2221] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2222] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2223] = {6'd3, 8'd140, 8'd112, 32'd0};//{'dest': 140, 'src': 112, 'op': 'move'}
    instructions[2224] = {6'd3, 8'd145, 8'd110, 32'd0};//{'dest': 145, 'src': 110, 'op': 'move'}
    instructions[2225] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2226] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2227] = {6'd33, 8'd141, 8'd145, 32'd1};//{'src': 145, 'right': 1, 'dest': 141, 'signed': False, 'op': '<<', 'type': 'int', 'size': 2}
    instructions[2228] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2229] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2230] = {6'd34, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '-', 'type': 'int', 'size': 2}
    instructions[2231] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2232] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2233] = {6'd3, 8'd113, 8'd139, 32'd0};//{'dest': 113, 'src': 139, 'op': 'move'}
    instructions[2234] = {6'd3, 8'd148, 8'd111, 32'd0};//{'dest': 148, 'src': 111, 'op': 'move'}
    instructions[2235] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2236] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2237] = {6'd14, 8'd145, 8'd148, 32'd6};//{'src': 148, 'right': 6, 'dest': 145, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2238] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2239] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2240] = {6'd11, 8'd146, 8'd145, 32'd108};//{'dest': 146, 'src': 145, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2241] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2242] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2243] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20109000, 'op': 'memory_read_request'}
    instructions[2244] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2245] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20109000, 'op': 'memory_read_wait'}
    instructions[2246] = {6'd19, 8'd141, 8'd146, 32'd0};//{'dest': 141, 'src': 146, 'sequence': 20109000, 'element_size': 2, 'op': 'memory_read'}
    instructions[2247] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2248] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2249] = {6'd12, 8'd140, 8'd141, 32'd61440};//{'src': 141, 'right': 61440, 'dest': 140, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[2250] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2251] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2252] = {6'd32, 8'd139, 8'd140, 32'd10};//{'src': 140, 'right': 10, 'dest': 139, 'signed': False, 'op': '>>', 'type': 'int', 'size': 2}
    instructions[2253] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2254] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2255] = {6'd3, 8'd114, 8'd139, 32'd0};//{'dest': 114, 'src': 139, 'op': 'move'}
    instructions[2256] = {6'd3, 8'd140, 8'd113, 32'd0};//{'dest': 140, 'src': 113, 'op': 'move'}
    instructions[2257] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2258] = {6'd3, 8'd141, 8'd114, 32'd0};//{'dest': 141, 'src': 114, 'op': 'move'}
    instructions[2259] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2260] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2261] = {6'd34, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '-', 'type': 'int', 'size': 2}
    instructions[2262] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2263] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2264] = {6'd3, 8'd104, 8'd139, 32'd0};//{'dest': 104, 'src': 139, 'op': 'move'}
    instructions[2265] = {6'd3, 8'd140, 8'd111, 32'd0};//{'dest': 140, 'src': 111, 'op': 'move'}
    instructions[2266] = {6'd3, 8'd145, 8'd114, 32'd0};//{'dest': 145, 'src': 114, 'op': 'move'}
    instructions[2267] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2268] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2269] = {6'd32, 8'd141, 8'd145, 32'd1};//{'src': 145, 'right': 1, 'dest': 141, 'signed': False, 'op': '>>', 'type': 'int', 'size': 2}
    instructions[2270] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2271] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2272] = {6'd11, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2273] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2274] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2275] = {6'd3, 8'd105, 8'd139, 32'd0};//{'dest': 105, 'src': 139, 'op': 'move'}
    instructions[2276] = {6'd3, 8'd145, 8'd111, 32'd0};//{'dest': 145, 'src': 111, 'op': 'move'}
    instructions[2277] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2278] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2279] = {6'd14, 8'd140, 8'd145, 32'd0};//{'src': 145, 'right': 0, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2280] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2281] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2282] = {6'd11, 8'd141, 8'd140, 32'd108};//{'dest': 141, 'src': 140, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2283] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2284] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2285] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20077816, 'op': 'memory_read_request'}
    instructions[2286] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2287] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20077816, 'op': 'memory_read_wait'}
    instructions[2288] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20077816, 'element_size': 2, 'op': 'memory_read'}
    instructions[2289] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2290] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2291] = {6'd3, 8'd89, 8'd139, 32'd0};//{'dest': 89, 'src': 139, 'op': 'move'}
    instructions[2292] = {6'd3, 8'd145, 8'd111, 32'd0};//{'dest': 145, 'src': 111, 'op': 'move'}
    instructions[2293] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2294] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2295] = {6'd14, 8'd140, 8'd145, 32'd1};//{'src': 145, 'right': 1, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2296] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2297] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2298] = {6'd11, 8'd141, 8'd140, 32'd108};//{'dest': 141, 'src': 140, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2299] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2300] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2301] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20059344, 'op': 'memory_read_request'}
    instructions[2302] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2303] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20059344, 'op': 'memory_read_wait'}
    instructions[2304] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20059344, 'element_size': 2, 'op': 'memory_read'}
    instructions[2305] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2306] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2307] = {6'd3, 8'd90, 8'd139, 32'd0};//{'dest': 90, 'src': 139, 'op': 'move'}
    instructions[2308] = {6'd3, 8'd148, 8'd111, 32'd0};//{'dest': 148, 'src': 111, 'op': 'move'}
    instructions[2309] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2310] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2311] = {6'd14, 8'd145, 8'd148, 32'd2};//{'src': 148, 'right': 2, 'dest': 145, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2312] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2313] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2314] = {6'd11, 8'd146, 8'd145, 32'd108};//{'dest': 146, 'src': 145, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2315] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2316] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2317] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20059560, 'op': 'memory_read_request'}
    instructions[2318] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2319] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20059560, 'op': 'memory_read_wait'}
    instructions[2320] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20059560, 'element_size': 2, 'op': 'memory_read'}
    instructions[2321] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2322] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2323] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2324] = {6'd11, 8'd141, 8'd140, 32'd91};//{'dest': 141, 'src': 140, 'srcb': 91, 'signed': False, 'op': '+'}
    instructions[2325] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2326] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2327] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2328] = {6'd3, 8'd148, 8'd111, 32'd0};//{'dest': 148, 'src': 111, 'op': 'move'}
    instructions[2329] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2330] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2331] = {6'd14, 8'd145, 8'd148, 32'd3};//{'src': 148, 'right': 3, 'dest': 145, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2332] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2333] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2334] = {6'd11, 8'd146, 8'd145, 32'd108};//{'dest': 146, 'src': 145, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2335] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2336] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2337] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20060352, 'op': 'memory_read_request'}
    instructions[2338] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2339] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20060352, 'op': 'memory_read_wait'}
    instructions[2340] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20060352, 'element_size': 2, 'op': 'memory_read'}
    instructions[2341] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2342] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2343] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2344] = {6'd11, 8'd141, 8'd140, 32'd91};//{'dest': 141, 'src': 140, 'srcb': 91, 'signed': False, 'op': '+'}
    instructions[2345] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2346] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2347] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2348] = {6'd3, 8'd148, 8'd111, 32'd0};//{'dest': 148, 'src': 111, 'op': 'move'}
    instructions[2349] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2350] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2351] = {6'd14, 8'd145, 8'd148, 32'd4};//{'src': 148, 'right': 4, 'dest': 145, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2352] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2353] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2354] = {6'd11, 8'd146, 8'd145, 32'd108};//{'dest': 146, 'src': 145, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2355] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2356] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2357] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20061360, 'op': 'memory_read_request'}
    instructions[2358] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2359] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20061360, 'op': 'memory_read_wait'}
    instructions[2360] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20061360, 'element_size': 2, 'op': 'memory_read'}
    instructions[2361] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2362] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2363] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2364] = {6'd11, 8'd141, 8'd140, 32'd92};//{'dest': 141, 'src': 140, 'srcb': 92, 'signed': False, 'op': '+'}
    instructions[2365] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2366] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2367] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2368] = {6'd3, 8'd148, 8'd111, 32'd0};//{'dest': 148, 'src': 111, 'op': 'move'}
    instructions[2369] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2370] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2371] = {6'd14, 8'd145, 8'd148, 32'd5};//{'src': 148, 'right': 5, 'dest': 145, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2372] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2373] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2374] = {6'd11, 8'd146, 8'd145, 32'd108};//{'dest': 146, 'src': 145, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2375] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2376] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2377] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20061936, 'op': 'memory_read_request'}
    instructions[2378] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2379] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20061936, 'op': 'memory_read_wait'}
    instructions[2380] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20061936, 'element_size': 2, 'op': 'memory_read'}
    instructions[2381] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2382] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2383] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2384] = {6'd11, 8'd141, 8'd140, 32'd92};//{'dest': 141, 'src': 140, 'srcb': 92, 'signed': False, 'op': '+'}
    instructions[2385] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2386] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2387] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2388] = {6'd3, 8'd145, 8'd111, 32'd0};//{'dest': 145, 'src': 111, 'op': 'move'}
    instructions[2389] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2390] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2391] = {6'd14, 8'd140, 8'd145, 32'd7};//{'src': 145, 'right': 7, 'dest': 140, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2392] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2393] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2394] = {6'd11, 8'd141, 8'd140, 32'd108};//{'dest': 141, 'src': 140, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2395] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2396] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2397] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20058192, 'op': 'memory_read_request'}
    instructions[2398] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2399] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20058192, 'op': 'memory_read_wait'}
    instructions[2400] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20058192, 'element_size': 2, 'op': 'memory_read'}
    instructions[2401] = {6'd3, 8'd146, 8'd111, 32'd0};//{'dest': 146, 'src': 111, 'op': 'move'}
    instructions[2402] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2403] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2404] = {6'd14, 8'd141, 8'd146, 32'd6};//{'src': 146, 'right': 6, 'dest': 141, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2405] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2406] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2407] = {6'd11, 8'd145, 8'd141, 32'd108};//{'dest': 145, 'src': 141, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2408] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2409] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2410] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20058408, 'op': 'memory_read_request'}
    instructions[2411] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2412] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20058408, 'op': 'memory_read_wait'}
    instructions[2413] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20058408, 'element_size': 2, 'op': 'memory_read'}
    instructions[2414] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2415] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2416] = {6'd12, 8'd139, 8'd140, 32'd1};//{'src': 140, 'right': 1, 'dest': 139, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[2417] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2418] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2419] = {6'd3, 8'd93, 8'd139, 32'd0};//{'dest': 93, 'src': 139, 'op': 'move'}
    instructions[2420] = {6'd3, 8'd146, 8'd111, 32'd0};//{'dest': 146, 'src': 111, 'op': 'move'}
    instructions[2421] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2422] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2423] = {6'd14, 8'd141, 8'd146, 32'd6};//{'src': 146, 'right': 6, 'dest': 141, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2424] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2425] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2426] = {6'd11, 8'd145, 8'd141, 32'd108};//{'dest': 145, 'src': 141, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2427] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2428] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2429] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20107344, 'op': 'memory_read_request'}
    instructions[2430] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2431] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20107344, 'op': 'memory_read_wait'}
    instructions[2432] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20107344, 'element_size': 2, 'op': 'memory_read'}
    instructions[2433] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2434] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2435] = {6'd12, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[2436] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2437] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2438] = {6'd3, 8'd94, 8'd139, 32'd0};//{'dest': 94, 'src': 139, 'op': 'move'}
    instructions[2439] = {6'd3, 8'd146, 8'd111, 32'd0};//{'dest': 146, 'src': 111, 'op': 'move'}
    instructions[2440] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2441] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2442] = {6'd14, 8'd141, 8'd146, 32'd6};//{'src': 146, 'right': 6, 'dest': 141, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2443] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2444] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2445] = {6'd11, 8'd145, 8'd141, 32'd108};//{'dest': 145, 'src': 141, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2446] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2447] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2448] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20107920, 'op': 'memory_read_request'}
    instructions[2449] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2450] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20107920, 'op': 'memory_read_wait'}
    instructions[2451] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20107920, 'element_size': 2, 'op': 'memory_read'}
    instructions[2452] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2453] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2454] = {6'd12, 8'd139, 8'd140, 32'd4};//{'src': 140, 'right': 4, 'dest': 139, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[2455] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2456] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2457] = {6'd3, 8'd95, 8'd139, 32'd0};//{'dest': 95, 'src': 139, 'op': 'move'}
    instructions[2458] = {6'd3, 8'd146, 8'd111, 32'd0};//{'dest': 146, 'src': 111, 'op': 'move'}
    instructions[2459] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2460] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2461] = {6'd14, 8'd141, 8'd146, 32'd6};//{'src': 146, 'right': 6, 'dest': 141, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2462] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2463] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2464] = {6'd11, 8'd145, 8'd141, 32'd108};//{'dest': 145, 'src': 141, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2465] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2466] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2467] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20108208, 'op': 'memory_read_request'}
    instructions[2468] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2469] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20108208, 'op': 'memory_read_wait'}
    instructions[2470] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20108208, 'element_size': 2, 'op': 'memory_read'}
    instructions[2471] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2472] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2473] = {6'd12, 8'd139, 8'd140, 32'd8};//{'src': 140, 'right': 8, 'dest': 139, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[2474] = {6'd3, 8'd146, 8'd111, 32'd0};//{'dest': 146, 'src': 111, 'op': 'move'}
    instructions[2475] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2476] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2477] = {6'd14, 8'd141, 8'd146, 32'd6};//{'src': 146, 'right': 6, 'dest': 141, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2478] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2479] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2480] = {6'd11, 8'd145, 8'd141, 32'd108};//{'dest': 145, 'src': 141, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2481] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2482] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2483] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20110800, 'op': 'memory_read_request'}
    instructions[2484] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2485] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20110800, 'op': 'memory_read_wait'}
    instructions[2486] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20110800, 'element_size': 2, 'op': 'memory_read'}
    instructions[2487] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2488] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2489] = {6'd12, 8'd139, 8'd140, 32'd16};//{'src': 140, 'right': 16, 'dest': 139, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[2490] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2491] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2492] = {6'd3, 8'd96, 8'd139, 32'd0};//{'dest': 96, 'src': 139, 'op': 'move'}
    instructions[2493] = {6'd3, 8'd146, 8'd111, 32'd0};//{'dest': 146, 'src': 111, 'op': 'move'}
    instructions[2494] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2495] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2496] = {6'd14, 8'd141, 8'd146, 32'd6};//{'src': 146, 'right': 6, 'dest': 141, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2497] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2498] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2499] = {6'd11, 8'd145, 8'd141, 32'd108};//{'dest': 145, 'src': 141, 'srcb': 108, 'signed': False, 'op': '+'}
    instructions[2500] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2501] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2502] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20109504, 'op': 'memory_read_request'}
    instructions[2503] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2504] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20109504, 'op': 'memory_read_wait'}
    instructions[2505] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20109504, 'element_size': 2, 'op': 'memory_read'}
    instructions[2506] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2507] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2508] = {6'd12, 8'd139, 8'd140, 32'd32};//{'src': 140, 'right': 32, 'dest': 139, 'signed': False, 'op': '&', 'type': 'int', 'size': 2}
    instructions[2509] = {6'd3, 8'd139, 8'd109, 32'd0};//{'dest': 139, 'src': 109, 'op': 'move'}
    instructions[2510] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2511] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2512] = {6'd3, 8'd107, 8'd139, 32'd0};//{'dest': 107, 'src': 139, 'op': 'move'}
    instructions[2513] = {6'd6, 8'd0, 8'd106, 32'd0};//{'src': 106, 'op': 'jmp_to_reg'}
    instructions[2514] = {6'd0, 8'd119, 8'd0, 32'd0};//{'dest': 119, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2515] = {6'd0, 8'd120, 8'd0, 32'd0};//{'dest': 120, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2516] = {6'd3, 8'd139, 8'd117, 32'd0};//{'dest': 139, 'src': 117, 'op': 'move'}
    instructions[2517] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2518] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2519] = {6'd3, 8'd120, 8'd139, 32'd0};//{'dest': 120, 'src': 139, 'op': 'move'}
    instructions[2520] = {6'd3, 8'd140, 8'd118, 32'd0};//{'dest': 140, 'src': 118, 'op': 'move'}
    instructions[2521] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2522] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2523] = {6'd3, 8'd3, 8'd140, 32'd0};//{'dest': 3, 'src': 140, 'op': 'move'}
    instructions[2524] = {6'd1, 8'd2, 8'd0, 32'd39};//{'dest': 2, 'label': 39, 'op': 'jmp_and_link'}
    instructions[2525] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2526] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2527] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2528] = {6'd3, 8'd119, 8'd139, 32'd0};//{'dest': 119, 'src': 139, 'op': 'move'}
    instructions[2529] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2530] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2531] = {6'd3, 8'd140, 8'd119, 32'd0};//{'dest': 140, 'src': 119, 'op': 'move'}
    instructions[2532] = {6'd3, 8'd141, 8'd118, 32'd0};//{'dest': 141, 'src': 118, 'op': 'move'}
    instructions[2533] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2534] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2535] = {6'd20, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[2536] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2537] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2538] = {6'd13, 8'd0, 8'd139, 32'd2563};//{'src': 139, 'label': 2563, 'op': 'jmp_if_false'}
    instructions[2539] = {6'd3, 8'd141, 8'd120, 32'd0};//{'dest': 141, 'src': 120, 'op': 'move'}
    instructions[2540] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2541] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2542] = {6'd11, 8'd145, 8'd141, 32'd116};//{'dest': 145, 'src': 141, 'srcb': 116, 'signed': False, 'op': '+'}
    instructions[2543] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2544] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2545] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20139184, 'op': 'memory_read_request'}
    instructions[2546] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2547] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20139184, 'op': 'memory_read_wait'}
    instructions[2548] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20139184, 'element_size': 2, 'op': 'memory_read'}
    instructions[2549] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2550] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2551] = {6'd3, 8'd3, 8'd140, 32'd0};//{'dest': 3, 'src': 140, 'op': 'move'}
    instructions[2552] = {6'd1, 8'd2, 8'd0, 32'd39};//{'dest': 2, 'label': 39, 'op': 'jmp_and_link'}
    instructions[2553] = {6'd3, 8'd139, 8'd120, 32'd0};//{'dest': 139, 'src': 120, 'op': 'move'}
    instructions[2554] = {6'd14, 8'd120, 8'd120, 32'd1};//{'src': 120, 'right': 1, 'dest': 120, 'signed': False, 'op': '+', 'size': 2}
    instructions[2555] = {6'd3, 8'd140, 8'd119, 32'd0};//{'dest': 140, 'src': 119, 'op': 'move'}
    instructions[2556] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2557] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2558] = {6'd14, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2559] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2560] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2561] = {6'd3, 8'd119, 8'd139, 32'd0};//{'dest': 119, 'src': 139, 'op': 'move'}
    instructions[2562] = {6'd15, 8'd0, 8'd0, 32'd2529};//{'label': 2529, 'op': 'goto'}
    instructions[2563] = {6'd6, 8'd0, 8'd115, 32'd0};//{'src': 115, 'op': 'jmp_to_reg'}
    instructions[2564] = {6'd0, 8'd125, 8'd0, 32'd0};//{'dest': 125, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2565] = {6'd0, 8'd126, 8'd0, 32'd0};//{'dest': 126, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2566] = {6'd0, 8'd127, 8'd0, 32'd0};//{'dest': 127, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2567] = {6'd38, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'input': 'socket', 'op': 'ready'}
    instructions[2568] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2569] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2570] = {6'd39, 8'd139, 8'd140, 32'd0};//{'src': 140, 'right': 0, 'dest': 139, 'signed': True, 'op': '==', 'type': 'int', 'size': 2}
    instructions[2571] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2572] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2573] = {6'd13, 8'd0, 8'd139, 32'd2580};//{'src': 139, 'label': 2580, 'op': 'jmp_if_false'}
    instructions[2574] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2575] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2576] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2577] = {6'd3, 8'd122, 8'd139, 32'd0};//{'dest': 122, 'src': 139, 'op': 'move'}
    instructions[2578] = {6'd6, 8'd0, 8'd121, 32'd0};//{'src': 121, 'op': 'jmp_to_reg'}
    instructions[2579] = {6'd15, 8'd0, 8'd0, 32'd2580};//{'label': 2580, 'op': 'goto'}
    instructions[2580] = {6'd3, 8'd139, 8'd124, 32'd0};//{'dest': 139, 'src': 124, 'op': 'move'}
    instructions[2581] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2582] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2583] = {6'd3, 8'd126, 8'd139, 32'd0};//{'dest': 126, 'src': 139, 'op': 'move'}
    instructions[2584] = {6'd1, 8'd8, 8'd0, 32'd54};//{'dest': 8, 'label': 54, 'op': 'jmp_and_link'}
    instructions[2585] = {6'd3, 8'd139, 8'd9, 32'd0};//{'dest': 139, 'src': 9, 'op': 'move'}
    instructions[2586] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2587] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2588] = {6'd3, 8'd127, 8'd139, 32'd0};//{'dest': 127, 'src': 139, 'op': 'move'}
    instructions[2589] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2590] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2591] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2592] = {6'd3, 8'd125, 8'd139, 32'd0};//{'dest': 125, 'src': 139, 'op': 'move'}
    instructions[2593] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2594] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2595] = {6'd3, 8'd140, 8'd125, 32'd0};//{'dest': 140, 'src': 125, 'op': 'move'}
    instructions[2596] = {6'd3, 8'd141, 8'd127, 32'd0};//{'dest': 141, 'src': 127, 'op': 'move'}
    instructions[2597] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2598] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2599] = {6'd20, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '<', 'type': 'int', 'size': 2}
    instructions[2600] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2601] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2602] = {6'd13, 8'd0, 8'd139, 32'd2622};//{'src': 139, 'label': 2622, 'op': 'jmp_if_false'}
    instructions[2603] = {6'd1, 8'd8, 8'd0, 32'd54};//{'dest': 8, 'label': 54, 'op': 'jmp_and_link'}
    instructions[2604] = {6'd3, 8'd139, 8'd9, 32'd0};//{'dest': 139, 'src': 9, 'op': 'move'}
    instructions[2605] = {6'd3, 8'd140, 8'd126, 32'd0};//{'dest': 140, 'src': 126, 'op': 'move'}
    instructions[2606] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2607] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2608] = {6'd11, 8'd141, 8'd140, 32'd123};//{'dest': 141, 'src': 140, 'srcb': 123, 'signed': False, 'op': '+'}
    instructions[2609] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2610] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2611] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2612] = {6'd3, 8'd139, 8'd126, 32'd0};//{'dest': 139, 'src': 126, 'op': 'move'}
    instructions[2613] = {6'd14, 8'd126, 8'd126, 32'd1};//{'src': 126, 'right': 1, 'dest': 126, 'signed': False, 'op': '+', 'size': 2}
    instructions[2614] = {6'd3, 8'd140, 8'd125, 32'd0};//{'dest': 140, 'src': 125, 'op': 'move'}
    instructions[2615] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2616] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2617] = {6'd14, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '+', 'type': 'int', 'size': 2}
    instructions[2618] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2619] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2620] = {6'd3, 8'd125, 8'd139, 32'd0};//{'dest': 125, 'src': 139, 'op': 'move'}
    instructions[2621] = {6'd15, 8'd0, 8'd0, 32'd2593};//{'label': 2593, 'op': 'goto'}
    instructions[2622] = {6'd3, 8'd139, 8'd127, 32'd0};//{'dest': 139, 'src': 127, 'op': 'move'}
    instructions[2623] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2624] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2625] = {6'd3, 8'd122, 8'd139, 32'd0};//{'dest': 122, 'src': 139, 'op': 'move'}
    instructions[2626] = {6'd6, 8'd0, 8'd121, 32'd0};//{'src': 121, 'op': 'jmp_to_reg'}
    instructions[2627] = {6'd0, 8'd129, 8'd0, 32'd638};//{'dest': 129, 'literal': 638, 'op': 'literal'}
    instructions[2628] = {6'd0, 8'd130, 8'd0, 32'd1662};//{'dest': 130, 'literal': 1662, 'op': 'literal'}
    instructions[2629] = {6'd0, 8'd131, 8'd0, 32'd27};//{'dest': 131, 'literal': 27, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2630] = {6'd0, 8'd132, 8'd0, 32'd0};//{'dest': 132, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2631] = {6'd0, 8'd133, 8'd0, 32'd0};//{'dest': 133, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2632] = {6'd0, 8'd134, 8'd0, 32'd0};//{'dest': 134, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2633] = {6'd0, 8'd135, 8'd0, 32'd0};//{'dest': 135, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2634] = {6'd0, 8'd136, 8'd0, 32'd0};//{'dest': 136, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2635] = {6'd0, 8'd137, 8'd0, 32'd0};//{'dest': 137, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2636] = {6'd0, 8'd138, 8'd0, 32'd0};//{'dest': 138, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2637] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2638] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2639] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2640] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2641] = {6'd27, 8'd141, 8'd140, 32'd79};//{'dest': 141, 'src': 140, 'srcb': 79, 'signed': True, 'op': '+'}
    instructions[2642] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2643] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2644] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2645] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2646] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2647] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2648] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2649] = {6'd27, 8'd141, 8'd140, 32'd79};//{'dest': 141, 'src': 140, 'srcb': 79, 'signed': True, 'op': '+'}
    instructions[2650] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2651] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2652] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2653] = {6'd3, 8'd139, 8'd133, 32'd0};//{'dest': 139, 'src': 133, 'op': 'move'}
    instructions[2654] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2655] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2656] = {6'd13, 8'd0, 8'd139, 32'd2660};//{'src': 139, 'label': 2660, 'op': 'jmp_if_false'}
    instructions[2657] = {6'd3, 8'd139, 8'd133, 32'd0};//{'dest': 139, 'src': 133, 'op': 'move'}
    instructions[2658] = {6'd35, 8'd133, 8'd133, 32'd1};//{'src': 133, 'right': 1, 'dest': 133, 'signed': False, 'op': '-', 'size': 2}
    instructions[2659] = {6'd15, 8'd0, 8'd0, 32'd2693};//{'label': 2693, 'op': 'goto'}
    instructions[2660] = {6'd0, 8'd139, 8'd0, 32'd120};//{'dest': 139, 'literal': 120, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2661] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2662] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2663] = {6'd3, 8'd133, 8'd139, 32'd0};//{'dest': 133, 'src': 139, 'op': 'move'}
    instructions[2664] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2665] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2666] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2667] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[2668] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2669] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2670] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2671] = {6'd3, 8'd84, 8'd139, 32'd0};//{'dest': 84, 'src': 139, 'op': 'move'}
    instructions[2672] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2673] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2674] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2675] = {6'd3, 8'd83, 8'd139, 32'd0};//{'dest': 83, 'src': 139, 'op': 'move'}
    instructions[2676] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2677] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2678] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2679] = {6'd3, 8'd87, 8'd139, 32'd0};//{'dest': 87, 'src': 139, 'op': 'move'}
    instructions[2680] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2681] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2682] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2683] = {6'd3, 8'd85, 8'd139, 32'd0};//{'dest': 85, 'src': 139, 'op': 'move'}
    instructions[2684] = {6'd3, 8'd150, 8'd130, 32'd0};//{'dest': 150, 'src': 130, 'op': 'move'}
    instructions[2685] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2686] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2687] = {6'd3, 8'd98, 8'd150, 32'd0};//{'dest': 98, 'src': 150, 'op': 'move'}
    instructions[2688] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2689] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2690] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2691] = {6'd3, 8'd99, 8'd140, 32'd0};//{'dest': 99, 'src': 140, 'op': 'move'}
    instructions[2692] = {6'd1, 8'd97, 8'd0, 32'd1705};//{'dest': 97, 'label': 1705, 'op': 'jmp_and_link'}
    instructions[2693] = {6'd3, 8'd139, 8'd138, 32'd0};//{'dest': 139, 'src': 138, 'op': 'move'}
    instructions[2694] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2695] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2696] = {6'd39, 8'd140, 8'd139, 32'd0};//{'src': 139, 'right': 0, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2697] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2698] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2699] = {6'd22, 8'd0, 8'd140, 32'd2716};//{'src': 140, 'label': 2716, 'op': 'jmp_if_true'}
    instructions[2700] = {6'd39, 8'd140, 8'd139, 32'd1};//{'src': 139, 'right': 1, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2701] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2702] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2703] = {6'd22, 8'd0, 8'd140, 32'd2733};//{'src': 140, 'label': 2733, 'op': 'jmp_if_true'}
    instructions[2704] = {6'd39, 8'd140, 8'd139, 32'd2};//{'src': 139, 'right': 2, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2705] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2706] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2707] = {6'd22, 8'd0, 8'd140, 32'd2799};//{'src': 140, 'label': 2799, 'op': 'jmp_if_true'}
    instructions[2708] = {6'd39, 8'd140, 8'd139, 32'd3};//{'src': 139, 'right': 3, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2709] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2710] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2711] = {6'd22, 8'd0, 8'd140, 32'd2878};//{'src': 140, 'label': 2878, 'op': 'jmp_if_true'}
    instructions[2712] = {6'd39, 8'd140, 8'd139, 32'd4};//{'src': 139, 'right': 4, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2713] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2714] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2715] = {6'd22, 8'd0, 8'd140, 32'd2888};//{'src': 140, 'label': 2888, 'op': 'jmp_if_true'}
    instructions[2716] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2717] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2718] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2719] = {6'd3, 8'd85, 8'd139, 32'd0};//{'dest': 85, 'src': 139, 'op': 'move'}
    instructions[2720] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2721] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2722] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2723] = {6'd3, 8'd84, 8'd139, 32'd0};//{'dest': 84, 'src': 139, 'op': 'move'}
    instructions[2724] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2725] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2726] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2727] = {6'd3, 8'd83, 8'd139, 32'd0};//{'dest': 83, 'src': 139, 'op': 'move'}
    instructions[2728] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2729] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2730] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2731] = {6'd3, 8'd87, 8'd139, 32'd0};//{'dest': 87, 'src': 139, 'op': 'move'}
    instructions[2732] = {6'd15, 8'd0, 8'd0, 32'd2920};//{'label': 2920, 'op': 'goto'}
    instructions[2733] = {6'd0, 8'd140, 8'd0, 32'd13};//{'dest': 140, 'literal': 13, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2734] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2735] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2736] = {6'd11, 8'd141, 8'd140, 32'd129};//{'dest': 141, 'src': 140, 'srcb': 129, 'signed': False, 'op': '+'}
    instructions[2737] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2738] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2739] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20115968, 'op': 'memory_read_request'}
    instructions[2740] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2741] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20115968, 'op': 'memory_read_wait'}
    instructions[2742] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20115968, 'element_size': 2, 'op': 'memory_read'}
    instructions[2743] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2744] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2745] = {6'd3, 8'd75, 8'd139, 32'd0};//{'dest': 75, 'src': 139, 'op': 'move'}
    instructions[2746] = {6'd0, 8'd140, 8'd0, 32'd14};//{'dest': 140, 'literal': 14, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2747] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2748] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2749] = {6'd11, 8'd141, 8'd140, 32'd129};//{'dest': 141, 'src': 140, 'srcb': 129, 'signed': False, 'op': '+'}
    instructions[2750] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2751] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2752] = {6'd17, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20116328, 'op': 'memory_read_request'}
    instructions[2753] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2754] = {6'd18, 8'd0, 8'd141, 32'd0};//{'element_size': 2, 'src': 141, 'sequence': 20116328, 'op': 'memory_read_wait'}
    instructions[2755] = {6'd19, 8'd139, 8'd141, 32'd0};//{'dest': 139, 'src': 141, 'sequence': 20116328, 'element_size': 2, 'op': 'memory_read'}
    instructions[2756] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2757] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2758] = {6'd3, 8'd76, 8'd139, 32'd0};//{'dest': 76, 'src': 139, 'op': 'move'}
    instructions[2759] = {6'd3, 8'd139, 8'd89, 32'd0};//{'dest': 139, 'src': 89, 'op': 'move'}
    instructions[2760] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2761] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2762] = {6'd3, 8'd78, 8'd139, 32'd0};//{'dest': 78, 'src': 139, 'op': 'move'}
    instructions[2763] = {6'd0, 8'd139, 8'd0, 32'd80};//{'dest': 139, 'literal': 80, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2764] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2765] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2766] = {6'd3, 8'd77, 8'd139, 32'd0};//{'dest': 77, 'src': 139, 'op': 'move'}
    instructions[2767] = {6'd3, 8'd142, 8'd81, 32'd0};//{'dest': 142, 'src': 81, 'op': 'move'}
    instructions[2768] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2769] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2770] = {6'd3, 8'd19, 8'd142, 32'd0};//{'dest': 19, 'src': 142, 'op': 'move'}
    instructions[2771] = {6'd3, 8'd142, 8'd91, 32'd0};//{'dest': 142, 'src': 91, 'op': 'move'}
    instructions[2772] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2773] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2774] = {6'd3, 8'd20, 8'd142, 32'd0};//{'dest': 20, 'src': 142, 'op': 'move'}
    instructions[2775] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2776] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2777] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2778] = {6'd3, 8'd21, 8'd140, 32'd0};//{'dest': 21, 'src': 140, 'op': 'move'}
    instructions[2779] = {6'd1, 8'd17, 8'd0, 32'd108};//{'dest': 17, 'label': 108, 'op': 'jmp_and_link'}
    instructions[2780] = {6'd3, 8'd139, 8'd18, 32'd0};//{'dest': 139, 'src': 18, 'op': 'move'}
    instructions[2781] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2782] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2783] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2784] = {6'd3, 8'd84, 8'd139, 32'd0};//{'dest': 84, 'src': 139, 'op': 'move'}
    instructions[2785] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2786] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2787] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2788] = {6'd3, 8'd87, 8'd139, 32'd0};//{'dest': 87, 'src': 139, 'op': 'move'}
    instructions[2789] = {6'd3, 8'd150, 8'd130, 32'd0};//{'dest': 150, 'src': 130, 'op': 'move'}
    instructions[2790] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2791] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2792] = {6'd3, 8'd98, 8'd150, 32'd0};//{'dest': 98, 'src': 150, 'op': 'move'}
    instructions[2793] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2794] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2795] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2796] = {6'd3, 8'd99, 8'd140, 32'd0};//{'dest': 99, 'src': 140, 'op': 'move'}
    instructions[2797] = {6'd1, 8'd97, 8'd0, 32'd1705};//{'dest': 97, 'label': 1705, 'op': 'jmp_and_link'}
    instructions[2798] = {6'd15, 8'd0, 8'd0, 32'd2920};//{'label': 2920, 'op': 'goto'}
    instructions[2799] = {6'd3, 8'd150, 8'd130, 32'd0};//{'dest': 150, 'src': 130, 'op': 'move'}
    instructions[2800] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2801] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2802] = {6'd3, 8'd123, 8'd150, 32'd0};//{'dest': 123, 'src': 150, 'op': 'move'}
    instructions[2803] = {6'd3, 8'd140, 8'd131, 32'd0};//{'dest': 140, 'src': 131, 'op': 'move'}
    instructions[2804] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2805] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2806] = {6'd3, 8'd124, 8'd140, 32'd0};//{'dest': 124, 'src': 140, 'op': 'move'}
    instructions[2807] = {6'd1, 8'd121, 8'd0, 32'd2564};//{'dest': 121, 'label': 2564, 'op': 'jmp_and_link'}
    instructions[2808] = {6'd3, 8'd139, 8'd122, 32'd0};//{'dest': 139, 'src': 122, 'op': 'move'}
    instructions[2809] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2810] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2811] = {6'd3, 8'd132, 8'd139, 32'd0};//{'dest': 132, 'src': 139, 'op': 'move'}
    instructions[2812] = {6'd0, 8'd145, 8'd0, 32'd0};//{'dest': 145, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2813] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2814] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2815] = {6'd11, 8'd146, 8'd145, 32'd80};//{'dest': 146, 'src': 145, 'srcb': 80, 'signed': False, 'op': '+'}
    instructions[2816] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2817] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2818] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20119424, 'op': 'memory_read_request'}
    instructions[2819] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2820] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20119424, 'op': 'memory_read_wait'}
    instructions[2821] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20119424, 'element_size': 2, 'op': 'memory_read'}
    instructions[2822] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2823] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2824] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2825] = {6'd11, 8'd141, 8'd140, 32'd79};//{'dest': 141, 'src': 140, 'srcb': 79, 'signed': False, 'op': '+'}
    instructions[2826] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2827] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2828] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2829] = {6'd0, 8'd145, 8'd0, 32'd1};//{'dest': 145, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2830] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2831] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2832] = {6'd11, 8'd146, 8'd145, 32'd80};//{'dest': 146, 'src': 145, 'srcb': 80, 'signed': False, 'op': '+'}
    instructions[2833] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2834] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2835] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20054384, 'op': 'memory_read_request'}
    instructions[2836] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2837] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20054384, 'op': 'memory_read_wait'}
    instructions[2838] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20054384, 'element_size': 2, 'op': 'memory_read'}
    instructions[2839] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2840] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2841] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2842] = {6'd11, 8'd141, 8'd140, 32'd79};//{'dest': 141, 'src': 140, 'srcb': 79, 'signed': False, 'op': '+'}
    instructions[2843] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2844] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2845] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[2846] = {6'd3, 8'd142, 8'd80, 32'd0};//{'dest': 142, 'src': 80, 'op': 'move'}
    instructions[2847] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2848] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2849] = {6'd3, 8'd19, 8'd142, 32'd0};//{'dest': 19, 'src': 142, 'op': 'move'}
    instructions[2850] = {6'd3, 8'd142, 8'd79, 32'd0};//{'dest': 142, 'src': 79, 'op': 'move'}
    instructions[2851] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2852] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2853] = {6'd3, 8'd20, 8'd142, 32'd0};//{'dest': 20, 'src': 142, 'op': 'move'}
    instructions[2854] = {6'd3, 8'd140, 8'd132, 32'd0};//{'dest': 140, 'src': 132, 'op': 'move'}
    instructions[2855] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2856] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2857] = {6'd3, 8'd21, 8'd140, 32'd0};//{'dest': 21, 'src': 140, 'op': 'move'}
    instructions[2858] = {6'd1, 8'd17, 8'd0, 32'd108};//{'dest': 17, 'label': 108, 'op': 'jmp_and_link'}
    instructions[2859] = {6'd3, 8'd139, 8'd18, 32'd0};//{'dest': 139, 'src': 18, 'op': 'move'}
    instructions[2860] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2861] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2862] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2863] = {6'd3, 8'd84, 8'd139, 32'd0};//{'dest': 84, 'src': 139, 'op': 'move'}
    instructions[2864] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2865] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2866] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2867] = {6'd3, 8'd87, 8'd139, 32'd0};//{'dest': 87, 'src': 139, 'op': 'move'}
    instructions[2868] = {6'd3, 8'd150, 8'd130, 32'd0};//{'dest': 150, 'src': 130, 'op': 'move'}
    instructions[2869] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2870] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2871] = {6'd3, 8'd98, 8'd150, 32'd0};//{'dest': 98, 'src': 150, 'op': 'move'}
    instructions[2872] = {6'd3, 8'd140, 8'd132, 32'd0};//{'dest': 140, 'src': 132, 'op': 'move'}
    instructions[2873] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2874] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2875] = {6'd3, 8'd99, 8'd140, 32'd0};//{'dest': 99, 'src': 140, 'op': 'move'}
    instructions[2876] = {6'd1, 8'd97, 8'd0, 32'd1705};//{'dest': 97, 'label': 1705, 'op': 'jmp_and_link'}
    instructions[2877] = {6'd15, 8'd0, 8'd0, 32'd2920};//{'label': 2920, 'op': 'goto'}
    instructions[2878] = {6'd3, 8'd150, 8'd130, 32'd0};//{'dest': 150, 'src': 130, 'op': 'move'}
    instructions[2879] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2880] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2881] = {6'd3, 8'd98, 8'd150, 32'd0};//{'dest': 98, 'src': 150, 'op': 'move'}
    instructions[2882] = {6'd3, 8'd140, 8'd132, 32'd0};//{'dest': 140, 'src': 132, 'op': 'move'}
    instructions[2883] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2884] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2885] = {6'd3, 8'd99, 8'd140, 32'd0};//{'dest': 99, 'src': 140, 'op': 'move'}
    instructions[2886] = {6'd1, 8'd97, 8'd0, 32'd1705};//{'dest': 97, 'label': 1705, 'op': 'jmp_and_link'}
    instructions[2887] = {6'd15, 8'd0, 8'd0, 32'd2920};//{'label': 2920, 'op': 'goto'}
    instructions[2888] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2889] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2890] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2891] = {6'd3, 8'd83, 8'd139, 32'd0};//{'dest': 83, 'src': 139, 'op': 'move'}
    instructions[2892] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2893] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2894] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2895] = {6'd3, 8'd87, 8'd139, 32'd0};//{'dest': 87, 'src': 139, 'op': 'move'}
    instructions[2896] = {6'd3, 8'd142, 8'd81, 32'd0};//{'dest': 142, 'src': 81, 'op': 'move'}
    instructions[2897] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2898] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2899] = {6'd3, 8'd19, 8'd142, 32'd0};//{'dest': 19, 'src': 142, 'op': 'move'}
    instructions[2900] = {6'd3, 8'd142, 8'd91, 32'd0};//{'dest': 142, 'src': 91, 'op': 'move'}
    instructions[2901] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2902] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2903] = {6'd3, 8'd20, 8'd142, 32'd0};//{'dest': 20, 'src': 142, 'op': 'move'}
    instructions[2904] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2905] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2906] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2907] = {6'd3, 8'd21, 8'd140, 32'd0};//{'dest': 21, 'src': 140, 'op': 'move'}
    instructions[2908] = {6'd1, 8'd17, 8'd0, 32'd108};//{'dest': 17, 'label': 108, 'op': 'jmp_and_link'}
    instructions[2909] = {6'd3, 8'd139, 8'd18, 32'd0};//{'dest': 139, 'src': 18, 'op': 'move'}
    instructions[2910] = {6'd3, 8'd150, 8'd130, 32'd0};//{'dest': 150, 'src': 130, 'op': 'move'}
    instructions[2911] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2912] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2913] = {6'd3, 8'd98, 8'd150, 32'd0};//{'dest': 98, 'src': 150, 'op': 'move'}
    instructions[2914] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2915] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2916] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2917] = {6'd3, 8'd99, 8'd140, 32'd0};//{'dest': 99, 'src': 140, 'op': 'move'}
    instructions[2918] = {6'd1, 8'd97, 8'd0, 32'd1705};//{'dest': 97, 'label': 1705, 'op': 'jmp_and_link'}
    instructions[2919] = {6'd15, 8'd0, 8'd0, 32'd2920};//{'label': 2920, 'op': 'goto'}
    instructions[2920] = {6'd0, 8'd139, 8'd0, 32'd10000};//{'dest': 139, 'literal': 10000, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2921] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2922] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2923] = {6'd3, 8'd134, 8'd139, 32'd0};//{'dest': 134, 'src': 139, 'op': 'move'}
    instructions[2924] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2925] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2926] = {6'd3, 8'd139, 8'd134, 32'd0};//{'dest': 139, 'src': 134, 'op': 'move'}
    instructions[2927] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2928] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2929] = {6'd13, 8'd0, 8'd139, 32'd3315};//{'src': 139, 'label': 3315, 'op': 'jmp_if_false'}
    instructions[2930] = {6'd3, 8'd150, 8'd129, 32'd0};//{'dest': 150, 'src': 129, 'op': 'move'}
    instructions[2931] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2932] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2933] = {6'd3, 8'd108, 8'd150, 32'd0};//{'dest': 108, 'src': 150, 'op': 'move'}
    instructions[2934] = {6'd1, 8'd106, 8'd0, 32'd2162};//{'dest': 106, 'label': 2162, 'op': 'jmp_and_link'}
    instructions[2935] = {6'd3, 8'd139, 8'd107, 32'd0};//{'dest': 139, 'src': 107, 'op': 'move'}
    instructions[2936] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2937] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2938] = {6'd3, 8'd135, 8'd139, 32'd0};//{'dest': 135, 'src': 139, 'op': 'move'}
    instructions[2939] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2940] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2941] = {6'd3, 8'd139, 8'd135, 32'd0};//{'dest': 139, 'src': 135, 'op': 'move'}
    instructions[2942] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2943] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2944] = {6'd13, 8'd0, 8'd139, 32'd2949};//{'src': 139, 'label': 2949, 'op': 'jmp_if_false'}
    instructions[2945] = {6'd3, 8'd140, 8'd90, 32'd0};//{'dest': 140, 'src': 90, 'op': 'move'}
    instructions[2946] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2947] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2948] = {6'd25, 8'd139, 8'd140, 32'd80};//{'src': 140, 'right': 80, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[2949] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2950] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2951] = {6'd13, 8'd0, 8'd139, 32'd3308};//{'src': 139, 'label': 3308, 'op': 'jmp_if_false'}
    instructions[2952] = {6'd3, 8'd140, 8'd138, 32'd0};//{'dest': 140, 'src': 138, 'op': 'move'}
    instructions[2953] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2954] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2955] = {6'd26, 8'd139, 8'd140, 32'd0};//{'src': 140, 'right': 0, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[2956] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2957] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2958] = {6'd13, 8'd0, 8'd139, 32'd2964};//{'src': 139, 'label': 2964, 'op': 'jmp_if_false'}
    instructions[2959] = {6'd3, 8'd140, 8'd89, 32'd0};//{'dest': 140, 'src': 89, 'op': 'move'}
    instructions[2960] = {6'd3, 8'd141, 8'd78, 32'd0};//{'dest': 141, 'src': 78, 'op': 'move'}
    instructions[2961] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2962] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2963] = {6'd21, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[2964] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2965] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2966] = {6'd13, 8'd0, 8'd139, 32'd2969};//{'src': 139, 'label': 2969, 'op': 'jmp_if_false'}
    instructions[2967] = {6'd15, 8'd0, 8'd0, 32'd3312};//{'label': 3312, 'op': 'goto'}
    instructions[2968] = {6'd15, 8'd0, 8'd0, 32'd2969};//{'label': 2969, 'op': 'goto'}
    instructions[2969] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[2970] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2971] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2972] = {6'd3, 8'd137, 8'd139, 32'd0};//{'dest': 137, 'src': 139, 'op': 'move'}
    instructions[2973] = {6'd3, 8'd139, 8'd138, 32'd0};//{'dest': 139, 'src': 138, 'op': 'move'}
    instructions[2974] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2975] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2976] = {6'd3, 8'd136, 8'd139, 32'd0};//{'dest': 136, 'src': 139, 'op': 'move'}
    instructions[2977] = {6'd3, 8'd139, 8'd138, 32'd0};//{'dest': 139, 'src': 138, 'op': 'move'}
    instructions[2978] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2979] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2980] = {6'd39, 8'd140, 8'd139, 32'd0};//{'src': 139, 'right': 0, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2981] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2982] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2983] = {6'd22, 8'd0, 8'd140, 32'd3000};//{'src': 140, 'label': 3000, 'op': 'jmp_if_true'}
    instructions[2984] = {6'd39, 8'd140, 8'd139, 32'd1};//{'src': 139, 'right': 1, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2985] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2986] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2987] = {6'd22, 8'd0, 8'd140, 32'd3023};//{'src': 140, 'label': 3023, 'op': 'jmp_if_true'}
    instructions[2988] = {6'd39, 8'd140, 8'd139, 32'd2};//{'src': 139, 'right': 2, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2989] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2990] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2991] = {6'd22, 8'd0, 8'd140, 32'd3101};//{'src': 140, 'label': 3101, 'op': 'jmp_if_true'}
    instructions[2992] = {6'd39, 8'd140, 8'd139, 32'd3};//{'src': 139, 'right': 3, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2993] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2994] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2995] = {6'd22, 8'd0, 8'd140, 32'd3137};//{'src': 140, 'label': 3137, 'op': 'jmp_if_true'}
    instructions[2996] = {6'd39, 8'd140, 8'd139, 32'd4};//{'src': 139, 'right': 4, 'dest': 140, 'signed': True, 'op': '==', 'size': 2}
    instructions[2997] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2998] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[2999] = {6'd22, 8'd0, 8'd140, 32'd3225};//{'src': 140, 'label': 3225, 'op': 'jmp_if_true'}
    instructions[3000] = {6'd3, 8'd139, 8'd94, 32'd0};//{'dest': 139, 'src': 94, 'op': 'move'}
    instructions[3001] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3002] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3003] = {6'd13, 8'd0, 8'd139, 32'd3009};//{'src': 139, 'label': 3009, 'op': 'jmp_if_false'}
    instructions[3004] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3005] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3006] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3007] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[3008] = {6'd15, 8'd0, 8'd0, 32'd3022};//{'label': 3022, 'op': 'goto'}
    instructions[3009] = {6'd0, 8'd139, 8'd0, 32'd1};//{'dest': 139, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3010] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3011] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3012] = {6'd3, 8'd85, 8'd139, 32'd0};//{'dest': 85, 'src': 139, 'op': 'move'}
    instructions[3013] = {6'd3, 8'd150, 8'd130, 32'd0};//{'dest': 150, 'src': 130, 'op': 'move'}
    instructions[3014] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3015] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3016] = {6'd3, 8'd98, 8'd150, 32'd0};//{'dest': 98, 'src': 150, 'op': 'move'}
    instructions[3017] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3018] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3019] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3020] = {6'd3, 8'd99, 8'd140, 32'd0};//{'dest': 99, 'src': 140, 'op': 'move'}
    instructions[3021] = {6'd1, 8'd97, 8'd0, 32'd1705};//{'dest': 97, 'label': 1705, 'op': 'jmp_and_link'}
    instructions[3022] = {6'd15, 8'd0, 8'd0, 32'd3235};//{'label': 3235, 'op': 'goto'}
    instructions[3023] = {6'd3, 8'd139, 8'd96, 32'd0};//{'dest': 139, 'src': 96, 'op': 'move'}
    instructions[3024] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3025] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3026] = {6'd13, 8'd0, 8'd139, 32'd3100};//{'src': 139, 'label': 3100, 'op': 'jmp_if_false'}
    instructions[3027] = {6'd0, 8'd145, 8'd0, 32'd1};//{'dest': 145, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3028] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3029] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3030] = {6'd11, 8'd146, 8'd145, 32'd92};//{'dest': 146, 'src': 145, 'srcb': 92, 'signed': False, 'op': '+'}
    instructions[3031] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3032] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3033] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20247904, 'op': 'memory_read_request'}
    instructions[3034] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3035] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20247904, 'op': 'memory_read_wait'}
    instructions[3036] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20247904, 'element_size': 2, 'op': 'memory_read'}
    instructions[3037] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3038] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3039] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3040] = {6'd11, 8'd141, 8'd140, 32'd79};//{'dest': 141, 'src': 140, 'srcb': 79, 'signed': False, 'op': '+'}
    instructions[3041] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3042] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3043] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[3044] = {6'd0, 8'd145, 8'd0, 32'd0};//{'dest': 145, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3045] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3046] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3047] = {6'd11, 8'd146, 8'd145, 32'd92};//{'dest': 146, 'src': 145, 'srcb': 92, 'signed': False, 'op': '+'}
    instructions[3048] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3049] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3050] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20248336, 'op': 'memory_read_request'}
    instructions[3051] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3052] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20248336, 'op': 'memory_read_wait'}
    instructions[3053] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20248336, 'element_size': 2, 'op': 'memory_read'}
    instructions[3054] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3055] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3056] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3057] = {6'd11, 8'd141, 8'd140, 32'd79};//{'dest': 141, 'src': 140, 'srcb': 79, 'signed': False, 'op': '+'}
    instructions[3058] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3059] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3060] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[3061] = {6'd0, 8'd145, 8'd0, 32'd1};//{'dest': 145, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3062] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3063] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3064] = {6'd11, 8'd146, 8'd145, 32'd92};//{'dest': 146, 'src': 145, 'srcb': 92, 'signed': False, 'op': '+'}
    instructions[3065] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3066] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3067] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20248768, 'op': 'memory_read_request'}
    instructions[3068] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3069] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20248768, 'op': 'memory_read_wait'}
    instructions[3070] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20248768, 'element_size': 2, 'op': 'memory_read'}
    instructions[3071] = {6'd0, 8'd140, 8'd0, 32'd1};//{'dest': 140, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3072] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3073] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3074] = {6'd11, 8'd141, 8'd140, 32'd80};//{'dest': 141, 'src': 140, 'srcb': 80, 'signed': False, 'op': '+'}
    instructions[3075] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3076] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3077] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[3078] = {6'd0, 8'd145, 8'd0, 32'd0};//{'dest': 145, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3079] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3080] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3081] = {6'd11, 8'd146, 8'd145, 32'd92};//{'dest': 146, 'src': 145, 'srcb': 92, 'signed': False, 'op': '+'}
    instructions[3082] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3083] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3084] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20249200, 'op': 'memory_read_request'}
    instructions[3085] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3086] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20249200, 'op': 'memory_read_wait'}
    instructions[3087] = {6'd19, 8'd139, 8'd146, 32'd0};//{'dest': 139, 'src': 146, 'sequence': 20249200, 'element_size': 2, 'op': 'memory_read'}
    instructions[3088] = {6'd0, 8'd140, 8'd0, 32'd0};//{'dest': 140, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3089] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3090] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3091] = {6'd11, 8'd141, 8'd140, 32'd80};//{'dest': 141, 'src': 140, 'srcb': 80, 'signed': False, 'op': '+'}
    instructions[3092] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3093] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3094] = {6'd23, 8'd0, 8'd141, 32'd139};//{'srcb': 139, 'src': 141, 'element_size': 2, 'op': 'memory_write'}
    instructions[3095] = {6'd0, 8'd139, 8'd0, 32'd2};//{'dest': 139, 'literal': 2, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3096] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3097] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3098] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[3099] = {6'd15, 8'd0, 8'd0, 32'd3100};//{'label': 3100, 'op': 'goto'}
    instructions[3100] = {6'd15, 8'd0, 8'd0, 32'd3235};//{'label': 3235, 'op': 'goto'}
    instructions[3101] = {6'd3, 8'd142, 8'd81, 32'd0};//{'dest': 142, 'src': 81, 'op': 'move'}
    instructions[3102] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3103] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3104] = {6'd3, 8'd19, 8'd142, 32'd0};//{'dest': 19, 'src': 142, 'op': 'move'}
    instructions[3105] = {6'd3, 8'd142, 8'd91, 32'd0};//{'dest': 142, 'src': 91, 'op': 'move'}
    instructions[3106] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3107] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3108] = {6'd3, 8'd20, 8'd142, 32'd0};//{'dest': 20, 'src': 142, 'op': 'move'}
    instructions[3109] = {6'd3, 8'd140, 8'd104, 32'd0};//{'dest': 140, 'src': 104, 'op': 'move'}
    instructions[3110] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3111] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3112] = {6'd3, 8'd21, 8'd140, 32'd0};//{'dest': 21, 'src': 140, 'op': 'move'}
    instructions[3113] = {6'd1, 8'd17, 8'd0, 32'd108};//{'dest': 17, 'label': 108, 'op': 'jmp_and_link'}
    instructions[3114] = {6'd3, 8'd139, 8'd18, 32'd0};//{'dest': 139, 'src': 18, 'op': 'move'}
    instructions[3115] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3116] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3117] = {6'd3, 8'd137, 8'd139, 32'd0};//{'dest': 137, 'src': 139, 'op': 'move'}
    instructions[3118] = {6'd3, 8'd139, 8'd93, 32'd0};//{'dest': 139, 'src': 93, 'op': 'move'}
    instructions[3119] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3120] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3121] = {6'd13, 8'd0, 8'd139, 32'd3127};//{'src': 139, 'label': 3127, 'op': 'jmp_if_false'}
    instructions[3122] = {6'd0, 8'd139, 8'd0, 32'd4};//{'dest': 139, 'literal': 4, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3123] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3124] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3125] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[3126] = {6'd15, 8'd0, 8'd0, 32'd3136};//{'label': 3136, 'op': 'goto'}
    instructions[3127] = {6'd3, 8'd139, 8'd132, 32'd0};//{'dest': 139, 'src': 132, 'op': 'move'}
    instructions[3128] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3129] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3130] = {6'd13, 8'd0, 8'd139, 32'd3136};//{'src': 139, 'label': 3136, 'op': 'jmp_if_false'}
    instructions[3131] = {6'd0, 8'd139, 8'd0, 32'd3};//{'dest': 139, 'literal': 3, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3132] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3133] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3134] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[3135] = {6'd15, 8'd0, 8'd0, 32'd3136};//{'label': 3136, 'op': 'goto'}
    instructions[3136] = {6'd15, 8'd0, 8'd0, 32'd3235};//{'label': 3235, 'op': 'goto'}
    instructions[3137] = {6'd3, 8'd142, 8'd81, 32'd0};//{'dest': 142, 'src': 81, 'op': 'move'}
    instructions[3138] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3139] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3140] = {6'd3, 8'd19, 8'd142, 32'd0};//{'dest': 19, 'src': 142, 'op': 'move'}
    instructions[3141] = {6'd3, 8'd142, 8'd91, 32'd0};//{'dest': 142, 'src': 91, 'op': 'move'}
    instructions[3142] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3143] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3144] = {6'd3, 8'd20, 8'd142, 32'd0};//{'dest': 20, 'src': 142, 'op': 'move'}
    instructions[3145] = {6'd3, 8'd140, 8'd104, 32'd0};//{'dest': 140, 'src': 104, 'op': 'move'}
    instructions[3146] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3147] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3148] = {6'd3, 8'd21, 8'd140, 32'd0};//{'dest': 21, 'src': 140, 'op': 'move'}
    instructions[3149] = {6'd1, 8'd17, 8'd0, 32'd108};//{'dest': 17, 'label': 108, 'op': 'jmp_and_link'}
    instructions[3150] = {6'd3, 8'd139, 8'd18, 32'd0};//{'dest': 139, 'src': 18, 'op': 'move'}
    instructions[3151] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3152] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3153] = {6'd3, 8'd137, 8'd139, 32'd0};//{'dest': 137, 'src': 139, 'op': 'move'}
    instructions[3154] = {6'd3, 8'd139, 8'd93, 32'd0};//{'dest': 139, 'src': 93, 'op': 'move'}
    instructions[3155] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3156] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3157] = {6'd13, 8'd0, 8'd139, 32'd3163};//{'src': 139, 'label': 3163, 'op': 'jmp_if_false'}
    instructions[3158] = {6'd0, 8'd139, 8'd0, 32'd4};//{'dest': 139, 'literal': 4, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3159] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3160] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3161] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[3162] = {6'd15, 8'd0, 8'd0, 32'd3224};//{'label': 3224, 'op': 'goto'}
    instructions[3163] = {6'd3, 8'd139, 8'd96, 32'd0};//{'dest': 139, 'src': 96, 'op': 'move'}
    instructions[3164] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3165] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3166] = {6'd13, 8'd0, 8'd139, 32'd3190};//{'src': 139, 'label': 3190, 'op': 'jmp_if_false'}
    instructions[3167] = {6'd0, 8'd141, 8'd0, 32'd1};//{'dest': 141, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3168] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3169] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3170] = {6'd11, 8'd145, 8'd141, 32'd80};//{'dest': 145, 'src': 141, 'srcb': 80, 'signed': False, 'op': '+'}
    instructions[3171] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3172] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3173] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20236912, 'op': 'memory_read_request'}
    instructions[3174] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3175] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20236912, 'op': 'memory_read_wait'}
    instructions[3176] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20236912, 'element_size': 2, 'op': 'memory_read'}
    instructions[3177] = {6'd0, 8'd145, 8'd0, 32'd1};//{'dest': 145, 'literal': 1, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3178] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3179] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3180] = {6'd11, 8'd146, 8'd145, 32'd92};//{'dest': 146, 'src': 145, 'srcb': 92, 'signed': False, 'op': '+'}
    instructions[3181] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3182] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3183] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20237056, 'op': 'memory_read_request'}
    instructions[3184] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3185] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20237056, 'op': 'memory_read_wait'}
    instructions[3186] = {6'd19, 8'd141, 8'd146, 32'd0};//{'dest': 141, 'src': 146, 'sequence': 20237056, 'element_size': 2, 'op': 'memory_read'}
    instructions[3187] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3188] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3189] = {6'd29, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[3190] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3191] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3192] = {6'd13, 8'd0, 8'd139, 32'd3216};//{'src': 139, 'label': 3216, 'op': 'jmp_if_false'}
    instructions[3193] = {6'd0, 8'd141, 8'd0, 32'd0};//{'dest': 141, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3194] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3195] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3196] = {6'd11, 8'd145, 8'd141, 32'd80};//{'dest': 145, 'src': 141, 'srcb': 80, 'signed': False, 'op': '+'}
    instructions[3197] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3198] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3199] = {6'd17, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20237344, 'op': 'memory_read_request'}
    instructions[3200] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3201] = {6'd18, 8'd0, 8'd145, 32'd0};//{'element_size': 2, 'src': 145, 'sequence': 20237344, 'op': 'memory_read_wait'}
    instructions[3202] = {6'd19, 8'd140, 8'd145, 32'd0};//{'dest': 140, 'src': 145, 'sequence': 20237344, 'element_size': 2, 'op': 'memory_read'}
    instructions[3203] = {6'd0, 8'd145, 8'd0, 32'd0};//{'dest': 145, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3204] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3205] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3206] = {6'd11, 8'd146, 8'd145, 32'd92};//{'dest': 146, 'src': 145, 'srcb': 92, 'signed': False, 'op': '+'}
    instructions[3207] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3208] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3209] = {6'd17, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20237488, 'op': 'memory_read_request'}
    instructions[3210] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3211] = {6'd18, 8'd0, 8'd146, 32'd0};//{'element_size': 2, 'src': 146, 'sequence': 20237488, 'op': 'memory_read_wait'}
    instructions[3212] = {6'd19, 8'd141, 8'd146, 32'd0};//{'dest': 141, 'src': 146, 'sequence': 20237488, 'element_size': 2, 'op': 'memory_read'}
    instructions[3213] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3214] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3215] = {6'd29, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[3216] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3217] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3218] = {6'd13, 8'd0, 8'd139, 32'd3224};//{'src': 139, 'label': 3224, 'op': 'jmp_if_false'}
    instructions[3219] = {6'd0, 8'd139, 8'd0, 32'd2};//{'dest': 139, 'literal': 2, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3220] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3221] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3222] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[3223] = {6'd15, 8'd0, 8'd0, 32'd3224};//{'label': 3224, 'op': 'goto'}
    instructions[3224] = {6'd15, 8'd0, 8'd0, 32'd3235};//{'label': 3235, 'op': 'goto'}
    instructions[3225] = {6'd3, 8'd139, 8'd96, 32'd0};//{'dest': 139, 'src': 96, 'op': 'move'}
    instructions[3226] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3227] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3228] = {6'd13, 8'd0, 8'd139, 32'd3234};//{'src': 139, 'label': 3234, 'op': 'jmp_if_false'}
    instructions[3229] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3230] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3231] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3232] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[3233] = {6'd15, 8'd0, 8'd0, 32'd3234};//{'label': 3234, 'op': 'goto'}
    instructions[3234] = {6'd15, 8'd0, 8'd0, 32'd3235};//{'label': 3235, 'op': 'goto'}
    instructions[3235] = {6'd3, 8'd139, 8'd95, 32'd0};//{'dest': 139, 'src': 95, 'op': 'move'}
    instructions[3236] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3237] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3238] = {6'd13, 8'd0, 8'd139, 32'd3244};//{'src': 139, 'label': 3244, 'op': 'jmp_if_false'}
    instructions[3239] = {6'd0, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'literal': 0, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3240] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3241] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3242] = {6'd3, 8'd138, 8'd139, 32'd0};//{'dest': 138, 'src': 139, 'op': 'move'}
    instructions[3243] = {6'd15, 8'd0, 8'd0, 32'd3244};//{'label': 3244, 'op': 'goto'}
    instructions[3244] = {6'd3, 8'd139, 8'd137, 32'd0};//{'dest': 139, 'src': 137, 'op': 'move'}
    instructions[3245] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3246] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3247] = {6'd13, 8'd0, 8'd139, 32'd3280};//{'src': 139, 'label': 3280, 'op': 'jmp_if_false'}
    instructions[3248] = {6'd3, 8'd150, 8'd129, 32'd0};//{'dest': 150, 'src': 129, 'op': 'move'}
    instructions[3249] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3250] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3251] = {6'd3, 8'd116, 8'd150, 32'd0};//{'dest': 116, 'src': 150, 'op': 'move'}
    instructions[3252] = {6'd3, 8'd140, 8'd105, 32'd0};//{'dest': 140, 'src': 105, 'op': 'move'}
    instructions[3253] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3254] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3255] = {6'd3, 8'd117, 8'd140, 32'd0};//{'dest': 117, 'src': 140, 'op': 'move'}
    instructions[3256] = {6'd3, 8'd140, 8'd104, 32'd0};//{'dest': 140, 'src': 104, 'op': 'move'}
    instructions[3257] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3258] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3259] = {6'd3, 8'd118, 8'd140, 32'd0};//{'dest': 118, 'src': 140, 'op': 'move'}
    instructions[3260] = {6'd1, 8'd115, 8'd0, 32'd2514};//{'dest': 115, 'label': 2514, 'op': 'jmp_and_link'}
    instructions[3261] = {6'd3, 8'd140, 8'd138, 32'd0};//{'dest': 140, 'src': 138, 'op': 'move'}
    instructions[3262] = {6'd3, 8'd141, 8'd136, 32'd0};//{'dest': 141, 'src': 136, 'op': 'move'}
    instructions[3263] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3264] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3265] = {6'd29, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[3266] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3267] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3268] = {6'd13, 8'd0, 8'd139, 32'd3279};//{'src': 139, 'label': 3279, 'op': 'jmp_if_false'}
    instructions[3269] = {6'd3, 8'd150, 8'd130, 32'd0};//{'dest': 150, 'src': 130, 'op': 'move'}
    instructions[3270] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3271] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3272] = {6'd3, 8'd98, 8'd150, 32'd0};//{'dest': 98, 'src': 150, 'op': 'move'}
    instructions[3273] = {6'd3, 8'd140, 8'd132, 32'd0};//{'dest': 140, 'src': 132, 'op': 'move'}
    instructions[3274] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3275] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3276] = {6'd3, 8'd99, 8'd140, 32'd0};//{'dest': 99, 'src': 140, 'op': 'move'}
    instructions[3277] = {6'd1, 8'd97, 8'd0, 32'd1705};//{'dest': 97, 'label': 1705, 'op': 'jmp_and_link'}
    instructions[3278] = {6'd15, 8'd0, 8'd0, 32'd3279};//{'label': 3279, 'op': 'goto'}
    instructions[3279] = {6'd15, 8'd0, 8'd0, 32'd3280};//{'label': 3280, 'op': 'goto'}
    instructions[3280] = {6'd3, 8'd140, 8'd138, 32'd0};//{'dest': 140, 'src': 138, 'op': 'move'}
    instructions[3281] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3282] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3283] = {6'd25, 8'd139, 8'd140, 32'd2};//{'src': 140, 'right': 2, 'dest': 139, 'signed': False, 'op': '==', 'type': 'int', 'size': 2}
    instructions[3284] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3285] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3286] = {6'd13, 8'd0, 8'd139, 32'd3288};//{'src': 139, 'label': 3288, 'op': 'jmp_if_false'}
    instructions[3287] = {6'd38, 8'd139, 8'd0, 32'd0};//{'dest': 139, 'input': 'socket', 'op': 'ready'}
    instructions[3288] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3289] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3290] = {6'd13, 8'd0, 8'd139, 32'd3293};//{'src': 139, 'label': 3293, 'op': 'jmp_if_false'}
    instructions[3291] = {6'd15, 8'd0, 8'd0, 32'd3315};//{'label': 3315, 'op': 'goto'}
    instructions[3292] = {6'd15, 8'd0, 8'd0, 32'd3293};//{'label': 3293, 'op': 'goto'}
    instructions[3293] = {6'd3, 8'd140, 8'd138, 32'd0};//{'dest': 140, 'src': 138, 'op': 'move'}
    instructions[3294] = {6'd3, 8'd141, 8'd136, 32'd0};//{'dest': 141, 'src': 136, 'op': 'move'}
    instructions[3295] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3296] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3297] = {6'd21, 8'd139, 8'd140, 32'd141};//{'srcb': 141, 'src': 140, 'dest': 139, 'signed': False, 'op': '!=', 'type': 'int', 'size': 2}
    instructions[3298] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3299] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3300] = {6'd13, 8'd0, 8'd139, 32'd3307};//{'src': 139, 'label': 3307, 'op': 'jmp_if_false'}
    instructions[3301] = {6'd0, 8'd139, 8'd0, 32'd120};//{'dest': 139, 'literal': 120, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3302] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3303] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3304] = {6'd3, 8'd133, 8'd139, 32'd0};//{'dest': 133, 'src': 139, 'op': 'move'}
    instructions[3305] = {6'd15, 8'd0, 8'd0, 32'd3315};//{'label': 3315, 'op': 'goto'}
    instructions[3306] = {6'd15, 8'd0, 8'd0, 32'd3307};//{'label': 3307, 'op': 'goto'}
    instructions[3307] = {6'd15, 8'd0, 8'd0, 32'd3312};//{'label': 3312, 'op': 'goto'}
    instructions[3308] = {6'd0, 8'd139, 8'd0, 32'd10000};//{'dest': 139, 'literal': 10000, 'size': 2, 'signed': 2, 'op': 'literal'}
    instructions[3309] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3310] = {6'd4, 8'd0, 8'd0, 32'd0};//{'op': 'nop'}
    instructions[3311] = {6'd40, 8'd0, 8'd139, 32'd0};//{'src': 139, 'op': 'wait_clocks'}
    instructions[3312] = {6'd3, 8'd139, 8'd134, 32'd0};//{'dest': 139, 'src': 134, 'op': 'move'}
    instructions[3313] = {6'd35, 8'd134, 8'd134, 32'd1};//{'src': 134, 'right': 1, 'dest': 134, 'signed': False, 'op': '-', 'size': 2}
    instructions[3314] = {6'd15, 8'd0, 8'd0, 32'd2924};//{'label': 2924, 'op': 'goto'}
    instructions[3315] = {6'd15, 8'd0, 8'd0, 32'd2653};//{'label': 2653, 'op': 'goto'}
    instructions[3316] = {6'd6, 8'd0, 8'd128, 32'd0};//{'src': 128, 'op': 'jmp_to_reg'}
  end


  //////////////////////////////////////////////////////////////////////////////
  // CPU IMPLEMENTAION OF C PROCESS                                             
  //                                                                            
  // This section of the file contains a CPU implementing the C process.        
  
  always @(posedge clk)
  begin

    //implement memory for 2 byte x n arrays
    if (memory_enable_2 == 1'b1) begin
      memory_2[address_2] <= data_in_2;
    end
    data_out_2 <= memory_2[address_2];
    memory_enable_2 <= 1'b0;

    write_enable_2 <= 0;
    //stage 0 instruction fetch
    if (stage_0_enable) begin
      stage_1_enable <= 1;
      instruction_0 <= instructions[program_counter];
      opcode_0 = instruction_0[53:48];
      dest_0 = instruction_0[47:40];
      src_0 = instruction_0[39:32];
      srcb_0 = instruction_0[7:0];
      literal_0 = instruction_0[31:0];
      if(write_enable_2) begin
        registers[dest_2] <= result_2;
      end
      program_counter_0 <= program_counter;
      program_counter <= program_counter + 1;
    end

    //stage 1 opcode fetch
    if (stage_1_enable) begin
      stage_2_enable <= 1;
      register_1 <= registers[src_0];
      registerb_1 <= registers[srcb_0];
      dest_1 <= dest_0;
      literal_1 <= literal_0;
      opcode_1 <= opcode_0;
      program_counter_1 <= program_counter_0;
    end

    //stage 2 opcode fetch
    if (stage_2_enable) begin
      dest_2 <= dest_1;
      case(opcode_1)

        16'd0:
        begin
          result_2 <= literal_1;
          write_enable_2 <= 1;
        end

        16'd1:
        begin
          program_counter <= literal_1;
          result_2 <= program_counter_1 + 1;
          write_enable_2 <= 1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd2:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd3:
        begin
          result_2 <= register_1;
          write_enable_2 <= 1;
        end

        16'd5:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_output_eth_tx_stb <= 1'b1;
          s_output_eth_tx <= register_1;
        end

        16'd6:
        begin
          program_counter <= register_1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd7:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_output_socket_stb <= 1'b1;
          s_output_socket <= register_1;
        end

        16'd8:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_input_eth_rx_ack <= 1'b1;
        end

        16'd9:
        begin
          result_2 <= 0;
          result_2[0] <= input_eth_rx_stb;
          write_enable_2 <= 1;
        end

        16'd10:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_input_socket_ack <= 1'b1;
        end

        16'd11:
        begin
          result_2 <= $unsigned(register_1) + $unsigned(registerb_1);
          write_enable_2 <= 1;
        end

        16'd12:
        begin
          result_2 <= $unsigned(register_1) & $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd13:
        begin
          if (register_1 == 0) begin
            program_counter <= literal_1;
            stage_0_enable <= 1;
            stage_1_enable <= 0;
            stage_2_enable <= 0;
          end
        end

        16'd14:
        begin
          result_2 <= $unsigned(register_1) + $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd15:
        begin
          program_counter <= literal_1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd16:
        begin
          result_2 <= ~register_1;
          write_enable_2 <= 1;
        end

        16'd17:
        begin
          address_2 <= register_1;
        end

        16'd19:
        begin
          result_2 <= data_out_2;
          write_enable_2 <= 1;
        end

        16'd20:
        begin
          result_2 <= $unsigned(register_1) < $unsigned(registerb_1);
          write_enable_2 <= 1;
        end

        16'd21:
        begin
          result_2 <= $unsigned(register_1) != $unsigned(registerb_1);
          write_enable_2 <= 1;
        end

        16'd22:
        begin
          if (register_1 != 0) begin
            program_counter <= literal_1;
            stage_0_enable <= 1;
            stage_1_enable <= 0;
            stage_2_enable <= 0;
          end
        end

        16'd23:
        begin
          address_2 <= register_1;
          data_in_2 <= registerb_1;
          memory_enable_2 <= 1'b1;
        end

        16'd24:
        begin
          $display ("%d (report at line: 107 in file: /media/sdb1/Projects/Chips-Demo/source/server.h)", $unsigned(register_1));
        end

        16'd25:
        begin
          result_2 <= $unsigned(register_1) == $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd26:
        begin
          result_2 <= $unsigned(register_1) != $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd27:
        begin
          result_2 <= $signed(register_1) + $signed(registerb_1);
          write_enable_2 <= 1;
        end

        16'd28:
        begin
          result_2 <= $unsigned(register_1) < $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd29:
        begin
          result_2 <= $unsigned(register_1) == $unsigned(registerb_1);
          write_enable_2 <= 1;
        end

        16'd30:
        begin
          result_2 <= $unsigned(literal_1) | $unsigned(register_1);
          write_enable_2 <= 1;
        end

        16'd31:
        begin
          result_2 <= $unsigned(register_1) <= $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd32:
        begin
          result_2 <= $unsigned(register_1) >> $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd33:
        begin
          result_2 <= $unsigned(register_1) << $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd34:
        begin
          result_2 <= $unsigned(register_1) - $unsigned(registerb_1);
          write_enable_2 <= 1;
        end

        16'd35:
        begin
          result_2 <= $unsigned(register_1) - $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd36:
        begin
          result_2 <= $unsigned(register_1) <= $unsigned(registerb_1);
          write_enable_2 <= 1;
        end

        16'd37:
        begin
          result_2 <= $unsigned(register_1) | $unsigned(literal_1);
          write_enable_2 <= 1;
        end

        16'd38:
        begin
          result_2 <= 0;
          result_2[0] <= input_socket_stb;
          write_enable_2 <= 1;
        end

        16'd39:
        begin
          result_2 <= $signed(register_1) == $signed(literal_1);
          write_enable_2 <= 1;
        end

        16'd40:
        begin
          timer <= register_1;
          timer_enable <= 1;
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

       endcase
    end
     if (s_output_eth_tx_stb == 1'b1 && output_eth_tx_ack == 1'b1) begin
       s_output_eth_tx_stb <= 1'b0;
       stage_0_enable <= 1;
       stage_1_enable <= 1;
       stage_2_enable <= 1;
     end

     if (s_output_socket_stb == 1'b1 && output_socket_ack == 1'b1) begin
       s_output_socket_stb <= 1'b0;
       stage_0_enable <= 1;
       stage_1_enable <= 1;
       stage_2_enable <= 1;
     end

    if (s_input_eth_rx_ack == 1'b1 && input_eth_rx_stb == 1'b1) begin
       result_2 <= input_eth_rx;
       write_enable_2 <= 1;
       s_input_eth_rx_ack <= 1'b0;
       stage_0_enable <= 1;
       stage_1_enable <= 1;
       stage_2_enable <= 1;
     end

    if (s_input_socket_ack == 1'b1 && input_socket_stb == 1'b1) begin
       result_2 <= input_socket;
       write_enable_2 <= 1;
       s_input_socket_ack <= 1'b0;
       stage_0_enable <= 1;
       stage_1_enable <= 1;
       stage_2_enable <= 1;
     end

    if (timer == 0) begin
      if (timer_enable) begin
         stage_0_enable <= 1;
         stage_1_enable <= 1;
         stage_2_enable <= 1;
         timer_enable <= 0;
      end
    end else begin
      timer <= timer - 1;
    end

    if (rst == 1'b1) begin
      stage_0_enable <= 1;
      stage_1_enable <= 0;
      stage_2_enable <= 0;
      timer <= 0;
      timer_enable <= 0;
      program_counter <= 0;
      s_input_eth_rx_ack <= 0;
      s_input_socket_ack <= 0;
      s_output_socket_stb <= 0;
      s_output_eth_tx_stb <= 0;
    end
  end
  assign input_eth_rx_ack = s_input_eth_rx_ack;
  assign input_socket_ack = s_input_socket_ack;
  assign output_socket_stb = s_output_socket_stb;
  assign output_socket = s_output_socket;
  assign output_eth_tx_stb = s_output_eth_tx_stb;
  assign output_eth_tx = s_output_eth_tx;

endmodule
