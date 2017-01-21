package org.sfu.mm;

import java.io.InputStream;
import java.util.ArrayList;
import java.awt.image.BufferedImage;
import java.util.AbstractMap.SimpleEntry;

public class H264s {

	/*******************************************************************
	 * Helper enums
	 *
	 */
	public enum FrameType {
		I, B, P
	}

	public enum ColorChannel {
		Y, U, V
	}

	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Constants
	 */
	private int LOG_SEARCH_STEP_SIZE = Program.LOG_SEARCH_STEP_SIZE;
	private int MACRO_BLOCK_SIZE = Program.MACRO_BLOCK_SIZE;
	private int INTEGER_TRANSFORM_BLOCK_SIZE = Program.INTEGER_TRANSFORM_BLOCK_SIZE;
	/**
	 * *****************************************************************
	 */

	/**
	 * Number of frames in the video sequence
	 */
	private int intFrameCount = 0;

	/**
	 * Instance of the integer transform (apply quantization internally)
	 */
	private IntegerTransform objIntegerTransform = null;

	/**
	 * The type of each frame in the sequence
	 */
	private ArrayList<FrameType> lstFrameTypes = new ArrayList<FrameType>();

	/*******************************************************************
	 * Original frames in YUV format
	 */
	private ArrayList<int[][]> lstOriginalY = new ArrayList<int[][]>();
	private ArrayList<int[][]> lstOriginalU = new ArrayList<int[][]>();
	private ArrayList<int[][]> lstOriginalV = new ArrayList<int[][]>();
	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Predicted frames in YUV format
	 */
	private ArrayList<int[][]> lstPredictedY = new ArrayList<int[][]>();
	private ArrayList<int[][]> lstPredictedU = new ArrayList<int[][]>();
	private ArrayList<int[][]> lstPredictedV = new ArrayList<int[][]>();
	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Residual frames in YUV format
	 */
	private ArrayList<int[][]> lstResidualY = new ArrayList<int[][]>();
	private ArrayList<int[][]> lstResidualU = new ArrayList<int[][]>();
	private ArrayList<int[][]> lstResidualV = new ArrayList<int[][]>();
	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Decoded frames in YUV format
	 */
	private ArrayList<int[][]> lstDecodedY = new ArrayList<int[][]>();
	private ArrayList<int[][]> lstDecodedU = new ArrayList<int[][]>();
	private ArrayList<int[][]> lstDecodedV = new ArrayList<int[][]>();
	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * All video frames (Original, Predicted, Residual, Decoded) as buffered
	 * images for display
	 */
	private ArrayList<BufferedImage> lstRGBImagesOriginal = new ArrayList<BufferedImage>();
	private ArrayList<BufferedImage> lstRGBImagesPredicted = new ArrayList<BufferedImage>();
	private ArrayList<BufferedImage> lstRGBImagesResidual = new ArrayList<BufferedImage>();
	private ArrayList<BufferedImage> lstRGBImagesDecoded = new ArrayList<BufferedImage>();

	/**
	 * *****************************************************************
	 */

	/**
	 * List of motion vectors for each frame, for each macroblock in raster
	 * format
	 */
	/**
	 * The first ArrayList has an entry
	 * (ArrayList<ArrayList<SimpleEntry<Integer, Integer>>>) for each frame.
	 */
	/**
	 * The seconds ArrayList has an entry (ArrayList<SimpleEntry<Integer,
	 * Integer>>) for each macroblock, saved in raster format
	 */
	/**
	 * The third ArrayList has an entry (SimpleEntry<Integer, Integer>) for each
	 * motion vector. * For I frames, only one entry is saved
	 * SimpleEntry<>(Prediction Mode, 0) * For P frames, only one entry is saved
	 * SimpleEntry<>(MotionVectorX, MotionVectorY) * For B frames, one or more
	 * entries are saved [not implemented]
	 */
	private ArrayList<ArrayList<ArrayList<SimpleEntry<Integer, Integer>>>> lstMotionVectors = new ArrayList<ArrayList<ArrayList<SimpleEntry<Integer, Integer>>>>();

