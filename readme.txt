____________________________________________________________________________
General Description:
	This is a high performance AES core. It supports 128/192/256 key size
	modes for encryption and decryption.
____________________________________________________________________________
Clock Speed: 
	It can reach more than 300 MHz under 65nm process. 
____________________________________________________________________________
Gatecount: 
	Around 35K NAND2 gates;
____________________________________________________________________________
Performance: 
	Clock Frequency * 128 / Round number, under 200 MHz, it is:
	128 bit -> 2.5Gbps;
	192 bit -> 2.1Gbps;
	256 bit -> 1.8Gbps;
____________________________________________________________________________
Some notes for the interface:
1. After a i_start assert (pluse), please wait for o_key_ready high
2. For decryption, don't input data before o_key_ready is not high
3. For encryption, data can be input after 1cycle of i_start pluse
4. Don't input data if previous cycle's o_ready is low
5. Don't input data if i_enable is low
6. make i_key_mode and i_key stable before o_key_ready is high
7. i_enable is used pause the core for any purpose
8. Basically, you can import 4  128 bit data to the core before the first valid output
	data, because there are 4 pipelines inside. Then you need to wait for the output data for
	Nr*4 cycles. (o_ready is reflecting it actually)
9. key expansion will take 30~40 cycles based on key modes (o_key_ready marks it).
10. Currently, there are 2 16x64 rams, with minor modifications, can change to 
	1 16x128 ram or 4 16x32 rams or 8 16x16 rams
11. in 128/192 mode, the higher bits of i_key is valid
____________________________________________________________________________
Any questions, please contact dongjun_luo@hotmail.com
