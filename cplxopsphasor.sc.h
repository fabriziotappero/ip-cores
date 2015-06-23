
#include <systemc.h>
#ifndef _CPLXOPSPHASOR_H_
#define _CPLXOPSPHASOR_H_

template<typename T>
class complex
{
    T real, imag;
    /*initialization of the real and imaginal parts of the complex values as 0
    definition of copy constructor and assignment operator*/
public:
    complex() : real(0),imag(0)         
    {
    }
    complex( const T& real_, const T& imag_ ) : real(real_), imag(imag_){}
    complex( const complex& other ) : real(other.real), imag(other.imag){}
    complex& operator = ( const complex& other )
    {
        real = other.real;
        imag = other.imag;
        return *this;
    }

    /*definiton of mutators and access member functions*/
    T get_real() const
    {
        return real;
    }
    T get_imag() const
    {
        return imag;
    }
    void set_real( const T& real_ )
    {
        real = real_;
    }
    void set_imag( const T& imag_ )
    {
        imag = imag_;
    }

    /*Definition of member operators*/
    complex& operator += ( const complex& other )
    {
        real += other.real;
        imag += other.imag;
        return *this;
    }
    /*Definition of complex aritmetic operators as friend Operators.*/
    friend complex operator + ( const complex& a, const complex& b )  //approved
    {
        complex result;
        result.set_real( a.get_real() + b.get_real() );
        result.set_imag( a.get_imag() + b.get_imag() );
        return result;
    }
    friend complex operator * ( const complex& a, const complex& b )  //approved
    {
        complex result;
        sc_uint<8> areal, aimag, breal, bimag;       //real and imaginary parts of the operands
        sc_uint<16> tempreal,tempimag;               //temporary outputs (16 BITS)
        
        /*complex multiplication of two complex numnbers a and b is defined by
        a*b=(areal*breal-aimag*bimag)+i(areal*bimag+aimag*breal)*/
        
        areal=a.get_real();aimag=a.get_imag();
        breal=b.get_real();bimag=b.get_imag();
        tempreal=areal*breal-aimag*bimag;       
        tempimag=aimag*breal+areal*bimag;
        result.set_real(tempreal);
        result.set_imag(tempimag);
        return result;                              //the result is returned
    }
    
    friend complex operator / ( const complex& a, const complex& b ) //approved
    {
        complex result;
        sc_uint<4> count=0;
        sc_uint<8> areal, aimag, breal, bimag;                                                   //real and imaginary parts of the operands
        sc_uint<8> tempxa=0,tempya=0,tempxb=0,tempyb=0,anglea=0,angleb=0,angleresult,rresult,angle=90,us=128;    //,raparameters to accumulate the temporary results of the operation
//        sc_uint<16> rb;
        areal=a.get_real(); breal=b.get_real(); aimag=a.get_imag(); b.get_imag();                       //read real and imaginary parts of the complex operands
        /*the operands will first be converted from cartesian to polar representation using cordic techniques
       then the operands will be divided as a/b=ra/rb(anglea-angleb) */
        if (areal[7]==1)                    //determination of the initial angular position of the operands
        {
            anglea=180;
        }
        if (breal[7]==1)
        {
            angleb=180;
        }
        while (count<=6)                    //CORDIC vector mode operation for converting 
        {                                   //the operands from cartesian to polar representation
            angle=angle>>1;
			count++;
			tempxa = areal>>count;
            tempya = aimag>>count;
            tempxb = breal>>count;
            tempyb = bimag>>count;
           if ( aimag[7]==1 )              //CORDIC operation for the first operand
            {
                areal=areal-tempya;
                aimag=aimag+tempxa;
                anglea=anglea-angle;
            }
            else //if ( aimag[7]==0 )
            {
                areal=areal+tempya;
                aimag=aimag-tempxa;
                anglea=anglea+angle; 
           }
            if ( bimag[7]==0 )             //CORDIC operation for the second operand
            {
                breal=breal-tempyb;
                bimag=bimag+tempxb;
                angleb=angleb-angle;
            }
            else //if ( bimag[7]==0 )
            {
                breal=breal+tempyb;
                bimag=bimag-tempxb;
                angleb=angleb+angle;
           }

        }
        rresult=areal/breal;                      //divide the absolute values
        angleresult=anglea-angleb;          //subtract the polar angles
        count=0;
        sc_uint<8> y=0,tempr,tempy;
		angle=90;
        while (count<=6)                    //CORDIC vector mode operation for converting 
        {                                   //the result from polar to cartesian representation
            count++;
			tempr = rresult>>count;
            tempy = y>>count;
            angle=angle>>1;
            if (angleresult[7]==0)
            {
                rresult=rresult-tempy;
                y=y+tempr;
                angleresult=angleresult-angle;
            }
            else if (angleresult[7]==1)
            {
                rresult=rresult+tempy;
                y=y-tempr;
                angleresult=angleresult+angle;
            }
         }
        result.set_real(rresult);
        result.set_imag(angleresult);
        return result;         
   }

