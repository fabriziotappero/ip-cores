/**     \file
        \brief Функции формирования и проверки массива данных

        В файле содержится реализация класса TF_TestBufM2 - формирование и проверка массива данных.

        \author Dmitry Smekhov
        \version 1.0


*/


#include <stdio.h>

#include "utypes.h"
#include "tf_testbufm2.h"

//! Конструктор
TF_TestBufM2::TF_TestBufM2() {
}

//! Деструктор
TF_TestBufM2::~TF_TestBufM2() {
}



//! Формирование массива
/**     Функция производит формирование массива. Алгоритм формирования
        зависит от номера n.

        \param  buf - указатель на массив
        \param  n   - номер блока
        \param  size - размер массива
		\param  mode - режим заполнения бит 7=1 - фиксированный тип блока, 11..8 - тип блока

*/
void	TF_TestBufM2::buf_set( U32 *buf, U32 n, U32 size, U32 mode ) 
{
    //  n%100 - тип блока
    U32 ii;

    __int64 *ptr=(__int64*)buf;
    U32 size64 = size/2;
    __int64 data_ex = 0ULL;
    __int64 data_sig = 0ULL;
    __int64 data_ex1 = 0ULL;
    __int64 data_ex2 = 0ULL;

    data_sig = n;
    if( mode & 0x80 )
    {
        block_mode=(mode>>8)&0xF;
        data_sig = n;
    }

    data_sig <<=32;
    data_sig |=0xA5A50123;
    *ptr++ = data_sig;  //data_in = *ptr++;

    switch( block_mode )
    {
    case 0:  data_ex = 1; break;
    case 1:  data_ex = ~1; break;
    case 2:  data_ex = 1; break;
    case 3:  data_ex = ~1; break;
    case 4:  data_ex = 1;  data_ex2=0; break;
    case 5:  data_ex = ~1; data_ex2=0xFFFFFFFFFFFFFFFFULL;  break;
    case 6:
    case 7:  data_ex = data_ex_cnt; break;
    case 8:
    case 9:  data_ex = data_ex_noise; break;
    }


    switch( block_mode )
    {
    case 0:
    case 1:
        for( ii=1; ii<size64; ii++ )
        {
            //data_in=*ptr++;
            *ptr++=data_ex;
            {
                U32 f= (data_ex & 0x8000000000000000ULL) ? 1:0;
                data_ex <<= 1;
                data_ex &=~1;
                data_ex |=f;
            }
        }
        break;

         case 2:
         case 3:

        //data_in=*ptr++;
        *ptr++=(~data_ex);
        {
            U32 f= (data_ex & 0x8000000000000000ULL) ? 1:0;
            data_ex <<= 1;
            data_ex &=~1;
            data_ex |=f;
        }

        for( ii=2; ii<size64; ii+=2 )
        {
            //data_in=*ptr++;
            *ptr++=data_ex;
            *ptr++=~data_ex;

            {
                U32 f= (data_ex & 0x8000000000000000ULL) ? 1:0;
                data_ex <<= 1;
                data_ex &=~1;
                data_ex |=f;
            }

        }
        break;


         case 4:
         case 5:
        {
            int flag;
            for( ii=1; ii<size64; ii++ )
            {
                flag=( (n & 0xFF)==(ii&0xFF) )? 1 : 0;
                //data_in=*ptr++;
                data_ex1 = ( flag ) ? data_ex : data_ex2;
                *ptr++=data_ex1;
                if( flag )
                {
                    U32 f= (data_ex & 0x8000000000000000ULL) ? 1:0;
                    data_ex <<= 1;
                    data_ex &=~1;
                    data_ex |=f;
                }
            }
        }
        break;


         case 6:
         case 7:

        //data_in=*ptr++;
        *ptr++=~data_ex;
        //if( (~data_ex)!=data_in )
        //{
        //  cnt_err+=check( 1, ~data_ex, data_in );
        //}
        data_ex++;

        for( ii=2; ii<size64; ii+=2 )
        {
            //data_in=*ptr++;
            *ptr++=data_ex;
            *ptr++=~data_ex;

            data_ex++;

        }
        data_ex_cnt = data_ex;
        break;


         case 8:
         case 9:
        {
            /*
             //__int64 f63;
             //__int64 f62;
             //__int64 f60;
             //__int64 f59;
             //__int64 f0;
             U32 data_h;
             U32 f63;
             U32 f62;
             U32 f60;
             U32 f59;
             U32 f0;
            */



            for( ii=1; ii<size64; ii++ )
            {
                //data_in=*ptr++;
                *ptr++=data_ex;
                
                {/*
                 f63 = data_ex >> 63;
                 f62 = data_ex >> 62;
                 f60 = data_ex >> 60;
                 f59 = data_ex >> 59;
                 f0 = (f63 ^ f62 ^ f60 ^ f59)&1;
                 */
                    U32 data_h=data_ex>>32;
                    U32 f63 = data_h >> 31;
                    U32 f62 = data_h >> 30;
                    U32 f60 = data_h >> 28;
                    U32 f59 = data_h >> 27;
                    U32 f0 = (f63 ^ f62 ^ f60 ^ f59)&1;
                    //U32 data_l=data_ex;
                    //U32 f31 = (data_l>>31) & 1;
                    //data_l<<=1;
                    //data_l&=~1;
                    //data_l|=f0;
                    //data_h<<=1;
                    //data_h&=~1;
                    //data_h|=f31;
                    //data_ex=data_h;
                    //data_ex<<=32;
                    //data_ex|=data_l;

                    data_ex <<= 1;
                    data_ex &= ~1;
                    data_ex |=f0;
                }



            }
        }

        data_ex_noise = data_ex;
        break;



    }

    block_mode++;
    if( block_mode==10 )
        block_mode=0;

    buf_current++;


}




