
#ifndef __TF_WORK_PARAM_H__
#define __TF_WORK_PARAM_H__

//! Класс хранения параметров обработки
/**

	\ingroup NodeWork

	Класс содержит параметры используемые при обработке.
	Парметры могут загружаться из файла данных.
	Каждый парметр может быть установлен с использованием
	текстовой строки.

*/
class TF_WorkParam 
{
public:

    //!  Структура массива параметров
    /**     Структра связывает название параметра и указатель на соответсвующую
			переменную.

			\ingroup WorkFunc

	*/
    struct STR_CFG {

        U32     is_float;       //!< 1 - число с плавающей точкой; 0 - целое.
        const char *name;			//!< Название параметра
        const char *def;			//!< Значение по умолчанию
        U32     *ptr;			//!< Указатель на переменную
        const char	*cmt;			//!< Комментарий для параметра

        STR_CFG(
                U32     p_is_float,     //!< 1 - число с плавающей точкой; 0 - целое.
                const char    *p_name,		//!< Название параметра
                const char	*p_def,			//!< Значение по умолчанию
                U32     *p_ptr,			//!< Указатель на переменную
                const char	*p_cmt			//!< Комментарий для параметра
                ){
            is_float = p_is_float;
            name	 = p_name;
            def		 = p_def;
            ptr		 = p_ptr;
            cmt		 = p_cmt;
        }

        STR_CFG(
                ){
            is_float = 100;
            name	 = NULL;
            def		 = NULL;
            ptr		 = NULL;
            cmt		 = NULL;
        }

    };




    TF_WorkParam( void );
    ~TF_WorkParam( void );

    //! Получение параметров из файла инициализации
    void GetParamFromFile(BRDCHAR* fname );

    //! Получение параметра из строки
    U32 GetParamFromStr( char* str );

    STR_CFG  array_cfg[500];
    U32		 max_item;

    //! Расчёт параметров
    virtual void CalculateParams( void );

    //! Сохранение параметров в памяти
    U32 PutParamToMemory( char* ptr, U32 max_size );

    //! Получение параметров из памяти
    void GetParamFromMemory( char* ptr );

    //! Установка параметров по умолчанию
    virtual void SetDefault( void );

    //! Отображение параметров
    virtual void ShowParam( void );

    //! Функция отображения параметров
    void log_out( const char* fmt, ... );
};

#endif //__TF_WORK_PARAM_H__
