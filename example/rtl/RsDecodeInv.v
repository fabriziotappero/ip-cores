//===================================================================
// Module Name : RsDecodeInv
// File Name   : RsDecodeInv.v
// Function    : Rs Decoder Inverse calculation Module
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module RsDecodeInv(
   B,   // data in
   R    // data out
 );


   input  [7:0]   B; // data in
   output [7:0]   R; // data out


   reg [7:0]   R;


   always @(B) begin
      case (B)
         8'd0: begin
            R = 8'd0;
         end
         8'd1: begin
            R = 8'd1;
         end
         8'd2: begin
            R = 8'd142;
         end
         8'd3: begin
            R = 8'd244;
         end
         8'd4: begin
            R = 8'd71;
         end
         8'd5: begin
            R = 8'd167;
         end
         8'd6: begin
            R = 8'd122;
         end
         8'd7: begin
            R = 8'd186;
         end
         8'd8: begin
            R = 8'd173;
         end
         8'd9: begin
            R = 8'd157;
         end
         8'd10: begin
            R = 8'd221;
         end
         8'd11: begin
            R = 8'd152;
         end
         8'd12: begin
            R = 8'd61;
         end
         8'd13: begin
            R = 8'd170;
         end
         8'd14: begin
            R = 8'd93;
         end
         8'd15: begin
            R = 8'd150;
         end
         8'd16: begin
            R = 8'd216;
         end
         8'd17: begin
            R = 8'd114;
         end
         8'd18: begin
            R = 8'd192;
         end
         8'd19: begin
            R = 8'd88;
         end
         8'd20: begin
            R = 8'd224;
         end
         8'd21: begin
            R = 8'd62;
         end
         8'd22: begin
            R = 8'd76;
         end
         8'd23: begin
            R = 8'd102;
         end
         8'd24: begin
            R = 8'd144;
         end
         8'd25: begin
            R = 8'd222;
         end
         8'd26: begin
            R = 8'd85;
         end
         8'd27: begin
            R = 8'd128;
         end
         8'd28: begin
            R = 8'd160;
         end
         8'd29: begin
            R = 8'd131;
         end
         8'd30: begin
            R = 8'd75;
         end
         8'd31: begin
            R = 8'd42;
         end
         8'd32: begin
            R = 8'd108;
         end
         8'd33: begin
            R = 8'd237;
         end
         8'd34: begin
            R = 8'd57;
         end
         8'd35: begin
            R = 8'd81;
         end
         8'd36: begin
            R = 8'd96;
         end
         8'd37: begin
            R = 8'd86;
         end
         8'd38: begin
            R = 8'd44;
         end
         8'd39: begin
            R = 8'd138;
         end
         8'd40: begin
            R = 8'd112;
         end
         8'd41: begin
            R = 8'd208;
         end
         8'd42: begin
            R = 8'd31;
         end
         8'd43: begin
            R = 8'd74;
         end
         8'd44: begin
            R = 8'd38;
         end
         8'd45: begin
            R = 8'd139;
         end
         8'd46: begin
            R = 8'd51;
         end
         8'd47: begin
            R = 8'd110;
         end
         8'd48: begin
            R = 8'd72;
         end
         8'd49: begin
            R = 8'd137;
         end
         8'd50: begin
            R = 8'd111;
         end
         8'd51: begin
            R = 8'd46;
         end
         8'd52: begin
            R = 8'd164;
         end
         8'd53: begin
            R = 8'd195;
         end
         8'd54: begin
            R = 8'd64;
         end
         8'd55: begin
            R = 8'd94;
         end
         8'd56: begin
            R = 8'd80;
         end
         8'd57: begin
            R = 8'd34;
         end
         8'd58: begin
            R = 8'd207;
         end
         8'd59: begin
            R = 8'd169;
         end
         8'd60: begin
            R = 8'd171;
         end
         8'd61: begin
            R = 8'd12;
         end
         8'd62: begin
            R = 8'd21;
         end
         8'd63: begin
            R = 8'd225;
         end
         8'd64: begin
            R = 8'd54;
         end
         8'd65: begin
            R = 8'd95;
         end
         8'd66: begin
            R = 8'd248;
         end
         8'd67: begin
            R = 8'd213;
         end
         8'd68: begin
            R = 8'd146;
         end
         8'd69: begin
            R = 8'd78;
         end
         8'd70: begin
            R = 8'd166;
         end
         8'd71: begin
            R = 8'd4;
         end
         8'd72: begin
            R = 8'd48;
         end
         8'd73: begin
            R = 8'd136;
         end
         8'd74: begin
            R = 8'd43;
         end
         8'd75: begin
            R = 8'd30;
         end
         8'd76: begin
            R = 8'd22;
         end
         8'd77: begin
            R = 8'd103;
         end
         8'd78: begin
            R = 8'd69;
         end
         8'd79: begin
            R = 8'd147;
         end
         8'd80: begin
            R = 8'd56;
         end
         8'd81: begin
            R = 8'd35;
         end
         8'd82: begin
            R = 8'd104;
         end
         8'd83: begin
            R = 8'd140;
         end
         8'd84: begin
            R = 8'd129;
         end
         8'd85: begin
            R = 8'd26;
         end
         8'd86: begin
            R = 8'd37;
         end
         8'd87: begin
            R = 8'd97;
         end
         8'd88: begin
            R = 8'd19;
         end
         8'd89: begin
            R = 8'd193;
         end
         8'd90: begin
            R = 8'd203;
         end
         8'd91: begin
            R = 8'd99;
         end
         8'd92: begin
            R = 8'd151;
         end
         8'd93: begin
            R = 8'd14;
         end
         8'd94: begin
            R = 8'd55;
         end
         8'd95: begin
            R = 8'd65;
         end
         8'd96: begin
            R = 8'd36;
         end
         8'd97: begin
            R = 8'd87;
         end
         8'd98: begin
            R = 8'd202;
         end
         8'd99: begin
            R = 8'd91;
         end
         8'd100: begin
            R = 8'd185;
         end
         8'd101: begin
            R = 8'd196;
         end
         8'd102: begin
            R = 8'd23;
         end
         8'd103: begin
            R = 8'd77;
         end
         8'd104: begin
            R = 8'd82;
         end
         8'd105: begin
            R = 8'd141;
         end
         8'd106: begin
            R = 8'd239;
         end
         8'd107: begin
            R = 8'd179;
         end
         8'd108: begin
            R = 8'd32;
         end
         8'd109: begin
            R = 8'd236;
         end
         8'd110: begin
            R = 8'd47;
         end
         8'd111: begin
            R = 8'd50;
         end
         8'd112: begin
            R = 8'd40;
         end
         8'd113: begin
            R = 8'd209;
         end
         8'd114: begin
            R = 8'd17;
         end
         8'd115: begin
            R = 8'd217;
         end
         8'd116: begin
            R = 8'd233;
         end
         8'd117: begin
            R = 8'd251;
         end
         8'd118: begin
            R = 8'd218;
         end
         8'd119: begin
            R = 8'd121;
         end
         8'd120: begin
            R = 8'd219;
         end
         8'd121: begin
            R = 8'd119;
         end
         8'd122: begin
            R = 8'd6;
         end
         8'd123: begin
            R = 8'd187;
         end
         8'd124: begin
            R = 8'd132;
         end
         8'd125: begin
            R = 8'd205;
         end
         8'd126: begin
            R = 8'd254;
         end
         8'd127: begin
            R = 8'd252;
         end
         8'd128: begin
            R = 8'd27;
         end
         8'd129: begin
            R = 8'd84;
         end
         8'd130: begin
            R = 8'd161;
         end
         8'd131: begin
            R = 8'd29;
         end
         8'd132: begin
            R = 8'd124;
         end
         8'd133: begin
            R = 8'd204;
         end
         8'd134: begin
            R = 8'd228;
         end
         8'd135: begin
            R = 8'd176;
         end
         8'd136: begin
            R = 8'd73;
         end
         8'd137: begin
            R = 8'd49;
         end
         8'd138: begin
            R = 8'd39;
         end
         8'd139: begin
            R = 8'd45;
         end
         8'd140: begin
            R = 8'd83;
         end
         8'd141: begin
            R = 8'd105;
         end
         8'd142: begin
            R = 8'd2;
         end
         8'd143: begin
            R = 8'd245;
         end
         8'd144: begin
            R = 8'd24;
         end
         8'd145: begin
            R = 8'd223;
         end
         8'd146: begin
            R = 8'd68;
         end
         8'd147: begin
            R = 8'd79;
         end
         8'd148: begin
            R = 8'd155;
         end
         8'd149: begin
            R = 8'd188;
         end
         8'd150: begin
            R = 8'd15;
         end
         8'd151: begin
            R = 8'd92;
         end
         8'd152: begin
            R = 8'd11;
         end
         8'd153: begin
            R = 8'd220;
         end
         8'd154: begin
            R = 8'd189;
         end
         8'd155: begin
            R = 8'd148;
         end
         8'd156: begin
            R = 8'd172;
         end
         8'd157: begin
            R = 8'd9;
         end
         8'd158: begin
            R = 8'd199;
         end
         8'd159: begin
            R = 8'd162;
         end
         8'd160: begin
            R = 8'd28;
         end
         8'd161: begin
            R = 8'd130;
         end
         8'd162: begin
            R = 8'd159;
         end
         8'd163: begin
            R = 8'd198;
         end
         8'd164: begin
            R = 8'd52;
         end
         8'd165: begin
            R = 8'd194;
         end
         8'd166: begin
            R = 8'd70;
         end
         8'd167: begin
            R = 8'd5;
         end
         8'd168: begin
            R = 8'd206;
         end
         8'd169: begin
            R = 8'd59;
         end
         8'd170: begin
            R = 8'd13;
         end
         8'd171: begin
            R = 8'd60;
         end
         8'd172: begin
            R = 8'd156;
         end
         8'd173: begin
            R = 8'd8;
         end
         8'd174: begin
            R = 8'd190;
         end
         8'd175: begin
            R = 8'd183;
         end
         8'd176: begin
            R = 8'd135;
         end
         8'd177: begin
            R = 8'd229;
         end
         8'd178: begin
            R = 8'd238;
         end
         8'd179: begin
            R = 8'd107;
         end
         8'd180: begin
            R = 8'd235;
         end
         8'd181: begin
            R = 8'd242;
         end
         8'd182: begin
            R = 8'd191;
         end
         8'd183: begin
            R = 8'd175;
         end
         8'd184: begin
            R = 8'd197;
         end
         8'd185: begin
            R = 8'd100;
         end
         8'd186: begin
            R = 8'd7;
         end
         8'd187: begin
            R = 8'd123;
         end
         8'd188: begin
            R = 8'd149;
         end
         8'd189: begin
            R = 8'd154;
         end
         8'd190: begin
            R = 8'd174;
         end
         8'd191: begin
            R = 8'd182;
         end
         8'd192: begin
            R = 8'd18;
         end
         8'd193: begin
            R = 8'd89;
         end
         8'd194: begin
            R = 8'd165;
         end
         8'd195: begin
            R = 8'd53;
         end
         8'd196: begin
            R = 8'd101;
         end
         8'd197: begin
            R = 8'd184;
         end
         8'd198: begin
            R = 8'd163;
         end
         8'd199: begin
            R = 8'd158;
         end
         8'd200: begin
            R = 8'd210;
         end
         8'd201: begin
            R = 8'd247;
         end
         8'd202: begin
            R = 8'd98;
         end
         8'd203: begin
            R = 8'd90;
         end
         8'd204: begin
            R = 8'd133;
         end
         8'd205: begin
            R = 8'd125;
         end
         8'd206: begin
            R = 8'd168;
         end
         8'd207: begin
            R = 8'd58;
         end
         8'd208: begin
            R = 8'd41;
         end
         8'd209: begin
            R = 8'd113;
         end
         8'd210: begin
            R = 8'd200;
         end
         8'd211: begin
            R = 8'd246;
         end
         8'd212: begin
            R = 8'd249;
         end
         8'd213: begin
            R = 8'd67;
         end
         8'd214: begin
            R = 8'd215;
         end
         8'd215: begin
            R = 8'd214;
         end
         8'd216: begin
            R = 8'd16;
         end
         8'd217: begin
            R = 8'd115;
         end
         8'd218: begin
            R = 8'd118;
         end
         8'd219: begin
            R = 8'd120;
         end
         8'd220: begin
            R = 8'd153;
         end
         8'd221: begin
            R = 8'd10;
         end
         8'd222: begin
            R = 8'd25;
         end
         8'd223: begin
            R = 8'd145;
         end
         8'd224: begin
            R = 8'd20;
         end
         8'd225: begin
            R = 8'd63;
         end
         8'd226: begin
            R = 8'd230;
         end
         8'd227: begin
            R = 8'd240;
         end
         8'd228: begin
            R = 8'd134;
         end
         8'd229: begin
            R = 8'd177;
         end
         8'd230: begin
            R = 8'd226;
         end
         8'd231: begin
            R = 8'd241;
         end
         8'd232: begin
            R = 8'd250;
         end
         8'd233: begin
            R = 8'd116;
         end
         8'd234: begin
            R = 8'd243;
         end
         8'd235: begin
            R = 8'd180;
         end
         8'd236: begin
            R = 8'd109;
         end
         8'd237: begin
            R = 8'd33;
         end
         8'd238: begin
            R = 8'd178;
         end
         8'd239: begin
            R = 8'd106;
         end
         8'd240: begin
            R = 8'd227;
         end
         8'd241: begin
            R = 8'd231;
         end
         8'd242: begin
            R = 8'd181;
         end
         8'd243: begin
            R = 8'd234;
         end
         8'd244: begin
            R = 8'd3;
         end
         8'd245: begin
            R = 8'd143;
         end
         8'd246: begin
            R = 8'd211;
         end
         8'd247: begin
            R = 8'd201;
         end
         8'd248: begin
            R = 8'd66;
         end
         8'd249: begin
            R = 8'd212;
         end
         8'd250: begin
            R = 8'd232;
         end
         8'd251: begin
            R = 8'd117;
         end
         8'd252: begin
            R = 8'd127;
         end
         8'd253: begin
            R = 8'd255;
         end
         8'd254: begin
            R = 8'd126;
         end
         default: begin
            R = 8'd253;
         end
      endcase
   end
endmodule