//! Проверка очередного слова данных
/**     Функция производит проверку очередного слова данных.
        При несовпадении ожидаемого и принятого слова функция
        записывает информацию в массив word_error (для первых ошибок -
        не более чем для max_cnt_error) и формирует распределение
        ошибок по битам.

        \param  index  Номер слова в массиве
        \param  d0     Ожидаемые сдово
        \param  di0    Принятое слово
        \return        1 - есть ошибка, 0 - нет ошибки

*/
inline U32     TF_TestBufM2::check( U32 index, __int64 d0, __int64 di0 ) {

    U32 flag_error=0;
    //if( d0!=di0 )
    {
        flag_error=1;
        // Запись информации об ошибке

        if( word_cnt_error<max_cnt_error ) {
            word_error[ word_cnt_error*4+0 ]=buf_current;
            word_error[ word_cnt_error*4+1 ]=index;
            word_error[ word_cnt_error*4+2 ]=d0;
            word_error[ word_cnt_error*4+3 ]=di0;

        }

        word_cnt_error++;
        /*
                if( max_bit_cnt>0 ) {           // Определение распределения по битам
                U32 jj;
                U32 mask=1;
                 for( jj=0; jj<32; jj++ ) {
                    if( (d0&mask)!=(di0&mask) ) {
                      if( max_bit_cnt<=32 ) {
                        if( (di0&mask)==0 )
                         bit_error0[jj%max_bit_cnt]++;
                        else
                         bit_error1[jj%max_bit_cnt]++;
                      } else {
                        if( (di0&mask)==0 )
                         bit_error0[jj+32*(index&1)]++;
                        else
                         bit_error1[jj+32*(index&1)]++;
                      }

                    }
                 }
                }
                */
    }
    return flag_error;
}




