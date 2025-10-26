import SwiftUI

// MARK: - AllActivitiesView (واجهة عرض أشهر متعددة — بدون VM)
struct AllActivitiesView: View {
    private let calendar = Calendar.current
    private let currentDate = Date()

    // الأشهر الثلاثة (السابق، الحالي، التالي)
    private var displayedMonths: [Date] {
        (-1...1).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: currentDate)
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // Header
                    HStack {
                        Button(action: { }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                        }
                        Text("All activities")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 4)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // الأشهر
                    ForEach(displayedMonths, id: \.self) { monthDate in
                        MonthCalendarView(monthDate: monthDate)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    let monthDate: Date
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // الأحد بداية الأسبوع
        return cal
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: monthDate)
    }

    private let cols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private var weekdayHeaders: [String] { ["SUN","MON","TUE","WED","THU","FRI","SAT"] }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // عنوان الشهر
            Text(monthName.capitalized)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            // عناوين الأيام
            LazyVGrid(columns: cols, spacing: 8) {
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)

            // الأيام
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(gridDays(for: monthDate), id: \.self) { value in
                    if value == 0 {
                        Circle().fill(Color.clear).frame(height: 36)
                    } else {
                        let comps = calendar.dateComponents([.year, .month], from: monthDate)
                        let date = calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: value)) ?? monthDate
                        let isToday = calendar.isDateInToday(date)

                        Circle()
                            .fill(isToday ? .white : Color.white.opacity(0.08))
                            .frame(height: 36)
                            .overlay(
                                Text("\(value)")
                                    .foregroundColor(isToday ? .black : .white)
                                    .font(.system(size: 15, weight: .semibold))
                            )
                    }
                }
            }
            .padding(.horizontal, 16)

            Divider()
                .overlay(Color.white.opacity(0.1))
                .padding(.horizontal, 16)
        }
    }

    private func gridDays(for month: Date) -> [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        let firstW = calendar.component(.weekday, from: first) // 1..7
        let leading = (firstW - calendar.firstWeekday + 7) % 7
        let days = Array(range)
        return Array(repeating: 0, count: leading) + days
    }
}

#Preview {
    AllActivitiesView()
}
