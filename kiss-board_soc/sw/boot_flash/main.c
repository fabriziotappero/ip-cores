
#include "support.h"
#include "spr_defs.h"
#include "syscall.h"
#include "debug.h"

#include "net.h"

int main(void); // is called from reset.S

/////////////////////////////////////////////
// local
/////////////////////////////////////////////
static void main_loop(void);
//#include "image_koizumi.c"
#include "image_rose.c"
enum COM_COMMAND {
	COM_COMMAND_NOP = 0,
	COM_COMMAND_WRITE,
	COM_COMMAND_READ,
	COM_COMMAND_BOOT
};
//static unsigned long int main_misc_byte2int(unsigned char *d){
//	unsigned long int ret;
//	ret = 0;
//	ret += d[0]<<24; ret += d[1]<<16; ret += d[2]<< 8; ret += d[3]<< 0;
//	return ret;	
//}
#define UC2ULI( d ) ((d)[0]<<24)+((d)[1]<<16)+((d)[2]<<8)+((d)[3]<<0)
/////////////////////////////////////////////
// main_job_a COMMAND
/////////////////////////////////////////////
struct main_job_a {
	void			(*current_function)(struct main_job_a *job_a);
	unsigned long int	time;
	unsigned char		buf_text[12];
	unsigned long int	buf_count;
	unsigned long int	command;
	unsigned long int	parameter1;
	unsigned long int	parameter2;
} typedef MAIN_JOB_A;
static void	main_job_a_init(MAIN_JOB_A *job_a);
static void	main_job_a_vm(MAIN_JOB_A *job_a);
static void	main_job_a_0(MAIN_JOB_A *job_a);
static void	main_job_a_1(MAIN_JOB_A *job_a);
static void	main_job_a_2(MAIN_JOB_A *job_a);
static void	main_job_a_3(MAIN_JOB_A *job_a);

