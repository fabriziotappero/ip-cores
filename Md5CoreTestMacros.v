/*
Copyright (C) 2014 John Leitch (johnleitch@outlook.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
`define Stages 65

`define TestCase(__number, __passed, __a, __b, __c, __d, __chunk)                           \
reg __passed;                                                                               \
always @(posedge clk)                                                                       \
  begin                                                                                     \
    if (count == __number)                                                                  \
      begin                                                                                 \
        chunk <= __chunk;                                                                   \
      end                                                                                   \
                                                                                            \
    if (count == __number + `Stages)                                                        \
      __passed <=                                                                           \
        a + 'h67452301 == __a &&                                                            \
        b + 'hefcdab89 == __b &&                                                            \
        c + 'h98badcfe == __c &&                                                            \
        d + 'h10325476 == __d;                                                              \
  end                                                                                       \
  
  