//! Проверка массива
/**     Функция проверяет массив buf на соответствие ожидаемым данным.
        Массив должен быть сформирован функцией buf_set или аналогичной
        При обнаружении ошибки в массив word_error записываются четыре числа:
                - номер массива
                - индекс в массивк
                - ожидаемые данные
                - полученные данные
        В массивы bit_error0 и bit_error1 заносится распределение ошибок по битам.

        \param  buf     - Адрес массива
        \param  n       - Номер массива
        \param  size    - Размер массива в 32-х разрядных словах
        \param  mode    - Режим формирвоания блока: бит 7=1 - признак принудительной установки, 11..8 - тип

        \return Число обнаруженных ошибок

*/
U32     TF_TestBufM2::buf_check( U32 *buf, U32 n, U32 size, U32 mode ) {

    //  n%100 - тип блока
    U32 ii;
    U32 cnt_err=0;

    __int64 *ptr=(__int64*)buf;
    U32 size64 = size/2;
    __int64 data_ex = 0ULL;
    __int64 data_in = 0ULL;
    __int64 data_sig = 0ULL;
    __int64 data_ex1 = 0ULL;
    __int64 data_ex2 = 0ULL;

    data_sig = n;
    if( mode & 0x80 )
    {
        block_mode=(mode>>8)&0xF;
        data_sig = n;
    }

    data_sig <<=32;
    data_sig |=0xA5A50123;
    data_in = *ptr++;
    if( data_sig!=data_in )
    {
        cnt_err+=check( 0, data_sig, data_in );
    }

    /*
	  when "0000" => -- Бегущая 1 по 64-м разрядам
			  	data_ex0 <= x"0000000000000001" after 1 ns;
			  when "0001" => -- Бегущий 0 по 64-м разрядам
			  	data_ex0 <= not x"0000000000000001" after 1 ns;
			  when "0010" => -- Бегущая 1 с инверсией  по 64-м разрядам
			  	data_ex1 <= x"0000000000000001" after 1 ns;
			  when "0011" => -- Бегущий 0 с инверсией  по 64-м разрядам
			  	data_ex1 <= not x"0000000000000001" after 1 ns;
			  when "0100" => -- Бегущая 1 в блоке 0
			  	data_ex2 <= x"0000000000000001" after 1 ns;
			  	data_ex3 <= (others=>'0');
			  when "0101" => -- Бегущий 0 в блоке 1
			  	data_ex2 <= not x"0000000000000001" after 1 ns;
			  	data_ex3 <= (others=>'1') after 1 ns;
           */
    switch( block_mode )
    {
    case 0:  data_ex = 1; break;
    case 1:  data_ex = ~1; break;
    case 2:  data_ex = 1; break;
    case 3:  data_ex = ~1; break;
    case 4:  data_ex = 1;  data_ex2=0; break;
    case 5:  data_ex = ~1; data_ex2=0xFFFFFFFFFFFFFFFFULL;  break;
    case 6:
    case 7:  data_ex = data_ex_cnt; break;
    case 8:
    case 9:  data_ex = data_ex_noise; break;
    }


    switch( block_mode )
    {
    case 0:
    case 1:
        for( ii=1; ii<size64; ii++ )
        {
            data_in=*ptr++;
            if( data_ex!=data_in )
            {
                cnt_err+=check( ii, data_ex, data_in );
                //cnt_err=0;
            }
            {
                U32 f= (data_ex & 0x8000000000000000ULL) ? 1:0;
                data_ex <<= 1;
                data_ex &=~1;
                data_ex |=f;
            }
        }
        break;

         case 2:
         case 3:

        data_in=*ptr++;
        if( (~data_ex)!=data_in )
        {
            cnt_err+=check( 1, ~data_ex, data_in );
        }
        {
            U32 f= (data_ex & 0x8000000000000000ULL) ? 1:0;
            data_ex <<= 1;
            data_ex &=~1;
            data_ex |=f;
        }

        for( ii=2; ii<size64; ii+=2 )
        {
            data_in=*ptr++;
            if( data_ex!=data_in )
            {
                cnt_err+=check( ii, data_ex, data_in );
                //cnt_err=0;
            }


            data_in=*ptr++;
            if( (~data_ex)!=data_in )
            {
                cnt_err+=check( ii+1, ~data_ex, data_in );
            }


            {
                U32 f= (data_ex & 0x8000000000000000ULL) ? 1:0;
                data_ex <<= 1;
                data_ex &=~1;
                data_ex |=f;
            }

        }
        break;


         case 4:
         case 5:
        {
            int flag;
            for( ii=1; ii<size64; ii++ )
            {
                flag=( (n & 0xFF)==(ii&0xFF) )? 1 : 0;
                data_in=*ptr++;
                data_ex1 = ( flag ) ? data_ex : data_ex2;
                if( data_ex1!=data_in )
                {
                    cnt_err+=check( ii, data_ex1, data_in );
                    //cnt_err=0;
                }
                if( flag )
                {
                    U32 f= (data_ex & 0x8000000000000000ULL) ? 1:0;
                    data_ex <<= 1;
                    data_ex &=~1;
                    data_ex |=f;
                }
            }
        }
        break;


         case 6:
         case 7:

        data_in=*ptr++;
        if( (~data_ex)!=data_in )
        {
            cnt_err+=check( 1, ~data_ex, data_in );
        }
        data_ex++;

        for( ii=2; ii<size64; ii+=2 )
        {
            data_in=*ptr++;
            if( data_ex!=data_in )
            {
                cnt_err+=check( ii, data_ex, data_in );
                //cnt_err=0;
            }


            data_in=*ptr++;
            if( (~data_ex)!=data_in )
            {
                cnt_err+=check( ii+1, ~data_ex, data_in );
            }

            data_ex++;

        }
        data_ex_cnt = data_ex;
        break;


         case 8:
         case 9:
        {
            /*
             //__int64 f63;
             //__int64 f62;
             //__int64 f60;
             //__int64 f59;
             //__int64 f0;
             U32 data_h;
             U32 f63;
             U32 f62;
             U32 f60;
             U32 f59;
             U32 f0;
            */



            for( ii=1; ii<size64; ii++ )
            {
                data_in=*ptr++;

                if( data_ex!=data_in )
                {
                    cnt_err+=check( ii, data_ex, data_in );
                }
                
                {/*
                 f63 = data_ex >> 63;
                 f62 = data_ex >> 62;
                 f60 = data_ex >> 60;
                 f59 = data_ex >> 59;
                 f0 = (f63 ^ f62 ^ f60 ^ f59)&1;
                 */
                    U32 data_h=data_ex>>32;
                    U32 f63 = data_h >> 31;
                    U32 f62 = data_h >> 30;
                    U32 f60 = data_h >> 28;
                    U32 f59 = data_h >> 27;
                    U32 f0 = (f63 ^ f62 ^ f60 ^ f59)&1;
                    //U32 data_l=data_ex;
                    //U32 f31 = (data_l>>31) & 1;
                    //data_l<<=1;
                    //data_l&=~1;
                    //data_l|=f0;
                    //data_h<<=1;
                    //data_h&=~1;
                    //data_h|=f31;
                    //data_ex=data_h;
                    //data_ex<<=32;
                    //data_ex|=data_l;

                    data_ex <<= 1;
                    data_ex &= ~1;
                    data_ex |=f0;
                }



            }
        }

        data_ex_noise = data_ex;
        break;



    }

    block_mode++;
    if( block_mode==10 )
        block_mode=0;

    buf_current++;
    if (cnt_err==0)
        buf_cnt_ok++;
    else
        buf_cnt_error++;

    return cnt_err;

}


