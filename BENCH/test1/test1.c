#include <16c57.h>//the is no 16f57.h file in the my version of ccs.so using it instered 

#byte DISP = 100

disp_byte(char c){
switch (c){
case 0:DISP ='0';break;
case 1:DISP ='1';break;
case 2:DISP ='2';break;
case 3:DISP ='3';break;
case 4:DISP ='4';break;
case 5:DISP ='5';break;
case 6:DISP ='6';break;
case 7:DISP ='7';break;
case 8:DISP ='8';break;
case 9:DISP ='9';break;
}
}

main(){
char i=0,j=0;
while(1){
	i=++i%10;
	disp_byte(i);
}
}

