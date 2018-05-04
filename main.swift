//
//  main.swift
//  pdf2png
//
//  Created by Jens-Uwe Mager on 03.10.17.
//  Copyright © 2017 Best Search Infobrokerage, Inc. All rights reserved.
//

import Commander
import AppKit

command(
	Option("width", default: 1024, description: "output pixel width"),
	Option("height", default: 1024, description: "output pixel height"),
	Option("page", default: 1, description: "page to render"),
	Flag("preserveaspectratio", default: true, description: "preserve the aspect ratio in the output"),
	Flag("hasalpha", default: false, description: "produce the alpha channel in the output"),
	Argument<String>("pdfin", description: "The PDF input file"),
	Argument<String>("pngout", description: "The PNG output file")
) { (width, height, pageno, preserveaspectratio, hasalpha, pdfin, pngout) throws  in
	let url = URL(fileURLWithPath: pdfin)
	if let pdfdoc = CGPDFDocument(url as CFURL) {
		let size = CGSize(width: width, height: height)
		if let page = pdfdoc.page(at: pageno) {
			let smallPageRect = page.getBoxRect(.cropBox)
			let cspace = NSCalibratedRGBColorSpace
			let image = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: hasalpha ? 4 : 3, hasAlpha: hasalpha, isPlanar: false, colorSpaceName: cspace, bytesPerRow: 0, bitsPerPixel: 32)!
			let destRect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
			let pdfScale = size.width/smallPageRect.size.width
			var drawingTransform = page.getDrawingTransform(.cropBox, rect: destRect, rotate: 0, preserveAspectRatio: preserveaspectratio)
			if pdfScale > 1 {
				drawingTransform = drawingTransform.scaledBy(x: pdfScale, y: pdfScale)
				drawingTransform.tx = 0
				drawingTransform.ty = 0
			}
			let ctx = NSGraphicsContext(bitmapImageRep: image)!
			let cgctx = ctx.cgContext
			cgctx.concatenate(drawingTransform)
			cgctx.drawPDFPage(page)
			if let data = image.representation(using: NSPNGFileType, properties: [:]) {
				let outurl = URL(fileURLWithPath: pngout)
				try data.write(to: outurl)
			} else {
				throw ArgumentParserError("Unable to create PNG representation")
			}
		} else {
			throw ArgumentParserError("could not find page \(pageno) in \(url.absoluteString)")
		}
	} else {
		throw ArgumentParserError("Unable to open \(url.absoluteString)")
	}
}.run()
