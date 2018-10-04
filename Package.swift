// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "pdf2png",
    dependencies: [
	.package(url: "https://github.com/kylef/Commander.git", from: "0.0.0"),
    ],
    targets: [
    	.target(
		name: "pdf2png",
		dependencies: ["Commander"],
		path: "."
	)
    ]
)

