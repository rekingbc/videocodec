package org.sfu.mm;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import javax.imageio.ImageIO;
import javax.swing.JFrame;

public class Helper {

	/**
	 * Class loader instance
	 */
	public static final ClassLoader CONTEXT_CLASS_LOADER = Thread
			.currentThread().getContextClassLoader();

	/**
	 * Render JFrame to user
	 * 
	 * @param objJFrame
	 *            JFrame instance to render
	 */
	public static void renderFrame(JFrame objJFrame) {
		objJFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		objJFrame.setResizable(false);
		objJFrame.pack();
	}

	public static double RGBtoY(double dblRed, double dblGreen, double dblBlue) {
		double dblY = RGBtoYUV(dblRed, dblGreen, dblBlue, 0.299, 0.587, 0.114);
		dblY = normalizeRGB((int) dblY);
		return dblY;
	}

	public static double RGBtoU(double dblRed, double dblGreen, double dblBlue) {
		double dblU = RGBtoYUV(dblRed, dblGreen, dblBlue, -0.14317, -0.28886,
				0.436);
		dblU = normalizeUV(dblU);
		return dblU;
	}

	public static double RGBtoV(double dblRed, double dblGreen, double dblBlue) {
		double dblV = RGBtoYUV(dblRed, dblGreen, dblBlue, 0.615, -0.51499,
				-0.10001);
		dblV = normalizeUV(dblV);
		return dblV;
	}

	public static int YUVtoR(int intY, int intU, int intV) {
		int intR = (int) (intY + 1.4075 * (intV - 128));
		intR = normalizeRGB(intR);
		return intR;
	}

	public static int YUVtoG(int intY, int intU, int intV) {
		int intG = (int) (intY - 0.3455 * (intU - 128) - (0.7169 * (intV - 128)));
		intG = normalizeRGB(intG);
		return intG;
	}

	public static int YUVtoB(int intY, int intU, int intV) {
		int intB = (int) (intY + 1.7790 * (intU - 128));
		intB = normalizeRGB(intB);
		return intB;
	}

	private static double RGBtoYUV(double dblRed, double dblGreen,
			double dblBlue, double dblRedCoeff, double dblGreenCoeff,
			double dblBlueCoeff) {
		double intReturnValue = (dblRedCoeff * dblRed)
				+ (dblGreenCoeff * dblGreen) + (dblBlueCoeff * dblBlue);
		return intReturnValue;
	}

	public static int normalizeRGB(int intRGB) {
		intRGB = (intRGB > 255) ? 255 : intRGB;
		intRGB = (intRGB < 0) ? 0 : intRGB;
		return intRGB;
	}

	private static double normalizeUV(double dblUV) {
		dblUV = (dblUV > 127.0) ? 127.0 : dblUV;
		dblUV = (dblUV < -128.0) ? -128.0 : dblUV;
		return dblUV;
	}

	public static int createRGB(int intRed, int intGreen, int intBlue) {
		int intRGB = intRed;
		intRGB = (intRGB << 8) + intGreen;
		intRGB = (intRGB << 8) + intBlue;
		return intRGB;
	}

	public static BufferedImage createImageFromRGB(int intWidth, int intHeight,
			int[][] arrR, int[][] arrG, int[][] arrB, String strOutputFilePath) {
		BufferedImage objBufferedImage = createImageFromRGB(intWidth,
				intHeight, arrR, arrG, arrB);

		File outputFile = new File(strOutputFilePath);
		try {
			ImageIO.write(objBufferedImage, "bmp", outputFile);
		} catch (IOException objIOException) {
			objIOException.printStackTrace();
		}

		return objBufferedImage;
	}

	public static BufferedImage createImageFromRGB(int intWidth, int intHeight,
			int[][] arrR, int[][] arrG, int[][] arrB) {
		BufferedImage objBufferedImage = new BufferedImage(intWidth, intHeight,
				BufferedImage.TYPE_INT_RGB);

		for (int h = 0; h < intHeight; h++) {
			for (int w = 0; w < intWidth; w++) {
				int intRGB = Helper.createRGB(arrR[h][w], arrG[h][w],
						arrB[h][w]);
				objBufferedImage.setRGB(w, h, intRGB);
			}
		}
		return objBufferedImage;
	}

	public static int downSampleBy2(int intOriginal) {
		int intDownSampled = (intOriginal + 2 - 1) / 2;
		return intDownSampled;
	}

