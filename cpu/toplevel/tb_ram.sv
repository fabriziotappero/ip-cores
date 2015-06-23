//--------------------------------------------------------------
// Implements RAM Model for simulation
// Loads in a file "ram.hexdump" before execution.
//--------------------------------------------------------------
module ram (Address, Data, CS, WE, OE);

// Set this to 1 if you want debug printout on each RAM access
int debug = 0;

input [15:0] Address;
inout [7:0] Data;
input CS, WE, OE;

reg [7:0] Mem [0:1<<16];

// Return data at the specified memory address; return 0x76 for non-initialized memory
assign Data = (!CS && !OE) ? (Mem[Address]===8'hxx) ? 8'h76 : Mem[Address] : {8{1'bz}};

// Read the initial content of the RAM memory from a file
initial begin : init
    // Read the CPU code (address 0) to simulate
    $readmemh("ram.hexdump", Mem, 0);
end : init

always @(!CS && !OE) begin
    if (debug)
        $strobe("[ram] RD A=%H, D=%H", Address, Data);
end

always @(CS or WE)
    if (!CS && !WE) begin
        if (debug)
            $strobe("[ram] WR A=%H, D=%H", Address, Data);
        Mem[Address] = Data;
    end

always @(WE or OE)
    if (!WE && !OE)
        $display("[ram] error: OE and WE both active!");

endmodule
