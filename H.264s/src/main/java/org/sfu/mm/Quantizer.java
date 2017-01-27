package org.sfu.mm;

public class Quantizer {

	private int BLOCK_SIZE = Program.INTEGER_TRANSFORM_BLOCK_SIZE;

	private double[][] arrMf = new double[BLOCK_SIZE][BLOCK_SIZE];
	private double[][] arrVi = new double[BLOCK_SIZE][BLOCK_SIZE];

	public Quantizer(int intScaleFactor) {
		double[][] arrM = { { 13107, 5243, 8066 }, { 11916, 4660, 7490 },
				{ 10082, 4194, 6554 }, { 9362, 3647, 5825 },
				{ 8192, 3355, 5243 }, { 7282, 2893, 4559 } };

		double[][] arrV = { { 10, 16, 13 }, { 11, 18, 14 }, { 13, 20, 16 },
				{ 14, 23, 18 }, { 16, 25, 20 }, { 18, 29, 23 } };

		double dblScale = 1.0;
		if (intScaleFactor >= 6) {
			dblScale = Math.pow(2, Math.floor((double) (intScaleFactor) / 6.0));
		}

		intScaleFactor = intScaleFactor % 6;

		this.arrMf = createQMatrix(arrM, intScaleFactor, dblScale);
		this.arrVi = createQMatrix(arrV, intScaleFactor, 1.0 / dblScale);

	}

	private double[][] createQMatrix(double[][] arrConversionMatrix,
			int intScaleFactor, double dblScale) {
		double[][] arrReturn = {
				{ arrConversionMatrix[intScaleFactor][0] / dblScale,
						arrConversionMatrix[intScaleFactor][2] / dblScale,
						arrConversionMatrix[intScaleFactor][0] / dblScale,
						arrConversionMatrix[intScaleFactor][2] / dblScale },
				{ arrConversionMatrix[intScaleFactor][2] / dblScale,
						arrConversionMatrix[intScaleFactor][1] / dblScale,
						arrConversionMatrix[intScaleFactor][2] / dblScale,
						arrConversionMatrix[intScaleFactor][1] / dblScale },
				{ arrConversionMatrix[intScaleFactor][0] / dblScale,
						arrConversionMatrix[intScaleFactor][2] / dblScale,
						arrConversionMatrix[intScaleFactor][0] / dblScale,
						arrConversionMatrix[intScaleFactor][2] / dblScale },
				{ arrConversionMatrix[intScaleFactor][2] / dblScale,
						arrConversionMatrix[intScaleFactor][1] / dblScale,
						arrConversionMatrix[intScaleFactor][2] / dblScale,
						arrConversionMatrix[intScaleFactor][1] / dblScale } };
		return arrReturn;
	}

	public double[][] quantitize(double[][] arrOriginal) {
		double arrQuantized[][] = new double[BLOCK_SIZE][BLOCK_SIZE];

		// \\\\\\\\\\ FILL IN HERE //////////
		for (int i = 0; i < BLOCK_SIZE; i++) {
			for (int j = 0; j < BLOCK_SIZE; j++) {
				arrQuantized[i][j] =  (arrOriginal[i][j] * arrMf[i][j]);
			}
		}

		return arrQuantized;
	}

	public double[][] dequantitize(double[][] arrQuantized) {

		double arrOriginal[][] = new double[BLOCK_SIZE][BLOCK_SIZE];
		for (int i = 0; i < BLOCK_SIZE; i++) {
			for (int j = 0; j < BLOCK_SIZE; j++) {
				arrOriginal[i][j] = (int) (arrQuantized[i][j] * arrVi[i][j]);
			}
		}

		return arrOriginal;
	}
}
