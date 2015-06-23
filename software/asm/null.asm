
; ============================================================================
;        __
;   \\__/ o\    (C) 2013, 2014  Robert Finch, Stratford
;    \  __ /    All rights reserved.
;     \/_//     robfinch<remove>@opencores.org
;       ||
;  
;
; This source file is free software: you can redistribute it and/or modify 
; it under the terms of the GNU Lesser General Public License as published 
; by the Free Software Foundation, either version 3 of the License, or     
; (at your option) any later version.                                      
;                                                                          
; This source file is distributed in the hope that it will be useful,      
; but WITHOUT ANY WARRANTY; without even the implied warranty of           
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
; GNU General Public License for more details.                             
;                                                                          
; You should have received a copy of the GNU General Public License        
; along with this program.  If not, see <http://www.gnu.org/licenses/>.    
;
; keyboard.asm                                                                         
; ============================================================================
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;
public NullDCB:
	align	4
	db	"NULL        "	; name
	dw	4	; number of chars in name
	dw	0	; type
	dw	1	; nBPB
	dw	0	; last erc
	dw	0	; nBlocks
	dw	NullCmdProc
	dw	NullInit
	dw	NullStat
	dw	255	; reentrancy count (1 to 255 are valid)
	dw	0	; single user
	dw	0	; hJob
	dw	0	; OSD1
	dw	0	; OSD2
	dw	0	; OSD3
	dw	0	; OSD4
	dw	0	; OSD5
	dw	0	; OSD6

NullCmdProc:
	rts

NullInit:
	rts

NullStat:
	rts
