package org.sfu.mm;

import java.io.*;
import java.awt.image.*;

public class YUVParser {

	private byte[] arrFrameData;
	private int intWidth = Program.FRAME_WIDTH;
	private int intHeight = Program.FRAME_HEIGHT;
	private int intArraySize = intHeight * intWidth;
	private int intFrameLength = 0;

	private int[][] arrY = null;
	private int[][] arrU = null;
	private int[][] arrV = null;

	private DataInputStream objDataInputStream = null;

	public int[][] getNextImageY() {
		return arrY;
	}

	public int[][] getNextImageU() {
		return arrU;
	}

	public int[][] getNextImageV() {
		return arrV;
	}

	public void startReading(InputStream inputStream) {
		try {
			objDataInputStream = new DataInputStream(new BufferedInputStream(
					inputStream));

			double dblPengali = 1.5;
			intFrameLength = (int) (intWidth * intHeight * (dblPengali));
			arrFrameData = new byte[intFrameLength];
		}

		catch (Exception objException) {
			objException.printStackTrace();
		}
	}

	public int getYFromStream(int intX, int intY) {
		return unsignedByteToInt(arrFrameData[intY * intWidth + intX]);
	}

	public int getUFromStream(int intX, int intY) {
		return unsignedByteToInt(arrFrameData[(intY / 2) * (intWidth / 2)
				+ intX / 2 + intArraySize]);
	}

	public int getVFromStream(int intX, int intY) {
		return unsignedByteToInt(arrFrameData[(intY / 2) * (intWidth / 2)
				+ intX / 2 + intArraySize + intArraySize / 4]);
	}

	public int getRGBFromStream(int intX, int intY) {
		int _intY = getYFromStream(intX, intY);
		int _intU = getUFromStream(intX, intY);
		int _intV = getVFromStream(intX, intY);

		int intR = Helper.YUVtoR(_intY, _intU, _intV);
		int intG = Helper.YUVtoG(_intY, _intU, _intV);
		int intB = Helper.YUVtoB(_intY, _intU, _intV);

		return Helper.createRGB(intR, intG, intB);
	}

	public Boolean processNextImage() {
		arrY = new int[intHeight][intWidth];
		arrU = new int[intHeight][intWidth];
		arrV = new int[intHeight][intWidth];

		try {
			int intFrameReadLength = objDataInputStream.read(arrFrameData);

			if (intFrameReadLength != intFrameLength) {
				return false;
			}

			for (int j = 0; j < intHeight; j++) {
				for (int i = 0; i < intWidth; i++) {
					arrY[j][i] = getYFromStream(i, j);
					arrU[j][i] = getUFromStream(i, j);
					arrV[j][i] = getVFromStream(i, j);
				}
			}

			return true;
		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	public BufferedImage nextImage() {
		try {
			int intFrameReadLength = objDataInputStream.read(arrFrameData);

			if (intFrameReadLength != intFrameLength) {
				return null;
			}

			BufferedImage objBufferedImage = new BufferedImage(intWidth,
					intHeight, BufferedImage.TYPE_INT_RGB);

			for (int j = 0; j < intHeight; j++) {
				for (int i = 0; i < intWidth; i++) {
					int intColor = getRGBFromStream(i, j);
					objBufferedImage.setRGB(i, j, intColor);
				}
			}

			return objBufferedImage;
		} catch (Exception e) {
			e.printStackTrace();
		}

		return null;
	}

	public void endReading() {
		try {
			objDataInputStream.close();
		} catch (IOException ex) {
			ex.printStackTrace();
		}
	}

	public static int unsignedByteToInt(byte b) {
		return (int) b & 0xFF;
	}
}
