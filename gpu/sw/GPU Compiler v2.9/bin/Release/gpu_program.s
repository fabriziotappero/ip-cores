// Diego Andrés González Idárraga

#def tipo_addr    0
#def vs_data_addr 4
#def vs_size_addr 8
#def inicio_addr  12
#def count_addr   16
#def _1_addr      20
#def _2_addr      24
#def _3_addr      28
#def __1_addr     32
#def __2_addr     36
#def is_data_addr 40
#def is_size_addr 44
#def offset_addr  48
#def _1v_addr     52

#def _11_addr 56
#def _12_addr 60
#def _13_addr 64
#def _14_addr 68
#def _21_addr 72
#def _22_addr 76
#def _23_addr 80
#def _24_addr 84
#def _31_addr 88
#def _32_addr 92
#def _33_addr 96
#def _34_addr 100
#def _41_addr 104
#def _42_addr 108
#def _43_addr 112
#def _44_addr 116

#def use_texture_addr   120
#def texture_addr_addr  124
#def texture_ancho_addr 128
#def texture_alto_addr  132

#def grosor_addr 136

#def caras_sh_addr  140
#def caras_sah_addr 144

#def mitad_x_addr     148
#def mitad_y_addr     152
#def inv_mitad_x_addr 156
#def inv_mitad_y_addr 160

#def ancho_addr   164
#def alto_addr    168
#def ancho_1_addr 172
#def alto_1_addr  176

#def use_z_addr     180
#def use_alpha_addr 184

#def buffer_addr_addr  188
#def bufferZ_addr_addr 192

#def x1_addr     196
#def y1_addr     200
#def z1_addr     204
#def w1_addr     208
#def blue1_addr  212
#def green1_addr 216
#def red1_addr   220
#def alpha1_addr 224
#def x2_addr     228
#def y2_addr     232
#def z2_addr     236
#def w2_addr     240
#def blue2_addr  244
#def green2_addr 248
#def red2_addr   252
#def alpha2_addr 256
#def x3_addr     260
#def y3_addr     264
#def z3_addr     268
#def w3_addr     272
#def blue3_addr  276
#def green3_addr 280
#def red3_addr   284
#def alpha3_addr 288
#def xa_addr     292
#def ya_addr     296
#def za_addr     300
#def wa_addr     304
#def bluea_addr  308
#def greena_addr 312
#def reda_addr   316
#def alphaa_addr 320
#def xb_addr     324
#def yb_addr     328
#def zb_addr     332
#def wb_addr     336
#def blueb_addr  340
#def greenb_addr 344
#def redb_addr   348
#def alphab_addr 352

#def x1p_addr     356
#def y1p_addr     360
#def z1p_addr     364
#def blue1p_addr  368
#def green1p_addr 372
#def red1p_addr   376
#def alpha1p_addr 380
#def x2p_addr     384
#def y2p_addr     388
#def z2p_addr     392
#def blue2p_addr  396
#def green2p_addr 400
#def red2p_addr   404
#def alpha2p_addr 408
#def x3p_addr     412
#def y3p_addr     416
#def z3p_addr     420
#def blue3p_addr  424
#def green3p_addr 428
#def red3p_addr   432
#def alpha3p_addr 436

#def z_my_addr     440
#def z_mx_addr     444
#def z_b_addr      448
#def w_a_addr      452
#def w_b_addr      456
#def w_c_addr      460
#def w_d_addr      464
#def blue_my_addr  468
#def blue_mx_addr  472
#def blue_b_addr   476
#def green_my_addr 480
#def green_mx_addr 484
#def green_b_addr  488
#def red_my_addr   492
#def red_mx_addr   496
#def red_b_addr    500
#def alpha_my_addr 504
#def alpha_mx_addr 508
#def alpha_b_addr  512

#def stack_init 1020

#def stack r31

ploadaddr_l stack_init;
loadaddr_h stack_init, stack;

//________________________________

plt_iplt:

