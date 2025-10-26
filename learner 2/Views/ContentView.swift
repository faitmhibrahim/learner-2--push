import SwiftUI  // واجهة المستخدم

// MARK: - الصفحة الرئيسية (UI فقط)
// أبقينا الشكل كما هو تمامًا، ونقلنا الحالة والمنطق إلى HomeViewModel.
struct ContentView: View {
    @StateObject private var vm = HomeViewModel() // إنشاء ViewModel وربطه بعمر الصفحة

    var body: some View {
        NavigationStack { // مكدّس تنقّل حديث
            ZStack {
                Color.black.ignoresSafeArea() // خلفية سوداء تغطي كامل الشاشة

                VStack(alignment: .leading, spacing: 18) { // تجميع العناصر عموديًا
                    Spacer().frame(height: 28) // مسافة علوية بسيطة

                    // Logo (أضفنا تأثير Glassy على حدود الدائرة)
                    HStack {
                        Spacer().frame(width: 130) // إزاحة بسيطة للمحاذاة
                        ZStack {
                            Circle()
                                .fill(Color("bkcolor"))  // لون من الـ Assets
                                .frame(width: 120, height: 120)
                                .overlay( // إطار متدرّج حول الدائرة (القديم)
                                    Circle().stroke(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.95), Color("accentBorder")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                )
                                // إضافة الحد الزجاجي بنفس أسلوب الأزرار
                                .overlay(glassyCircleBorder())
                                .shadow(color: .black.opacity(0.6), radius: 18, x: 0, y: 8)

                            Image(systemName: "flame.fill")
                                .resizable().scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.orange)
                        }
                        Spacer()
                    }

                    // عناوين ترحيبية
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hello Learner")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        Text("This app will help you learn everyday!")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 8)

                    // عنوان الحقل
                    Text("I want to learn")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding(.horizontal, 28)
                        .padding(.top, 18)

                    // حقل النص وخط الفصل تحته (نفس الشكل)
                    VStack(spacing: 4) {
                        TextField("Enter subject", text: $vm.learnSubject) // ← ربط بالحقل داخل VM
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 8)
                        Rectangle()
                            .fill(Color.gray.opacity(0.35))
                            .frame(height: 1)
                            .padding(.horizontal, 28)
                    }

                    // عنوان المدة
                    Text("I want to learn it in a")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding(.horizontal, 28)
                        .padding(.top, 12)

                    // أزرار اختيار المدة (Glassy edges + selectedBGend للخيار المختار)
                    HStack(spacing: 14) {
                        ForEach(Period.allCases) { p in
                            PeriodButton(title: p.rawValue, isSelected: vm.selectedPeriod == p) {
                                vm.selectedPeriod = p // تحديث القيمة داخل VM
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 6)

                    Spacer()

                    // زر البدء — نفس لون ودرجة زر المدة المحدد تمامًا + حد زجاجي
                    HStack {
                        Spacer()
                        Button {
                            vm.startLearning()
                        } label: {
                            Text("Start learning")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color("selectedBGend"))
                                        .overlay(glassyRoundedBorder(cornerRadius: 28))
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!vm.isSubjectValid)
                        .opacity(vm.isSubjectValid ? 1 : 0.9)
                        Spacer()
                    }
                    .padding(.bottom, 36)

                    // NavigationLink مقيّد بحالة من الـ VM (بدون أي تغيير بصري)
                    NavigationLink("", isActive: $vm.navigateToActivity) {
                        ActivityView(subject: vm.learnSubject, period: vm.selectedPeriod)
                    }
                    .hidden()
                }
            }
            .preferredColorScheme(.dark) // واجهة داكنة
        }
    }
}

// MARK: - خلفية زجاجية موحّدة للزر المحدد (نفس ما نريده للـ Start)
private struct GlassySelectedBackground: View {
    var cornerRadius: CGFloat = 28
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color("selectedBGend")) // تعبئة مباشرة باللون
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.26),
                                Color.white.opacity(0.07),
                                Color.clear
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.clear
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: max(0, cornerRadius - 2))
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    .blur(radius: 1.2)
            )
            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
    }
}

// MARK: - زر اختيار المدة (Glassy edges)
// - عند التحديد: الخلفية Color("selectedBGend")
// - غير محدد: خلفية زجاجية خفيفة
struct PeriodButton: View {
    let title: String               // النص المعروض
    var isSelected: Bool            // هل هو مختار؟
    var action: () -> Void          // ما الذي يحدث عند النقر

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(isSelected ? 1 : 0.9))
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(
                    ZStack {
                        // الخلفية: selectedBGend عند التحديد، وإلا زجاجية خفيفة
                        RoundedRectangle(cornerRadius: 28)
                            .fill(isSelected ? Color("selectedBGend") : Color.clear)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(.ultraThinMaterial.opacity(isSelected ? 0.10 : 0.16))
                            )

                        // لمعان علوي زجاجي
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.26),
                                        Color.white.opacity(0.07),
                                        Color.clear
                                    ],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )

                        // حد زجاجي موحّد
                        glassyRoundedBorder(cornerRadius: 28)
                    }
                )
        }
        .buttonStyle(.plain) // منع التأثيرات الافتراضية للزر
        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    ContentView()
}
