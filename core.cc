#include <systemc>
#include <iostream>
#include "core.h"
#include "define.h"

using namespace std;

void core :: transfer_data()
{
	sc_uint<FIFO_DEEP>      buff;
	sc_uint<FIFO_DEEP>      f_ct[3];
	sc_uint<3>              channel = 0;
	sc_uint<3>              sel = 0;
	sc_uint<8>				data_address = 0;
	bool                    stop_flag = 0;
	bool                    temp = 0;
	bool                    ready = 0;

	while(true){
		if(!reset_n.read()){
			stop_flag = 0;
			f_ct[0] = f_ct[1] = f_ct[2] = 0;
			data_address = 0;
		}
		else{
			if(clk.read()){
				write_n->write(true);
				if(((full->read()&0x01) != 0x01) && ((write_state & FIFO1) == FIFO1)){
					sel = 1;
					channel = 0;
					stop_flag = 0;
					f_ct[channel]++;
					data_address = write_address[0];
				}
				else if(((full->read()&0x02) != 0x02)&&((write_state & FIFO2) == FIFO2)){
					sel = 2;
					channel = 1;
					stop_flag = 0;
					f_ct[channel]++;
					data_address = write_address[1];
				}
				else if(((full->read()&0x04) != 0x04)&&((write_state & FIFO3) == FIFO3)){
					sel = 3;
					channel = 2;
					stop_flag = 0;
					f_ct[channel]++;
					data_address = write_address[2];
				}
				else{
					sel = 0;
					stop_flag = 1;
				}
				core_to_fifo_sel->write(sel);
				ready = 1;
			}
			else if((ready == 1) && (stop_flag == 0)){
				if(((f_ct[channel] - 1) < FIFO_DEEP)){
					buff = wmemory[data_address];
					temp = (bool)((buff >> (f_ct[channel] - 1)) & 0x0001);
					data_out->write(temp);
					wait(1,SC_NS);
					write_n->write(false);
					ready = 0;
					EI_POWER;
				}
				if((f_ct[channel]) == FIFO_DEEP){
#ifdef CORE_TRANSMIT_DEBUG
					short debug_temp = 0;
					for(int dc = 0; dc <= FIFO_DEEP; dc++){
						debug_temp = wmemory[data_address];
						debug_temp = debug_temp >> dc;
						debug_temp &= 0x0001;
						if(dc  == 0){
							cout << "Core [" << core_id << "] channel[" << channel 
								<< "] " << " transmit data: \t\t";
							cout << debug_temp;
						}
						else if(dc < FIFO_DEEP){
							cout << debug_temp;
						}
					}
					cout << endl;
#endif
					EI_POWER;
					wmemory[data_address] = 0;
					f_ct[channel] = 0;
					if(channel == 0){
						write_state &= ~FIFO1;
					}
					else if(channel == 1){
						write_state &= ~FIFO2;
					}
					else if(channel == 2){
						write_state &= ~FIFO3;
					}
				}
			}
		}
		wait();
	}
}

void core :: receive_data()
{

	sc_uint<FIFO_DEEP>  rec_buff = 0;
	sc_uint<FIFO_DEEP>  f_ct[3];         //fifo deep counter.
	sc_uint<2>			sel = 0;
	sc_uint<2>			channel = 0;
	sc_uint<8>				data_address = 0;
	bool temp = 0;
	bool ready = 0;

	f_ct[0] = f_ct[1] = f_ct[2] = 0;

	while(true){
		wait();
		if(!reset_n.read())
		{
			f_ct[0] = f_ct[1] = f_ct[2] = 0;
		}
		else{
			if(clk.read()){
				read_n->write(true);
				if(((empty->read()&0x01) != 0x01) && ((read_state & FIFO1) == FIFO1)){
					channel = 0;
					sel = 1;
					f_ct[channel]++;
					ready = 1;
					data_address = read_address[0];
				}
				else if(((empty->read()&0x02) != 0x02) && ((read_state & FIFO2) == FIFO2)){
					channel = 1;
					sel = 2;
					f_ct[channel]++;
					ready = 1;
					data_address = read_address[1];
				}
				else if(((empty->read()&0x04) != 0x04) && ((read_state & FIFO3) == FIFO3)){
					channel = 2;
					sel = 3;
					f_ct[channel]++;
					ready = 1;
					data_address = read_address[1];
				}
				else{
					ready = 0;
					sel = 0;
				}
				fifo_to_core_sel->write(sel);
			}
			else if(ready == 1){ 
				if((f_ct[channel]-1) < FIFO_DEEP){
					read_n->write(false);
					wait(2,SC_NS);
					temp = data_in->read();
					rmemory[data_address] |= (temp << (f_ct[channel]-1));
					ready = 0;
					EI_POWER;
				}
				if((f_ct[channel]) == (FIFO_DEEP)){
					f_ct[channel] = 0;
					if(channel == 0)
						read_state &= ~FIFO1;
					else if(channel == 1)
						read_state &= ~FIFO2;
					else if(channel == 2)
						read_state &= ~FIFO3;
#ifdef CORE_RECEIVE_DEBUG
					short debug_temp = 0;
					for(int dc = 0; dc <= FIFO_DEEP; dc++){
						debug_temp = rmemory[data_address];
						debug_temp = debug_temp >> dc;
						debug_temp &= 0x0001;
						if(dc  == 0){
							cout << "Core [" << core_id << "] channel[" << channel 
								<< "] " << " receive data: \t\t";
							cout << debug_temp;
						}
						else if(dc < FIFO_DEEP){
							cout << debug_temp;
						}
					}
					rmemory[data_address] = 0;
					cout << endl;
#endif
				}
			}
		}
	}
}

