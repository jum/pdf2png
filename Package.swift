import PackageDescription

let package = Package(
    name: "pdf2png",
    targets: [],
    dependencies: [
	.Package(url: "https://github.com/kylef/Commander.git",
		majorVersion: 0),
    ]
)

