import SwiftUI
import WebKit

struct RemoteVideoUrlView: UIViewRepresentable {
    let videoUrl: URL
    func makeUIView(context: Context) ->  WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.scrollView.isScrollEnabled = false
        uiView.allowsLinkPreview = true
        print(videoUrl)
        uiView.load(URLRequest(url: videoUrl))
    }
}
