//
//  SafariView.swift
//  WebAuthentication-iOS
//
//  Created by Hugues Stéphano TELOLAHY on 04/02/2025.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false // Disable reader mode

        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.preferredControlTintColor = .systemRed     // Tint color for buttons
        safariVC.delegate = context.coordinator         // Handle dismissal events
        safariVC.dismissButtonStyle = .cancel
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed for static URLs
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariView

        init(_ parent: SafariView) {
            self.parent = parent
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            // Handle when the user dismisses SafariViewController
            print("SafariViewController dismissed.")
        }

        func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
            []
        }
    }
}
