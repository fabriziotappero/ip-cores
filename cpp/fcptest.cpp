// fcptest.cpp

#include "fcpprotocol.hpp"

#include <iostream>
#include <time.h>
#include <sys/time.h>

using namespace std;

int main(char ** argv, int argc)
{

	FCPProtocol *fcp = new FCPProtocol();
	bool r = fcp->connect((byte[]){0x01, 0x23, 0x45, 0x67, 0x89, 0xab},
		(byte[]){192, 168, 1, 222});
	cout << "Connected: " << r << endl;
	
	struct timeval start, stop;
	
	gettimeofday(&start, 0);
	r = fcp->sendData(1, (byte[]){0x11}, 1);
	gettimeofday(&stop, 0);
	cout << "Latency Time: " << (long)(stop.tv_usec - start.tv_usec) << " us" << endl;
	cout << "Data Sent: " << r << endl;
	//byte data[] = {0, 0};
	//r = fcp->requestData(1, 1, data);
	//cout << "Data Received: " << r << endl;
	//cout << "Value: " << (int)data[0] << endl;
	
	cout << "Performing Speed Test..." << endl;
	
	byte senddata[1024];
	
	for (int j=0; j<1024; j++)
	{
		senddata[j] = (byte)(j/4);
	}
	
	gettimeofday(&start, 0);
	for (int i=0; i<4096; i++)
	{
    senddata[1023] = i;
		r = fcp->sendData(1,senddata, 1024); 
		if (!r) cout << "Send Error!" << endl;
	}
	gettimeofday(&stop, 0);
	cout << "Throughput Time: " << (long)(stop.tv_usec - start.tv_usec) << " us" << endl;

	cout << "Throughput: " << 32000000.0 / (long)(stop.tv_usec - start.tv_usec) << "Mb/s" << endl;
	
	
	delete fcp;
}
