import SwiftUI
import VisionKit
import Vision

nonisolated enum ScannedDataType: Sendable {
    case barcode(String)
    case qrCode(String)
    case text(String)
}

@Observable
@MainActor
class BarcodeScannerService {
    var isAvailable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    var scannedItems: [ScannedDataType] = []
    var isScanning = false
    var errorMessage: String?

    func processRecognizedItem(_ item: RecognizedItem) {
        switch item {
        case .barcode(let barcode):
            let value = barcode.payloadStringValue ?? ""
            scannedItems.append(.barcode(value))
        case .text(let text):
            scannedItems.append(.text(text.transcript))
        @unknown default:
            break
        }
    }

    func clearScannedItems() {
        scannedItems.removeAll()
    }
}

struct BarcodeScannerView: UIViewControllerRepresentable {
    let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    let onItemScanned: @MainActor (RecognizedItem) -> Void
    let onDismiss: @MainActor () -> Void

    init(
        recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [.barcode()],
        onItemScanned: @escaping @MainActor (RecognizedItem) -> Void,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.recognizedDataTypes = recognizedDataTypes
        self.onItemScanned = onItemScanned
        self.onDismiss = onDismiss
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onItemScanned: onItemScanned, onDismiss: onDismiss)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onItemScanned: @MainActor (RecognizedItem) -> Void
        let onDismiss: @MainActor () -> Void

        init(
            onItemScanned: @escaping @MainActor (RecognizedItem) -> Void,
            onDismiss: @escaping @MainActor () -> Void
        ) {
            self.onItemScanned = onItemScanned
            self.onDismiss = onDismiss
        }

        nonisolated func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            Task { @MainActor in
                onItemScanned(item)
            }
        }

        nonisolated func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let firstItem = addedItems.first else { return }
            Task { @MainActor in
                onItemScanned(firstItem)
            }
        }

        nonisolated func dataScannerDidZoom(_ dataScanner: DataScannerViewController) {}

        nonisolated func dataScannerDidChangeAvailability(_ dataScanner: DataScannerViewController) {}
    }
}