static void main_job_a_init(MAIN_JOB_A *job_a){
	job_a->current_function	= main_job_a_0;
	job_a->time		= 0;
	job_a->buf_count	= 0;
	return;
}
static void main_job_a_vm(MAIN_JOB_A *job_a){
	job_a->current_function(job_a); // 0 or 1 or 2 or 3
	job_a->time++;
	return;
}
static void main_job_a_0(MAIN_JOB_A *job_a){
	// screen message
	//main_screen(SCREEN_PUT_STRING,"Ready\n");
	// UART message
	//main_uart(UART_PUT_STRING,"Ready");
	//main_uart(UART_PUT,0x00);
	// next job
	//job_a->current_function = main_job_a_1;
	//while (1) {
	//	syscall(SYS_UART_DTR,1);		// dtr active
	//	syscall(SYS_UART_DTR,0);		// dtr active
	//}
//	while (1) {
//		REG32(0x02000000) = 0x01234567;
//		REG32(0x02000000);
//	}
	if (syscall(SYS_UART_IS_DSR)) {
		//DEBUG_PRINT("DSR\n");
		syscall(SYS_UART_PUT_CLEAR);		// clear tx buffer
		syscall(SYS_UART_GET_CLEAR);		// clear rx buffer
		syscall(SYS_UART_DTR,1);		// dtr active
		job_a->current_function = main_job_a_1;	// goto Parse command
		job_a->buf_count	= 0;
	}
	return;
}
static void main_job_a_1(MAIN_JOB_A *job_a){								// Parse command {command[4],parameter[4],parameter[4]}. length is 12byte
	if (!syscall(SYS_UART_IS_DSR)) {
		//DEBUG_PRINT("!DSR\n");
		syscall(SYS_UART_DTR,0);		// dtr inactive
		job_a->current_function = main_job_a_0;
		return;
	}
	if (syscall(SYS_UART_GET_EXIST)) {
		job_a->buf_text[ job_a->buf_count ] = syscall(SYS_UART_GET);				// get 1byte
		//syscall(SYS_UART_PUT,0x00);								// ack 1byte,when is host received,so send next data.
		syscall(SYS_UART_PUT,job_a->buf_text[ job_a->buf_count ]);								// ack 1byte,when is host received,so send next data.
		job_a->buf_count++;
	}
	if (12==job_a->buf_count) {
		job_a->command		= UC2ULI( &(job_a->buf_text[0]) );
		job_a->parameter1	= UC2ULI( &(job_a->buf_text[4]) );
		job_a->parameter2	= UC2ULI( &(job_a->buf_text[8]) );
		//DEBUG_PRINT("c =");
		//DEBUG_INTGER( job_a->command );
		//DEBUG_PRINT("\n");
		//DEBUG_PRINT("p1=");
		//DEBUG_INTGER( job_a->parameter1 );
		//DEBUG_PRINT("\n");
		//DEBUG_PRINT("p2=");
		//DEBUG_INTGER( job_a->parameter2 );
		//DEBUG_PRINT("\n");
		switch ( job_a->command ) {
			case COM_COMMAND_NOP: {
				job_a->current_function = main_job_a_0;		// goto start
				//DEBUG_PRINT("Boot\n");
				break;
			}
			case COM_COMMAND_WRITE: {
				job_a->current_function = main_job_a_2;		// goto write
				//DEBUG_PRINT("Write\n");
				break;
			}
			case COM_COMMAND_READ: {
				job_a->current_function = main_job_a_3;		// goto read
				//DEBUG_PRINT("Read\n");
				break;
			}
			case COM_COMMAND_BOOT: {
				unsigned long int (*boot_function)(void *);
				boot_function = *(void **)job_a->parameter1;
				boot_function(syscall);				// call to *(address)
				job_a->current_function = main_job_a_0;		// goto start
				//DEBUG_PRINT("Boot\n");
				break;
			}
			default: {
				job_a->current_function = main_job_a_0;
				//DEBUG_PRINT("Unknow\n");
				break;
			}
		 }
	}
	return;
}
static void main_job_a_2(MAIN_JOB_A *job_a){								// Write to Memory
	if (!syscall(SYS_UART_IS_DSR)) {
		//DEBUG_PRINT("!DSR\n");
		syscall(SYS_UART_DTR,0);		// dtr inactive
		job_a->current_function = main_job_a_0;
		return;
	}
	if (syscall(SYS_UART_GET_EXIST)) {
		*(unsigned char *)job_a->parameter1 = (unsigned char)syscall(SYS_UART_GET);
		(unsigned char *)job_a->parameter1 = (unsigned char *)job_a->parameter1 + 1; 
		job_a->parameter2--;
		syscall(SYS_UART_PUT,0x00);								// ack 1byte
		//DEBUG_PRINT("W");
	}
	if (0==job_a->parameter2) {									// DONE,so next job
		job_a->current_function = main_job_a_0;							// goto parse command
		//DEBUG_PRINT("\n");
	}
	return;
}
static void main_job_a_3(MAIN_JOB_A *job_a){								// Read from Memory
	if (!syscall(SYS_UART_IS_DSR)) {
		//DEBUG_PRINT("!DSR\n");
		syscall(SYS_UART_DTR,0);		// dtr inactive
		job_a->current_function = main_job_a_0;
		return;
	}
	if (syscall(SYS_UART_GET_EXIST)) {								// read(=requet)
		syscall(SYS_UART_GET);									// dummy(=empty)
		syscall(SYS_UART_PUT,*(unsigned char *)job_a->parameter1);
		(unsigned char *)(job_a->parameter1) = (unsigned char *)(job_a->parameter1) + 1; 
		job_a->parameter2--;
		//DEBUG_PRINT("R");
	}												// Done,so next job
	if (0==job_a->parameter2) {									// parse command
		job_a->current_function = main_job_a_0;	
		//DEBUG_PRINT("\n");
	}
	return;
}


/////////////////////////////////////////////
// main_job_b INDICATOR
/////////////////////////////////////////////
struct main_job_b {
	void (*current_function)(struct main_job_b *job_b);
	unsigned long int time;
	unsigned long int state;
	unsigned long int draw;
} typedef MAIN_JOB_B;
static void	main_job_b_init(MAIN_JOB_B *job_b);
static void	main_job_b_vm(MAIN_JOB_B *job_b);
static void	main_job_b_0(MAIN_JOB_B *job_b);

static void	main_job_b_score2(unsigned long int x,unsigned long int y,unsigned char *string,unsigned long time);
static void	main_job_b_score1(unsigned long int x,unsigned long int y,unsigned char *string);