	public static int[][] downSampleBy2(int[][] arrOriginal) {
		int intHeight = arrOriginal.length;
		int intWidth = arrOriginal[0].length;

		int intDownSampledHeight = Helper.downSampleBy2(intHeight);
		int intDownSampledWidth = Helper.downSampleBy2(intWidth);

		int[][] arrDownSampled = new int[intDownSampledHeight][intDownSampledWidth];

		int intDownSampledH = 0;
		Boolean blnSkipRow = false;
		for (int h = 0; h < intHeight; h++) {
			if (!blnSkipRow) {
				int intDownSampledW = 0;
				Boolean blnSkipColumn = false;
				for (int w = 0; w < intWidth; w++) {
					if (!blnSkipColumn) {
						Boolean blnLastRow = (h == intHeight - 1);
						Boolean blnLastColumn = (w == intWidth - 1);

						double dbleNewPixelValue = arrOriginal[h][w];
						double dblPixelsCount = 1.0;
						if (!blnLastRow) {

							dbleNewPixelValue += arrOriginal[h + 1][w];
							dblPixelsCount++;

							if (!blnLastColumn) {
								dbleNewPixelValue += arrOriginal[h + 1][w + 1];
								dblPixelsCount++;
							}
						}

						if (!blnLastColumn) {
							dbleNewPixelValue += arrOriginal[h][w + 1];
							dblPixelsCount++;
						}

						dbleNewPixelValue = Math.round(dbleNewPixelValue
								/ dblPixelsCount);
						arrDownSampled[intDownSampledH][intDownSampledW] = (int) dbleNewPixelValue;

						blnSkipColumn = true;
						intDownSampledW++;
					} else {
						blnSkipColumn = false;
					}
				}
				blnSkipRow = true;
				intDownSampledH++;
			} else {
				blnSkipRow = false;
			}
		}

		return arrDownSampled;
	}

	public static int[][] upSampleBy2(int[][] arrOriginal) {

		int intHeight = arrOriginal.length;
		int intWidth = arrOriginal[0].length;

		int intUpSampledHeight = Helper.upSampleBy2(intHeight);
		int intUpSampledWidth = Helper.upSampleBy2(intWidth);

		int[][] arrUpSampled = new int[intUpSampledHeight][intUpSampledWidth];

		int intUpSampledH = 0;
		for (int h = 0; h < intHeight; h++) {
			int intUpSampledW = 0;
			for (int w = 0; w < intWidth; w++) {

				Boolean blnLastRow = (h == intHeight - 1);
				Boolean blnLastColumn = (w == intWidth - 1);

				arrUpSampled[intUpSampledH][intUpSampledW] = arrOriginal[h][w];

				arrUpSampled[intUpSampledH][intUpSampledW + 1] = arrOriginal[h][w];

				if (!blnLastColumn) {
					arrUpSampled[intUpSampledH][intUpSampledW + 1] += arrOriginal[h][w + 1];
					arrUpSampled[intUpSampledH][intUpSampledW + 1] /= 2;
				}

				arrUpSampled[intUpSampledH + 1][intUpSampledW] = arrUpSampled[intUpSampledH][intUpSampledW];
				arrUpSampled[intUpSampledH + 1][intUpSampledW + 1] = arrUpSampled[intUpSampledH][intUpSampledW + 1];

				if (!blnLastRow) {

					arrUpSampled[intUpSampledH + 1][intUpSampledW] += arrOriginal[h + 1][w];
					arrUpSampled[intUpSampledH + 1][intUpSampledW] /= 2;

					arrUpSampled[intUpSampledH + 1][intUpSampledW + 1] += arrOriginal[h + 1][w];
					arrUpSampled[intUpSampledH + 1][intUpSampledW + 1] /= 2;

				}

				intUpSampledW += 2;
			}
			intUpSampledH += 2;
		}

		return arrUpSampled;
	}

	public static int upSampleBy2(int intOriginal) {
		int intUpSampled = intOriginal * 2;
		return intUpSampled;
	}

	public static int[][] sliceArray(int[][] arrOriginal, int h, int w,
			int BLOCK_SIZE) {
		int intHeight = arrOriginal.length;
		int intWidth = arrOriginal[0].length;
		int[][] arrSlice = new int[BLOCK_SIZE][BLOCK_SIZE];

		int intSlice_h = 0;
		for (int h_local = h; h_local < Math.min(intHeight, h + BLOCK_SIZE); h_local++) {
			int intSlice_w = 0;
			for (int w_local = w; w_local < Math.min(intWidth, w + BLOCK_SIZE); w_local++) {
				arrSlice[intSlice_h][intSlice_w] = arrOriginal[h_local][w_local];
				intSlice_w++;
			}
			intSlice_h++;
		}

		return arrSlice;
	}

	public static void copySlice(int[][] arrTransformed, int[][] arrSlice,
			int h, int w, int BLOCK_SIZE) {
		int intHeight = arrTransformed.length;
		int intWidth = arrTransformed[0].length;

		int intSlice_h = 0;
		for (int h_local = h; h_local < Math.min(intHeight, h + BLOCK_SIZE); h_local++) {
			int intSlice_w = 0;
			for (int w_local = w; w_local < Math.min(intWidth, w + BLOCK_SIZE); w_local++) {
				arrTransformed[h_local][w_local] = arrSlice[intSlice_h][intSlice_w];
				intSlice_w++;
			}
			intSlice_h++;
		}
	}

