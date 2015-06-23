#include <system.h>
#include "gpu_pic.h"
#include "input.h"

#pragma CLOCK_FREQ 50000000						//required for accurate delay functionality
//#pragma DATA 0x2007, 0x3F3A					//Configuration bits to prevent having to configure in programmer


void scene1(void)
{
	char i = 0;
	char j = 0;
		
	//initalize graphics to original settings
	
	Bitmap black;
		black.address = 0x0001C200;
		black.lines = 0x00F0;
		black.width = 0x00A0;

	Sprite near_future;
		near_future.image.address = 0x00025800;
		near_future.image.lines = 0x000B;
		near_future.image.width = 0x00A0;
		near_future.position.x = 0;
		near_future.position.y = 63;
		near_future.alpha = 0;

	Sprite eye_anim;
		eye_anim.image.address = 0x00026CA0;
		eye_anim.image.lines = 0x001B;
		eye_anim.image.width = 0x001F;
		eye_anim.position.x = 14;
		eye_anim.position.y = 135;
		eye_anim.alpha = 0;
	
	Sprite eye_mask;
		eye_mask.image.address = 0x0001C200;
		eye_mask.image.lines = 0x001B;
		eye_mask.image.width = 0x001F;
		eye_mask.position.x = 14;
		eye_mask.position.y = 135;
		eye_mask.alpha = 0;
			
	Sprite compass;
		compass.image.address = 0x00029A40;
		compass.image.lines = 0x0006;
		compass.image.width = 0x002D;
		compass.position.x = 51;
		compass.position.y = 134;
		compass.alpha = 0;

	Sprite lines;
		lines.image.address = 0x00029E00;
		lines.image.lines = 0x001A;
		lines.image.width = 0x004F;
		lines.position.x = 73;
		lines.position.y = 76;
		lines.alpha = 0;

	Sprite bars;
		bars.image.address = 0x0002AE94;
		bars.image.lines = 15;
		bars.image.width = 0x002F;
		bars.position.x = 10;
		bars.position.y = 81;
		bars.alpha = 0;

	Sprite outline;
		outline.image.address = 0x00027D80;
		outline.image.lines = 46;
		outline.image.width = 43;
		outline.position.x = 27;
		outline.position.y = 130;
		outline.alpha = 1;

//right limit is about 94,
//left limit is about 51
/*
	Sprite north;
		north.image.address = 0x00029ACA;
		north.image.lines = 6;
		north.image.width = 2;
		north.position.x = 	92;
		north.position.y = 128;
		north.alpha = 1;

	Sprite east;
		east.image.address = 0x00029ACE;
		east.image.lines = 6;
		east.image.width = 2;
		east.position.x = 	51;
		east.position.y = 128;
		east.alpha = 1;

	Sprite south;
		south.image.address = 0x00029AD2;
		south.image.lines = 6;
		south.image.width = 2;
		south.position.x = 	65;
		south.position.y = 128;
		south.alpha = 1;

	Sprite west;
		west.image.address = 0x00029AD6;
		west.image.lines = 6;
		west.image.width = 2;
		west.position.x = 	80;
		west.position.y = 128;
		west.alpha = 1;
*/	
	//fade in introduction text
	drawtobackground(black);
	delay_s(2);
	drawsprite(near_future);
	delay_ms(255);
	near_future.image.address = 0X00025EE0;
	drawtobackground(black);
	drawsprite(near_future);
	delay_ms(255);
	near_future.image.address = 0X000265C0;
	drawtobackground(black);
	drawsprite(near_future);
	delay_s(2);
	//black screen - dramatic pause
	drawtobackground(black);
	delay_s(2);
	//draw eye open animation
	for (i = 0; i < 5; i++)
	{
		drawsprite(eye_mask);
		drawsprite(eye_anim);
		eye_anim.image.address += 0x00000020;
		delay_ms(100);
	}
	//draw and animate compass
	j = 30;
	for ( i = 0; i < 5; i++)//slow down
	{
		drawsprite(compass);//1
		compass.image.address += 0x0000002E;
		delay_ms(j);
		drawsprite(compass);//2
		compass.image.address += 0x0000002E;
		delay_ms(j);
		drawsprite(compass);//3
		compass.image.address -= 0x0000005C;	
		delay_ms(j);
		j+= 15;
	}
	j=20;
	for ( i = 0; i < 5; i++)//reverse
	{
		compass.image.address += 0x0000005C;
		drawsprite(compass);//3
		compass.image.address -= 0x0000002E;
		delay_ms(j);
		drawsprite(compass);//2
		compass.image.address -= 0x0000002E;
		delay_ms(j);
		drawsprite(compass);//1
		delay_ms(j);
		j+= 15;
	}
	j=150;
	for ( i = 0; i < 3; i++)//speed up
	{
		drawsprite(compass);//1
		compass.image.address += 0x0000002E;
		delay_ms(j);
		drawsprite(compass);//2
		compass.image.address += 0x0000002E;
		delay_ms(j);
		drawsprite(compass);//3
		compass.image.address -= 0x0000005C;	
		delay_ms(j);
		j-= 60;
	}
	drawsprite (lines);
	drawsprite (bars);

	j=10;
	for ( i = 0; i < 2; i++)//slow down
	{
		drawsprite(compass);
		compass.image.address += 0x0000002E;
		delay_ms(j);
		drawsprite(compass);//2
		compass.image.address += 0x0000002E;
		delay_ms(j);
		drawsprite(compass);//3
		compass.image.address -= 0x0000005C;	
		delay_ms(j);
		j+= 40;
	}

	lines.image.address = 0x00029E50;
	lines.image.width = 0x004B;
	bars.image.address += 0x00000960;
	bars.image.width = 0x0035;
	drawsprite (lines);
	drawsprite (bars);
	
	drawsprite(compass);
	compass.image.address += 0x0000002E;
	delay_ms(j);
	drawsprite(compass);//2
	compass.image.address += 0x0000002E;
	delay_ms(j);
	drawsprite(compass);//3
	compass.image.address -= 0x0000005C;	
	delay_ms(j);
	j+= 40;

	lines.image.address = 0x0002AE40;
	lines.image.width = 0x0053;
	bars.image.address += 0x0000960;
	drawsprite (lines);
	drawsprite (bars);
	
	//last compass animation
	//drawsprite (north);
	//drawsprite (south);
	//drawsprite (east);
	//drawsprite (west);

	drawsprite(compass);
	compass.image.address += 0x0000002E;
	delay_ms(j);
	drawsprite(compass);//2
	compass.image.address += 0x0000002E;
	delay_ms(j);
	drawsprite(compass);//3
	compass.image.address -= 0x0000005C;	
	delay_ms(j);
	drawsprite(compass);//1
	
	lines.image.address = 0x0002BE80;
	bars.image.address += 0x00000961;
	bars.image.width = 0x0036;
	drawsprite (lines);
	drawsprite (bars);
	delay_ms(200);

	lines.image.address = 0x0002CEC0;
	lines.image.lines = 32;
	lines.image.width = 84;
	lines.position.x = 72;
	lines.position.y = 75;
	bars.image.address += 0x00000960;
	drawsprite (bars);	
	drawsprite (lines);
	delay_ms(50);
	bars.image.address = 0x000713E0;
	bars.image.lines = 21;
	bars.image.width = 62;
	bars.position.x = 4;
	bars.position.y = 80;
	drawsprite (bars);
	drawsprite (lines);
	
	//glitch stuff up
	for (i = 0; i < 50; i++)
	{
		bars.image.address = 0x000713E0;
		lines.image.address = 0x000821E0;
		drawsprite(bars);
		drawsprite (lines);
		delay_ms(5);
		bars.image.address = 0x000706C0;
		lines.image.address = 0x0002CEC0;
		drawsprite(bars);
		drawsprite (lines);
		delay_ms(5);			
	}	

	//draw overlay

	drawsprite (outline);		

	for (i = 0; i < 30; i++)
	{
		bars.image.address = 0x000713E0;
		lines.image.address = 0x000821E0;
		drawsprite(bars);
		drawsprite (lines);
		delay_ms(5);
		bars.image.address = 0x000706C0;
		lines.image.address = 0x0002CEC0;
		drawsprite(bars);
		drawsprite (lines);
		delay_ms(5);			
	}		

	//draw eye close animation with overlay
	eye_anim.image.address = 0x00026D20;
	for (i = 0; i < 5; i++)
	{
		drawsprite(eye_mask);			
		drawsprite(eye_anim);
		drawsprite(outline);
		eye_anim.image.address -= 0x00000020;
		delay_ms(50);
	}
	//draw eye open with overlay
	eye_anim.image.address = 0x00026CA0;
	for (i = 0; i < 5; i++)
	{
		drawsprite(eye_mask);
		drawsprite(eye_anim);
		drawsprite(outline);
		eye_anim.image.address += 0x00000020;
		delay_ms(50);
	}

	delay_ms(255);
	//draw rest of overlay
	drawsprite(eye_mask);
	outline.position.x = 24;
	outline.image.address = 0x00027DAB;
	outline.image.width = 46;
	drawsprite(outline);
	drawsprite(compass);
	delay_ms(200);
	outline.image.address = 0x00027DD9;
	outline.image.width = 60;
	drawsprite(outline);
	drawsprite(compass);
	delay_s(2);
	
	return;
}
void scene2(void)
{
	char i = 0;
	char j = 0;
	
	//initalize graphics to original settings
	
	Bitmap black;
		black.address = 0x0001C200;
		black.lines = 0x00F0;
		black.width = 0x00A0;
	
	Sprite pilot;
		pilot.image.address = 0x000AB180;//0x000A4740;
		pilot.image.lines = 170;
		pilot.image.width = 77;
		pilot.position.x = 20;
		pilot.position.y = 39;
		pilot.alpha = 1;
	
	Sprite screen0;
		screen0.image.address = 0x000A86AD;
		screen0.image.lines = 69;
		screen0.image.width = 40;
		screen0.position.x = 72;
		screen0.position.y = 71;
		screen0.alpha = 1;
		
	Sprite screen1;
		screen1.image.address = 0x000A4F0D;
		screen1.image.lines = 89;
		screen1.image.width = 59;
		screen1.position.x = 72;
		screen1.position.y = 59;
		screen1.alpha = 1;
	
	Sprite screen2;
		screen2.image.address = 0x0009E5C0;
		screen2.image.lines = 156;
		screen2.image.width = 57;
		screen2.position.x = 49;
		screen2.position.y = 25;
		screen2.alpha = 1;
		
	Sprite screen3;
		screen3.image.address = 0x0009E5F9;
		screen3.image.lines = 156;
		screen3.image.width = 38;
		screen3.position.x = 106;
		screen3.position.y = 25;
		screen3.alpha = 1;
		
	Sprite screen4;
		screen4.image.address = 0x0009A060;
		screen4.image.lines = 111;
		screen4.image.width = 40;
		screen4.position.x = 13;
		screen4.position.y = 3;
		screen4.alpha = 1;
	
	Sprite screen5;
		screen5.image.address = 0x0009A095;
		screen5.image.lines = 111;
		screen5.image.width = 21;
		screen5.position.x = 67;
		screen5.position.y = 3;
		screen5.alpha = 1;
	
	Sprite screen6;
		screen6.image.address = 0x00099EEB;
		screen6.image.lines = 17;
		screen6.image.width = 17;
		screen6.position.x = 120;
		screen6.position.y = 2;
		screen6.alpha = 1;
		
	Sprite screen7;
		screen7.image.address = 0x000AA575;
		screen7.image.lines = 20;
		screen7.image.width = 16;
		screen7.position.x = 143;
		screen7.position.y = 188;
		screen7.alpha = 1;
		
	Sprite boot0;
		boot0.image.address = 0x000A478D;
		boot0.image.lines = 12;
		boot0.image.width = 59;
		boot0.position.x = 6;
		boot0.position.y = 15;
		boot0.alpha = 1;
		
	Sprite boot1;
		boot1.image.address = 0x000A0EBF;
		boot1.image.lines = 9;
		boot1.image.width = 65;
		boot1.position.x = 6;
		boot1.position.y = 29;
		boot1.alpha = 1;
		
	Sprite boot2;
		boot2.image.address = 0x000A145F;
		boot2.image.lines = 9;
		boot2.image.width = 65;
		boot2.position.x = 6;
		boot2.position.y = 44;
		boot2.alpha = 1;
		
	Sprite boot3;
		boot3.image.address = 0x000A19FF;
		boot3.image.lines = 9;
		boot3.image.width = 26;
		boot3.position.x = 6;
		boot3.position.y = 58;
		boot3.alpha = 1;

	Sprite boot4;
		boot4.image.address = 0x00099AC0;
		boot4.image.lines = 9;
		boot4.image.width = 60;
		boot4.position.x = 6;
		boot4.position.y = 73;
		boot4.alpha = 1;
	
	Sprite boot5;
		boot5.image.address = 0x00099AFC;
		boot5.image.lines = 9;
		boot5.image.width = 60;
		boot5.position.x = 66;
		boot5.position.y = 73;
		boot5.alpha = 1;
		
	drawtobackground (black);
	delay_s(1);
	drawsprite(pilot);
	delay_ms(200);
	drawsprite(screen0);
	//flash newest screen
	for (i = 0; i < 10; i++)
	{
		drawtobackground(black);
		drawsprite(pilot);
		delay_ms(25);
		drawsprite(screen0);
		delay_ms(25);
	}	
	drawsprite(screen1);	
	for (i = 0; i < 10; i++)
	{
		drawtobackground(black);
		drawsprite(pilot);
		drawsprite(screen0);
		delay_ms(25);
		drawsprite(screen1);
		delay_ms(25);
	}	
	
	drawsprite(screen2);
	drawsprite(screen3);		
	for (i = 0; i < 10; i++)
	{
		drawtobackground(black);
		drawsprite(pilot);
		drawsprite(screen0);
		drawsprite(screen1);
		delay_ms(25);
		drawsprite(screen2);
		drawsprite(screen3);
		delay_ms(25);
		if (i == 3)
			pilot.image.address = 0x000AB1CD;
	}	

	delay_ms(255);
	drawsprite(screen4);
	drawsprite(screen5);
	drawsprite(screen6);
	drawsprite(screen7);
	for (i = 0; i < 10; i++)
	{
		drawtobackground(black);
		drawsprite(pilot);
		drawsprite(screen0);
		drawsprite(screen1);
		drawsprite(screen2);
		drawsprite(screen3);
		delay_ms(25);
		drawsprite(screen4);
		drawsprite(screen5);
		drawsprite(screen6);
		drawsprite(screen7);
		delay_ms(25);
		if (i == 7)
			pilot.image.address = 0x000A4740;
	}	

	delay_s (1);
	drawsprite(boot0);
	delay_ms(255);
	delay_ms(255);
	drawsprite(boot1);
	delay_ms(255);
	delay_ms(255);
	delay_ms(255);
	drawsprite(boot2);
	delay_s(2);
	drawsprite(boot3);
	delay_ms(255);
	drawsprite(boot4);
	drawsprite(boot5);
	delay_s(1);

	return;
}

