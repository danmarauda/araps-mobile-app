import SwiftUI
import UIKit

@Observable
@MainActor
class PrintService {
    var isPrinting = false
    var errorMessage: String?

    var canPrint: Bool {
        UIPrintInteractionController.isPrintingAvailable
    }

    func printText(_ text: String, jobName: String = "ARAPS Document") {
        guard canPrint else {
            errorMessage = "Printing is not available on this device"
            return
        }

        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = jobName
        printController.printInfo = printInfo

        let formatter = UIMarkupTextPrintFormatter(markupText: "<html><body><pre>\(text)</pre></body></html>")
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printFormatter = formatter

        isPrinting = true
        printController.present(animated: true) { [weak self] _, completed, error in
            Task { @MainActor in
                self?.isPrinting = false
                if let error, !completed {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func printHTML(_ html: String, jobName: String = "ARAPS Report") {
        guard canPrint else {
            errorMessage = "Printing is not available on this device"
            return
        }

        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = jobName
        printController.printInfo = printInfo

        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printFormatter = formatter

        isPrinting = true
        printController.present(animated: true) { [weak self] _, completed, error in
            Task { @MainActor in
                self?.isPrinting = false
                if let error, !completed {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func printImage(_ image: UIImage, jobName: String = "ARAPS Image") {
        guard canPrint else {
            errorMessage = "Printing is not available on this device"
            return
        }

        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printInfo.jobName = jobName
        printController.printInfo = printInfo
        printController.printingItem = image

        isPrinting = true
        printController.present(animated: true) { [weak self] _, completed, error in
            Task { @MainActor in
                self?.isPrinting = false
                if let error, !completed {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func printPDF(at url: URL, jobName: String = "ARAPS PDF") {
        guard canPrint else {
            errorMessage = "Printing is not available on this device"
            return
        }

        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = jobName
        printController.printInfo = printInfo
        printController.printingItem = url

        isPrinting = true
        printController.present(animated: true) { [weak self] _, completed, error in
            Task { @MainActor in
                self?.isPrinting = false
                if let error, !completed {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