#def v1 r0
#def v2 r22
#def v3 r23
#def tipo r1
#def vs_data r2
#def vs_size r3
#def i r4
#def count r5
#def _1 r6
#def _2 r7
#def _3 r8
#def __1 r9
#def __2 r10
#def is_data r11
#def is_size r12
#def offset r13
#def _1v r14
#def use_texture r15
#def j r16
#def case r17
#def aux1 r18
#def aux2 r19
#def sentido r20

    plt_iplt_loop:
        ploadaddr_l tipo_addr;
        loadaddr_h tipo_addr, tipo;
        load tipo, tipo;
        i_load vs_data;
        i_load vs_size;
        i_load i;
        i_load count;
        i_load _1;
        i_load _2;
        i_load _3;
        i_load __1;
        i_load __2;
        i_load is_data;
        i_load is_size;
        i_load offset;
        i_load _1v;

        fcomp_g 0.f, tipo, cr7;
        [cr7] fneg tipo, tipo;
        ploadaddr_l use_texture_addr;
        loadaddr_h use_texture_addr, use_texture;
        load use_texture, use_texture;
        fcomp_ne 0.f, use_texture, cr6;
        copy 0.f, j;

        plt_iplt_switch1:
        fmulp2 1.f, 0, case;
        fcomp_e tipo, case, cr0;
        [cr0] jump plt_iplt_case1_LISTA_PUNTOS;
        [cr0] nop;
        fmulp2 1.f, 1, case;
        fcomp_e tipo, case, cr0;
        [cr0] jump plt_iplt_case1_LISTA_LINEAS;
        [cr0] nop;
        fmulp2 1.f, 2, case;
        fcomp_e tipo, case, cr0;
        [cr0] jump plt_iplt_case1_TIRA_LINEAS;
        [cr0] nop;
        fmulp2 1.f, 3, case;
        fcomp_e tipo, case, cr0;
        [cr0] jump plt_iplt_case1_LISTA_TRIANGULOS;
        [cr0] nop;
        fmulp2 1.f, 4, case;
        fcomp_e tipo, case, cr0;
        [cr0] jump plt_iplt_case1_TIRA_TRIANGULOS;
        [cr0] nop;
        fmulp2 1.f, 5, case;
        fcomp_e tipo, case, cr0;
        [cr0] jump plt_iplt_case1_ABANICO_TRIANGULOS;
        [cr0] nop;
        jump plt_iplt_default1;
        nop;
        plt_iplt_case1_LISTA_PUNTOS:
            plt_iplt_while1:
            u32tof i, aux1;
            [cr7] fcomp_l aux1, vs_size, cr0;
            [!cr7] fcomp_l aux1, is_size, cr0;
            [cr0] fcomp_l j, count, cr0;
            [!cr0] jump plt_iplt_end_while1;
            [!cr0] nop;
                [cr7] add vs_data, i, v1;

                plt_iplt_else1:
                [cr7] jump plt_iplt_end_if1;
                [cr7] nop;
                    add is_data, i, v1;
                    load v1, v1;
                    u32tof _1, aux1;
                    fmulp2 aux1, 3, aux1;
                    fmulp2 1.f, 3, aux2;
                    fcomp_e aux1, aux2, cr0;
                    fmulp2 1.f, 4, aux2;
                    fcomp_e aux1, aux2, cr1;
                    fmulp2 1.f, 5, aux2;
                    fcomp_e aux1, aux2, cr2;
                    [cr0] u8tof_ll v1, v1;
                    [cr1] u16tof_l v1, v1;
                    [cr2] u32tof v1, v1;
                    fmul v1, _1v, v1;
                    nop;
                    nop;
                    ftou32 v1, v1;
                    add vs_data, v1, v1;
                    add v1, offset, v1;
                plt_iplt_end_if1:

                store_addr stack;
                push vs_data;
                [cr7] push vs_size;
                push count;
                push _1;
                [!cr7] push is_data;
                [!cr7] push is_size;
                [!cr7] push offset;
                [!cr7] push _1v;
                push i;
                push j;
                load_addr stack;

                store_addr stack;
                rcall punto;
                load_addr stack;

                store_addr stack;
                pop j;
                pop i;
                [!cr7] pop _1v;
                [!cr7] pop offset;
                [!cr7] pop is_size;
                [!cr7] pop is_data;
                pop _1;
                pop count;
                [cr7] pop vs_size;
                pop vs_data;
                load_addr stack;

                add i, _1, i;
                fadd 1.f, j, j;
            jump plt_iplt_while1;
            nop;
            plt_iplt_end_while1:

            jump plt_iplt_end_switch1;
            nop;
        plt_iplt_case1_LISTA_LINEAS:
            add i, _1, i;

            plt_iplt_while2:
            u32tof i, aux1;
            [cr7] fcomp_l aux1, vs_size, cr0;
            [!cr7] fcomp_l aux1, is_size, cr0;
            [cr0] fcomp_l j, count, cr0;
            [!cr0] jump plt_iplt_end_while2;
            [!cr0] nop;
                [cr7] add vs_data, i, v2;
                [!cr7] add is_data, i, v2;
                add v2, __1, v1;

                plt_iplt_else2:
                [cr7] jump plt_iplt_end_if2;
                [cr7] nop;
                    load v2, v2;
                    load v1, v1;
                    u32tof _1, aux1;
                    fmulp2 aux1, 3, aux1;
                    fmulp2 1.f, 3, aux2;
                    fcomp_e aux1, aux2, cr0;
                    fmulp2 1.f, 4, aux2;
                    fcomp_e aux1, aux2, cr1;
                    fmulp2 1.f, 5, aux2;
                    fcomp_e aux1, aux2, cr2;
                    [cr0] u8tof_ll v2, v2;
                    [cr0] u8tof_ll v1, v1;
                    [cr1] u16tof_l v2, v2;
                    [cr1] u16tof_l v1, v1;
                    [cr2] u32tof v2, v2;
                    [cr2] u32tof v1, v1;
                    fmul v2, _1v, v2;
                    fmul v1, _1v, v1;
                    nop;
                    nop;
                    ftou32 v2, v2;
                    ftou32 v1, v1;
                    add vs_data, v2, v2;
                    add vs_data, v1, v1;
                    add v2, offset, v2;
                    add v1, offset, v1;
                plt_iplt_end_if2:

                store_addr stack;
                push vs_data;
                [cr7] push vs_size;
                push count;
                [!cr7] push _1;
                push _2;
                push __1;
                [!cr7] push is_data;
                [!cr7] push is_size;
                [!cr7] push offset;
                [!cr7] push _1v;
                push i;
                push j;
                load_addr stack;

                store_addr stack;
                rcall linea;
                load_addr stack;

                store_addr stack;
                pop j;
                pop i;
                [!cr7] pop _1v;
                [!cr7] pop offset;
                [!cr7] pop is_size;
                [!cr7] pop is_data;
                pop __1;
                pop _2;
                [!cr7] pop _1;
                pop count;
                [cr7] pop vs_size;
                pop vs_data;
                load_addr stack;

                add i, _2, i;
                fadd 1.f, j, j;
            jump plt_iplt_while2;
            nop;
            plt_iplt_end_while2:

            jump plt_iplt_end_switch1;
            nop;
        plt_iplt_case1_TIRA_LINEAS:
            add i, _1, i;

            plt_iplt_while3:
            u32tof i, aux1;
            [cr7] fcomp_l aux1, vs_size, cr0;
            [!cr7] fcomp_l aux1, is_size, cr0;
            [cr0] fcomp_l j, count, cr0;
            [!cr0] jump plt_iplt_end_while3;
            [!cr0] nop;
                [cr7] add vs_data, i, v2;
                [!cr7] add is_data, i, v2;
                add v2, __1, v1;

                plt_iplt_else3:
                [cr7] jump plt_iplt_end_if3;
                [cr7] nop;
                    load v2, v2;
                    load v1, v1;
                    u32tof _1, aux1;
                    fmulp2 aux1, 3, aux1;
                    fmulp2 1.f, 3, aux2;
                    fcomp_e aux1, aux2, cr0;
                    fmulp2 1.f, 4, aux2;
                    fcomp_e aux1, aux2, cr1;
                    fmulp2 1.f, 5, aux2;
                    fcomp_e aux1, aux2, cr2;
                    [cr0] u8tof_ll v2, v2;
                    [cr0] u8tof_ll v1, v1;
                    [cr1] u16tof_l v2, v2;
                    [cr1] u16tof_l v1, v1;
                    [cr2] u32tof v2, v2;
                    [cr2] u32tof v1, v1;
                    fmul v2, _1v, v2;
                    fmul v1, _1v, v1;
                    nop;
                    nop;
                    ftou32 v2, v2;
                    ftou32 v1, v1;
                    add vs_data, v2, v2;
                    add vs_data, v1, v1;
                    add v2, offset, v2;
                    add v1, offset, v1;
                plt_iplt_end_if3:

                store_addr stack;
                push vs_data;
                [cr7] push vs_size;
                push count;
                push _1;
                push __1;
                [!cr7] push is_data;
                [!cr7] push is_size;
                [!cr7] push offset;
                [!cr7] push _1v;
                push i;
                push j;
                load_addr stack;

                store_addr stack;
                rcall linea;
                load_addr stack;

                store_addr stack;
                pop j;
                pop i;
                [!cr7] pop _1v;
                [!cr7] pop offset;
                [!cr7] pop is_size;
                [!cr7] pop is_data;
                pop __1;
                pop _1;
                pop count;
                [cr7] pop vs_size;
                pop vs_data;
                load_addr stack;

                add i, _1, i;
                fadd 1.f, j, j;
            jump plt_iplt_while3;
            nop;
            plt_iplt_end_while3:

            jump plt_iplt_end_switch1;
            nop;
        plt_iplt_case1_LISTA_TRIANGULOS:
            add i, _2, i;

            plt_iplt_while4:
            u32tof i, aux1;
            [cr7] fcomp_l aux1, vs_size, cr0;
            [!cr7] fcomp_l aux1, is_size, cr0;
            [cr0] fcomp_l j, count, cr0;
            [!cr0] jump plt_iplt_end_while4;
            [!cr0] nop;
                [cr7] add vs_data, i, v3;
                [!cr7] add is_data, i, v3;
                add v3, __1, v2;
                add v3, __2, v1;

                plt_iplt_else4:
                [cr7] jump plt_iplt_end_if4;
                [cr7] nop;
                    load v3, v3;
                    load v2, v2;
                    load v1, v1;
                    u32tof _1, aux1;
                    fmulp2 aux1, 3, aux1;
                    fmulp2 1.f, 3, aux2;
                    fcomp_e aux1, aux2, cr0;
                    fmulp2 1.f, 4, aux2;
                    fcomp_e aux1, aux2, cr1;
                    fmulp2 1.f, 5, aux2;
                    fcomp_e aux1, aux2, cr2;
                    [cr0] u8tof_ll v3, v3;
                    [cr0] u8tof_ll v2, v2;
                    [cr0] u8tof_ll v1, v1;
                    [cr1] u16tof_l v3, v3;
                    [cr1] u16tof_l v2, v2;
                    [cr1] u16tof_l v1, v1;
                    [cr2] u32tof v3, v3;
                    [cr2] u32tof v2, v2;
                    [cr2] u32tof v1, v1;
                    fmul v3, _1v, v3;
                    fmul v2, _1v, v2;
                    fmul v1, _1v, v1;
                    nop;
                    nop;
                    ftou32 v3, v3;
                    ftou32 v2, v2;
                    ftou32 v1, v1;
                    add vs_data, v3, v3;
                    add vs_data, v2, v2;
                    add vs_data, v1, v1;
                    add v3, offset, v3;
                    add v2, offset, v2;
                    add v1, offset, v1;
                plt_iplt_end_if4:

                store_addr stack;
                push vs_data;
                [cr7] push vs_size;
                push count;
                [!cr7] push _1;
                push _3;
                push __1;
                push __2;
                [!cr7] push is_data;
                [!cr7] push is_size;
                [!cr7] push offset;
                [!cr7] push _1v;
                push i;
                push j;
                load_addr stack;

                store_addr stack;
                rcall triangulo;
                load_addr stack;

                store_addr stack;
                pop j;
                pop i;
                [!cr7] pop _1v;
                [!cr7] pop offset;
                [!cr7] pop is_size;
                [!cr7] pop is_data;
                pop __2;
                pop __1;
                pop _3;
                [!cr7] pop _1;
                pop count;
                [cr7] pop vs_size;
                pop vs_data;
                load_addr stack;

                add i, _3, i;
                fadd 1.f, j, j;
            jump plt_iplt_while4;
            nop;
            plt_iplt_end_while4:

            jump plt_iplt_end_switch1;
            nop;
        plt_iplt_case1_TIRA_TRIANGULOS:
            copy 1.f, sentido;
            add i, _2, i;

            plt_iplt_while5:
            u32tof i, aux1;
            [cr7] fcomp_l aux1, vs_size, cr0;
            [!cr7] fcomp_l aux1, is_size, cr0;
            [cr0] fcomp_l j, count, cr0;
            [!cr0] jump plt_iplt_end_while5;
            [!cr0] nop;
                [cr7] add vs_data, i, v3;
                [!cr7] add is_data, i, v3;

                fcomp_ne 0.f, sentido, cr0;
                [cr0] add v3, __1, v2;
                [cr0] add v3, __2, v1;
                [cr0] copy 0.f, sentido;
                [!cr0] add v3, __2, v2;
                [!cr0] add v3, __1, v1;
                [!cr0] copy 1.f, sentido;

                plt_iplt_else5:
                [cr7] jump plt_iplt_end_if5;
                [cr7] nop;
                    load v3, v3;
                    load v2, v2;
                    load v1, v1;
                    u32tof _1, aux1;
                    fmulp2 aux1, 3, aux1;
                    fmulp2 1.f, 3, aux2;
                    fcomp_e aux1, aux2, cr0;
                    fmulp2 1.f, 4, aux2;
                    fcomp_e aux1, aux2, cr1;
                    fmulp2 1.f, 5, aux2;
                    fcomp_e aux1, aux2, cr2;
                    [cr0] u8tof_ll v3, v3;
                    [cr0] u8tof_ll v2, v2;
                    [cr0] u8tof_ll v1, v1;
                    [cr1] u16tof_l v3, v3;
                    [cr1] u16tof_l v2, v2;
                    [cr1] u16tof_l v1, v1;
                    [cr2] u32tof v3, v3;
                    [cr2] u32tof v2, v2;
                    [cr2] u32tof v1, v1;
                    fmul v3, _1v, v3;
                    fmul v2, _1v, v2;
                    fmul v1, _1v, v1;
                    nop;
                    nop;
                    ftou32 v3, v3;
                    ftou32 v2, v2;
                    ftou32 v1, v1;
                    add vs_data, v3, v3;
                    add vs_data, v2, v2;
                    add vs_data, v1, v1;
                    add v3, offset, v3;
                    add v2, offset, v2;
                    add v1, offset, v1;
                plt_iplt_end_if5:

                store_addr stack;
                push vs_data;
                [cr7] push vs_size;
                push count;
                push _1;
                push __1;
                push __2;
                [!cr7] push is_data;
                [!cr7] push is_size;
                [!cr7] push offset;
                [!cr7] push _1v;
                push i;
                push j;
                push sentido;
                load_addr stack;

                store_addr stack;
                rcall triangulo;
                load_addr stack;

                store_addr stack;
                pop sentido;
                pop j;
                pop i;
                [!cr7] pop _1v;
                [!cr7] pop offset;
                [!cr7] pop is_size;
                [!cr7] pop is_data;
                pop __2;
                pop __1;
                pop _1;
                pop count;
                [cr7] pop vs_size;
                pop vs_data;
                load_addr stack;

                add i, _1, i;
                fadd 1.f, j, j;
            jump plt_iplt_while5;
            nop;
            plt_iplt_end_while5:

            jump plt_iplt_end_switch1;
            nop;
        plt_iplt_case1_ABANICO_TRIANGULOS:
            [cr7] add vs_data, i, v1;
            [!cr7] add is_data, i, v1;
            [!cr7] load v1, v1;
            fcomp_o nan, r0, cr0;
            fcomp_o nan, r0, cr1;
            fcomp_o nan, r0, cr2;
            [!cr7] u32tof _1, aux1;
            [!cr7] fmulp2 aux1, 3, aux1;
            [!cr7] fmulp2 1.f, 3, aux2;
            [!cr7] fcomp_e aux1, aux2, cr0;
            [!cr7] fmulp2 1.f, 4, aux2;
            [!cr7] fcomp_e aux1, aux2, cr1;
            [!cr7] fmulp2 1.f, 5, aux2;
            [!cr7] fcomp_e aux1, aux2, cr2;
            [cr0] u8tof_ll v1, v1;
            [cr1] u16tof_l v1, v1;
            [cr2] u32tof v1, v1;
            [!cr7] fmul v1, _1v, v1;
            [!cr7] nop;
            [!cr7] nop;
            [!cr7] ftou32 v1, v1;
            [!cr7] add vs_data, v1, v1;
            [!cr7] add v1, offset, v1;
            add i, _2, i;

            plt_iplt_while6:
            u32tof i, aux1;
            [cr7] fcomp_l aux1, vs_size, cr0;
            [!cr7] fcomp_l aux1, is_size, cr0;
            [cr0] fcomp_l j, count, cr0;
            [!cr0] jump plt_iplt_end_while6;
            [!cr0] nop;
                [cr7] add vs_data, i, v3;
                [!cr7] add is_data, i, v3;
                add v3, __1, v2;

                plt_iplt_else6:
                [cr7] jump plt_iplt_end_if6;
                [cr7] nop;
                    load v3, v3;
                    load v2, v2;
                    u32tof _1, aux1;
                    fmulp2 aux1, 3, aux1;
                    fmulp2 1.f, 3, aux2;
                    fcomp_e aux1, aux2, cr0;
                    fmulp2 1.f, 4, aux2;
                    fcomp_e aux1, aux2, cr1;
                    fmulp2 1.f, 5, aux2;
                    fcomp_e aux1, aux2, cr2;
                    [cr0] u8tof_ll v3, v3;
                    [cr0] u8tof_ll v2, v2;
                    [cr1] u16tof_l v3, v3;
                    [cr1] u16tof_l v2, v2;
                    [cr2] u32tof v3, v3;
                    [cr2] u32tof v2, v2;
                    fmul v3, _1v, v3;
                    fmul v2, _1v, v2;
                    nop;
                    nop;
                    ftou32 v3, v3;
                    ftou32 v2, v2;
                    add vs_data, v3, v3;
                    add vs_data, v2, v2;
                    add v3, offset, v3;
                    add v2, offset, v2;
                plt_iplt_end_if6:

                store_addr stack;
                push v1;
                push vs_data;
                [cr7] push vs_size;
                push count;
                push _1;
                push __1;
                [!cr7] push is_data;
                [!cr7] push is_size;
                [!cr7] push offset;
                [!cr7] push _1v;
                push i;
                push j;
                load_addr stack;

                store_addr stack;
                rcall triangulo;
                load_addr stack;

                store_addr stack;
                pop j;
                pop i;
                [!cr7] pop _1v;
                [!cr7] pop offset;
                [!cr7] pop is_size;
                [!cr7] pop is_data;
                pop __1;
                pop _1;
                pop count;
                [cr7] pop vs_size;
                pop vs_data;
                pop v1;
                load_addr stack;

                add i, _1, i;
                fadd 1.f, j, j;
            jump plt_iplt_while6;
            nop;
            plt_iplt_end_while6:

            jump plt_iplt_end_switch1;
            nop;
        plt_iplt_default1:
        plt_iplt_end_switch1:

        irq;
        stop_core;
    jump plt_iplt_loop;
    nop;

#undef v1
#undef v2
#undef v3
#undef tipo
#undef vs_data
#undef vs_size
#undef i
#undef count
#undef _1
#undef _2
#undef _3
#undef __1
#undef __2
#undef is_data
#undef is_size
#undef offset
#undef _1v
#undef use_texture
#undef j
#undef case
#undef aux1
#undef aux2
#undef sentido

store_addr stack;
ret;
load_addr stack;

//________________________________

punto:

#def raddr r0
#def x r2
#def y r3
#def z r4
#def w r5
#def color r6
#def blue r7
#def green r8
#def red r9
#def alpha r10

    fcomp_o nan, r0, cr0;
    store_addr stack;
    rcall vs_main;
    load_addr stack;

    fcomp_g 0.f, z, cr0;
    [!cr0] fcomp_l 1.f, z, cr0;
    [cr0] store_addr stack;
    [cr0] ret;
    [cr0] load_addr stack;