void scene4(void)
{
	char i = 0;
	char j = 0;

	Bitmap black;
		black.address = 0x0001C200;
		black.lines = 0x00F0;
		black.width = 0x00A0;
		
	Sprite skyline;
		skyline.image.address = 0x00090510;
		skyline.image.lines = 320;
		skyline.image.width = 0;
		skyline.position.x = 80;
		skyline.position.y = 0;
		skyline.alpha = 0;
		
	Sprite plane_1;
		plane_1.image.address = 0x0008B7E0;
		plane_1.image.lines = 123;
		plane_1.image.width = 40;
		plane_1.position.x = 0;
		plane_1.position.y = 200;
		plane_1.alpha = 1;
		
	Sprite plane_2;
		plane_2.image.address = 0x0008B808;
		plane_2.image.lines = 123;
		plane_2.image.width = 40;
		plane_2.position.x = 40;
		plane_2.position.y = 200;
		plane_2.alpha = 1;
	
	Sprite plane_3;
		plane_3.image.address = 0x0008B830;
		plane_3.image.lines = 123;
		plane_3.image.width = 40;
		plane_3.position.x = 80;
		plane_3.position.y = 200;
		plane_3.alpha = 1;
	
	Sprite plane_4;
		plane_4.image.address = 0x0008B858;
		plane_4.image.lines = 123;
		plane_4.image.width = 40;
		plane_4.position.x = 120;
		plane_4.position.y = 200;
		plane_4.alpha = 1;
		
	drawtobackground(black);
	
	for (i = 0; i <80 ; i++)
	{
		drawsprite (skyline);
		drawsprite (plane_1);
		drawsprite (plane_2);
		drawsprite (plane_3);
		drawsprite (plane_4);
		//do some slide fx here
		skyline.image.width +=2;
		skyline.image.address --;
		skyline.position.x --;
	
		plane_1.position.y -= 1;
		plane_2.position.y -= 1;
		plane_3.position.y -= 1;
		plane_4.position.y -= 1;
		
		delay_ms(20 + i/2);
	}
	delay_s(3);
}

