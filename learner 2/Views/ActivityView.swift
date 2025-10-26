import SwiftUI
import Combine
import SwiftUI

// MARK: - صفحة Activity (الواجهة فقط، المنطق داخل ActivityViewModel)
struct ActivityView: View {
    // Props قادمة من الصفحة السابقة
    let subject: String   // اسم الهدف (مثلاً: Swift)
    let period: Period    // المدة (Week/Month/Year)

    // ViewModel يمسك المنطق والحالة
    @StateObject private var vm: ActivityViewModel
    // حالات واجهة مساعدة (عرض الشاشات الفرعية)
    @State private var showCalendar = false
    @State private var showEditSheet = false
    @State private var showLearningGoalView = false

    // اختيار شهر/سنة (للشريط العلوي داخل البطاقة)
    @State private var showMonthYearPicker = false
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonthIndex: Int = Calendar.current.component(.month, from: Date()) - 1 // 0..11

    // مرساة التاريخ وازاحة الأسبوع (للعرض فقط — لا تغيّر الشكل)
    @State private var anchorDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var weekOffset = 0 // تحريك الأسبوع يمين/يسار

    // مُنشئ يمرر القيم للـ VM
    init(subject: String, period: Period) {
        self.subject = subject
        self.period  = period
        _vm = StateObject(wrappedValue: ActivityViewModel(subject: subject, period: period))
    }

    // تاريخ الأساس حسب الإزاحة حول المرساة
    private var baseDate: Date {
        Calendar.current.date(byAdding: .day, value: weekOffset * 7, to: anchorDate) ?? anchorDate
    }

    // تجهيز خريطة السجلات لتمريرها لصفحة التقويم
    private var logsMapForCalendar: [Int: String] {
        var map: [Int: String] = [:]
        for log in vm.logs {
            map[log.yyyymmdd] = log.status.rawValue // "learned"/"frozen"
        }
        return map
    }