#undef raddr
#def mitad_x r0
#def mitad_y r1
#def grosor r11
#def x_min r12
#def ypt r13
#def x_max r14
#def y_max r15
#def ancho_1 r16
#def alto_1 r17
#def ancho r18
#def use_z r19
#def use_alpha r20
#def buffer_addr r21
#def bufferZ_addr r22
#def texture_addr r23
#def texture_ancho r24
#def texture_alto r25

    fdiv x, w, x;
    fdiv y, w, y;

    ploadaddr_l mitad_x_addr;
    loadaddr_h mitad_x_addr, mitad_x;
    load mitad_x, mitad_x;
    i_load mitad_y;

    ploadaddr_l grosor_addr;
    loadaddr_h grosor_addr, grosor;
    load grosor, grosor;

    fmulp2 grosor, -1, grosor;
    nop;
    fmul mitad_x, x, x;
    fmul mitad_y, y, y;
    nop;
    fadd x, mitad_x, x;
    fadd y, mitad_y, y;
    nop;
    fsub x, grosor, x_min;
    fsub y, grosor, ypt;
    fadd x, grosor, x_max;
    fadd y, grosor, y_max;
    nop;
    nop;

    ploadaddr_l ancho_1_addr;
    loadaddr_h ancho_1_addr, ancho_1;
    load ancho_1, ancho_1;
    i_load alto_1;

    fcomp_le x_min, ancho_1, cr0;
    [cr0] fcomp_le 0.f, x_max, cr0;
    [cr0] fcomp_le ypt, alto_1, cr0;
    [cr0] fcomp_le 0.f, y_max, cr0;
    [!cr0] store_addr stack;
    [!cr0] ret;
    [!cr0] load_addr stack;

    ploadaddr_l ancho_addr;
    loadaddr_h ancho_addr, ancho;
    load ancho, ancho;

    ceil x_min, x_min;
    ceil ypt, ypt;
    floor x_max, x_max;
    floor y_max, y_max;
    fmax 0.f, x_min, x_min;
    fmax 0.f, ypt, ypt;
    fmin x_max, ancho_1, x_max;
    fmin y_max, alto_1, y_max;

    ploadaddr_l use_z_addr;
    loadaddr_h use_z_addr, use_z;
    load use_z, use_z;
    i_load use_alpha;

    fcomp_ne 0.f, use_z, cr1;
    fcomp_ne 0.f, use_alpha, cr2;

    ploadaddr_l buffer_addr_addr;
    loadaddr_h buffer_addr_addr, buffer_addr;
    load buffer_addr, buffer_addr;
    i_load bufferZ_addr;

    punto_if1:
    [!cr6] jump punto_end_if1;
    [!cr6] nop;
        ploadaddr_l texture_addr_addr;
        loadaddr_h texture_addr_addr, texture_addr;
        load texture_addr, texture_addr;
        i_load texture_ancho;
        i_load texture_alto;

        floor blue, red;
        floor green, alpha;
        fsub blue, red, blue;
        fsub green, alpha, green;
        nop;
        fmul blue, texture_ancho, blue;
        fmul green, texture_alto, green;
        nop;
        nop;
        trunc blue, blue;
        trunc green, green;
        fmul texture_ancho, green, green;
        nop;
        nop;
        fadd green, blue, blue;
        nop;
        nop;
        ftou32 blue, blue;
        add blue, blue, blue;
        add blue, blue, blue;
        add texture_addr, blue, alpha;
        load alpha, color;
    punto_end_if1:

#undef x
#undef y
#undef w
#undef mitad_x
#undef mitad_y
#undef grosor
#undef ancho_1
#undef use_z
#undef use_alpha
#undef texture_addr
#undef texture_ancho
#undef texture_alto
#def xpt r0
#def i r1
#def aux1 r2
#def aux2 r3
#def Z r5
#def Color r11
#def Blue r16
#def Green r19
#def Red r20
#def Alpha r23
#def aux3 r24

    punto_while1:
    fcomp_le ypt, y_max, cr0;
    [!cr0] jump punto_end_while1;
    [!cr0] nop;
        copy x_min, xpt;
        fsub alto_1, ypt, aux3;
        nop;
        nop;
        fmul ancho, aux3, aux3;

        punto_while2:
        fcomp_le xpt, x_max, cr0;
        [!cr0] jump punto_end_while2;
        [!cr0] nop;
            fadd aux3, xpt, i;
            nop;
            nop;
            ftou32 i, i;
            add i, i, i;
            add i, i, i;
            add buffer_addr, i, aux1;
            [cr1] add bufferZ_addr, i, aux2;
            [cr1] load aux2, Z;

            u8tof_ll color, blue;
            u8tof_lh color, green;
            u8tof_hl color, red;
            u8tof_hh color, alpha;

            punto_if2:
            [!cr2] jump punto_end_if2;
            [!cr2] nop;
                load aux1, Color;
                u8tof_ll Color, Blue;
                u8tof_lh Color, Green;
                u8tof_hl Color, Red;
                fmulp2 alpha, -8, alpha;
                fsub 1.f, alpha, Alpha;
                fmul alpha, blue, blue;
                fmul alpha, green, green;
                fmul alpha, red, red;
                fmul Alpha, Blue, Blue;
                fmul Alpha, Green, Green;
                fmul Alpha, Red, Red;
                fadd blue, Blue, blue;
                fadd green, Green, green;
                fadd red, Red, red;
                nop;
                nop;
            punto_end_if2:

            ftou8_ll blue, Color, Color;
            ftou8_lh green, Color, Color;
            ftou8_hl red, Color, Color;

            [cr1] fcomp_l z, Z, cr0;
            [!cr1] fcomp_u nan, r0, cr0;
            [cr0] store Color, aux1;
            [!cr1] fcomp_o nan, r0, cr0;
            [cr0] store z, aux2;

            fadd 1.f, xpt, xpt;
        jump punto_while2;
        nop;
        punto_end_while2:

        fadd 1.f, ypt, ypt;
    jump punto_while1;
    nop;
    punto_end_while1:

#undef z
#undef color
#undef blue
#undef green
#undef red
#undef alpha
#undef x_min
#undef ypt
#undef x_max
#undef y_max
#undef alto_1
#undef ancho
#undef buffer_addr
#undef bufferZ_addr
#undef xpt
#undef i
#undef aux1
#undef aux2
#undef Z
#undef Color
#undef Blue
#undef Green
#undef Red
#undef Alpha
#undef aux3

store_addr stack;
ret;
load_addr stack;

//________________________________

linea:

#def raddr1 r0
#def raddr2 r22
#def waddr r1
#def z r4
#def z1 r26
#def z2 r27

    fcomp_u nan, r0, cr0;

    ploadaddr_l x1_addr;
    loadaddr_h x1_addr, waddr;
    store_addr stack;
    rcall vs_main;
    load_addr stack;
    copy z, z1;

    copy raddr2, raddr1;
    ploadaddr_l x2_addr;
    loadaddr_h x2_addr, waddr;
    store_addr stack;
    rcall vs_main;
    load_addr stack;
    copy z, z2;

#undef raddr1
#undef raddr2
#undef waddr
#undef z
#def raddr1 r0
#def raddr2 r1
#def z r2
#def waddr r3

    linea_if1:
    fcomp_g 0.f, z1, cr0;
    [!cr0] jump linea_else1;
    [!cr0] nop;
        fcomp_g 0.f, z2, cr0;
            [cr0] store_addr stack;
            [cr0] ret;
            [cr0] load_addr stack;

        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        copy 0.f, z;
        copy raddr1, waddr;
        store_addr stack;
        rcall vz;
        load_addr stack;

        fcomp_l 1.f, z2, cr0;
            [cr0] ploadaddr_l x2_addr;
            [cr0] loadaddr_h x2_addr, raddr1;
            [cr0] ploadaddr_l x1_addr;
            [cr0] loadaddr_h x1_addr, raddr2;
            [cr0] copy 1.f, z;
            [cr0] copy raddr1, waddr;
            [cr0] store_addr stack;
            [cr0] rcall vz;
            [cr0] load_addr stack;
    jump linea_end_if1;
    nop;
    linea_else1:
    linea_if2:
    fcomp_g 0.f, z2, cr0;
    [!cr0] jump linea_else2;
    [!cr0] nop;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr1;
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr2;
        copy 0.f, z;
        copy raddr1, waddr;
        store_addr stack;
        rcall vz;
        load_addr stack;

        fcomp_l 1.f, z1, cr0;
            [cr0] ploadaddr_l x1_addr;
            [cr0] loadaddr_h x1_addr, raddr1;
            [cr0] ploadaddr_l x2_addr;
            [cr0] loadaddr_h x2_addr, raddr2;
            [cr0] copy 1.f, z;
            [cr0] copy raddr1, waddr;
            [cr0] store_addr stack;
            [cr0] rcall vz;
            [cr0] load_addr stack;
    jump linea_end_if2;
    nop;
    linea_else2:
    linea_if3:
    fcomp_l 1.f, z1, cr0;
    [!cr0] jump linea_else3;
    [!cr0] nop;
        fcomp_l 1.f, z2, cr0;
            [cr0] store_addr stack;
            [cr0] ret;
            [cr0] load_addr stack;

        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        copy 1.f, z;
        copy raddr1, waddr;
        store_addr stack;
        rcall vz;
        load_addr stack;
    jump linea_end_if3;
    nop;
    linea_else3:
    fcomp_l 1.f, z2, cr0;
        [cr0] ploadaddr_l x2_addr;
        [cr0] loadaddr_h x2_addr, raddr1;
        [cr0] ploadaddr_l x1_addr;
        [cr0] loadaddr_h x1_addr, raddr2;
        [cr0] copy 1.f, z;
        [cr0] copy raddr1, waddr;
        [cr0] store_addr stack;
        [cr0] rcall vz;
        [cr0] load_addr stack;
    linea_end_if3:
    linea_end_if2:
    linea_end_if1:

#undef z1
#undef z2
#undef raddr1
#undef raddr2
#undef z
#undef waddr
#def x1 r0
#def y1 r1
#def z1 r2
#def w1 r3
#def x2 r4
#def y2 r5
#def z2 r6
#def w2 r7
#def grosor r8
#def aux1 r9
#def aux2 r10
#def aux3 r11
#def aux4 r12
#def ancho r13
#def alto r14
#def d1x r15
#def d1y r16
#def d2x r17
#def d2y r18
#def dx r19
#def dy r20

    ploadaddr_l x1_addr;
    loadaddr_h x1_addr, x1;
    load x1, x1;
    i_load y1;
    i_load z1;
    i_load w1;

    ploadaddr_l x2_addr;
    loadaddr_h x2_addr, x2;
    load x2, x2;
    i_load y2;
    i_load z2;
    i_load w2;

    ploadaddr_l grosor_addr;
    loadaddr_h grosor_addr, grosor;
    load grosor, grosor;

    fdiv y1, w1, aux1;
    fdiv y2, w2, aux2;
    fdiv x2, w2, aux3;
    fdiv x1, w1, aux4;

    ploadaddr_l ancho_addr;
    loadaddr_h ancho_addr, ancho;
    load ancho, ancho;
    i_load alto;

    nop;
    nop;
    nop;
    nop;
    fsub aux1, aux2, dx;
    nop;
    fsub aux3, aux4, dy;
    fmul grosor, dx, d1x;
    fmul grosor, dx, d2x;
    fmul grosor, dy, d1y;
    fmul grosor, dy, d2y;
    fmul w1, d1x, d1x;
    fmul w2, d2x, d2x;
    fmul w1, d1y, d1y;
    fmul w2, d2y, d2y;
    nop;
    nop;
    fabs dx, aux1;
    fabs dy, aux2;
    fmin aux1, aux2, aux3;
    fmax aux1, aux2, aux4;
    fmulp2 aux3, -2, aux3;
    fadd aux4, aux3, aux1;
    nop;
    nop;
    fmul aux1, ancho, dx;
    fmul aux1, alto, dy;
    nop;
    fdiv d1x, dx, d1x;
    fdiv d2x, dx, d2x;
    fdiv d1y, dy, d1y;
    fdiv d2y, dy, d2y;

#undef grosor
#undef aux1
#undef aux2
#undef aux3
#undef aux4
#undef ancho
#undef alto
#undef dx
#undef dy
#def x1__d1x r8
#def x1_d1x r9
#def y1__d1y r10
#def y1_d1y r11
#def x2__d2x r12
#def x2_d2x r13
#def y2__d2y r14
#def y2_d2y r19
#def blue1 r20
#def green1 r21
#def red1 r22
#def alpha1 r23
#def blue2 r24
#def green2 r25
#def red2 r26
#def alpha2 r27
#def addr r28

    ploadaddr_l blue1_addr;
    loadaddr_h blue1_addr, blue1;
    load blue1, blue1;
    i_load green1;
    i_load red1;
    i_load alpha1;

    nop;
    nop;
    fsub x1, d1x, x1__d1x;
    fadd x1, d1x, x1_d1x;
    fsub x2, d2x, x2__d2x;
    fadd x2, d2x, x2_d2x;
    fsub y1, d1y, y1__d1y;
    fadd y1, d1y, y1_d1y;
    fsub y2, d2y, y2__d2y;
    fadd y2, d2y, y2_d2y;
    nop;
    nop;

    ploadaddr_l blue2_addr;
    loadaddr_h blue2_addr, blue2;
    load blue2, blue2;
    i_load green2;
    i_load red2;
    i_load alpha2;

    ploadaddr_l x1_addr;
    loadaddr_h x1_addr, addr;
    store x1__d1x, addr;
    i_store y1__d1y;

    ploadaddr_l x2_addr;
    loadaddr_h x2_addr, addr;
    store x2__d2x, addr;
    i_store y2__d2y;

    ploadaddr_l x3_addr;
    loadaddr_h x3_addr, addr;
    store x2_d2x, addr;
    i_store y2_d2y;
    i_store z2;
    i_store w2;
    i_store blue2;
    i_store green2;
    i_store red2;
    i_store alpha2;
    i_store x1_d1x;
    i_store y1_d1y;
    i_store z1;
    i_store w1;
    i_store blue1;
    i_store green1;
    i_store red1;
    i_store alpha1;

