package org.sfu.mm;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.TimeUnit;

import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

public class GUI extends JPanel implements ActionListener, ChangeListener {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 1L;

	private String[] arrQF = new String[] { "20", "30", "40" };

	private H264s objH26X = null;

	private JFrame objFrame;
	private JPanel pnlMain = new JPanel();
	private JPanel pnlInput = new JPanel();
	private JPanel pnlOutput = new JPanel();
	private JScrollPane scrlOutput = new JScrollPane();
	private JPanel pnlGeneralSettings = new JPanel();

	private ImagePanel pnlOriginalVideo = new ImagePanel();

	private ImagePanel pnlDecodedVideo = new ImagePanel();
	private ImagePanel pnlPredictedVideo = new ImagePanel();
	private ImagePanel pnlResidualVideo = new ImagePanel();

	private JButton btnRun = new JButton("Run... ");
	private JButton btnPlay = new JButton("Play >");
	private JComboBox<String> cbQF = new JComboBox<>(arrQF);

	private JLabel lblQFactor = new JLabel("QP: ");
	private JLabel lblTestImage = new JLabel("Sequence:");
	private JLabel lblDecodedVideo = new JLabel("Decoded Video");
	private JLabel lblPredictedVideo = new JLabel("Predicted Video");
	private JLabel lblResidualVideo = new JLabel("Residual Video");

	private ButtonGroup objButtonGroupImage = new ButtonGroup();
	private JRadioButton rbCoastGuard = new JRadioButton("Coast Guard");
	private JRadioButton rbStefan = new JRadioButton("Stefan");

	/**
	 * Constructor
	 * 
	 * @throws IOException
	 */
	public GUI(JFrame objFrame) throws IOException {
		super(new BorderLayout());

		/**
		 * Disable play button initially
		 */
		btnPlay.setEnabled(false);

		this.objFrame = objFrame;
		pnlMain.setLayout(new BorderLayout());

		/**
		 * add action listener
		 */
		addActionListenerForControls();

		/**
		 * Input panel, image + general settings
		 */
		pnlInput.setLayout(new BorderLayout());
		pnlMain.add(pnlInput, BorderLayout.WEST);

		/**
		 * General Settings panel
		 */
		pnlGeneralSettings = new JPanel();
		createGeneralSettingsPanel(pnlGeneralSettings);
		pnlInput.add(pnlGeneralSettings, BorderLayout.PAGE_START);

		/**
		 * Add image panel
		 */
		setImage();
		pnlInput.add(pnlOriginalVideo, BorderLayout.PAGE_END);

		/**
		 * Create output panel
		 */
		createOutputPanel();
		pnlMain.add(scrlOutput, BorderLayout.EAST);

		/**
		 * Add the tabbed pane to the form
		 */
		stateChanged(null);
		add(pnlMain, BorderLayout.CENTER);
	}

	private void setImage() throws IOException {
		BufferedImage objBufferedImage = null;

		pnlOriginalVideo.setBorder(BorderFactory.createTitledBorder(
				BorderFactory.createEtchedBorder(EtchedBorder.LOWERED), null,
				TitledBorder.CENTER, TitledBorder.CENTER));
		if (rbCoastGuard.isSelected()) {
			objBufferedImage = Program.THUMB_COASTGUARD;
		} else if (rbStefan.isSelected()) {
			objBufferedImage = Program.THUMB_STEFAN;
		}

		pnlOriginalVideo.setImage(objBufferedImage, "Original Video");
		stateChanged(null);
	}

	@Override
	public void stateChanged(ChangeEvent e) {
		this.setPreferredSize(pnlMain.getPreferredSize());
		objFrame.pack();
		objFrame.setLocationRelativeTo(null);
	}

