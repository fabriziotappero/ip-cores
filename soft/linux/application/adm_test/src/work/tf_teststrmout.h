
#include "tf_testbufm2.h"
#include "tf_workparam.h"
#include "tf_test.h"

class CL_AMBPEX;

class TF_TestStrmOut : public TF_WorkParam, public TF_Test
{

    struct ParamExchange
    {
        U32 Strm;
        U32 Mode;
        U32 BlockWr;
        U32 BlockRd;
        U32 BlockOk;
        U32 BlockError;
        U32 TotalError;
        U32 DataType;	 	// Тип данных при фиксированном типе блока, 6 - счётчик, 8 - псевдослучайная последовательность
        U32 DataFix;		// 1 - фиксированный тип блока, 0 - данные в блоке записят от номера блока
        U32	trd;
        float	VelocityCurrent;
        float	VelocityAvarage;
        TF_TestBufM2 testBuf;

        U32 time_start;
        U32 time_last;
        U32 BlockLast;
        U32 BlockStart;
        U32 freeCycle;
        U32 freeCycleZ;


        ParamExchange()
        {
            Strm=0;
            Mode=0;
            BlockWr=0;
            BlockRd=0;
            BlockOk=0;
            BlockError=0;
            TotalError=0;
            DataType=0;
            DataFix=0;
            trd=0;
            VelocityCurrent=0;
            VelocityAvarage=0;
            time_start=0;
            time_last=0;
            BlockLast=0;
            BlockStart=0;
            freeCycle=0;
            freeCycleZ=0;
        }
    };


    UINT ThreadId;
    pthread_t hThread;
    pthread_attr_t  attrThread_;
    CL_AMBPEX  *pBrd;

    static void* ThreadFunc( void* lpvThreadParm );
    static void* ThreadFuncIsvi( void* lpvThreadParm );

public:

    TF_TestStrmOut( BRDCHAR* fname, CL_AMBPEX *fotr );
    virtual ~TF_TestStrmOut();

    virtual void Prepare( void );
    virtual void Start( void );
    virtual void Stop( void );
    virtual int isComplete( void );
    virtual void GetResult( void );
    virtual void Step( void );
    U32 Execute( void );
    U32 ExecuteIsvi( void );


    //! Установка параметров по умолчанию
    virtual void SetDefault( void );

    //! Расчёт параметров
    virtual void CalculateParams( void );

    //! Отображение параметров
    virtual void ShowParam( void );


    U32 Terminate;
    U32 BlockRd;
    U32 BlockOk;
    U32 BlockError;
    U32 TotalError;

    U32 CntBuffer;			// Число буферов стрима
    U32 CntBlockInBuffer;	// Число блоков в буфере
    U32 SizeBlockOfWords;	// Размер блока в словах
    U32 SizeBlockOfBytes;	// Размер блока в байтах
    U32	SizeBuferOfBytes;	// Размер буфера в байтах
    U32 SizeStreamOfBytes;	// Общий размер буфера стрима
    U32 isCycle;			// 1 - циклический режим работы стрима
    U32 isSystem;			// 1 - системная память
    U32 isAgreeMode;		// 1 - согласованный режим

    U32	trdNo;		// номер тетрады
    U32 strmNo;		// номер стрима
    U32 isSdram;	// 1 - проводить инициализацию SDRAM
    U32 isDac;		// 1 - DAC
    U32 isTest;		// 1 - проверка псевдослучайной последовательности


    char*	fnameDacParam;	// Имя файла параметров для режима АЦП


    U32 lc_status;

    ParamExchange	tr0;

    void SendData( ParamExchange *pr );

private :
    bool isFirstCallStep;

    void PrepareAdm( void );

    //! Запуск проверки в тетраде TestCtrl
    void TestCtrlStart( ParamExchange *pr );

    //! Остановка проверки в тетраде TestCtrl
    void TestCtrlStop( ParamExchange *pr );

    //! Чтение текущего состояния тетрады TestCtrl
    void TestCtrlReadStatus( ParamExchange *pr );

    //! Получение результата в тетраде TestCtrl
    void TestCtrlResult( ParamExchange *pr );


    U32 fa_cnt_re;
    U32 fa_cnt_im;
    U32 fa_inc_re;
    U32 fa_inc_im;

    //! Заполнение блока синусом
    void SetSignalInit( void );

    //! Заполнение блока синусом
    void SetSignal( U32* ptr );

};
