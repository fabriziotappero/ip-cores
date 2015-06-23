#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "ann.h"
#include "Data.h"
// include definitions for performance counter and custom instruction
#include "altera_avalon_performance_counter.h"
#include "system.h"

// debug options
#define PRINT_RESULTS    1
#define ACCELERATED_TANH 0
#define ACCELERATED_FLOATING_POINT 1

#if ACCELERATED_FLOATING_POINT == 0
#pragma no_custom_fadds
#pragma no_custom_fsubs
#pragma no_custom_fmuls
#pragma no_custom_fdivs
#endif // ACCELERATED_FLOATING_POINT == 0

#if ACCELERATED_TANH != 0
#define ALT_F_LOGSIG_APPROX_INST(A) __builtin_custom_fnf(ALT_CI_LOGSIG_APPROX_INST_N,(A))
#endif // ACCELERATED_TANH != 0

float aOutput[DATA_LENGTH][DATA_WIDTH];

void PrintArray(float *aIn, int nLength)
{
	int nIndex;  
    
    printf("\n");
	for (nIndex = 0; nIndex < nLength; nIndex++)
	{
		printf("%f ", aIn[nIndex]);
	}
	printf("\n");
}

int main()
{
	int nIndexCol, nIndexRow;
    float nMeanSquaredError = 0;
    float nCurrentError = 0;
    
	float aInputWeightsMultipliedByInput[DATA_WIDTH];
	float aIntermediate1[DATA_WIDTH];

	float aHiddenWeightsMultipliedByInt1[DATA_WIDTH];
	float aIntermediate2[DATA_WIDTH];

	float aOutputWeightsMultipliedByInt2[DATA_WIDTH];

    printf("Start: Tansig acceleration [%d], floating point unit [%d]\n", ACCELERATED_TANH, ACCELERATED_FLOATING_POINT );

    Normalize(aInput, DATA_LENGTH);
    ArrayFill(aOutput, DATA_LENGTH, 0);

    // start measuring time
    PERF_RESET (PERFORMANCE_COUNTER_0_BASE);            //Reset Performance Counters to 0
    PERF_START_MEASURING (PERFORMANCE_COUNTER_0_BASE);  //Start the Counter
    PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,2);          //Start the overhead counter
    PERF_BEGIN (PERFORMANCE_COUNTER_0_BASE,1);          //Start the Matrix Multiplication Counter
    PERF_END (PERFORMANCE_COUNTER_0_BASE,2);            //Stop the overhead counter

	for (nIndexCol = 0; nIndexCol < DATA_LENGTH; nIndexCol++)
	{
		MatrixMultiplication(aInputWeights, aInput[nIndexCol], aInputWeightsMultipliedByInput, false);
		MatrixAddition(aInputWeightsMultipliedByInput, aInputBias, aIntermediate1);
		ArrayTanh(aIntermediate1);

		MatrixMultiplication(aHiddenWeights, aIntermediate1, aHiddenWeightsMultipliedByInt1, false);
		MatrixAddition(aHiddenWeightsMultipliedByInt1, aHiddenBias, aIntermediate2);
		ArrayTanh(aIntermediate2);

		MatrixMultiplication(aOutputWeights, aIntermediate2, aOutputWeightsMultipliedByInt2, false);
		MatrixAddition(aOutputWeightsMultipliedByInt2, aOutputBias, aOutput[nIndexCol]);
	}

    PERF_END (PERFORMANCE_COUNTER_0_BASE,1);            //Stop the Matrix Multiplication Counter
    PERF_STOP_MEASURING (PERFORMANCE_COUNTER_0_BASE);   //Stop all counters  
    perf_print_formatted_report((void *)PERFORMANCE_COUNTER_0_BASE, ALT_CPU_FREQ, 2,
    "ANN Calcs","PC overhead");  


	Unnormalize(aOutput, DATA_LENGTH);

#if PRINT_RESULTS != 0
	// Print results
	printf("Results\n");
	for (nIndexCol = 0; nIndexCol < DATA_LENGTH; nIndexCol++)
	{
		// print only the first 3 columns of result matrix (as result is a Nx3 matrix)
        printf("%f %f %f\n", aOutput[nIndexCol][0], aOutput[nIndexCol][1], aOutput[nIndexCol][2] );
	}
#endif // PRINT_RESULTS != 0

	for (nIndexCol = 0; nIndexCol < DATA_LENGTH; nIndexCol++)
	{
		for (nIndexRow = 0; nIndexRow < (DATA_WIDTH - 1); nIndexRow++)
		{
			nCurrentError		= aOutput[nIndexCol][nIndexRow] - aExpectedResults[nIndexCol][nIndexRow];
			nMeanSquaredError	+= nCurrentError * nCurrentError;
		}
	}

	nMeanSquaredError = nMeanSquaredError / (DATA_LENGTH * (DATA_WIDTH - 1));

	printf("Mean Squared Error: %f", nMeanSquaredError);

	system("PAUSE");
}