    friend complex pol2car ( const complex& a)//approved
    {
        complex result;
        sc_int <4> count=0;
        sc_uint <8> r,angle;                 //absolute value and polar angle of the operand
        sc_uint <8> tempr,tempy,tempangle=90,y; //temporary values for polar to cartesian operation
        r=a.get_real();
        angle=a.get_imag();
         while (count<6) //count= 1; count < 7; count++)  //Cordic operation for polar to cartesian transformation
        {
            count++;
			tempr = r >>count;
            tempy = y >>count;
            tempangle=tempangle>>1;
            if (angle[7]==0)
            {
                r=r-tempy;
                y=y+tempr;
                angle=angle-tempangle;
            }
            else if (angle[7]==1)
            {
                r=r+tempy;
                y=y-tempr;
                angle=angle+tempangle;
            }
        }
        result.set_real(r);
        result.set_imag(y);
        return (result);
    }

    friend complex sqrt ( const complex& a)	//approved
    {    //sqrt(x+iy)==1/2sqrt(2)[sqrt(sqrt(x^2+y^2)+x)+isgn(y)sqrt(sqrt(x^2+y^2)-x)].
        complex result;
        int cnt=0;//,cnt1=1;
        sc_uint<8> tempabs, tempreal, tempimag, sgn, areal, aimag, abs, base1, base2, sqrt1,sqrt2;//ra,
        sc_uint<8> tempareal,tempaimag;
		areal=a.get_real();
        aimag=a.get_imag();
        abs=a.get_real();
        while (cnt<6)        //CORDIC vector mode to evaluate the absolute value of a
        {
            cnt++;           
            tempareal = areal >>cnt;
            tempaimag = aimag >>cnt;   
            if ( aimag[7]==1)
            {
                abs=abs-tempaimag;
                aimag=aimag+tempabs;
            }
            if ( aimag[7]==0)
            {
                abs=abs+tempaimag;
                aimag=aimag-tempabs;                
            }
        }
        tempreal=abs+a.get_real();                  //sqrt(x^2+y^2)+x
        tempimag=abs-a.get_real();                  //sqrt(x^2+y^2)-x
        sqrt1=0;base1=8;sqrt2=0;base2=8;        
        for (cnt= 0; cnt < 2; cnt++)//while (cnt1<5)                             //evaluating the temporary square roots using numeric techniques
        {                                           //sqrt(sqrt(x^2+y^2)+x),sqrt(sqrt(x^2+y^2)-x)
                 sqrt1 = base1 + sqrt1;
                if  ( (base1 * base1) > tempreal )
                {
                        sqrt1 = base1 - sqrt1 ;     // base should not have been added, so we substract again
                }
                base1>>1 ;                        // shift 1 digit to the right = divide baimag 2
                sqrt2 = base2 + sqrt2 ;
                if  ( (sqrt2 * sqrt2) > tempimag )
                {
                        sqrt2 = base2 - sqrt2 ;    
                }
                base2>>1 ;                        
        }
        sqrt1=sqrt1>>1;                             //multiply the tmeporary results with 0.5 instead of 0.7
        sqrt2=sqrt2>>1;                             //1/2*sqrt(2)=
        sqrt2[7]=aimag[7];                          //apply the sign of the imaginary part
        result.set_real(sqrt1);
        result.set_imag(sqrt2);
        return result;
    }
    
    friend complex operator - ( const complex& a, const complex& b )//approved
    {
        complex result;
        result.set_real( a.get_real() - b.get_real() );
        result.set_imag( a.get_imag() - b.get_imag() );
        return result;
    }

    friend complex conj ( const complex& a )//approved
    {
        complex result;
		sc_uint<8> tempa,tempb;
		tempa=a.get_imag();
		tempb=tempa;
		tempb[7]=!tempa[7];
        result.set_real( a.get_real());
        result.set_imag( tempb);
        return result;
    }
    /*
     * Predicate operators
     
     */
    friend bool operator == ( const complex& a, const complex& b )
    {
        return ( (a.get_real() == b.get_real()) && (a.get_real() == b.get_real()) );
    }
    friend bool operator != ( const complex& a, const complex& b )
    {
        return ( ! (a == b) );
    }
};



#endif