//! Проверка массива
/**     Функция проверяет массив buf на соответствие ожидаемым данным.
        Массив должен быть сформирован функцией buf_set или аналогичной
        При обнаружении ошибки в массив word_error записываются четыре числа:
                - номер массива
                - индекс в массивк
                - ожидаемые данные
                - полученные данные
        В массивы bit_error0 и bit_error1 заносится распределение ошибок по битам.

		Ожидается псевдослучайная последовательность. Начальное значение 2;
		Сигнатуры и номера блока не ожидается.

        \param  buf     - Адрес массива
        \param  size    - Размер массива в 32-х разрядных словах

        \return Число обнаруженных ошибок

*/
U32     TF_TestBufM2::buf_check_psd( U32 *buf, U32 size  ) 
{

    //  n%100 - тип блока
    U32 ii;
    U32 cnt_err=0;

    __int64 *ptr=(__int64*)buf;
    U32 size64 = size/2;
    __int64 data_ex;
    __int64 data_in;

    data_ex = data_ex_psd ;


    for( ii=0; ii<size64; ii++ )
    {
        data_in=*ptr++;

        if( data_ex!=data_in )
        {
            if( word_cnt_error<max_cnt_error )
            {
                word_error[ word_cnt_error*4+0 ]=buf_current;
                word_error[ word_cnt_error*4+1 ]=ii;
                word_error[ word_cnt_error*4+2 ]=data_ex;
                word_error[ word_cnt_error*4+3 ]=data_in;
            }
            word_cnt_error++;
            cnt_err++;
            //cnt_err+=check( ii, data_ex, data_in );
            data_ex=data_in;
        }

        {/*
             f63 = data_ex >> 63;
             f62 = data_ex >> 62;
             f60 = data_ex >> 60;
             f59 = data_ex >> 59;
             f0 = (f63 ^ f62 ^ f60 ^ f59)&1;
             */

            U32 data_h=data_ex>>32;
            U32 f63 = data_h >> 31;
            U32 f62 = data_h >> 30;
            U32 f60 = data_h >> 28;
            U32 f59 = data_h >> 27;
            U32 f0 = (f63 ^ f62 ^ f60 ^ f59)&1;

            //U32 data_l=data_ex;
            //U32 f31 = (data_l>>31) & 1;
            //data_l<<=1;
            //data_l&=~1;
            //data_l|=f0;
            //data_h<<=1;
            //data_h&=~1;
            //data_h|=f31;
            //data_ex=data_h;
            //data_ex<<=32;
            //data_ex|=data_l;

            data_ex <<= 1;
            data_ex &= ~1;
            data_ex |=f0;
        }



    }

    data_ex_psd = data_ex;

    block_mode++;
    if( block_mode==10 )
        block_mode=0;

    buf_current++;
    if (cnt_err==0)
        buf_cnt_ok++;
    else
        buf_cnt_error++;

    return cnt_err;

}