	public static int[][] convertToInt(double[][] arrDbl, int intDim) {
		return convertToInt(arrDbl, intDim, 1);
	}

	public static int[][] convertToInt(double[][] arrDbl, int intDim,
			int intScaleFactor) {
		int[][] arrResult = new int[intDim][intDim];
		for (int i = 0; i < intDim; i++) {
			for (int j = 0; j < intDim; j++) {
				arrResult[i][j] = (int) Math.round(arrDbl[i][j]
						/ intScaleFactor);
			}
		}
		return arrResult;
	}

	public static double[][] convertToDbl(int[][] arrInt, int intDim) {
		double[][] arrResult = new double[intDim][intDim];
		for (int i = 0; i < intDim; i++) {
			for (int j = 0; j < intDim; j++) {
				arrResult[i][j] = arrInt[i][j];
			}
		}
		return arrResult;
	}

	public static int[][] minus2Darray(int[][] arrOriginal, int[][] arrPredicted) {
		int intHeight = arrOriginal.length;
		int intWidth = arrOriginal[0].length;
		int[][] arrResult = new int[intHeight][intWidth];

		for (int i = 0; i < intHeight; i++) {
			for (int j = 0; j < intWidth; j++) {
				arrResult[i][j] = arrOriginal[i][j] - arrPredicted[i][j];
			}
		}

		return arrResult;
	}

	public static int[][] plus2Darray(int[][] arrResidual, int[][] arrPredicted) {
		int intHeight = arrResidual.length;
		int intWidth = arrResidual[0].length;
		int[][] arrResult = new int[intHeight][intWidth];

		for (int i = 0; i < intHeight; i++) {
			for (int j = 0; j < intWidth; j++) {
				arrResult[i][j] = arrResidual[i][j] + arrPredicted[i][j];
			}
		}

		return arrResult;
	}

	public static int[][] getSlice(int[][] arrOriginal, int h, int w, int intDim) {
		int[][] arrSlice = new int[intDim][intDim];
		for (int i = 0; i < intDim; i++) {
			for (int j = 0; j < intDim; j++) {
				arrSlice[i][j] = arrOriginal[h + i][w + j];
			}
		}
		return arrSlice;
	}

	public static double meanAbsoluteError(int[][] arrOriginal,
			int[][] arrPredicted) {
		int intHeight = arrOriginal.length;
		int intWidth = arrOriginal[0].length;
		double dblMAE = 0;

		for (int i = 0; i < intHeight; i++) {
			for (int j = 0; j < intWidth; j++) {
				dblMAE += Math.abs(arrOriginal[i][j] - arrPredicted[i][j]);
			}
		}

		dblMAE = dblMAE / (double) (intHeight * intWidth);

		return dblMAE;
	}

	public static int[][] average(int[][] arrSlice1, int[][] arrSlice2) {
		int intHeight = arrSlice1.length;
		int intWidth = arrSlice1[0].length;

		int[][] arrResult = new int[intHeight][intWidth];

		for (int i = 0; i < intHeight; i++) {
			for (int j = 0; j < intWidth; j++) {
				arrResult[i][j] = (int) Math
						.round((double) (arrSlice1[i][j] + arrSlice2[i][j]) / 2.0);
			}
		}

		return arrResult;
	}

	public static int average(ArrayList<Integer> lstNumbers) {
		Integer intSum = 0;
		if (!lstNumbers.isEmpty()) {
			for (int intNumber : lstNumbers) {
				intSum += intNumber;
			}
			intSum = (int) (intSum.doubleValue() / (double) lstNumbers.size());
		}
		return intSum;
	}

	public static BufferedImage createImageFromYUV(int[][] arrY, int[][] arrU,
			int[][] arrV) {
		int[][] arrR = new int[Program.FRAME_HEIGHT][Program.FRAME_WIDTH];
		int[][] arrG = new int[Program.FRAME_HEIGHT][Program.FRAME_WIDTH];
		int[][] arrB = new int[Program.FRAME_HEIGHT][Program.FRAME_WIDTH];

		for (int h = 0; h < Program.FRAME_HEIGHT; h++) {
			for (int w = 0; w < Program.FRAME_WIDTH; w++) {
				int intY = arrY[h][w];
				int intU = arrU[h][w];
				int intV = arrV[h][w];

				arrR[h][w] = Helper.YUVtoR(intY, intU, intV);
				arrG[h][w] = Helper.YUVtoG(intY, intU, intV);
				arrB[h][w] = Helper.YUVtoB(intY, intU, intV);
			}
		}

		return Helper.createImageFromRGB(Program.FRAME_WIDTH,
				Program.FRAME_HEIGHT, arrR, arrG, arrB);
	}
}
