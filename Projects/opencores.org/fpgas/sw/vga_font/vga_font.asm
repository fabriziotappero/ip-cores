
	
       cpu 6502
           output HEX
	
	     * = $0000  ; assemble at $f000
               code
;-------------------------------------------
;				;
;Code  00h     defines a solid block	    ;
;Codes 01h-04h define block graphics	    ;
;Codes 05h-1Fh define line graphics          ;
;Codes 20h-7Eh define the ASCII characters   ;
;Code  7Fh     defines a hash pattern	    ;
;Codes 80h-FFh user defined characters	    ;
;------------------------------------------- ;
;//// Solid Block ////
        ;// 00h: solid block                      address    000   
     db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF;
;// Block graphics ////
        ; 01h: Left block up, right block down    address    008   
     db $F0,$F0,$F0,$F0,$0F,$0F,$0F,$0F;
        ; 02h: Left block down, right block up    address    010   
     db $0F,$0F,$0F,$0F,$F0,$F0,$F0,$F0;
        ; 03h: Both blocks down                   address    018   
     db $00,$00,$00,$00,$FF,$FF,$FF,$FF;
        ; 04h: Both blocks up                     address    020   
     db $FF,$FF,$FF,$FF,$00,$00,$00,$00;
;// Line Graphics ////
        ; 05h: corner upper left                  address    028   
     db $FF,$80,$80,$80,$80,$80,$80,$80;
        ; 06h: corner upper right                 address    030   
     db $FF,$01,$01,$01,$01,$01,$01,$01;
        ; 07h: corner lower left                  address    038   
     db $80,$80,$80,$80,$80,$80,$80,$FF;
        ; 08h: corner lower right                 address    040   
     db $01,$01,$01,$01,$01,$01,$01,$FF;
        ; 09h: cross junction                     address    048   
     db $10,$10,$10,$FF,$10,$10,$10,$10;
        ; 0Ah: "T" junction                       address    050   
     db $FF,$10,$10,$10,$10,$10,$10,$10;
        ; 0Bh: "T" juntion rotated 90 clockwise   address    058   
     db $01,$01,$01,$FF,$01,$01,$01,$01;
        ; 0Ch: "T" juntion rotated 180            address    060   
     db $10,$10,$10,$10,$10,$10,$10,$FF;
        ; 0Dh: "T" junction rotated 270 clockwise    address    068   
     db $80,$80,$80,$FF,$80,$80,$80,$80;
        ; 0Eh: arrow pointing right                  address    070   
     db $08,$04,$02,$FF,$02,$04,$08,$00;
        ; 0Fh: arrow pointing left                   address    078   
     db $10,$20,$40,$FF,$40,$20,$10,$00;
        ; 10h: first (top) horizontal line           address    080   
     db $FF,$00,$00,$00,$00,$00,$00,$00;
        ; 11h: second horizontal line                address    088   
     db $00,$FF,$00,$00,$00,$00,$00,$00;
        ; 12h: third horizontal line                 address    090   
     db $00,$00,$FF,$00,$00,$00,$00,$00;
        ; 13h: fourth horizontal line                address    098   
     db $00,$00,$00,$FF,$00,$00,$00,$00;
        ; 14h: fifth horizontal line                 address    0A0   
     db $00,$00,$00,$00,$FF,$00,$00;
        ; 15h: sixth horizontal line                 address    0A7   
     db $00,$00,$00,$00,$00,$00,$FF,$00,$00;
        ; 16h: seventh horizontal line               address    0B0   
     db $00,$00,$00,$00,$00,$00,$FF,$00;
        ; 17h: eighth (bottom) horizontal line       address    0B8   
     db $00,$00,$00,$00,$00,$00,$00,$FF;
        ; 18h: first (left) vertical line            address    0C0   
     db $80,$80,$80,$80,$80,$80,$80,$80;
        ; 19h: second vertical line                  address    0C8   
     db $40,$40,$40,$40,$40,$40,$40,$40;
        ; 1Ah: third vertical line                   address    0D0   
     db $20,$20,$20,$20,$20,$20,$20,$20;
        ; 1Bh: fourth vertical line                  address    0D8   
     db $10,$10,$10,$10,$10,$10,$10,$10;
        ; 1Ch: fifth vertical line                   address    0E0   
     db $08,$08,$08,$08,$08,$08,$08,$08;
        ; 1Dh: sixth vertical line                   address    0E8   
     db $04,$04,$04,$04,$04,$04,$04,$04;
        ; 1Eh: seventh vertical line                 address    0F0   
     db $02,$02,$02,$02,$02,$02,$02,$02;
        ; 1Fh: eighth (right) vertical line          address    0F8   
     db $01,$01,$01,$01,$01,$01,$01,$01;
