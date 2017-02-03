package org.sfu.mm;

import java.awt.EventQueue;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.awt.image.BufferedImage;
import java.net.URL;

import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFrame;

public class Program extends JFrame implements WindowListener {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 1L;

	public static int LOG_SEARCH_STEP_SIZE = 32;
	public static int INTEGER_TRANSFORM_BLOCK_SIZE = 4;
	public static int MACRO_BLOCK_SIZE = 16;
	public static int FRAME_WIDTH = 352;
	public static int FRAME_HEIGHT = 288;

	/**
	 * Test videos file names
	 */
	public static String COASTGUARD_FILE_NAME = "coastguard_cif.yuv";
	public static String STEFAN_FILE_NAME = "stefan_cif.yuv";
	public static String AKIYO_FILE_NAME = "akiyo_cif.yuv";

	/**
	 * Test videos first frame
	 */
	public static BufferedImage THUMB_COASTGUARD = null;
	public static BufferedImage THUMB_STEFAN = null;
	public static BufferedImage THUMB_AKIYO = null;

	/**
	 * Constructor
	 */
	public Program() {
		super("H.26x Demo");
		try {
			JFrame.setDefaultLookAndFeelDecorated(true);
			JDialog.setDefaultLookAndFeelDecorated(true);
			GUI objContentPane = new GUI(this);
			addWindowListener(this);

			/**
			 * Create and set up the content pane.
			 */
			JComponent objJComponent = (JComponent) objContentPane;
			objJComponent.setOpaque(true);
			this.setContentPane(objJComponent);
			Helper.renderFrame(this);

		} catch (Exception objException) {
			System.err.println("Error: " + objException.getMessage());
			System.exit(-1);
		}
	}

	public static void main(String[] args) {
		try {
			/**
			 * Load first frame from each test video
			 */
			loadThumbnails();

			/**
			 * Start main frame
			 */
			EventQueue.invokeLater(new Runnable() {

				public void run() {
					try {
						Program objMainFrame = new Program();
						objMainFrame.setVisible(true);
						objMainFrame.setLocationRelativeTo(null);
					} catch (Exception objException) {
						System.err.println("Error while creating the window: "
								+ objException.getMessage());
					}
				}
			});

		} catch (Exception objException) {
			System.err.println("Error: " + objException.getMessage());
			System.exit(-1);
		}
	}

	private static void loadThumbnails() {
		URL urlImage = null;

		urlImage = Helper.CONTEXT_CLASS_LOADER
				.getResource(COASTGUARD_FILE_NAME);
		THUMB_COASTGUARD = loadThumbnail(urlImage);

		urlImage = Helper.CONTEXT_CLASS_LOADER.getResource(STEFAN_FILE_NAME);
		THUMB_STEFAN = loadThumbnail(urlImage);
		
		urlImage = Helper.CONTEXT_CLASS_LOADER.getResource(AKIYO_FILE_NAME);
		THUMB_AKIYO = loadThumbnail(urlImage);
	}

	private static BufferedImage loadThumbnail(URL urlImage) {
		BufferedImage objBufferedImage = null;
		try {
			YUVParser objYUVParser = new YUVParser();
			objYUVParser.startReading(urlImage.openStream());
			objBufferedImage = objYUVParser.nextImage();
			objYUVParser.endReading();
		} catch (Exception objException) {
			objException.printStackTrace();
		}
		return objBufferedImage;
	}

	@Override
	public void windowOpened(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void windowClosing(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void windowClosed(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void windowIconified(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void windowDeiconified(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void windowActivated(WindowEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void windowDeactivated(WindowEvent e) {
		// TODO Auto-generated method stub

	}

}
