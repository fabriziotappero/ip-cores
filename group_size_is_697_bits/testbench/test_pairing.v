/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`timescale 1ns / 1ps
`define P 20 // clock period 
`define M     503         // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define WIDTH_D0 (1008-1)

module test_pairing;

	// Inputs
	reg clk;
	reg reset;
	reg sel;
	reg [5:0] addr;
	reg w;
    reg update;
    reg ready;
    reg i;

	// Outputs
	wire done;
    wire o;

    // Buffers
	reg [`WIDTH_D0:0] out;

	// Instantiate the Unit Under Test (UUT)
	pairing uut (
        .clk(clk), 
        .reset(reset), 
        .sel(sel), 
        .addr(addr), 
        .w(w), 
        .update(update),
        .ready(ready),
        .i(i),
        .o(o),
        .done(done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		sel = 0;
		addr = 0;
		w = 0;
        update = 0;
        ready = 0;
        i = 0;
        out = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        /* keep FSM silent */
        reset = 1;
            /* init xp, yp, xq, yq */
            write(3, 1006'h0412500224298894260864922a0084a98a0454681a18164a08268062495a596469659050406960a191646a024a0aa26688240682059585a258a89664946584924a9a8a1a8145400889899a6a2601184a2596419a04161969169128281805669a9509145852901691690a8506a9145224850109a150110629229564901a00);
            write(5, 1006'h161181618265a480158208a088a01aa89a424001019a90912969511008944a806119a1429520105654089861546a912295590518a90842962660a665899405681aa510844840524240145a0295855920091640a66a5a044568510469454a18a06218922914510004a25409a81a5800456055996128a965624116289904aa);
            write(6, 1006'h0412500224298894260864922a0084a98a0454681a18164a08268062495a596469659050406960a191646a024a0aa26688240682059585a258a89664946584924a9a8a1a8145400889899a6a2601184a2596419a04161969169128281805669a9509145852901691690a8506a9145224850109a150110629229564901a00);
            write(7, 1006'h161181618265a480158208a088a01aa89a424001019a90912969511008944a806119a1429520105654089861546a912295590518a90842962660a665899405681aa510844840524240145a0295855920091640a66a5a044568510469454a18a06218922914510004a25409a81a5800456055996128a965624116289904aa);
            /* read back. uncomment me if error happens */
            /* read(3);
            $display("xp = %h", out);
            read(5);
            $display("yp = %h", out);
            read(6);
            $display("xq = %h", out);
            read(7);
            $display("yq = %h", out);*/
        reset = 0;
        
        sel = 0; w = 0;
        @(posedge done);
        @(negedge clk);
            read(9);
            check(1006'h2965a664a44a85426524a19821aa12a42605258540a056525248149a96061560451a6a95861496a8140985a8902955951552696a425948159a2141a0aaa5840442851218546a49a2a2496658644656a9a6162a5098a025645151aa668902aaa102a0805900488980545120462896204252584282868449488a00884995a9);
            read(10);
            check(1006'h244151402864a58144a0509a26121148024224a299a4062a248944801589895a04a8a681a4245492a5aa5958901a142120515582941220529512012554699982594528256086220a55641a5a212511aa50a0a4a198200560a628994925551249659028459a8a24688191044a08529064119949a112564a52082068858890);
            read(11);
            check(1006'h180645a168488aa651260a226a124a66080299922a8595404428610808262992a22682905a55625665824505a609882a88422a886296551a6221a29a16aa11141a12280942aa84094946860205964a26669684569054810a914124a086212a5a5821440119015a98844101854a9951141981221169224a1599a11914a504);
            read(12);
            check(1006'h18a6911a415584242209a6a52629464160400a0a45554552866a9a20a8520a551856814024118140a144a151604449609aa24085a609a2a0851285445a96602a2461212641204a591a66a5604211004882191912920862a9860a861a88a005516611622a44880a48690412292244615156004952521664a84a5961510225);
            read(13);
            check(1006'h250869062a008a1882940945a20441680111009595094282260a95488aaa4588262641912aa64a29a8526408451940619612014212441090209588888a004002462206a8294a158809258852650a15226a99808952201191614814166198a52a8151454968a288295994286919811691aa21048661a5288402182a558215);
            read(14);
            check(1006'h016641111896469064656661124a160226a89485469954a6a5406aa28590655a018922965688045984585a61888165085289a61a051258a59459210842108082566966664250991442a2941521806608610a52182256042680a4881900605a8459260a9824295244629865a6a62a18958a66955152404814065588150894);
            $display("Good");
        $finish;
	end

    initial #100 forever #(`P/2) clk = ~clk;

    task write;
        input [5:0] adr;
        input [`WIDTH_D0:0] dat;
        integer j;
        begin
            sel = 1; 
            w = 0;
            addr = adr;
            update = 1;
            #`P;
            update = 0;
            ready = 1;
            for(j=0;j<`WIDTH_D0+1;j=j+1)
               begin
               i = dat[j];
               #`P;
               end
            ready = 0;
            w = 1; #`P; w = 0;
        end
    endtask

    task read;
        input [5:0] adr;
        integer j;
        begin
            sel = 1;
            w = 0;
            addr = adr;
            #`P;
            update = 1;
            #`P;
            update = 0;
            out = 0;
            ready = 1;
            for(j=0;j<`WIDTH_D0+1;j=j+1)
               begin
               out = {o, out[`WIDTH_D0:1]};
               #`P;
               end
        end
    endtask
    
    task check;
        input [`WIDTH_D0:0] wish;
        begin
            if (out !== wish) 
                begin $display("Error!"); $finish; end
        end
    endtask    
endmodule