    // نطاق سنوات لاختيارها في الشيت
    private var yearRange: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 10)...(current + 10))
    }

    // هل اليوم مسجّل Learned؟
    private var didLogLearnedToday: Bool {
        let todayKey = Date().yyyymmddInt
        return vm.logs.contains(where: { $0.yyyymmdd == todayKey && $0.status == .learned })
    }

    // هل اليوم مسجّل Frozen؟
    private var didLogFrozenToday: Bool {
        let todayKey = Date().yyyymmddInt
        return vm.logs.contains(where: { $0.yyyymmdd == todayKey && $0.status == .frozen })
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) //التباعد بين الفقارات
            {

                // Header + Icons (نفس التصميم)
                HStack(spacing: 12)// الجزء العلوي
                {
                    Text("Activity")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    TopCircleButton(system: "calendar") { showCalendar = true }
                    TopCircleButton(system: "pencil.and.outline") { showLearningGoalView = true }
                }
                .padding(.horizontal, 20) ///تباعد افقي
                .padding(.top, 8)// العلوي

                // Calendar Card (بدون تغيير بصري)
                VStack(alignment: .leading, spacing: 12)// العناصر الي داخل المستطيل
                {
                    HStack(spacing: 10) // توسع افقي
                    {
                        Text(currentMonthYear(baseDate))
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))

                        // زر السهم لفتح اختيار الشهر/السنة
                        Button {
                            let comps = Calendar.current.dateComponents([.year, .month], from: baseDate)
                            selectedYear = comps.year ?? selectedYear
                            selectedMonthIndex = (comps.month ?? (selectedMonthIndex + 1)) - 1
                            showMonthYearPicker = true
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.orange)
                                .font(.system(size: 16, weight: .semibold))
                        }

                        Spacer()

                        Button {
                            withAnimation(.easeInOut) { weekOffset -= 1 }
                        } label: {
                            Image(systemName: "chevron.left").foregroundColor(.orange)
                        }
                        Button {
                            withAnimation(.easeInOut) { weekOffset += 1 }
                        } label: {
                            Image(systemName: "chevron.right").foregroundColor(.orange)
                        }
                    }

                    // Weekday names + days aligned في Grid بسبعة أعمدة
                    let cols = Array(repeating: GridItem(.flexible(), spacing: 14), count: 7)

                    LazyVGrid(columns: cols, spacing: 8) {
                        ForEach(weekdayShortNames(), id: \.self) { w in
                            Text(w)
                                .foregroundColor(.gray)
                                .font(.system(size: 12, weight: .medium))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 6)

                    LazyVGrid(columns: cols, spacing: 12) {
                        ForEach(weekStrip(from: baseDate), id: \.self) { day in
                            let isToday = Calendar.current.isDateInToday(day)
                            let label   = dayNumber(day)

                            let dayKey = day.yyyymmddInt
                            let status = vm.logs.first(where: { $0.yyyymmdd == dayKey })?.status

                            let fillColor: Color = {
                                if let status = status {
                                    switch status {
                                    case .learned: return .orange
                                    case .frozen:  return Color.blue.opacity(0.5)
                                    }
                                } else {
                                    return isToday ? Color("selectedBGstart") : Color.white.opacity(0.08)
                                }
                            }()

                            Circle()
                                .fill(fillColor)
                                .frame(height: 36)
                                .overlay(
                                    Text(label)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.horizontal, 6)

                    Divider().overlay(Color.white.opacity(1)) //لون السهم الي يفصل بين ارقام الايام

                    Text("Learning \(subject.isEmpty ? "Swift" : subject)")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))

                    // إحصائيات (نفس الشكل)
                    HStack(spacing: 14) {
                        StatPill(
                            leadingIcon: "flame.fill",
                            tint: .orange,
                            count: vm.learnedDays,
                            label: singular(vm.learnedDays) ? "Day Learned" : "Days Learned",
                            background: Color.brown.opacity(0.6) //لون الليرند
                        )
                        StatPill(
                            leadingIcon: "cube.fill",
                            tint: Color.cyan.opacity(0.9),
                            count: vm.frozenDays,
                            label: singular(vm.frozenDays) ? "Day Frozen" : "Days Frozen",
                            background: Color.blue.opacity(0.5) // لون الفروزن
                        )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial).opacity(0.6) // لون خلفيه المربع
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.4), lineWidth: 1))// لون الخط حول المربع
                )
                .padding(.horizontal, 16) // مقاسات المربع

                Spacer(minLength: 8) //التباعد بين المربع والي تحته

                // Log as Learned / Frozen (يتبدّل الشكل حسب حالة اليوم)
                Button(action: { vm.logAsLearned() }) {
                    ZStack {
                        // حالة Learned اليوم → خلفية برتقالية داخل الدائرة
                        if didLogLearnedToday {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.22), Color.orange.opacity(0.10)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 300, height: 300)
                                .overlay(glassyCircleBorder())
                                .mask(Circle().frame(width: 300, height: 300))
                        }

                        // حالة Frozen اليوم → خلفية زرقاء داخل الدائرة
                        if didLogFrozenToday {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.24), Color.blue.opacity(0.12)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 300, height: 300)
                                .overlay(glassyCircleBorder())
                                .mask(Circle().frame(width: 300, height: 300))
                        }

                        // الدائرة الأساسية حسب الحالة
                        if didLogLearnedToday {
                            // Learned: إطار زجاجي برتقالي (الخلفية شفافة)
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 300, height: 300)
                                .overlay(glassyCircleBorder())
                                .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 8)
                        } else if didLogFrozenToday {
                            // Frozen: إطار زجاجي أزرق (الخلفية شفافة)
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 300, height: 300)
                                .overlay(
                                    ZStack {
                                        // نعيد استخدام نفس الطبقات مع تلوين أزرق خفيف
                                        Circle().stroke(Color.white.opacity(0.14), lineWidth: 1)
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.26),
                                                        Color.white.opacity(0.08),
                                                        Color.clear
                                                    ],
                                                    startPoint: .top, endPoint: .bottom
                                                ),
                                                lineWidth: 2
                                            )
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.10),
                                                        Color.clear
                                                    ],
                                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                            .blendMode(.overlay)
                                        Circle()
                                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                                            .blur(radius: 1.2)
                                    }
                                )
                                .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 8)
                        } else {
                            // الشكل الأصلي قبل التسجيل
                            Circle()
                                .fill(Color("selectedBGend"))
                                .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
                                .overlay(glassyCircleBorder())
                                .shadow(color: .black.opacity(0.6), radius: 20, x: 0, y: 10)
                                .frame(width: 300, height: 300)
                        }

                        // النص داخل الدائرة حسب الحالة
                        if didLogFrozenToday {
                            Text("Day\nFreezed")
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .opacity(0.95)
                        } else {
                            Text("Learned\nToday")
                                .font(.system(size: 34, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .opacity(didLogLearnedToday ? 0.9 : 1)
                        }
                    }
                }
                .disabled(vm.isDisabledToday || vm.allFreezesUsed)
                .opacity(vm.isDisabledToday || vm.allFreezesUsed ? 0.5 : 1)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)

                // Log as Frozen
                Button(action: { vm.logAsFrozen() }) {
                    Text("Log as Frozen")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.blue.opacity(0.5))
                                .overlay(glassyRoundedBorder(cornerRadius: 28)) // ← حد زجاجي موحد
                        )
                }
                .disabled(vm.allFreezesUsed || vm.isDisabledToday)
                .opacity(vm.allFreezesUsed || vm.isDisabledToday ? 0.5 : 1)
                .padding(.horizontal, 28)

                // Footer
                Text("\(vm.frozenDays) out of \(vm.totalFreezes) \(vm.totalFreezes == 1 ? "Freeze" : "Freezes") used")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
            }
        }
        // NAV → Calendar
        .navigationDestination(isPresented: $showCalendar) {
            CalendarView(
                subject: subject,
                logs: logsMapForCalendar
            )
        }
        // NAV → LearningGoalView
        .navigationDestination(isPresented: $showLearningGoalView) {
            LearningGoalView()
        }
        // SHEET → Month/Year picker
        .sheet(isPresented: $showMonthYearPicker) {
            MonthYearPickerSheet(
                selectedYear: $selectedYear,
                selectedMonthIndex: $selectedMonthIndex,
                yearRange: yearRange,
                onConfirm: {
                    let comps = DateComponents(year: selectedYear, month: selectedMonthIndex + 1, day: 1)
                    if let firstDay = Calendar.current.date(from: comps) {
                        anchorDate = firstDay
                        weekOffset = 0
                    }
                    showMonthYearPicker = false
                },
                onCancel: { showMonthYearPicker = false }
            )
            .presentationDetents([.height(300)])
            .preferredColorScheme(.dark)
        }
        // ✅ شيت الإنهاء مع الأنيميشن (انقله هنا على ActivityView)
        .sheet(isPresented: $vm.showCompletionSheet) {
            GoalCompletionSheet(
                subject: subject,
                isPresented: $vm.showCompletionSheet,
                onNewGoal: { showLearningGoalView = true },
                onSameGoal: { vm.resetForNewGoal() }
            )
            .presentationDetents([.fraction(0.45)])
            .overlay(ConfettiView().allowsHitTesting(false))
            .preferredColorScheme(.dark)
        }
        // Lifecycle
        .onAppear {
            anchorDate = Calendar.current.startOfDay(for: Date())
            vm.enforceStreakRuleIfNeeded()
            vm.resetButtonsIfNewDay()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            vm.isDisabledToday = false // إعادة تفعيل الأزرار مع بداية يوم جديد
        }
        .onChange(of: vm.learnedDays) { _ in vm.save() }
        .onChange(of: vm.frozenDays)  { _ in vm.save() }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Helpers (نفسها لضمان عدم تغيير الشكل/السلوك)