void scene5(void)
{
	char i = 0;
	char j = 0;
	unsigned long takeoff_addr[8] = 
	{
		0x0002E720,
		0x000332C0,
		0x00037E60,
		0x0003CA00,
		0x00040BA0,
		0x00044D40,
		0x00049840,
		0x0004E3E0
	};
	char takeoff_lines[8] =
	{
		121,
		121,
		121,
		105,
		105,
		120,
		120,
		121
	};
	Bitmap black;
		black.address = 0x0001C200;
		black.lines = 0x00F0;
		black.width = 0x00A0;
	
	Sprite takeoff;
		takeoff.image.address = takeoff_addr[0];
		takeoff.image.lines = takeoff_lines[0];
		takeoff.image.width = 160;
		takeoff.position.x = 0;
		takeoff.position.y = 49;
		takeoff.alpha = 0;
		
	drawtobackground(black);
	
	//accelerate plane
	for (i = 0; i < 15 ; i++)
	{
		for ( j = 0; j < 8; j++)
		{
			drawsprite (takeoff);
			takeoff.image.address = takeoff_addr[j];
			takeoff.image.lines = takeoff_lines[j];
			delay_ms (100 - (i * 4));
		}
	}

	//max speed
	for (i = 0; i < 10 ; i++)
	{
		for ( j = 0; j < 8; j++)
		{
			drawsprite (takeoff);
			takeoff.image.address = takeoff_addr[j];
			takeoff.image.lines = takeoff_lines[j];
			delay_ms(40);
		}
	}

}

