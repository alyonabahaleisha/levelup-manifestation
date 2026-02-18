import SwiftUI
import UIKit

extension View {
    func statusBarStyle(_ style: UIStatusBarStyle) -> some View {
        self.background(StatusBarStyleModifier(style: style))
    }
}

struct StatusBarStyleModifier: UIViewControllerRepresentable {
    let style: UIStatusBarStyle

    func makeUIViewController(context: Context) -> UIViewController {
        return StatusBarViewController(style: style)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let vc = uiViewController as? StatusBarViewController else { return }
        vc.statusBarStyle = style
        vc.setNeedsStatusBarAppearanceUpdate()
    }
}

class StatusBarViewController: UIViewController {
    var statusBarStyle: UIStatusBarStyle

    init(style: UIStatusBarStyle) {
        self.statusBarStyle = style
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}
