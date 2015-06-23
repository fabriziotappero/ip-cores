             ;Interrupt example
             ;
			 waveform_port		.EQU	02	;bit0 will be data
             counter_port		.EQU	04
             pattern_10101010	.EQU	0xAA
             interrupt_counter	.EQU	sA
             ; 
      start: LOAD	interrupt_counter	, 00				;reset interrupt counter
             LOAD	s2					, pattern_10101010	;initial output condition
             EINT											; enable interrupts
             ;
 drive_wave: OUTPUT s2, waveform_port
             LOAD	s0, 0x07                            ;delay size
       loop: SUB	s0, 0x01                             ;delay loop
             JUMP	NZ, loop
             XOR	s2, 0xFF                             ;toggle waveform
             JUMP	drive_wave
             ;
			 
             .ORG	0x080
int_routine: 
			 ADD	interrupt_counter, 01              ;increment counter
             OUTPUT interrupt_counter, counter_port
             RETI	ENABLE
             ; 
             .ORG	0x3FF                            ;set interrupt vector
             JUMP int_routine
