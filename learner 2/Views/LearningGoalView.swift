import SwiftUI

// MARK: - LearningGoalView (الواجهة فقط — المنطق في LearningGoalViewModel)
struct LearningGoalView: View {
    @StateObject private var vm = LearningGoalViewModel() // حالة الصفحة تنتقل للـ VM

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    // العنوان
                    Text("Update Learning Goal")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 30)
                        .padding(.horizontal, 24)

                    // حقل "I want to learn"
                    Text("I want to learn")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding(.horizontal, 28)

                    VStack(spacing: 4) {
                        TextField("Enter subject", text: $vm.subject) // ← ربط بالـ VM
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 8)
                            .background(Color.clear)

                        Rectangle()
                            .fill(Color.gray.opacity(0.35))
                            .frame(height: 1)
                            .padding(.horizontal, 28)
                    }

                    // حقل المدة
                    Text("I want to learn it in a")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding(.horizontal, 28)
                        .padding(.top, 10)

                    HStack(spacing: 14) {
                        ForEach(Period.allCases) { period in
                            PeriodButton(title: period.rawValue, isSelected: vm.selectedPeriod == period) {
                                vm.selectedPeriod = period
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 4)

                    Spacer()

                    // زر الحفظ بحد زجاجي
                    HStack {
                        Spacer()
                        Button {
                            vm.onTapSave() // ← المنطق في الـ VM
                        } label: {
                            Text("Save goal")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(.thinMaterial)
                                        .overlay(glassyRoundedBorder(cornerRadius: 28))
                                )
                        }
                        Spacer()
                    }
                    .padding(.bottom, 40)

                    NavigationLink(
                        destination: ActivityView(subject: vm.subject, period: vm.selectedPeriod),
                        isActive: $vm.navigateToActivity
                    ) { EmptyView() }
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $vm.showConfirmationSheet) {
                ConfirmationSheet(
                    subject: $vm.subject,
                    selectedPeriod: $vm.selectedPeriod,
                    navigateToActivity: $vm.navigateToActivity,
                    showConfirmationSheet: $vm.showConfirmationSheet
                )
                .presentationDetents([.fraction(0.35)])
            }
        }
    }
}

// MARK: - الـ Sheet (نفس الشكل) مع حدود زجاجية للأزرار
struct ConfirmationSheet: View {
    @Binding var subject: String
    @Binding var selectedPeriod: Period
    @Binding var navigateToActivity: Bool
    @Binding var showConfirmationSheet: Bool

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Text("Update Learning goal")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)

            Text("If you update now, your streak will start over.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .font(.system(size: 15))
                .padding(.horizontal)

            HStack(spacing: 18) {
                Button("Dismiss") {
                    showConfirmationSheet = false
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.06))
                        .overlay(glassyRoundedBorder(cornerRadius: 16))
                )

                Button("Update") {
                    showConfirmationSheet = false
                    navigateToActivity = true
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange)
                        .overlay(glassyRoundedBorder(cornerRadius: 16))
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    LearningGoalView()
}
