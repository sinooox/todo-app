import SwiftUI

enum Page {
    case LoginView
    case RegisterView
    case MainView
}

class PageManager: ObservableObject {
    @Published var page: Page
    init(page: Page) {
        self.page = page
    }
}

@main
struct ToDo_App: App {
    @ObservedObject var pageManager = PageManager(page: .LoginView)

    var body: some Scene {
        WindowGroup {
            switch pageManager.page {
            case Page.LoginView:
                LoginView()
                    .environmentObject(pageManager)
            case .RegisterView:
                RegisterView()
                    .environmentObject(pageManager)
            case Page.MainView:
                MainView()
                    .environmentObject(pageManager)
            }
        }
    }
}
