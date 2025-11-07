import SwiftUI
import CoreData

struct FRAppIconView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var storage = Storage.shared
    
    private var _app: AppInfoPresentable
    private var _size: CGFloat
    
    init(app: AppInfoPresentable, size: CGFloat = 87) {
        self._app = app
        self._size = size
    }
	
	var body: some View {
		if
			let iconFilePath = storage.getAppDirectory(for: _app)?.appendingPathComponent(_app.icon ?? ""),
			let uiImage = UIImage(contentsOfFile: iconFilePath.path)
		{
			Image(uiImage: uiImage)
				.appIconStyle(size: _size)
		} else {
			Image("App_Unknown")
				.appIconStyle(size: _size)
		}
	}
}