void ArrayFill(float aInput[DATA_LENGTH][DATA_WIDTH], int nCountCol, float nValueToFill)
{
	int nIndexCol, nIndexRow;
    for (nIndexCol = 0; nIndexCol < nCountCol; nIndexCol++)
	{
		for (nIndexRow = 0; nIndexRow < DATA_WIDTH; nIndexRow++)
		{
			aInput[nIndexCol][nIndexRow] = nValueToFill;
		}
	}
}


void ArrayTanh(float aInput[DATA_WIDTH])
{
	int nIndexRow;
    for (nIndexRow = 0; nIndexRow < DATA_WIDTH; nIndexRow++)
	{
        // choose between accelerated and non-accelerated tangent sigmoid
#if ACCELERATED_TANH == 0
        // non-accelerated (calculate with math.h)
		aInput[nIndexRow] = tanhf(aInput[nIndexRow]);
#else
        // accelerated (estimate with dedicated look-up table)
        aInput[nIndexRow] = ALT_F_LOGSIG_APPROX_INST(aInput[nIndexRow]);
#endif
	}
}


// Multiplies a 4x4 matrix by a 4x1
void MatrixMultiplication(float aMatrix1[DATA_WIDTH][DATA_WIDTH], float aMatrix2[DATA_WIDTH], float aOutput[DATA_WIDTH], char bPrintResults)
{
	int nIndexRow, nIndexCol;
    if (bPrintResults == true) printf("beginning matrix multiplication\n");
	// Init Output to 0's
	for (nIndexRow = 0; nIndexRow < DATA_WIDTH; nIndexRow++)
	{
		aOutput[nIndexRow] = 0;
	}
	
	for (nIndexRow = 0; nIndexRow < DATA_WIDTH; nIndexRow++)
	{
		for (nIndexCol = 0; nIndexCol < DATA_WIDTH; nIndexCol++)
		{
			if (bPrintResults == true) printf("%f * %f\n",aMatrix1[nIndexRow][nIndexCol],aMatrix2[nIndexCol]);
			aOutput[nIndexRow] += aMatrix1[nIndexRow][nIndexCol] * aMatrix2[nIndexCol];
		}
	}
}

// Adds two 4x1 matrices
void MatrixAddition(float aMatrix1[DATA_WIDTH], float aMatrix2[DATA_WIDTH], float aOutput[DATA_WIDTH])
{
	int nIndexRow;
    for (nIndexRow = 0; nIndexRow < DATA_WIDTH; nIndexRow++)
	{
		aOutput[nIndexRow] = aMatrix1[nIndexRow] + aMatrix2[nIndexRow];
	}
}


// Normalizes matrix entries from -1 to 1
void Normalize(float aInput[DATA_LENGTH][DATA_WIDTH], int nCountCol)
{
	float aMin[DATA_WIDTH];
	float aMax[DATA_WIDTH];
	float nCurrentCell;
    int nIndexRow, nIndexCol;

	// First find min and max
	for ( nIndexRow = 0; nIndexRow < DATA_WIDTH; nIndexRow++ )
	{
		aMin[nIndexRow] = 9999999; // HACK!!
		aMax[nIndexRow] = 0;
		for ( nIndexCol = 0; nIndexCol < nCountCol; nIndexCol++ )
		{
			nCurrentCell = aInput[nIndexCol][nIndexRow];
			if (nCurrentCell < aMin[nIndexRow]) aMin[nIndexRow] = nCurrentCell;
			if (nCurrentCell > aMax[nIndexRow]) aMax[nIndexRow] = nCurrentCell;
		}
	}


	// Normalize
	for ( nIndexCol = 0; nIndexCol < nCountCol; nIndexCol++)
	{
		for ( nIndexRow = 0; nIndexRow < DATA_WIDTH; nIndexRow++)
		{
			nCurrentCell					= aInput[nIndexCol][nIndexRow];
			aInput[nIndexCol][nIndexRow]	= (((nCurrentCell - aMin[nIndexRow]) / (aMax[nIndexRow] - aMin[nIndexRow])) * 2) - 1;
		}
	}
}

// "Un-normalizes matrix"
void Unnormalize(float aInput[][DATA_WIDTH], int nCountCol)
{
	int nIndexCol, nIndexRow;
    for ( nIndexCol = 0; nIndexCol < nCountCol; nIndexCol++)
	{
		for ( nIndexRow = 0; nIndexRow < DATA_WIDTH; nIndexRow++)
		{
			aInput[nIndexCol][nIndexRow] = (aInput[nIndexCol][nIndexRow] + 1) / 2;
		}
	}
}

