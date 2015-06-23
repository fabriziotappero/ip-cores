typedef 32 PLBAddrSize;
typedef Bit#(PLBAddrSize) PLBAddr;
typedef 2 WordsPerBeat;  // PLB bandwidth
typedef 16 BurstSize;  // number of beats per burst
typedef 16 BeatsPerBurst;
typedef Bit#(64) BusWord;
typedef TMul#(WordsPerBeat,BeatsPerBurst) WordsPerBurst;