#undef x1
#undef y1
#undef z1
#undef w1
#undef x2
#undef y2
#undef z2
#undef w2
#undef d1x
#undef d1y
#undef d2x
#undef d2y
#undef x1__d1x
#undef x1_d1x
#undef y1__d1y
#undef y1_d1y
#undef x2__d2x
#undef x2_d2x
#undef y2__d2y
#undef y2_d2y
#undef blue1
#undef green1
#undef red1
#undef alpha1
#undef blue2
#undef green2
#undef red2
#undef alpha2
#undef addr
#def raddr1 r0
#def raddr2 r1
#def raddr3 r2

    ploadaddr_l x1_addr;
    loadaddr_h x1_addr, raddr1;
    ploadaddr_l x2_addr;
    loadaddr_h x2_addr, raddr2;
    ploadaddr_l x3_addr;
    loadaddr_h x3_addr, raddr3;
    fcomp_o nan, r0, cr0;
    store_addr stack;
    rcall triangulo_p;
    load_addr stack;

    ploadaddr_l x3_addr;
    loadaddr_h x3_addr, raddr1;
    ploadaddr_l xa_addr;
    loadaddr_h xa_addr, raddr2;
    ploadaddr_l x1_addr;
    loadaddr_h x1_addr, raddr3;
    fcomp_o nan, r0, cr0;
    store_addr stack;
    rcall triangulo_p;
    load_addr stack;

#undef raddr1
#undef raddr2
#undef raddr3

store_addr stack;
ret;
load_addr stack;

//________________________________

triangulo:

#def raddr1 r0
#def raddr2 r22
#def raddr3 r23
#def waddr r1
#def z r4
#def z1 r26
#def z2 r27
#def z3 r28

    fcomp_u nan, r0, cr0;

    ploadaddr_l x1_addr;
    loadaddr_h x1_addr, waddr;
    store_addr stack;
    rcall vs_main;
    load_addr stack;
    copy z, z1;

    copy raddr2, raddr1;
    ploadaddr_l x2_addr;
    loadaddr_h x2_addr, waddr;
    store_addr stack;
    rcall vs_main;
    load_addr stack;
    copy z, z2;

    copy raddr3, raddr1;
    ploadaddr_l x3_addr;
    loadaddr_h x3_addr, waddr;
    store_addr stack;
    rcall vs_main;
    load_addr stack;
    copy z, z3;

#undef raddr1
#undef raddr2
#undef raddr3
#undef waddr
#undef z
#def vst r29
#def raddr1 r0
#def raddr2 r1
#def z r2
#def waddr r3

    fmulp2 1.f, 0, vst;

    triangulo_if1:
    fcomp_g 0.f, z1, cr0;
    [!cr0] jump triangulo_else1;
    [!cr0] nop;
        triangulo_if2:
        fcomp_g 0.f, z2, cr0;
        [!cr0] jump triangulo_else2;
        [!cr0] nop;
            fcomp_g 0.f, z3, cr0;
                [cr0] store_addr stack;
                [cr0] ret;
                [cr0] load_addr stack;

            ploadaddr_l x1_addr;
            loadaddr_h x1_addr, raddr1;
            ploadaddr_l x3_addr;
            loadaddr_h x3_addr, raddr2;
            copy 0.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            ploadaddr_l x2_addr;
            loadaddr_h x2_addr, raddr1;
            ploadaddr_l x3_addr;
            loadaddr_h x3_addr, raddr2;
            copy 0.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            fcomp_l 1.f, z3, cr0;
                [cr0] fmulp2 1.f, 3, vst;

                [cr0] ploadaddr_l x3_addr;
                [cr0] loadaddr_h x3_addr, raddr1;
                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] ploadaddr_l xa_addr;
                [cr0] loadaddr_h xa_addr, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;

                [cr0] ploadaddr_l x3_addr;
                [cr0] loadaddr_h x3_addr, raddr1;
                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] copy raddr1, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;
        jump triangulo_end_if2;
        nop;
        triangulo_else2:
        triangulo_if3:
        fcomp_g 0.f, z3, cr0;
        [!cr0] jump triangulo_else3;
        [!cr0] nop;
            ploadaddr_l x1_addr;
            loadaddr_h x1_addr, raddr1;
            ploadaddr_l x2_addr;
            loadaddr_h x2_addr, raddr2;
            copy 0.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            ploadaddr_l x3_addr;
            loadaddr_h x3_addr, raddr1;
            ploadaddr_l x2_addr;
            loadaddr_h x2_addr, raddr2;
            copy 0.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            fcomp_l 1.f, z2, cr0;
                [cr0] fmulp2 1.f, 2, vst;

                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr1;
                [cr0] ploadaddr_l x1_addr;
                [cr0] loadaddr_h x1_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] ploadaddr_l xa_addr;
                [cr0] loadaddr_h xa_addr, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;

                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr1;
                [cr0] ploadaddr_l x3_addr;
                [cr0] loadaddr_h x3_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] copy raddr1, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;
        jump triangulo_end_if3;
        nop;
        triangulo_else3:
            fmulp2 1.f, 1, vst;

            ploadaddr_l x1_addr;
            loadaddr_h x1_addr, raddr1;
            ploadaddr_l x3_addr;
            loadaddr_h x3_addr, raddr2;
            copy 0.f, z;
            ploadaddr_l xa_addr;
            loadaddr_h xa_addr, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            ploadaddr_l x1_addr;
            loadaddr_h x1_addr, raddr1;
            ploadaddr_l x2_addr;
            loadaddr_h x2_addr, raddr2;
            copy 0.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            triangulo_if4:
            fcomp_l 1.f, z2, cr0;
            [!cr0] jump triangulo_else4;
            [!cr0] nop;
                fcomp_l 1.f, z3, cr0;
                    [cr0] ploadaddr_l x2_addr;
                    [cr0] loadaddr_h x2_addr, raddr1;
                    [cr0] ploadaddr_l x1_addr;
                    [cr0] loadaddr_h x1_addr, raddr2;
                    [cr0] copy 1.f, z;
                    [cr0] copy raddr1, waddr;
                    [cr0] store_addr stack;
                    [cr0] rcall vz;
                    [cr0] load_addr stack;

                    [cr0] ploadaddr_l x3_addr;
                    [cr0] loadaddr_h x3_addr, raddr1;
                    [cr0] ploadaddr_l xa_addr;
                    [cr0] loadaddr_h xa_addr, raddr2;
                    [cr0] copy 1.f, z;
                    [cr0] copy raddr1, waddr;
                    [cr0] store_addr stack;
                    [cr0] rcall vz;
                    [cr0] load_addr stack;

                    [!cr0] fmulp2 1.f, 4, vst;

                    [!cr0] ploadaddr_l x2_addr;
                    [!cr0] loadaddr_h x2_addr, raddr1;
                    [!cr0] ploadaddr_l x1_addr;
                    [!cr0] loadaddr_h x1_addr, raddr2;
                    [!cr0] copy 1.f, z;
                    [!cr0] ploadaddr_l xb_addr;
                    [!cr0] loadaddr_h xb_addr, waddr;
                    [!cr0] store_addr stack;
                    [!cr0] rcall vz;
                    [!cr0] load_addr stack;

                    [!cr0] ploadaddr_l x2_addr;
                    [!cr0] loadaddr_h x2_addr, raddr1;
                    [!cr0] ploadaddr_l x3_addr;
                    [!cr0] loadaddr_h x3_addr, raddr2;
                    [!cr0] copy 1.f, z;
                    [!cr0] copy raddr1, waddr;
                    [!cr0] store_addr stack;
                    [!cr0] rcall vz;
                    [!cr0] load_addr stack;
            jump triangulo_end_if4;
            nop;
            triangulo_else4:
                fcomp_l 1.f, z3, cr0;
                    [cr0] fmulp2 1.f, 5, vst;

                    [cr0] ploadaddr_l x3_addr;
                    [cr0] loadaddr_h x3_addr, raddr1;
                    [cr0] ploadaddr_l x2_addr;
                    [cr0] loadaddr_h x2_addr, raddr2;
                    [cr0] copy 1.f, z;
                    [cr0] ploadaddr_l xb_addr;
                    [cr0] loadaddr_h xb_addr, waddr;
                    [cr0] store_addr stack;
                    [cr0] rcall vz;
                    [cr0] load_addr stack;

                    [cr0] ploadaddr_l x3_addr;
                    [cr0] loadaddr_h x3_addr, raddr1;
                    [cr0] ploadaddr_l xa_addr;
                    [cr0] loadaddr_h xa_addr, raddr2;
                    [cr0] copy 1.f, z;
                    [cr0] copy raddr1, waddr;
                    [cr0] store_addr stack;
                    [cr0] rcall vz;
                    [cr0] load_addr stack;
            triangulo_end_if4:
        triangulo_end_if3:
        triangulo_end_if2:
    jump triangulo_end_if1;
    nop;
    triangulo_else1:
    triangulo_if5:
    fcomp_g 0.f, z2, cr0;
    [!cr0] jump triangulo_else5;
    [!cr0] nop;
        triangulo_if6:
        fcomp_g 0.f, z3, cr0;
        [!cr0] jump triangulo_else6;
        [!cr0] nop;
            ploadaddr_l x2_addr;
            loadaddr_h x2_addr, raddr1;
            ploadaddr_l x1_addr;
            loadaddr_h x1_addr, raddr2;
            copy 0.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            ploadaddr_l x3_addr;
            loadaddr_h x3_addr, raddr1;
            ploadaddr_l x1_addr;
            loadaddr_h x1_addr, raddr2;
            copy 0.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            fcomp_l 1.f, z1, cr0;
                [cr0] fmulp2 1.f, 1, vst;

                [cr0] ploadaddr_l x1_addr;
                [cr0] loadaddr_h x1_addr, raddr1;
                [cr0] ploadaddr_l x3_addr;
                [cr0] loadaddr_h x3_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] ploadaddr_l xa_addr;
                [cr0] loadaddr_h xa_addr, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;

                [cr0] ploadaddr_l x1_addr;
                [cr0] loadaddr_h x1_addr, raddr1;
                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] copy raddr1, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;
        jump triangulo_end_if6;
        nop;
        triangulo_else6:
            fmulp2 1.f, 2, vst;

            ploadaddr_l x2_addr;
            loadaddr_h x2_addr, raddr1;
            ploadaddr_l x1_addr;
            loadaddr_h x1_addr, raddr2;
            copy 0.f, z;
            ploadaddr_l xa_addr;
            loadaddr_h xa_addr, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            ploadaddr_l x2_addr;
            loadaddr_h x2_addr, raddr1;
            ploadaddr_l x3_addr;
            loadaddr_h x3_addr, raddr2;
            copy 0.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            triangulo_if7:
            fcomp_l 1.f, z1, cr0;
            [!cr0] jump triangulo_else7;
            [!cr0] nop;
                fcomp_l 1.f, z3, cr0;
                    [cr0] ploadaddr_l x1_addr;
                    [cr0] loadaddr_h x1_addr, raddr1;
                    [cr0] ploadaddr_l xa_addr;
                    [cr0] loadaddr_h xa_addr, raddr2;
                    [cr0] copy 1.f, z;
                    [cr0] copy raddr1, waddr;
                    [cr0] store_addr stack;
                    [cr0] rcall vz;
                    [cr0] load_addr stack;

                    [cr0] ploadaddr_l x3_addr;
                    [cr0] loadaddr_h x3_addr, raddr1;
                    [cr0] ploadaddr_l x2_addr;
                    [cr0] loadaddr_h x2_addr, raddr2;
                    [cr0] copy 1.f, z;
                    [cr0] copy raddr1, waddr;
                    [cr0] store_addr stack;
                    [cr0] rcall vz;
                    [cr0] load_addr stack;

                    [!cr0] fmulp2 1.f, 6, vst;

                    [!cr0] ploadaddr_l x1_addr;
                    [!cr0] loadaddr_h x1_addr, raddr1;
                    [!cr0] ploadaddr_l x3_addr;
                    [!cr0] loadaddr_h x3_addr, raddr2;
                    [!cr0] copy 1.f, z;
                    [!cr0] ploadaddr_l xb_addr;
                    [!cr0] loadaddr_h xb_addr, waddr;
                    [!cr0] store_addr stack;
                    [!cr0] rcall vz;
                    [!cr0] load_addr stack;

                    [!cr0] ploadaddr_l x1_addr;
                    [!cr0] loadaddr_h x1_addr, raddr1;
                    [!cr0] ploadaddr_l xa_addr;
                    [!cr0] loadaddr_h xa_addr, raddr2;
                    [!cr0] copy 1.f, z;
                    [!cr0] copy raddr1, waddr;
                    [!cr0] store_addr stack;
                    [!cr0] rcall vz;
                    [!cr0] load_addr stack;
            jump triangulo_end_if7;
            nop;
            triangulo_else7:
                fcomp_l 1.f, z3, cr0;
                    [cr0] fmulp2 1.f, 7, vst;

                    [cr0] ploadaddr_l x3_addr;
                    [cr0] loadaddr_h x3_addr, raddr1;
                    [cr0] ploadaddr_l x2_addr;
                    [cr0] loadaddr_h x2_addr, raddr2;
                    [cr0] copy 1.f, z;
                    [cr0] ploadaddr_l xb_addr;
                    [cr0] loadaddr_h xb_addr, waddr;
                    [cr0] store_addr stack;
                    [cr0] rcall vz;
                    [cr0] load_addr stack;

                    [cr0] ploadaddr_l x3_addr;
                    [cr0] loadaddr_h x3_addr, raddr1;
                    [cr0] ploadaddr_l x1_addr;
                    [cr0] loadaddr_h x1_addr, raddr2;
                    [cr0] copy 1.f, z;
                    [cr0] copy raddr1, waddr;
                    [cr0] store_addr stack;
                    [cr0] rcall vz;
                    [cr0] load_addr stack;
            triangulo_end_if7:
        triangulo_end_if6:
    jump triangulo_end_if5;
    nop;
    triangulo_else5:
    triangulo_if8:
    fcomp_g 0.f, z3, cr0;
    [!cr0] jump triangulo_else8;
    [!cr0] nop;
        fmulp2 1.f, 3, vst;

        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        copy 0.f, z;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, waddr;
        store_addr stack;
        rcall vz;
        load_addr stack;

        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr1;
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr2;
        copy 0.f, z;
        copy raddr1, waddr;
        store_addr stack;
        rcall vz;
        load_addr stack;

        triangulo_if9:
        fcomp_l 1.f, z1, cr0;
        [!cr0] jump triangulo_else9;
        [!cr0] nop;
            fcomp_l 1.f, z2, cr0;
                [cr0] ploadaddr_l x1_addr;
                [cr0] loadaddr_h x1_addr, raddr1;
                [cr0] ploadaddr_l x3_addr;
                [cr0] loadaddr_h x3_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] copy raddr1, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;

                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr1;
                [cr0] ploadaddr_l xa_addr;
                [cr0] loadaddr_h xa_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] copy raddr1, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;

                [!cr0] fmulp2 1.f, 8, vst;

                [!cr0] ploadaddr_l x1_addr;
                [!cr0] loadaddr_h x1_addr, raddr1;
                [!cr0] ploadaddr_l x3_addr;
                [!cr0] loadaddr_h x3_addr, raddr2;
                [!cr0] copy 1.f, z;
                [!cr0] ploadaddr_l xb_addr;
                [!cr0] loadaddr_h xb_addr, waddr;
                [!cr0] store_addr stack;
                [!cr0] rcall vz;
                [!cr0] load_addr stack;

                [!cr0] ploadaddr_l x1_addr;
                [!cr0] loadaddr_h x1_addr, raddr1;
                [!cr0] ploadaddr_l x2_addr;
                [!cr0] loadaddr_h x2_addr, raddr2;
                [!cr0] copy 1.f, z;
                [!cr0] copy raddr1, waddr;
                [!cr0] store_addr stack;
                [!cr0] rcall vz;
                [!cr0] load_addr stack;
        jump triangulo_end_if9;
        nop;
        triangulo_else9:
            fcomp_l 1.f, z2, cr0;
                [cr0] fmulp2 1.f, 9, vst;

                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr1;
                [cr0] ploadaddr_l x1_addr;
                [cr0] loadaddr_h x1_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] ploadaddr_l xb_addr;
                [cr0] loadaddr_h xb_addr, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;

                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr1;
                [cr0] ploadaddr_l xa_addr;
                [cr0] loadaddr_h xa_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] copy raddr1, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;
        triangulo_end_if9:
    jump triangulo_end_if8;
    nop;
    triangulo_else8:
    triangulo_if10:
    fcomp_l 1.f, z1, cr0;
    [!cr0] jump triangulo_else10;
    [!cr0] nop;
        triangulo_if11:
        fcomp_l 1.f, z2, cr0;
        [!cr0] jump triangulo_else11;
        [!cr0] nop;
            fcomp_l 1.f, z3, cr0;
                [cr0] store_addr stack;
                [cr0] ret;
                [cr0] load_addr stack;

            ploadaddr_l x1_addr;
            loadaddr_h x1_addr, raddr1;
            ploadaddr_l x3_addr;
            loadaddr_h x3_addr, raddr2;
            copy 1.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;

            ploadaddr_l x2_addr;
            loadaddr_h x2_addr, raddr1;
            ploadaddr_l x3_addr;
            loadaddr_h x3_addr, raddr2;
            copy 1.f, z;
            copy raddr1, waddr;
            store_addr stack;
            rcall vz;
            load_addr stack;
        jump triangulo_end_if11;
        nop;
        triangulo_else11:
            fcomp_l 1.f, z3, cr0;
                [cr0] ploadaddr_l x1_addr;
                [cr0] loadaddr_h x1_addr, raddr1;
                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] copy raddr1, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;

                [cr0] ploadaddr_l x3_addr;
                [cr0] loadaddr_h x3_addr, raddr1;
                [cr0] ploadaddr_l x2_addr;
                [cr0] loadaddr_h x2_addr, raddr2;
                [cr0] copy 1.f, z;
                [cr0] copy raddr1, waddr;
                [cr0] store_addr stack;
                [cr0] rcall vz;
                [cr0] load_addr stack;

                [!cr0] fmulp2 1.f, 1, vst;

                [!cr0] ploadaddr_l x1_addr;
                [!cr0] loadaddr_h x1_addr, raddr1;
                [!cr0] ploadaddr_l x3_addr;
                [!cr0] loadaddr_h x3_addr, raddr2;
                [!cr0] copy 1.f, z;
                [!cr0] ploadaddr_l xa_addr;
                [!cr0] loadaddr_h xa_addr, waddr;
                [!cr0] store_addr stack;
                [!cr0] rcall vz;
                [!cr0] load_addr stack;

                [!cr0] ploadaddr_l x1_addr;
                [!cr0] loadaddr_h x1_addr, raddr1;
                [!cr0] ploadaddr_l x2_addr;
                [!cr0] loadaddr_h x2_addr, raddr2;
                [!cr0] copy 1.f, z;
                [!cr0] copy raddr1, waddr;
                [!cr0] store_addr stack;
                [!cr0] rcall vz;
                [!cr0] load_addr stack;
        triangulo_end_if11:
    jump triangulo_end_if10;
    nop;
    triangulo_else10:
    triangulo_if12:
    fcomp_l 1.f, z2, cr0;
    [!cr0] jump triangulo_else12;
    [!cr0] nop;
        fcomp_l 1.f, z3, cr0;
            [cr0] ploadaddr_l x2_addr;
            [cr0] loadaddr_h x2_addr, raddr1;
            [cr0] ploadaddr_l x1_addr;
            [cr0] loadaddr_h x1_addr, raddr2;
            [cr0] copy 1.f, z;
            [cr0] copy raddr1, waddr;
            [cr0] store_addr stack;
            [cr0] rcall vz;
            [cr0] load_addr stack;

            [cr0] ploadaddr_l x3_addr;
            [cr0] loadaddr_h x3_addr, raddr1;
            [cr0] ploadaddr_l x1_addr;
            [cr0] loadaddr_h x1_addr, raddr2;
            [cr0] copy 1.f, z;
            [cr0] copy raddr1, waddr;
            [cr0] store_addr stack;
            [cr0] rcall vz;
            [cr0] load_addr stack;

            [!cr0] fmulp2 1.f, 2, vst;

            [!cr0] ploadaddr_l x2_addr;
            [!cr0] loadaddr_h x2_addr, raddr1;
            [!cr0] ploadaddr_l x1_addr;
            [!cr0] loadaddr_h x1_addr, raddr2;
            [!cr0] copy 1.f, z;
            [!cr0] ploadaddr_l xa_addr;
            [!cr0] loadaddr_h xa_addr, waddr;
            [!cr0] store_addr stack;
            [!cr0] rcall vz;
            [!cr0] load_addr stack;

            [!cr0] ploadaddr_l x2_addr;
            [!cr0] loadaddr_h x2_addr, raddr1;
            [!cr0] ploadaddr_l x3_addr;
            [!cr0] loadaddr_h x3_addr, raddr2;
            [!cr0] copy 1.f, z;
            [!cr0] copy raddr1, waddr;
            [!cr0] store_addr stack;
            [!cr0] rcall vz;
            [!cr0] load_addr stack;
    jump triangulo_end_if12;
    nop;
    triangulo_else12:
    fcomp_l 1.f, z3, cr0;
        [cr0] fmulp2 1.f, 3, vst;

        [cr0] ploadaddr_l x3_addr;
        [cr0] loadaddr_h x3_addr, raddr1;
        [cr0] ploadaddr_l x2_addr;
        [cr0] loadaddr_h x2_addr, raddr2;
        [cr0] copy 1.f, z;
        [cr0] ploadaddr_l xa_addr;
        [cr0] loadaddr_h xa_addr, waddr;
        [cr0] store_addr stack;
        [cr0] rcall vz;
        [cr0] load_addr stack;

        [cr0] ploadaddr_l x3_addr;
        [cr0] loadaddr_h x3_addr, raddr1;
        [cr0] ploadaddr_l x1_addr;
        [cr0] loadaddr_h x1_addr, raddr2;
        [cr0] copy 1.f, z;
        [cr0] copy raddr1, waddr;
        [cr0] store_addr stack;
        [cr0] rcall vz;
        [cr0] load_addr stack;
    triangulo_end_if12:
    triangulo_end_if10:
    triangulo_end_if8:
    triangulo_end_if5:
    triangulo_end_if1:

#undef z1
#undef z2
#undef z3
#undef raddr1
#undef raddr2
#undef z
#undef waddr
#def case r3
#def raddr1 r0
#def raddr2 r1
#def raddr3 r2

    fmulp2 1.f, 0, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_v1_v2_v3;
    [cr0] nop;
    fmulp2 1.f, 1, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_va_v1_v2_v3;
    [cr0] nop;
    fmulp2 1.f, 2, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_v1_va_v2_v3;
    [cr0] nop;
    fmulp2 1.f, 3, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_v1_v2_va_v3;
    [cr0] nop;
    fmulp2 1.f, 4, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_va_v1_vb_v2_v3;
    [cr0] nop;
    fmulp2 1.f, 5, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_va_v1_v2_vb_v3;
    [cr0] nop;
    fmulp2 1.f, 6, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_vb_v1_va_v2_v3;
    [cr0] nop;
    fmulp2 1.f, 7, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_v1_va_v2_vb_v3;
    [cr0] nop;
    fmulp2 1.f, 8, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_vb_v1_v2_va_v3;
    [cr0] nop;
    fmulp2 1.f, 9, case;
    fcomp_e case, vst, cr0;
    [cr0] jump triangulo_case1_v1_vb_v2_va_v3;
    [cr0] nop;
    jump triangulo_default1;
    nop;
    triangulo_case1_v1_v2_v3:
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_va_v1_v2_v3:
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr1;
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr2;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_v1_va_v2_v3:
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr2;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_v1_v2_va_v3:
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_va_v1_vb_v2_v3:
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr1;
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr2;
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr1;
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr2;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_va_v1_v2_vb_v3:
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr1;
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr2;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr1;
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_vb_v1_va_v2_v3:
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr1;
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr2;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr1;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr2;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_v1_va_v2_vb_v3:
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr2;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_vb_v1_v2_va_v3:
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr1;
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr2;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr1;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_case1_v1_vb_v2_va_v3:
        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l xb_addr;
        loadaddr_h xb_addr, raddr2;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l x2_addr;
        loadaddr_h x2_addr, raddr2;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        ploadaddr_l x1_addr;
        loadaddr_h x1_addr, raddr1;
        ploadaddr_l xa_addr;
        loadaddr_h xa_addr, raddr2;
        ploadaddr_l x3_addr;
        loadaddr_h x3_addr, raddr3;
        fcomp_u nan, r0, cr0;
        store_addr stack;
        rcall triangulo_p;
        load_addr stack;

        jump triangulo_end_switch1;
        nop;
    triangulo_default1:
    triangulo_end_switch1:

#undef vst
#undef case
#undef raddr1
#undef raddr2
#undef raddr3

store_addr stack;
ret;
load_addr stack;

//________________________________

vs_main:

/*
    _x = x*_11 + y*_21 + z*_31 + _41;
    _y = x*_12 + y*_22 + z*_32 + _42;
    _z = x*_13 + y*_23 + z*_33 + _43;
    _w = x*_14 + y*_24 + z*_34 + _44;

    if (use_texture) {
        _blue  = blue;
        _green = green;
    } else {
        _blue  = float(color.blue);
        _green = float(color.green);
        _red   = float(color.red);
        _alpha = float(color.alpha);
    }
*/