//! Проверка двоично-инверсной последовательности
U32     TF_TestBufM2::buf_check_inv( U32 *buf, U32 size  )
{

    //  n%100 - тип блока
    U32 ii;
    U32 cnt_err=0;

    __int64 *ptr=(__int64*)buf;
    U32 size64 = size/2;
    __int64 data_ex;
    __int64 data_in;

    register unsigned f0;


    data_ex = data_ex_inv ;


    for( ii=0; ii<size64; ii++ )
    {
        data_in=*ptr++;

        if( data_ex!=data_in )
        {
            cnt_err+=check( ii, data_ex, data_in );
            //data_ex=data_in;
        }

        //data_h=data_ex>>32; f63 = data_h >> 31; f0 = f63^1; data_ex <<= 1; data_ex &= ~1; data_ex |=f0;
        f0 = ((data_ex >>63) & 1) ^1; data_ex <<= 1; data_ex &= ~1; data_ex |=f0;




    }

    data_ex_inv = data_ex;

    block_mode++;
    if( block_mode==10 )
        block_mode=0;

    buf_current++;
    if (cnt_err==0)
        buf_cnt_ok++;
    else
        buf_cnt_error++;

    return cnt_err;

}

//! Начало проверки группы массивов
/**     Функция подготавливает параметры для проверки нескольких массивов.
        Обнуляются счётчики ошибок.

        \param  n_error - число фиксируемых ошибок. Не больше 128.
        \param  bit_cnt - Число бит в слове, для определения распределения ошибок по битам.


*/
void  TF_TestBufM2::buf_check_start( U32 n_error, U32 bit_cnt ) {

    if( n_error<32 ) {
        max_cnt_error=n_error;
    } else {
        max_cnt_error=32;
    }

    buf_cnt_ok=0;
    buf_cnt_error=0;
    word_cnt_error=0;
    buf_current=0;
    max_bit_cnt=bit_cnt;
    block_mode=0;

    data_ex_cnt=0;
    data_ex_noise=1;
    data_ex_psd=2;
    data_ex_inv=0;

    for( int ii=0; ii<64; ii++ ) {
        bit_error0[ii]=0;
        bit_error1[ii]=0;
    }

    for( int ii=0; ii<128*4; ii++ ) {
        word_error[ii]=0;
    }

}

