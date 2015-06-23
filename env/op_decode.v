/*
 * Z80 instruction decoder
 * Author: Guy Hutchison
 */

module op_decode;

task decode0;
  input [7:0] opcode;
  inout [7:0] state;
  begin
  case (opcode)
    8'h00 : $display ("%t: OPCODE  : NOP   ", $time);
    8'h01 : 
      begin
        $display ("%t: OPCODE  : LD    BC,word", $time);
        state = {4'd1, 4'd2};
      end
    8'h02 : $display ("%t: OPCODE  : LD    (BC),A", $time);
    8'h03 : $display ("%t: OPCODE  : INC   BC", $time);
    8'h04 : $display ("%t: OPCODE  : INC   B", $time);
    8'h05 : $display ("%t: OPCODE  : DEC   B", $time);
    8'h06 : 
      begin
        $display ("%t: OPCODE  : LD    B,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'h07 : $display ("%t: OPCODE  : RLCA  ", $time);
    8'h08 : $display ("%t: OPCODE  : EX    AF,AF'", $time);
    8'h09 : $display ("%t: OPCODE  : ADD   HL,BC", $time);
    8'h0a : $display ("%t: OPCODE  : LD    A,(BC)", $time);
    8'h0b : $display ("%t: OPCODE  : DEC   BC", $time);
    8'h0c : $display ("%t: OPCODE  : INC   C", $time);
    8'h0d : $display ("%t: OPCODE  : DEC   C", $time);
    8'h0e : 
      begin
        $display ("%t: OPCODE  : LD    C,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'h0f : $display ("%t: OPCODE  : RRCA  ", $time);
    8'h10 : 
      begin
        $display ("%t: OPCODE  : DJNZ  index", $time);
        state = {4'd1, 4'd1};
      end
    8'h11 : 
      begin
        $display ("%t: OPCODE  : LD    DE,word", $time);
        state = {4'd1, 4'd2};
      end
    8'h12 : $display ("%t: OPCODE  : LD    (DE),A", $time);
    8'h13 : $display ("%t: OPCODE  : INC   DE", $time);
    8'h14 : $display ("%t: OPCODE  : INC   D", $time);
    8'h15 : $display ("%t: OPCODE  : DEC   D", $time);
    8'h16 : 
      begin
        $display ("%t: OPCODE  : LD    D,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'h17 : $display ("%t: OPCODE  : RLA   ", $time);
    8'h18 : 
      begin
        $display ("%t: OPCODE  : JR    index", $time);
        state = {4'd1, 4'd1};
      end
    8'h19 : $display ("%t: OPCODE  : ADD   HL,DE", $time);
    8'h1a : $display ("%t: OPCODE  : LD    A,(DE)", $time);
    8'h1b : $display ("%t: OPCODE  : DEC   DE", $time);
    8'h1c : $display ("%t: OPCODE  : INC   E", $time);
    8'h1d : $display ("%t: OPCODE  : DEC   E", $time);
    8'h1e : 
      begin
        $display ("%t: OPCODE  : LD    E,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'h1f : $display ("%t: OPCODE  : RRA   ", $time);
    8'h20 : 
      begin
        $display ("%t: OPCODE  : JR    NZ,index", $time);
        state = {4'd1, 4'd1};
      end
    8'h21 : 
      begin
        $display ("%t: OPCODE  : LD    HL,word", $time);
        state = {4'd1, 4'd2};
      end
    8'h22 : 
      begin
        $display ("%t: OPCODE  : LD    (word),HL", $time);
        state = {4'd1, 4'd2};
      end
    8'h23 : $display ("%t: OPCODE  : INC   HL", $time);
    8'h24 : $display ("%t: OPCODE  : INC   H", $time);
    8'h25 : $display ("%t: OPCODE  : DEC   H", $time);
    8'h26 : 
      begin
        $display ("%t: OPCODE  : LD    H,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'h27 : $display ("%t: OPCODE  : DAA   ", $time);
    8'h28 : 
      begin
        $display ("%t: OPCODE  : JR    Z,index", $time);
        state = {4'd1, 4'd1};
      end
    8'h29 : $display ("%t: OPCODE  : ADD   HL,HL", $time);
    8'h2a : 
      begin
        $display ("%t: OPCODE  : LD    HL,(word)", $time);
        state = {4'd1, 4'd2};
      end
    8'h2b : $display ("%t: OPCODE  : DEC   HL", $time);
    8'h2c : $display ("%t: OPCODE  : INC   L", $time);
    8'h2d : $display ("%t: OPCODE  : DEC   L", $time);
    8'h2e : 
      begin
        $display ("%t: OPCODE  : LD    L,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'h2f : $display ("%t: OPCODE  : CPL   ", $time);
    8'h30 : 
      begin
        $display ("%t: OPCODE  : JR    NC,index", $time);
        state = {4'd1, 4'd1};
      end
    8'h31 : 
      begin
        $display ("%t: OPCODE  : LD    SP,word", $time);
        state = {4'd1, 4'd2};
      end
    8'h32 : 
      begin
        $display ("%t: OPCODE  : LD    (word),A", $time);
        state = {4'd1, 4'd2};
      end
    8'h33 : $display ("%t: OPCODE  : INC   SP", $time);
    8'h34 : $display ("%t: OPCODE  : INC   (HL)", $time);
    8'h35 : $display ("%t: OPCODE  : DEC   (HL)", $time);
    8'h36 : 
      begin
        $display ("%t: OPCODE  : LD    (HL),byte", $time);
        state = {4'd1, 4'd1};
      end
    8'h37 : $display ("%t: OPCODE  : SCF   ", $time);
    8'h38 : 
      begin
        $display ("%t: OPCODE  : JR    C,index", $time);
        state = {4'd1, 4'd1};
      end
    8'h39 : $display ("%t: OPCODE  : ADD   HL,SP", $time);
    8'h3a : 
      begin
        $display ("%t: OPCODE  : LD    A,(word)", $time);
        state = {4'd1, 4'd2};
      end
    8'h3b : $display ("%t: OPCODE  : DEC   SP", $time);
    8'h3c : $display ("%t: OPCODE  : INC   A", $time);
    8'h3d : $display ("%t: OPCODE  : DEC   A", $time);
    8'h3e : 
      begin
        $display ("%t: OPCODE  : LD    A,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'h3f : $display ("%t: OPCODE  : CCF   ", $time);
    8'h40 : $display ("%t: OPCODE  : LD    B,B", $time);
    8'h41 : $display ("%t: OPCODE  : LD    B,C", $time);
    8'h42 : $display ("%t: OPCODE  : LD    B,D", $time);
    8'h43 : $display ("%t: OPCODE  : LD    B,E", $time);
    8'h44 : $display ("%t: OPCODE  : LD    B,H", $time);
    8'h45 : $display ("%t: OPCODE  : LD    B,L", $time);
    8'h46 : $display ("%t: OPCODE  : LD    B,(HL)", $time);
    8'h47 : $display ("%t: OPCODE  : LD    B,A", $time);
    8'h48 : $display ("%t: OPCODE  : LD    C,B", $time);
    8'h49 : $display ("%t: OPCODE  : LD    C,C", $time);
    8'h4a : $display ("%t: OPCODE  : LD    C,D", $time);
    8'h4b : $display ("%t: OPCODE  : LD    C,E", $time);
    8'h4c : $display ("%t: OPCODE  : LD    C,H", $time);
    8'h4d : $display ("%t: OPCODE  : LD    C,L", $time);
    8'h4e : $display ("%t: OPCODE  : LD    C,(HL)", $time);
    8'h4f : $display ("%t: OPCODE  : LD    C,A", $time);
    8'h50 : $display ("%t: OPCODE  : LD    D,B", $time);
    8'h51 : $display ("%t: OPCODE  : LD    D,C", $time);
    8'h52 : $display ("%t: OPCODE  : LD    D,D", $time);
    8'h53 : $display ("%t: OPCODE  : LD    D,E", $time);
    8'h54 : $display ("%t: OPCODE  : LD    D,H", $time);
    8'h55 : $display ("%t: OPCODE  : LD    D,L", $time);
    8'h56 : $display ("%t: OPCODE  : LD    D,(HL)", $time);
    8'h57 : $display ("%t: OPCODE  : LD    D,A", $time);
    8'h58 : $display ("%t: OPCODE  : LD    E,B", $time);
    8'h59 : $display ("%t: OPCODE  : LD    E,C", $time);
    8'h5a : $display ("%t: OPCODE  : LD    E,D", $time);
    8'h5b : $display ("%t: OPCODE  : LD    E,E", $time);
    8'h5c : $display ("%t: OPCODE  : LD    E,H", $time);
    8'h5d : $display ("%t: OPCODE  : LD    E,L", $time);
    8'h5e : $display ("%t: OPCODE  : LD    E,(HL)", $time);
    8'h5f : $display ("%t: OPCODE  : LD    E,A", $time);
    8'h60 : $display ("%t: OPCODE  : LD    H,B", $time);
    8'h61 : $display ("%t: OPCODE  : LD    H,C", $time);
    8'h62 : $display ("%t: OPCODE  : LD    H,D", $time);
    8'h63 : $display ("%t: OPCODE  : LD    H,E", $time);
    8'h64 : $display ("%t: OPCODE  : LD    H,H", $time);
    8'h65 : $display ("%t: OPCODE  : LD    H,L", $time);
    8'h66 : $display ("%t: OPCODE  : LD    H,(HL)", $time);
    8'h67 : $display ("%t: OPCODE  : LD    H,A", $time);
    8'h68 : $display ("%t: OPCODE  : LD    L,B", $time);
    8'h69 : $display ("%t: OPCODE  : LD    L,C", $time);
    8'h6a : $display ("%t: OPCODE  : LD    L,D", $time);
    8'h6b : $display ("%t: OPCODE  : LD    L,E", $time);
    8'h6c : $display ("%t: OPCODE  : LD    L,H", $time);
    8'h6d : $display ("%t: OPCODE  : LD    L,L", $time);
    8'h6e : $display ("%t: OPCODE  : LD    L,(HL)", $time);
    8'h6f : $display ("%t: OPCODE  : LD    L,A", $time);
    8'h70 : $display ("%t: OPCODE  : LD    (HL),B", $time);
    8'h71 : $display ("%t: OPCODE  : LD    (HL),C", $time);
    8'h72 : $display ("%t: OPCODE  : LD    (HL),D", $time);
    8'h73 : $display ("%t: OPCODE  : LD    (HL),E", $time);
    8'h74 : $display ("%t: OPCODE  : LD    (HL),H", $time);
    8'h75 : $display ("%t: OPCODE  : LD    (HL),L", $time);
    8'h76 : $display ("%t: OPCODE  : HLT   ", $time);
    8'h77 : $display ("%t: OPCODE  : LD    (HL),A", $time);
    8'h78 : $display ("%t: OPCODE  : LD    A,B", $time);
    8'h79 : $display ("%t: OPCODE  : LD    A,C", $time);
    8'h7a : $display ("%t: OPCODE  : LD    A,D", $time);
    8'h7b : $display ("%t: OPCODE  : LD    A,E", $time);
    8'h7c : $display ("%t: OPCODE  : LD    A,H", $time);
    8'h7d : $display ("%t: OPCODE  : LD    A,L", $time);
    8'h7e : $display ("%t: OPCODE  : LD    A,(HL)", $time);
    8'h7f : $display ("%t: OPCODE  : LD    A,A", $time);
    8'h80 : $display ("%t: OPCODE  : ADD   A,B", $time);
    8'h81 : $display ("%t: OPCODE  : ADD   A,C", $time);
    8'h82 : $display ("%t: OPCODE  : ADD   A,D", $time);
    8'h83 : $display ("%t: OPCODE  : ADD   A,E", $time);
    8'h84 : $display ("%t: OPCODE  : ADD   A,H", $time);
    8'h85 : $display ("%t: OPCODE  : ADD   A,L", $time);
    8'h86 : $display ("%t: OPCODE  : ADD   A,(HL)", $time);
    8'h87 : $display ("%t: OPCODE  : ADD   A,A", $time);
    8'h88 : $display ("%t: OPCODE  : ADC   A,B", $time);
    8'h89 : $display ("%t: OPCODE  : ADC   A,C", $time);
    8'h8a : $display ("%t: OPCODE  : ADC   A,D", $time);
    8'h8b : $display ("%t: OPCODE  : ADC   A,E", $time);
    8'h8c : $display ("%t: OPCODE  : ADC   A,H", $time);
    8'h8d : $display ("%t: OPCODE  : ADC   A,L", $time);
    8'h8e : $display ("%t: OPCODE  : ADC   A,(HL)", $time);
    8'h8f : $display ("%t: OPCODE  : ADC   A,A", $time);
    8'h90 : $display ("%t: OPCODE  : SUB   B", $time);
    8'h91 : $display ("%t: OPCODE  : SUB   C", $time);
    8'h92 : $display ("%t: OPCODE  : SUB   D", $time);
    8'h93 : $display ("%t: OPCODE  : SUB   E", $time);
    8'h94 : $display ("%t: OPCODE  : SUB   H", $time);
    8'h95 : $display ("%t: OPCODE  : SUB   L", $time);
    8'h96 : $display ("%t: OPCODE  : SUB   (HL)", $time);
    8'h97 : $display ("%t: OPCODE  : SUB   A", $time);
    8'h98 : $display ("%t: OPCODE  : SBC   B", $time);
    8'h99 : $display ("%t: OPCODE  : SBC   C", $time);
    8'h9a : $display ("%t: OPCODE  : SBC   D", $time);
    8'h9b : $display ("%t: OPCODE  : SBC   E", $time);
    8'h9c : $display ("%t: OPCODE  : SBC   H", $time);
    8'h9d : $display ("%t: OPCODE  : SBC   L", $time);
    8'h9e : $display ("%t: OPCODE  : SBC   (HL)", $time);
    8'h9f : $display ("%t: OPCODE  : SBC   A", $time);
    8'ha0 : $display ("%t: OPCODE  : AND   B", $time);
    8'ha1 : $display ("%t: OPCODE  : AND   C", $time);
    8'ha2 : $display ("%t: OPCODE  : AND   D", $time);
    8'ha3 : $display ("%t: OPCODE  : AND   E", $time);
    8'ha4 : $display ("%t: OPCODE  : AND   H", $time);
    8'ha5 : $display ("%t: OPCODE  : AND   L", $time);
    8'ha6 : $display ("%t: OPCODE  : AND   (HL)", $time);
    8'ha7 : $display ("%t: OPCODE  : AND   A", $time);
    8'ha8 : $display ("%t: OPCODE  : XOR   B", $time);
    8'ha9 : $display ("%t: OPCODE  : XOR   C", $time);
    8'haa : $display ("%t: OPCODE  : XOR   D", $time);
    8'hab : $display ("%t: OPCODE  : XOR   E", $time);
    8'hac : $display ("%t: OPCODE  : XOR   H", $time);
    8'had : $display ("%t: OPCODE  : XOR   L", $time);
    8'hae : $display ("%t: OPCODE  : XOR   (HL)", $time);
    8'haf : $display ("%t: OPCODE  : XOR   A", $time);
    8'hb0 : $display ("%t: OPCODE  : OR    B", $time);
    8'hb1 : $display ("%t: OPCODE  : OR    C", $time);
    8'hb2 : $display ("%t: OPCODE  : OR    D", $time);
    8'hb3 : $display ("%t: OPCODE  : OR    E", $time);
    8'hb4 : $display ("%t: OPCODE  : OR    H", $time);
    8'hb5 : $display ("%t: OPCODE  : OR    L", $time);
    8'hb6 : $display ("%t: OPCODE  : OR    (HL)", $time);
    8'hb7 : $display ("%t: OPCODE  : OR    A", $time);
    8'hb8 : $display ("%t: OPCODE  : CP    B", $time);
    8'hb9 : $display ("%t: OPCODE  : CP    C", $time);
    8'hba : $display ("%t: OPCODE  : CP    D", $time);
    8'hbb : $display ("%t: OPCODE  : CP    E", $time);
    8'hbc : $display ("%t: OPCODE  : CP    H", $time);
    8'hbd : $display ("%t: OPCODE  : CP    L", $time);
    8'hbe : $display ("%t: OPCODE  : CP    (HL)", $time);
    8'hbf : $display ("%t: OPCODE  : CP    A", $time);
    8'hc0 : $display ("%t: OPCODE  : RET   NZ", $time);
    8'hc1 : $display ("%t: OPCODE  : POP   BC", $time);
    8'hc2 : 
      begin
        $display ("%t: OPCODE  : JP    NZ,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hc3 : 
      begin
        $display ("%t: OPCODE  : JP    address", $time);
        state = {4'd1, 4'd2};
      end
    8'hc4 : 
      begin
        $display ("%t: OPCODE  : CALL  NZ,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hc5 : $display ("%t: OPCODE  : PUSH  BC", $time);
    8'hc6 : 
      begin
        $display ("%t: OPCODE  : ADD   A,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'hc7 : $display ("%t: OPCODE  : RST   0", $time);
    8'hc8 : $display ("%t: OPCODE  : RET   Z", $time);
    8'hc9 : $display ("%t: OPCODE  : RET   ", $time);
    8'hca : 
      begin
        $display ("%t: OPCODE  : JP    Z,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hcb : state = 8'hcb;
    8'hcc : 
      begin
        $display ("%t: OPCODE  : CALL  Z,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hcd : 
      begin
        $display ("%t: OPCODE  : CALL  address", $time);
        state = {4'd1, 4'd2};
      end
    8'hce : 
      begin
        $display ("%t: OPCODE  : ADC   A,byte", $time);
        state = {4'd1, 4'd1};
      end
    8'hcf : $display ("%t: OPCODE  : RST   8", $time);
    8'hd0 : $display ("%t: OPCODE  : RET   NC", $time);
    8'hd1 : $display ("%t: OPCODE  : POP   DE", $time);
    8'hd2 : 
      begin
        $display ("%t: OPCODE  : JP    NC,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hd3 :
      begin
        $display ("%t: OPCODE  : OUT   (byte),A", $time);
        state = {4'd1, 4'd1};
      end
    8'hd4 : 
      begin
        $display ("%t: OPCODE  : CALL  NC,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hd5 : $display ("%t: OPCODE  : PUSH  DE", $time);
    8'hd6 : 
      begin
        $display ("%t: OPCODE  : SUB   byte", $time);
        state = {4'd1, 4'd1};
      end
    8'hd7 : $display ("%t: OPCODE  : RST   10H", $time);
    8'hd8 : $display ("%t: OPCODE  : RET   C", $time);
    8'hd9 : $display ("%t: OPCODE  : EXX   ", $time);
    8'hda : 
      begin
        $display ("%t: OPCODE  : JP    C,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hdb : 
      begin
        $display ("%t: OPCODE  : IN    A,(byte)", $time);
        state = {4'd1, 4'd1};
      end
    8'hd3 : 
      begin
        $display ("%t: OPCODE  : OUT   (byte),A", $time);
        state = {4'd1, 4'd1};
      end
    8'hdc : 
      begin
        $display ("%t: OPCODE  : CALL  C,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hdd : state = 8'hdd;
    8'hde : 
      begin
        $display ("%t: OPCODE  : SBC   byte", $time);
        state = {4'd1, 4'd1};
      end
    8'hdf : $display ("%t: OPCODE  : RST   18H", $time);
    8'he0 : $display ("%t: OPCODE  : RET   PO", $time);
    8'he1 : $display ("%t: OPCODE  : POP   HL", $time);
    8'he2 : 
      begin
        $display ("%t: OPCODE  : JP    PO,address", $time);
        state = {4'd1, 4'd2};
      end
    8'he3 : $display ("%t: OPCODE  : EX    (SP),HL", $time);
    8'he4 : 
      begin
        $display ("%t: OPCODE  : CALL  PO,address", $time);
        state = {4'd1, 4'd2};
      end
    8'he5 : $display ("%t: OPCODE  : PUSH  HL", $time);
    8'he6 : 
      begin
        $display ("%t: OPCODE  : AND   byte", $time);
        state = {4'd1, 4'd1};
      end
    8'he7 : $display ("%t: OPCODE  : RST   20H", $time);
    8'he8 : $display ("%t: OPCODE  : RET   PE", $time);
    8'he9 : $display ("%t: OPCODE  : JP    (HL)", $time);
    8'hea : 
      begin
        $display ("%t: OPCODE  : JP    PE,address", $time);
        state = {4'd1, 4'd2};
      end
    8'heb : $display ("%t: OPCODE  : EX    DE,HL", $time);
    8'hec : 
      begin
        $display ("%t: OPCODE  : CALL  PE,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hed : state = 8'hed;
    8'hee : 
      begin
        $display ("%t: OPCODE  : XOR   byte", $time);
        state = {4'd1, 4'd1};
      end
    8'hef : $display ("%t: OPCODE  : RST   28H", $time);
    8'hf0 : $display ("%t: OPCODE  : RET   P", $time);
    8'hf1 : $display ("%t: OPCODE  : POP   AF", $time);
    8'hf2 : 
      begin
        $display ("%t: OPCODE  : JP    P,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hf3 : $display ("%t: OPCODE  : DI    ", $time);
    8'hf4 : 
      begin
        $display ("%t: OPCODE  : CALL  P,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hf5 : $display ("%t: OPCODE  : PUSH  AF", $time);
    8'hf6 : 
      begin
        $display ("%t: OPCODE  : OR    byte", $time);
        state = {4'd1, 4'd1};
      end
    8'hf7 : $display ("%t: OPCODE  : RST   30H", $time);
    8'hf8 : $display ("%t: OPCODE  : RET   M", $time);
    8'hf9 : $display ("%t: OPCODE  : LD    SP,HL", $time);
    8'hfa : 
      begin
        $display ("%t: OPCODE  : JM    M,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hfb : $display ("%t: OPCODE  : EI    ", $time);
    8'hfc : 
      begin
        $display ("%t: OPCODE  : CALL  M,address", $time);
        state = {4'd1, 4'd2};
      end
    8'hfd : state = 8'hfd;
    8'hfe : 
      begin
        $display ("%t: OPCODE  : CP    byte", $time);
        state = {4'd1, 4'd1};
      end
    8'hff : $display ("%t: OPCODE  : RST   38H", $time);
  endcase
  end
endtask
task decode1;
  input [7:0] opcode;
  inout [7:0] state;
  begin
  casex (state)
    8'hcb : 
      begin
        case (opcode)
          8'h07 : 
            begin
              $display ("%t: OPCODE  : RLC   A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h00 : 
            begin
              $display ("%t: OPCODE  : RLC   B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h01 : 
            begin
              $display ("%t: OPCODE  : RLC   C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h02 : 
            begin
              $display ("%t: OPCODE  : RLC   D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h03 : 
            begin
              $display ("%t: OPCODE  : RLC   E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h04 : 
            begin
              $display ("%t: OPCODE  : RLC   H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h05 : 
            begin
              $display ("%t: OPCODE  : RLC   L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h06 : 
            begin
              $display ("%t: OPCODE  : RLC   (HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h17 : 
            begin
              $display ("%t: OPCODE  : RL    A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h10 : 
            begin
              $display ("%t: OPCODE  : RL    B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h11 : 
            begin
              $display ("%t: OPCODE  : RL    C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h12 : 
            begin
              $display ("%t: OPCODE  : RL    D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h13 : 
            begin
              $display ("%t: OPCODE  : RL    E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h14 : 
            begin
              $display ("%t: OPCODE  : RL    H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h15 : 
            begin
              $display ("%t: OPCODE  : RL    L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h16 : 
            begin
              $display ("%t: OPCODE  : RL    (HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h0f : 
            begin
              $display ("%t: OPCODE  : RRC   A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h08 : 
            begin
              $display ("%t: OPCODE  : RRC   B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h09 : 
            begin
              $display ("%t: OPCODE  : RRC   C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h0a : 
            begin
              $display ("%t: OPCODE  : RRC   D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h0b : 
            begin
              $display ("%t: OPCODE  : RRC   E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h0c : 
            begin
              $display ("%t: OPCODE  : RRC   H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h0d : 
            begin
              $display ("%t: OPCODE  : RRC   L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h0e : 
            begin
              $display ("%t: OPCODE  : RRC   (HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h1f : 
            begin
              $display ("%t: OPCODE  : RL    A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h18 : 
            begin
              $display ("%t: OPCODE  : RL    B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h19 : 
            begin
              $display ("%t: OPCODE  : RL    C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h1a : 
            begin
              $display ("%t: OPCODE  : RL    D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h1b : 
            begin
              $display ("%t: OPCODE  : RL    E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h1c : 
            begin
              $display ("%t: OPCODE  : RL    H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h1d : 
            begin
              $display ("%t: OPCODE  : RL    L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h1e : 
            begin
              $display ("%t: OPCODE  : RL    (HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h47 : 
            begin
              $display ("%t: OPCODE  : BIT   0,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h40 : 
            begin
              $display ("%t: OPCODE  : BIT   0,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h41 : 
            begin
              $display ("%t: OPCODE  : BIT   0,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h42 : 
            begin
              $display ("%t: OPCODE  : BIT   0,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h43 : 
            begin
              $display ("%t: OPCODE  : BIT   0,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h44 : 
            begin
              $display ("%t: OPCODE  : BIT   0,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h45 : 
            begin
              $display ("%t: OPCODE  : BIT   0,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h46 : 
            begin
              $display ("%t: OPCODE  : BIT   0,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h4f : 
            begin
              $display ("%t: OPCODE  : BIT   1,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h48 : 
            begin
              $display ("%t: OPCODE  : BIT   1,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h49 : 
            begin
              $display ("%t: OPCODE  : BIT   1,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h4a : 
            begin
              $display ("%t: OPCODE  : BIT   1,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h4b : 
            begin
              $display ("%t: OPCODE  : BIT   1,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h4c : 
            begin
              $display ("%t: OPCODE  : BIT   1,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h4d : 
            begin
              $display ("%t: OPCODE  : BIT   1,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h4e : 
            begin
              $display ("%t: OPCODE  : BIT   1,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h57 : 
            begin
              $display ("%t: OPCODE  : BIT   2,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h50 : 
            begin
              $display ("%t: OPCODE  : BIT   2,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h51 : 
            begin
              $display ("%t: OPCODE  : BIT   2,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h52 : 
            begin
              $display ("%t: OPCODE  : BIT   2,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h53 : 
            begin
              $display ("%t: OPCODE  : BIT   2,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h54 : 
            begin
              $display ("%t: OPCODE  : BIT   2,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h55 : 
            begin
              $display ("%t: OPCODE  : BIT   2,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h56 : 
            begin
              $display ("%t: OPCODE  : BIT   2,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h5f : 
            begin
              $display ("%t: OPCODE  : BIT   3,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h58 : 
            begin
              $display ("%t: OPCODE  : BIT   3,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h59 : 
            begin
              $display ("%t: OPCODE  : BIT   3,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h5a : 
            begin
              $display ("%t: OPCODE  : BIT   3,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h5b : 
            begin
              $display ("%t: OPCODE  : BIT   3,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h5c : 
            begin
              $display ("%t: OPCODE  : BIT   3,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h5d : 
            begin
              $display ("%t: OPCODE  : BIT   3,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h5e : 
            begin
              $display ("%t: OPCODE  : BIT   3,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h67 : 
            begin
              $display ("%t: OPCODE  : BIT   4,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h60 : 
            begin
              $display ("%t: OPCODE  : BIT   4,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h61 : 
            begin
              $display ("%t: OPCODE  : BIT   4,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h62 : 
            begin
              $display ("%t: OPCODE  : BIT   4,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h63 : 
            begin
              $display ("%t: OPCODE  : BIT   4,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h64 : 
            begin
              $display ("%t: OPCODE  : BIT   4,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h65 : 
            begin
              $display ("%t: OPCODE  : BIT   4,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h66 : 
            begin
              $display ("%t: OPCODE  : BIT   4,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h6f : 
            begin
              $display ("%t: OPCODE  : BIT   5,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h68 : 
            begin
              $display ("%t: OPCODE  : BIT   5,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h69 : 
            begin
              $display ("%t: OPCODE  : BIT   5,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h6a : 
            begin
              $display ("%t: OPCODE  : BIT   5,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h6b : 
            begin
              $display ("%t: OPCODE  : BIT   5,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h6c : 
            begin
              $display ("%t: OPCODE  : BIT   5,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h6d : 
            begin
              $display ("%t: OPCODE  : BIT   5,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h6e : 
            begin
              $display ("%t: OPCODE  : BIT   5,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h77 : 
            begin
              $display ("%t: OPCODE  : BIT   6,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h70 : 
            begin
              $display ("%t: OPCODE  : BIT   6,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h71 : 
            begin
              $display ("%t: OPCODE  : BIT   6,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h72 : 
            begin
              $display ("%t: OPCODE  : BIT   6,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h73 : 
            begin
              $display ("%t: OPCODE  : BIT   6,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h74 : 
            begin
              $display ("%t: OPCODE  : BIT   6,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h75 : 
            begin
              $display ("%t: OPCODE  : BIT   6,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h76 : 
            begin
              $display ("%t: OPCODE  : BIT   6,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h7f : 
            begin
              $display ("%t: OPCODE  : BIT   7,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h78 : 
            begin
              $display ("%t: OPCODE  : BIT   7,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h79 : 
            begin
              $display ("%t: OPCODE  : BIT   7,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h7a : 
            begin
              $display ("%t: OPCODE  : BIT   7,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h7b : 
            begin
              $display ("%t: OPCODE  : BIT   7,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h7c : 
            begin
              $display ("%t: OPCODE  : BIT   7,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h7d : 
            begin
              $display ("%t: OPCODE  : BIT   7,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h7e : 
            begin
              $display ("%t: OPCODE  : BIT   7,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h87 : 
            begin
              $display ("%t: OPCODE  : RES   0,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h80 : 
            begin
              $display ("%t: OPCODE  : RES   0,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h81 : 
            begin
              $display ("%t: OPCODE  : RES   0,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h82 : 
            begin
              $display ("%t: OPCODE  : RES   0,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h83 : 
            begin
              $display ("%t: OPCODE  : RES   0,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h84 : 
            begin
              $display ("%t: OPCODE  : RES   0,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h85 : 
            begin
              $display ("%t: OPCODE  : RES   0,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h86 : 
            begin
              $display ("%t: OPCODE  : RES   0,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h8f : 
            begin
              $display ("%t: OPCODE  : RES   1,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h88 : 
            begin
              $display ("%t: OPCODE  : RES   1,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h89 : 
            begin
              $display ("%t: OPCODE  : RES   1,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h8a : 
            begin
              $display ("%t: OPCODE  : RES   1,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h8b : 
            begin
              $display ("%t: OPCODE  : RES   1,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h8c : 
            begin
              $display ("%t: OPCODE  : RES   1,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h8d : 
            begin
              $display ("%t: OPCODE  : RES   1,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h8e : 
            begin
              $display ("%t: OPCODE  : RES   1,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h97 : 
            begin
              $display ("%t: OPCODE  : RES   2,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h90 : 
            begin
              $display ("%t: OPCODE  : RES   2,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h91 : 
            begin
              $display ("%t: OPCODE  : RES   2,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h92 : 
            begin
              $display ("%t: OPCODE  : RES   2,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h93 : 
            begin
              $display ("%t: OPCODE  : RES   2,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h94 : 
            begin
              $display ("%t: OPCODE  : RES   2,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h95 : 
            begin
              $display ("%t: OPCODE  : RES   2,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h96 : 
            begin
              $display ("%t: OPCODE  : RES   2,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h9f : 
            begin
              $display ("%t: OPCODE  : RES   3,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h98 : 
            begin
              $display ("%t: OPCODE  : RES   3,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h99 : 
            begin
              $display ("%t: OPCODE  : RES   3,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h9a : 
            begin
              $display ("%t: OPCODE  : RES   3,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h9b : 
            begin
              $display ("%t: OPCODE  : RES   3,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h9c : 
            begin
              $display ("%t: OPCODE  : RES   3,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h9d : 
            begin
              $display ("%t: OPCODE  : RES   3,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h9e : 
            begin
              $display ("%t: OPCODE  : RES   3,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha7 : 
            begin
              $display ("%t: OPCODE  : RES   4,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha0 : 
            begin
              $display ("%t: OPCODE  : RES   4,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha1 : 
            begin
              $display ("%t: OPCODE  : RES   4,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha2 : 
            begin
              $display ("%t: OPCODE  : RES   4,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha3 : 
            begin
              $display ("%t: OPCODE  : RES   4,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha4 : 
            begin
              $display ("%t: OPCODE  : RES   4,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha5 : 
            begin
              $display ("%t: OPCODE  : RES   4,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha6 : 
            begin
              $display ("%t: OPCODE  : RES   4,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'haf : 
            begin
              $display ("%t: OPCODE  : RES   5,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha8 : 
            begin
              $display ("%t: OPCODE  : RES   5,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha9 : 
            begin
              $display ("%t: OPCODE  : RES   5,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'haa : 
            begin
              $display ("%t: OPCODE  : RES   5,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hab : 
            begin
              $display ("%t: OPCODE  : RES   5,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hac : 
            begin
              $display ("%t: OPCODE  : RES   5,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'had : 
            begin
              $display ("%t: OPCODE  : RES   5,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hae : 
            begin
              $display ("%t: OPCODE  : RES   5,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb7 : 
            begin
              $display ("%t: OPCODE  : RES   6,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb0 : 
            begin
              $display ("%t: OPCODE  : RES   6,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb1 : 
            begin
              $display ("%t: OPCODE  : RES   6,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb2 : 
            begin
              $display ("%t: OPCODE  : RES   6,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb3 : 
            begin
              $display ("%t: OPCODE  : RES   6,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb4 : 
            begin
              $display ("%t: OPCODE  : RES   6,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb5 : 
            begin
              $display ("%t: OPCODE  : RES   6,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb6 : 
            begin
              $display ("%t: OPCODE  : RES   6,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hbf : 
            begin
              $display ("%t: OPCODE  : RES   7,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb8 : 
            begin
              $display ("%t: OPCODE  : RES   7,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb9 : 
            begin
              $display ("%t: OPCODE  : RES   7,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hba : 
            begin
              $display ("%t: OPCODE  : RES   7,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hbb : 
            begin
              $display ("%t: OPCODE  : RES   7,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hbc : 
            begin
              $display ("%t: OPCODE  : RES   7,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hbd : 
            begin
              $display ("%t: OPCODE  : RES   7,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hbe : 
            begin
              $display ("%t: OPCODE  : RES   7,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc7 : 
            begin
              $display ("%t: OPCODE  : SET   0,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc0 : 
            begin
              $display ("%t: OPCODE  : SET   0,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc1 : 
            begin
              $display ("%t: OPCODE  : SET   0,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc2 : 
            begin
              $display ("%t: OPCODE  : SET   0,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc3 : 
            begin
              $display ("%t: OPCODE  : SET   0,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc4 : 
            begin
              $display ("%t: OPCODE  : SET   0,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc5 : 
            begin
              $display ("%t: OPCODE  : SET   0,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc6 : 
            begin
              $display ("%t: OPCODE  : SET   0,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hcf : 
            begin
              $display ("%t: OPCODE  : SET   1,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc8 : 
            begin
              $display ("%t: OPCODE  : SET   1,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hc9 : 
            begin
              $display ("%t: OPCODE  : SET   1,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hca : 
            begin
              $display ("%t: OPCODE  : SET   1,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   1,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hcc : 
            begin
              $display ("%t: OPCODE  : SET   1,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hcd : 
            begin
              $display ("%t: OPCODE  : SET   1,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hce : 
            begin
              $display ("%t: OPCODE  : SET   1,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd7 : 
            begin
              $display ("%t: OPCODE  : SET   2,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd0 : 
            begin
              $display ("%t: OPCODE  : SET   2,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd1 : 
            begin
              $display ("%t: OPCODE  : SET   2,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd2 : 
            begin
              $display ("%t: OPCODE  : SET   2,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd3 : 
            begin
              $display ("%t: OPCODE  : SET   2,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd4 : 
            begin
              $display ("%t: OPCODE  : SET   2,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd5 : 
            begin
              $display ("%t: OPCODE  : SET   2,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd6 : 
            begin
              $display ("%t: OPCODE  : SET   2,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hdf : 
            begin
              $display ("%t: OPCODE  : SET   3,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd8 : 
            begin
              $display ("%t: OPCODE  : SET   3,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hd9 : 
            begin
              $display ("%t: OPCODE  : SET   3,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hda : 
            begin
              $display ("%t: OPCODE  : SET   3,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hdb : 
            begin
              $display ("%t: OPCODE  : SET   3,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hdc : 
            begin
              $display ("%t: OPCODE  : SET   3,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hdd : 
            begin
              $display ("%t: OPCODE  : SET   3,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hde : 
            begin
              $display ("%t: OPCODE  : SET   3,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he7 : 
            begin
              $display ("%t: OPCODE  : SET   4,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he0 : 
            begin
              $display ("%t: OPCODE  : SET   4,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he1 : 
            begin
              $display ("%t: OPCODE  : SET   4,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he2 : 
            begin
              $display ("%t: OPCODE  : SET   4,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he3 : 
            begin
              $display ("%t: OPCODE  : SET   4,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he4 : 
            begin
              $display ("%t: OPCODE  : SET   4,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he5 : 
            begin
              $display ("%t: OPCODE  : SET   4,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he6 : 
            begin
              $display ("%t: OPCODE  : SET   4,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hef : 
            begin
              $display ("%t: OPCODE  : SET   5,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he8 : 
            begin
              $display ("%t: OPCODE  : SET   5,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he9 : 
            begin
              $display ("%t: OPCODE  : SET   5,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hea : 
            begin
              $display ("%t: OPCODE  : SET   5,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'heb : 
            begin
              $display ("%t: OPCODE  : SET   5,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hec : 
            begin
              $display ("%t: OPCODE  : SET   5,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hed : 
            begin
              $display ("%t: OPCODE  : SET   5,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hee : 
            begin
              $display ("%t: OPCODE  : SET   5,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf7 : 
            begin
              $display ("%t: OPCODE  : SET   6,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf0 : 
            begin
              $display ("%t: OPCODE  : SET   6,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf1 : 
            begin
              $display ("%t: OPCODE  : SET   6,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf2 : 
            begin
              $display ("%t: OPCODE  : SET   6,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf3 : 
            begin
              $display ("%t: OPCODE  : SET   6,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf4 : 
            begin
              $display ("%t: OPCODE  : SET   6,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf5 : 
            begin
              $display ("%t: OPCODE  : SET   6,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf6 : 
            begin
              $display ("%t: OPCODE  : SET   6,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hff : 
            begin
              $display ("%t: OPCODE  : SET   7,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf8 : 
            begin
              $display ("%t: OPCODE  : SET   7,B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hf9 : 
            begin
              $display ("%t: OPCODE  : SET   7,C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hfa : 
            begin
              $display ("%t: OPCODE  : SET   7,D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hfb : 
            begin
              $display ("%t: OPCODE  : SET   7,E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hfc : 
            begin
              $display ("%t: OPCODE  : SET   7,H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hfd : 
            begin
              $display ("%t: OPCODE  : SET   7,L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hfe : 
            begin
              $display ("%t: OPCODE  : SET   7,(HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h27 : 
            begin
              $display ("%t: OPCODE  : SLA   A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h20 : 
            begin
              $display ("%t: OPCODE  : SLA   B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h21 : 
            begin
              $display ("%t: OPCODE  : SLA   C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h22 : 
            begin
              $display ("%t: OPCODE  : SLA   D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h23 : 
            begin
              $display ("%t: OPCODE  : SLA   E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h24 : 
            begin
              $display ("%t: OPCODE  : SLA   H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h25 : 
            begin
              $display ("%t: OPCODE  : SLA   L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h26 : 
            begin
              $display ("%t: OPCODE  : SLA   (HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h2f : 
            begin
              $display ("%t: OPCODE  : SRA   A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h28 : 
            begin
              $display ("%t: OPCODE  : SRA   B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h29 : 
            begin
              $display ("%t: OPCODE  : SRA   C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h2a : 
            begin
              $display ("%t: OPCODE  : SRA   D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h2b : 
            begin
              $display ("%t: OPCODE  : SRA   E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h2c : 
            begin
              $display ("%t: OPCODE  : SRA   H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h2d : 
            begin
              $display ("%t: OPCODE  : SRA   L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h2e : 
            begin
              $display ("%t: OPCODE  : SRA   (HL)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h3f : 
            begin
              $display ("%t: OPCODE  : SRL   A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h38 : 
            begin
              $display ("%t: OPCODE  : SRL   B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h39 : 
            begin
              $display ("%t: OPCODE  : SRL   C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h3a : 
            begin
              $display ("%t: OPCODE  : SRL   D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h3b : 
            begin
              $display ("%t: OPCODE  : SRL   E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h3c : 
            begin
              $display ("%t: OPCODE  : SRL   H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h3d : 
            begin
              $display ("%t: OPCODE  : SRL   L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h3e : 
            begin
              $display ("%t: OPCODE  : SRL   (HL)", $time);
              state = { 4'd0, 4'd0 };
            end
        endcase
      end
    8'hdd : 
      begin
        case (opcode)
          8'h7e : 
            begin
              $display ("%t: OPCODE  : LD    A,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h46 : 
            begin
              $display ("%t: OPCODE  : LD    B,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h4e : 
            begin
              $display ("%t: OPCODE  : LD    C,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h56 : 
            begin
              $display ("%t: OPCODE  : LD    D,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h5e : 
            begin
              $display ("%t: OPCODE  : LD    E,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h66 : 
            begin
              $display ("%t: OPCODE  : LD    H,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h6e : 
            begin
              $display ("%t: OPCODE  : LD    L,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h77 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),A", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h70 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),B", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h71 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),C", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h72 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),D", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h73 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),E", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h74 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),H", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h75 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),L", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h76 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),byte", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h36 : 
            begin
              $display ("%t: OPCODE  : LD    (IX+index),byte", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h21 : 
            begin
              $display ("%t: OPCODE  : LD    IX,word", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h2a : 
            begin
              $display ("%t: OPCODE  : LD    IX,(word)", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h22 : 
            begin
              $display ("%t: OPCODE  : LD    (word),IX", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h22 : 
            begin
              $display ("%t: OPCODE  : LD    (word),IY", $time);
              state = { 4'd1, 4'd2 };
            end
          8'hf9 : 
            begin
              $display ("%t: OPCODE  : LD    SP,IX", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he3 : 
            begin
              $display ("%t: OPCODE  : EX    (SP),IX", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h86 : 
            begin
              $display ("%t: OPCODE  : ADD   A,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h8e : 
            begin
              $display ("%t: OPCODE  : ADC   A,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h96 : 
            begin
              $display ("%t: OPCODE  : SUB   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h9e : 
            begin
              $display ("%t: OPCODE  : SBC   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h09 : 
            begin
              $display ("%t: OPCODE  : ADD   IX,BC", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h19 : 
            begin
              $display ("%t: OPCODE  : ADD   IX,DE", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h29 : 
            begin
              $display ("%t: OPCODE  : ADD   IX,IX", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h39 : 
            begin
              $display ("%t: OPCODE  : ADD   IX,SP", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h34 : 
            begin
              $display ("%t: OPCODE  : INC   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h35 : 
            begin
              $display ("%t: OPCODE  : DEC   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h23 : 
            begin
              $display ("%t: OPCODE  : INC   IX", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h2b : 
            begin
              $display ("%t: OPCODE  : DEC   IX", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RLC   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RL    (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RRC   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RL    (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'ha6 : 
            begin
              $display ("%t: OPCODE  : AND   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hae : 
            begin
              $display ("%t: OPCODE  : XOR   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hb6 : 
            begin
              $display ("%t: OPCODE  : OR    (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hbe : 
            begin
              $display ("%t: OPCODE  : CP    (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'he9 : 
            begin
              $display ("%t: OPCODE  : JP    (IX)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he5 : 
            begin
              $display ("%t: OPCODE  : PUSH  IX", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he1 : 
            begin
              $display ("%t: OPCODE  : POP   IX", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   0,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   1,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   2,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   3,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   4,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   5,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   6,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   7,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   0,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   1,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   2,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   3,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   4,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   5,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   6,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   7,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   0,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   1,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   2,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   3,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   4,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   5,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   6,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   7,(IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SLA   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SRA   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SRL   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
        endcase
      end
    8'hed : 
      begin
        case (opcode)
          8'h57 : 
            begin
              $display ("%t: OPCODE  : LD    A,I", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h4b : 
            begin
              $display ("%t: OPCODE  : LD    BC,(word)", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h5b : 
            begin
              $display ("%t: OPCODE  : LD    DE,(word)", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h6b : 
            begin
              $display ("%t: OPCODE  : LD    HL,(word)", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h7b : 
            begin
              $display ("%t: OPCODE  : LD    SP,(word)", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h43 : 
            begin
              $display ("%t: OPCODE  : LD    (word),BC", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h53 : 
            begin
              $display ("%t: OPCODE  : LD    (word),DE", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h6b : 
            begin
              $display ("%t: OPCODE  : LD    (word),HL", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h73 : 
            begin
              $display ("%t: OPCODE  : LD    (word),SP", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h4a : 
            begin
              $display ("%t: OPCODE  : ADC   HL,BC", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h5a : 
            begin
              $display ("%t: OPCODE  : ADC   HL,DE", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h6a : 
            begin
              $display ("%t: OPCODE  : ADC   HL,HL", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h7a : 
            begin
              $display ("%t: OPCODE  : ADC   HL,SP", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h42 : 
            begin
              $display ("%t: OPCODE  : SBC   HL,BC", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h52 : 
            begin
              $display ("%t: OPCODE  : SBC   HL,DE", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h62 : 
            begin
              $display ("%t: OPCODE  : SBC   HL,HL", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h72 : 
            begin
              $display ("%t: OPCODE  : SBC   HL,SP", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h46 : 
            begin
              $display ("%t: OPCODE  : IM    0", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h56 : 
            begin
              $display ("%t: OPCODE  : IM    1", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h5e : 
            begin
              $display ("%t: OPCODE  : IM    2", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h47 : 
            begin
              $display ("%t: OPCODE  : LD    I,A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h44 : 
            begin
              $display ("%t: OPCODE  : NEG   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h6f : 
            begin
              $display ("%t: OPCODE  : RLD   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h67 : 
            begin
              $display ("%t: OPCODE  : RRD   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha1 : 
            begin
              $display ("%t: OPCODE  : CPI   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb1 : 
            begin
              $display ("%t: OPCODE  : CPIR  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha9 : 
            begin
              $display ("%t: OPCODE  : CPD   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb9 : 
            begin
              $display ("%t: OPCODE  : CPDR  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h4d : 
            begin
              $display ("%t: OPCODE  : RETI  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h45 : 
            begin
              $display ("%t: OPCODE  : RETN  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h78 : 
            begin
              $display ("%t: OPCODE  : IN    A,(C)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h40 : 
            begin
              $display ("%t: OPCODE  : IN    B,(C)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h48 : 
            begin
              $display ("%t: OPCODE  : IN    C,(C)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h50 : 
            begin
              $display ("%t: OPCODE  : IN    D,(C)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h58 : 
            begin
              $display ("%t: OPCODE  : IN    E,(C)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h60 : 
            begin
              $display ("%t: OPCODE  : IN    H,(C)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h68 : 
            begin
              $display ("%t: OPCODE  : IN    L,(C)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha2 : 
            begin
              $display ("%t: OPCODE  : INI   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb2 : 
            begin
              $display ("%t: OPCODE  : INIR  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'haa : 
            begin
              $display ("%t: OPCODE  : IND   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hba : 
            begin
              $display ("%t: OPCODE  : INDR  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h79 : 
            begin
              $display ("%t: OPCODE  : OUT   (C),A", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h41 : 
            begin
              $display ("%t: OPCODE  : OUT   (C),B", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h49 : 
            begin
              $display ("%t: OPCODE  : OUT   (C),C", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h51 : 
            begin
              $display ("%t: OPCODE  : OUT   (C),D", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h59 : 
            begin
              $display ("%t: OPCODE  : OUT   (C),E", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h61 : 
            begin
              $display ("%t: OPCODE  : OUT   (C),H", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h69 : 
            begin
              $display ("%t: OPCODE  : OUT   (C),L", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha3 : 
            begin
              $display ("%t: OPCODE  : OUTI  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb3 : 
            begin
              $display ("%t: OPCODE  : OTIR  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hab : 
            begin
              $display ("%t: OPCODE  : OUTD  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hbb : 
            begin
              $display ("%t: OPCODE  : OTDR  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha0 : 
            begin
              $display ("%t: OPCODE  : LDI   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb0 : 
            begin
              $display ("%t: OPCODE  : LDIR  ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'ha8 : 
            begin
              $display ("%t: OPCODE  : LDD   ", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hb8 : 
            begin
              $display ("%t: OPCODE  : LDDR  ", $time);
              state = { 4'd0, 4'd0 };
            end
        endcase
      end
    8'hfd : 
      begin
        case (opcode)
          8'h7e : 
            begin
              $display ("%t: OPCODE  : LD    A,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h46 : 
            begin
              $display ("%t: OPCODE  : LD    B,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h4e : 
            begin
              $display ("%t: OPCODE  : LD    C,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h56 : 
            begin
              $display ("%t: OPCODE  : LD    D,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h5e : 
            begin
              $display ("%t: OPCODE  : LD    E,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h66 : 
            begin
              $display ("%t: OPCODE  : LD    H,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h6e : 
            begin
              $display ("%t: OPCODE  : LD    L,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h77 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),A", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h70 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),B", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h71 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),C", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h72 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),D", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h73 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),E", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h74 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),H", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h75 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),L", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h76 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),byte", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h36 : 
            begin
              $display ("%t: OPCODE  : LD    (IY+index),byte", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h21 : 
            begin
              $display ("%t: OPCODE  : LD    IY,word", $time);
              state = { 4'd1, 4'd2 };
            end
          8'h2a : 
            begin
              $display ("%t: OPCODE  : LD    IY,(word)", $time);
              state = { 4'd1, 4'd2 };
            end
          8'hf9 : 
            begin
              $display ("%t: OPCODE  : LD    SP,IY", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he3 : 
            begin
              $display ("%t: OPCODE  : EX    (SP),IY", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h86 : 
            begin
              $display ("%t: OPCODE  : ADD   A,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h8e : 
            begin
              $display ("%t: OPCODE  : ADC   A,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h96 : 
            begin
              $display ("%t: OPCODE  : SUB   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h9e : 
            begin
              $display ("%t: OPCODE  : SBC   (IX+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h09 : 
            begin
              $display ("%t: OPCODE  : ADD   IY,BC", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h19 : 
            begin
              $display ("%t: OPCODE  : ADD   IY,DE", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h29 : 
            begin
              $display ("%t: OPCODE  : ADD   IY,IY", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h39 : 
            begin
              $display ("%t: OPCODE  : ADD   IY,SP", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h34 : 
            begin
              $display ("%t: OPCODE  : INC   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h35 : 
            begin
              $display ("%t: OPCODE  : DEC   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'h23 : 
            begin
              $display ("%t: OPCODE  : INC   IY", $time);
              state = { 4'd0, 4'd0 };
            end
          8'h2b : 
            begin
              $display ("%t: OPCODE  : DEC   IY", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RLC   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RL    (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RRC   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RL    (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'ha6 : 
            begin
              $display ("%t: OPCODE  : AND   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hae : 
            begin
              $display ("%t: OPCODE  : XOR   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hb6 : 
            begin
              $display ("%t: OPCODE  : OR    (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hbe : 
            begin
              $display ("%t: OPCODE  : CP    (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'he9 : 
            begin
              $display ("%t: OPCODE  : JP    (IY)", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he5 : 
            begin
              $display ("%t: OPCODE  : PUSH  IY", $time);
              state = { 4'd0, 4'd0 };
            end
          8'he1 : 
            begin
              $display ("%t: OPCODE  : POP   IY", $time);
              state = { 4'd0, 4'd0 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   0,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   1,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   2,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   3,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   4,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   5,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   6,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : BIT   7,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   0,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   1,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   2,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   3,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   4,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   5,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   6,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : RES   7,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   0,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   1,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   2,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   3,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   4,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   5,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   6,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SET   7,(IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SLA   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SRA   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
          8'hcb : 
            begin
              $display ("%t: OPCODE  : SRL   (IY+index)", $time);
              state = { 4'd1, 4'd1 };
            end
        endcase
      end // case: 8'hfd

    default :
      begin
        $display ("%t: OPCODE  : Unknown opcode %x", $time, opcode);
      end
  endcase
  end
endtask

  task decode;
    input [7:0] byte;
    inout [7:0] state;
    begin
      if (state == 0)
        decode0 (byte, state);
      else if (state[7:4] == 1)
        begin
          state[3:0] = state[3:0] - 1;
          if (state[3:0] == 0)
            state[7:0] = 0;
        end
      else
        begin
          decode1 (byte, state);
        end
    end
  endtask // decode
  
endmodule // op_decode