	/**
	 * Constructor: Load YUV sequence
	 * 
	 * @param objInputStream
	 *            YUV sequence file path
	 * @param intQScaleFactor
	 *            Quantization Parameter
	 */
	public H264s(InputStream objInputStream, int intQScaleFactor) {

		objIntegerTransform = new IntegerTransform(intQScaleFactor);

		try {
			YUVParser objYUVParser = new YUVParser();
			objYUVParser.startReading(objInputStream);

			while (objYUVParser.processNextImage()) {
				int[][] arrY = objYUVParser.getNextImageY();
				lstOriginalY.add(arrY);

				int[][] arrU = Helper.downSampleBy2(objYUVParser
						.getNextImageU());
				lstOriginalU.add(arrU);

				int[][] arrV = Helper.downSampleBy2(objYUVParser
						.getNextImageV());
				lstOriginalV.add(arrV);

				intFrameCount++;

				ArrayList<ArrayList<SimpleEntry<Integer, Integer>>> lstMoitionVectors_macroBlocks = new ArrayList<ArrayList<SimpleEntry<Integer, Integer>>>();
				lstMotionVectors.add(lstMoitionVectors_macroBlocks);
			}

			objYUVParser.endReading();

		} catch (Exception objException) {
			objException.printStackTrace();
		}

		orderFrames();
		codec();
		orderFrames(true);
		generateRGBImages();
	}

	/*******************************************************************
	 * Codec
	 */

	/**
	 * Encode the sequence, then decode it
	 */
	private void codec() {
		for (int i = 0; i < intFrameCount; i++) {
			switch (lstFrameTypes.get(i)) {
			case I:
				codec(ColorChannel.Y, i, FrameType.I);
				codec(ColorChannel.U, i, FrameType.I);
				codec(ColorChannel.V, i, FrameType.I);
				break;
			case P:
				codec(ColorChannel.Y, i, FrameType.P);
				codec(ColorChannel.U, i, FrameType.P);
				codec(ColorChannel.V, i, FrameType.P);
				break;
			case B:
				codec(ColorChannel.Y, i, FrameType.B);
				codec(ColorChannel.U, i, FrameType.B);
				codec(ColorChannel.V, i, FrameType.B);
				break;
			}
		}
	}

	/**
	 * Apply prediction, transform, quantization, and then reverse operation
	 * 
	 * @param enmColorChannel
	 *            Y, U, V
	 * @param intFrameIndex
	 *            Index of the frame
	 * @param enmFrameType
	 *            I, P, B
	 */
	private void codec(ColorChannel enmColorChannel, int intFrameIndex,
			FrameType enmFrameType) {
		encode(enmColorChannel, intFrameIndex, enmFrameType);
		decode(enmColorChannel, intFrameIndex, enmFrameType);
	}

	/**
	 * Encode Frame: Apply prediction, transform, quantization
	 * 
	 * @param enmColorChannel
	 *            Y, U, V
	 * @param intFrameIndex
	 *            Index of the frame
	 * @param enmFrameType
	 *            I, P, B
	 */
	private void encode(ColorChannel enmColorChannel, int intFrameIndex,
			FrameType enmFrameType) {
		predictFrame(enmColorChannel, intFrameIndex, enmFrameType);
		applyIntegerTransform(enmColorChannel, intFrameIndex);
	}

	/**
	 * Decode Frame Apply reverse (quantization, transform, prediction)
	 * 
	 * @param enmColorChannel
	 *            Y, U, V
	 * @param intFrameIndex
	 *            Index of the frame
	 * @param enmFrameType
	 *            I, P, B
	 */
	private void decode(ColorChannel enmColorChannel, int intFrameIndex,
			FrameType enmFrameType) {
		applyIntegerTransform(enmColorChannel, intFrameIndex, true);
		predictFrame(enmColorChannel, intFrameIndex, enmFrameType, true);
	}

	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Order Frames
	 */
	private void orderFrames() {
		orderFrames(false);
	}

	private void orderFrames(Boolean blnInverse) {
		if (!blnInverse) {
			orderFrames(this.lstOriginalY, this.lstOriginalU,
					this.lstOriginalV, blnInverse);
		} else {
			orderFrames(this.lstOriginalY, this.lstOriginalU,
					this.lstOriginalV, blnInverse);
			orderFrames(this.lstDecodedY, this.lstDecodedU, this.lstDecodedV,
					blnInverse);
			orderFrames(this.lstPredictedY, this.lstPredictedU,
					this.lstPredictedV, blnInverse);
			orderFrames(this.lstResidualY, this.lstResidualU,
					this.lstResidualV, blnInverse);
		}
	}