//! Результаты проверки группы массивов
/**     Функция возвращает результаты проверки массивов.
        Если указатель равен NULL, то он игнорируется.

        \param  cnt_ok          - Указатель на число правильных массивов.
        \param  cnt_error       - Указатель на число неправильных массивов.
        \param  error           - Указатель на указатель. По этому адресу
         передаётся указатель на word_error - список ошибок.

        \param  bit0            - Указатель на указатель. По этому адресу
         передаётся указатель на bit_error0 - число ошибочно принятых нулей по битам.

        \param  bit1            - Указатель на указатель. По этому адресу
         передаётся указатель на bit_error1 - число ошибочно принятых нулей по битам.

        \return Общее число ошибок.

*/

U32   TF_TestBufM2::check_result( U32 *cnt_ok, U32 *cnt_error, U32 **error, U32 **bit0, U32 **bit1 ) {

    if( cnt_ok ) *cnt_ok=buf_cnt_ok;
    if( cnt_error ) *cnt_error=buf_cnt_error;
    if( error ) *error=(U32*)word_error;
    if( bit0 )  *bit0=bit_error0;
    if( bit1 )  *bit1=bit_error1;

    return word_cnt_error;
}

//! Формирование отчёта по ошибкам
/**     Функция формирует отчёт по обнаруженным ошибкам и
        возвращает указатель на сформированную строку.
        Выводится номер массива, адрес в массиве,
        ожидаемое и полученное значение.
        Выводится распределение ошибок по битам для каждого слова.


*/
char*  TF_TestBufM2::report_word_error( void ) {

    char *ptr=str;
    int len;
    //char bit[64], *ptr_bit;
    U32 nb, na;
    __int64 dout, din;
    int size=0;
    //U32 mask;
    *ptr=0;
    int cnt=max_cnt_error;
    if( word_cnt_error<max_cnt_error )
        cnt=word_cnt_error;
    for( int ii=0; ii<cnt; ii++ ) {
        nb=word_error[ii*4+0];
        na=word_error[ii*4+1];
        dout=word_error[ii*4+2];
        din=word_error[ii*4+3];
        //ptr_bit=bit;
        /*
          mask=0x80000000;
          for( int jj=0; jj<32; jj++ ) {
            if( mask & (dout ^ din ) ) {
             *ptr_bit++='1';
            } else {
             *ptr_bit++='0';
            }
            mask>>=1;
            if( ((jj+1)%8)==0 ) *ptr_bit++=' ';
          }
          *ptr_bit=0;
          */

        //          len=sprintf( ptr, "%4d  Block: %-4d  Index: %.8X  Waiting: %.16LX  Receive: %.16LX \r\n",
        len=sprintf( ptr, "%4d  Block: %-4d  Index: %.8X  Waiting: %.16llX  Received: %.16llX \r\n",
                     //"                  Bits:   %s\r\n\r\n"
                     ii, nb, na, dout, din
                     //bit
                     );
        ptr+=len;
        size+=len;
        if( size>5000 ) break;

    }
    return str;
}

//! Формирование отчёта распределения ошибок по битам
/**     Функция формирует отчёт по обнаруженным ошибкам и
        возвращает указатель на сформированную строку.
        Выводиться число ошибок для каждого бита,
        число ошибочно принятых 0 и число ошибочно принятых 1.

*/
char*  TF_TestBufM2::report_bit_error( void ) {

    char *ptr=str;
    //int len;
    //char bit[64], *ptr_bit;
    //U32 mask;
    *ptr=0;

    return str;
}


//---------------------------------------------------------------------------