#def raddr r0
#def waddr r1
#def x r2
#def y r3
#def z r4
#def w r5
#def _11 r6
#def _12 r7
#def _13 r8
#def _14 r9
#def _21 r10
#def _22 r11
#def _23 r12
#def _24 r13
#def _31 r14
#def _32 r15
#def _33 r16
#def _34 r17
#def _41 r18
#def _42 r19
#def _43 r20
#def _44 r21

    ploadaddr_l _11_addr;
    loadaddr_h _11_addr, _11;
    load _11, _11;
    i_load _12;
    i_load _13;
    i_load _14;
    i_load _21;
    i_load _22;
    i_load _23;
    i_load _24;
    i_load _31;
    i_load _32;
    i_load _33;
    i_load _34;
    i_load _41;
    i_load _42;
    i_load _43;
    i_load _44;

    load raddr, x;
    i_load y;
    i_load z;

    fmul x, _11, _11;
    fmul x, _12, _12;
    fmul x, _13, _13;
    fmul x, _14, _14;
    fmul y, _21, _21;
    fmul y, _22, _22;
    fmul y, _23, _23;
    fmul y, _24, _24;
    fadd _11, _21, _11;
    fadd _12, _22, _12;
    fadd _13, _23, _13;
    fadd _14, _24, _14;
    fmul z, _31, _31;
    fmul z, _32, _32;
    fmul z, _33, _33;
    fmul z, _34, _34;
    fadd _11, _31, _11;
    fadd _12, _32, _12;
    fadd _13, _33, _13;
    fadd _14, _34, _14;
    fadd _11, _41, x;
    fadd _12, _42, y;
    fadd _13, _43, z;
    fadd _14, _44, w;
    nop;
    nop;

#undef _11
#undef _12
#undef _13
#undef _14
#undef _21
#undef _22
#undef _23
#undef _24
#undef _31
#undef _32
#undef _33
#undef _34
#undef _41
#undef _42
#undef _43
#undef _44
#def color r6
#def blue r7
#def green r8
#def red r9
#def alpha r10

    [cr6] i_load blue;
    [cr6] i_load green;
    [!cr6] i_load color;
    [!cr6] u8tof_ll color, blue;
    [!cr6] u8tof_lh color, green;
    [!cr6] u8tof_hl color, red;
    [!cr6] u8tof_hh color, alpha;

    [cr0] store x, waddr;
    [cr0] i_store y;
    [cr0] i_store z;
    [cr0] i_store w;
    [cr0] i_store blue;
    [cr0] i_store green;
    [cr0] i_store red;
    [cr0] i_store alpha;

#undef raddr
#undef waddr
#undef x
#undef y
#undef z
#undef w
#undef color
#undef blue
#undef green
#undef red
#undef alpha

store_addr stack;
ret;
load_addr stack;

//________________________________

vz:

/*
    xz     = (x2    -x1)    /(z2-z1)*(z-z1)+x1;
    yz     = (y2    -y1)    /(z2-z1)*(z-z1)+y1;
    wz     = (w2    -w1)    /(z2-z1)*(z-z1)+w1;
    bluez  = (blue2 -blue1) /(z2-z1)*(z-z1)+blue1;
    greenz = (green2-green1)/(z2-z1)*(z-z1)+green1;
    redz   = (red2  -red1)  /(z2-z1)*(z-z1)+red1;
    alphaz = (alpha2-alpha1)/(z2-z1)*(z-z1)+alpha1;
*/

#def raddr1 r0
#def raddr2 r1
#def z r2
#def waddr r3
#def x1 r4
#def y1 r5
#def z1 r6
#def w1 r7
#def blue1 r8
#def green1 r9
#def red1 r10
#def alpha1 r11
#def x2 r12
#def y2 r13
#def z2 r14
#def w2 r15
#def blue2 r16
#def green2 r17
#def red2 r18
#def alpha2 r19

    load raddr1, x1;
    i_load y1;
    i_load z1;
    i_load w1;
    i_load blue1;
    i_load green1;
    [!cr6] i_load red1;
    [!cr6] i_load alpha1;

    load raddr2, x2;
    i_load y2;
    i_load z2;
    i_load w2;
    i_load blue2;
    i_load green2;
    [!cr6] i_load red2;
    [!cr6] i_load alpha2;

#undef raddr1
#undef raddr2
#def z2_z1 r0
#def x2_x1 r1
#def y2_y1 r20
#def w2_w1 r21
#def blue2_blue1 r22
#def green2_green1 r23
#def red2_red1 r24
#def alpha2_alpha1 r25

    fsub z2, z1, z2_z1;
    fsub x2, x1, x2_x1;
    fsub y2, y1, y2_y1;
    fsub w2, w1, w2_w1;
    fsub blue2, blue1, blue2_blue1;
    fsub green2, green1, green2_green1;
    fsub red2, red1, red2_red1;
    fsub alpha2, alpha1, alpha2_alpha1;

#undef x2
#undef y2
#undef z2
#undef w2
#undef blue2
#undef green2
#undef red2
#undef alpha2
#def xz r12
#def yz r13
#def wz r14
#def bluez r15
#def greenz r16
#def redz r17
#def alphaz r18
#def z_z1 r19

    fdiv x2_x1, z2_z1, xz;
    fdiv y2_y1, z2_z1, yz;
    fdiv w2_w1, z2_z1, wz;
    fdiv blue2_blue1, z2_z1, bluez;
    fdiv green2_green1, z2_z1, greenz;
    fdiv red2_red1, z2_z1, redz;
    fdiv alpha2_alpha1, z2_z1, alphaz;
    fsub z, z1, z_z1;
    nop;
    nop;
    nop;
    nop;
    nop;
    nop;
    nop;
    fmul xz, z_z1, xz;
    fmul yz, z_z1, yz;
    fmul wz, z_z1, wz;
    fmul bluez, z_z1, bluez;
    fmul greenz, z_z1, greenz;
    fmul redz, z_z1, redz;
    fmul alphaz, z_z1, alphaz;
    fadd xz, x1, xz;
    fadd yz, y1, yz;
    fadd wz, w1, wz;
    fadd bluez, blue1, bluez;
    fadd greenz, green1, greenz;
    fadd redz, red1, redz;
    fadd alphaz, alpha1, alphaz;

    store xz, waddr;
    i_store yz;
    i_store z;
    i_store wz;
    i_store bluez;
    i_store greenz;
    [!cr6] i_store redz;
    [!cr6] i_store alphaz;

#undef z
#undef waddr
#undef x1
#undef y1
#undef z1
#undef w1
#undef blue1
#undef green1
#undef red1
#undef alpha1
#undef z2_z1
#undef x2_x1
#undef y2_y1
#undef w2_w1
#undef blue2_blue1
#undef green2_green1
#undef red2_red1
#undef alpha2_alpha1
#undef xz
#undef yz
#undef wz
#undef bluez
#undef greenz
#undef redz
#undef alphaz
#undef z_z1

store_addr stack;
ret;
load_addr stack;

//________________________________

triangulo_p:

#def raddr1 r0
#def raddr2 r1
#def raddr3 r2
#def waddr r3
#def x1 r4
#def y1 r5
#def z1 r6
#def w1 r7
#def blue1 r8
#def green1 r9
#def red1 r10
#def alpha1 r11
#def x2 r12
#def y2 r13
#def z2 r14
#def w2 r15
#def blue2 r16
#def green2 r17
#def red2 r18
#def alpha2 r19
#def x3 r20
#def y3 r21
#def z3 r22
#def w3 r23
#def blue3 r24
#def green3 r25
#def red3 r26
#def alpha3 r27

// XXXXXXXX XXXXXXXX XXXXXXXX XXXX---S

    load raddr1, x1;
    i_load y1;
    i_load z1;
    i_load w1;
    i_load blue1;
    i_load green1;
    [!cr6] i_load red1;
    [!cr6] i_load alpha1;

    load raddr2, x2;
    i_load y2;
    i_load z2;
    i_load w2;
    i_load blue2;
    i_load green2;
    [!cr6] i_load red2;
    [!cr6] i_load alpha2;

    load raddr3, x3;
    i_load y3;
    i_load z3;
    i_load w3;
    i_load blue3;
    i_load green3;
    [!cr6] i_load red3;
    [!cr6] i_load alpha3;

    ploadaddr_l x1p_addr;
    loadaddr_h x1p_addr, waddr;

    fdiv x1, w1, x1;
    fdiv y1, w1, y1;
    fdiv z1, w1, z1;
    fdiv blue1, w1, blue1;
    fdiv green1, w1, green1;
    fdiv red1, w1, red1;
    fdiv alpha1, w1, alpha1;
    fdiv x2, w2, x2;
    fdiv y2, w2, y2;
    fdiv z2, w2, z2;
    fdiv blue2, w2, blue2;
    fdiv green2, w2, green2;
    fdiv red2, w2, red2;
    fdiv alpha2, w2, alpha2;
    fdiv x3, w3, x3;
    fdiv y3, w3, y3;
    fdiv z3, w3, z3;
    fdiv blue3, w3, blue3;
    fdiv green3, w3, green3;
    fdiv red3, w3, red3;
    fdiv alpha3, w3, alpha3;

    store x1, waddr;
    i_store y1;
    i_store z1;
    i_store blue1;
    i_store green1;
    i_store red1;
    i_store alpha1;
    i_store x2;
    i_store y2;
    i_store z2;
    i_store blue2;
    i_store green2;
    i_store red2;
    i_store alpha2;
    i_store x3;
    i_store y3;
    i_store z3;
    i_store blue3;
    i_store green3;
    [!cr6] i_store red3;
    [!cr6] i_store alpha3;

#undef z1
#undef w1
#undef blue1
#undef green1
#undef red1
#undef alpha1
#undef z2
#undef w2
#undef blue2
#undef green2
#undef red2
#undef alpha2
#undef z3
#undef w3
#undef blue3
#undef green3
#undef red3
#undef alpha3
#def caras_sh r6
#def caras_sah r7
#def aux1 r8
#def aux2 r9
#def aux3 r10
#def aux4 r11
#def mitad_x r14
#def mitad_y r15
#def x1pt r16
#def y1pt r17
#def x2pt r18
#def y2pt r19
#def x3pt r22
#def y3pt r23
#def x_min r24
#def y_min r25
#def x_max r26
#def y_max r27
#def ancho_1 r28
#def alto_1 r29

// XXXXXXXX XXXXXXXX XXXXXXXX XXXXXX-S

    ploadaddr_l caras_sh_addr;
    loadaddr_h caras_sh_addr, caras_sh;
    load caras_sh, caras_sh;
    i_load caras_sah;

    triangulo_p_if1:
    [!cr0] jump triangulo_p_end_if1;
    [!cr0] nop;
        fsub x2, x1, aux1;
        fsub y3, y1, aux4;
        fsub y2, y1, aux2;
        fsub x3, x1, aux3;
        fmul aux1, aux4, aux1;
        nop;
        fmul aux2, aux3, aux2;
        nop;
        nop;
        fsub aux1, aux2, aux1;
        nop;
        fcomp_e 0.f, caras_sh, cr0;
        [cr0] fcomp_g 0.f, aux1, cr0;
            [cr0] store_addr stack;
            [cr0] ret;
            [cr0] load_addr stack;
        fcomp_e 0.f, caras_sah, cr0;
        [cr0] fcomp_l 0.f, aux1, cr0;
            [cr0] store_addr stack;
            [cr0] ret;
            [cr0] load_addr stack;
    triangulo_p_end_if1:

    ploadaddr_l mitad_x_addr;
    loadaddr_h mitad_x_addr, mitad_x;
    load mitad_x, mitad_x;
    i_load mitad_y;

    fmul mitad_x, x1, x1pt;
    fmul mitad_y, y1, y1pt;
    fmul mitad_x, x2, x2pt;
    fmul mitad_y, y2, y2pt;
    fmul mitad_x, x3, x3pt;
    fmul mitad_y, y3, y3pt;
    fadd x1pt, mitad_x, x1pt;
    fadd y1pt, mitad_y, y1pt;
    fadd x2pt, mitad_x, x2pt;
    fadd y2pt, mitad_y, y2pt;
    fadd x3pt, mitad_x, x3pt;
    fadd y3pt, mitad_y, y3pt;
    nop;
    nop;
    copy x1pt, x_min;
    copy y1pt, y_min;
    copy x1pt, x_max;
    copy y1pt, y_max;
    fmin x_min, x2pt, x_min;
    fmin y_min, y2pt, y_min;
    fmax x_max, x2pt, x_max;
    fmax y_max, y2pt, y_max;
    fmin x_min, x3pt, x_min;
    fmin y_min, y3pt, y_min;
    fmax x_max, x3pt, x_max;
    fmax y_max, y3pt, y_max;

    ploadaddr_l ancho_1_addr;
    loadaddr_h ancho_1_addr, ancho_1;
    load ancho_1, ancho_1;
    i_load alto_1;

    fcomp_le x_min, ancho_1, cr0;
    [cr0] fcomp_le 0.f, x_max, cr0;
    [cr0] fcomp_le y_min, alto_1, cr0;
    [cr0] fcomp_le 0.f, y_max, cr0;
        [!cr0] store_addr stack;
        [!cr0] ret;
        [!cr0] load_addr stack;

#undef x1
#undef y1
#undef x2
#undef y2
#undef x3
#undef y3
#undef caras_sh
#undef caras_sah
#undef aux1
#undef aux2
#undef aux3
#undef aux4