	private void orderFrames(ArrayList<int[][]> lstUnOrderedY,
			ArrayList<int[][]> lstUnOrderedU, ArrayList<int[][]> lstUnOrderedV,
			Boolean blnInverse) {
		ArrayList<int[][]> lstOrderedY = new ArrayList<int[][]>();
		ArrayList<int[][]> lstOrderedU = new ArrayList<int[][]>();
		ArrayList<int[][]> lstOrderedV = new ArrayList<int[][]>();

		lstOrderedY.add(lstUnOrderedY.get(0));
		lstOrderedU.add(lstUnOrderedU.get(0));
		lstOrderedV.add(lstUnOrderedV.get(0));
		lstFrameTypes.add(FrameType.I);

		for (int i = 1; i < intFrameCount; i++) {
			lstFrameTypes.add(FrameType.P);
			lstOrderedY.add(lstUnOrderedY.get(i));
			lstOrderedU.add(lstUnOrderedU.get(i));
			lstOrderedV.add(lstUnOrderedV.get(i));
		}

		lstUnOrderedY.clear();
		lstUnOrderedU.clear();
		lstUnOrderedV.clear();

		for (int i = 0; i < intFrameCount; i++) {

			lstUnOrderedY.add(lstOrderedY.get(i));
			lstUnOrderedU.add(lstOrderedU.get(i));
			lstUnOrderedV.add(lstOrderedV.get(i));
		}

		System.gc();
	}

	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Generate RGB images for display
	 */
	private void generateRGBImages() {
		for (int i = 0; i < intFrameCount; i++) {
			int[][] arrY = null;
			int[][] arrU = null;
			int[][] arrV = null;

			arrY = lstPredictedY.get(i);
			arrU = Helper.upSampleBy2(lstPredictedU.get(i));
			arrV = Helper.upSampleBy2(lstPredictedV.get(i));
			lstRGBImagesPredicted.add(Helper.createImageFromYUV(arrY, arrU,
					arrV));

			arrY = lstResidualY.get(i);
			arrU = Helper.upSampleBy2(lstResidualU.get(i));
			arrV = Helper.upSampleBy2(lstResidualV.get(i));
			lstRGBImagesResidual.add(Helper
					.createImageFromYUV(arrY, arrU, arrV));

			arrY = lstOriginalY.get(i);
			arrU = Helper.upSampleBy2(lstOriginalU.get(i));
			arrV = Helper.upSampleBy2(lstOriginalV.get(i));
			lstRGBImagesOriginal.add(Helper
					.createImageFromYUV(arrY, arrU, arrV));

			arrY = lstDecodedY.get(i);
			arrU = Helper.upSampleBy2(lstDecodedU.get(i));
			arrV = Helper.upSampleBy2(lstDecodedV.get(i));
			lstRGBImagesDecoded
					.add(Helper.createImageFromYUV(arrY, arrU, arrV));
		}
	}

	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Prediction
	 */

	private void predictFrame(ColorChannel enmColorChannel, int intFrameIndex,
			FrameType enmFrameType) {
		predictFrame(enmColorChannel, intFrameIndex, enmFrameType, false);
	}

	private void predictFrame(ColorChannel enmColorChannel, int intFrameIndex,
			FrameType enmFrameType, Boolean blnInverse) {

		int[][] arrOriginal = null;
		if (!blnInverse) {
			switch (enmColorChannel) {
			case Y:
				arrOriginal = lstOriginalY.get(intFrameIndex);
				break;
			case U:
				arrOriginal = lstOriginalU.get(intFrameIndex);
				break;
			case V:
				arrOriginal = lstOriginalV.get(intFrameIndex);
				break;
			}
		} else {
			switch (enmColorChannel) {
			case Y:
				arrOriginal = lstResidualY.get(intFrameIndex).clone();
				break;
			case U:
				arrOriginal = lstResidualU.get(intFrameIndex).clone();
				break;
			case V:
				arrOriginal = lstResidualV.get(intFrameIndex).clone();
				break;
			}

		}

		switch (enmFrameType) {
		case I:
			predictIFrame(enmColorChannel, intFrameIndex, blnInverse,
					arrOriginal);
			break;
		case P:
			predictPFrame(enmColorChannel, intFrameIndex, blnInverse,
					arrOriginal);
			break;
		case B:
			// Not Implemented
			break;
		}
	}