static void main_job_b_init(MAIN_JOB_B *job_b){
	job_b->current_function	= main_job_b_0;
	job_b->time		= 0;
	job_b->state		= 0;
	job_b->draw		= 0;
	return;
}
static void main_job_b_vm(MAIN_JOB_B *job_b){
	job_b->current_function(job_b); // 0
	job_b->time++;
	return;
}
static void main_job_b_0(MAIN_JOB_B *job_b){
	if (0==job_b->time%128) {
		long int x;
		long int y;
		// push
		x = syscall(SYS_SCREEN_GET_LOCATE_X);
		y = syscall(SYS_SCREEN_GET_LOCATE_Y);
		// print
		syscall(SYS_SCREEN_LOCATE,640-8,480-12);
		switch ( job_b->state ) {
			case 0: syscall(SYS_SCREEN_PUT_CHAR,'|'); break;
			case 1: syscall(SYS_SCREEN_PUT_CHAR,'/'); break;
			case 2: syscall(SYS_SCREEN_PUT_CHAR,'-'); break;
			case 3: syscall(SYS_SCREEN_PUT_CHAR,'\\'); break;
		}
		job_b->state++;
		job_b->state = job_b->state % 4;
		// pop
		syscall(SYS_SCREEN_SET_LOCATE_X,x);
		syscall(SYS_SCREEN_SET_LOCATE_Y,y);
	}
	if (0==job_b->time%32768*2) {
		unsigned long int tick_count_stamp_start;
		unsigned long int tick_count_stamp_stop;
		unsigned long int x,y;
		switch ( job_b->draw ) {
			case 0: {
				main_job_b_score1(640-128,120,"Draw1 Time:...");
				tick_count_stamp_start		= syscall(SYS_TIMER_GET_COUNT);
//				for (y=0;y<10;y++)
//					for (x=0;x<10;x++) syscall(SYS_VRAM_IMAGE_PASTE,&image_koizumi,image_koizumi.width*x,image_koizumi.height*y);
				for (y=0;y<5;y++)
					for (x=0;x<8;x++) syscall(SYS_VRAM_IMAGE_PASTE,&image_rose,image_rose.width*x,image_rose.height*y);
				tick_count_stamp_stop		= syscall(SYS_TIMER_GET_COUNT);
				main_job_b_score2(640-128,120,"Draw1 Time:   ",tick_count_stamp_stop - tick_count_stamp_start);
			} break;
			case 1: {
				main_job_b_score1(640-128,120+12+12+12+12 +12+12+12+12,"Erase Time:...");
				tick_count_stamp_start		= syscall(SYS_TIMER_GET_COUNT);
//				for (y=0;y<10;y++)
//					for (x=0;x<10;x++) syscall(SYS_VRAM_IMAGE_CLEAR,&image_koizumi,image_koizumi.width*x,image_koizumi.height*y);
				for (y=0;y<5;y++)
					for (x=0;x<8;x++) syscall(SYS_VRAM_IMAGE_CLEAR,&image_rose,image_rose.width*x,image_rose.height*y);
				tick_count_stamp_stop		= syscall(SYS_TIMER_GET_COUNT);
				main_job_b_score2(640-128,120+12+12+12+12 +12+12+12+12,"Erase Time:   ",tick_count_stamp_stop - tick_count_stamp_start);
			} break;
			case 2: {
				main_job_b_score1(640-128,120+12+12+12+12,"Draw2 Time:...");
				tick_count_stamp_start		= syscall(SYS_TIMER_GET_COUNT);
//				for (y=0;y<10;y++)
//					for (x=0;x<10;x++) syscall(SYS_VRAM_IMAGE_PASTE_FILTER,&image_koizumi,image_koizumi.width*x,image_koizumi.height*y);
				for (y=0;y<5;y++)
					for (x=0;x<8;x++) syscall(SYS_VRAM_IMAGE_PASTE_FILTER,&image_rose,image_rose.width*x,image_rose.height*y);
				tick_count_stamp_stop		= syscall(SYS_TIMER_GET_COUNT);
				main_job_b_score2(640-128,120+12+12+12+12,"Draw2 Time:   ",tick_count_stamp_stop - tick_count_stamp_start);
			} break;
			case 3: {
				main_job_b_score1(640-128,120+12+12+12+12 +12+12+12+12,"Erase Time:...");
				tick_count_stamp_start		= syscall(SYS_TIMER_GET_COUNT);
//				for (y=0;y<10;y++)
//					for (x=0;x<10;x++) syscall(SYS_VRAM_IMAGE_CLEAR,&image_koizumi,image_koizumi.width*x,image_koizumi.height*y);
				for (y=0;y<5;y++)
					for (x=0;x<8;x++) syscall(SYS_VRAM_IMAGE_CLEAR,&image_rose,image_rose.width*x,image_rose.height*y);
				tick_count_stamp_stop		= syscall(SYS_TIMER_GET_COUNT);
				main_job_b_score2(640-128,120+12+12+12+12 +12+12+12+12,"Erase Time:   ",tick_count_stamp_stop - tick_count_stamp_start);
			} break;
		}
		job_b->draw++;
		job_b->draw = job_b->draw % 4;
	}
	return;
}
static void main_job_b_score2(unsigned long int xx,unsigned long int yy,unsigned char *string,unsigned long int time){
	long int x;
	long int y;
	unsigned char debug_text[DEBUG_TEXT_LEN+1];
	// push
	x = syscall(SYS_SCREEN_GET_LOCATE_X);
	y = syscall(SYS_SCREEN_GET_LOCATE_Y);
	// color
	syscall(SYS_SCREEN_SET_COLOR_FG,255,0,0);
	syscall(SYS_SCREEN_SET_COLOR_BG,255,255,255);
	// print
	syscall(SYS_SCREEN_LOCATE,xx,yy);
	syscall(SYS_SCREEN_PUT_STRING,string);
	debug_convert( time , debug_text , DEBUG_TEXT_LEN , 10 );
	syscall(SYS_SCREEN_LOCATE,xx,yy+12);
	syscall(SYS_SCREEN_PUT_STRING,debug_text);
	syscall(SYS_SCREEN_PUT_STRING,"(ms)");
	// color
	syscall(SYS_SCREEN_SET_COLOR_FG,0,0,255);
	syscall(SYS_SCREEN_SET_COLOR_BG,255,255,255);
	// pop
	syscall(SYS_SCREEN_SET_LOCATE_X,x);
	syscall(SYS_SCREEN_SET_LOCATE_Y,y);
	//
	return;
}
static void main_job_b_score1(unsigned long int xx,unsigned long int yy,unsigned char *string){
	long int x;
	long int y;
	unsigned char debug_text[DEBUG_TEXT_LEN+1];
	// push
	x = syscall(SYS_SCREEN_GET_LOCATE_X);
	y = syscall(SYS_SCREEN_GET_LOCATE_Y);
	// color
	syscall(SYS_SCREEN_SET_COLOR_FG,255,255,255);
	syscall(SYS_SCREEN_SET_COLOR_BG,255,0,0);
	// print
	syscall(SYS_SCREEN_LOCATE,xx,yy);
	syscall(SYS_SCREEN_PUT_STRING,string);
	// color
	syscall(SYS_SCREEN_SET_COLOR_FG,0,0,255);	// def
	syscall(SYS_SCREEN_SET_COLOR_BG,255,255,255);
	// pop
	syscall(SYS_SCREEN_SET_LOCATE_X,x);
	syscall(SYS_SCREEN_SET_LOCATE_Y,y);
	//
	return;
}


