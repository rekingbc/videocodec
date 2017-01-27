package org.sfu.mm;

import org.apache.commons.math3.linear.Array2DRowRealMatrix;
import org.apache.commons.math3.linear.RealMatrix;

public class IntegerTransform {

	private int BLOCK_SIZE = Program.INTEGER_TRANSFORM_BLOCK_SIZE;
	private int intScaleFactor;
	private Quantizer objQuantizer;

	private RealMatrix matH = null;
	private RealMatrix matH_T = null;
	private RealMatrix matH_INV = null;
	private RealMatrix matH_INV_T = null;

	public IntegerTransform(int intScaleFactor) {
		this.intScaleFactor = intScaleFactor;
		this.objQuantizer = new Quantizer(this.intScaleFactor);

		double[][] arrH = new double[][] { { 1, 1, 1, 1 }, { 2, 1, -1, -2 },
				{ 1, -1, -1, 1 }, { 1, -2, 2, -1 } };
		double[][] arrH_INV = new double[][] { { 1, 1, 1, 0.5 },
				{ 1, 0.5, -1, -1 }, { 1, -0.5, -1, 1 }, { 1, -1, 1, -0.5 } };

		double[][] arrH_T = new double[BLOCK_SIZE][BLOCK_SIZE];
		double[][] arrH_INV_T = new double[BLOCK_SIZE][BLOCK_SIZE];

		for (int i = 0; i < BLOCK_SIZE; i++) {
			for (int j = 0; j < BLOCK_SIZE; j++) {
				arrH_T[j][i] = arrH[i][j];
				arrH_INV_T[j][i] = arrH_INV[i][j];
			}
		}

		matH = new Array2DRowRealMatrix(arrH);
		matH_T = new Array2DRowRealMatrix(arrH_T);

		matH_INV = new Array2DRowRealMatrix(arrH_INV);
		matH_INV_T = new Array2DRowRealMatrix(arrH_INV_T);
	}

	/*******************************************************************
	 * Forward Transform
	 */
	public int[][] forwardT(int[][] arrOriginal) {
		int intDim = arrOriginal.length;
		int[][] arrResult = new int[intDim][intDim];

		for (int h = 0; h < intDim; h += BLOCK_SIZE) {
			for (int w = 0; w < intDim; w += BLOCK_SIZE) {
				int[][] arrResultSlice = _forwardT(Helper.getSlice(arrOriginal,
						h, w, BLOCK_SIZE));
				Helper.copySlice(arrResult, arrResultSlice, h, w, BLOCK_SIZE);
			}
		}

		return arrResult;
	}

	private int[][] _forwardT(int[][] arrOriginal) {
		int[][] arrResult = null;

		// \\\\\\\\\\ FILL IN HERE //////////
		double[][] arrTransformedDbl = Helper.convertToDbl(arrOriginal,
				BLOCK_SIZE);

		
		RealMatrix matTransformed = new Array2DRowRealMatrix(arrTransformedDbl);
		
		double[][] arrResultDbl = matH.multiply(matTransformed)
				.multiply(matH_T).getData();
		
		arrResultDbl = objQuantizer.quantitize(arrResultDbl);

	   // arrResult = Helper.convertToInt(arrResultDbl, BLOCK_SIZE,(int) Math.pow(2, 15));
	    arrResult = Helper.convertToInt(arrResultDbl, BLOCK_SIZE,
				(int) Math.pow(2, 15));
		
		return arrResult;
	}

	/**
	 ******************************************************************
	 */

	/*******************************************************************
	 * Inverse Transform
	 */
	public int[][] inverseT(int[][] arrTransformed) {
		int intDim = arrTransformed.length;
		int[][] arrResult = new int[intDim][intDim];

		for (int h = 0; h < intDim; h += BLOCK_SIZE) {
			for (int w = 0; w < intDim; w += BLOCK_SIZE) {
				int[][] arrResultSlice = _inverseT(Helper.getSlice(
						arrTransformed, h, w, BLOCK_SIZE));
				Helper.copySlice(arrResult, arrResultSlice, h, w, BLOCK_SIZE);
			}
		}

		return arrResult;
	}

	private int[][] _inverseT(int[][] arrTransformed) {
		double[][] arrTransformedDbl = Helper.convertToDbl(arrTransformed,
				BLOCK_SIZE);

		arrTransformedDbl = objQuantizer.dequantitize(arrTransformedDbl);
		RealMatrix matTransformed = new Array2DRowRealMatrix(arrTransformedDbl);
		double[][] arrResultDbl = matH_INV.multiply(matTransformed)
				.multiply(matH_INV_T).getData();

		int[][] arrResult = Helper.convertToInt(arrResultDbl, BLOCK_SIZE,
				(int) Math.pow(2, 6));
		return arrResult;
	}
	/**
	 ******************************************************************
	 */
}