	/*******************************************************************
	 * I Frame
	 */
	private void predictIFrame(ColorChannel enmColorChannel, int intFrameIndex,
			Boolean blnInverse, int[][] arrOriginal) {

		int intHeight = arrOriginal.length;
		int intWidth = arrOriginal[0].length;

		int intMode = 0;
		int intMacroBlockIndex = 0;
		int intMacroBlockSize = MACRO_BLOCK_SIZE;
		if (enmColorChannel != ColorChannel.Y) {
			intMacroBlockSize /= 2;
		}

		int[][] arrResidual = new int[intHeight][intWidth];
		int[][] arrPredicted = new int[intHeight][intWidth];
		int[][] arrDecoded = new int[intHeight][intWidth];

		for (int h = 0; h < intHeight; h += intMacroBlockSize) {
			for (int w = 0; w < intWidth; w += intMacroBlockSize) {

				int[][] arrPredictedSlice = new int[intMacroBlockSize][intMacroBlockSize];

				/*******************************************************************
				 * Encode
				 */
				if (!blnInverse) {
					// \\\\\\\\\\ FILL IN HERE //////////
				}
				/**
				 * *************************************************************
				 */

				/*******************************************************************
				 * Decode
				 */
				else {
					intMode = getIFrameMoitionVector(intFrameIndex,
							intMacroBlockIndex);
					switch (intMode) {
					case -1: // Copy residual, no prediction
						break;
					case 0: // Horizontal Prediction
						arrPredictedSlice = modePredHOR(arrDecoded, h, w,
								intMacroBlockSize);
						break;
					case 1: // Vertical Prediction
						arrPredictedSlice = modePredVER(arrDecoded, h, w,
								intMacroBlockSize);
						break;
					case 2: // DC prediction
						arrPredictedSlice = modePredDC(arrDecoded, h, w,
								intMacroBlockSize);
						break;
					}

					/**
					 * Calculate Decoded Slice
					 */
					int[][] arrResidualSlice = Helper.getSlice(arrOriginal, h,
							w, intMacroBlockSize);
					int[][] arrDecodedSlice = Helper.plus2Darray(
							arrPredictedSlice, arrResidualSlice);
					Helper.copySlice(arrDecoded, arrDecodedSlice, h, w,
							intMacroBlockSize);
				}
				/**
				 * *************************************************************
				 */
				intMacroBlockIndex++;
			}
		}

		/*******************************************************************
		 * Update frame lists
		 */
		if (!blnInverse) {
			switch (enmColorChannel) {
			case Y:
				lstPredictedY.add(arrPredicted);
				lstResidualY.add(arrResidual);
				break;
			case U:
				lstPredictedU.add(arrPredicted);
				lstResidualU.add(arrResidual);
				break;
			case V:
				lstPredictedV.add(arrPredicted);
				lstResidualV.add(arrResidual);
				break;
			}
		} else {
			switch (enmColorChannel) {
			case Y:
				lstDecodedY.add(arrDecoded);
				break;
			case U:
				lstDecodedU.add(arrDecoded);
				break;
			case V:
				lstDecodedV.add(arrDecoded);
				break;
			}

		}
		/**
		 * *****************************************************************
		 */
	}

	private int getIFrameMoitionVector(int intFrameIndex, int intMacroBlockIndex) {
		SimpleEntry<Integer, Integer> objMotionVector = lstMotionVectors
				.get(intFrameIndex).get(intMacroBlockIndex).get(0);
		int intMode = objMotionVector.getKey();
		return intMode;
	}

	private void addIFrameMoitionVector(int intFrameIndex, int intMode) {
		ArrayList<SimpleEntry<Integer, Integer>> lstMoitionVectors_macroBlock = new ArrayList<SimpleEntry<Integer, Integer>>();
		lstMoitionVectors_macroBlock.add(new SimpleEntry<Integer, Integer>(
				intMode, 0));
		lstMotionVectors.get(intFrameIndex).add(lstMoitionVectors_macroBlock);
	}

	private int calculateIFrameBlockMode(int[][] arrOriginal,
			int[][] arrDecoded, int h, int w, int intMacroBlockSize) {
		int intMode = 0;

		// \\\\\\\\\\ FILL IN HERE //////////

		return intMode;
	}

	private int[][] modePredHOR(int[][] arrOriginal, int h, int w, int intDim) {
		int[][] arrSlice = new int[intDim][intDim];

		// \\\\\\\\\\ FILL IN HERE //////////

		return arrSlice;
	}

	private int[][] modePredVER(int[][] arrOriginal, int h, int w, int intDim) {
		int[][] arrSlice = new int[intDim][intDim];

		// \\\\\\\\\\ FILL IN HERE //////////

		return arrSlice;
	}

