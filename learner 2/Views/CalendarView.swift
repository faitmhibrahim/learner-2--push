import SwiftUI

// MARK: - CalendarView (نفس الشكل والوظائف مع تعليقات توضيحية)
struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss  // للوصول لزر الرجوع

    // بيانات يتم تمريرها من ActivityView
    var subject: String = ""                     // اسم الهدف (للعنوان فقط)
    // مفتاح اليوم yyyymmdd -> "learned" | "frozen"
    var logs: [Int: String] = [:]                // نستخدمه لتلوين الأيام

    private let calendar = Calendar(identifier: .gregorian)

    // نطاق السنوات المتاحة للاختيار
    private let yearRange: [Int] = {
        let current = Calendar(identifier: .gregorian).component(.year, from: Date())
        return Array((current - 10)...(current + 10))
    }()

    // الأشهر الإثنا عشر لسنة معينة
    private func months(for year: Int) -> [Date] {
        let cal = calendar
        let startOfYear = cal.date(from: DateComponents(year: year, month: 1, day: 1))!
        return (0..<12).compactMap { cal.date(byAdding: .month, value: $0, to: startOfYear) }
    }

    // الحالة لاختيار السنة/الشهر
    @State private var showMonthYearPicker = false
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonthIndex: Int = Calendar.current.component(.month, from: Date()) - 1 // 0..11

    private let cols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        HStack(spacing: 10) {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(width: 36, height: 36)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .overlay(glassyCircleBorder())
                            }
                            Text("All activities\(subject.isEmpty ? "" : " • \(subject)")")
                                .foregroundColor(.white)
                                .font(.system(size: 26, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        // شريط سريع لاختيار الشهر/السنة الحالية
                        HStack(spacing: 8) {
                            Text("\(monthTitle(forMonthIndex: selectedMonthIndex)) \(selectedYear)")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 16, weight: .semibold))
                            Button { showMonthYearPicker = true } label: {
                                Image(systemName: "chevron.down").foregroundColor(.orange)
                            }
                            Spacer()
                            Button("Go") {
                                let target = dateFor(monthIndex: selectedMonthIndex, year: selectedYear)
                                withAnimation(.easeInOut) { proxy.scrollTo(monthID(for: target), anchor: .top) }
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(glassyRoundedBorder(cornerRadius: 12))
                            )
                        }
                        .padding(.horizontal, 16)

                        // عرض الأشهر عبر السنوات
                        ForEach(yearRange, id: \.self) { year in
                            ForEach(months(for: year), id: \.self) { monthDate in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(monthTitle(for: monthDate))
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .semibold))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)

                                    // أسماء الأيام
                                    LazyVGrid(columns: cols, spacing: 8) {
                                        ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { w in
                                            Text(w)
                                                .foregroundColor(.gray)
                                                .font(.system(size: 12, weight: .medium))
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.horizontal, 16)

                                    // الشبكة اليومية
                                    LazyVGrid(columns: cols, spacing: 10) {
                                        ForEach(gridDays(for: monthDate), id: \.self) { value in
                                            if value == 0 {
                                                Circle().fill(Color.clear).frame(height: 36)
                                            } else {
                                                let dayDate = dateFor(day: value, in: monthDate)
                                                let dayKey  = dayDate.yyyymmddInt
                                                let status  = logs[dayKey]

                                                let fillColor: Color = {
                                                    switch status {
                                                    case "learned": return .orange
                                                    case "frozen":  return Color.blue.opacity(0.5)
                                                    default:        return Color.white.opacity(0.08)
                                                    }
                                                }()

                                                Circle()
                                                    .fill(fillColor)
                                                    .frame(height: 36)
                                                    .overlay(
                                                        Text("\(value)")
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 15, weight: .semibold))
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)

                                    Divider().overlay(Color.white.opacity(0.06))
                                        .padding(.horizontal, 16)
                                }
                                .id(monthID(for: monthDate)) // مهم للتمرير
                            }
                        }
                        Spacer(minLength: 40)
                    }
                }
                .onAppear {
                    let target = dateFor(monthIndex: selectedMonthIndex, year: selectedYear)
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) { proxy.scrollTo(monthID(for: target), anchor: .top) }
                    }
                }
            }
        }
        .sheet(isPresented: $showMonthYearPicker) {
            MonthYearPickerSheet(
                selectedYear: $selectedYear,
                selectedMonthIndex: $selectedMonthIndex,
                yearRange: yearRange
            )
            .presentationDetents([.height(300)])
            .preferredColorScheme(.dark)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - تنسيقات مساعدة
    private func monthTitle(for date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "LLLL yyyy"; return f.string(from: date)
    }
    private func monthTitle(forMonthIndex index: Int) -> String {
        let f = DateFormatter(); return f.monthSymbols[index]
    }
    private func gridDays(for month: Date) -> [Int] {
        var cal = calendar; cal.firstWeekday = 1 // Sunday
        guard let range = cal.range(of: .day, in: .month, for: month),
              let first = cal.date(from: cal.dateComponents([.year, .month], from: month)) else { return [] }
        let firstW = cal.component(.weekday, from: first) // 1..7
        let leading = (firstW - cal.firstWeekday + 7) % 7
        let days = Array(range)
        return Array(repeating: 0, count: leading) + days
    }
    private func dateFor(day: Int, in month: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: month)
        return calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: day)) ?? month
    }
    private func dateFor(monthIndex: Int, year: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1))!
    }
    private func monthID(for date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return "\(comps.year ?? 0)-\(comps.month ?? 0)"
    }
}

private struct MonthYearPickerSheet: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonthIndex: Int
    let yearRange: [Int]

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

            Text("Press Go in the header to jump")
                .foregroundColor(.gray)
                .font(.system(size: 13))

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    private func monthName(_ index: Int) -> String {
        let f = DateFormatter(); return f.monthSymbols[index]
    }
}

// تحويل التاريخ إلى Int
#Preview {
    CalendarView(subject: "Swift", logs: [:])
}
