
`timescale 1ps/1ps

module rom (
	cex,
	//wex,
	oex,
	address,
	data
);
	input		cex;
	//input		wex;
	input		oex;
	input	[20:0]	address;
	inout	[7:0]	data;

	reg	[7:0]	mem[0:2097152-1];

	integer		i;
	
	parameter	LoadFileName = "default_rom.txt";
	parameter	SaveFileName = "default_rom.txt";

	// original version(share FPGA_image and Boot_image)
	// parameter	ImageOffset   = 1048576;
	parameter	ImageOffset   = 0;
	parameter	ImageSize     = 1048576;

	initial begin
		#1;
		$display("ROM-INIT:time=%0t",$time);
		$display("ROM-INIT:instance:(%m)");
		$display("ROM-INIT:LoadFilename:(%s)",LoadFileName);
		$display("ROM-INIT:ImageOffset(%d)",ImageOffset);
		$display("ROM-INIT:ImageSize(%d)",ImageSize);
		
		$display("ROM-INIT:read");
		$readmemh(LoadFileName,mem);
		
		$display("ROM-INIT:move");
		for (i=0;i<ImageSize;i=i+1) mem[i+ImageOffset] = mem[i];

		$display("ROM-INIT:org area x");
		for (i=0;i<ImageOffset;i=i+1) mem[i] = {8{1'bx}};

	end

	assign #10_000 data = ((!cex) && (!oex)) ? mem[address]: {8{1'bz}};

endmodule
