// 
// ******************************************************************************
// *                                                                            *
// *                   Copyright (C) 2004-2009, Nangate Inc.                    *
// *                           All rights reserved.                             *
// *                                                                            *
// * Nangate and the Nangate logo are trademarks of Nangate Inc.                *
// *                                                                            *
// * All trademarks, logos, software marks, and trade names (collectively the   *
// * "Marks") in this program are proprietary to Nangate or other respective    *
// * owners that have granted Nangate the right and license to use such Marks.  *
// * You are not permitted to use the Marks without the prior written consent   *
// * of Nangate or such third party that may own the Marks.                     *
// *                                                                            *
// * This file has been provided pursuant to a License Agreement containing     *
// * restrictions on its use. This file contains valuable trade secrets and     *
// * proprietary information of Nangate Inc., and is protected by U.S. and      *
// * international laws and/or treaties.                                        *
// *                                                                            *
// * The copyright notice(s) in this file does not indicate actual or intended  *
// * publication of this file.                                                  *
// *                                                                            *
// *   NGLibraryCharacterizer, v2009.07-HR28-2009-07-08 - build 200907162109    *
// *                                                                            *
// ******************************************************************************

module AND2_X1 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  and(ZN, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AND2_X2 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  and(ZN, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AND2_X4 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  and(ZN, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AND3_X1 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  and(ZN, i_66, A3);
  and(i_66, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AND3_X2 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  and(ZN, i_66, A3);
  and(i_66, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AND3_X4 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  and(ZN, i_46, A3);
  and(i_46, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AND4_X1 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  and(ZN, i_12, A4);
  and(i_12, i_13, A3);
  and(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AND4_X2 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  and(ZN, i_12, A4);
  and(i_12, i_13, A3);
  and(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AND4_X4 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  and(ZN, i_12, A4);
  and(i_12, i_13, A3);
  and(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module ANTENNA_X1 (A);

  input A;

endmodule

module AOI211_X1 (A, B, C1, C2, ZN);

  input A;
  input B;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, A);
  or(i_19, i_20, B);
  and(i_20, C1, C2);

  specify
    if((B == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI211_X2 (A, B, C1, C2, ZN);

  input A;
  input B;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, A);
  or(i_19, i_20, B);
  and(i_20, C1, C2);

  specify
    if((B == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI211_X4 (A, B, C1, C2, ZN);

  input A;
  input B;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, A);
  or(i_19, i_20, B);
  and(i_20, C1, C2);

  specify
    if((B == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI21_X1 (A, B1, B2, ZN);

  input A;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_12);
  or(i_12, A, i_13);
  and(i_13, B1, B2);

  specify
    if((B1 == 1'b1) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI21_X2 (A, B1, B2, ZN);

  input A;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_52);
  or(i_52, A, i_53);
  and(i_53, B1, B2);

  specify
    if((B1 == 1'b1) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI21_X4 (A, B1, B2, ZN);

  input A;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_52);
  or(i_52, A, i_53);
  and(i_53, B1, B2);

  specify
    if((B1 == 1'b1) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI221_X1 (A, B1, B2, C1, C2, ZN);

  input A;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_24);
  or(i_24, i_25, i_27);
  or(i_25, i_26, A);
  and(i_26, C1, C2);
  and(i_27, B1, B2);

  specify
    (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b0) || (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI221_X2 (A, B1, B2, C1, C2, ZN);

  input A;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_24);
  or(i_24, i_25, i_27);
  or(i_25, i_26, A);
  and(i_26, C1, C2);
  and(i_27, B1, B2);

  specify
    (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b0) || (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) || (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI221_X4 (A, B1, B2, C1, C2, ZN);

  input A;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_24);
  or(i_24, i_25, i_27);
  or(i_25, i_26, A);
  and(i_26, C1, C2);
  and(i_27, B1, B2);

  specify
    (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) || (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI222_X1 (A1, A2, B1, B2, C1, C2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_30);
  or(i_30, i_31, i_34);
  or(i_31, i_32, i_33);
  and(i_32, A1, A2);
  and(i_33, B1, B2);
  and(i_34, C1, C2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI222_X2 (A1, A2, B1, B2, C1, C2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_30);
  or(i_30, i_31, i_34);
  or(i_31, i_32, i_33);
  and(i_32, A1, A2);
  and(i_33, B1, B2);
  and(i_34, C1, C2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI222_X4 (A1, A2, B1, B2, C1, C2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_30);
  or(i_30, i_31, i_34);
  or(i_31, i_32, i_33);
  and(i_32, A1, A2);
  and(i_33, B1, B2);
  and(i_34, C1, C2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI22_X1 (A1, A2, B1, B2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, i_20);
  and(i_19, A1, A2);
  and(i_20, B1, B2);

  specify
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI22_X2 (A1, A2, B1, B2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, i_20);
  and(i_19, A1, A2);
  and(i_20, B1, B2);

  specify
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module AOI22_X4 (A1, A2, B1, B2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, i_20);
  and(i_19, A1, A2);
  and(i_20, B1, B2);

  specify
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module BUF_X1 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

module BUF_X16 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

module BUF_X2 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

module BUF_X32 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

module BUF_X4 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

module BUF_X8 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

module CLKBUF_X1 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

module CLKBUF_X2 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

module CLKBUF_X3 (A, Z);

  input A;
  output Z;

  buf(Z, A);

  specify
    (A => Z) = (0.1, 0.1);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATETST_X1 (CK, E, SE, GCK);

  input CK;
  input E;
  input SE;
  output GCK;
  reg NOTIFIER;

  and(GCK, IQ, CK);
  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQn, IQ);
  or(nextstate, E, SE);


  specify
    (CK => GCK) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
    $width(negedge E, 0.1, 0, NOTIFIER);
    $width(posedge E, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATETST_X2 (CK, E, SE, GCK);

  input CK;
  input E;
  input SE;
  output GCK;
  reg NOTIFIER;

  and(GCK, IQ, CK);
  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQn, IQ);
  or(nextstate, E, SE);


  specify
    (CK => GCK) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
    $width(negedge E, 0.1, 0, NOTIFIER);
    $width(posedge E, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATETST_X4 (CK, E, SE, GCK);

  input CK;
  input E;
  input SE;
  output GCK;
  reg NOTIFIER;

  and(GCK, IQ, CK);
  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQn, IQ);
  or(nextstate, E, SE);


  specify
    (CK => GCK) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
    $width(negedge E, 0.1, 0, NOTIFIER);
    $width(posedge E, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATETST_X8 (CK, E, SE, GCK);

  input CK;
  input E;
  input SE;
  output GCK;
  reg NOTIFIER;

  and(GCK, IQ, CK);
  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQn, IQ);
  or(nextstate, E, SE);


  specify
    (CK => GCK) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
    $width(negedge E, 0.1, 0, NOTIFIER);
    $width(posedge E, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATE_X1 (CK, E, GCK);

  input CK;
  input E;
  output GCK;
  reg NOTIFIER;

  and(GCK, CK, IQ);
  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQn, IQ);
  buf(nextstate, E);


  specify
    (CK => GCK) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
    $width(negedge E, 0.1, 0, NOTIFIER);
    $width(posedge E, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATE_X2 (CK, E, GCK);

  input CK;
  input E;
  output GCK;
  reg NOTIFIER;

  and(GCK, CK, IQ);
  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQn, IQ);
  buf(nextstate, E);


  specify
    (CK => GCK) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
    $width(negedge E, 0.1, 0, NOTIFIER);
    $width(posedge E, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATE_X4 (CK, E, GCK);

  input CK;
  input E;
  output GCK;
  reg NOTIFIER;

  and(GCK, CK, IQ);
  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQn, IQ);
  buf(nextstate, E);


  specify
    (CK => GCK) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
    $width(negedge E, 0.1, 0, NOTIFIER);
    $width(posedge E, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATE_X8 (CK, E, GCK);

  input CK;
  input E;
  output GCK;
  reg NOTIFIER;

  and(GCK, CK, IQ);
  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQn, IQ);
  buf(nextstate, E);


  specify
    (CK => GCK) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
    $width(negedge E, 0.1, 0, NOTIFIER);
    $width(posedge E, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, SN, RN, nextstate, CK, NOTIFIER);
  output IQ;
  input SN;
  input RN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // SN          RN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           1           ?           0           r           ?       : ? :           0;
           ?           1           1           r           ?       : ? :           1;
           1           ?           0           *           ?       : 0 :           0; // reduce pessimism
           ?           1           1           *           ?       : 1 :           1; // reduce pessimism
           1           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           1           ?           ?           ?       : ? :           1; // SN activated
           *           1           ?           ?           ?       : 1 :           1; // Cover all transitions on SN
           ?           0           ?           ?           ?       : ? :           0; // RN activated
           1           *           ?           ?           ?       : 0 :           0; // Cover all transitions on RN
           ?           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DFFRS_X1 (CK, D, RN, SN, Q, QN);

  input CK;
  input D;
  input RN;
  input SN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, SN, RN, nextstate, CK, NOTIFIER);
  and(IQN, i_15, i_16);
  not(i_15, IQ);
  not(i_16, i_17);
  and(i_17, i_18, i_19);
  not(i_18, SN);
  not(i_19, RN);
  buf(Q, IQ);
  buf(QN, IQN);
  buf(nextstate, D);

    and(id_3, SN, RN);

  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b0)) (RN => Q) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b0)) (RN => Q) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b0)) (SN => QN) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b0)) (SN => QN) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);

    $width(negedge CK &&& id_3, 0.1, 0, NOTIFIER);
    $width(posedge CK &&& id_3, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge RN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge RN, 0.1, NOTIFIER);
    $width(negedge RN, 0.1, 0, NOTIFIER);
    $width(posedge RN, 0.1, 0, NOTIFIER);
    $recovery(posedge SN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge SN, 0.1, NOTIFIER);
    $width(negedge SN, 0.1, 0, NOTIFIER);
    $width(posedge SN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, SN, RN, nextstate, CK, NOTIFIER);
  output IQ;
  input SN;
  input RN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // SN          RN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           1           ?           0           r           ?       : ? :           0;
           ?           1           1           r           ?       : ? :           1;
           1           ?           0           *           ?       : 0 :           0; // reduce pessimism
           ?           1           1           *           ?       : 1 :           1; // reduce pessimism
           1           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           1           ?           ?           ?       : ? :           1; // SN activated
           *           1           ?           ?           ?       : 1 :           1; // Cover all transitions on SN
           ?           0           ?           ?           ?       : ? :           0; // RN activated
           1           *           ?           ?           ?       : 0 :           0; // Cover all transitions on RN
           ?           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DFFRS_X2 (CK, D, RN, SN, Q, QN);

  input CK;
  input D;
  input RN;
  input SN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, SN, RN, nextstate, CK, NOTIFIER);
  and(IQN, i_15, i_16);
  not(i_15, IQ);
  not(i_16, i_17);
  and(i_17, i_18, i_19);
  not(i_18, SN);
  not(i_19, RN);
  buf(Q, IQ);
  buf(QN, IQN);
  buf(nextstate, D);

    and(id_3, SN, RN);

  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b0)) (RN => Q) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b0)) (RN => Q) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b0)) (SN => QN) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b0)) (SN => QN) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);

    $width(negedge CK &&& id_3, 0.1, 0, NOTIFIER);
    $width(posedge CK &&& id_3, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge RN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge RN, 0.1, NOTIFIER);
    $width(negedge RN, 0.1, 0, NOTIFIER);
    $width(posedge RN, 0.1, 0, NOTIFIER);
    $recovery(posedge SN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge SN, 0.1, NOTIFIER);
    $width(negedge SN, 0.1, 0, NOTIFIER);
    $width(posedge SN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, RN, nextstate, CK, NOTIFIER);
  output IQ;
  input RN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // RN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           ?           0           r           ?       : ? :           0;
           1           1           r           ?       : ? :           1;
           ?           0           *           ?       : 0 :           0; // reduce pessimism
           1           1           *           ?       : 1 :           1; // reduce pessimism
           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           ?           ?           ?       : ? :           0; // RN activated
           *           ?           ?           ?       : 0 :           0; // Cover all transitions on RN
           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DFFR_X1 (CK, D, RN, Q, QN);

  input CK;
  input D;
  input RN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, RN, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  buf(nextstate, D);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);

    $width(negedge CK &&& ((RN)), 0.1, 0, NOTIFIER);
    $width(posedge CK &&& ((RN)), 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge RN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge RN, 0.1, NOTIFIER);
    $width(negedge RN, 0.1, 0, NOTIFIER);
    $width(posedge RN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, RN, nextstate, CK, NOTIFIER);
  output IQ;
  input RN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // RN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           ?           0           r           ?       : ? :           0;
           1           1           r           ?       : ? :           1;
           ?           0           *           ?       : 0 :           0; // reduce pessimism
           1           1           *           ?       : 1 :           1; // reduce pessimism
           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           ?           ?           ?       : ? :           0; // RN activated
           *           ?           ?           ?       : 0 :           0; // Cover all transitions on RN
           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DFFR_X2 (CK, D, RN, Q, QN);

  input CK;
  input D;
  input RN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, RN, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  buf(nextstate, D);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);

    $width(negedge CK &&& ((RN)), 0.1, 0, NOTIFIER);
    $width(posedge CK &&& ((RN)), 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge RN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge RN, 0.1, NOTIFIER);
    $width(negedge RN, 0.1, 0, NOTIFIER);
    $width(posedge RN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, SN, nextstate, CK, NOTIFIER);
  output IQ;
  input SN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // SN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           1           0           r           ?       : ? :           0;
           ?           1           r           ?       : ? :           1;
           1           0           *           ?       : 0 :           0; // reduce pessimism
           ?           1           *           ?       : 1 :           1; // reduce pessimism
           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           ?           ?           ?       : ? :           1; // SN activated
           *           ?           ?           ?       : 1 :           1; // Cover all transitions on SN
           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DFFS_X1 (CK, D, SN, Q, QN);

  input CK;
  input D;
  input SN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, SN, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  buf(nextstate, D);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);

    $width(negedge CK &&& ((SN)), 0.1, 0, NOTIFIER);
    $width(posedge CK &&& ((SN)), 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge SN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge SN, 0.1, NOTIFIER);
    $width(negedge SN, 0.1, 0, NOTIFIER);
    $width(posedge SN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, SN, nextstate, CK, NOTIFIER);
  output IQ;
  input SN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // SN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           1           0           r           ?       : ? :           0;
           ?           1           r           ?       : ? :           1;
           1           0           *           ?       : 0 :           0; // reduce pessimism
           ?           1           *           ?       : 1 :           1; // reduce pessimism
           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           ?           ?           ?       : ? :           1; // SN activated
           *           ?           ?           ?       : 1 :           1; // Cover all transitions on SN
           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DFFS_X2 (CK, D, SN, Q, QN);

  input CK;
  input D;
  input SN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, SN, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  buf(nextstate, D);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);

    $width(negedge CK &&& ((SN)), 0.1, 0, NOTIFIER);
    $width(posedge CK &&& ((SN)), 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge SN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge SN, 0.1, NOTIFIER);
    $width(negedge SN, 0.1, 0, NOTIFIER);
    $width(posedge SN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           r           ?       : ? :           0;
           1           r           ?       : ? :           1;
           0           *           ?       : 0 :           0; // reduce pessimism
           1           *           ?       : 1 :           1; // reduce pessimism
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DFF_X1 (CK, D, Q, QN);

  input CK;
  input D;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  buf(nextstate, D);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           r           ?       : ? :           0;
           1           r           ?       : ? :           1;
           0           *           ?       : 0 :           0; // reduce pessimism
           1           *           ?       : 1 :           1; // reduce pessimism
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DFF_X2 (CK, D, Q, QN);

  input CK;
  input D;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  buf(nextstate, D);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, G, NOTIFIER);
  output IQ;
  input nextstate;
  input G;
  input NOTIFIER;
  reg IQ;

  table
