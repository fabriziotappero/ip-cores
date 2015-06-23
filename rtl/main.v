`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Company: EnergyLabs Brasil
// Engineer: Lucas Teske
// 
// Create Date:    	16:11:50 02/04/2011 
// Design Name: 	 	LVDS LCD Virtual Terminal
// Module Name:    	main 
// Project Name:   	LVDS LCD Virtual Terminal
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Circuito Funcionando, ainda com alguns bugs.
// Revision 0.03 - Reescrito descrições, código organizado
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////
module main(
				 input 	clk,
				 output 	[2:0] dataouta_p,
				 output 	[2:0] dataouta_n,
				 output 	clkouta1_p,
				 output 	clkouta1_n,
				 output 	led1,
				 output 	led2,
				 output 	led3,
				 output 	led4,
				 output 	TxD,
				 input 	RxD,
				 input 	PS2clk,
				 input 	PS2data
    );


//Multiplicador de Clock (DCM)
//Tenho um clock de 16MHz na entrada, periodo 62.5ns
//Multiplico ele por 4 para obter 64MHz, a tela pecisa de 60Mhz para fazer 60Hz + ou -

wire clo,clk4x;
DCM_SP #(
	.CLKIN_PERIOD	("62.5"),
	.CLKFX_MULTIPLY	(4)
	)
dcm_main (
	.CLKIN   	(clk),
	.CLKFB   	(clo),
	.RST     	(1'b0),
	.CLK0    	(clo),
	.CLKFX   	(clk4x)
);
defparam dcm_main.CLKIN_PERIOD = 62.5;
defparam dcm_main.CLKFX_MULTIPLY = 4;
defparam dcm_main.CLKFX_DIVIDE = 1;

//Parametros para o tamanho da tela

parameter ScreenX = 1024;
parameter ScreenY = 768;

//Registradores para a cor

reg [5:0] DataBlue = 0;
reg [5:0] DataRed = 0;
reg [5:0] DataGreen = 0;

//Contador de colunas e linhas
//Com esses valores você pode desenhar na tela
reg [10:0] ContadorX = 0; // Contador de colunas
reg [10:0] ContadorY = 0; // Contador de linhas

//Sincronia Horizontal e Vertical
//São sinais que atuam na descida, então padrão deles é 1
reg HSync = 1;
reg VSync = 1;
//Ativa a gravação de dados no LCD.
//Atente-se que o data_enable é recebido pelo LCD,
//Ele atua entre uma linha e outra ou entre uma tela e outra
reg data_enable = 1;

//Esse registrador é usado para fazer o fundo se mover. A cada vsync ele é incrementado.
//Somo esse registrador nos valores de R, G e B para rodar o fundo.
reg [5:0] Parallax = 0;


//Tamanho do Console Virtual e Registradores de Controle

//Esses registradores são usados na leitura
reg [6:0] ColunaChar = 1;
reg [5:0] LinhaChar = 1;
reg LineLock = 0;
reg CharLock = 0;

//Esses Registradores são usados na gravação
reg [6:0] ColunaW = 0;
reg [5:0] RefLine = 59;
reg [6:0] RefChar = 0;

//Definição do tamanho do console.
//Note que são apenas wires para a detecção do fim
//das colunas e linhas. Há outras alterações além 
//daqui para se aumentar o console.

wire MaxChars = (ColunaChar == 79);
wire MaxLines = (LinhaChar == 59);

//Limites do console virtual
wire OutOfBondary = ((ContadorY < 144) | (ContadorY >= 624) | (ContadorX >= 835) | (ContadorX <= 192));

reg [2:0] PixelChar = 7;
wire [7:0] CharByte;
wire [7:0] ActualChar;
reg Point = 0;

//Operadores da RAM

reg charwrote = 0;
reg ReadScroll = 0;
reg ReadEnable = 1;
reg [12:0] ContadorChar  = 4720; // Registrador para Gravação do caracter na RAM
reg [7:0] DataWrite;
reg WriteLocked = 0;
reg WorkLocked = 0;
reg [1:0] ScreenWork = 0;
reg CharErased = 0;
reg CharWrited = 0;
reg Scrolling = 0;
wire [17:0] LogoByte;
reg [5:0] LinhaShift = 0;
reg [5:0] LinhaRead = 0;

//Serial Write Data
reg WE;
wire [7:0] SerialByte;
wire SerialReady;
wire SerialIdle;


//Wires para ligar os sub-circuitos
wire [20:0] lcddata;
wire [27:0] serializerdata;
wire serial_write, TxD_busy;
wire [7:0] serial_data;
wire mod_led;

//Transmissor Serial
async_transmitter SerialTX(
	.clk(clk4x),
	.TxD(TxD),
	.TxD_start(serial_write),
	.TxD_data(serial_data),
	.TxD_busy(TxD_busy)
	);

//Receptor Serial
async_receiver SerialRX (
    .clk(clk4x), 
    .RxD(RxD), 
    .RxD_data_ready(SerialReady), 
    .RxD_data(SerialByte), 
    .RxD_idle(SerialIdle)
    );
	
//Controlador do Teclado PS2
PS2 Keyboard (
    .clk(clk4x), 
    .ps2clk(PS2clk), 
    .ps2data(PS2data), 
    .write(serial_write), 
    .dataout(serial_data),
	 .mod_led(mod_led)
    );

//Serializador LVDS

top4_tx serializador (
  	.clkint(clk4x), 
    .datain(serializerdata), 
    .rstin(1'b1), 
    .dataouta_p(dataouta_p), 
	 .dataouta_n(dataouta_n), 
    .clkouta1_p(clkouta1_p), 
    .clkouta1_n(clkouta1_n)
    );


//ROM com Logo da EnergyLabs Brasil
LogoROM LogoROM (
	.clka(clk4x),
	.ena( (((ContadorX <= 128)|(ContadorX >= (ScreenX-128))) & (ContadorY <= 128))),
	.addra({ContadorY[6:1],ContadorX[6:1]}), 
	.douta(LogoByte)); 

//ROM com a fonte IBM PC
fontrom  FONT_ROM (
	.clka(clk4x),
	.addra({ContadorY[2:0],ActualChar[7:0]}),
	.douta(CharByte));

//RAM para Buffer dos caracteres na tela
textram CharRam (
	.clka(clk4x),
	.ena(WE),
	.wea(WE), 
	.addra(ContadorChar),  
	.dina(DataWrite),  
	.clkb(clk4x),
	.enb(ReadEnable | ReadScroll),
	.addrb({(LinhaRead)*80+ColunaChar}),
	.doutb(ActualChar)); 
	
//Função da recepção de dados na Serial
always @(posedge clk4x)
begin
	//Trabalhos
	if(WorkLocked)
	begin
			case(ScreenWork)
				2'b01: //BackSpace
				begin	
						if(~CharErased)
						begin
								ContadorChar 	<= ContadorChar -1;
								if(RefChar == 0)
								begin
										RefChar 	<= 79;
										if(RefLine == 0)
											RefLine 	<= 59;
										else
											RefLine 	<= RefLine - 1;
								end
								else
										RefChar 	<= RefChar - 1;
								DataWrite 	<= 0;
								WE 			<= 1;
								WorkLocked 	<= 1;
								CharErased 	<= 1;
						end
						else
						begin
								DataWrite 	<='h00;
								WE 			<= 0;
								WorkLocked 	<= 0;
								CharErased 	<= 0;
						end
				end
				2'b10: //ClearScreen
				begin
						if(ContadorChar != 4799)
						begin
								DataWrite 	<= 'h00;
								WE 			<= 1;
								ContadorChar <= ContadorChar +1;
								if(RefChar == 79)
								begin
										RefChar 	<= 0;
										if(RefLine == 59)
											RefLine <= 0;
										else
											RefLine <= RefLine + 1;
								end
								else
										RefChar <= RefChar + 1;
						end
						else
						begin
								WE 				<= 0;
								ContadorChar 	<= 4720;
								WorkLocked 		<= 0;
								RefChar 			<= 0;
								RefLine 			<= 59;
								LinhaShift 		<= 0;
						end
				end
				2'b11: //Scroll Screen UP
				begin
						if(Scrolling == 0)
						begin
								Scrolling 		<=	1;
								WE 				<= 0;
								if(LinhaShift == 59)
									ContadorChar <= 0;
								else
									ContadorChar <= (LinhaShift+1)  * 80; // Ponto de gravação
								ReadScroll 		<= 0;
								ColunaW 			<= 0;
								if(LinhaShift == 59)
									LinhaShift 	<= 0;
								else
									LinhaShift 	<=	LinhaShift 	+	1;
						end
						else
						begin
								if(charwrote)
								begin
										//Ciclo de Posicionamento
										charwrote 	<= 0;
										WE 			<= 0;
										if(ColunaW == 79)
										begin
												Scrolling		<= 0;
												WorkLocked 		<=	0;
												RefLine 			<= 59;
												RefChar 			<= 0;
												ColunaW 			<= 0;
												ContadorChar 	<= LinhaShift * 80; // Ponto de gravação
										end
										else
										begin
												ColunaW 			<= ColunaW 	+	1;
												ContadorChar 	<= ContadorChar + 1;
										end
								end
								else
								begin
										//Ciclo de Gravação
										charwrote 	<= 1;
										DataWrite 	<= 0;
										WE 			<= 1;
								end
						end
/*						
			Aqui é a rotina antiga de shift do conteúdo da tela
			Ele reescrevia todas as linhas no endereço anterior da atual
			Muito lento, por isso refiz apenas com um registrador de deslocamento
						if(Scrolling == 0)
						begin
								Scrolling <= 1;
								LinhaW <= 1;
								ColunaW <= 0;
								ContadorChar <= 0;
								charwrote <= 0;
						end
						else
						begin	
								if(charwrote)
								begin //Ciclo de seleção
										charwrote <= 0;
										charread <= 0;
										WE <= 0;
										ReadScroll <= 1;
										if(ColunaW == 79)
										begin
												ColunaW <= 0;
												if(LinhaW == 60)
												begin
														Scrolling <= 0;
														LinhaW <= 0;
														WorkLocked <=0;
														RefLine <= 59;
														RefChar <= 0;
														ContadorChar <= 4720; // 59 * 80 = 4720
												end
												else
												begin
														ContadorChar <= LinhaW * 80;
														LinhaW <= LinhaW +1;
												end
										end
										else
										begin
												ContadorChar <= ContadorChar +2;
												ColunaW <= ColunaW + 1;
										end
								end
								else
								begin //Ciclo de Gravação
										if(charread)
										begin
												WE <= 1;
												charwrote <= 1;
												ReadScroll <= 0;
												charread <= 0;
										end
										else
										begin
												DataWrite <= ActualChar;
												charread <= 1;									
												ContadorChar <= ContadorChar -1;
										end
										
										
								end
						end
				*/
				end
			endcase
	end
	if(SerialReady & ~WriteLocked & ~WorkLocked)
	begin
			WriteLocked <= 1;
			//Checagem de BYTE recebido
			//Aqui há um pequeno problema, o Windows envia \r\n e o Linux apenas \n.
			//Não deveria dar problema, o maximo que iria acontecer é pular duas linhas.
			//Mas não funciona. Para o Windows, comente todas as linhas no Carriage Return
			
			case (SerialByte)
				'h0A: // Nova linha \n
					begin
							WorkLocked 	<= 1;
							ScreenWork 	<= 2'b11;
					end
				'h08: // BackSpace
					begin
							WorkLocked 	<= 1;
							ScreenWork 	<= 1; //BackSpace
					end
				'h09: //Horizontal Tab, acertado pra 5 espaços.
					begin
							//Não dar Tab se a linha não tiver menos do que 5 caracteres disponíveis no caso, 75 ocupados.
							if( ((RefLine * 80) - ContadorChar) < 74)
							begin
									ContadorChar 	<= ContadorChar + 5;
									RefChar 			<= RefChar + 5;									
							end
							
					end
				'h0D: // Carriage Return, retornar para  coluna 1, \r
					begin
							ContadorChar 	<= RefLine * 80; 
							RefChar 			<= 0;
					end

				'h0C: //Frame Feed - Apagar a tela e retornar ao caracter 0x0 da tela.
					begin
							WorkLocked 		<=1;
							ScreenWork 		<= 2; //Erase Screen
							ContadorChar 	<= 0;
					end
				default: //Caso não seja nenhum dos listados acima
				begin
						DataWrite 	<= SerialByte;
						WE 			<= 1;	
						CharWrited 	<=1;
				end
			endcase
	end
	
	if(CharWrited)
	begin
			//Caso o caractere já tenha sido gravado na RAM
			//Aqui ele posicionará o gravador um caracter 
			//adiante. Ele também irá atualizar RefLine e RefChar
			if( (ContadorChar == 4799) | (RefChar == 79) )
			begin
					WorkLocked 		<= 1;
					ScreenWork 		<= 2'b11;
					if(RefChar == 79)
					begin
						RefChar <= 0;
						if(RefLine == 59)
							RefLine <= 0;
						else
							RefLine <= RefLine + 1;
					end
			end
			else
			begin
					ContadorChar 	<= ContadorChar 	+	1;	
					RefChar 			<= RefChar 			+ 	1;				
			end
			CharWrited <= 0;
			WE <= 0;
	end
	
	if(SerialIdle)
	begin
			WriteLocked <=	0;
			if(~WorkLocked)
					WE 	<= 0;
	end	
end

//Ciclo de Imagem
always @(posedge clk4x)
begin
		//Como a RAM de Buffer só escreve ou lê, mas nunca os dois ao mesmo tempo,
		//Definimos aqui, que caso esteja fazendo algum trabalho, na memoria
		//O ReadEnable será 0, caso não, será o valor do data_enable
		if(WorkLocked != 1)
				ReadEnable <= data_enable;
		else
				ReadEnable <= 0;
		
		//Detectamos aqui se estamos dentro da área do console
		//Se não estamos trabalhando e apagando a tela
		if(~OutOfBondary & ~((ScreenWork == 2'b11) & (WorkLocked == 1)) )
		begin
				if((ContadorX[2:0] == 0) & ~CharLock)
				begin
						CharLock 	<= 1;
						if(MaxChars)
								ColunaChar 	<= 0;
						else
								ColunaChar 	<= ColunaChar +1;
				end
				if(ContadorX[2:0] != 0)
					CharLock 	<= 0;
					
				if(ContadorY[2:0] == 0 & ~LineLock)
				begin
						LineLock 	<= 1;
						if(MaxLines)
						begin
								LinhaChar 	<=0;
								LinhaRead 	<= LinhaShift;
						end
						else
						begin
								LinhaChar 	<= LinhaChar +1;
								if((LinhaShift+LinhaChar+1) >= 60)
									LinhaRead 	<= (LinhaShift+LinhaChar+1)-59;
								else
									LinhaRead 	<= LinhaShift+LinhaChar+1;						
						end
				end
				
				if(ContadorY[2:0] != 0)
					LineLock 	<=	0;
					
				if(ContadorX[2:0] == 2)
				begin
						PixelChar 	<= 7;
						Point 		<= CharByte[PixelChar];
				end
				else
				begin
						PixelChar 	<= PixelChar -1;
						Point 		<= CharByte[PixelChar];
				end
				if(Point)
				begin
						DataBlue 	<= 6'b111111;
						DataGreen 	<= 6'b111111;
						DataRed 		<= 6'b111111;
				end
				else
				begin
						DataRed 		<= 6'b000000;
						DataBlue 	<= 6'b000000;
						DataGreen 	<= 6'b000000;
				end
			end
			else
			begin
				if(~((ScreenWork == 2'b11) & (WorkLocked == 1)))
				begin
						if((ContadorX >= 835) | (ContadorX <= 190))
						begin
								CharLock 	<=	1;
								ColunaChar 	<= 0;
						end
						if((ContadorY < 144) | (ContadorY >= 624))
						begin
								LinhaChar 	<= 0;
								if(LinhaShift == 59)
									LinhaRead 	<= 0;
								else
									LinhaRead 	<= LinhaShift+1;
								LineLock 	<= 1;
						end
						DataBlue 	<= 0;
						DataGreen 	<= 0;
						DataRed 		<= 0;	
				end
				else
				begin
						LinhaChar 	<= 0;
						LinhaRead 	<= 0;
						ColunaChar 	<= 0;
				end
			end
			
			if(((ContadorX < 128) | (ContadorX > (ScreenX-128))) & (ContadorY < 128) & ~( ( ( (LogoByte[17:12] <= 4) | (LogoByte[5:0] <= 4) ) ) & (LogoByte[11:6] == 63)))
			begin
					DataRed 		<= LogoByte[17:12];
					DataGreen 	<= LogoByte[11:6];
					DataBlue 	<= LogoByte[5:0];
			end
			else
			begin

				if((ContadorY < 140) | (ContadorX > 835) | (ContadorX < 190) | (ContadorY > 623) )
				begin
						DataRed 		<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 2	);
						DataBlue 	<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax)	) * 3 );
						DataGreen 	<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax)	) * 4 );
				end
				if( ( (ContadorY == 140) & (ContadorX >= 191) & (ContadorX <= 623) ) | ( (ContadorY == 623) & (ContadorX >= 191) & (ContadorX <= 623) ) | ( (ContadorX == 835) & (ContadorY >= 140) & (ContadorY <= 623) ) | ( (ContadorX == 191) & (ContadorY >= 140) & (ContadorY <= 623) ) )
				begin
						DataBlue 	<= 6'b111111;
						DataGreen 	<= 6'b111111;
						DataRed 		<= 6'b111111;		
				end
				if( (ContadorY >= 141) & (ContadorY <= 143) & (ContadorX >= 191) & (ContadorX <= 623) )
				begin
						DataBlue 	<= 6'b000000;
						DataGreen 	<= 6'b000000;
						DataRed 		<= 6'b000000;			
				end
			end
		
			//Sync Generator
			
			ContadorX <= ContadorX + 1;
			
			if((ContadorX == 0) & (ContadorY < ScreenY))
					data_enable 	<= 1;
		
			if(ContadorX == ScreenX)
			begin
					data_enable 	<= 0;
					DataBlue 		<= 0;
					DataRed 			<= 0;
					DataGreen 		<= 0;
					HSync 			<= 0;
			end
			
			if(ContadorX == (ScreenX+280))
					HSync 			<= 1;
			
			if(ContadorX == (ScreenX+300))
			begin
					if(ContadorY == ScreenY)
					begin
							VSync 		<= 0;
							data_enable <= 0;
					end
					if(ContadorY == (ScreenY+35))
					begin
							VSync 		<= 1;
							Parallax 	<= Parallax - 1;
							ContadorY 	<= 0;
							ContadorX 	<= 0;
					end
					else
							ContadorY <= ContadorY +1;
			end
			
			if(ContadorX == (ScreenX+320))
					ContadorX 	<= 0;
end



//Designações de pinos e leds.
assign DE 		= data_enable;
assign led1    = mod_led;
assign led2		= SerialReady;
assign led3		= ~PS2clk;
assign led4		= WorkLocked;


//Aqui fiz um pequeno jogo. O XAPP486 da Xilinx envia os dados assim:
// 			0, 	4,  	8, 	12, 	16, 	20, 	24 - Canal 0
// 			1, 	5,  	9, 	13, 	17, 	21, 	25 - Canal 1
// 			2, 	6, 	10, 	14, 	18, 	22, 	26 - Canal 2
// 			3, 	7, 	11, 	15, 	19, 	23, 	27 - Canal 3
//
//Porém, o LCD precisa deles assim:
//				6,		5,		4,		3,		2,		1,		0	- Canal 0
//				13,	12,	12,	10,	9,		8,		7	- Canal 1
//				20,	19,	18,	17,	16,	15,	14	- Canal 2
//				X,		X,		X,		X,		X,		X,		X	- Canal 3
// Nota: X <= Irrelevante
//Então fiz aqui uma associação da maneira que eu precisava.

assign serializerdata[0] 	= lcddata[6];  //
assign serializerdata[4] 	= lcddata[5]; 	//
assign serializerdata[8] 	= lcddata[4]; 	//
assign serializerdata[12] 	= lcddata[3];  // Canal 0 
assign serializerdata[16] 	= lcddata[2]; 	//
assign serializerdata[20] 	= lcddata[1]; 	//
assign serializerdata[24] 	= lcddata[0]; 	//

assign serializerdata[1] 	= lcddata[13]; //
assign serializerdata[5] 	= lcddata[12]; //
assign serializerdata[9] 	= lcddata[11]; //
assign serializerdata[13] 	= lcddata[10]; //	Canal 1
assign serializerdata[17] 	= lcddata[9];  //
assign serializerdata[21] 	= lcddata[8];  //
assign serializerdata[25] 	= lcddata[7];  //

assign serializerdata[2] 	= lcddata[20]; //
assign serializerdata[6] 	= lcddata[19]; //
assign serializerdata[10] 	= lcddata[18]; //
assign serializerdata[14] 	= lcddata[17]; //	Canal 3
assign serializerdata[18] 	= lcddata[16]; //
assign serializerdata[22] 	= lcddata[15]; //
assign serializerdata[26] 	= lcddata[14]; //

assign serializerdata[3] 	= 1'b0;			//
assign serializerdata[7] 	= 1'b0;			//
assign serializerdata[11] 	= 1'b0;			//
assign serializerdata[15] 	= 1'b0;			//	Canal 4 - Porém irrelevante
assign serializerdata[19] 	= 1'b0;			//
assign serializerdata[23] 	= 1'b0;			//
assign serializerdata[27] 	= 1'b0;			//

// A ordem destes bits no LCD é: Data Enable, Sincronia Vertical, Sincronia Horizontal
assign lcddata [20:18]  = { DE , VSync, HSync};

//A ordem de cores no LCD é: AZUL, VERDE, VERMELHO
assign lcddata [17:0] = {DataBlue, DataGreen, DataRed};

endmodule
