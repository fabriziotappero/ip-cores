/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module condition(
    input               oflag,
    input               cflag,
    input               sflag,
    input               zflag,
    input               pflag,
    
    input       [3:0]   index,
    
    output              condition
);

//------------------------------------------------------------------------------

assign condition =
    (index[3:0] == 4'd0)?    oflag :
    (index[3:0] == 4'd1)?   !oflag :
    (index[3:0] == 4'd2)?    cflag :
    (index[3:0] == 4'd3)?   !cflag :
    (index[3:0] == 4'd4)?    zflag :
    (index[3:0] == 4'd5)?   !zflag :
    (index[3:0] == 4'd6)?    (cflag | zflag) :
    (index[3:0] == 4'd7)?   !(cflag | zflag) :
    (index[3:0] == 4'd8)?    sflag :
    (index[3:0] == 4'd9)?   !sflag :
    (index[3:0] == 4'd10)?   pflag :
    (index[3:0] == 4'd11)?  !pflag :
    (index[3:0] == 4'd12)?   (sflag ^ oflag) :
    (index[3:0] == 4'd13)?  !(sflag ^ oflag) :
    (index[3:0] == 4'd14)?   ((sflag ^ oflag) | zflag) :
                            !((sflag ^ oflag) | zflag);

endmodule
