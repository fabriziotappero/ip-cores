//****************************************************//
// This controller provides timing synchronization    //
// among all four modules (SC, KES, CSEE and FIFO     //
// Registers). It consists of 2 FSMs that operate on  //
// different clock phases.                            //
// With these FSMs, it is possible for SC block to    //
// get new received word data, while CSEE is still    //
// correcting old data. It is no need to wait the     //
// CSEE block to correct old data completely.         //
// So, it can minimize throughput bottleneck          //
// to only in KES block.                              //
//****************************************************//

module MainControl(start, reset, clock1, clock2, finish_kes,
                  errdetect, rootcntr, lambda_degree, active_sc, 
                  active_kes, active_csee, evalsynd, holdsynd, 
                  errfound, decode_fail, ready, dataoutstart, 
                  dataoutend, shift_fifo, hold_fifo, en_infifo, 
                  en_outfifo, lastdataout, evalerror);

input start, reset;
input clock1, clock2;
input errdetect, finish_kes;
input [2:0] rootcntr, lambda_degree;
output active_sc, active_kes, active_csee, ready;
output evalsynd, holdsynd, errfound, decode_fail;
output dataoutstart, dataoutend;
output shift_fifo, hold_fifo, en_infifo, en_outfifo;
output lastdataout, evalerror;

reg active_sc, active_kes, active_csee;
reg ready, decode_fail, evalsynd, holdsynd, errfound;
reg shift_fifo, hold_fifo, en_infifo, en_outfifo;
reg encntdataout, encntdatain;
reg [4:0] cntdatain, cntdataout;
reg dataoutstart, dataoutend;
reg datainfinish;
wire lastdataout;

parameter [3:0] st1_0=0, st1_1=1, st1_2=2, st1_3=3, st1_4=4, st1_5=5, 
                st1_6=6, st1_7=7, st1_8=8, st1_9=9, st1_10=10, 
                st1_11=11, st1_12=12, st1_13=13, st1_14=14;
reg [3:0] state1, nxt_state1;

parameter [3:0] st2_0=0, st2_1=1, st2_2=2, st2_3=3, st2_4=4, st2_5=5,
                st2_6=6, st2_7=7, st2_8=8, st2_9=9, st2_10=10,
                st2_11=11;
reg [3:0] state2, nxt_state2;

//***************************************************//
//                    FSM 1                          //
//***************************************************//
always@(posedge clock1 or negedge reset)
begin
    if(~reset)
      state1 = st1_0;
    else
      state1 = nxt_state1;    
end

always@(state1 or start or rootcntr or lambda_degree or errdetect 
         or datainfinish or finish_kes or dataoutend)
begin
   case(state1)
        st1_0 : begin
                if(start)
                  nxt_state1 = st1_1;
                else
                  nxt_state1 = st1_0;
                end
        st1_1 : nxt_state1 = st1_2;
        st1_2 : begin
                if(datainfinish)
                   nxt_state1 = st1_3;
                else
                   nxt_state1 = st1_2;
                end   
        st1_3 : begin
                if(errdetect)
                   nxt_state1 = st1_4;
                else
                   nxt_state1 = st1_12;
                end
        st1_4 : nxt_state1 = st1_5;
        st1_5 : begin
                if(finish_kes)
                  nxt_state1 = st1_6;
                else
                   nxt_state1 = st1_5;
                end
        st1_6 : nxt_state1 = st1_7;
        st1_7 : begin
                if((~start)&&(~dataoutend))
                   nxt_state1 = st1_7;
                else if(dataoutend)
                   begin
                       if(lambda_degree == rootcntr)
                          nxt_state1 = st1_0;
                       else
                          nxt_state1 = st1_10;
                   end
                else
                   nxt_state1 = st1_8;
                end
        st1_8 : begin
                if(dataoutend)
                   begin
                      if(lambda_degree == rootcntr)
                         nxt_state1 = st1_2;
                      else
                         nxt_state1 = st1_11;
                   end
                else
                   nxt_state1 = st1_9;
                end
        st1_9 : begin
                if(dataoutend)
                   begin
                      if(lambda_degree == rootcntr)
                         nxt_state1 = st1_2;
                      else
                         nxt_state1 = st1_11;
                   end
                else
                   nxt_state1 = st1_9;
                end 
        st1_10: begin
                if(start)
                   nxt_state1 = st1_1;
                else
                   nxt_state1 = st1_0;
                end
        st1_11: begin
                if(datainfinish)
                   nxt_state1 = st1_3;
                else
                   nxt_state1 = st1_2;
                end
        st1_12: begin
                if((~start)&&(~dataoutend))
                   nxt_state1 = st1_12;
                else if(dataoutend)
                   nxt_state1 = st1_0;
                else
                   nxt_state1 = st1_13;
                end
        st1_13: begin
                if(dataoutend)
                   nxt_state1 = st1_2;
                else
                   nxt_state1 = st1_14;
                end
        st1_14: begin
                if(dataoutend)
                   nxt_state1 = st1_2;
                else
                   nxt_state1 = st1_14;
                end
       default: nxt_state1 = st1_0;
   endcase