/////////////////////////////////////////////
// main_job_b TIMER
/////////////////////////////////////////////
struct main_job_c {
	void (*current_function)(struct main_job_c *job_c);
	unsigned long int time;
} typedef MAIN_JOB_C;
static void main_job_c_init(MAIN_JOB_C *job_c);
static void main_job_c_vm(MAIN_JOB_C *job_c);
static void main_job_c_0(MAIN_JOB_C *job_c);

static void main_job_c_init(MAIN_JOB_C *job_c){
	job_c->current_function	= main_job_c_0;
	job_c->time		= 0;
	return;
}
static void main_job_c_vm(MAIN_JOB_C *job_c){
	job_c->current_function(job_c); // 0
	job_c->time++;
	return;
}
static void main_job_c_0(MAIN_JOB_C *job_c){
	if (0==job_c->time%256) {
		long int x;
		long int y;
		unsigned char debug_text[DEBUG_TEXT_LEN+1];
		// push
		x = syscall(SYS_SCREEN_GET_LOCATE_X);
		y = syscall(SYS_SCREEN_GET_LOCATE_Y);
		// print
		syscall(SYS_SCREEN_LOCATE,320-8,480-12);
		syscall(SYS_SCREEN_PUT_STRING,"TickTimer Count:  ");
		debug_convert( syscall(SYS_TIMER_GET_COUNT) , debug_text , DEBUG_TEXT_LEN , 10 );
		syscall(SYS_SCREEN_PUT_STRING,debug_text);
		// pop
		syscall(SYS_SCREEN_SET_LOCATE_X,x);
		syscall(SYS_SCREEN_SET_LOCATE_Y,y);
		//
		//net_send();
		//net_recv();
	}
	if (0==job_c->time%4096) {
		unsigned char *p;
		long int x;
		long int y;
		unsigned char data;
		unsigned char debug_text[DEBUG_TEXT_LEN+1];
		//
		x = syscall(SYS_SCREEN_GET_LOCATE_X);
		y = syscall(SYS_SCREEN_GET_LOCATE_Y);
		//
		syscall(SYS_SCREEN_LOCATE,0,480-12-12-12);
		syscall(SYS_SCREEN_PUT_STRING,"0x04400000:(page0)");
		REG8(0x04400000) = 0x22; // page0
		for(p=0x04400000;p<0x04400010;p++){
			data = REG8(p);
			debug_convert( (unsigned long int)data , debug_text , 2 , 16 );
			syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		}
		syscall(SYS_SCREEN_LOCATE,0,480-12-12);
		syscall(SYS_SCREEN_PUT_STRING,"0x04400000:(page1)");
		REG8(0x04400000) = 0x62; // page1
		for(p=0x04400000;p<0x04400010;p++){
			data = REG8(p);
			debug_convert( (unsigned long int)data , debug_text , 2 , 16 );
			syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		}
		//		
		syscall(SYS_SCREEN_SET_LOCATE_X,x);
		syscall(SYS_SCREEN_SET_LOCATE_Y,y);
		//
	}
	return;
}