// XXXX---- ------XX XXXX--XX XXXXXX-S

    store_addr stack;
    push mitad_x;
    push mitad_y;
    push x1pt;
    push y1pt;
    push x2pt;
    push y2pt;
    push x3pt;
    push y3pt;
    push x_min;
    push y_min;
    push x_max;
    push y_max;
    push ancho_1;
    push alto_1;
    load_addr stack;

    store_addr stack;
    rcall w_xyz;
    load_addr stack;

    ploadaddr_l z1p_addr;
    loadaddr_h z1p_addr, raddr1;
    ploadaddr_l z2p_addr;
    loadaddr_h z2p_addr, raddr2;
    ploadaddr_l z3p_addr;
    loadaddr_h z3p_addr, raddr3;
    ploadaddr_l z_my_addr;
    loadaddr_h z_my_addr, waddr;
    store_addr stack;
    rcall z_xy;
    load_addr stack;

    ploadaddr_l blue1p_addr;
    loadaddr_h blue1p_addr, raddr1;
    ploadaddr_l blue2p_addr;
    loadaddr_h blue2p_addr, raddr2;
    ploadaddr_l blue3p_addr;
    loadaddr_h blue3p_addr, raddr3;
    ploadaddr_l blue_my_addr;
    loadaddr_h blue_my_addr, waddr;
    store_addr stack;
    rcall z_xy;
    load_addr stack;

    ploadaddr_l green1p_addr;
    loadaddr_h green1p_addr, raddr1;
    ploadaddr_l green2p_addr;
    loadaddr_h green2p_addr, raddr2;
    ploadaddr_l green3p_addr;
    loadaddr_h green3p_addr, raddr3;
    ploadaddr_l green_my_addr;
    loadaddr_h green_my_addr, waddr;
    store_addr stack;
    rcall z_xy;
    load_addr stack;

    triangulo_p_if2:
    [cr6] jump triangulo_p_end_if2;
    [cr6] nop;
        ploadaddr_l red1p_addr;
        loadaddr_h red1p_addr, raddr1;
        ploadaddr_l red2p_addr;
        loadaddr_h red2p_addr, raddr2;
        ploadaddr_l red3p_addr;
        loadaddr_h red3p_addr, raddr3;
        ploadaddr_l red_my_addr;
        loadaddr_h red_my_addr, waddr;
        store_addr stack;
        rcall z_xy;
        load_addr stack;

        ploadaddr_l alpha1p_addr;
        loadaddr_h alpha1p_addr, raddr1;
        ploadaddr_l alpha2p_addr;
        loadaddr_h alpha2p_addr, raddr2;
        ploadaddr_l alpha3p_addr;
        loadaddr_h alpha3p_addr, raddr3;
        ploadaddr_l alpha_my_addr;
        loadaddr_h alpha_my_addr, waddr;
        store_addr stack;
        rcall z_xy;
        load_addr stack;
    triangulo_p_end_if2:

    store_addr stack;
    pop alto_1;
    pop ancho_1;
    pop y_max;
    pop x_max;
    pop y_min;
    pop x_min;
    pop y3pt;
    pop x3pt;
    pop y2pt;
    pop x2pt;
    pop y1pt;
    pop x1pt;
    pop mitad_y;
    pop mitad_x;
    load_addr stack;

#undef raddr1
#undef raddr2
#undef raddr3
#undef waddr
#def xpt r0
#def ypt r1
#def m1 r2
#def b1 r3
#def m2 r4
#def b2 r5
#def m3 r6
#def b3 r7
#def l1_y3 r8
#def l2_y1 r9
#def l3_y2 r10

// XXXXXXXX XXX---XX XXXX--XX XXXXXX-S

    ceil x_min, xpt;
    ceil y_min, ypt;
    floor x_max, x_max;
    floor y_max, y_max;
    fmax 0.f, xpt, xpt;
    fmax 0.f, ypt, ypt;
    fmin x_max, ancho_1, x_max;
    fmin y_max, alto_1, y_max;

    fsub x2pt, x1pt, m1;
    fsub y2pt, y1pt, b1;
    fsub x3pt, x2pt, m2;
    fsub y3pt, y2pt, b2;
    fsub x1pt, x3pt, m3;
    fsub y1pt, y3pt, b3;
    fdiv m1, b1, m1;
    fdiv m2, b2, m2;
    fdiv m3, b3, m3;
    nop;
    nop;
    nop;
    nop;
    nop;
    nop;
    nop;
    nop;
    fmul m1, y1pt, b1;
    fmul m2, y2pt, b2;
    fmul m3, y3pt, b3;
    fsub x1pt, b1, b1;
    fsub x2pt, b2, b2;
    fsub x3pt, b3, b3;
    fmul m1, y3pt, l1_y3;
    fmul m2, y1pt, l2_y1;
    fmul m3, y2pt, l3_y2;
    fadd l1_y3, b1, l1_y3;
    fadd l2_y1, b2, l2_y1;
    fadd l3_y2, b3, l3_y2;
    fcomp_l l1_y3, x3pt, cr0;
    fcomp_g l1_y3, x3pt, cr1;
    fcomp_l l2_y1, x1pt, cr2;
    fcomp_g l2_y1, x1pt, cr3;
    fcomp_l l3_y2, x2pt, cr4;
    fcomp_g l3_y2, x2pt, cr5;

#undef x1pt
#undef y1pt
#undef x2pt
#undef y2pt
#undef x3pt
#undef y3pt
#undef x_min
#undef y_min
#undef l1_y3
#undef l2_y1
#undef l3_y2
#def m1_1 r8
#def b1_1 r9
#def m2_1 r10
#def b2_1 r11
#def m3_1 r12
#def b3_1 r13
#def m1_2 r16
#def b1_2 r17
#def m2_2 r18
#def b2_2 r19
#def m3_2 r20
#def b3_2 r21

// XXXXXXXX XXXXXXXX XXXXXX-- --XXXX-S

    [cr0] copy m1, m1_1;
    [cr0] copy b1, b1_1;
    [cr1] copy m1, m1_2;
    [cr1] copy b1, b1_2;
    [cr2] copy m2, m2_1;
    [cr2] copy b2, b2_1;
    [cr3] copy m2, m2_2;
    [cr3] copy b2, b2_2;
    [cr4] copy m3, m3_1;
    [cr4] copy b3, b3_1;
    [cr5] copy m3, m3_2;
    [cr5] copy b3, b3_2;
    [!cr0] copy nan, m1_1;
    [!cr1] copy nan, m1_2;
    [!cr2] copy nan, m2_1;
    [!cr3] copy nan, m2_2;
    [!cr4] copy nan, m3_1;
    [!cr5] copy nan, m3_2;

#undef m1
#undef b1
#undef m2
#undef b2
#undef m3
#undef b3
#def inv_mitad_x r2
#def inv_mitad_y r3
#def ancho r4
#def use_z r5
#def use_alpha r6
#def aux1 r7
#def aux2 r22
#def aux3 r23
#def aux4 r24

// XXXXXXXX XXXXXXXX XXXXXXXX X-XXXX-S

    ploadaddr_l inv_mitad_x_addr;
    loadaddr_h inv_mitad_x_addr, inv_mitad_x;
    load inv_mitad_x, inv_mitad_x;
    i_load inv_mitad_y;

    ploadaddr_l ancho_addr;
    loadaddr_h ancho_addr, ancho;
    load ancho, ancho;

    ploadaddr_l use_z_addr;
    loadaddr_h use_z_addr, use_z;
    load use_z, use_z;
    i_load use_alpha;
    fcomp_ne 0.f, use_z, cr4;
    fcomp_ne 0.f, use_alpha, cr5;

    triangulo_p_while1:
    fcomp_le ypt, y_max, cr0;
    [!cr0] jump triangulo_p_end_while1;
    [!cr0] nop;
        fmul m1_1, ypt, xpt;
        fmul m2_1, ypt, aux1;
        fmul m3_1, ypt, aux2;
        fmul m1_2, ypt, x_max;
        fmul m2_2, ypt, aux3;
        fmul m3_2, ypt, aux4;
        fadd xpt, b1_1, xpt;
        fadd aux1, b2_1, aux1;
        fadd aux2, b3_1, aux2;
        fadd x_max, b1_2, x_max;
        fadd aux3, b2_2, aux3;
        fadd aux4, b3_2, aux4;
        nop;
        nop;
        fmax xpt, aux1, xpt;
        fmin x_max, aux3, x_max;
        fmax xpt, aux2, xpt;
        fmin x_max, aux4, x_max;

        fcomp_le xpt, ancho_1, cr0;
        [cr0] fcomp_le 0.f, x_max, cr0;
            [!cr0] fadd 1.f, ypt, ypt;
            [!cr0] jump triangulo_p_while1;
            [!cr0] nop;

        ceil xpt, xpt;
        floor x_max, x_max;
        fmax 0.f, xpt, xpt;
        fmin x_max, ancho_1, x_max;

#undef use_z
#undef use_alpha
#undef aux1
#undef aux2
#undef aux3
#undef aux4

// XXXXX--- XXXXXXXX XXXXXX-- --XXXX-S

        store_addr stack;
        push y_max;
        push ancho_1;
        push m1_1;
        push b1_1;
        push m2_1;
        push b2_1;
        push m3_1;
        push b3_1;
        push m1_2;
        push b1_2;
        push m2_2;
        push b2_2;
        push m3_2;
        push b3_2;
        load_addr stack;

#undef y_max
#undef ancho_1
#undef m1_1
#undef b1_1
#undef m2_1
#undef b2_1
#undef m3_1
#undef b3_1
#undef m1_2
#undef b1_2
#undef m2_2
#undef b2_2
#undef m3_2
#undef b3_2
#def xp r5
#def yp r6
#def i r7
#def z_my r8
#def z_mx r9
#def z_b r10
#def w_a r11
#def w_b r12
#def w_c r13
#def w_d r16
#def blue_my r17
#def blue_mx r18
#def blue_b r19
#def green_my r20
#def green_mx r21
#def green_b r22
#def red_my r23
#def red_mx r24
#def red_b r25
#def alpha_my r27
#def alpha_mx r28
#def alpha_b r30
#def z z_my
#def w w_c
#def blue blue_my
#def green green_my
#def red red_my
#def alpha alpha_my

// XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXS

        triangulo_p_while2:
        fcomp_le xpt, x_max, cr0;
        [!cr0] jump triangulo_p_end_while2;
        [!cr0] nop;

/*
    i = 4*uint32_t(ancho*(alto_1-ypt)+xpt);

    xp = (xpt-mitad_x)*inv_mitad_x;
    yp = (ypt-mitad_y)*inv_mitad_y;
*/

            fsub alto_1, ypt, i;
            fsub xpt, mitad_x, xp;
            fsub ypt, mitad_y, yp;
            fmul ancho, i, i;
            fmul xp, inv_mitad_x, xp;
            fmul yp, inv_mitad_y, yp;
            fadd i, xpt, i;
            nop;
            nop;
            ftou32 i, i;
            add i, i, i;
            add i, i, i;

            ploadaddr_l z_my_addr;
            loadaddr_h z_my_addr, z_my;
            load z_my, z_my;
            i_load z_mx;
            i_load z_b;
            i_load w_a;
            i_load w_b;
            i_load w_c;
            i_load w_d;
            i_load blue_my;
            i_load blue_mx;
            i_load blue_b;
            i_load green_my;
            i_load green_mx;
            i_load green_b;
            [!cr6] i_load red_my;
            [!cr6] i_load red_mx;
            [!cr6] i_load red_b;
            [!cr6] i_load alpha_my;
            [!cr6] i_load alpha_mx;
            [!cr6] i_load alpha_b;

/*
    z     = z_my*yp     + z_mx*xp     + z_b;
    blue  = blue_my*yp  + blue_mx*xp  + blue_b;
    green = green_my*yp + green_mx*xp + green_b;
    red   = red_my*yp   + red_mx*xp   + red_b;
    alpha = alpha_my*yp + alpha_mx*xp + alpha_b;

    w = w_a / (w_b*z - w_c*yp + w_d*xp);

    z     = w*z;
    blue  = w*blue;
    green = w*green;
    red   = w*red;
    alpha = w*alpha;
*/

            fmul z_my, yp, z_my;
            fmul z_mx, xp, z_mx;
            fmul w_c, yp, w_c;
            fmul w_d, xp, w_d;
            fadd z_my, z_mx, z;
            fmul blue_my, yp, blue_my;
            fmul blue_mx, xp, blue_mx;
            fadd z, z_b, z;
            fsub w_d, w_c, w;
            fmul green_my, yp, green_my;
            fmul green_mx, xp, green_mx;
            fmul w_b, z, w_b;
            fmul red_my, yp, red_my;
            fmul red_mx, xp, red_mx;
            fadd w_b, w, w;
            fmul alpha_my, yp, alpha_my;
            fmul alpha_mx, xp, alpha_mx;
            fdiv w_a, w, w;
            fadd blue_my, blue_mx, blue;
            fadd green_my, green_mx, green;
            fadd red_my, red_mx, red;
            fadd alpha_my, alpha_mx, alpha;
            fadd blue, blue_b, blue;
            fadd green, green_b, green;
            fadd red, red_b, red;
            nop;
            fadd alpha, alpha_b, alpha;
            nop;
            fmul w, z, z;
            fmul w, blue, blue;
            fmul w, green, green;
            fmul w, red, red;
            fmul w, alpha, alpha;

