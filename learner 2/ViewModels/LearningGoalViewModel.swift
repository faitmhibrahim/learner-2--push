import Foundation
import SwiftUI
import Combine

// MARK: - LearningGoalViewModel
// يدير منطق صفحة تعديل الهدف (التحقق، إظهار الشيت، التنقّل).
final class LearningGoalViewModel: ObservableObject {
    // القيم التي كانت @State داخل الواجهة
    @Published var subject: String = ""                    // نص الموضوع
    @Published var selectedPeriod: Period = .week          // المدة
    @Published var showConfirmationSheet: Bool = false     // عرض الشيت
    @Published var navigateToActivity: Bool = false        // تفعيل الانتقال
    @Published var hasExistingProgress: Bool = true        // افتراض: يوجد تقدم سابق

    // صلاحية النص
    var isSubjectValid: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // زر الحفظ
    func onTapSave() {
        if hasExistingProgress {
            showConfirmationSheet = true
        } else {
            navigateToActivity = true
        }
    }

    // المستخدم أكد التحديث من الشيت
    func confirmUpdate() {
        showConfirmationSheet = false
        navigateToActivity = true
    }

    // المستخدم أغلق الشيت
    func dismissSheet() {
        showConfirmationSheet = false
    }
}