private func singular(_ count: Int) -> Bool { count <= 1 } // 0 و1 = صيغة مفرد

private func currentMonthYear(_ date: Date = Date()) -> String {
    let f = DateFormatter(); f.dateFormat = "LLLL yyyy"; return f.string(from: date)
}

private func weekdayShortNames() -> [String] { ["SUN","MON","TUE","WED","THU","FRI","SAT"] }

private func weekStrip(from base: Date = Date()) -> [Date] {
    var cal = Calendar(identifier: .gregorian); cal.firstWeekday = 1 // Sunday
    let startOfDay = cal.startOfDay(for: base)
    let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfDay)
    let weekStart = cal.date(from: comps)! // بداية الأسبوع
    return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: weekStart) }
}

private func dayNumber(_ date: Date) -> String {
    let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: date)
}

private struct TopCircleButton: View {
    let system: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
                .overlay(glassyCircleBorder())
        }
    }
}

private struct StatPill: View {
    let leadingIcon: String
    let tint: Color
    let count: Int
    let label: String
    let background: Color
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: leadingIcon).foregroundColor(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)").foregroundColor(.white).font(.system(size: 20, weight: .bold))
                Text(label).foregroundColor(.white.opacity(0.85)).font(.system(size: 13))
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14).padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(background)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }
}