#undef z_my
#undef z_mx
#undef z_b
#undef w_a
#undef w_b
#undef w_c
#undef w_d
#undef blue_my
#undef blue_mx
#undef blue_b
#undef green_my
#undef green_mx
#undef green_b
#undef red_my
#undef red_mx
#undef red_b
#undef alpha_my
#undef alpha_mx
#undef alpha_b
#def buffer_addr r9
#def bufferZ_addr r10
#def color r11
#def Z r12
#def Color r16
#def Blue r18
#def Green r19
#def Red r21
#def Alpha r22
#def texture_addr r24
#def texture_ancho r25
#def texture_alto r28
#def _255 r30

// XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXS

            triangulo_p_if3:
            [!cr6] jump triangulo_p_end_if3;
            [!cr6] nop;
                ploadaddr_l texture_addr_addr;
                loadaddr_h texture_addr_addr, texture_addr;
                load texture_addr, texture_addr;
                i_load texture_ancho;
                i_load texture_alto;

/*
    t_x = trunc((blue -floor(blue)) *texture_ancho);
    t_y = trunc((green-floor(green))*texture_alto);

    color = t[uint32_t(texture_ancho*t_y+t_x)];
*/

                floor blue, red;
                floor green, alpha;
                fsub blue, red, blue;
                fsub green, alpha, green;
                nop;
                fmul blue, texture_ancho, blue;
                fmul green, texture_alto, green;
                nop;
                nop;
                trunc blue, blue;
                trunc green, green;
                fmul texture_ancho, green, green;
                nop;
                nop;
                fadd green, blue, blue;
                nop;
                nop;
                ftou32 blue, blue;
                add blue, blue, blue;
                add blue, blue, blue;
                add texture_addr, blue, alpha;
                load alpha, alpha;
                u8tof_ll alpha, blue;
                u8tof_lh alpha, green;
                u8tof_hl alpha, red;
                u8tof_hh alpha, alpha;
            triangulo_p_end_if3:

            ploadaddr_l buffer_addr_addr;
            loadaddr_h buffer_addr_addr, buffer_addr;
            load buffer_addr, buffer_addr;
            [cr4] i_load bufferZ_addr;

            add buffer_addr, i, buffer_addr;
            add bufferZ_addr, i, bufferZ_addr;
            [cr4] load bufferZ_addr, Z;
            [!cr4] copy inf, Z;

            [cr5] fcomp_ne 0.f, alpha, cr0;
            [!cr5] fcomp_u nan, r0, cr0;
            [cr0] fcomp_l z, Z, cr0;
                [!cr0] fadd 1.f, xpt, xpt;
                [!cr0] jump triangulo_p_while2;
                [!cr0] nop;

            ploadf_l 255;
            loadf_h 255, _255;

            triangulo_p_if4:
            [cr5] fcomp_ne alpha, _255, cr0;
            [!cr5] fcomp_o nan, r0, cr0;
            [!cr0] jump triangulo_p_end_if4;
            [!cr0] nop;

/*
    alpha = alpha/255.f;

    blue  = alpha*blue  + (1.f-alpha)*Blue;
    green = alpha*green + (1.f-alpha)*Green;
    red   = alpha*red   + (1.f-alpha)*Red;
*/

                fdiv alpha, _255, alpha;
                load buffer_addr, Color;
                u8tof_ll Color, Blue;
                u8tof_lh Color, Green;
                u8tof_hl Color, Red;
                nop;
                nop;
                nop;
                nop;
                nop;
                nop;
                fsub 1.f, alpha, Alpha;
                fmul alpha, blue, blue;
                fmul alpha, green, green;
                fmul alpha, red, red;
                fmul Alpha, Blue, Blue;
                fmul Alpha, Green, Green;
                fmul Alpha, Red, Red;
                fadd blue, Blue, blue;
                fadd green, Green, green;
                fadd red, Red, red;
                nop;
                nop;
            triangulo_p_end_if4:

            round blue, blue;
            round green, green;
            round red, red;
            ftou8_ll blue, color, color;
            ftou8_lh green, color, color;
            ftou8_hl red, color, color;
            store color, buffer_addr;
            [cr4] store z, bufferZ_addr;

            fadd 1.f, xpt, xpt;
        jump triangulo_p_while2;
        nop;
        triangulo_p_end_while2:

#undef xp
#undef yp
#undef i
#undef z
#undef w
#undef blue
#undef green
#undef red
#undef alpha
#undef buffer_addr
#undef bufferZ_addr
#undef color
#undef Z
#undef Color
#undef Blue
#undef Green
#undef Red
#undef Alpha
#undef texture_addr
#undef texture_ancho
#undef texture_alto
#undef _255
#def y_max r27
#def ancho_1 r28
#def m1_1 r8
#def b1_1 r9
#def m2_1 r10
#def b2_1 r11
#def m3_1 r12
#def b3_1 r13
#def m1_2 r16
#def b1_2 r17
#def m2_2 r18
#def b2_2 r19
#def m3_2 r20
#def b3_2 r21

// XXXXXX-- XXXXXXXX XXXXXX-- --XXX--S

        store_addr stack;
        pop b3_2;
        pop m3_2;
        pop b2_2;
        pop m2_2;
        pop b1_2;
        pop m1_2;
        pop b3_1;
        pop m3_1;
        pop b2_1;
        pop m2_1;
        pop b1_1;
        pop m1_1;
        pop ancho_1;
        pop y_max;
        load_addr stack;

        fadd 1.f, ypt, ypt;
    jump triangulo_p_while1;
    nop;
    triangulo_p_end_while1:

#undef mitad_x
#undef mitad_y
#undef x_max
#undef y_max
#undef ancho_1
#undef alto_1
#undef ypt
#undef xpt
#undef m1_1
#undef b1_1
#undef m2_1
#undef b2_1
#undef m3_1
#undef b3_1
#undef m1_2
#undef b1_2
#undef m2_2
#undef b2_2
#undef m3_2
#undef b3_2
#undef inv_mitad_x
#undef inv_mitad_y
#undef ancho

store_addr stack;
ret;
load_addr stack;

//________________________________

w_xyz:

/*
    b = y3*(x2-x1) + y2*(x1-x3) + y1*(x3-x2);
    c = z3*(x2-x1) + z2*(x1-x3) + z1*(x3-x2);
    d = z3*(y2-y1) + z2*(y1-y3) + z1*(y3-y2);
    a = w1 * (b*z1p - c*y1p + d*x1p);
*/

#def raddr1 r0
#def raddr2 r1
#def raddr3 r2
#def x1 r3
#def y1 r4
#def z1 r5
#def w1 r6
#def x2 r7
#def y2 r8
#def z2 r9
#def w2 r10
#def x3 r11
#def y3 r12
#def z3 r13
#def w3 r14
#def x1p r15
#def y1p r16
#def z1p r17
#def x2_x1 r18
#def x1_x3 r19
#def x3_x2 r20
#def y2_y1 r21
#def y1_y3 r22
#def y3_y2 r23
#def a r24
#def b r25
#def c r26
#def d r27
#def aux1 r28
#def aux2 r29
#def aux3 r30

    load raddr1, x1;
    i_load y1;
    i_load z1;
    i_load w1;

    load raddr2, x2;
    i_load y2;
    i_load z2;
    i_load w2;

    load raddr3, x3;
    i_load y3;
    i_load z3;
    i_load w3;

    ploadaddr_l x1p_addr;
    loadaddr_h x1p_addr, x1p;
    load x1p, x1p;
    i_load y1p;
    i_load z1p;

    fsub x2, x1, x2_x1;
    fsub x1, x3, x1_x3;
    fsub x3, x2, x3_x2;
    fsub y2, y1, y2_y1;
    fsub y1, y3, y1_y3;
    fsub y3, y2, y3_y2;
    fmul y3, x2_x1, b;
    fmul z3, x2_x1, c;
    fmul z3, y2_y1, d;
    fmul y2, x1_x3, aux1;
    fmul z2, x1_x3, aux2;
    fmul z2, y1_y3, aux3;
    fadd b, aux1, b;
    fadd c, aux2, c;
    fadd d, aux3, d;
    fmul y1, x3_x2, aux1;
    fmul z1, x3_x2, aux2;
    fmul z1, y3_y2, aux3;
    fadd b, aux1, b;
    fadd c, aux2, c;
    fadd d, aux3, d;
    fmul b, z1p, aux1;
    fmul c, y1p, aux2;
    fmul d, x1p, aux3;
    nop;
    fsub aux1, aux2, a;
    nop;
    nop;
    fadd a, aux3, a;
    nop;
    nop;
    fmul w1, a, a;
    nop;
    nop;

    ploadaddr_l w_a_addr;
    loadaddr_h w_a_addr, aux1;
    store a, aux1;
    i_store b;
    i_store c;
    i_store d;

#undef raddr1
#undef raddr2
#undef raddr3
#undef x1
#undef y1
#undef z1
#undef w1
#undef x2
#undef y2
#undef z2
#undef w2
#undef x3
#undef y3
#undef z3
#undef w3
#undef x1p
#undef y1p
#undef z1p
#undef x2_x1
#undef x1_x3
#undef x3_x2
#undef y2_y1
#undef y1_y3
#undef y3_y2
#undef a
#undef b
#undef c
#undef d
#undef aux1
#undef aux2
#undef aux3

store_addr stack;
ret;
load_addr stack;

//________________________________

z_xy:

/*
    my = (z3*(x2-x1) + z2*(x1-x3) + z1*(x3-x2)) /  (y3*(x2-x1) + y2*(x1-x3) + y1*(x3-x2));
    mx = (z3*(y2-y1) + z2*(y1-y3) + z1*(y3-y2)) / -(y3*(x2-x1) + y2*(x1-x3) + y1*(x3-x2));
    b = z1 - my*y1 - mx*x1;
*/

#def raddr1 r0
#def raddr2 r1
#def raddr3 r2
#def _z_my_addr r3
#def x1 r4
#def y1 r5
#def z1 r6
#def x2 r7
#def y2 r8
#def z2 r9
#def x3 r10
#def y3 r11
#def z3 r12
#def x2_x1 r13
#def x1_x3 r14
#def x3_x2 r15
#def y2_y1 r16
#def y1_y3 r17
#def y3_y2 r18
#def aux r19
#def my r20
#def mx r21
#def b r22
#def aux1 r23
#def aux2 r24
#def aux3 r25

    ploadaddr_l x1p_addr;
    loadaddr_h x1p_addr, x1;
    load x1, x1;
    i_load y1;

    ploadaddr_l x2p_addr;
    loadaddr_h x2p_addr, x2;
    load x2, x2;
    i_load y2;

    ploadaddr_l x3p_addr;
    loadaddr_h x3p_addr, x3;
    load x3, x3;
    i_load y3;

    load raddr1, z1;
    load raddr2, z2;
    load raddr3, z3;

    fsub x2, x1, x2_x1;
    fsub x1, x3, x1_x3;
    fsub x3, x2, x3_x2;
    fsub y2, y1, y2_y1;
    fsub y1, y3, y1_y3;
    fsub y3, y2, y3_y2;
    fmul y3, x2_x1, aux;
    fmul z3, x2_x1, my;
    fmul z3, y2_y1, mx;
    fmul y2, x1_x3, aux1;
    fmul z2, x1_x3, aux2;
    fmul z2, y1_y3, aux3;
    fadd aux, aux1, aux;
    fadd my, aux2, my;
    fadd mx, aux3, mx;
    fmul y1, x3_x2, aux1;
    fmul z1, x3_x2, aux2;
    fmul z1, y3_y2, aux3;
    fadd aux, aux1, aux;
    fadd my, aux2, my;
    fadd mx, aux3, mx;
    nop;
    fdiv my, aux, my;
    fneg aux, aux1;
    fdiv mx, aux1, mx;
    nop;
    nop;
    nop;
    nop;
    nop;
    nop;
    nop;
    nop;
    fmul my, y1, aux1;
    nop;
    fmul mx, x1, aux2;
    fsub z1, aux1, b;
    nop;
    nop;
    fsub b, aux2, b;

    store my, _z_my_addr;
    i_store mx;
    i_store b;

#undef raddr1
#undef raddr2
#undef raddr3
#undef _z_my_addr
#undef x1
#undef y1
#undef z1
#undef x2
#undef y2
#undef z2
#undef x3
#undef y3
#undef z3
#undef x2_x1
#undef x1_x3
#undef x3_x2
#undef y2_y1
#undef y1_y3
#undef y3_y2
#undef aux
#undef my
#undef mx
#undef b
#undef aux1
#undef aux2
#undef aux3

store_addr stack;
ret;
load_addr stack;
