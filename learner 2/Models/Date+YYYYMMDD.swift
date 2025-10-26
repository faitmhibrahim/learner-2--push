import Foundation

// MARK: - مفتاح يوم بصيغة عدد صحيح YYYYMMDD
// هذا التوسيع متاح على مستوى المشروع كله — يُستدعى عبر Date().yyyymmddInt
public extension Date {
    var yyyymmddInt: Int {
        let c = Calendar.current
        let y = c.component(.year,  from: self)
        let m = c.component(.month, from: self)
        let d = c.component(.day,   from: self)
        return y * 10_000 + m * 100 + d
    }
}
