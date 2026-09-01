import SwiftUI
import UIKit

/// Thin `UIViewControllerRepresentable` wrapper around
/// `UIActivityViewController`, used to hand the exported JSON file to
/// Files, Mail, AirDrop, or any other share destination the person picks.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
