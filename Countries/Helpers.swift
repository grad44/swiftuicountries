import Foundation

func formatDoubleValues(val: Double, numberStyle: NumberFormatter.Style = .decimal, maximumFractionDigits: Int = 0) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = numberStyle
    formatter.maximumFractionDigits = maximumFractionDigits

    return formatter.string(from: val as NSNumber) ?? ""
}
