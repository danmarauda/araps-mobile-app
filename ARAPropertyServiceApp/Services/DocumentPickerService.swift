import SwiftUI
import UniformTypeIdentifiers

nonisolated struct PickedDocument: Sendable {
    let url: URL
    let filename: String
    let fileExtension: String
    let fileSize: Int64?
}

@Observable
@MainActor
class DocumentPickerService {
    var pickedDocuments: [PickedDocument] = []
    var isPresenting = false
    var errorMessage: String?

    func processPickedURLs(_ urls: [URL]) {
        pickedDocuments = urls.compactMap { url in
            guard url.startAccessingSecurityScopedResource() else { return nil }
            defer { url.stopAccessingSecurityScopedResource() }

            let fileSize: Int64? = {
                let values = try? url.resourceValues(forKeys: [.fileSizeKey])
                return values?.fileSize.map { Int64($0) }
            }()

            return PickedDocument(
                url: url,
                filename: url.lastPathComponent,
                fileExtension: url.pathExtension,
                fileSize: fileSize
            )
        }
    }

    func clearDocuments() {
        pickedDocuments.removeAll()
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let allowsMultipleSelection: Bool
    let onPick: @MainActor ([URL]) -> Void
    let onCancel: @MainActor () -> Void

    init(
        contentTypes: [UTType] = [.pdf, .image, .plainText],
        allowsMultipleSelection: Bool = false,
        onPick: @escaping @MainActor ([URL]) -> Void,
        onCancel: @escaping @MainActor () -> Void = {}
    ) {
        self.contentTypes = contentTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onPick = onPick
        self.onCancel = onCancel
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onCancel: onCancel)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: @MainActor ([URL]) -> Void
        let onCancel: @MainActor () -> Void

        init(
            onPick: @escaping @MainActor ([URL]) -> Void,
            onCancel: @escaping @MainActor () -> Void
        ) {
            self.onPick = onPick
            self.onCancel = onCancel
        }

        nonisolated func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            Task { @MainActor in
                onPick(urls)
            }
        }

        nonisolated func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            Task { @MainActor in
                onCancel()
            }
        }
    }
}