// nextstate           G    NOTIFIER     : @IQ :          IQ
           0           1           ?       : ? :           0;
           1           1           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           0           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DLH_X1 (D, G, Q);

  input D;
  input G;
  output Q;
  reg NOTIFIER;

  seq3(IQ, nextstate, G, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(nextstate, D);


  specify
    (D => Q) = (0.1, 0.1);
    (posedge G => (Q +: D)) = (0.1, 0.1);

    $setuphold(negedge G, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(negedge G, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $width(negedge G, 0.1, 0, NOTIFIER);
    $width(posedge G, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, G, NOTIFIER);
  output IQ;
  input nextstate;
  input G;
  input NOTIFIER;
  reg IQ;

  table
// nextstate           G    NOTIFIER     : @IQ :          IQ
           0           1           ?       : ? :           0;
           1           1           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           0           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DLH_X2 (D, G, Q);

  input D;
  input G;
  output Q;
  reg NOTIFIER;

  seq3(IQ, nextstate, G, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(nextstate, D);


  specify
    (D => Q) = (0.1, 0.1);
    (posedge G => (Q +: D)) = (0.1, 0.1);

    $setuphold(negedge G, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(negedge G, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $width(negedge G, 0.1, 0, NOTIFIER);
    $width(posedge G, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, GN, NOTIFIER);
  output IQ;
  input nextstate;
  input GN;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          GN    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DLL_X1 (D, GN, Q);

  input D;
  input GN;
  output Q;
  reg NOTIFIER;

  seq3(IQ, nextstate, GN, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(nextstate, D);


  specify
    (D => Q) = (0.1, 0.1);
    (negedge GN => (Q +: D)) = (0.1, 0.1);

    $setuphold(posedge GN, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge GN, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $width(negedge GN, 0.1, 0, NOTIFIER);
    $width(posedge GN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, GN, NOTIFIER);
  output IQ;
  input nextstate;
  input GN;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          GN    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module DLL_X2 (D, GN, Q);

  input D;
  input GN;
  output Q;
  reg NOTIFIER;

  seq3(IQ, nextstate, GN, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(nextstate, D);


  specify
    (D => Q) = (0.1, 0.1);
    (negedge GN => (Q +: D)) = (0.1, 0.1);

    $setuphold(posedge GN, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge GN, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $width(negedge GN, 0.1, 0, NOTIFIER);
    $width(posedge GN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

module FA_X1 (A, B, CI, CO, S);

  input A;
  input B;
  input CI;
  output CO;
  output S;

  or(CO, i_24, i_25);
  and(i_24, A, B);
  and(i_25, CI, i_26);
  or(i_26, A, B);
  xor(S, CI, i_30);
  xor(i_30, A, B);

  specify
    if((B == 1'b0) && (CI == 1'b1)) (A => CO) = (0.1, 0.1);
    if((B == 1'b1) && (CI == 1'b0)) (A => CO) = (0.1, 0.1);
    if((A == 1'b1) && (CI == 1'b0)) (B => CO) = (0.1, 0.1);
    if((A == 1'b0) && (CI == 1'b1)) (B => CO) = (0.1, 0.1);
    if((A == 1'b1) && (B == 1'b0)) (CI => CO) = (0.1, 0.1);
    if((A == 1'b0) && (B == 1'b1)) (CI => CO) = (0.1, 0.1);
    if((B == 1'b0) && (CI == 1'b1)) (A => S) = (0.1, 0.1);
    if((B == 1'b0) && (CI == 1'b0)) (A => S) = (0.1, 0.1);
    if((B == 1'b1) && (CI == 1'b1)) (A => S) = (0.1, 0.1);
    if((B == 1'b1) && (CI == 1'b0)) (A => S) = (0.1, 0.1);
    if((A == 1'b0) && (CI == 1'b0)) (B => S) = (0.1, 0.1);
    if((A == 1'b1) && (CI == 1'b0)) (B => S) = (0.1, 0.1);
    if((A == 1'b1) && (CI == 1'b1)) (B => S) = (0.1, 0.1);
    if((A == 1'b0) && (CI == 1'b1)) (B => S) = (0.1, 0.1);
    if((A == 1'b1) && (B == 1'b1)) (CI => S) = (0.1, 0.1);
    if((A == 1'b1) && (B == 1'b0)) (CI => S) = (0.1, 0.1);
    if((A == 1'b0) && (B == 1'b1)) (CI => S) = (0.1, 0.1);
    if((A == 1'b0) && (B == 1'b0)) (CI => S) = (0.1, 0.1);
  endspecify

endmodule

module FILLCELL_X1 ();


endmodule

module FILLCELL_X16 ();


endmodule

module FILLCELL_X2 ();


endmodule

module FILLCELL_X32 ();


endmodule

module FILLCELL_X4 ();


endmodule

module FILLCELL_X8 ();


endmodule

module HA_X1 (A, B, CO, S);

  input A;
  input B;
  output CO;
  output S;

  and(CO, A, B);
  xor(S, A, B);

  specify
    (A => CO) = (0.1, 0.1);
    (B => CO) = (0.1, 0.1);
    if((B == 1'b0)) (A => S) = (0.1, 0.1);
    if((B == 1'b1)) (A => S) = (0.1, 0.1);
    if((A == 1'b1)) (B => S) = (0.1, 0.1);
    if((A == 1'b0)) (B => S) = (0.1, 0.1);
  endspecify

endmodule

module INV_X1 (A, ZN);

  input A;
  output ZN;

  not(ZN, A);

  specify
    (A => ZN) = (0.1, 0.1);
  endspecify

endmodule

module INV_X16 (A, ZN);

  input A;
  output ZN;

  not(ZN, A);

  specify
    (A => ZN) = (0.1, 0.1);
  endspecify

endmodule

module INV_X2 (A, ZN);

  input A;
  output ZN;

  not(ZN, A);

  specify
    (A => ZN) = (0.1, 0.1);
  endspecify

endmodule

module INV_X32 (A, ZN);

  input A;
  output ZN;

  not(ZN, A);

  specify
    (A => ZN) = (0.1, 0.1);
  endspecify

endmodule

module INV_X4 (A, ZN);

  input A;
  output ZN;

  not(ZN, A);

  specify
    (A => ZN) = (0.1, 0.1);
  endspecify

endmodule

module INV_X8 (A, ZN);

  input A;
  output ZN;

  not(ZN, A);

  specify
    (A => ZN) = (0.1, 0.1);
  endspecify

endmodule

module LOGIC0_X1 (Z);

  output Z;

  buf(Z, 0);
endmodule

module LOGIC1_X1 (Z);

  output Z;

  buf(Z, 1);
endmodule

module MUX2_X1 (A, B, S, Z);

  input A;
  input B;
  input S;
  output Z;

  or(Z, i_38, i_39);
  and(i_38, S, B);
  and(i_39, A, i_40);
  not(i_40, S);

  specify
    if((B == 1'b1) && (S == 1'b0)) (A => Z) = (0.1, 0.1);
    if((B == 1'b0) && (S == 1'b0)) (A => Z) = (0.1, 0.1);
    if((A == 1'b1) && (S == 1'b1)) (B => Z) = (0.1, 0.1);
    if((A == 1'b0) && (S == 1'b1)) (B => Z) = (0.1, 0.1);
    if((A == 1'b1) && (B == 1'b0)) (S => Z) = (0.1, 0.1);
    if((A == 1'b0) && (B == 1'b1)) (S => Z) = (0.1, 0.1);
  endspecify

endmodule

module MUX2_X2 (A, B, S, Z);

  input A;
  input B;
  input S;
  output Z;

  or(Z, i_58, i_59);
  and(i_58, S, B);
  and(i_59, A, i_60);
  not(i_60, S);

  specify
    if((B == 1'b1) && (S == 1'b0)) (A => Z) = (0.1, 0.1);
    if((B == 1'b0) && (S == 1'b0)) (A => Z) = (0.1, 0.1);
    if((A == 1'b1) && (S == 1'b1)) (B => Z) = (0.1, 0.1);
    if((A == 1'b0) && (S == 1'b1)) (B => Z) = (0.1, 0.1);
    if((A == 1'b1) && (B == 1'b0)) (S => Z) = (0.1, 0.1);
    if((A == 1'b0) && (B == 1'b1)) (S => Z) = (0.1, 0.1);
  endspecify

endmodule

module NAND2_X1 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  not(ZN, i_6);
  and(i_6, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NAND2_X2 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  not(ZN, i_6);
  and(i_6, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NAND2_X4 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  not(ZN, i_6);
  and(i_6, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NAND3_X1 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  not(ZN, i_32);
  and(i_32, i_33, A3);
  and(i_33, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NAND3_X2 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  not(ZN, i_32);
  and(i_32, i_33, A3);
  and(i_33, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NAND3_X4 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  not(ZN, i_12);
  and(i_12, i_13, A3);
  and(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NAND4_X1 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, A4);
  and(i_19, i_20, A3);
  and(i_20, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NAND4_X2 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, A4);
  and(i_19, i_20, A3);
  and(i_20, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NAND4_X4 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, A4);
  and(i_19, i_20, A3);
  and(i_20, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR2_X1 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  not(ZN, i_66);
  or(i_66, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR2_X2 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  not(ZN, i_46);
  or(i_46, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR2_X4 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  not(ZN, i_66);
  or(i_66, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR3_X1 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  not(ZN, i_12);
  or(i_12, i_13, A3);
  or(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR3_X2 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  not(ZN, i_12);
  or(i_12, i_13, A3);
  or(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR3_X4 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  not(ZN, i_12);
  or(i_12, i_13, A3);
  or(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR4_X1 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, A4);
  or(i_19, i_20, A3);
  or(i_20, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR4_X2 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, A4);
  or(i_19, i_20, A3);
  or(i_20, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module NOR4_X4 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  not(ZN, i_18);
  or(i_18, i_19, A4);
  or(i_19, i_20, A3);
  or(i_20, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI211_X1 (A, B, C1, C2, ZN);

  input A;
  input B;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, B);
  and(i_19, i_20, A);
  or(i_20, C1, C2);

  specify
    if((B == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI211_X2 (A, B, C1, C2, ZN);

  input A;
  input B;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, B);
  and(i_19, i_20, A);
  or(i_20, C1, C2);

  specify
    if((B == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI211_X4 (A, B, C1, C2, ZN);

  input A;
  input B;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, B);
  and(i_19, i_20, A);
  or(i_20, C1, C2);

  specify
    if((B == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (B => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI21_X1 (A, B1, B2, ZN);

  input A;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_12);
  and(i_12, A, i_13);
  or(i_13, B1, B2);

  specify
    if((B1 == 1'b1) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b1) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI21_X2 (A, B1, B2, ZN);

  input A;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_12);
  and(i_12, A, i_13);
  or(i_13, B1, B2);

  specify
    if((B1 == 1'b1) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b1) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI21_X4 (A, B1, B2, ZN);

  input A;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_12);
  and(i_12, A, i_13);
  or(i_13, B1, B2);

  specify
    if((B1 == 1'b1) && (B2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b1) && (B2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI221_X1 (A, B1, B2, C1, C2, ZN);

  input A;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_24);
  and(i_24, i_25, i_27);
  and(i_25, i_26, A);
  or(i_26, C1, C2);
  or(i_27, B1, B2);

  specify
    (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI221_X2 (A, B1, B2, C1, C2, ZN);

  input A;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_24);
  and(i_24, i_25, i_27);
  and(i_25, i_26, A);
  or(i_26, C1, C2);
  or(i_27, B1, B2);

  specify
    (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI221_X4 (A, B1, B2, C1, C2, ZN);

  input A;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_24);
  and(i_24, i_25, i_27);
  and(i_25, i_26, A);
  or(i_26, C1, C2);
  or(i_27, B1, B2);

  specify
    (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI222_X1 (A1, A2, B1, B2, C1, C2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_30);
  and(i_30, i_31, i_34);
  and(i_31, i_32, i_33);
  or(i_32, A1, A2);
  or(i_33, B1, B2);
  or(i_34, C1, C2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI222_X2 (A1, A2, B1, B2, C1, C2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_30);
  and(i_30, i_31, i_34);
  and(i_31, i_32, i_33);
  or(i_32, A1, A2);
  or(i_33, B1, B2);
  or(i_34, C1, C2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI222_X4 (A1, A2, B1, B2, C1, C2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  input C1;
  input C2;
  output ZN;

  not(ZN, i_30);
  and(i_30, i_31, i_34);
  and(i_31, i_32, i_33);
  or(i_32, A1, A2);
  or(i_33, B1, B2);
  or(i_34, C1, C2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b1) || (A1 == 1'b0) && (B1 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1) || (A1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b1) && (C2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
    if((A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b0) && (C2 == 1'b1) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) || (A1 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1) || (A2 == 1'b1) && (B1 == 1'b0) && (C1 == 1'b1) && (C2 == 1'b1)) (B2 => ZN) = (0.1, 0.1);
    (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C2 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C2 == 1'b0)) (C1 => ZN) = (0.1, 0.1);
    (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b1) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (C1 == 1'b0) || (A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (C1 == 1'b0)) (C2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI22_X1 (A1, A2, B1, B2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, i_20);
  or(i_19, A1, A2);
  or(i_20, B1, B2);

  specify
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI22_X2 (A1, A2, B1, B2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, i_20);
  or(i_19, A1, A2);
  or(i_20, B1, B2);

  specify
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI22_X4 (A1, A2, B1, B2, ZN);

  input A1;
  input A2;
  input B1;
  input B2;
  output ZN;

  not(ZN, i_18);
  and(i_18, i_19, i_20);
  or(i_19, A1, A2);
  or(i_20, B1, B2);

  specify
    if((A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B2 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b0) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (A2 == 1'b1) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (B1 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OAI33_X1 (A1, A2, A3, B1, B2, B3, ZN);

  input A1;
  input A2;
  input A3;
  input B1;
  input B2;
  input B3;
  output ZN;

  not(ZN, i_30);
  and(i_30, i_31, i_33);
  or(i_31, i_32, A3);
  or(i_32, A1, A2);
  or(i_33, i_34, B3);
  or(i_34, B1, B2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (B3 == 1'b0) || (A2 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (B3 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (B3 == 1'b0)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (B3 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    if((A2 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) || (A2 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b1) && (B3 == 1'b1)) (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (B3 == 1'b0) || (A1 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (B3 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (B3 == 1'b0)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) || (A1 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b1) && (B3 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A3 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (B3 == 1'b1)) (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (B3 == 1'b1)) (A3 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b1) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1) && (B3 == 1'b1)) (A3 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b1) && (B2 == 1'b0) && (B3 == 1'b0)) (A3 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b1) && (B3 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) && (B3 == 1'b1)) (A3 => ZN) = (0.1, 0.1);
    (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (A3 == 1'b0) && (B2 == 1'b0) && (B3 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b0) && (A3 == 1'b1) && (B2 == 1'b0) && (B3 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (A3 == 1'b1) && (B2 == 1'b0) && (B3 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B2 == 1'b0) && (B3 == 1'b0)) (B1 => ZN) = (0.1, 0.1);
    (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (A3 == 1'b1) && (B1 == 1'b0) && (B3 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B3 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (A3 == 1'b0) && (B1 == 1'b0) && (B3 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b0) && (A3 == 1'b1) && (B1 == 1'b0) && (B3 == 1'b0)) (B2 => ZN) = (0.1, 0.1);
    (B3 => ZN) = (0.1, 0.1);
    if((A1 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (B3 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (A3 == 1'b0) && (B1 == 1'b0) && (B2 == 1'b0) || (A1 == 1'b0) && (A2 == 1'b0) && (A3 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (B3 => ZN) = (0.1, 0.1);
    if((A1 == 1'b0) && (A2 == 1'b1) && (A3 == 1'b1) && (B1 == 1'b0) && (B2 == 1'b0)) (B3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR2_X1 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  or(ZN, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR2_X2 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  or(ZN, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR2_X4 (A1, A2, ZN);

  input A1;
  input A2;
  output ZN;

  or(ZN, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR3_X1 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  or(ZN, i_6, A3);
  or(i_6, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR3_X2 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  or(ZN, i_6, A3);
  or(i_6, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR3_X4 (A1, A2, A3, ZN);

  input A1;
  input A2;
  input A3;
  output ZN;

  or(ZN, i_6, A3);
  or(i_6, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR4_X1 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  or(ZN, i_12, A4);
  or(i_12, i_13, A3);
  or(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR4_X2 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  or(ZN, i_12, A4);
  or(i_12, i_13, A3);
  or(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

module OR4_X4 (A1, A2, A3, A4, ZN);

  input A1;
  input A2;
  input A3;
  input A4;
  output ZN;

  or(ZN, i_12, A4);
  or(i_12, i_13, A3);
  or(i_13, A1, A2);

  specify
    (A1 => ZN) = (0.1, 0.1);
    (A2 => ZN) = (0.1, 0.1);
    (A3 => ZN) = (0.1, 0.1);
    (A4 => ZN) = (0.1, 0.1);
  endspecify

endmodule

primitive seq3 (IQ, SN, RN, nextstate, CK, NOTIFIER);
  output IQ;
  input SN;
  input RN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // SN          RN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           1           ?           0           r           ?       : ? :           0;
           ?           1           1           r           ?       : ? :           1;
           1           ?           0           *           ?       : 0 :           0; // reduce pessimism
           ?           1           1           *           ?       : 1 :           1; // reduce pessimism
           1           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           1           ?           ?           ?       : ? :           1; // SN activated
           *           1           ?           ?           ?       : 1 :           1; // Cover all transitions on SN
           ?           0           ?           ?           ?       : ? :           0; // RN activated
           1           *           ?           ?           ?       : 0 :           0; // Cover all transitions on RN
           ?           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module SDFFRS_X1 (CK, D, RN, SE, SI, SN, Q, QN);

  input CK;
  input D;
  input RN;
  input SE;
  input SI;
  input SN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, SN, RN, nextstate, CK, NOTIFIER);
  and(IQN, i_33, i_34);
  not(i_33, IQ);
  not(i_34, i_35);
  and(i_35, i_36, i_37);
  not(i_36, SN);
  not(i_37, RN);
  buf(Q, IQ);
  buf(QN, IQN);
  or(nextstate, i_38, i_39);
  and(i_38, SE, SI);
  and(i_39, D, i_40);
  not(i_40, SE);

    and(id_3, SN, RN);

  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b0)) (RN => Q) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b0)) (RN => Q) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b0)) (SN => QN) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b0)) (SN => QN) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);

    $width(negedge CK &&& id_3, 0.1, 0, NOTIFIER);
    $width(posedge CK &&& id_3, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge RN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge RN, 0.1, NOTIFIER);
    $width(negedge RN, 0.1, 0, NOTIFIER);
    $width(posedge RN, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SI, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SI, 0.1, 0.1, NOTIFIER);
    $width(negedge SI, 0.1, 0, NOTIFIER);
    $width(posedge SI, 0.1, 0, NOTIFIER);
    $recovery(posedge SN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge SN, 0.1, NOTIFIER);
    $width(negedge SN, 0.1, 0, NOTIFIER);
    $width(posedge SN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, SN, RN, nextstate, CK, NOTIFIER);
  output IQ;
  input SN;
  input RN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // SN          RN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           1           ?           0           r           ?       : ? :           0;
           ?           1           1           r           ?       : ? :           1;
           1           ?           0           *           ?       : 0 :           0; // reduce pessimism
           ?           1           1           *           ?       : 1 :           1; // reduce pessimism
           1           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           1           ?           ?           ?       : ? :           1; // SN activated
           *           1           ?           ?           ?       : 1 :           1; // Cover all transitions on SN
           ?           0           ?           ?           ?       : ? :           0; // RN activated
           1           *           ?           ?           ?       : 0 :           0; // Cover all transitions on RN
           ?           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module SDFFRS_X2 (CK, D, RN, SE, SI, SN, Q, QN);

  input CK;
  input D;
  input RN;
  input SE;
  input SI;
  input SN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, SN, RN, nextstate, CK, NOTIFIER);
  and(IQN, i_33, i_34);
  not(i_33, IQ);
  not(i_34, i_35);
  and(i_35, i_36, i_37);
  not(i_36, SN);
  not(i_37, RN);
  buf(Q, IQ);
  buf(QN, IQN);
  or(nextstate, i_38, i_39);
  and(i_38, SE, SI);
  and(i_39, D, i_40);
  not(i_40, SE);

    and(id_3, SN, RN);

  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b0)) (RN => Q) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b0)) (RN => Q) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1) && (SN == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0) && (SN == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b1) && (RN == 1'b0)) (SN => QN) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b0)) (SN => QN) = (0.1, 0.1);
    if((CK == 1'b0) && (RN == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);

    $width(negedge CK &&& id_3, 0.1, 0, NOTIFIER);
    $width(posedge CK &&& id_3, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge RN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge RN, 0.1, NOTIFIER);
    $width(negedge RN, 0.1, 0, NOTIFIER);
    $width(posedge RN, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SI, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SI, 0.1, 0.1, NOTIFIER);
    $width(negedge SI, 0.1, 0, NOTIFIER);
    $width(posedge SI, 0.1, 0, NOTIFIER);
    $recovery(posedge SN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge SN, 0.1, NOTIFIER);
    $width(negedge SN, 0.1, 0, NOTIFIER);
    $width(posedge SN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, RN, nextstate, CK, NOTIFIER);
  output IQ;
  input RN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // RN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           ?           0           r           ?       : ? :           0;
           1           1           r           ?       : ? :           1;
           ?           0           *           ?       : 0 :           0; // reduce pessimism
           1           1           *           ?       : 1 :           1; // reduce pessimism
           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           ?           ?           ?       : ? :           0; // RN activated
           *           ?           ?           ?       : 0 :           0; // Cover all transitions on RN
           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module SDFFR_X1 (CK, D, RN, SE, SI, Q, QN);

  input CK;
  input D;
  input RN;
  input SE;
  input SI;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, RN, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  or(nextstate, i_18, i_19);
  and(i_18, SE, SI);
  and(i_19, D, i_20);
  not(i_20, SE);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);

    $width(negedge CK &&& ((RN)), 0.1, 0, NOTIFIER);
    $width(posedge CK &&& ((RN)), 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge RN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge RN, 0.1, NOTIFIER);
    $width(negedge RN, 0.1, 0, NOTIFIER);
    $width(posedge RN, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SI, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SI, 0.1, 0.1, NOTIFIER);
    $width(negedge SI, 0.1, 0, NOTIFIER);
    $width(posedge SI, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, RN, nextstate, CK, NOTIFIER);
  output IQ;
  input RN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // RN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           ?           0           r           ?       : ? :           0;
           1           1           r           ?       : ? :           1;
           ?           0           *           ?       : 0 :           0; // reduce pessimism
           1           1           *           ?       : 1 :           1; // reduce pessimism
           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           ?           ?           ?       : ? :           0; // RN activated
           *           ?           ?           ?       : 0 :           0; // Cover all transitions on RN
           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module SDFFR_X2 (CK, D, RN, SE, SI, Q, QN);

  input CK;
  input D;
  input RN;
  input SE;
  input SI;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, RN, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  or(nextstate, i_18, i_19);
  and(i_18, SE, SI);
  and(i_19, D, i_20);
  not(i_20, SE);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge RN => (Q +: 1'b0)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge RN => (QN +: 1'b1)) = (0.1, 0.1);

    $width(negedge CK &&& ((RN)), 0.1, 0, NOTIFIER);
    $width(posedge CK &&& ((RN)), 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $recovery(posedge RN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge RN, 0.1, NOTIFIER);
    $width(negedge RN, 0.1, 0, NOTIFIER);
    $width(posedge RN, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SI, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SI, 0.1, 0.1, NOTIFIER);
    $width(negedge SI, 0.1, 0, NOTIFIER);
    $width(posedge SI, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, SN, nextstate, CK, NOTIFIER);
  output IQ;
  input SN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // SN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           1           0           r           ?       : ? :           0;
           ?           1           r           ?       : ? :           1;
           1           0           *           ?       : 0 :           0; // reduce pessimism
           ?           1           *           ?       : 1 :           1; // reduce pessimism
           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           ?           ?           ?       : ? :           1; // SN activated
           *           ?           ?           ?       : 1 :           1; // Cover all transitions on SN
           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module SDFFS_X1 (CK, D, SE, SI, SN, Q, QN);

  input CK;
  input D;
  input SE;
  input SI;
  input SN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, SN, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  or(nextstate, i_18, i_19);
  and(i_18, SE, SI);
  and(i_19, D, i_20);
  not(i_20, SE);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);

    $width(negedge CK &&& ((SN)), 0.1, 0, NOTIFIER);
    $width(posedge CK &&& ((SN)), 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SI, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SI, 0.1, 0.1, NOTIFIER);
    $width(negedge SI, 0.1, 0, NOTIFIER);
    $width(posedge SI, 0.1, 0, NOTIFIER);
    $recovery(posedge SN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge SN, 0.1, NOTIFIER);
    $width(negedge SN, 0.1, 0, NOTIFIER);
    $width(posedge SN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, SN, nextstate, CK, NOTIFIER);
  output IQ;
  input SN;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
       // SN   nextstate          CK    NOTIFIER     : @IQ :          IQ
           1           0           r           ?       : ? :           0;
           ?           1           r           ?       : ? :           1;
           1           0           *           ?       : 0 :           0; // reduce pessimism
           ?           1           *           ?       : 1 :           1; // reduce pessimism
           1           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           1           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           0           ?           ?           ?       : ? :           1; // SN activated
           *           ?           ?           ?       : 1 :           1; // Cover all transitions on SN
           ?           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module SDFFS_X2 (CK, D, SE, SI, SN, Q, QN);

  input CK;
  input D;
  input SE;
  input SI;
  input SN;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, SN, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  or(nextstate, i_18, i_19);
  and(i_18, SE, SI);
  and(i_19, D, i_20);
  not(i_20, SE);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge SN => (Q +: 1'b1)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);
    if((CK == 1'b1)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);
    if((CK == 1'b0)) (negedge SN => (QN +: 1'b0)) = (0.1, 0.1);

    $width(negedge CK &&& ((SN)), 0.1, 0, NOTIFIER);
    $width(posedge CK &&& ((SN)), 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SI, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SI, 0.1, 0.1, NOTIFIER);
    $width(negedge SI, 0.1, 0, NOTIFIER);
    $width(posedge SI, 0.1, 0, NOTIFIER);
    $recovery(posedge SN, posedge CK, 0.1, NOTIFIER);
    $hold(posedge CK, posedge SN, 0.1, NOTIFIER);
    $width(negedge SN, 0.1, 0, NOTIFIER);
    $width(posedge SN, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           r           ?       : ? :           0;
           1           r           ?       : ? :           1;
           0           *           ?       : 0 :           0; // reduce pessimism
           1           *           ?       : 1 :           1; // reduce pessimism
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module SDFF_X1 (CK, D, SE, SI, Q, QN);

  input CK;
  input D;
  input SE;
  input SI;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  or(nextstate, i_18, i_19);
  and(i_18, SE, SI);
  and(i_19, D, i_20);
  not(i_20, SE);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SI, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SI, 0.1, 0.1, NOTIFIER);
    $width(negedge SI, 0.1, 0, NOTIFIER);
    $width(posedge SI, 0.1, 0, NOTIFIER);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           r           ?       : ? :           0;
           1           r           ?       : ? :           1;
           0           *           ?       : 0 :           0; // reduce pessimism
           1           *           ?       : 1 :           1; // reduce pessimism
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           f           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module SDFF_X2 (CK, D, SE, SI, Q, QN);

  input CK;
  input D;
  input SE;
  input SI;
  output Q;
  output QN;
  reg NOTIFIER;

  seq3(IQ, nextstate, CK, NOTIFIER);
  not(IQN, IQ);
  buf(Q, IQ);
  buf(QN, IQN);
  or(nextstate, i_18, i_19);
  and(i_18, SE, SI);
  and(i_19, D, i_20);
  not(i_20, SE);


  specify
    (posedge CK => (Q +: D)) = (0.1, 0.1);
    (posedge CK => (QN -: D)) = (0.1, 0.1);

    $width(negedge CK, 0.1, 0, NOTIFIER);
    $width(posedge CK, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
    $width(negedge SE, 0.1, 0, NOTIFIER);
    $width(posedge SE, 0.1, 0, NOTIFIER);
    $setuphold(posedge CK, negedge SI, 0.1, 0.1, NOTIFIER);
    $setuphold(posedge CK, posedge SI, 0.1, 0.1, NOTIFIER);
    $width(negedge SI, 0.1, 0, NOTIFIER);
    $width(posedge SI, 0.1, 0, NOTIFIER);
  endspecify

endmodule

module TBUF_X1 (A, EN, Z);

  input A;
  input EN;
  output Z;

  bufif0(Z, Z_in, Z_enable);
  buf(Z_enable, EN);
  buf(Z_in, A);

  specify
    (A => Z) = (0.1, 0.1);
    (EN => Z) = (0.1, 0.1);
  endspecify

endmodule

module TBUF_X16 (A, EN, Z);

  input A;
  input EN;
  output Z;

  bufif0(Z, Z_in, Z_enable);
  buf(Z_enable, EN);
  buf(Z_in, A);

  specify
    (A => Z) = (0.1, 0.1);
    (EN => Z) = (0.1, 0.1);
  endspecify

endmodule

module TBUF_X2 (A, EN, Z);

  input A;
  input EN;
  output Z;

  bufif0(Z, Z_in, Z_enable);
  buf(Z_enable, EN);
  buf(Z_in, A);

  specify
    (A => Z) = (0.1, 0.1);
    (EN => Z) = (0.1, 0.1);
  endspecify

endmodule

module TBUF_X4 (A, EN, Z);

  input A;
  input EN;
  output Z;

  bufif0(Z, Z_in, Z_enable);
  buf(Z_enable, EN);
  buf(Z_in, A);

  specify
    (A => Z) = (0.1, 0.1);
    (EN => Z) = (0.1, 0.1);
  endspecify

endmodule

module TBUF_X8 (A, EN, Z);

  input A;
  input EN;
  output Z;

  bufif0(Z, Z_in, Z_enable);
  buf(Z_enable, EN);
  buf(Z_in, A);

  specify
    (A => Z) = (0.1, 0.1);
    (EN => Z) = (0.1, 0.1);
  endspecify

endmodule

module TINV_X1 (EN, I, ZN);

  input EN;
  input I;
  output ZN;

  bufif0(ZN, ZN_in, ZN_enable);
  buf(ZN_enable, EN);
  not(ZN_in, I);

  specify
    (EN => ZN) = (0.1, 0.1);
    (I => ZN) = (0.1, 0.1);
  endspecify

endmodule

primitive seq3 (IQ, nextstate, G, NOTIFIER);
  output IQ;
  input nextstate;
  input G;
  input NOTIFIER;
  reg IQ;

  table
// nextstate           G    NOTIFIER     : @IQ :          IQ
           0           1           ?       : ? :           0;
           1           1           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           0           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module TLAT_X1 (D, G, OE, Q);

  input D;
  input G;
  input OE;
  output Q;
  reg NOTIFIER;

  bufif0(Q, Q_in, Q_enable);
  not(Q_enable, OE);
  seq3(IQ, nextstate, G, NOTIFIER);
  not(IQN, IQ);
  buf(Q_in, IQ);
  buf(nextstate, D);


  specify
    (D => Q) = (0.1, 0.1);
    (posedge G => (Q +: D)) = (0.1, 0.1);
    (OE => Q) = (0.1, 0.1);

    $setuphold(negedge G, negedge D, 0.1, 0.1, NOTIFIER);
    $setuphold(negedge G, posedge D, 0.1, 0.1, NOTIFIER);
    $width(negedge D, 0.1, 0, NOTIFIER);
    $width(posedge D, 0.1, 0, NOTIFIER);
    $width(negedge G, 0.1, 0, NOTIFIER);
    $width(posedge G, 0.1, 0, NOTIFIER);
    $width(negedge OE, 0.1, 0, NOTIFIER);
    $width(posedge OE, 0.1, 0, NOTIFIER);
  endspecify

endmodule

module XNOR2_X1 (A, B, ZN);

  input A;
  input B;
  output ZN;

  not(ZN, i_46);
  xor(i_46, A, B);

  specify
    if((B == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b1)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b0)) (B => ZN) = (0.1, 0.1);
  endspecify

endmodule

module XNOR2_X2 (A, B, ZN);

  input A;
  input B;
  output ZN;

  not(ZN, i_46);
  xor(i_46, A, B);

  specify
    if((B == 1'b0)) (A => ZN) = (0.1, 0.1);
    if((B == 1'b1)) (A => ZN) = (0.1, 0.1);
    if((A == 1'b1)) (B => ZN) = (0.1, 0.1);
    if((A == 1'b0)) (B => ZN) = (0.1, 0.1);
  endspecify

endmodule

module XOR2_X1 (A, B, Z);

  input A;
  input B;
  output Z;

  xor(Z, A, B);

  specify
    if((B == 1'b0)) (A => Z) = (0.1, 0.1);
    if((B == 1'b1)) (A => Z) = (0.1, 0.1);
    if((A == 1'b1)) (B => Z) = (0.1, 0.1);
    if((A == 1'b0)) (B => Z) = (0.1, 0.1);
  endspecify

endmodule

module XOR2_X2 (A, B, Z);

  input A;
  input B;
  output Z;

  xor(Z, A, B);

  specify
    if((B == 1'b0)) (A => Z) = (0.1, 0.1);
    if((B == 1'b1)) (A => Z) = (0.1, 0.1);
    if((A == 1'b1)) (B => Z) = (0.1, 0.1);
    if((A == 1'b0)) (B => Z) = (0.1, 0.1);
  endspecify

endmodule

//
// End of file
//