// Sheet لاختيار الشهر/السنة (نفس التصميم مع callbacks)
private struct MonthYearPickerSheet: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonthIndex: Int
    let yearRange: [Int]
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Select month & year")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold))

            HStack(spacing: 0) {
                Picker("Month", selection: $selectedMonthIndex) {
                    ForEach(0..<12, id: \.self) { idx in
                        Text(monthName(idx)).tag(idx)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Year", selection: $selectedYear) {
                    ForEach(yearRange, id: \.self) { y in
                        Text("\(y)").tag(y)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .foregroundColor(.white)

            HStack(spacing: 12) {
                Button("Cancel") { onCancel() }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)

                Button("Go") { onConfirm() }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.cornerRadius(12))
            }
            .padding(.top, 6)

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    private func monthName(_ index: Int) -> String {
        let f = DateFormatter()
        return f.monthSymbols[index]
    }
    // ✅ تمت إزالة الـ .sheet الخاطئة من هنا
}
// MARK: - Goal Completion Sheet
struct GoalCompletionSheet: View {
    var subject: String
    @Binding var isPresented: Bool
    var onNewGoal: () -> Void
    var onSameGoal: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)

            Image(systemName: "hands.and.sparkles.fill")
                .font(.system(size: 50))
                .foregroundColor(Color.orange)
                .foregroundColor(Color("selectedBGend"))

            Text("Well done!")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)

            Text("You completed your \(subject) goal 🎉")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button {
                // أغلق الشيت أولاً، ثم نفّذ الإجراء المطلوب
                isPresented = false
                onNewGoal()
            } label: {
                Text("Set new learning goal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color("selectedBGstart"), Color("selectedBGend")],
                            startPoint: .top, endPoint: .bottom
                        )
                        .cornerRadius(30)
                    )
            }
            .padding(.horizontal, 28)

            Button {
                // أغلق الشيت أولاً، ثم أعد نفس الهدف
                isPresented = false
                onSameGoal()
            } label: {
                Text("Set same goal again")
                    .foregroundColor(Color("selectedBGend"))
                    .font(.system(size: 15, weight: .medium))
                    .padding(.bottom, 20)
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}


// تحويل التاريخ إلى عدد صحيح لتطابق الـ ViewModel
#Preview {
    ActivityView(subject: "Swift", period: .week)
}