end

// Output logic of FSM1 //
always@(state1)
begin
    case(state1)
        st1_0 :begin
               ready = 1;
               active_sc = 0;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 0;
               end
        st1_1 :begin
               ready = 1;
               active_sc = 1;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 0;
               end         
        st1_2 :begin
               ready = 1;
               active_sc = 0;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 0;
               end
        st1_3 :begin
               ready = 0;
               active_sc = 0;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 1;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 0;
               end
        st1_4 :begin
               ready = 0;
               active_sc = 0;
               active_kes = 1;
               active_csee = 0;
               evalsynd = 0;
               errfound = 1;
               decode_fail = 0;
               en_outfifo = 0;
               end
        st1_5 :begin
               ready = 0;
               active_sc = 0;
               active_kes = 1;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 0;
               end
        st1_6 :begin
               ready = 0;
               active_sc = 0;
               active_kes = 1;
               active_csee = 1;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 0;
               end
        st1_7 :begin
               ready = 1;
               active_sc = 0;
               active_kes = 1;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 1;
               end        
        st1_8 :begin
               ready = 1;
               active_sc = 1;
               active_kes = 1;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 1;
               end           
        st1_9 :begin
               ready = 1;
               active_sc = 0;
               active_kes = 1;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 1;
               end           
        st1_10:begin
               ready = 1;
               active_sc = 0;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 1;
               en_outfifo = 0;
               end
        st1_11:begin
               ready = 1;
               active_sc = 0;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 1;
               en_outfifo = 0;
               end
        st1_12:begin
               ready = 1;
               active_sc = 0;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 1;
               end
        st1_13:begin
               ready = 1;
               active_sc = 1;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 1;
               end
        st1_14:begin
               ready = 1;
               active_sc = 0;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 1;
               end
       default:begin
               ready = 1;
               active_sc = 0;
               active_kes = 0;
               active_csee = 0;
               evalsynd = 0;
               errfound = 0;
               decode_fail = 0;
               en_outfifo = 0;
               end
    endcase
end
       
//****************************************// 
//                 FSM 2                  //
//****************************************//
always@(posedge clock2 or negedge reset)
begin
   if(~reset)
      state2 = st2_0;
   else
      state2 = nxt_state2;
end
      
