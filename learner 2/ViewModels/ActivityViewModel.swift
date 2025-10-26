import Foundation
import SwiftUI
import Combine

// MARK: - ActivityViewModel
// يحوي كل منطق صفحة Activity: العدّ، الحفظ، القواعد، وإدارة السجلات.
final class ActivityViewModel: ObservableObject {
    // القيم المعروضة في الواجهة
    @Published var learnedDays = 0            // عدد الأيام المكتسبة
    @Published var frozenDays  = 0            // عدد الأيام المجمّدة
    @Published var totalFreezes = 0           // الحد الأعلى للتجميد حسب المدة
    @Published var lastActivityDate: Date? = nil  // آخر يوم سجّلنا فيه
    @Published var isDisabledToday = false    // منع النقر مرتين في نفس اليوم
    @Published var allFreezesUsed = false     // هل استهلكنا كل التجميدات
    @Published var logs: Set<DayLog> = []     // سجلات الأيام (learned/frozen)
    @Published var showCompletionSheet = false

    // ثوابت تمر من الـ View
    let subject: String
    let period: Period

    // المُنشئ يتسلم الموضوع والمدة، ويحمّل البيانات ويحسب الحصة
    init(subject: String, period: Period) {
        self.subject = subject
        self.period  = period
        self.totalFreezes = Self.quota(for: period) // حساب الحد الأقصى
        load() // عند الإنشاء نحمّل البيانات المخزنة سابقًا
    }

    // مفتاح التخزين (يشمل الموضوع والمدة لنعزل كل هدف عن الآخر)
    private var keyPrefix: String { "learn-\(subject)-\(period.rawValue)" }

    // MARK: - حفظ
    func save() {
        let enc = JSONEncoder()
        if let data = try? enc.encode(Array(logs)) {
            UserDefaults.standard.set(data, forKey: "\(keyPrefix)-logs") // حفظ السجلات كـ Data
        }
        UserDefaults.standard.set(learnedDays, forKey: "\(keyPrefix)-learned")
        UserDefaults.standard.set(frozenDays,  forKey: "\(keyPrefix)-frozen")
        UserDefaults.standard.set(lastActivityDate, forKey: "\(keyPrefix)-lastDate")
    }

    // MARK: - تحميل
    func load() {
        let dec = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "\(keyPrefix)-logs"),
           let arr  = try? dec.decode([DayLog].self, from: data) {
            logs = Set(arr) // نعيدها إلى Set
        }
        learnedDays = UserDefaults.standard.integer(forKey: "\(keyPrefix)-learned")
        frozenDays  = UserDefaults.standard.integer(forKey: "\(keyPrefix)-frozen")
        lastActivityDate = UserDefaults.standard.object(forKey: "\(keyPrefix)-lastDate") as? Date
        allFreezesUsed = frozenDays >= totalFreezes

        // إذا كان آخر نشاط اليوم نفسه → عطّل الأزرار
        if let last = lastActivityDate, Calendar.current.isDateInToday(last) {
            isDisabledToday = true
        } else {
            isDisabledToday = false
        }
    }

    // MARK: - قواعد/حصص
    static func quota(for period: Period) -> Int {
        switch period {
        case .week:  return 2   // نفس المنطق الأصلي
        case .month: return 8
        case .year:  return 96
        }
    }

    // MARK: - إجراءات
    func logAsLearned() {
        guard !isDisabledToday else { return } // لا نسمح بتكرار التسجيل اليوم
        learnedDays += 1
        lastActivityDate = Date()
        isDisabledToday = true

        // نضيف سجل اليوم بحالة learned
        logs.insert(DayLog(yyyymmdd: Date().yyyymmddInt, status: .learned))
        save()
        checkIfGoalCompleted()
        showCompletionSheet = true  // ✅ لعرض الشيت فورًا أثناء التجربة

    }
    // ✅ تحقق من إكمال الهدف بعد تسجيل اليوم

    func logAsFrozen() {
        guard !isDisabledToday else { return }       // لا نسمح بالنقر مرتين اليوم
        guard frozenDays < totalFreezes else {       // لا تتجاوز الحصة
            allFreezesUsed = true
            return
        }
        frozenDays += 1
        lastActivityDate = Date()
        isDisabledToday = true
        allFreezesUsed = (frozenDays >= totalFreezes)

        // نضيف سجل اليوم بحالة frozen
        logs.insert(DayLog(yyyymmdd: Date().yyyymmddInt, status: .frozen))
        save()
    }

    // إذا مر أكثر من ~ 32 ساعة على آخر نشاط → نعيد العداد
    func enforceStreakRuleIfNeeded() {
        guard let last = lastActivityDate else { return }
        if Date().timeIntervalSince(last) > 32 * 3600 {
            learnedDays = 0
            frozenDays  = 0
            allFreezesUsed = false
            isDisabledToday = false
            logs.removeAll()
            save()
        }
    }

    // إعادة تفعيل الأزرار عند بداية يوم جديد
    func resetButtonsIfNewDay() {
        if let last = lastActivityDate, Calendar.current.isDateInToday(last) {
            isDisabledToday = true
        } else {
            isDisabledToday = false
        }
    }

    // عند تحديث الهدف (موضوع/مدة جديدة) نعيد التهيئة
    func resetForNewGoal() {
        learnedDays = 0
        frozenDays  = 0
        allFreezesUsed = false
        isDisabledToday = false
        lastActivityDate = nil
        logs.removeAll()
        save()
    }

    // MARK: - فحص اكتمال الهدف
    private func checkIfGoalCompleted() {
        switch period {
        case .week:
            if learnedDays >= 7 { showCompletionSheet = true }
        case .month:
            if learnedDays >= 30 { showCompletionSheet = true }
        case .year:
            if learnedDays >= 365 { showCompletionSheet = true }
        }
    }
}

// MARK: - توسيع التاريخ لتخزينه كعدد صحيح YYYYMMDD

