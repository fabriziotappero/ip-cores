//--------------------------------------------------------------
// Implements I/O Model for simulation
//--------------------------------------------------------------
module io (Address, Data, CS, WE, OE);

// Set to 1 to have text output to the file "iolog.txt"
int iolog = 1;

// Set to 1 if you want debug printout on each IO access
int debug = 0;

int fd;
input [15:0] Address;
inout [7:0] Data;
input CS, WE, OE;

reg [7:0] IO [0:1<<16];

// Return data for the specified IO address:
//  1. If the current address is 0A00, that's the UART busy bit (which is never busy for ModelSim), so return 00
//  2. If the IO map is not defined for the current address, return FF
//  3. If the IO map is defined, return the value from it
//  4. Lastly, if !CS and !OE (not selecting the IO), tri-state the data bus
assign Data = (!CS && !OE) ? (Address==16'h0A00)? 8'h00 : (IO[Address]===8'hxx) ? 8'hFF : IO[Address] : {8{1'bz}};

// Read the initial content of the IO map from file
initial begin : init
    $readmemh("io.hex", IO);
    // If logging to a file was enabled, clear the file so we can append
    if (iolog) begin
        fd = $fopen("iolog.txt", "wb");
        $fclose(fd);
    end
end : init

always @(!CS && !OE) begin
    if (debug)
        $strobe("[IO] IN A=%H, D=%H", Address, Data);
end

always @(CS or WE)
    if (!CS && !WE) begin
        if (debug)
            $strobe("[IO] OUT A=%H, D=%H", Address, Data);
        if (Address==8*256) begin
            $write("%c", Data);
            // If logging to a file was enabled, append a character
            if (iolog) begin
                fd = $fopen("iolog.txt", "ab");
                $fwrite(fd, "%c", Data);
                $fclose(fd);
            end
        end
        IO[Address] = Data;
    end

always @(WE or OE)
    if (!WE && !OE)
        $display("[IO] error: OE and WE both active!");

endmodule
