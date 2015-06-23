// Sizes of our data structures
#define DATA_WIDTH		4
#define DATA_LENGTH		150

#define true 1
#define false 0

void ArrayFill(float aInput[][DATA_WIDTH], int nCountCol, float nValueToFill);
void ArrayTanh(float aInput[DATA_WIDTH]);
void MatrixMultiplication(float aMatrix1[DATA_WIDTH][DATA_WIDTH], float aMatrix2[DATA_WIDTH], float aOutput[DATA_WIDTH], char bPrint);
void MatrixAddition(float aMatrix1[DATA_WIDTH], float aMatrix2[DATA_WIDTH], float aOutput[DATA_WIDTH]);
void Normalize(float aInput[][DATA_WIDTH], int nCountCol);
void Unnormalize(float aInput[][DATA_WIDTH], int nCountCol);

