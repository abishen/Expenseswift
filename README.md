# ExpenseSwift

ExpenseSwift is a small SwiftUI sample app that demonstrates using SwiftData to store and manage simple expense records. The app supports adding expenses, grouping them by date in the list, attaching a photo (camera / photo library), and performing on-device OCR (Vision) to extract text (e.g. merchant and amounts) from captured images to help prefill expense fields.

This repository is intended as a compact example of modern iOS development using:
- SwiftUI for UI
- SwiftData for model persistence (@Model and @Query)
- Vision for on-device text recognition (OCR)
- UIKit bridging (UIImagePickerController) to capture/select images
- Charts for a small expense chart view

## Key features
- Add new expenses with name, date and amount.
- Attach a photo to an expense (camera / photo library). A thumbnail is shown in the list.
- When an image is selected, Vision OCR runs and attempts to prefill the name and amount fields.
- Expenses are grouped by calendar day in the list (one section per day) and sorted newest-first.
- Swipe a row to the right to reveal an Edit action which opens an edit sheet. Changes are bound to the SwiftData model and saved automatically.
- A small chart view shows expense slices by name.

## Project structure (important files)
- `ExpenseSwiftData/Expense.swift` — The `@Model` for `Expense` (name, date, value, imageData).
- `ExpenseSwiftData/ContentView.swift` — Main list UI, groups expenses by date and wires up add/edit flows and the chart.
- `ExpenseSwiftData/AddExpenseSheet.swift` — Sheet to add a new expense; supports image capture/selection and OCR prefill.
- `ExpenseSwiftData/UpdateExpense.swift` — Edit sheet for existing expenses; supports image editing and OCR prefill on change.
- `ExpenseSwiftData/ExpenseCell.swift` — Row view showing thumbnail (if available), name and amount.
- `ExpenseSwiftData/ImagePicker.swift` — UIKit wrapper for `UIImagePickerController` to capture/choose photos.
- `ExpenseSwiftData/TextRecognizer.swift` — Small wrapper around Vision text recognition used to extract text from images.

## Build & run
1. Open `ExpenseSwiftData.xcodeproj` in Xcode (recommended) and run on a device or simulator.
2. If running on a physical device, the camera capture will work as expected. On Simulator, camera may be unavailable — the app falls back to the photo library.

Command-line (example):
```bash
# from repository root
xcodebuild -project ExpenseSwiftData.xcodeproj -scheme ExpenseSwiftData -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14' clean build
```

## Permissions
- The app uses the camera and photo library. Xcode / your app target must include the appropriate usage descriptions in the app's `Info.plist` to avoid runtime permission rejections:
  - `NSCameraUsageDescription` — explain why the app needs the camera
  - `NSPhotoLibraryUsageDescription` — explain why the app needs access to photos

If these keys are not present, add them with appropriate strings describing usage (e.g. "Attach a photo of a receipt to this expense").

## Notes on OCR
- The OCR implementation uses Vision with `VNRecognizeTextRequest` and is intentionally simple. It extracts recognized lines and attempts to:
  - Prefill the expense name with the first non-empty line when the name field is empty.
  - Prefill the amount with the first numeric-like token when the amount is zero.
- This is heuristic and may not be accurate for all receipts. For better accuracy consider:
  - Preprocessing images (grayscale, contrast), scaling down/up appropriate for Vision
  - Searching for lines containing currency symbols or words like "Total"/"Amount"
  - Using a more advanced ML model or a third-party OCR service if needed

## Potential improvements
- Store a separate thumbnail in the model to avoid storing large images in the data store.
- Allow the user to confirm/choose which recognized line to use for the name or amount (show all recognized lines).
- Improve amount extraction to prefer lines with currency symbols or labels.
- Add unit / UI tests.

## License
This project is provided as an example. Add a license file if you intend to publish or distribute.

---
If you want, I can add `Info.plist` keys, refine OCR heuristics, or implement a confirmation UI for recognized text lines. Tell me which improvement to implement next.
