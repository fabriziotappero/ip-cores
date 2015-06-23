Revision 3
; Created by bitgen D.19 at Thu Jan 09 22:24:06 2003
; Bit lines have the following form:
; <offset> <frame number> <frame offset> <information>
; <information> may be zero or more <kw>=<value> pairs
; Block=<blockname     specifies the block associated with this
;                      memory cell.
;
; Latch=<name>         specifies the latch associated with this memory cell.
;
; Net=<netname>        specifies the user net associated with this
;                      memory cell.
;
; COMPARE=[YES | NO]   specifies whether or not it is appropriate
;                      to compare this bit position between a
;                      "program" and a "readback" bitstream.
;                      If not present the default is NO.
;
; Ram=<ram id>:<bit>   This is used in cases where a CLB function
; Rom=<ram id>:<bit>   generator is used as RAM (or ROM).  <Ram id>
;                      will be either 'F', 'G', or 'M', indicating
;                      that it is part of a single F or G function
;                      generator used as RAM, or as a single RAM
;                      (or ROM) built from both F and G.  <Bit> is
;                      a decimal number.
;
; Info lines have the following form:
; Info <name>=<value>  specifies a bit associated with the LCA
;                      configuration options, and the value of
;                      that bit.  The names of these bits may have
;                      special meaning to software reading the .ll file.
;
Bit       21      1    140 Block=P76 Latch=I1
Bit       31      1    130 Block=P78 Latch=I1
Bit       41      1    120 Block=P80 Latch=I1
Bit       51      1    110 Block=P83 Latch=I1
Bit       61      1    100 Block=P85 Latch=I1
Bit       71      1     90 Block=P87 Latch=I1
Bit       81      1     80 Block=P89 Latch=I1
Bit       92      1     69 Block=P93 Latch=I1
Bit      102      1     59 Block=P95 Latch=I1
Bit      112      1     49 Block=P97 Latch=I1
Bit      122      1     39 Block=P99 Latch=I1
Bit      132      1     29 Block=P102 Latch=I1
Bit      142      1     19 Block=P104 Latch=I1
Bit      152      1      9 Block=P106 Latch=I1
Bit      337      3    146 Block=P75 Latch=OQ
Bit      343      3    140 Block=P76 Latch=I2
Bit      347      3    136 Block=P77 Latch=OQ
Bit      353      3    130 Block=P78 Latch=I2
Bit      357      3    126 Block=P79 Latch=OQ
Bit      363      3    120 Block=P80 Latch=I2
Bit      367      3    116 Block=P82 Latch=OQ
Bit      373      3    110 Block=P83 Latch=I2
Bit      377      3    106 Block=P84 Latch=OQ
Bit      383      3    100 Block=P85 Latch=I2
Bit      387      3     96 Block=P86 Latch=OQ
Bit      393      3     90 Block=P87 Latch=I2
Bit      397      3     86 Block=P88 Latch=OQ
Bit      403      3     80 Block=P89 Latch=I2
Bit      408      3     75 Block=P92 Latch=OQ
Bit      414      3     69 Block=P93 Latch=I2
Bit      418      3     65 Block=P94 Latch=OQ
Bit      424      3     59 Block=P95 Latch=I2
Bit      428      3     55 Block=P96 Latch=OQ
Bit      434      3     49 Block=P97 Latch=I2
Bit      438      3     45 Block=P98 Latch=OQ
Bit      444      3     39 Block=P99 Latch=I2
Bit      448      3     35 Block=P101 Latch=OQ
Bit      454      3     29 Block=P102 Latch=I2
Bit      458      3     25 Block=P103 Latch=OQ
Bit      464      3     19 Block=P104 Latch=I2
Bit      468      3     15 Block=P105 Latch=OQ
Bit      474      3      9 Block=P106 Latch=I2
Bit      499      4    145 Block=P75 Latch=I2
Bit      504      4    140 Block=P76 Latch=OQ
Bit      509      4    135 Block=P77 Latch=I2
Bit      514      4    130 Block=P78 Latch=OQ
Bit      519      4    125 Block=P79 Latch=I2
Bit      524      4    120 Block=P80 Latch=OQ
Bit      529      4    115 Block=P82 Latch=I2
Bit      534      4    110 Block=P83 Latch=OQ
Bit      539      4    105 Block=P84 Latch=I2
Bit      544      4    100 Block=P85 Latch=OQ
Bit      549      4     95 Block=P86 Latch=I2
Bit      554      4     90 Block=P87 Latch=OQ
Bit      559      4     85 Block=P88 Latch=I2
Bit      564      4     80 Block=P89 Latch=OQ
Bit      570      4     74 Block=P92 Latch=I2
Bit      575      4     69 Block=P93 Latch=OQ
Bit      580      4     64 Block=P94 Latch=I2
Bit      585      4     59 Block=P95 Latch=OQ
Bit      590      4     54 Block=P96 Latch=I2
Bit      595      4     49 Block=P97 Latch=OQ
Bit      600      4     44 Block=P98 Latch=I2
Bit      605      4     39 Block=P99 Latch=OQ
Bit      610      4     34 Block=P101 Latch=I2
Bit      615      4     29 Block=P102 Latch=OQ
Bit      620      4     24 Block=P103 Latch=I2
Bit      625      4     19 Block=P104 Latch=OQ
Bit      630      4     14 Block=P105 Latch=I2
Bit      635      4      9 Block=P106 Latch=OQ
Bit      660      5    145 Block=P75 Latch=I1
Bit      670      5    135 Block=P77 Latch=I1
Bit      680      5    125 Block=P79 Latch=I1
Bit      690      5    115 Block=P82 Latch=I1
Bit      700      5    105 Block=P84 Latch=I1
Bit      710      5     95 Block=P86 Latch=I1
Bit      720      5     85 Block=P88 Latch=I1
Bit      731      5     74 Block=P92 Latch=I1
Bit      741      5     64 Block=P94 Latch=I1
Bit      751      5     54 Block=P96 Latch=I1
Bit      761      5     44 Block=P98 Latch=I1
Bit      771      5     34 Block=P101 Latch=I1
Bit      781      5     24 Block=P103 Latch=I1
Bit      791      5     14 Block=P105 Latch=I1
Bit     7102     45    143 Block=CLB_R14C14 Latch=Y
Bit     7112     45    133 Block=CLB_R13C14 Latch=Y
Bit     7122     45    123 Block=CLB_R12C14 Latch=Y
Bit     7132     45    113 Block=CLB_R11C14 Latch=Y
Bit     7142     45    103 Block=CLB_R10C14 Latch=Y
Bit     7152     45     93 Block=CLB_R9C14 Latch=Y
Bit     7162     45     83 Block=CLB_R8C14 Latch=Y
Bit     7173     45     72 Block=CLB_R7C14 Latch=Y
Bit     7183     45     62 Block=CLB_R6C14 Latch=Y
Bit     7193     45     52 Block=CLB_R5C14 Latch=Y
Bit     7203     45     42 Block=CLB_R4C14 Latch=Y
Bit     7213     45     32 Block=CLB_R3C14 Latch=Y
Bit     7223     45     22 Block=CLB_R2C14 Latch=Y
Bit     7233     45     12 Block=CLB_R1C14 Latch=Y
Bit     7906     50    144 Block=CLB_R14C14 Latch=YQ
Bit     7916     50    134 Block=CLB_R13C14 Latch=YQ
Bit     7926     50    124 Block=CLB_R12C14 Latch=YQ
Bit     7936     50    114 Block=CLB_R11C14 Latch=YQ
Bit     7946     50    104 Block=CLB_R10C14 Latch=YQ
Bit     7956     50     94 Block=CLB_R9C14 Latch=YQ
Bit     7966     50     84 Block=CLB_R8C14 Latch=YQ
Bit     7977     50     73 Block=CLB_R7C14 Latch=YQ
Bit     7987     50     63 Block=CLB_R6C14 Latch=YQ
Bit     7997     50     53 Block=CLB_R5C14 Latch=YQ
Bit     8007     50     43 Block=CLB_R4C14 Latch=YQ
Bit     8017     50     33 Block=CLB_R3C14 Latch=YQ
Bit     8027     50     23 Block=CLB_R2C14 Latch=YQ
Bit     8037     50     13 Block=CLB_R1C14 Latch=YQ
Bit     8551     54    143 Block=CLB_R14C14 Latch=XQ
Bit     8561     54    133 Block=CLB_R13C14 Latch=XQ
Bit     8571     54    123 Block=CLB_R12C14 Latch=XQ
Bit     8581     54    113 Block=CLB_R11C14 Latch=XQ
Bit     8591     54    103 Block=CLB_R10C14 Latch=XQ
Bit     8601     54     93 Block=CLB_R9C14 Latch=XQ
Bit     8611     54     83 Block=CLB_R8C14 Latch=XQ
Bit     8622     54     72 Block=CLB_R7C14 Latch=XQ
Bit     8632     54     62 Block=CLB_R6C14 Latch=XQ
Bit     8642     54     52 Block=CLB_R5C14 Latch=XQ
Bit     8652     54     42 Block=CLB_R4C14 Latch=XQ
Bit     8662     54     32 Block=CLB_R3C14 Latch=XQ
Bit     8672     54     22 Block=CLB_R2C14 Latch=XQ
Bit     8682     54     12 Block=CLB_R1C14 Latch=XQ
Bit     8857     56    159 Block=P69 Latch=OQ
Bit     9013     56      3 Block=P112 Latch=OQ
Bit     9018     57    159 Block=P70 Latch=OQ
Bit     9174     57      3 Block=P111 Latch=OQ
Bit     9179     58    159 Block=P70 Latch=I1
Bit     9194     58    144 Block=CLB_R14C14 Latch=X
Bit     9204     58    134 Block=CLB_R13C14 Latch=X
Bit     9214     58    124 Block=CLB_R12C14 Latch=X
Bit     9224     58    114 Block=CLB_R11C14 Latch=X
Bit     9234     58    104 Block=CLB_R10C14 Latch=X
Bit     9244     58     94 Block=CLB_R9C14 Latch=X
Bit     9254     58     84 Block=CLB_R8C14 Latch=X
Bit     9265     58     73 Block=CLB_R7C14 Latch=X
Bit     9275     58     63 Block=CLB_R6C14 Latch=X
Bit     9285     58     53 Block=CLB_R5C14 Latch=X
Bit     9295     58     43 Block=CLB_R4C14 Latch=X
Bit     9305     58     33 Block=CLB_R3C14 Latch=X
Bit     9315     58     23 Block=CLB_R2C14 Latch=X
Bit     9325     58     13 Block=CLB_R1C14 Latch=X
Bit     9335     58      3 Block=P111 Latch=I1
Bit     9341     59    158 Block=P70 Latch=I2
Bit     9495     59      4 Block=P111 Latch=I2
Bit     9501     60    159 Block=P69 Latch=I2
Bit     9502     60    158 Block=P69 Latch=I1
Bit     9656     60      4 Block=P112 Latch=I1
Bit     9657     60      3 Block=P112 Latch=I2
Bit    12898     81    143 Block=CLB_R14C13 Latch=Y
Bit    12908     81    133 Block=CLB_R13C13 Latch=Y
Bit    12918     81    123 Block=CLB_R12C13 Latch=Y
Bit    12928     81    113 Block=CLB_R11C13 Latch=Y
Bit    12938     81    103 Block=CLB_R10C13 Latch=Y
Bit    12948     81     93 Block=CLB_R9C13 Latch=Y
Bit    12958     81     83 Block=CLB_R8C13 Latch=Y
Bit    12969     81     72 Block=CLB_R7C13 Latch=Y
Bit    12979     81     62 Block=CLB_R6C13 Latch=Y
Bit    12989     81     52 Block=CLB_R5C13 Latch=Y
Bit    12999     81     42 Block=CLB_R4C13 Latch=Y
Bit    13009     81     32 Block=CLB_R3C13 Latch=Y
Bit    13019     81     22 Block=CLB_R2C13 Latch=Y
Bit    13029     81     12 Block=CLB_R1C13 Latch=Y
Bit    13702     86    144 Block=CLB_R14C13 Latch=YQ
Bit    13712     86    134 Block=CLB_R13C13 Latch=YQ
Bit    13722     86    124 Block=CLB_R12C13 Latch=YQ
Bit    13732     86    114 Block=CLB_R11C13 Latch=YQ
Bit    13742     86    104 Block=CLB_R10C13 Latch=YQ
Bit    13752     86     94 Block=CLB_R9C13 Latch=YQ
Bit    13762     86     84 Block=CLB_R8C13 Latch=YQ
Bit    13773     86     73 Block=CLB_R7C13 Latch=YQ
Bit    13783     86     63 Block=CLB_R6C13 Latch=YQ
Bit    13793     86     53 Block=CLB_R5C13 Latch=YQ
Bit    13803     86     43 Block=CLB_R4C13 Latch=YQ
Bit    13813     86     33 Block=CLB_R3C13 Latch=YQ
Bit    13823     86     23 Block=CLB_R2C13 Latch=YQ
Bit    13833     86     13 Block=CLB_R1C13 Latch=YQ
Bit    14347     90    143 Block=CLB_R14C13 Latch=XQ
Bit    14357     90    133 Block=CLB_R13C13 Latch=XQ
Bit    14367     90    123 Block=CLB_R12C13 Latch=XQ
Bit    14377     90    113 Block=CLB_R11C13 Latch=XQ
Bit    14387     90    103 Block=CLB_R10C13 Latch=XQ
Bit    14397     90     93 Block=CLB_R9C13 Latch=XQ
Bit    14407     90     83 Block=CLB_R8C13 Latch=XQ
Bit    14418     90     72 Block=CLB_R7C13 Latch=XQ
Bit    14428     90     62 Block=CLB_R6C13 Latch=XQ
Bit    14438     90     52 Block=CLB_R5C13 Latch=XQ
Bit    14448     90     42 Block=CLB_R4C13 Latch=XQ
Bit    14458     90     32 Block=CLB_R3C13 Latch=XQ
Bit    14468     90     22 Block=CLB_R2C13 Latch=XQ
Bit    14478     90     12 Block=CLB_R1C13 Latch=XQ
Bit    14653     92    159 Block=P67 Latch=OQ
Bit    14809     92      3 Block=P114 Latch=OQ
Bit    14814     93    159 Block=P68 Latch=OQ
Bit    14970     93      3 Block=P113 Latch=OQ
Bit    14975     94    159 Block=P68 Latch=I1
Bit    14990     94    144 Block=CLB_R14C13 Latch=X
Bit    15000     94    134 Block=CLB_R13C13 Latch=X
Bit    15010     94    124 Block=CLB_R12C13 Latch=X
Bit    15020     94    114 Block=CLB_R11C13 Latch=X
Bit    15030     94    104 Block=CLB_R10C13 Latch=X
Bit    15040     94     94 Block=CLB_R9C13 Latch=X
Bit    15050     94     84 Block=CLB_R8C13 Latch=X
Bit    15061     94     73 Block=CLB_R7C13 Latch=X
Bit    15071     94     63 Block=CLB_R6C13 Latch=X
Bit    15081     94     53 Block=CLB_R5C13 Latch=X
Bit    15091     94     43 Block=CLB_R4C13 Latch=X
Bit    15101     94     33 Block=CLB_R3C13 Latch=X
Bit    15111     94     23 Block=CLB_R2C13 Latch=X
Bit    15121     94     13 Block=CLB_R1C13 Latch=X
Bit    15131     94      3 Block=P113 Latch=I1
Bit    15137     95    158 Block=P68 Latch=I2
Bit    15291     95      4 Block=P113 Latch=I2
Bit    15297     96    159 Block=P67 Latch=I2
Bit    15298     96    158 Block=P67 Latch=I1
Bit    15452     96      4 Block=P114 Latch=I1
Bit    15453     96      3 Block=P114 Latch=I2
Bit    18694    117    143 Block=CLB_R14C12 Latch=Y
Bit    18704    117    133 Block=CLB_R13C12 Latch=Y
Bit    18714    117    123 Block=CLB_R12C12 Latch=Y
Bit    18724    117    113 Block=CLB_R11C12 Latch=Y
Bit    18734    117    103 Block=CLB_R10C12 Latch=Y
Bit    18744    117     93 Block=CLB_R9C12 Latch=Y
Bit    18754    117     83 Block=CLB_R8C12 Latch=Y
Bit    18765    117     72 Block=CLB_R7C12 Latch=Y
Bit    18775    117     62 Block=CLB_R6C12 Latch=Y
Bit    18785    117     52 Block=CLB_R5C12 Latch=Y
Bit    18795    117     42 Block=CLB_R4C12 Latch=Y
Bit    18805    117     32 Block=CLB_R3C12 Latch=Y
Bit    18815    117     22 Block=CLB_R2C12 Latch=Y
Bit    18825    117     12 Block=CLB_R1C12 Latch=Y
Bit    19498    122    144 Block=CLB_R14C12 Latch=YQ
Bit    19508    122    134 Block=CLB_R13C12 Latch=YQ
Bit    19518    122    124 Block=CLB_R12C12 Latch=YQ
Bit    19528    122    114 Block=CLB_R11C12 Latch=YQ
Bit    19538    122    104 Block=CLB_R10C12 Latch=YQ
Bit    19548    122     94 Block=CLB_R9C12 Latch=YQ
Bit    19558    122     84 Block=CLB_R8C12 Latch=YQ
Bit    19569    122     73 Block=CLB_R7C12 Latch=YQ
Bit    19579    122     63 Block=CLB_R6C12 Latch=YQ
Bit    19589    122     53 Block=CLB_R5C12 Latch=YQ
Bit    19599    122     43 Block=CLB_R4C12 Latch=YQ
Bit    19609    122     33 Block=CLB_R3C12 Latch=YQ
Bit    19619    122     23 Block=CLB_R2C12 Latch=YQ
Bit    19629    122     13 Block=CLB_R1C12 Latch=YQ
Bit    20143    126    143 Block=CLB_R14C12 Latch=XQ
Bit    20153    126    133 Block=CLB_R13C12 Latch=XQ
Bit    20163    126    123 Block=CLB_R12C12 Latch=XQ
Bit    20173    126    113 Block=CLB_R11C12 Latch=XQ
Bit    20183    126    103 Block=CLB_R10C12 Latch=XQ
Bit    20193    126     93 Block=CLB_R9C12 Latch=XQ
Bit    20203    126     83 Block=CLB_R8C12 Latch=XQ
Bit    20214    126     72 Block=CLB_R7C12 Latch=XQ
Bit    20224    126     62 Block=CLB_R6C12 Latch=XQ
Bit    20234    126     52 Block=CLB_R5C12 Latch=XQ
Bit    20244    126     42 Block=CLB_R4C12 Latch=XQ
Bit    20254    126     32 Block=CLB_R3C12 Latch=XQ
Bit    20264    126     22 Block=CLB_R2C12 Latch=XQ
Bit    20274    126     12 Block=CLB_R1C12 Latch=XQ
Bit    20449    128    159 Block=P65 Latch=OQ
Bit    20605    128      3 Block=P116 Latch=OQ
Bit    20610    129    159 Block=P66 Latch=OQ
Bit    20766    129      3 Block=P115 Latch=OQ
Bit    20771    130    159 Block=P66 Latch=I1
Bit    20786    130    144 Block=CLB_R14C12 Latch=X
Bit    20796    130    134 Block=CLB_R13C12 Latch=X
Bit    20806    130    124 Block=CLB_R12C12 Latch=X
Bit    20816    130    114 Block=CLB_R11C12 Latch=X
Bit    20826    130    104 Block=CLB_R10C12 Latch=X
Bit    20836    130     94 Block=CLB_R9C12 Latch=X
Bit    20846    130     84 Block=CLB_R8C12 Latch=X
Bit    20857    130     73 Block=CLB_R7C12 Latch=X
Bit    20867    130     63 Block=CLB_R6C12 Latch=X
Bit    20877    130     53 Block=CLB_R5C12 Latch=X
Bit    20887    130     43 Block=CLB_R4C12 Latch=X
Bit    20897    130     33 Block=CLB_R3C12 Latch=X
Bit    20907    130     23 Block=CLB_R2C12 Latch=X
Bit    20917    130     13 Block=CLB_R1C12 Latch=X
Bit    20927    130      3 Block=P115 Latch=I1
Bit    20933    131    158 Block=P66 Latch=I2
Bit    21087    131      4 Block=P115 Latch=I2
Bit    21093    132    159 Block=P65 Latch=I2
Bit    21094    132    158 Block=P65 Latch=I1
Bit    21248    132      4 Block=P116 Latch=I1
Bit    21249    132      3 Block=P116 Latch=I2
Bit    24490    153    143 Block=CLB_R14C11 Latch=Y
Bit    24500    153    133 Block=CLB_R13C11 Latch=Y
Bit    24510    153    123 Block=CLB_R12C11 Latch=Y
Bit    24520    153    113 Block=CLB_R11C11 Latch=Y
Bit    24530    153    103 Block=CLB_R10C11 Latch=Y
Bit    24540    153     93 Block=CLB_R9C11 Latch=Y
Bit    24550    153     83 Block=CLB_R8C11 Latch=Y
Bit    24561    153     72 Block=CLB_R7C11 Latch=Y
Bit    24571    153     62 Block=CLB_R6C11 Latch=Y
Bit    24581    153     52 Block=CLB_R5C11 Latch=Y
Bit    24591    153     42 Block=CLB_R4C11 Latch=Y
Bit    24601    153     32 Block=CLB_R3C11 Latch=Y
Bit    24611    153     22 Block=CLB_R2C11 Latch=Y
Bit    24621    153     12 Block=CLB_R1C11 Latch=Y
Bit    25294    158    144 Block=CLB_R14C11 Latch=YQ
Bit    25304    158    134 Block=CLB_R13C11 Latch=YQ
Bit    25314    158    124 Block=CLB_R12C11 Latch=YQ
Bit    25324    158    114 Block=CLB_R11C11 Latch=YQ
Bit    25334    158    104 Block=CLB_R10C11 Latch=YQ
Bit    25344    158     94 Block=CLB_R9C11 Latch=YQ Net=Uart_Txrate/Cnt<1>
Bit    25354    158     84 Block=CLB_R8C11 Latch=YQ
Bit    25365    158     73 Block=CLB_R7C11 Latch=YQ
Bit    25375    158     63 Block=CLB_R6C11 Latch=YQ
Bit    25385    158     53 Block=CLB_R5C11 Latch=YQ
Bit    25395    158     43 Block=CLB_R4C11 Latch=YQ
Bit    25405    158     33 Block=CLB_R3C11 Latch=YQ
Bit    25415    158     23 Block=CLB_R2C11 Latch=YQ
Bit    25425    158     13 Block=CLB_R1C11 Latch=YQ
Bit    25939    162    143 Block=CLB_R14C11 Latch=XQ
Bit    25949    162    133 Block=CLB_R13C11 Latch=XQ
Bit    25959    162    123 Block=CLB_R12C11 Latch=XQ
Bit    25969    162    113 Block=CLB_R11C11 Latch=XQ
Bit    25979    162    103 Block=CLB_R10C11 Latch=XQ
Bit    25989    162     93 Block=CLB_R9C11 Latch=XQ Net=Uart_Txrate/Cnt<0>
Bit    25999    162     83 Block=CLB_R8C11 Latch=XQ Net=EnabTx
Bit    26010    162     72 Block=CLB_R7C11 Latch=XQ
Bit    26020    162     62 Block=CLB_R6C11 Latch=XQ
Bit    26030    162     52 Block=CLB_R5C11 Latch=XQ
Bit    26040    162     42 Block=CLB_R4C11 Latch=XQ
Bit    26050    162     32 Block=CLB_R3C11 Latch=XQ
Bit    26060    162     22 Block=CLB_R2C11 Latch=XQ
Bit    26070    162     12 Block=CLB_R1C11 Latch=XQ
Bit    26245    164    159 Block=P62 Latch=OQ
Bit    26401    164      3 Block=P120 Latch=OQ
Bit    26406    165    159 Block=P63 Latch=OQ
Bit    26562    165      3 Block=P119 Latch=OQ
Bit    26567    166    159 Block=P63 Latch=I1
Bit    26582    166    144 Block=CLB_R14C11 Latch=X
Bit    26592    166    134 Block=CLB_R13C11 Latch=X
Bit    26602    166    124 Block=CLB_R12C11 Latch=X
Bit    26612    166    114 Block=CLB_R11C11 Latch=X
Bit    26622    166    104 Block=CLB_R10C11 Latch=X
Bit    26632    166     94 Block=CLB_R9C11 Latch=X
Bit    26642    166     84 Block=CLB_R8C11 Latch=X
Bit    26653    166     73 Block=CLB_R7C11 Latch=X
Bit    26663    166     63 Block=CLB_R6C11 Latch=X
Bit    26673    166     53 Block=CLB_R5C11 Latch=X
Bit    26683    166     43 Block=CLB_R4C11 Latch=X
Bit    26693    166     33 Block=CLB_R3C11 Latch=X
Bit    26703    166     23 Block=CLB_R2C11 Latch=X
Bit    26713    166     13 Block=CLB_R1C11 Latch=X
Bit    26723    166      3 Block=P119 Latch=I1
Bit    26729    167    158 Block=P63 Latch=I2
Bit    26883    167      4 Block=P119 Latch=I2 Net=N_WB_STB_I
Bit    26889    168    159 Block=P62 Latch=I2
Bit    26890    168    158 Block=P62 Latch=I1
Bit    27044    168      4 Block=P120 Latch=I1
Bit    27045    168      3 Block=P120 Latch=I2
Bit    30286    189    143 Block=CLB_R14C10 Latch=Y Net=C7/N11
Bit    30296    189    133 Block=CLB_R13C10 Latch=Y
Bit    30306    189    123 Block=CLB_R12C10 Latch=Y
Bit    30316    189    113 Block=CLB_R11C10 Latch=Y
Bit    30326    189    103 Block=CLB_R10C10 Latch=Y
Bit    30336    189     93 Block=CLB_R9C10 Latch=Y
Bit    30346    189     83 Block=CLB_R8C10 Latch=Y
Bit    30357    189     72 Block=CLB_R7C10 Latch=Y
Bit    30367    189     62 Block=CLB_R6C10 Latch=Y
Bit    30377    189     52 Block=CLB_R5C10 Latch=Y
Bit    30387    189     42 Block=CLB_R4C10 Latch=Y
Bit    30397    189     32 Block=CLB_R3C10 Latch=Y
Bit    30407    189     22 Block=CLB_R2C10 Latch=Y
Bit    30417    189     12 Block=CLB_R1C10 Latch=Y
Bit    31090    194    144 Block=CLB_R14C10 Latch=YQ Net=RxData<7>
Bit    31100    194    134 Block=CLB_R13C10 Latch=YQ
Bit    31110    194    124 Block=CLB_R12C10 Latch=YQ
Bit    31120    194    114 Block=CLB_R11C10 Latch=YQ
Bit    31130    194    104 Block=CLB_R10C10 Latch=YQ
Bit    31140    194     94 Block=CLB_R9C10 Latch=YQ
Bit    31150    194     84 Block=CLB_R8C10 Latch=YQ
Bit    31161    194     73 Block=CLB_R7C10 Latch=YQ
Bit    31171    194     63 Block=CLB_R6C10 Latch=YQ
Bit    31181    194     53 Block=CLB_R5C10 Latch=YQ
Bit    31191    194     43 Block=CLB_R4C10 Latch=YQ
Bit    31201    194     33 Block=CLB_R3C10 Latch=YQ
Bit    31211    194     23 Block=CLB_R2C10 Latch=YQ
Bit    31221    194     13 Block=CLB_R1C10 Latch=YQ
Bit    31735    198    143 Block=CLB_R14C10 Latch=XQ Net=RxData<6>
Bit    31745    198    133 Block=CLB_R13C10 Latch=XQ
Bit    31755    198    123 Block=CLB_R12C10 Latch=XQ
Bit    31765    198    113 Block=CLB_R11C10 Latch=XQ
Bit    31775    198    103 Block=CLB_R10C10 Latch=XQ
Bit    31785    198     93 Block=CLB_R9C10 Latch=XQ
Bit    31795    198     83 Block=CLB_R8C10 Latch=XQ
Bit    31806    198     72 Block=CLB_R7C10 Latch=XQ
Bit    31816    198     62 Block=CLB_R6C10 Latch=XQ
Bit    31826    198     52 Block=CLB_R5C10 Latch=XQ
Bit    31836    198     42 Block=CLB_R4C10 Latch=XQ
Bit    31846    198     32 Block=CLB_R3C10 Latch=XQ
Bit    31856    198     22 Block=CLB_R2C10 Latch=XQ
Bit    31866    198     12 Block=CLB_R1C10 Latch=XQ Net=N299
Bit    32041    200    159 Block=P60 Latch=OQ
Bit    32197    200      3 Block=P122 Latch=OQ
Bit    32202    201    159 Block=P61 Latch=OQ
Bit    32358    201      3 Block=P121 Latch=OQ
Bit    32363    202    159 Block=P61 Latch=I1
Bit    32378    202    144 Block=CLB_R14C10 Latch=X Net=C7/N29
Bit    32388    202    134 Block=CLB_R13C10 Latch=X
Bit    32398    202    124 Block=CLB_R12C10 Latch=X
Bit    32408    202    114 Block=CLB_R11C10 Latch=X
Bit    32418    202    104 Block=CLB_R10C10 Latch=X
Bit    32428    202     94 Block=CLB_R9C10 Latch=X
Bit    32438    202     84 Block=CLB_R8C10 Latch=X
Bit    32449    202     73 Block=CLB_R7C10 Latch=X
Bit    32459    202     63 Block=CLB_R6C10 Latch=X
Bit    32469    202     53 Block=CLB_R5C10 Latch=X
Bit    32479    202     43 Block=CLB_R4C10 Latch=X
Bit    32489    202     33 Block=CLB_R3C10 Latch=X
Bit    32499    202     23 Block=CLB_R2C10 Latch=X
Bit    32509    202     13 Block=CLB_R1C10 Latch=X Net=C5/N5
Bit    32519    202      3 Block=P121 Latch=I1
Bit    32525    203    158 Block=P61 Latch=I2
Bit    32679    203      4 Block=P121 Latch=I2
Bit    32685    204    159 Block=P60 Latch=I2
Bit    32686    204    158 Block=P60 Latch=I1
Bit    32840    204      4 Block=P122 Latch=I1
Bit    32841    204      3 Block=P122 Latch=I2 Net=N_WB_WE_I
Bit    36082    225    143 Block=CLB_R14C9 Latch=Y Net=C7/N4
Bit    36092    225    133 Block=CLB_R13C9 Latch=Y Net=C7/N17
Bit    36102    225    123 Block=CLB_R12C9 Latch=Y
Bit    36112    225    113 Block=CLB_R11C9 Latch=Y Net=syn862
Bit    36122    225    103 Block=CLB_R10C9 Latch=Y
Bit    36132    225     93 Block=CLB_R9C9 Latch=Y
Bit    36142    225     83 Block=CLB_R8C9 Latch=Y
Bit    36153    225     72 Block=CLB_R7C9 Latch=Y
Bit    36163    225     62 Block=CLB_R6C9 Latch=Y
Bit    36173    225     52 Block=CLB_R5C9 Latch=Y
Bit    36183    225     42 Block=CLB_R4C9 Latch=Y
Bit    36193    225     32 Block=CLB_R3C9 Latch=Y
Bit    36203    225     22 Block=CLB_R2C9 Latch=Y
Bit    36213    225     12 Block=CLB_R1C9 Latch=Y
Bit    36886    230    144 Block=CLB_R14C9 Latch=YQ Net=RxData<2>
Bit    36896    230    134 Block=CLB_R13C9 Latch=YQ Net=RxData<5>
Bit    36906    230    124 Block=CLB_R12C9 Latch=YQ Net=Uart_RxUnit/RReg<5>
Bit    36916    230    114 Block=CLB_R11C9 Latch=YQ
Bit    36926    230    104 Block=CLB_R10C9 Latch=YQ
Bit    36936    230     94 Block=CLB_R9C9 Latch=YQ
Bit    36946    230     84 Block=CLB_R8C9 Latch=YQ
Bit    36957    230     73 Block=CLB_R7C9 Latch=YQ
Bit    36967    230     63 Block=CLB_R6C9 Latch=YQ
Bit    36977    230     53 Block=CLB_R5C9 Latch=YQ
Bit    36987    230     43 Block=CLB_R4C9 Latch=YQ
Bit    36997    230     33 Block=CLB_R3C9 Latch=YQ
Bit    37007    230     23 Block=CLB_R2C9 Latch=YQ
Bit    37017    230     13 Block=CLB_R1C9 Latch=YQ
Bit    37531    234    143 Block=CLB_R14C9 Latch=XQ Net=RxData<3>
Bit    37541    234    133 Block=CLB_R13C9 Latch=XQ Net=RxData<4>
Bit    37551    234    123 Block=CLB_R12C9 Latch=XQ Net=Uart_RxUnit/RReg<4>
Bit    37561    234    113 Block=CLB_R11C9 Latch=XQ
Bit    37571    234    103 Block=CLB_R10C9 Latch=XQ
Bit    37581    234     93 Block=CLB_R9C9 Latch=XQ Net=N298
Bit    37591    234     83 Block=CLB_R8C9 Latch=XQ
Bit    37602    234     72 Block=CLB_R7C9 Latch=XQ
Bit    37612    234     62 Block=CLB_R6C9 Latch=XQ
Bit    37622    234     52 Block=CLB_R5C9 Latch=XQ
Bit    37632    234     42 Block=CLB_R4C9 Latch=XQ
Bit    37642    234     32 Block=CLB_R3C9 Latch=XQ
Bit    37652    234     22 Block=CLB_R2C9 Latch=XQ Net=ReadA
Bit    37662    234     12 Block=CLB_R1C9 Latch=XQ
Bit    37837    236    159 Block=P58 Latch=OQ
Bit    37993    236      3 Block=P124 Latch=OQ
Bit    37998    237    159 Block=P59 Latch=OQ
Bit    38154    237      3 Block=P123 Latch=OQ
Bit    38159    238    159 Block=P59 Latch=I1
Bit    38174    238    144 Block=CLB_R14C9 Latch=X Net=C7/N35
Bit    38184    238    134 Block=CLB_R13C9 Latch=X Net=C7/N23
Bit    38194    238    124 Block=CLB_R12C9 Latch=X
Bit    38204    238    114 Block=CLB_R11C9 Latch=X Net=syn903
Bit    38214    238    104 Block=CLB_R10C9 Latch=X Net=syn1336
Bit    38224    238     94 Block=CLB_R9C9 Latch=X
Bit    38234    238     84 Block=CLB_R8C9 Latch=X
Bit    38245    238     73 Block=CLB_R7C9 Latch=X
Bit    38255    238     63 Block=CLB_R6C9 Latch=X
Bit    38265    238     53 Block=CLB_R5C9 Latch=X
Bit    38275    238     43 Block=CLB_R4C9 Latch=X
Bit    38285    238     33 Block=CLB_R3C9 Latch=X
Bit    38295    238     23 Block=CLB_R2C9 Latch=X Net=Uart_RxUnit/n558
Bit    38305    238     13 Block=CLB_R1C9 Latch=X
Bit    38315    238      3 Block=P123 Latch=I1
Bit    38321    239    158 Block=P59 Latch=I2
Bit    38475    239      4 Block=P123 Latch=I2
Bit    38481    240    159 Block=P58 Latch=I2
Bit    38482    240    158 Block=P58 Latch=I1
Bit    38636    240      4 Block=P124 Latch=I1
Bit    38637    240      3 Block=P124 Latch=I2 Net=N_WB_RST_I
Bit    41878    261    143 Block=CLB_R14C8 Latch=Y
Bit    41888    261    133 Block=CLB_R13C8 Latch=Y
Bit    41898    261    123 Block=CLB_R12C8 Latch=Y
Bit    41908    261    113 Block=CLB_R11C8 Latch=Y Net=syn883
Bit    41918    261    103 Block=CLB_R10C8 Latch=Y Net=syn854
Bit    41928    261     93 Block=CLB_R9C8 Latch=Y
Bit    41938    261     83 Block=CLB_R8C8 Latch=Y
Bit    41949    261     72 Block=CLB_R7C8 Latch=Y
Bit    41959    261     62 Block=CLB_R6C8 Latch=Y
Bit    41969    261     52 Block=CLB_R5C8 Latch=Y
Bit    41979    261     42 Block=CLB_R4C8 Latch=Y
Bit    41989    261     32 Block=CLB_R3C8 Latch=Y
Bit    41999    261     22 Block=CLB_R2C8 Latch=Y
Bit    42009    261     12 Block=CLB_R1C8 Latch=Y
Bit    42682    266    144 Block=CLB_R14C8 Latch=YQ Net=Uart_RxUnit/RReg<3>
Bit    42692    266    134 Block=CLB_R13C8 Latch=YQ Net=Uart_RxUnit/RReg<7>
Bit    42702    266    124 Block=CLB_R12C8 Latch=YQ Net=Uart_RxUnit/RReg<1>
Bit    42712    266    114 Block=CLB_R11C8 Latch=YQ
Bit    42722    266    104 Block=CLB_R10C8 Latch=YQ
Bit    42732    266     94 Block=CLB_R9C8 Latch=YQ Net=Uart_RxUnit/BitPos<2>
Bit    42742    266     84 Block=CLB_R8C8 Latch=YQ
Bit    42753    266     73 Block=CLB_R7C8 Latch=YQ
Bit    42763    266     63 Block=CLB_R6C8 Latch=YQ
Bit    42773    266     53 Block=CLB_R5C8 Latch=YQ
Bit    42783    266     43 Block=CLB_R4C8 Latch=YQ
Bit    42793    266     33 Block=CLB_R3C8 Latch=YQ
Bit    42803    266     23 Block=CLB_R2C8 Latch=YQ
Bit    42813    266     13 Block=CLB_R1C8 Latch=YQ
Bit    43327    270    143 Block=CLB_R14C8 Latch=XQ Net=Uart_RxUnit/RReg<2>
Bit    43337    270    133 Block=CLB_R13C8 Latch=XQ Net=Uart_RxUnit/RReg<6>
Bit    43347    270    123 Block=CLB_R12C8 Latch=XQ Net=Uart_RxUnit/RReg<0>
Bit    43357    270    113 Block=CLB_R11C8 Latch=XQ
Bit    43367    270    103 Block=CLB_R10C8 Latch=XQ Net=Uart_RxUnit/BitPos<0>
Bit    43377    270     93 Block=CLB_R9C8 Latch=XQ Net=Uart_RxUnit/BitPos<1>
Bit    43387    270     83 Block=CLB_R8C8 Latch=XQ
Bit    43398    270     72 Block=CLB_R7C8 Latch=XQ
Bit    43408    270     62 Block=CLB_R6C8 Latch=XQ
Bit    43418    270     52 Block=CLB_R5C8 Latch=XQ
Bit    43428    270     42 Block=CLB_R4C8 Latch=XQ
Bit    43438    270     32 Block=CLB_R3C8 Latch=XQ
Bit    43448    270     22 Block=CLB_R2C8 Latch=XQ
Bit    43458    270     12 Block=CLB_R1C8 Latch=XQ
Bit    43633    272    159 Block=P56 Latch=OQ
Bit    43789    272      3 Block=P126 Latch=OQ
Bit    43794    273    159 Block=P57 Latch=OQ
Bit    43950    273      3 Block=P125 Latch=OQ
Bit    43955    274    159 Block=P57 Latch=I1
Bit    43970    274    144 Block=CLB_R14C8 Latch=X
Bit    43980    274    134 Block=CLB_R13C8 Latch=X
Bit    43990    274    124 Block=CLB_R12C8 Latch=X
Bit    44000    274    114 Block=CLB_R11C8 Latch=X Net=syn893
Bit    44010    274    104 Block=CLB_R10C8 Latch=X Net=Uart_RxUnit/C315
Bit    44020    274     94 Block=CLB_R9C8 Latch=X
Bit    44030    274     84 Block=CLB_R8C8 Latch=X
Bit    44041    274     73 Block=CLB_R7C8 Latch=X
Bit    44051    274     63 Block=CLB_R6C8 Latch=X
Bit    44061    274     53 Block=CLB_R5C8 Latch=X
Bit    44071    274     43 Block=CLB_R4C8 Latch=X
Bit    44081    274     33 Block=CLB_R3C8 Latch=X
Bit    44091    274     23 Block=CLB_R2C8 Latch=X
Bit    44101    274     13 Block=CLB_R1C8 Latch=X
Bit    44111    274      3 Block=P125 Latch=I1
Bit    44117    275    158 Block=P57 Latch=I2
Bit    44271    275      4 Block=P125 Latch=I2
Bit    44277    276    159 Block=P56 Latch=I2
Bit    44278    276    158 Block=P56 Latch=I1 Net=N_RxD_PAD_I
Bit    44432    276      4 Block=P126 Latch=I1
Bit    44433    276      3 Block=P126 Latch=I2
Bit    47835    298    143 Block=CLB_R14C7 Latch=Y Net=C7/N45
Bit    47845    298    133 Block=CLB_R13C7 Latch=Y
Bit    47855    298    123 Block=CLB_R12C7 Latch=Y
Bit    47865    298    113 Block=CLB_R11C7 Latch=Y
Bit    47875    298    103 Block=CLB_R10C7 Latch=Y Net=syn944
Bit    47885    298     93 Block=CLB_R9C7 Latch=Y Net=Uart_RxUnit/C13/N3
Bit    47895    298     83 Block=CLB_R8C7 Latch=Y
Bit    47906    298     72 Block=CLB_R7C7 Latch=Y
Bit    47916    298     62 Block=CLB_R6C7 Latch=Y
Bit    47926    298     52 Block=CLB_R5C7 Latch=Y
Bit    47936    298     42 Block=CLB_R4C7 Latch=Y
Bit    47946    298     32 Block=CLB_R3C7 Latch=Y
Bit    47956    298     22 Block=CLB_R2C7 Latch=Y
Bit    47966    298     12 Block=CLB_R1C7 Latch=Y
Bit    48639    303    144 Block=CLB_R14C7 Latch=YQ Net=N_IntRx_O
Bit    48649    303    134 Block=CLB_R13C7 Latch=YQ Net=RxData<1>
Bit    48659    303    124 Block=CLB_R12C7 Latch=YQ
Bit    48669    303    114 Block=CLB_R11C7 Latch=YQ
Bit    48679    303    104 Block=CLB_R10C7 Latch=YQ
Bit    48689    303     94 Block=CLB_R9C7 Latch=YQ
Bit    48699    303     84 Block=CLB_R8C7 Latch=YQ Net=Uart_RxUnit/SampleCnt<1>
Bit    48710    303     73 Block=CLB_R7C7 Latch=YQ
Bit    48720    303     63 Block=CLB_R6C7 Latch=YQ
Bit    48730    303     53 Block=CLB_R5C7 Latch=YQ
Bit    48740    303     43 Block=CLB_R4C7 Latch=YQ
Bit    48750    303     33 Block=CLB_R3C7 Latch=YQ
Bit    48760    303     23 Block=CLB_R2C7 Latch=YQ
Bit    48770    303     13 Block=CLB_R1C7 Latch=YQ
Bit    49284    307    143 Block=CLB_R14C7 Latch=XQ
Bit    49294    307    133 Block=CLB_R13C7 Latch=XQ Net=RxData<0>
Bit    49304    307    123 Block=CLB_R12C7 Latch=XQ
Bit    49314    307    113 Block=CLB_R11C7 Latch=XQ Net=Uart_RxUnit/BitPos<3>
Bit    49324    307    103 Block=CLB_R10C7 Latch=XQ
Bit    49334    307     93 Block=CLB_R9C7 Latch=XQ
Bit    49344    307     83 Block=CLB_R8C7 Latch=XQ Net=Uart_RxUnit/SampleCnt<0>
Bit    49355    307     72 Block=CLB_R7C7 Latch=XQ
Bit    49365    307     62 Block=CLB_R6C7 Latch=XQ
Bit    49375    307     52 Block=CLB_R5C7 Latch=XQ
Bit    49385    307     42 Block=CLB_R4C7 Latch=XQ
Bit    49395    307     32 Block=CLB_R3C7 Latch=XQ
Bit    49405    307     22 Block=CLB_R2C7 Latch=XQ
Bit    49415    307     12 Block=CLB_R1C7 Latch=XQ
Bit    49590    309    159 Block=P52 Latch=OQ
Bit    49746    309      3 Block=P130 Latch=OQ
Bit    49751    310    159 Block=P53 Latch=OQ
Bit    49907    310      3 Block=P129 Latch=OQ
Bit    49912    311    159 Block=P53 Latch=I1
Bit    49927    311    144 Block=CLB_R14C7 Latch=X Net=C37
Bit    49937    311    134 Block=CLB_R13C7 Latch=X Net=C7/N52
Bit    49947    311    124 Block=CLB_R12C7 Latch=X
Bit    49957    311    114 Block=CLB_R11C7 Latch=X Net=syn878
Bit    49967    311    104 Block=CLB_R10C7 Latch=X Net=syn1466
Bit    49977    311     94 Block=CLB_R9C7 Latch=X Net=Uart_RxUnit/C15/N19
Bit    49987    311     84 Block=CLB_R8C7 Latch=X
Bit    49998    311     73 Block=CLB_R7C7 Latch=X
Bit    50008    311     63 Block=CLB_R6C7 Latch=X
Bit    50018    311     53 Block=CLB_R5C7 Latch=X
Bit    50028    311     43 Block=CLB_R4C7 Latch=X
Bit    50038    311     33 Block=CLB_R3C7 Latch=X
Bit    50048    311     23 Block=CLB_R2C7 Latch=X
Bit    50058    311     13 Block=CLB_R1C7 Latch=X
Bit    50068    311      3 Block=P129 Latch=I1
Bit    50074    312    158 Block=P53 Latch=I2 Net=N_WB_ADR_I<0>
Bit    50228    312      4 Block=P129 Latch=I2
Bit    50234    313    159 Block=P52 Latch=I2
Bit    50235    313    158 Block=P52 Latch=I1 Net=N_WB_ADR_I<1>
Bit    50389    313      4 Block=P130 Latch=I1
Bit    50390    313      3 Block=P130 Latch=I2 Net=TxData<7>
Bit    53631    334    143 Block=CLB_R14C6 Latch=Y
Bit    53641    334    133 Block=CLB_R13C6 Latch=Y
Bit    53651    334    123 Block=CLB_R12C6 Latch=Y
Bit    53661    334    113 Block=CLB_R11C6 Latch=Y
Bit    53671    334    103 Block=CLB_R10C6 Latch=Y
Bit    53681    334     93 Block=CLB_R9C6 Latch=Y
Bit    53691    334     83 Block=CLB_R8C6 Latch=Y Net=Uart_RxUnit/C11/N5
Bit    53702    334     72 Block=CLB_R7C6 Latch=Y
Bit    53712    334     62 Block=CLB_R6C6 Latch=Y Net=syn755
Bit    53722    334     52 Block=CLB_R5C6 Latch=Y
Bit    53732    334     42 Block=CLB_R4C6 Latch=Y
Bit    53742    334     32 Block=CLB_R3C6 Latch=Y
Bit    53752    334     22 Block=CLB_R2C6 Latch=Y
Bit    53762    334     12 Block=CLB_R1C6 Latch=Y
Bit    54435    339    144 Block=CLB_R14C6 Latch=YQ
Bit    54445    339    134 Block=CLB_R13C6 Latch=YQ
Bit    54455    339    124 Block=CLB_R12C6 Latch=YQ
Bit    54465    339    114 Block=CLB_R11C6 Latch=YQ
Bit    54475    339    104 Block=CLB_R10C6 Latch=YQ Net=Uart_TxUnit/SyncLoad/C1A
Bit    54485    339     94 Block=CLB_R9C6 Latch=YQ
Bit    54495    339     84 Block=CLB_R8C6 Latch=YQ
Bit    54506    339     73 Block=CLB_R7C6 Latch=YQ Net=Uart_TxUnit/BitPos<3>
Bit    54516    339     63 Block=CLB_R6C6 Latch=YQ Net=Uart_TxUnit/TReg<3>
Bit    54526    339     53 Block=CLB_R5C6 Latch=YQ Net=Uart_TxUnit/TReg<6>
Bit    54536    339     43 Block=CLB_R4C6 Latch=YQ Net=Uart_TxUnit/TBuff<7>
Bit    54546    339     33 Block=CLB_R3C6 Latch=YQ Net=Uart_TxUnit/TBuff<2>
Bit    54556    339     23 Block=CLB_R2C6 Latch=YQ
Bit    54566    339     13 Block=CLB_R1C6 Latch=YQ
Bit    55080    343    143 Block=CLB_R14C6 Latch=XQ
Bit    55090    343    133 Block=CLB_R13C6 Latch=XQ
Bit    55100    343    123 Block=CLB_R12C6 Latch=XQ
Bit    55110    343    113 Block=CLB_R11C6 Latch=XQ
Bit    55120    343    103 Block=CLB_R10C6 Latch=XQ
Bit    55130    343     93 Block=CLB_R9C6 Latch=XQ
Bit    55140    343     83 Block=CLB_R8C6 Latch=XQ
Bit    55151    343     72 Block=CLB_R7C6 Latch=XQ Net=Uart_TxUnit/BitPos<2>
Bit    55161    343     62 Block=CLB_R6C6 Latch=XQ Net=Uart_TxUnit/TReg<2>
Bit    55171    343     52 Block=CLB_R5C6 Latch=XQ Net=Uart_TxUnit/TReg<7>
Bit    55181    343     42 Block=CLB_R4C6 Latch=XQ Net=Uart_TxUnit/TBuff<6>
Bit    55191    343     32 Block=CLB_R3C6 Latch=XQ Net=Uart_TxUnit/TBuff<3>
Bit    55201    343     22 Block=CLB_R2C6 Latch=XQ
Bit    55211    343     12 Block=CLB_R1C6 Latch=XQ
Bit    55386    345    159 Block=P50 Latch=OQ
Bit    55542    345      3 Block=P132 Latch=OQ
Bit    55547    346    159 Block=P51 Latch=OQ
Bit    55703    346      3 Block=P131 Latch=OQ
Bit    55708    347    159 Block=P51 Latch=I1
Bit    55723    347    144 Block=CLB_R14C6 Latch=X
Bit    55733    347    134 Block=CLB_R13C6 Latch=X
Bit    55743    347    124 Block=CLB_R12C6 Latch=X
Bit    55753    347    114 Block=CLB_R11C6 Latch=X
Bit    55763    347    104 Block=CLB_R10C6 Latch=X
Bit    55773    347     94 Block=CLB_R9C6 Latch=X Net=Uart_RxUnit/C12/N5
Bit    55783    347     84 Block=CLB_R8C6 Latch=X Net=Uart_RxUnit/C10/N10
Bit    55794    347     73 Block=CLB_R7C6 Latch=X
Bit    55804    347     63 Block=CLB_R6C6 Latch=X Net=syn1134
Bit    55814    347     53 Block=CLB_R5C6 Latch=X
Bit    55824    347     43 Block=CLB_R4C6 Latch=X
Bit    55834    347     33 Block=CLB_R3C6 Latch=X
Bit    55844    347     23 Block=CLB_R2C6 Latch=X
Bit    55854    347     13 Block=CLB_R1C6 Latch=X
Bit    55864    347      3 Block=P131 Latch=I1
Bit    55870    348    158 Block=P51 Latch=I2
Bit    56024    348      4 Block=P131 Latch=I2 Net=TxData<2>
Bit    56030    349    159 Block=P50 Latch=I2
Bit    56031    349    158 Block=P50 Latch=I1
Bit    56185    349      4 Block=P132 Latch=I1
Bit    56186    349      3 Block=P132 Latch=I2 Net=TxData<3>
Bit    59427    370    143 Block=CLB_R14C5 Latch=Y
Bit    59437    370    133 Block=CLB_R13C5 Latch=Y
Bit    59447    370    123 Block=CLB_R12C5 Latch=Y
Bit    59457    370    113 Block=CLB_R11C5 Latch=Y
Bit    59467    370    103 Block=CLB_R10C5 Latch=Y Net=N296
Bit    59477    370     93 Block=CLB_R9C5 Latch=Y Net=Uart_TxUnit/C11/N6
Bit    59487    370     83 Block=CLB_R8C5 Latch=Y Net=Uart_TxUnit/C14/N19
Bit    59498    370     72 Block=CLB_R7C5 Latch=Y
Bit    59508    370     62 Block=CLB_R6C5 Latch=Y
Bit    59518    370     52 Block=CLB_R5C5 Latch=Y
Bit    59528    370     42 Block=CLB_R4C5 Latch=Y
Bit    59538    370     32 Block=CLB_R3C5 Latch=Y Net=Uart_Rxrate/C64
Bit    59548    370     22 Block=CLB_R2C5 Latch=Y
Bit    59558    370     12 Block=CLB_R1C5 Latch=Y
Bit    60231    375    144 Block=CLB_R14C5 Latch=YQ
Bit    60241    375    134 Block=CLB_R13C5 Latch=YQ
Bit    60251    375    124 Block=CLB_R12C5 Latch=YQ
Bit    60261    375    114 Block=CLB_R11C5 Latch=YQ
Bit    60271    375    104 Block=CLB_R10C5 Latch=YQ Net=Uart_TxUnit/SyncLoad/R
Bit    60281    375     94 Block=CLB_R9C5 Latch=YQ
Bit    60291    375     84 Block=CLB_R8C5 Latch=YQ
Bit    60302    375     73 Block=CLB_R7C5 Latch=YQ Net=Uart_TxUnit/BitPos<1>
Bit    60312    375     63 Block=CLB_R6C5 Latch=YQ
Bit    60322    375     53 Block=CLB_R5C5 Latch=YQ
Bit    60332    375     43 Block=CLB_R4C5 Latch=YQ Net=Uart_TxUnit/TReg<1>
Bit    60342    375     33 Block=CLB_R3C5 Latch=YQ Net=EnabRx
Bit    60352    375     23 Block=CLB_R2C5 Latch=YQ Net=Uart_Rxrate/Cnt<6>
Bit    60362    375     13 Block=CLB_R1C5 Latch=YQ Net=Uart_Rxrate/Cnt<4>
Bit    60876    379    143 Block=CLB_R14C5 Latch=XQ
Bit    60886    379    133 Block=CLB_R13C5 Latch=XQ
Bit    60896    379    123 Block=CLB_R12C5 Latch=XQ
Bit    60906    379    113 Block=CLB_R11C5 Latch=XQ
Bit    60916    379    103 Block=CLB_R10C5 Latch=XQ Net=Uart_TxUnit/LoadS
Bit    60926    379     93 Block=CLB_R9C5 Latch=XQ
Bit    60936    379     83 Block=CLB_R8C5 Latch=XQ Net=Uart_TxUnit/TBufL
Bit    60947    379     72 Block=CLB_R7C5 Latch=XQ Net=Uart_TxUnit/BitPos<0>
Bit    60957    379     62 Block=CLB_R6C5 Latch=XQ Net=N_TxD_PAD_O
Bit    60967    379     52 Block=CLB_R5C5 Latch=XQ
Bit    60977    379     42 Block=CLB_R4C5 Latch=XQ Net=Uart_TxUnit/TReg<0>
Bit    60987    379     32 Block=CLB_R3C5 Latch=XQ Net=Uart_Rxrate/Cnt<7>
Bit    60997    379     22 Block=CLB_R2C5 Latch=XQ Net=Uart_Rxrate/Cnt<5>
Bit    61007    379     12 Block=CLB_R1C5 Latch=XQ Net=Uart_Rxrate/Cnt<3>
Bit    61182    381    159 Block=P48 Latch=OQ
Bit    61338    381      3 Block=P134 Latch=OQ
Bit    61343    382    159 Block=P49 Latch=OQ
Bit    61499    382      3 Block=P133 Latch=OQ
Bit    61504    383    159 Block=P49 Latch=I1
Bit    61519    383    144 Block=CLB_R14C5 Latch=X
Bit    61529    383    134 Block=CLB_R13C5 Latch=X
Bit    61539    383    124 Block=CLB_R12C5 Latch=X Net=GLOBAL_LOGIC1_0
Bit    61549    383    114 Block=CLB_R11C5 Latch=X
Bit    61559    383    104 Block=CLB_R10C5 Latch=X Net=Uart_TxUnit/C8/N5
Bit    61569    383     94 Block=CLB_R9C5 Latch=X Net=Uart_TxUnit/C9/N5
Bit    61579    383     84 Block=CLB_R8C5 Latch=X Net=Uart_TxUnit/C10/N6
Bit    61590    383     73 Block=CLB_R7C5 Latch=X
Bit    61600    383     63 Block=CLB_R6C5 Latch=X
Bit    61610    383     53 Block=CLB_R5C5 Latch=X Net=syn785
Bit    61620    383     43 Block=CLB_R4C5 Latch=X Net=syn1133
Bit    61630    383     33 Block=CLB_R3C5 Latch=X
Bit    61640    383     23 Block=CLB_R2C5 Latch=X
Bit    61650    383     13 Block=CLB_R1C5 Latch=X
Bit    61660    383      3 Block=P133 Latch=I1
Bit    61666    384    158 Block=P49 Latch=I2
Bit    61820    384      4 Block=P133 Latch=I2 Net=TxData<6>
Bit    61826    385    159 Block=P48 Latch=I2
Bit    61827    385    158 Block=P48 Latch=I1
Bit    61981    385      4 Block=P134 Latch=I1
Bit    61982    385      3 Block=P134 Latch=I2 Net=TxData<0>
Bit    65223    406    143 Block=CLB_R14C4 Latch=Y
Bit    65233    406    133 Block=CLB_R13C4 Latch=Y
Bit    65243    406    123 Block=CLB_R12C4 Latch=Y
Bit    65253    406    113 Block=CLB_R11C4 Latch=Y
Bit    65263    406    103 Block=CLB_R10C4 Latch=Y
Bit    65273    406     93 Block=CLB_R9C4 Latch=Y
Bit    65283    406     83 Block=CLB_R8C4 Latch=Y
Bit    65294    406     72 Block=CLB_R7C4 Latch=Y
Bit    65304    406     62 Block=CLB_R6C4 Latch=Y
Bit    65314    406     52 Block=CLB_R5C4 Latch=Y
Bit    65324    406     42 Block=CLB_R4C4 Latch=Y
Bit    65334    406     32 Block=CLB_R3C4 Latch=Y Net=Uart_Rxrate/C67
Bit    65344    406     22 Block=CLB_R2C4 Latch=Y
Bit    65354    406     12 Block=CLB_R1C4 Latch=Y
Bit    66027    411    144 Block=CLB_R14C4 Latch=YQ
Bit    66037    411    134 Block=CLB_R13C4 Latch=YQ
Bit    66047    411    124 Block=CLB_R12C4 Latch=YQ
Bit    66057    411    114 Block=CLB_R11C4 Latch=YQ
Bit    66067    411    104 Block=CLB_R10C4 Latch=YQ
Bit    66077    411     94 Block=CLB_R9C4 Latch=YQ
Bit    66087    411     84 Block=CLB_R8C4 Latch=YQ
Bit    66098    411     73 Block=CLB_R7C4 Latch=YQ
Bit    66108    411     63 Block=CLB_R6C4 Latch=YQ Net=Uart_TxUnit/TReg<4>
Bit    66118    411     53 Block=CLB_R5C4 Latch=YQ Net=Uart_TxUnit/TBuff<5>
Bit    66128    411     43 Block=CLB_R4C4 Latch=YQ Net=Uart_TxUnit/TBuff<1>
Bit    66138    411     33 Block=CLB_R3C4 Latch=YQ
Bit    66148    411     23 Block=CLB_R2C4 Latch=YQ Net=Uart_Rxrate/Cnt<0>
Bit    66158    411     13 Block=CLB_R1C4 Latch=YQ Net=Uart_Rxrate/Cnt<2>
Bit    66672    415    143 Block=CLB_R14C4 Latch=XQ
Bit    66682    415    133 Block=CLB_R13C4 Latch=XQ
Bit    66692    415    123 Block=CLB_R12C4 Latch=XQ
Bit    66702    415    113 Block=CLB_R11C4 Latch=XQ
Bit    66712    415    103 Block=CLB_R10C4 Latch=XQ
Bit    66722    415     93 Block=CLB_R9C4 Latch=XQ
Bit    66732    415     83 Block=CLB_R8C4 Latch=XQ
Bit    66743    415     72 Block=CLB_R7C4 Latch=XQ
Bit    66753    415     62 Block=CLB_R6C4 Latch=XQ Net=Uart_TxUnit/TReg<5>
Bit    66763    415     52 Block=CLB_R5C4 Latch=XQ Net=Uart_TxUnit/TBuff<4>
Bit    66773    415     42 Block=CLB_R4C4 Latch=XQ Net=Uart_TxUnit/TBuff<0>
Bit    66783    415     32 Block=CLB_R3C4 Latch=XQ
Bit    66793    415     22 Block=CLB_R2C4 Latch=XQ
Bit    66803    415     12 Block=CLB_R1C4 Latch=XQ Net=Uart_Rxrate/Cnt<1>
Bit    66978    417    159 Block=P46 Latch=OQ
Bit    67134    417      3 Block=P136 Latch=OQ
Bit    67139    418    159 Block=P47 Latch=OQ
Bit    67295    418      3 Block=P135 Latch=OQ
Bit    67300    419    159 Block=P47 Latch=I1
Bit    67315    419    144 Block=CLB_R14C4 Latch=X
Bit    67325    419    134 Block=CLB_R13C4 Latch=X
Bit    67335    419    124 Block=CLB_R12C4 Latch=X
Bit    67345    419    114 Block=CLB_R11C4 Latch=X
Bit    67355    419    104 Block=CLB_R10C4 Latch=X
Bit    67365    419     94 Block=CLB_R9C4 Latch=X
Bit    67375    419     84 Block=CLB_R8C4 Latch=X
Bit    67386    419     73 Block=CLB_R7C4 Latch=X
Bit    67396    419     63 Block=CLB_R6C4 Latch=X
Bit    67406    419     53 Block=CLB_R5C4 Latch=X
Bit    67416    419     43 Block=CLB_R4C4 Latch=X
Bit    67426    419     33 Block=CLB_R3C4 Latch=X
Bit    67436    419     23 Block=CLB_R2C4 Latch=X
Bit    67446    419     13 Block=CLB_R1C4 Latch=X
Bit    67456    419      3 Block=P135 Latch=I1
Bit    67462    420    158 Block=P47 Latch=I2
Bit    67616    420      4 Block=P135 Latch=I2 Net=TxData<5>
Bit    67622    421    159 Block=P46 Latch=I2
Bit    67623    421    158 Block=P46 Latch=I1
Bit    67777    421      4 Block=P136 Latch=I1
Bit    67778    421      3 Block=P136 Latch=I2 Net=TxData<4>
Bit    71019    442    143 Block=CLB_R14C3 Latch=Y
Bit    71029    442    133 Block=CLB_R13C3 Latch=Y
Bit    71039    442    123 Block=CLB_R12C3 Latch=Y
Bit    71049    442    113 Block=CLB_R11C3 Latch=Y Net=GLOBAL_LOGIC1
Bit    71059    442    103 Block=CLB_R10C3 Latch=Y
Bit    71069    442     93 Block=CLB_R9C3 Latch=Y
Bit    71079    442     83 Block=CLB_R8C3 Latch=Y
Bit    71090    442     72 Block=CLB_R7C3 Latch=Y
Bit    71100    442     62 Block=CLB_R6C3 Latch=Y
Bit    71110    442     52 Block=CLB_R5C3 Latch=Y
Bit    71120    442     42 Block=CLB_R4C3 Latch=Y
Bit    71130    442     32 Block=CLB_R3C3 Latch=Y
Bit    71140    442     22 Block=CLB_R2C3 Latch=Y
Bit    71150    442     12 Block=CLB_R1C3 Latch=Y
Bit    71823    447    144 Block=CLB_R14C3 Latch=YQ
Bit    71833    447    134 Block=CLB_R13C3 Latch=YQ
Bit    71843    447    124 Block=CLB_R12C3 Latch=YQ
Bit    71853    447    114 Block=CLB_R11C3 Latch=YQ
Bit    71863    447    104 Block=CLB_R10C3 Latch=YQ
Bit    71873    447     94 Block=CLB_R9C3 Latch=YQ
Bit    71883    447     84 Block=CLB_R8C3 Latch=YQ
Bit    71894    447     73 Block=CLB_R7C3 Latch=YQ
Bit    71904    447     63 Block=CLB_R6C3 Latch=YQ
Bit    71914    447     53 Block=CLB_R5C3 Latch=YQ
Bit    71924    447     43 Block=CLB_R4C3 Latch=YQ
Bit    71934    447     33 Block=CLB_R3C3 Latch=YQ
Bit    71944    447     23 Block=CLB_R2C3 Latch=YQ
Bit    71954    447     13 Block=CLB_R1C3 Latch=YQ
Bit    72468    451    143 Block=CLB_R14C3 Latch=XQ
Bit    72478    451    133 Block=CLB_R13C3 Latch=XQ
Bit    72488    451    123 Block=CLB_R12C3 Latch=XQ
Bit    72498    451    113 Block=CLB_R11C3 Latch=XQ
Bit    72508    451    103 Block=CLB_R10C3 Latch=XQ
Bit    72518    451     93 Block=CLB_R9C3 Latch=XQ
Bit    72528    451     83 Block=CLB_R8C3 Latch=XQ
Bit    72539    451     72 Block=CLB_R7C3 Latch=XQ
Bit    72549    451     62 Block=CLB_R6C3 Latch=XQ
Bit    72559    451     52 Block=CLB_R5C3 Latch=XQ
Bit    72569    451     42 Block=CLB_R4C3 Latch=XQ
Bit    72579    451     32 Block=CLB_R3C3 Latch=XQ
Bit    72589    451     22 Block=CLB_R2C3 Latch=XQ
Bit    72599    451     12 Block=CLB_R1C3 Latch=XQ
Bit    72774    453    159 Block=P43 Latch=OQ
Bit    72930    453      3 Block=P139 Latch=OQ
Bit    72935    454    159 Block=P44 Latch=OQ
Bit    73091    454      3 Block=P138 Latch=OQ
Bit    73096    455    159 Block=P44 Latch=I1
Bit    73111    455    144 Block=CLB_R14C3 Latch=X
Bit    73121    455    134 Block=CLB_R13C3 Latch=X
Bit    73131    455    124 Block=CLB_R12C3 Latch=X
Bit    73141    455    114 Block=CLB_R11C3 Latch=X
Bit    73151    455    104 Block=CLB_R10C3 Latch=X
Bit    73161    455     94 Block=CLB_R9C3 Latch=X
Bit    73171    455     84 Block=CLB_R8C3 Latch=X
Bit    73182    455     73 Block=CLB_R7C3 Latch=X
Bit    73192    455     63 Block=CLB_R6C3 Latch=X
Bit    73202    455     53 Block=CLB_R5C3 Latch=X
Bit    73212    455     43 Block=CLB_R4C3 Latch=X
Bit    73222    455     33 Block=CLB_R3C3 Latch=X
Bit    73232    455     23 Block=CLB_R2C3 Latch=X
Bit    73242    455     13 Block=CLB_R1C3 Latch=X
Bit    73252    455      3 Block=P138 Latch=I1
Bit    73258    456    158 Block=P44 Latch=I2
Bit    73412    456      4 Block=P138 Latch=I2 Net=TxData<1>
Bit    73418    457    159 Block=P43 Latch=I2
Bit    73419    457    158 Block=P43 Latch=I1
Bit    73573    457      4 Block=P139 Latch=I1
Bit    73574    457      3 Block=P139 Latch=I2
Bit    76815    478    143 Block=CLB_R14C2 Latch=Y
Bit    76825    478    133 Block=CLB_R13C2 Latch=Y
Bit    76835    478    123 Block=CLB_R12C2 Latch=Y
Bit    76845    478    113 Block=CLB_R11C2 Latch=Y
Bit    76855    478    103 Block=CLB_R10C2 Latch=Y
Bit    76865    478     93 Block=CLB_R9C2 Latch=Y
Bit    76875    478     83 Block=CLB_R8C2 Latch=Y
Bit    76886    478     72 Block=CLB_R7C2 Latch=Y
Bit    76896    478     62 Block=CLB_R6C2 Latch=Y
Bit    76906    478     52 Block=CLB_R5C2 Latch=Y
Bit    76916    478     42 Block=CLB_R4C2 Latch=Y
Bit    76926    478     32 Block=CLB_R3C2 Latch=Y
Bit    76936    478     22 Block=CLB_R2C2 Latch=Y
Bit    76946    478     12 Block=CLB_R1C2 Latch=Y
Bit    77619    483    144 Block=CLB_R14C2 Latch=YQ
Bit    77629    483    134 Block=CLB_R13C2 Latch=YQ
Bit    77639    483    124 Block=CLB_R12C2 Latch=YQ
Bit    77649    483    114 Block=CLB_R11C2 Latch=YQ
Bit    77659    483    104 Block=CLB_R10C2 Latch=YQ
Bit    77669    483     94 Block=CLB_R9C2 Latch=YQ
Bit    77679    483     84 Block=CLB_R8C2 Latch=YQ
Bit    77690    483     73 Block=CLB_R7C2 Latch=YQ
Bit    77700    483     63 Block=CLB_R6C2 Latch=YQ
Bit    77710    483     53 Block=CLB_R5C2 Latch=YQ
Bit    77720    483     43 Block=CLB_R4C2 Latch=YQ
Bit    77730    483     33 Block=CLB_R3C2 Latch=YQ
Bit    77740    483     23 Block=CLB_R2C2 Latch=YQ
Bit    77750    483     13 Block=CLB_R1C2 Latch=YQ
Bit    78264    487    143 Block=CLB_R14C2 Latch=XQ
Bit    78274    487    133 Block=CLB_R13C2 Latch=XQ
Bit    78284    487    123 Block=CLB_R12C2 Latch=XQ
Bit    78294    487    113 Block=CLB_R11C2 Latch=XQ
Bit    78304    487    103 Block=CLB_R10C2 Latch=XQ
Bit    78314    487     93 Block=CLB_R9C2 Latch=XQ
Bit    78324    487     83 Block=CLB_R8C2 Latch=XQ
Bit    78335    487     72 Block=CLB_R7C2 Latch=XQ
Bit    78345    487     62 Block=CLB_R6C2 Latch=XQ
Bit    78355    487     52 Block=CLB_R5C2 Latch=XQ
Bit    78365    487     42 Block=CLB_R4C2 Latch=XQ
Bit    78375    487     32 Block=CLB_R3C2 Latch=XQ
Bit    78385    487     22 Block=CLB_R2C2 Latch=XQ
Bit    78395    487     12 Block=CLB_R1C2 Latch=XQ
Bit    78570    489    159 Block=P41 Latch=OQ
Bit    78726    489      3 Block=P141 Latch=OQ
Bit    78731    490    159 Block=P42 Latch=OQ
Bit    78887    490      3 Block=P140 Latch=OQ
Bit    78892    491    159 Block=P42 Latch=I1
Bit    78907    491    144 Block=CLB_R14C2 Latch=X
Bit    78917    491    134 Block=CLB_R13C2 Latch=X
Bit    78927    491    124 Block=CLB_R12C2 Latch=X
Bit    78937    491    114 Block=CLB_R11C2 Latch=X
Bit    78947    491    104 Block=CLB_R10C2 Latch=X
Bit    78957    491     94 Block=CLB_R9C2 Latch=X
Bit    78967    491     84 Block=CLB_R8C2 Latch=X
Bit    78978    491     73 Block=CLB_R7C2 Latch=X
Bit    78988    491     63 Block=CLB_R6C2 Latch=X
Bit    78998    491     53 Block=CLB_R5C2 Latch=X
Bit    79008    491     43 Block=CLB_R4C2 Latch=X
Bit    79018    491     33 Block=CLB_R3C2 Latch=X
Bit    79028    491     23 Block=CLB_R2C2 Latch=X
Bit    79038    491     13 Block=CLB_R1C2 Latch=X
Bit    79048    491      3 Block=P140 Latch=I1
Bit    79054    492    158 Block=P42 Latch=I2
Bit    79208    492      4 Block=P140 Latch=I2
Bit    79214    493    159 Block=P41 Latch=I2
Bit    79215    493    158 Block=P41 Latch=I1
Bit    79369    493      4 Block=P141 Latch=I1
Bit    79370    493      3 Block=P141 Latch=I2
Bit    82611    514    143 Block=CLB_R14C1 Latch=Y
Bit    82621    514    133 Block=CLB_R13C1 Latch=Y
Bit    82631    514    123 Block=CLB_R12C1 Latch=Y
Bit    82641    514    113 Block=CLB_R11C1 Latch=Y
Bit    82651    514    103 Block=CLB_R10C1 Latch=Y
Bit    82661    514     93 Block=CLB_R9C1 Latch=Y
Bit    82671    514     83 Block=CLB_R8C1 Latch=Y
Bit    82682    514     72 Block=CLB_R7C1 Latch=Y
Bit    82692    514     62 Block=CLB_R6C1 Latch=Y
Bit    82702    514     52 Block=CLB_R5C1 Latch=Y
Bit    82712    514     42 Block=CLB_R4C1 Latch=Y
Bit    82722    514     32 Block=CLB_R3C1 Latch=Y
Bit    82732    514     22 Block=CLB_R2C1 Latch=Y
Bit    82742    514     12 Block=CLB_R1C1 Latch=Y
Bit    83415    519    144 Block=CLB_R14C1 Latch=YQ
Bit    83425    519    134 Block=CLB_R13C1 Latch=YQ
Bit    83435    519    124 Block=CLB_R12C1 Latch=YQ
Bit    83445    519    114 Block=CLB_R11C1 Latch=YQ
Bit    83455    519    104 Block=CLB_R10C1 Latch=YQ
Bit    83465    519     94 Block=CLB_R9C1 Latch=YQ
Bit    83475    519     84 Block=CLB_R8C1 Latch=YQ
Bit    83486    519     73 Block=CLB_R7C1 Latch=YQ
Bit    83496    519     63 Block=CLB_R6C1 Latch=YQ
Bit    83506    519     53 Block=CLB_R5C1 Latch=YQ
Bit    83516    519     43 Block=CLB_R4C1 Latch=YQ
Bit    83526    519     33 Block=CLB_R3C1 Latch=YQ
Bit    83536    519     23 Block=CLB_R2C1 Latch=YQ
Bit    83546    519     13 Block=CLB_R1C1 Latch=YQ
Bit    84060    523    143 Block=CLB_R14C1 Latch=XQ
Bit    84070    523    133 Block=CLB_R13C1 Latch=XQ
Bit    84080    523    123 Block=CLB_R12C1 Latch=XQ
Bit    84090    523    113 Block=CLB_R11C1 Latch=XQ
Bit    84100    523    103 Block=CLB_R10C1 Latch=XQ
Bit    84110    523     93 Block=CLB_R9C1 Latch=XQ
Bit    84120    523     83 Block=CLB_R8C1 Latch=XQ
Bit    84131    523     72 Block=CLB_R7C1 Latch=XQ
Bit    84141    523     62 Block=CLB_R6C1 Latch=XQ
Bit    84151    523     52 Block=CLB_R5C1 Latch=XQ
Bit    84161    523     42 Block=CLB_R4C1 Latch=XQ
Bit    84171    523     32 Block=CLB_R3C1 Latch=XQ
Bit    84181    523     22 Block=CLB_R2C1 Latch=XQ
Bit    84191    523     12 Block=CLB_R1C1 Latch=XQ
Bit    84366    525    159 Block=P39 Latch=OQ
Bit    84522    525      3 Block=P143 Latch=OQ
Bit    84527    526    159 Block=P40 Latch=OQ
Bit    84683    526      3 Block=P142 Latch=OQ
Bit    84688    527    159 Block=P40 Latch=I1
Bit    84703    527    144 Block=CLB_R14C1 Latch=X
Bit    84713    527    134 Block=CLB_R13C1 Latch=X
Bit    84723    527    124 Block=CLB_R12C1 Latch=X
Bit    84733    527    114 Block=CLB_R11C1 Latch=X
Bit    84743    527    104 Block=CLB_R10C1 Latch=X
Bit    84753    527     94 Block=CLB_R9C1 Latch=X
Bit    84763    527     84 Block=CLB_R8C1 Latch=X
Bit    84774    527     73 Block=CLB_R7C1 Latch=X
Bit    84784    527     63 Block=CLB_R6C1 Latch=X
Bit    84794    527     53 Block=CLB_R5C1 Latch=X
Bit    84804    527     43 Block=CLB_R4C1 Latch=X
Bit    84814    527     33 Block=CLB_R3C1 Latch=X
Bit    84824    527     23 Block=CLB_R2C1 Latch=X
Bit    84834    527     13 Block=CLB_R1C1 Latch=X
Bit    84844    527      3 Block=P142 Latch=I1
Bit    84850    528    158 Block=P40 Latch=I2
Bit    85004    528      4 Block=P142 Latch=I2
Bit    85010    529    159 Block=P39 Latch=I2
Bit    85011    529    158 Block=P39 Latch=I1
Bit    85165    529      4 Block=P143 Latch=I1
Bit    85166    529      3 Block=P143 Latch=I2
Bit    91303    568    145 Block=P33 Latch=I1
Bit    91313    568    135 Block=P31 Latch=I1
Bit    91323    568    125 Block=P29 Latch=I1
Bit    91333    568    115 Block=P26 Latch=I1
Bit    91343    568    105 Block=P24 Latch=I1
Bit    91353    568     95 Block=P22 Latch=I1
Bit    91363    568     85 Block=P20 Latch=I1
Bit    91374    568     74 Block=P16 Latch=I1
Bit    91384    568     64 Block=P14 Latch=I1
Bit    91394    568     54 Block=P12 Latch=I1
Bit    91404    568     44 Block=P10 Latch=I1
Bit    91414    568     34 Block=P7 Latch=I1
Bit    91424    568     24 Block=P5 Latch=I1
Bit    91434    568     14 Block=P3 Latch=I1
Bit    91464    569    145 Block=P33 Latch=I2
Bit    91469    569    140 Block=P32 Latch=OQ
Bit    91474    569    135 Block=P31 Latch=I2
Bit    91479    569    130 Block=P30 Latch=OQ
Bit    91484    569    125 Block=P29 Latch=I2
Bit    91489    569    120 Block=P28 Latch=OQ
Bit    91494    569    115 Block=P26 Latch=I2
Bit    91499    569    110 Block=P25 Latch=OQ
Bit    91504    569    105 Block=P24 Latch=I2
Bit    91509    569    100 Block=P23 Latch=OQ
Bit    91514    569     95 Block=P22 Latch=I2
Bit    91519    569     90 Block=P21 Latch=OQ
Bit    91524    569     85 Block=P20 Latch=I2
Bit    91529    569     80 Block=P19 Latch=OQ
Bit    91535    569     74 Block=P16 Latch=I2
Bit    91540    569     69 Block=P15 Latch=OQ
Bit    91545    569     64 Block=P14 Latch=I2
Bit    91550    569     59 Block=P13 Latch=OQ
Bit    91555    569     54 Block=P12 Latch=I2
Bit    91560    569     49 Block=UNB104 Latch=OQ
Bit    91565    569     44 Block=P10 Latch=I2
Bit    91570    569     39 Block=P9 Latch=OQ
Bit    91575    569     34 Block=P7 Latch=I2
Bit    91580    569     29 Block=P6 Latch=OQ
Bit    91585    569     24 Block=P5 Latch=I2
Bit    91590    569     19 Block=P4 Latch=OQ
Bit    91595    569     14 Block=P3 Latch=I2
Bit    91600    569      9 Block=P2 Latch=OQ
Bit    91624    570    146 Block=P33 Latch=OQ
Bit    91630    570    140 Block=P32 Latch=I2
Bit    91634    570    136 Block=P31 Latch=OQ
Bit    91640    570    130 Block=P30 Latch=I2
Bit    91644    570    126 Block=P29 Latch=OQ
Bit    91650    570    120 Block=P28 Latch=I2
Bit    91654    570    116 Block=P26 Latch=OQ
Bit    91660    570    110 Block=P25 Latch=I2
Bit    91664    570    106 Block=P24 Latch=OQ
Bit    91670    570    100 Block=P23 Latch=I2
Bit    91674    570     96 Block=P22 Latch=OQ
Bit    91680    570     90 Block=P21 Latch=I2
Bit    91684    570     86 Block=P20 Latch=OQ
Bit    91690    570     80 Block=P19 Latch=I2
Bit    91695    570     75 Block=P16 Latch=OQ
Bit    91701    570     69 Block=P15 Latch=I2
Bit    91705    570     65 Block=P14 Latch=OQ
Bit    91711    570     59 Block=P13 Latch=I2
Bit    91715    570     55 Block=P12 Latch=OQ
Bit    91721    570     49 Block=UNB104 Latch=I2
Bit    91725    570     45 Block=P10 Latch=OQ
Bit    91731    570     39 Block=P9 Latch=I2
Bit    91735    570     35 Block=P7 Latch=OQ
Bit    91741    570     29 Block=P6 Latch=I2
Bit    91745    570     25 Block=P5 Latch=OQ
Bit    91751    570     19 Block=P4 Latch=I2
Bit    91755    570     15 Block=P3 Latch=OQ
Bit    91761    570      9 Block=P2 Latch=I2
Bit    91952    572    140 Block=P32 Latch=I1
Bit    91962    572    130 Block=P30 Latch=I1
Bit    91972    572    120 Block=P28 Latch=I1
Bit    91982    572    110 Block=P25 Latch=I1
Bit    91992    572    100 Block=P23 Latch=I1
Bit    92002    572     90 Block=P21 Latch=I1
Bit    92012    572     80 Block=P19 Latch=I1
Bit    92023    572     69 Block=P15 Latch=I1
Bit    92033    572     59 Block=P13 Latch=I1
Bit    92043    572     49 Block=UNB104 Latch=I1
Bit    92053    572     39 Block=P9 Latch=I1
Bit    92063    572     29 Block=P6 Latch=I1
Bit    92073    572     19 Block=P4 Latch=I1
Bit    92083    572      9 Block=P2 Latch=I1
Info ReadCaptureEnabled=1
Info STARTSEL0=1