	@Override
	public void actionPerformed(ActionEvent objActionEvent) {
		if (objActionEvent.getSource() == rbCoastGuard
				|| objActionEvent.getSource() == rbStefan) {
			try {
				setImage();
			} catch (IOException e) {
				e.printStackTrace();
			}
			stateChanged(null);
		}

		else if (objActionEvent.getSource() == btnRun) {
			try {
				run();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		else if (objActionEvent.getSource() == btnPlay) {
			playBtn();
		}
	}

	private void run() throws IOException {

		final int intQScaleFactor = Integer.parseInt(cbQF.getSelectedItem()
				.toString());

		Thread objThread = new Thread(new Runnable() {

			public void run() {
				try {
					enableControls(false);
					InputStream openStream = null;
					if (rbCoastGuard.isSelected()) {
						openStream = Helper.CONTEXT_CLASS_LOADER.getResource(
								Program.COASTGUARD_FILE_NAME).openStream();
					} else if (rbStefan.isSelected()) {
						openStream = Helper.CONTEXT_CLASS_LOADER.getResource(
								Program.STEFAN_FILE_NAME).openStream();
					}

					objH26X = new H264s(openStream, intQScaleFactor);
					play();

					enableControls();
				} catch (Exception objException) {
					objException.printStackTrace();
				}
			}
		});
		objThread.start();

		scrlOutput.setVisible(true);
		scrlOutput.getVerticalScrollBar().setValue(0);
	}

	public void play() {
		try {
			int intFramesCount = objH26X.getFrameCount();
			for (int i = 0; i < intFramesCount; i++) {
				pnlOriginalVideo
						.setImage(objH26X.getRGBImageOriginalByIndex(i),
								"Original Video");
				pnlDecodedVideo.setImage(objH26X.getRGBImageDecodedByIndex(i),
						null);
				pnlPredictedVideo.setImage(
						objH26X.getRGBImagePredictedByIndex(i), null);
				pnlResidualVideo.setImage(
						objH26X.getRGBImageResidualByIndex(i), null);
				stateChanged(null);
				Thread.sleep(TimeUnit.SECONDS.toMillis(1) / 30);
			}
		} catch (Exception objException) {
			objException.printStackTrace();
		}
	}

	private void playBtn() {
		Thread objThread = new Thread(new Runnable() {
			public void run() {
				enableControls(false);
				play();
				enableControls();
			}
		});
		objThread.start();
	}

	public void enableControls() {
		enableControls(true);
	}

	public void enableControls(Boolean blnEnable) {
		this.rbCoastGuard.setEnabled(blnEnable);
		this.rbStefan.setEnabled(blnEnable);
		this.cbQF.setEnabled(blnEnable);
		this.btnRun.setEnabled(blnEnable);
		this.btnPlay.setEnabled(blnEnable);
	}

	private void addActionListenerForControls() {
		cbQF.addActionListener(this);
		btnRun.addActionListener(this);
		rbCoastGuard.addActionListener(this);
		rbStefan.addActionListener(this);
		btnPlay.addActionListener(this);
	}

	private void createOutputPanel() {
		pnlOutput.setBorder(BorderFactory.createTitledBorder(
				BorderFactory.createEtchedBorder(EtchedBorder.LOWERED), null,
				TitledBorder.CENTER, TitledBorder.CENTER));

		GroupLayout objOutputGroupLayout = new GroupLayout(pnlOutput);
		pnlOutput.setLayout(objOutputGroupLayout);

		objOutputGroupLayout
				.setHorizontalGroup(objOutputGroupLayout
						.createSequentialGroup()
						.addGroup(
								objOutputGroupLayout
										.createParallelGroup(
												GroupLayout.Alignment.LEADING)
										.addComponent(lblDecodedVideo)
										.addComponent(pnlDecodedVideo)
										.addComponent(lblPredictedVideo)
										.addComponent(pnlPredictedVideo)
										.addComponent(lblResidualVideo)
										.addComponent(pnlResidualVideo))
						.addGroup(
								objOutputGroupLayout
										.createParallelGroup(GroupLayout.Alignment.LEADING)));

		objOutputGroupLayout.setVerticalGroup(objOutputGroupLayout
				.createSequentialGroup()
				.addGroup(
						objOutputGroupLayout.createParallelGroup(
								GroupLayout.Alignment.BASELINE).addComponent(
								lblDecodedVideo))
				.addGroup(
						objOutputGroupLayout.createParallelGroup(
								GroupLayout.Alignment.BASELINE).addComponent(
								pnlDecodedVideo))
				.addGroup(
						objOutputGroupLayout.createParallelGroup(
								GroupLayout.Alignment.BASELINE).addComponent(
								lblPredictedVideo))
				.addGroup(
						objOutputGroupLayout.createParallelGroup(
								GroupLayout.Alignment.BASELINE).addComponent(
								pnlPredictedVideo))
				.addGroup(
						objOutputGroupLayout.createParallelGroup(
								GroupLayout.Alignment.BASELINE).addComponent(
								lblResidualVideo))
				.addGroup(
						objOutputGroupLayout.createParallelGroup(
								GroupLayout.Alignment.BASELINE).addComponent(
								pnlResidualVideo)));

		Dimension objNewDim = pnlInput.getPreferredSize();
		objNewDim.setSize(objNewDim.width + 30, objNewDim.height);
		scrlOutput.setPreferredSize(objNewDim);
		scrlOutput.setViewportView(pnlOutput);
		scrlOutput.setVisible(false);
	}

	private void createGeneralSettingsPanel(JPanel pnlGeneralSettings) {
		pnlGeneralSettings.setBorder(BorderFactory.createTitledBorder(
				BorderFactory.createEtchedBorder(EtchedBorder.LOWERED),
				"General Settings", TitledBorder.CENTER, TitledBorder.CENTER));
		GroupLayout objGeneralSettingsGroupLayout = new GroupLayout(
				pnlGeneralSettings);
		pnlGeneralSettings.setLayout(objGeneralSettingsGroupLayout);

		/**
		 * Set menu labels bold
		 */
		Font objFont = lblQFactor.getFont();
		// same font but bold
		Font objBoldFont = new Font(objFont.getFontName(), Font.BOLD,
				objFont.getSize());

		lblQFactor.setFont(objBoldFont);
		lblTestImage.setFont(objBoldFont);

		/**
		 * Create radio buttons groups
		 */

		objButtonGroupImage.add(rbCoastGuard);
		objButtonGroupImage.add(rbStefan);
		rbStefan.setSelected(true);

		objGeneralSettingsGroupLayout
				.setHorizontalGroup(objGeneralSettingsGroupLayout
						.createSequentialGroup()
						.addGroup(
								objGeneralSettingsGroupLayout
										.createParallelGroup(
												GroupLayout.Alignment.LEADING)
										.addComponent(lblTestImage)
										.addComponent(rbStefan)
										.addComponent(rbCoastGuard))
						.addGroup(
								objGeneralSettingsGroupLayout
										.createParallelGroup(
												GroupLayout.Alignment.LEADING)
										.addComponent(lblQFactor)
										.addComponent(cbQF)
										.addComponent(btnRun)
										.addComponent(btnPlay)));
		objGeneralSettingsGroupLayout
				.setVerticalGroup(objGeneralSettingsGroupLayout
						.createSequentialGroup()
						.addGroup(
								objGeneralSettingsGroupLayout
										.createParallelGroup(
												GroupLayout.Alignment.BASELINE)
										.addComponent(lblTestImage)
										.addComponent(lblQFactor))
						.addGroup(
								objGeneralSettingsGroupLayout
										.createParallelGroup(
												GroupLayout.Alignment.BASELINE)
										.addComponent(rbStefan)
										.addComponent(cbQF))
						.addGroup(
								objGeneralSettingsGroupLayout
										.createParallelGroup(
												GroupLayout.Alignment.BASELINE)
										.addComponent(rbCoastGuard)
										.addComponent(btnRun))
						.addGroup(
								objGeneralSettingsGroupLayout
										.createParallelGroup(
												GroupLayout.Alignment.BASELINE)
										.addComponent(btnPlay)));
	}
}