	private int[][] modePredDC(int[][] arrOriginal, int h, int w, int intDim) {
		int[][] arrSlice = new int[intDim][intDim];

		// \\\\\\\\\\ FILL IN HERE //////////

		return arrSlice;
	}

	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * P Frame
	 */
	private void predictPFrame(ColorChannel enmColorChannel, int intFrameIndex,
			Boolean blnInverse, int[][] arrOriginal) {

		int intHeight = arrOriginal.length;
		int intWidth = arrOriginal[0].length;

		int intMacroBlockIndex = 0;
		int intMacroBlockSize = MACRO_BLOCK_SIZE;
		if (enmColorChannel != ColorChannel.Y) {
			intMacroBlockSize /= 2;
		}

		int[][] arrResidual = new int[intHeight][intWidth];
		int[][] arrPredicted = new int[intHeight][intWidth];
		int[][] arrDecoded = new int[intHeight][intWidth];

		int intReferenceFrameIndex = getPFrameReferenceIndex(intFrameIndex);
		int[][] arrReferenceFrame = getPFrameReference(enmColorChannel,
				intFrameIndex, intReferenceFrameIndex);

		for (int h = 0; h < intHeight; h += intMacroBlockSize) {
			for (int w = 0; w < intWidth; w += intMacroBlockSize) {

				/*******************************************************************
				 * Encode
				 */
				if (!blnInverse) {
					// \\\\\\\\\\ FILL IN HERE //////////
				}
				/**
				 * *************************************************************
				 */

				/*******************************************************************
				 * Decode
				 */
				else {
					SimpleEntry<Integer, Integer> objMotionVector = getPFrameMoitionVector(
							intFrameIndex, intMacroBlockIndex);
					int intXMoitionVector = objMotionVector.getKey();
					int intYMoitionVector = objMotionVector.getValue();

					if (enmColorChannel != ColorChannel.Y) {
						intXMoitionVector /= 2;
						intYMoitionVector /= 2;
					}

					intXMoitionVector = intXMoitionVector + w;
					intYMoitionVector = intYMoitionVector + h;

					int[][] arrPredictedSlice = Helper.getSlice(
							arrReferenceFrame, intYMoitionVector,
							intXMoitionVector, intMacroBlockSize);
					Helper.copySlice(arrPredicted, arrPredictedSlice, h, w,
							intMacroBlockSize);

					int[][] arrResidualSlice = Helper.getSlice(arrOriginal, h,
							w, intMacroBlockSize);
					int[][] arrDecodedSlice = Helper.plus2Darray(
							arrPredictedSlice, arrResidualSlice);
					Helper.copySlice(arrDecoded, arrDecodedSlice, h, w,
							intMacroBlockSize);
				}
				/**
				 * *************************************************************
				 */
				intMacroBlockIndex++;
			}
		}

		/*******************************************************************
		 * Update frame lists
		 */
		if (!blnInverse) {
			switch (enmColorChannel) {
			case Y:
				lstResidualY.add(arrResidual);
				break;
			case U:
				lstResidualU.add(arrResidual);
				break;
			case V:
				lstResidualV.add(arrResidual);
				break;
			}
		} else {
			switch (enmColorChannel) {
			case Y:
				lstPredictedY.add(arrPredicted);
				lstDecodedY.add(arrDecoded);
				break;
			case U:
				lstPredictedU.add(arrPredicted);
				lstDecodedU.add(arrDecoded);
				break;
			case V:
				lstPredictedV.add(arrPredicted);
				lstDecodedV.add(arrDecoded);
				break;
			}
		}
		/**
		 * *****************************************************************
		 */
	}

	private void addPFrameMoitionVector(int intFrameIndex,
			SimpleEntry<Integer, Integer> objMotionVector) {
		ArrayList<SimpleEntry<Integer, Integer>> lstMoitionVectors_macroBlock = new ArrayList<SimpleEntry<Integer, Integer>>();
		lstMoitionVectors_macroBlock.add(objMotionVector);
		lstMotionVectors.get(intFrameIndex).add(lstMoitionVectors_macroBlock);
	}

	private SimpleEntry<Integer, Integer> getPFrameMoitionVector(
			int intFrameIndex, int intMacroBlockIndex) {
		SimpleEntry<Integer, Integer> objMotionVector = lstMotionVectors
				.get(intFrameIndex).get(intMacroBlockIndex).get(0);
		return objMotionVector;
	}