/////////////////////////////////////////////
// main_loop
/////////////////////////////////////////////
static void main_loop(void) {
	MAIN_JOB_A a;
	MAIN_JOB_B b;
	MAIN_JOB_C c;
	// init
	main_job_a_init(&a);
	main_job_b_init(&b);
	main_job_c_init(&c);
	// vm loop
	while (1) {
		net_recv();
		main_job_a_vm(&a);
		main_job_b_vm(&b);
		main_job_c_vm(&c);
	}
	return;
}
/////////////////////////////////////////////
// main
/////////////////////////////////////////////
extern void *boot_id;
int main(void){
// rtl8019as init
	net_init();
// init syscall(must call one time)
	syscall(SYS_INIT);
// hello world
	{
		int i,ii;
		syscall(SYS_SCREEN_LOCATE,0,0);
		syscall(SYS_SCREEN_PUT_STRING,"Hello World\n");
		syscall(SYS_SCREEN_PUT_STRING,"Let's OpenCores!!!\n");
		for (i=0;i<16384;i++){
	//		for (ii=0;ii<16384;ii++) {}
		}
	}
//	mtspr( SPR_PCMR( (0) ), SPR_PCMR_CP | SPR_PCMR_IF );
	
// print version
	syscall(SYS_VRAM_CLEAR);
	syscall(SYS_SCREEN_LOCATE,0,480-12-12-12-12-12-12);
#ifdef BUILD_ID
	syscall(SYS_SCREEN_PUT_STRING,"BUILD ID:  ");
	syscall(SYS_SCREEN_PUT_STRING,BUILD_ID);
	syscall(SYS_SCREEN_PUT_STRING,"\n");
#endif
	syscall(SYS_SCREEN_PUT_STRING," BOOT ID:  ");
	syscall(SYS_SCREEN_PUT_STRING,(unsigned char *)&boot_id);
	syscall(SYS_SCREEN_PUT_STRING,"\n");
// main_loop
	main_loop();
	return;
}


