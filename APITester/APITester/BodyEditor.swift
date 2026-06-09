import SwiftUI
import UIKit

struct BodyEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.smartQuotesType = .no
        view.smartDashesType = .no

        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        bar.items = [
            UIBarButtonItem(title: "{ }", style: .plain, target: context.coordinator,
                            action: #selector(Coordinator.insertBraces)),
            UIBarButtonItem(title: "\" \"", style: .plain, target: context.coordinator,
                            action: #selector(Coordinator.insertQuotes)),
            UIBarButtonItem(title: "[ ]", style: .plain, target: context.coordinator,
                            action: #selector(Coordinator.insertBrackets)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator,
                            action: #selector(Coordinator.done))
        ]
        bar.sizeToFit()
        view.inputAccessoryView = bar
        context.coordinator.textView = view
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        if view.text != text {
            view.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        weak var textView: UITextView?

        init(text: Binding<String>) {
            self._text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }

        @objc func insertBraces() { insertPair("{", "}") }
        @objc func insertQuotes() { insertPair("\"", "\"") }
        @objc func insertBrackets() { insertPair("[", "]") }

        @objc func done() {
            textView?.resignFirstResponder()
        }

        private func insertPair(_ open: String, _ close: String) {
            guard let view = textView else { return }
            let selected = view.selectedRange
            let pair = open + close
            if let rangeStart = view.position(from: view.beginningOfDocument, offset: selected.location),
               let rangeEnd = view.position(from: rangeStart, offset: selected.length),
               let textRange = view.textRange(from: rangeStart, to: rangeEnd) {
                view.replace(textRange, withText: pair)
            }
            let cursorOffset = selected.location + open.count
            if let pos = view.position(from: view.beginningOfDocument, offset: cursorOffset) {
                view.selectedTextRange = view.textRange(from: pos, to: pos)
            }
            text = view.text
        }
    }
}