char core :: write_data(sc_uint<3> sel, sc_uint<8> addr)
{
	sc_uint<3> fifo = 0;

	if(!(write_state & sel)){
		if(sel == FIFO1)
			fifo = 0;
		else if(sel == FIFO2)
			fifo = 1;
		else if(sel == FIFO3)
			fifo = 2;
		else
			cout << "error" << endl;

		write_address[fifo] = addr;
		write_state |= sel;
		return SUCCEED;
	}
	else
		return FAIL;
}

char core :: read_data(sc_uint<3> sel, sc_uint<8> addr)
{
	sc_uint<3> fifo = 0;

	if(!(read_state & sel)){
		if(sel == FIFO1)
			fifo = 0;
		else if(sel == FIFO2)
			fifo = 1;
		else if(sel == FIFO3)
			fifo = 2;
		read_address[fifo] = addr;
		read_state |= sel;
		return SUCCEED;
	}
	else
		return FAIL;
}

void core :: core_handle()
{
	char state1 = FAIL, state2 = FAIL, state3 = FAIL, state4 = FAIL;
	char state5 = FAIL, state6 = FAIL;
	char rstate1 = 0, rstate2 = 0, rstate3 = 0;
	unsigned int delay = 0;
	HEAD_FLIT *head;
	BODY_FLIT *body;

	head = (HEAD_FLIT *)(wmemory+10); //0000 0010 1000 0000.

	head->type = 0;
	head->conn_type = 0;
	head->dst_addr = 4;
	head->pkt_size = 0;

	body = (BODY_FLIT *)(wmemory+11);//0100 1111 1111 0000
	body->type = 1;
	body->data = 0x0ff0;
	

	body = (BODY_FLIT *)(wmemory+12);//0100 1000 1000 0000
	body->type = 1;
	body->data = 0x0880;

	//Optical interconnects 
	head = (HEAD_FLIT *)(wmemory+13); //0010 0100 0000 0000
	head->type = 0;
	head->conn_type = 1;
	head->dst_addr = 15;
	head->pkt_size = 0;
	
	body = (BODY_FLIT *)(wmemory+14); //0100 0001 0001 0000
	body->type = 1;
	body->data = 0x0110;
	
	body = (BODY_FLIT *)(wmemory+15); //0100 1111 1111 1111
	body->type = 1;
	body->data = 0x0fff;

	while(true){
		if(!reset_n.read()){
			
		}
		else{
			if(core_id == 0){
				
				if(state1 == FAIL)
					state1 = write_data(FIFO1,10);
			 	if(state2 == FAIL)
					state2 = write_data(FIFO1,11);
				if(state3 == FAIL)
					state3 = write_data(FIFO1,12);
				
				if(state4 == FAIL)
					state4 = write_data(FIFO2,13);

				if(state4 == SUCCEED){
					if(delay > 200){
						if(state5 == FAIL)
							state5 = write_data(FIFO2,14);
						if(state6 == FAIL){
							state6 = write_data(FIFO2,15);
							if(state6 == SUCCEED)
								delay = 0;
						}
					}
					else{
						delay++;
					}
				}
			}
			rstate1 = read_data(FIFO1,0);
			rstate2 = read_data(FIFO2,1);
			rstate3 = read_data(FIFO3,2);
		}
		wait();
	}
}