;// ASCII Characters ////
        ; 20h: space                                 address    100   
     db $00,$00,$00,$00,$00,$00,$00,$00;
        ; 21h: !                                     address    108   
     db $10,$10,$10,$10,$00,$00,$10,$00;
        ; 22h: "                                     address    110   
     db $28,$28,$28,$00,$00,$00,$00,$00;
        ; 23h: #                                     address    118   
     db $28,$28,$7C,$28,$7C,$28,$28,$00;
        ; 24h: $                                     address    120   
     db $10,$3C,$50,$38,$14,$78,$10,$00;
        ; 25h: %                                     address    128   
     db $60,$64,$08,$10,$20,$46,$06,$00;
        ; 26h: &                                     address    130   
     db $30,$48,$50,$20,$54,$48,$34,$00;
        ; 27h: '                                     address    138   
     db $30,$10,$20,$00,$00,$00,$00,$00;
        ; 28h: (                                     address    140   
     db $08,$10,$20,$20,$20,$10,$08,$00;
        ; 29h: )                                     address    148   
     db $20,$10,$08,$08,$08,$10,$20,$00;
        ; 2Ah: *                                     address    150   
     db $00,$10,$54,$38,$54,$10,$00,$00;
        ; 2Bh: +                                     address    158   
     db $00,$10,$10,$7C,$10,$10,$00,$00;
        ; 2Ch: ,                                     address    160   
     db $00,$00,$00,$00,$00,$30,$10,$20;
        ; 2Dh: -                                     address    168   
     db $00,$00,$00,$7C,$00,$00,$00,$00;
        ; 2Eh: .                                     address    170   
     db $00,$00,$00,$00,$00,$30,$30,$00;
        ;  2Fh: /                                     address    178   
     db $00,$04,$08,$10,$20,$40,$00,$00;
        ; 30h: 0                                     address    180   
     db $38,$44,$4C,$54,$64,$44,$38,$00;
        ; 31h: 1                                     address    188   
     db $10,$30,$10,$10,$10,$10,$38,$00;
        ; 32h: 2                                     address    190   
     db $38,$44,$04,$08,$10,$20,$7C,$00;
        ; 33h: 3                                     address    198   
     db $7C,$08,$10,$08,$04,$44,$38,$00;
        ; 34h: 4                                     address    1A0   
     db $08,$18,$28,$48,$7C,$08,$08,$00;
        ; 35h: 5                                     address    1A8   
     db $7C,$40,$78,$04,$04,$44,$38,$00;
        ; 36h: 6                                     address    1B0   
     db $18,$20,$40,$78,$44,$44,$38,$00;
        ; 37h: 7                                     address    1B8   
     db $7C,$04,$08,$10,$20,$20,$20,$00;
        ; 38h: 8                                     address    1C0   
     db $38,$44,$44,$38,$44,$44,$38,$00;
        ; 39h: 9                                     address    1C8   
     db $38,$44,$44,$3C,$04,$08,$30,$00;
        ; 3Ah: :                                     address    1D0   
     db $00,$30,$30,$00,$00,$30,$30,$00;
        ; 3Bh: ;                                     address    1D8   
     db $00,$30,$30,$00,$00,$30,$10,$20;
        ; 3Ch: <                                     address    1E0   
     db $08,$10,$20,$40,$20,$10,$08,$00;
        ; 3Dh: =                                     address    1E8   
     db $00,$00,$7C,$00,$7C,$00,$00,$00;
        ; 3Eh: >                                     address    1F0   
     db $20,$10,$08,$04,$08,$10,$20,$00;
        ; 3Fh: ?                                     address    1F8   
     db $38,$44,$04,$08,$10,$00,$10,$00;
        ; 40h: @                                     address    200   
     db $38,$44,$04,$34,$54,$54,$38,$00;
        ; 41h: A                                     address    208   
     db $38,$44,$44,$44,$7C,$44,$44,$00;
        ; 42h: B                                     address    210   
     db $78,$44,$44,$78,$44,$44,$78,$00;
        ; 43h: C                                     address    218   
     db $38,$44,$40,$40,$40,$44,$38,$00;
        ; 44h: D                                     address    220   
     db $70,$48,$44,$44,$44,$48,$70,$00;
        ; 45h: E                                     address    228   
     db $7C,$40,$40,$78,$40,$40,$7C,$00;
        ; 46h: F                                     address    230   
     db $7C,$40,$40,$78,$40,$40,$40,$00;
        ; 47h: G                                     address    238   
     db $38,$44,$40,$5C,$44,$44,$3C,$00;
        ; 48h: H                                     address    240   
     db $44,$44,$44,$7C,$44,$44,$44,$00;
        ; 49h: I                                     address    248   
     db $38,$10,$10,$10,$10,$10,$38,$00;
        ; 4Ah: J                                     address    250   
     db $1C,$08,$08,$08,$08,$48,$30,$00;
        ; 4Bh: K                                     address    258   
     db $44,$48,$50,$60,$50,$48,$44,$00;
        ; 4Ch: L                                     address    260   
     db $40,$40,$40,$40,$40,$40,$7C,$00;
        ; 4Dh: M                                     address    268   
     db $44,$6C,$54,$54,$44,$44,$44,$00;
        ; 4Eh: N                                     address    270   
     db $44,$44,$64,$54,$4C,$44,$44,$00;
        ; 4Fh: O                                     address    278   
     db $38,$44,$44,$44,$44,$44,$38,$00;
        ; 50h: P                                     address    280   
     db $78,$44,$44,$78,$40,$40,$40,$00;
        ; 51h: Q                                     address    288   
     db $38,$44,$44,$44,$54,$48,$34,$00;
        ; 52h: R                                     address    290   
     db $78,$44,$44,$78,$50,$48,$44,$00;
        ; 53h: S                                     address    298   
     db $3C,$40,$40,$38,$04,$04,$78,$00;
        ; 54h: T                                     address    2A0   
     db $7C,$10,$10,$10,$10,$10,$10,$00;
        ; 55h: U                                     address    2A8   
     db $44,$44,$44,$44,$44,$44,$38,$00;
        ; 56h: V                                     address    2B0   
     db $44,$44,$44,$44,$44,$28,$10,$00;
        ; 57h: W                                     address    2B8   
     db $44,$44,$44,$54,$54,$54,$28,$00;
        ; 58h: X                                     address    2C0   
     db $44,$44,$28,$10,$28,$44,$44,$00;
        ; 59h: Y                                     address    2C8   
     db $44,$44,$44,$28,$10,$10,$10,$00;
        ; 5Ah: Z                                     address    2D0   
     db $7C,$04,$08,$10,$20,$40,$7C,$00;
        ; 5Bh: [                                     address    2D8   
     db $38,$20,$20,$20,$20,$20,$38,$00;
        ; 5Ch: \                                     address    2E0   
     db $00,$40,$20,$10,$08,$04,$00,$00;
        ; 5Dh: ]                                     address    2E8   
     db $38,$08,$08,$08,$08,$08,$38,$00;
        ; 5Eh: ^                                     address    2F0   
     db $10,$28,$44,$00,$00,$00,$00,$00;
        ; 5Fh: _                                     address    2F8   
     db $00,$00,$00,$00,$00,$00,$7C,$00;
        ; 60h: `                                     address    300   
     db $20,$10,$08,$00,$00,$00,$00,$00;
        ; 61h: a                                     address    308   
     db $00,$00,$38,$04,$3C,$44,$3C,$00;
        ; 62h: b                                     address    310   
     db $40,$40,$58,$64,$44,$44,$78,$00;
        ; 63h: c                                     address    318   
     db $00,$00,$38,$40,$40,$44,$38,$00;
        ; 64h: d                                     address    320   
     db $04,$04,$34,$4C,$44,$44,$3C,$00;
        ; 65h: e                                     address    328   
     db $00,$00,$38,$44,$7C,$40,$38,$00;
        ; 66h: f                                     address    330   
     db $18,$24,$20,$70,$20,$20,$20,$00;
        ; 67h: g                                     address    338   
     db $00,$00,$3C,$44,$44,$3C,$04,$38;
        ; 68h: h                                     address    340   
     db $40,$40,$58,$64,$44,$44,$44,$00;
        ; 69h: i                                     address    348   
     db $10,$10,$30,$10,$10,$10,$38,$00;
        ; 6Ah: j                                     address    350   
     db $00,$08,$00,$18,$08,$08,$48,$30;
        ; 6Bh: k                                     address    358   
     db $40,$40,$48,$50,$60,$50,$48,$00;
        ; 6Ch: l                                     address    360   
     db $30,$10,$10,$10,$10,$10,$38,$00;
        ; 6Dh: m                                     address    368   
     db $00,$00,$68,$54,$54,$44,$44,$00;
        ; 6Eh: n                                     address    370   
     db $00,$00,$58,$64,$44,$44,$44,$00;
        ; 6Fh: o                                     address    378   
     db $00,$00,$38,$44,$44,$44,$38,$00;
        ; 70h: p                                     address    380   
     db $00,$00,$78,$44,$78,$40,$40,$40;
        ; 71h: q                                     address    388   
     db $00,$00,$00,$34,$4C,$3C,$04,$04;
        ; 72h: r                                     address    390   
     db $00,$00,$58,$64,$40,$40,$40,$00;
        ; 73h: s                                     address    398   
     db $00,$00,$38,$40,$38,$04,$78,$00;
        ; 74h: t                                     address    3A0   
     db $00,$20,$20,$70,$20,$20,$24,$18;
        ; 75h: u                                     address    3A8   
     db $00,$00,$44,$44,$44,$4C,$34,$00;
        ; 76h: v                                     address    3B0   
     db $00,$00,$44,$44,$44,$28,$10,$00;
        ; 77h: w                                     address    3B8   
     db $00,$00,$44,$44,$54,$54,$28,$00;
        ; 78h: x                                     address    3C0   
     db $00,$00,$44,$28,$10,$28,$44,$00;
        ; 79h: y                                     address    3C8   
     db $00,$00,$00,$44,$44,$3C,$04,$38;
        ; 7Ah: z                                     address    3D0   
     db $00,$00,$7C,$08,$10,$20,$7C,$00;
        ; 7Bh: {                                     address    3D8   
     db $08,$10,$10,$20,$10,$10,$08,$00;
        ; 7Ch: |                                     address    3E0   
     db $10,$10,$10,$10,$10,$10,$10,$00;
        ; 7Dh: }                                     address    3E8   
     db $20,$10,$10,$08,$10,$10,$20,$00;
        ; 7Eh: ~                                     address    3F0   
     db $00,$00,$60,$92,$0C,$00,$00,$00;
;// Hash Pattern ////
        ; 7Fh: hash pattern                          address    3F8   
     db $55,$AA,$55,$AA,$55,$AA,$55,$AA;
;// User Defined Characters ////
        ; 80h: vertical to the left                  address    400   
     db $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0;
        ; 81h: vertical to the right                 address    408   
     db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F;
        ; 82h: circle                                address    410   
     db $00,$18,$3C,$7E,$7E,$3C,$18,$00;
        ; 83h: Upper left block only                 address    418   
     db $F0,$F0,$F0,$F0,$00,$00,$00,$00;
        ; 84h: Upper right block only                address    420   
     db $0F,$0F,$0F,$0F,$00,$00,$00,$00;
        ; 85h: Lower left block only                 address    428   
     db $00,$00,$00,$00,$F0,$F0,$F0,$F0;
        ; 86h: Lower right block only                address    430   
     db $00,$00,$00,$00,$0F,$0F,$0F,$0F;
        ; 87h: One horizontal line                   address    438   
     db $00,$00,$00,$00,$00,$00,$00,$FF;
        ; 88h: Two horizontal lines                  address    440   
     db $00,$00,$00,$00,$00,$00,$FF,$FF;
        ; 89h: Three horizontal lines                address    448   
     db $00,$00,$00,$00,$00,$FF,$FF,$FF;
        ; 8Ah: Four horizontal lines                 address    450   
     db $00,$00,$00,$00,$FF,$FF,$FF,$FF;
        ; 8Bh: Five horizontal lines                 address    458   
     db $00,$00,$00,$FF,$FF,$FF,$FF,$FF;
        ; 8Ch: Six horizontal lines                  address    460   
     db $00,$00,$FF,$FF,$FF,$FF,$FF,$FF;
        ; 8Dh: Seven horizontal lines                address    468   
     db $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF;
        ; 8Eh: One vertical line                     address    470   
     db $80,$80,$80,$80,$80,$80,$80,$80;
        ; 8Fh: Two vertical lines                    address    478   
     db $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0;


 code