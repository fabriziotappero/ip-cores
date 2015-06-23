#include "tv_responder.h"

uint64_t get_time_stamp () {
	sc_time t;
	
	t = sc_time_stamp();
	return t.value();
}

void tv_responder::event ()
{
	// init
	//reset_n = 0;
	/*
	wait_n = 1;
	int_n = 1;
	nmi_n = 1;
	busrq_n = 1;
	di_resp = 0;
	*/
	uint8_t oldval;
	
	if (reset_time > 0) {
		reset_n = 0;
	    wait_n = 1;
		int_n = 1;
		nmi_n = 1;
		busrq_n = 1;
		di_resp = 0;
		reset_time--;
		if (reset_time == 0)
			printf ("Initialization complete.\n");
		return;
	} else {
		if (reset_time == 0) {
			reset_n = 1;
			reset_time--;
		}
	}
		
	
    if (!iorq_n & !rd_n)
        {
          switch (addr) {
            case (0x82) : di_resp = timeout_ctl; break;
	  		case(0x83) : di_resp = max_timeout & 0xff; break;
	   		case(0x84) : di_resp = max_timeout >> 8; break;

	    	case(0x90) : di_resp = int_countdown; break;
            case(CKSUM_VALUE) : 
            	di_resp = checksum; 
				//printf ("%2.6f: Read checksum value of %02x\n", sc_time_stamp().to_seconds(), checksum);
            	break;
            case(0x93) : di_resp = ior_value; break;
            case(0x94) : di_resp = rand();  break;
            case(0x95) : di_resp = nmi_countdown; break;
            case(0xA0) : di_resp = nmi_trigger; break;
            default : di_resp = 0;
          }
        } // if (!iorq_n & !rd_n)

//  wire wr_stb;
//  reg last_iowrite;

//  assign wr_stb = (!iorq_n & !wr_n);
  
//  always @(posedge clk)
//   begin
      //last_iowrite <= #1 wr_stb;
    //if (!iorq_n && !wr_n)
    //	printf ("DEBUG:  I/O Write detected addr=%02x\n", 0xff & (int) addr.read());
    	
    if (!iorq_n && !wr_n && !last_iowrite) {
    	int l_dout, l_addr;
    	
    	l_addr = addr.read();
    	l_dout = dout.read();
    	
      	last_iowrite = true;
		switch ( l_addr & 0xff) {
			case(SIM_CTL_PORT) :
			// dump control deprecated
			if (l_dout == 1) {
				printf ("%2.6f: --- TEST PASSED ---\n", sc_time_stamp().to_seconds());
				sc_stop();
			} else if (l_dout == 2) {
				printf ("%2.6f: !!! TEST FAILED !!!\n", sc_time_stamp().to_seconds());
				sc_stop();
			}
			break;

			case(MSG_PORT) :
	    
	      		if (l_dout == 0x0A) {
					printf ("%2.6f: PROGRAM : ", sc_time_stamp().to_seconds());

					for (int i=0; i<buf_ptr; i=i+1)
						printf ("%c", str_buf[i]);
				  
					printf ("\n");
		 			buf_ptr = 0;
				} else {
	      			str_buf[buf_ptr] = (char) (l_dout & 0xff);
	      			buf_ptr = buf_ptr + 1;
	      		}
		    break;

			case(TIMEOUT_PORT) :
		    	timeout_ctl = l_dout;
				break;

			case(MAX_TIMEOUT_LOW) :
				max_timeout = l_dout | (max_timeout & 0xFF00);
				break;
				
			case(MAX_TIMEOUT_HIGH) :
				max_timeout = (l_dout << 8) | (max_timeout & 0x00FF);
				printf ("%2.6f: ENVIRON : Timeout reset to %d (dout=%d)\n", sc_time_stamp().to_seconds(), max_timeout, l_dout);
				break;

			case(0x90) : int_countdown = dout; break;
			case(CKSUM_VALUE) : checksum = dout; break;
			case(CKSUM_ACCUM) : 
				oldval = checksum;
				checksum = checksum + dout; 
				//printf ("%2.6f: ENVIRON : cksum %02x=%02x + %02x\n", sc_time_stamp().to_seconds(), checksum, oldval, l_dout);
				break;
			case(0x93) : ior_value = dout; break;
			case(0x95) : nmi_countdown = dout; break;
			case(0xA0) : nmi_trigger = dout; break;
		}
    } else if (iorq_n)
    	last_iowrite = false;

	if (timeout_ctl & 0x2) {
		cur_timeout = 0;
		timeout_ctl = timeout_ctl & 1;
	} else if (timeout_ctl & 0x1)
		cur_timeout = cur_timeout + 1;

    if (cur_timeout >= max_timeout) {
	  printf ("%2.6f: ERROR   : Reached timeout %d cycles\n", sc_time_stamp().to_seconds(), max_timeout);
	  //tb_top.test_fail;
	  sc_stop();
    }

	if (int_countdown == 0) {
		int_n = 1;
	} else if (int_countdown == 1)
		int_n  = 0;
    else if (int_countdown > 1) {
	  int_countdown = int_countdown - 1;
	  int_n  = 1;
    }

    // when nmi countdown reaches 1, an NMI will be issued.
    // to clear the interrupt, write nmi_countdown to 0.
    if ((nmi_countdown == 0) && (nmi_trigger == 0))
		nmi_n = 1;
    else if (nmi_countdown == 1)
		nmi_n = 0;
    else if (nmi_countdown > 1) {
		nmi_countdown = nmi_countdown - 1;
		nmi_n = 1;
    }

    // when IR equals the target instruction, an NMI will be
    // issued.  To clear the interrupt, write nmi_trigger to
    // zero.
    /*  can't do this in systemc
    if (nmi_trigger != 0) {
          if (nmi_trigger === tb_top.tv80s_inst.i_tv80_core.IR[7:0])
            begin
              tb_top.nmi_n <= #80 0;
              tb_top.nmi_n <= #160 1;
            end
    } else if (nmi_countdown == 0)
        nmi_n = 1;
     */
}
