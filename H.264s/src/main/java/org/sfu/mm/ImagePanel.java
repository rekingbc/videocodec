package org.sfu.mm;

import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.image.BufferedImage;

import javax.swing.BorderFactory;
import javax.swing.JPanel;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;

public class ImagePanel extends JPanel {

	/**
	 * Serial Number
	 */
	private static final long serialVersionUID = 1L;

	private BufferedImage objBufferedImage = null;

	public void setImage(BufferedImage objBufferedImage, String strLabel) {
		this.objBufferedImage = objBufferedImage;
		this.setBorder(BorderFactory.createTitledBorder(
				BorderFactory.createEtchedBorder(EtchedBorder.LOWERED),
				strLabel, TitledBorder.CENTER, TitledBorder.CENTER));

		Dimension dimNew = new Dimension(objBufferedImage.getWidth() + 20,
				objBufferedImage.getHeight() + 20);
		this.setPreferredSize(dimNew);
	}

	@Override
	protected void paintComponent(Graphics objGraphics) {
		super.paintComponent(objGraphics);
		if (objBufferedImage != null) {
			objGraphics.drawImage(objBufferedImage, 10, 15, null);
		}
	}
}
