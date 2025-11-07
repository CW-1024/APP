import Foundation
import SWCompression
import Compression

enum TweakHandlerError: Error, LocalizedError {
    case unsupportedFileExtension(String)
    case decompressionFailed(Error)
    case invalidFormat
    case fileNotFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFileExtension(let ext):
            return "Unsupported file extension: \(ext)"
        case .decompressionFailed(let error):
            return "Decompression failed: \(error.localizedDescription)"
        case .invalidFormat:
            return "Invalid file format"
        case .fileNotFound:
            return "File not found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

func extractFile(at fileURL: inout URL) throws {
	let fileExtension = fileURL.pathExtension.lowercased()
	let fileManager = FileManager.default
	
	let decompressors: [String: (Data) throws -> Data] = [
		"xz": XZArchive.unarchive,
		"lzma": LZMA.decompress,
		"bz2": BZip2.decompress,
		"gz": GzipArchive.unarchive
	]
	
	if let decompressor = decompressors[fileExtension] {
		let outputURL = fileURL.deletingPathExtension()
		try decompressor(Data(contentsOf: fileURL)).write(to: outputURL)
		fileURL = outputURL
		return
	}
	
	if fileExtension == "tar" {
		let tarData = try Data(contentsOf: fileURL)
		let tarContainer = try TarContainer.open(container: tarData)
		
		let extractionDirectory = fileURL.deletingLastPathComponent().appendingPathComponent(UUID().uuidString)
		try fileManager.createDirectory(at: extractionDirectory, withIntermediateDirectories: true)
		
		for entry in tarContainer {
			let entryPath = extractionDirectory.appendingPathComponent(entry.info.name)
			
			if entry.info.type == .directory {
				try fileManager.createDirectory(at: entryPath, withIntermediateDirectories: true)
			} else if entry.info.type == .regular, let entryData = entry.data {
				try entryData.write(to: entryPath)
			}
		}
		
		fileURL = extractionDirectory
		return
	}
	
	throw TweakHandlerError.unsupportedFileExtension(fileExtension)
}
