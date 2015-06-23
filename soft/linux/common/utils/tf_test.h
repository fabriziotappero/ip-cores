

#pragma  once

class TF_Test 
{


public:

    virtual ~TF_Test()
    {
      isDmaStart=0;
    }

    virtual void Prepare( void )=0;
    virtual void Start( void )=0;
    virtual void Stop( void )=0;
    virtual int isComplete( void )=0;
    virtual void GetResult( void )=0;
    virtual void Step( void )=0;

    int isDmaStart;

};
