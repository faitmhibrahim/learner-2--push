import Foundation   // للوصول إلى أدوات النظام العامة
import SwiftUI      // لاستخدام @Published و ObservableObject
import Combine

// MARK: - HomeViewModel
// هذا الـ ViewModel يمسك حالة صفحة الهوم ويحتوي منطق التحقق والتنقّل.
final class HomeViewModel: ObservableObject {
    // الحقول التي كانت @State داخل ContentView أصبحت @Published هنا
    @Published var learnSubject: String = ""          // موضوع التعلم
    @Published var selectedPeriod: Period = .week     // المدة المختارة
    @Published var navigateToActivity: Bool = false   // تحكم بالانتقال

    // التحقق إن كان المستخدم كتب موضوعًا صالحًا
    var isSubjectValid: Bool {
        !learnSubject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // ينفّذ عند الضغط على زر "Start learning"
    func startLearning() {
        guard isSubjectValid else { return } // لا ننتقل إذا الحقل فاضي
        navigateToActivity = true            // تفعيل NavigationLink المقيّد بهذه الحالة
    }
}
