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
`define M     593         // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define WIDTH_D0 1187

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
            write(3, 1186'h088a6aa4a8aa80a9aa922965a92a56510856606aa6400649a6004866466928a20090908210195560a8162a52442029a44a68004a8168496a0a8a8564962a0948118a5599a29450214995828245914a099051991602550105228289686988621a1a9126648644619a66111a026452641169158a4686884aa212199582406600921229a5948802528289a62454a2566a4122586a496);
            write(5, 1186'h05448582294062429a891a6509092496844141090214064988646241904502a0225046a54851a05454020044881088a2092411592909289861049124644a964a6188014aa25869a09890401a924048815a1008421459455411a4a65094410615a524458901026a9108a468650515a5aa50468005881a29055980995a145995146909841aa18890902264628884421894959956195);
            write(6, 1186'h088a6aa4a8aa80a9aa922965a92a56510856606aa6400649a6004866466928a20090908210195560a8162a52442029a44a68004a8168496a0a8a8564962a0948118a5599a29450214995828245914a099051991602550105228289686988621a1a9126648644619a66111a026452641169158a4686884aa212199582406600921229a5948802528289a62454a2566a4122586a496);
            write(7, 1186'h05448582294062429a891a6509092496844141090214064988646241904502a0225046a54851a05454020044881088a2092411592909289861049124644a964a6188014aa25869a09890401a924048815a1008421459455411a4a65094410615a524458901026a9108a468650515a5aa50468005881a29055980995a145995146909841aa18890902264628884421894959956195);
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
            check(1186'h20115a6958895a08585a412698a58250900a651a859448a4848125164545598a426119a09885802424154a08855a0042a168516099228606222540582026aa0a6029a88805a1888628856a2a64504120aa290491925284508921140a24a0a8641548a521512698985a610861a401208644612a4a52625119000006004518844899810191a056aaa680889958996508954685a0920);
            read(10);
            check(1186'h228a9556506501a0258028a8856851a5466a205a2544849a12a10a018a40aaa461959859a4408245094969a44565a160a98229805169491120568121008a04918050a9022854868440662591221116889a9668a82aa84182a59025424469164015a56698a95989555601618402286696055608a82508125aaa5882000aaa96114998660a684582889a5a5190058a0411426145250);
            read(11);
            check(1186'h001224a468a9154205488585aaa9a0a9882056194952001a88424522191052a96a21102915181a845a5509844985196696160900a0515956a2a10a100a12566408a14450049a586951896442400a8620148582958a8a51869990a161412406860012a61a66214a4461a86895640a48284528201852615921952aaaaa40802586168a929582128a985929990826a9110186891489a);
            read(12);
            check(1186'h019618a9624a522a280a06a0654418906998059625a892054996a0560a941a842589189984190884426125114000aa60a0a568285221026662226a626a8600605095054405486561a95059449282969a5a10819101a620902609052a1294182962a020512196945a2aa42598a41842096596551544969262a12a86685214a952494a956166a199682a649249a990088296422051a);
            read(13);
            check(1186'h1a6999a0105054aaa2145298116480601695482119a0619155a4414a8a82840918a512a5680a8000889a4905016868480211289860a8a5699a250245161a042846096a9866025094a189860a9829465281646040866a26959a61a18621848689101a9a95685016a9581224968461a0a108958a91205a0220a18865105928298299a642a906900289a95095845649aa41591069866);
            read(14);
            check(1186'h15a4208a19a0405005900212505098a881a49445242619a12a12491844110169529a422046a684668819599891a411954196961160591865590a699a04908a6196928965a1686a664210420908115a5816919169662656a855099464680902514586265602510840a566a94a506961a615420a908aa91959610a1a0899589600902a10962460a664104126056a82551462459169a);
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

