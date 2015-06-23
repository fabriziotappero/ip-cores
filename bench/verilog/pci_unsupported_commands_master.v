`include "bus_commands.v"
module pci_unsupported_commands_master
(
    CLK,
    AD,
    CBE,
    RST,
    REQ,
    GNT,
    FRAME,
    IRDY,
    DEVSEL,
    TRDY,
    STOP,
    PAR
);

parameter normal       = 0 ;
parameter disconnect   = 1 ;
parameter retry        = 2 ;
parameter target_abort = 3 ;
parameter master_abort = 4 ;
parameter error        = 5 ;

input CLK ;
inout [31:0] AD ;
inout [3:0]  CBE ;
input  RST ;
output REQ ;
input  GNT ;
inout FRAME ;
inout IRDY ;
input  DEVSEL ;
input  TRDY ;
input  STOP ;
inout  PAR ;

reg [31:0] AD_int ;
reg        AD_en ;

reg [3:0] CBE_int ;
reg       CBE_en ;

reg FRAME_int ;
reg FRAME_en ;

reg IRDY_int ;
reg IRDY_en ;

reg PAR_int ;
reg PAR_en ;

assign AD    = AD_en    ? AD_int    : 32'hzzzz_zzzz ;
assign CBE   = CBE_en   ? CBE_int   : 4'hz ;
assign FRAME = FRAME_en ? FRAME_int : 1'bz ;
assign IRDY  = IRDY_en  ? IRDY_int  : 1'bz ;
assign PAR   = PAR_en   ? PAR_int   : 1'bz ;

reg         REQ ;

event e_finish_transaction ;
event e_transfers_done ;

reg write ;
reg make_parity_error_after_last_dataphase ;

initial
begin
    REQ      = 1'b1 ;
    AD_en    = 1'b0 ;
    CBE_en   = 1'b0 ;
    FRAME_en = 1'b0 ;
    IRDY_en  = 1'b0 ;
    PAR_en   = 1'b0 ;
    write = 1'b0 ;
    make_parity_error_after_last_dataphase = 1'b0 ;
end

task unsupported_reference ;
    input [31:0] addr1 ;
    input [31:0] addr2 ;
    input [3:0]  bc1 ;
    input [3:0]  bc2 ;
    input [3:0]  be ;
    input [31:0] data ;
    input        make_addr_perr1 ;
    input        make_addr_perr2 ;
    output       ok ;
    integer      i ;
    reg          dual_address ;
    reg  [2:0]   received_termination ;
    reg  [31:0]  current_data         ;
begin:main
    ok = 1 ;
    dual_address = (bc1 == `BC_DUAL_ADDR_CYC) ;

    get_bus_ownership(ok) ;
    if (ok !== 1'b1)
        disable main ;

    addr_phase1(addr1, bc1) ;
    
    current_data = data ;

    if ( dual_address )
    begin
        write = bc2[0] ;
        addr_phase2(addr2, bc2, make_addr_perr1) ;
        first_and_last_data_phase(bc2[0], current_data, be, make_addr_perr2, 1'b0, received_termination) ;
        finish_transaction(bc2[0], 1'b0) ;
    end
    else
    begin
        write = bc1[0] ;
        first_and_last_data_phase(bc1[0], current_data, be, make_addr_perr1, 1'b0, received_termination) ;
        finish_transaction(bc1[0], 1'b0) ;
    end

    if (received_termination !== master_abort)
    begin
        ok = 0 ;
    end
end
endtask // master_reference

// task added for target overflow testing
// master writes the addresses to the coresponding locations
task normal_write_transfer ;
    input  [31:0] start_address ;
    input  [3:0]  bus_command ;
    input  [31:0] size ;
    input  [2:0]  wait_cycles ;
    output [31:0] actual_transfer ;
    output [2:0]  received_termination ;
    reg ok ;
    reg [31:0] current_address ;
    reg [31:0] current_data    ;
begin:main

    write = 1'b1 ;
    get_bus_ownership (ok) ;
    if (ok !== 1'b1)
    begin
        received_termination = error ;
        disable main ;
    end

    make_parity_error_after_last_dataphase = 1'b0 ;

    addr_phase1(start_address, bus_command) ;
    actual_transfer = 0 ;
    current_data = ~start_address ;
    if (size == 1)
    begin
        first_and_last_data_phase (1'b1, current_data, 4'hF, 1'b0, 1'b0, received_termination) ;
        if ((received_termination == normal) || (received_termination == disconnect))
            actual_transfer = 1 ;

        -> e_finish_transaction ;
    end
    else
    begin
        current_address = start_address ;
        first_data_phase (1'b1, current_data, 4'hF, 1'b0, 1'b0, received_termination) ;
        if ((received_termination == normal) || (received_termination == disconnect))
            actual_transfer = 1 ;

        if (received_termination == master_abort)
        begin
            -> e_transfers_done ;
        end

        while ((actual_transfer < (size - 1)) && (received_termination == normal))
        begin
            current_address = current_address + 4 ;
            insert_waits(1'b1, wait_cycles, received_termination) ;
            if (received_termination === normal)
            begin
                current_data = ~current_address ;
                subsequent_data_phase(1'b1, current_data, 4'hF, 1'b0, received_termination) ;
                if ((received_termination == normal) || (received_termination == disconnect))
                    actual_transfer = actual_transfer + 1 ;
            end
        end

        if (received_termination == normal)
        begin
            current_address = current_address + 4 ;
            insert_waits(1'b1, wait_cycles, received_termination) ;
            if (received_termination === normal)
            begin
                current_data = ~current_address ;
                last_data_phase(1'b1, current_data, 4'hF, 1'b0, received_termination) ;
                if ((received_termination == normal) || (received_termination == disconnect))
                    actual_transfer = actual_transfer + 1 ;
            
                -> e_finish_transaction ;
            end
            else
                -> e_transfers_done ;
        end
        else
            -> e_transfers_done ;
    end
end
endtask // normal_write_transfer

task single_transfer ;
    input  [31:0] start_address         ;
    input  [3:0]  bus_command           ;
    inout  [31:0] data                  ;
    input  [3:0]  byte_en               ;
    output [31:0] actual_transfer       ;
    output [2:0]  received_termination  ;
    reg ok ;
begin:main

    write = bus_command[0] ;
    get_bus_ownership (ok) ;
    if (ok !== 1'b1)
    begin
        received_termination = error ;
        disable main ;
    end

    make_parity_error_after_last_dataphase = 1'b0 ;

    addr_phase1(start_address, bus_command) ;
    actual_transfer = 0 ;

    first_and_last_data_phase
    (
        bus_command[0]          ,   //  !read/write
        data                    ,   //  data
        byte_en                 ,   //  byte enables
        1'b0                    ,   //  generate address parity error
        1'b0                    ,   //  generate data parity error
        received_termination        //  target response
    ) ;

    if ((received_termination == normal) || (received_termination == disconnect))
        actual_transfer = 1 ;

    -> e_finish_transaction ;

end
endtask // single_transfer

task get_bus_ownership ;
    output  ok ;
    integer deadlock ;
begin
    deadlock = 0 ;
    @(posedge CLK) ;
    while( ((GNT !== 0) || (FRAME !== 1'b1) || (IRDY !== 1'b1)) && (deadlock < 5000) )
    begin
        REQ <= #6 1'b0 ;
        @(posedge CLK) ;
        deadlock = deadlock + 1 ;
    end

    if (GNT !== 0)
    begin
        $display("*E, PCI Master could not get ownership of the bus in 5000 cycles") ;
        ok = 0 ;
    end
    else
    begin
        ok = 1 ;
    end

    REQ <= #6 1'b1 ;
end
endtask // get_bus_ownership

task addr_phase1 ;
    input [31:0] address ;
    input [3:0]  bus_command ;
begin
    FRAME_en  <= #6 1'b1 ;
    FRAME_int <= #6 1'b0 ;

    AD_en     <= #6 1'b1 ;
    AD_int    <= #6 address ;

    CBE_en    <= #6 1'b1 ;
    CBE_int   <= #6 bus_command ;
    @(posedge CLK) ;
end
endtask // addr_phase1

task addr_phase2 ;
    input [31:0] address ;
    input [3:0]  bus_command ;
    input        make_parity_error;
begin
    PAR_int <= #6 ^{AD, CBE, make_parity_error} ;
    PAR_en  <= #6 1'b1 ;
    AD_int  <= #6 address ;
    CBE_int <= #6 bus_command ;
    @(posedge CLK) ;
end
endtask

task first_and_last_data_phase ;
    input         rw ;
    inout  [31:0] data ;
    input  [3:0]  be ;
    input         make_addr_parity_error ;
    input         make_data_parity_error ;
    output [2:0]  received_termination ;
    integer i ;
begin
    FRAME_int <= #6 1'b1 ;
    first_data_phase (rw, data, be, make_addr_parity_error, make_data_parity_error, received_termination) ;
end
endtask // first_and_last_data_phase

task first_data_phase ;
    input         rw ;
    inout  [31:0] data ;
    input  [3:0]  be ;
    input         make_addr_parity_error ;
    input         make_data_parity_error ;
    output [2:0]  received_termination ;
    integer       i ;
begin
    PAR_int  <= #6 ^{AD, CBE, make_addr_parity_error} ;
    PAR_en   <= #6 1'b1 ;
    IRDY_en  <= #6 1'b1 ;
    IRDY_int <= #6 1'b0 ;
    CBE_int  <= #6 ~be ;
    if (rw)
        AD_int <= #6 data ;
    else
        AD_en <= #6 1'b0 ;

    @(posedge CLK) ;
    if (!rw)
        PAR_en <= #6 1'b0 ;
    else
        PAR_int <= #6 ^{AD, CBE, make_data_parity_error} ;

    i = 1 ;
    while ( (i < 5) && (DEVSEL === 1'b1) )
    begin
        @(posedge CLK) ;
        i = i + 1 ;
    end

    if (DEVSEL === 1'b1)
    begin
        received_termination = master_abort ;
    end
    else
    begin
        get_termination(received_termination);
        if (!rw)
            data = AD ;
    end
end
endtask // first_data_phase

task subsequent_data_phase ;
    input         rw    ;
    inout  [31:0] data  ;
    input  [3:0]  be    ;
    input         make_parity_error ;
    output [2:0]  received_termination ;
begin
    if (rw)
    begin
        PAR_int <= #6 ^{AD, CBE, make_parity_error} ;
        AD_int  <= #6 data ;
    end

    IRDY_int <= #6 1'b0 ;
    CBE_int <= #6 ~be ;
    @(posedge CLK);
    get_termination(received_termination);
    if (!rw)
        data = AD ;
end
endtask // subsequent_data_phase

task last_data_phase ;
    input         rw ;
    inout  [31:0] data ;
    input  [3:0]  be ;
    input         make_parity_error ;
    output [2:0]  received_termination ;
begin
    FRAME_int <= #6 1'b1 ;
    IRDY_int  <= #6 1'b0 ;
    if (rw)
    begin
        PAR_int <= #6 ^{AD, CBE, make_parity_error} ;
        AD_int <= #6 data ;
    end

    CBE_int <= #6 ~be ;

    @(posedge CLK);
    get_termination(received_termination);
    if (!rw)
        data = AD ;
end
endtask // last_data_phase

task get_termination ;
    output [2:0] received_termination ;
begin
    while ((TRDY === 1'b1) && (STOP === 1'b1))
        @(posedge CLK) ;

    if ( DEVSEL !== 1'b0 )
        received_termination = target_abort ;
    else if (TRDY !== 1'b1)
    begin
        if (STOP !== 1'b1)
            received_termination = disconnect ;
        else
            received_termination = normal ;
    end
    else
        received_termination = retry ;
end
endtask // get_termination

task finish_transaction ;
    input rw ;
    input make_parity_error ;
begin
    if (rw)
        PAR_int <= #6 ^{AD, CBE, make_parity_error} ;

    IRDY_int <= #6 1'b1 ;
    FRAME_en <= #6 1'b0 ;
    AD_en    <= #6 1'b0 ;
    CBE_en   <= #6 1'b0 ;
    
    @(posedge CLK) ;
    PAR_en  <= #6 1'b0 ;
    IRDY_en <= #6 1'b0 ;
end
endtask // finish_transaction

always@(e_finish_transaction)
begin
    finish_transaction (write, make_parity_error_after_last_dataphase) ;
end

always@(e_transfers_done)
begin

    if (FRAME !== 1'b1)
    begin
        FRAME_int <= #6 1'b1 ;
        IRDY_int  <= #6 1'b0 ;
        if (write)
            PAR_int <= #6 ^{CBE, AD} ;

        @(posedge CLK) ;
    end

    -> e_finish_transaction ;
end

task insert_waits ;
    input rw ;
    input  [2:0] wait_cycles ;
    output [2:0] termination ;
    reg   [2:0] wait_cycles_left ;
    reg         stop_without_trdy_received ;
begin
    stop_without_trdy_received = 1'b0 ;
    wait_cycles_left = wait_cycles ;

    termination = normal ;

    PAR_int <= #6 ^{AD, CBE} ;

    for (wait_cycles_left = wait_cycles ; (wait_cycles_left > 0) && !stop_without_trdy_received ; wait_cycles_left = wait_cycles_left - 1'b1)
    begin
        IRDY_int <= #6 1'b1 ;
        @(posedge CLK) ;

        PAR_int <= #6 ^{AD, CBE, 1'b1} ;

        if ((STOP !== 1'b1) && (TRDY !== 1'b0))
        begin
            stop_without_trdy_received = 1'b1 ;
            if (DEVSEL !== 1'b0)
                termination = target_abort ;
            else
                termination = retry ;
        end
    end
end
endtask // insert_waits
endmodule