always@(state2 or active_sc or cntdatain or lastdataout or en_outfifo)
begin
   case(state2)
      st2_0 : begin
              if(active_sc)
                 nxt_state2 = st2_1;
              else
                 nxt_state2 = st2_0;
              end
      st2_1 : begin
              if(cntdatain == 5'b11110)
                 nxt_state2 = st2_2;
              else
                 nxt_state2 = st2_1;
              end
      st2_2 : nxt_state2 = st2_3;
      st2_3 : begin
              if(en_outfifo)
                 nxt_state2 = st2_4;
              else
                 nxt_state2 = st2_3;
              end
      st2_4 : begin
              if(active_sc)
                 nxt_state2 = st2_8;
              else
                 nxt_state2 = st2_5;
              end
      st2_5 : begin
              if(active_sc)
                 nxt_state2 = st2_9;
              else
                 nxt_state2 = st2_6;
              end
      st2_6 : begin
              if(active_sc)
                 nxt_state2 = st2_9;
              else if((lastdataout) && (~active_sc))
                 nxt_state2 = st2_7;
              else
                 nxt_state2 = st2_6;
              end
      st2_7 : begin
              if(active_sc)
                 nxt_state2 = st2_1;
              else
                 nxt_state2 = st2_0;
              end
      st2_8 : nxt_state2 = st2_9;
      st2_9 : begin
              if((lastdataout) && (cntdatain==5'b11110))
                 nxt_state2 = st2_10;
              else if(lastdataout)
                 nxt_state2 = st2_11;
              else
                 nxt_state2 = st2_9;
              end
      st2_10: nxt_state2 = st2_3;
      st2_11: begin
              if(cntdatain==5'b11110)
                 nxt_state2 = st2_2;
              else
                 nxt_state2 = st2_1;
              end
      default: nxt_state2 = st2_0;
   endcase
end

// Output logic of FSM 2 //
always@(state2)
begin
    case(state2)
        st2_0 : begin
                dataoutstart = 0;
                dataoutend = 0;
                shift_fifo = 0;
                hold_fifo = 0;
                en_infifo = 0;
                encntdatain = 0;
                encntdataout = 0;
                holdsynd = 0;
                datainfinish = 0;
                end
        st2_1 : begin
                dataoutstart = 0;
                dataoutend = 0;
                shift_fifo = 1;
                hold_fifo = 0;
                en_infifo = 1;
                encntdatain = 1;
                encntdataout = 0;
                holdsynd = 0;
                datainfinish = 0;
                end
        st2_2 : begin
                dataoutstart = 0;
                dataoutend = 0;
                shift_fifo = 1;
                hold_fifo = 0;
                en_infifo = 1;
                encntdatain = 0;
                encntdataout = 0;
                holdsynd = 0;
                datainfinish = 1;
                end
        st2_3 : begin
                dataoutstart = 0;
                dataoutend = 0;
                shift_fifo = 0;
                hold_fifo = 1;
                en_infifo = 0;
                encntdatain = 0;
                encntdataout = 0;
                holdsynd = 1;
                datainfinish = 0;
                end
        st2_4 : begin
                dataoutstart = 0;
                dataoutend = 0;
                shift_fifo = 0;
                hold_fifo = 1;
                en_infifo = 0;
                encntdatain = 0;
                encntdataout = 1;
                holdsynd = 0;
                datainfinish = 0;
                end
        st2_5 : begin
                dataoutstart = 1;
                dataoutend = 0;
                shift_fifo = 1;
                hold_fifo = 0;
                en_infifo = 0;
                encntdatain = 0;
                encntdataout = 1;
                holdsynd = 0;
                datainfinish = 0;
                end
        st2_6 : begin
                dataoutstart = 0;
                dataoutend = 0;
                shift_fifo = 1;
                hold_fifo = 0;
                en_infifo = 0;
                encntdatain = 0;
                encntdataout = 1;
                holdsynd = 0;
                datainfinish = 0;
                end
        st2_7 : begin
                dataoutstart = 0;
                dataoutend = 1;
                shift_fifo = 0;
                hold_fifo = 0;
                en_infifo = 0;
                encntdatain = 0;
                encntdataout = 0;
                holdsynd = 0;
                datainfinish = 0;
                end
        st2_8 : begin
                dataoutstart = 1;
                dataoutend = 0;
                shift_fifo = 1;
                hold_fifo = 0;
                en_infifo = 1;
                encntdatain = 1;
                encntdataout = 1;
                holdsynd = 0;
                datainfinish = 0;
                end
        st2_9 : begin
                dataoutstart = 0;
                dataoutend = 0;
                shift_fifo = 1;
                hold_fifo = 0;
                en_infifo = 1;
                encntdatain = 1;
                encntdataout = 1;
                holdsynd = 0;
                datainfinish = 0;
                end
        st2_10: begin
                dataoutstart = 0;
                dataoutend = 1;
                shift_fifo = 1;
                hold_fifo = 0;
                en_infifo = 1;
                encntdatain = 0;
                encntdataout = 0;
                holdsynd = 0;
                datainfinish = 1;
                end
        st2_11: begin
                dataoutstart = 0;
                dataoutend = 1;
                shift_fifo = 1;
                hold_fifo = 0;
                en_infifo = 1;
                encntdatain = 1;
                encntdataout = 0;
                holdsynd = 0;
                datainfinish = 0;
                end
       default: begin
                dataoutstart = 0;
                dataoutend = 0;
                shift_fifo = 0;
                hold_fifo = 0;
                en_infifo = 0;
                encntdatain = 0;
                encntdataout = 0;
                holdsynd = 0;
                datainfinish = 0;
                end
   endcase
  end
        

//*********************//
// Counter for dataout //               
always@(posedge clock1)
begin
   if(encntdataout)
      cntdataout =  cntdataout + 1;
   else
      cntdataout = 5'b0;
end

// Counter for datain //               
always@(posedge clock1)
begin
   if(encntdatain)
      cntdatain =  cntdatain + 1;
   else
      cntdatain = 5'b0;
end

// lastdataout is 1 if cntdataout = 5'b11111 //
assign lastdataout = cntdataout[4] & (cntdataout[3]&cntdataout[2]) &
                     (cntdataout[1]&cntdataout[0]);

assign evalerror = encntdataout;

endmodule         