void bootup(void)
{
	char i = 0;
	char j = 0;

	Bitmap black;
		black.address = 0x0001C200;
		black.lines = 0x00F0;
		black.width = 0x00A0;

	Sprite frame;
		frame.image.address = 0x00376800;
		frame.image.lines = 160;
		frame.image.width = 79;
		frame.position.x = 0;
		frame.position.y = 0;
		frame.alpha = 0;

	//reset frame to center
	frame.position.x = 40;
	frame.position.y = 40;
	
	drawtobackground(black);
		
	delay_ms(200);

	//play boot movie
	for (i = 0; i <  21; i++)
	{
		//show 'left' frame
		drawsprite (frame);
		//show 'right' frame
		if (i > 18)
			delay_ms(100);
		else
			delay_ms(60);
		frame.image.address += 80;
		drawsprite (frame);
		if (i > 18)
			delay_ms(100);
		else
			delay_ms(60);
		//skip down to next two frames
		frame.image.address += 25520;	
	}
	return;
}

void main( void )
{
	//Configure port A
	adcon1 = 0x07;								//disable analog inputs
	trisa = 00000000b;
	//Configure port B
	trisb = 0x00;
	//Configure port C
	trisc = 10000000b;
	//Configure port D
	trisd = 10000000b;

	//Initialize port A
	porta = 0x00;
	//Initialize port B
	portb = 0x00;
	//Initialize port C
	portc = 0x00;
	//Initialize port D
	portc = 0x00;

	//wait for GPU to get ready
	//START OF REAL PROGRAM--------------------------------------------


	//char input;
	//setupinput();
	bootup();						//draw bootup logo
	
	//Endless loop
	while( true )
	{
		scene1();
		scene2();
		scene4();
		scene5();
		//final halt
		delay_s(5);	
	}

}
