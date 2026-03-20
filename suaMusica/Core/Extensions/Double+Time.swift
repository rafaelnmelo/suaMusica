import Foundation

extension Double {
    var formattedAsTime: String {
        guard isFinite && self > 0 else { return "0:00" }
        let s = Int(self)
        return "\(s / 60):\(String(format: "%02d", s % 60))"
    }
}
