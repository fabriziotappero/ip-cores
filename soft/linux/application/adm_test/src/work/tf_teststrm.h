
#include "tf_testbufm2.h"
#include "tf_workparam.h"
#include "tf_test.h"

class CL_AMBPEX;
class TF_TestDDS;
class TF_Emac;

class TF_TestStrm : public TF_WorkParam, public TF_Test
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
        float	fftTime_us;
        TF_TestBufM2 testBuf;

        long time_start;
        long time_last;
        U32 BlockLast;
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
            freeCycle=0;
            freeCycleZ=0;
        }
    };

    UINT ThreadId;
    UINT ThreadIdIsvi;

    pthread_t hThread;
    pthread_attr_t  attrThread_;

    pthread_t hThreadIsvi;
    pthread_attr_t  attrThreadIsvi_;

    CL_AMBPEX  *pBrd;

    static void* ThreadFunc( void* lpvThreadParm );
    static void* ThreadFuncIsvi( void* lpvThreadParm );

public:

    TF_TestStrm( BRDCHAR* fname, CL_AMBPEX *fotr );
    virtual ~TF_TestStrm();

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

    U32 CntBuffer;		// Число буферов стрима
    U32 CntBlockInBuffer;	// Число блоков в буфере
    U32 SizeBlockOfWords;	// Размер блока в словах
    U32 SizeBlockOfBytes;	// Размер блока в байтах
    U32	SizeBuferOfBytes;	// Размер буфера в байтах
    U32 SizeStreamOfBytes;	// Общий размер буфера стрима
    U32 isCycle;		// 1 - циклический режим работы стрима
    U32 isSystem;		// 1 - системная память
    U32 isAgreeMode;		// 1 - согласованный режим

    U32	trdNo;		// номер тетрады
    U32 strmNo;		// номер стрима
    U32 isTest;		// 1 - проверка псевдослучайной последовательности, 2 - проверка тестовой последовательности
    U32 isMainTest; // 1 - включение режима тестирования в тетараде MAIN

    U32 isFifoRdy;	// 1 - генератор тестовой последовательности анализирует флаг готовности FIFO
    U32 Cnt1;		// Число тактов записи в FIFO, 0 - постоянная запись в FIFO
    U32 Cnt2;		// Число тактов паузы при записи в FIFO
    U32 DataType;	// Тип данных при фиксированном типе блока, 6 - счётчик, 8 - псевдослучайная последовательность
    U32 DataFix;	// 1 - фиксированный тип блока, 0 - данные в блоке записят от номера блока

    U32	BlockMode;	// режим проверки

    U32 isTestCtrl;	// 1 - подготовка тетрады TEST_CTRL

    char*	fnameAdcParam;	// Имя файла параметров для режима АЦП
    char*	fnameDdcParam;	// Имя файла параметров для режима DDC
    char*	fnameIsvi;		// Имя файла данных ISVI

    char*	fnameAdmReg;	// Имя файла регистров
    U32		isAdmReg;		// 1 - разрешение записи регистров из файла fnameAdmReg

    char*	fnameAdmReg2;	// Имя файла регистров (выполняется после старта стрима)
    U32		isAdmReg2;		// 1 - разрешение записи регистров из файла fnameAdmReg2

    U32		isIsvi;			// 1 - вывод в ISVI
    U32*	bufIsvi;		// Буфер данных ISVI
    char	IsviHeaderStr[1024]; // суффикс ISVI
    U32		IsviHeaderLen;
    U32		IsviHeaderMode;			// режим формирования суффикса ISVI, 0 - нет, 1 - DDC, 2 - ADC
    U32		IsviStatus;			// состояние вывода в ISVI
    U32		IsviCnt;			// число выведенных кадров в ISVI

    void IsviStep( U32* ptr );
    void WriteFlagSinc(int flg, int isNewParam);
    int  ReadFlagSinc(void);
    void WriteDataFile( U32 *pBuf, U32 sizew );

    U32 lc_status;
    float cpuFreq;

    ParamExchange       rd0;

    void ReceiveData(  ParamExchange *pr );

    U32	 TestSeq;	// Региср управления режимом формирования тестовой последовательности

    void RestartAdc( void );

    U32 isRestart;	// 1 - перезапуск сбора после завершения заполнения буфера стрима
    U32 cntRestart; // число перезапусков

    U32 isSystemMonitor;    //!< 1 - чтение данных системного монитора

private :

    bool isFirstCallStep;

    void PrepareAdm( void );
    void PrepareAdmReg( char* fname );
    void PrepareAdc( void );
    void PrepareDac( void );
    void RestartDac(void);
    void PrepareMain( void );
    void PrepareTestCtrl( void );
    void StartTestCtrl( void );
};
