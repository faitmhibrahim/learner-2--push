import SwiftUI  // استيراد SwiftUI لاستخدام أنواع الألوان والخطوط لو احتجنا لاحقًا

// MARK: - تعريف المدة الزمنية (Model بسيط)
// هذا الـ enum يمثل خيارات المدة (أسبوع/شهر/سنة) ويُستخدم عبر الواجهة والـ ViewModels.
// نلتزم بنفس الأسماء والقيم حتى لا يتغيّر شكل التطبيق إطلاقًا.
enum Period: String, CaseIterable, Identifiable {  // نجعله Identifiable لسهولة استخدامه في ForEach
    case week  = "Week"   // نفس النص المعروض في الواجهة
    case month = "Month"  // "
    case year  = "Year"   // "
    var id: String { rawValue } // معرّف العنصر = القيمة الخام نفسها (مفيد للقوائم)
}
