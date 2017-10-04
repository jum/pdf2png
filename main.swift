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
	Option("width", 1024, description: "output pixel width"),
	Option("height", 1024, description: "output pixel height"),
	Option("page", 1, description: "page to render"),
	Argument<String>("pdfin", description: "The PDF input file"),
	Argument<String>("pngout", description: "The PNG output file")
) { width, height, pageno, pdfin, pngout  in
	//debugPrint(pdfin, pngout, width, height)
	let url = URL(fileURLWithPath: pdfin)
	if let pdfdoc = CGPDFDocument(url as CFURL) {
		let size = CGSize(width: width, height: height)
		if let page = pdfdoc.page(at: pageno) {
			let smallPageRect = page.getBoxRect(.cropBox)
			//let cspace = NSColorSpaceName.deviceRGB
			let cspace = NSDeviceRGBColorSpace
			let image = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: cspace, bytesPerRow: 0, bitsPerPixel: 0)!
			let destRect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
			let pdfScale = size.width/smallPageRect.size.width
			var drawingTransform = page.getDrawingTransform(.cropBox, rect: destRect, rotate: 0, preserveAspectRatio: true)
			if pdfScale > 1 {
				drawingTransform = drawingTransform.scaledBy(x: pdfScale, y: pdfScale)
				drawingTransform.tx = 0
				drawingTransform.ty = 0
			}
			let ctx = NSGraphicsContext(bitmapImageRep: image)!
			let cgctx = ctx.cgContext
			cgctx.concatenate(drawingTransform)
			cgctx.drawPDFPage(page)
			let data = image.representation(using: NSPNGFileType, properties: [:])!
			let outurl = URL(fileURLWithPath: pngout)
			do {
				try data.write(to: outurl)
			} catch {
				print("unable to write \(url.absoluteString): \(error)")
			}
		} else {
			print("could not find page \(pageno) in \(url.absoluteString)")
		}
	} else {
		print("Unable to open \(url.absoluteString)")
	}
}.run()
