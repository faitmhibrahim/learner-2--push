import Foundation  // نحتاج Foundation للتعامل مع التاريخ وCodable

// MARK: - حالات اليوم
// نمثل حالة اليوم كـ rawValue لتخزينها بسهولة في UserDefaults.
enum DayStatus: String, Codable { case learned, frozen }

// MARK: - سجل يوم واحد
// نخزن (YYYYMMDD) كعدد صحيح + الحالة. نجعله Hashable حتى نضعه داخل Set.
struct DayLog: Codable, Hashable {
    let yyyymmdd: Int
    let status: DayStatus
}