	private int getPFrameReferenceIndex(int intFrameIndex) {
		int intReferenceFrameIndex = 0;
		for (int i = intFrameIndex - 1; i >= 0; i--) {
			if (lstFrameTypes.get(i) == FrameType.I
					|| lstFrameTypes.get(i) == FrameType.P) {
				intReferenceFrameIndex = i;
				break;
			}
		}
		return intReferenceFrameIndex;
	}

	private int[][] getPFrameReference(ColorChannel enmColorChannel,
			int intFrameIndex, int intReferenceFrameIndex) {
		int[][] arrReference = null;

		switch (enmColorChannel) {
		case Y:
			arrReference = lstDecodedY.get(intReferenceFrameIndex);
			break;
		case U:
			arrReference = lstDecodedU.get(intReferenceFrameIndex);
			break;
		case V:
			arrReference = lstDecodedV.get(intReferenceFrameIndex);
			break;
		}
		return arrReference;
	}

	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * B Frames
	 */
	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * P + B Frames Helper
	 */
	private SimpleEntry<Integer, Integer> logSearch(int intReferenceFrameIndex,
			int[][] arrReferenceFrame, int intFrameIndex, int[][] arrSlice,
			int intYpos, int intXpos, ColorChannel enmColorChannel,
			int intMacroBlockSize) {
		SimpleEntry<Integer, Integer> objMotionVector = null;

		// \\\\\\\\\\ FILL IN HERE //////////

		return objMotionVector;
	}

	/**
	 * *****************************************************************
	 */

	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Transform + Quantization
	 */

	private int[][] applyIntegerTransform(ColorChannel enmColorChannel,
			int intFrameIndex) {
		return applyIntegerTransform(enmColorChannel, intFrameIndex, false);
	}

	private int[][] applyIntegerTransform(ColorChannel enmColorChannel,
			int intFrameIndex, Boolean blnInverse) {

		int[][] arrOriginal = null;
		int[][] arrTransformed = null;

		switch (enmColorChannel) {
		case Y:
			arrOriginal = lstResidualY.get(intFrameIndex);
			break;
		case U:
			arrOriginal = lstResidualU.get(intFrameIndex);
			break;
		case V:
			arrOriginal = lstResidualV.get(intFrameIndex);
			break;
		}

		arrTransformed = applyIntegerTransform(arrOriginal, blnInverse);

		switch (enmColorChannel) {
		case Y:
			lstResidualY.set(intFrameIndex, arrTransformed);
			break;
		case U:
			lstResidualU.set(intFrameIndex, arrTransformed);
			break;
		case V:
			lstResidualV.set(intFrameIndex, arrTransformed);
			break;
		}

		return arrTransformed;
	}

	private int[][] applyIntegerTransform(int[][] arrOriginal,
			Boolean blnInverse) {
		int intHeight = arrOriginal.length;
		int intWidth = arrOriginal[0].length;
		int[][] arrTransformed = new int[intHeight][intWidth];

		for (int h = 0; h < intHeight; h += INTEGER_TRANSFORM_BLOCK_SIZE) {
			for (int w = 0; w < intWidth; w += INTEGER_TRANSFORM_BLOCK_SIZE) {
				int[][] arrSlice = Helper.sliceArray(arrOriginal, h, w,
						INTEGER_TRANSFORM_BLOCK_SIZE);
				if (blnInverse) {
					arrSlice = objIntegerTransform.inverseT(arrSlice);
				} else {
					arrSlice = objIntegerTransform.forwardT(arrSlice);
				}
				Helper.copySlice(arrTransformed, arrSlice, h, w,
						INTEGER_TRANSFORM_BLOCK_SIZE);
			}
		}

		return arrTransformed;
	}

	/**
	 * *****************************************************************
	 */

	/*******************************************************************
	 * Getters
	 */
	public int getFrameCount() {
		return intFrameCount;
	}

	public BufferedImage getRGBImageDecodedByIndex(int i) {
		return lstRGBImagesDecoded.get(i);
	}

	public BufferedImage getRGBImagePredictedByIndex(int i) {
		return lstRGBImagesPredicted.get(i);
	}

	public BufferedImage getRGBImageResidualByIndex(int i) {
		return lstRGBImagesResidual.get(i);
	}

	public BufferedImage getRGBImageOriginalByIndex(int i) {
		return lstRGBImagesOriginal.get(i);
	}
	/**
	 * *****************************************************************
	 */
}