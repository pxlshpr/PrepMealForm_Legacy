import SwiftUI
import SwiftUISugar
import PrepDataTypes
import SwiftHaptics
import PrepCoreDataStack

public typealias ExistingMealTimesFunction = ((Date) async throws -> [Date])

public struct MealForm: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let date: Date
    let existingMeal: DayMeal?
    
    @State var name: String
    @State var time: Date = Date()
    
    @State var showingNameForm = false
    @State var showingTimeForm = false

    let existingMealTimesFunction: ExistingMealTimesFunction?
    @State var existingMealTimes: [Date] = []

    let didSaveMeal: (String, Date, GoalSet?) -> ()
    
    public init(
        existingMeal: DayMeal? = nil,
        date: Date,
        recents: [String] = [],
        presets: [String]? = nil,
        existingMealTimesFunction: ExistingMealTimesFunction? = nil,
        didSaveMeal: @escaping (String, Date, GoalSet?) -> ()
    ) {
        self.date = date
        self.existingMealTimesFunction = existingMealTimesFunction
        self.existingMeal = existingMeal
        self.didSaveMeal = didSaveMeal
        
        if let existingMeal {
            _name = State(initialValue: existingMeal.name)
            _time = State(initialValue: Date(timeIntervalSince1970: existingMeal.time))
        } else {
            let time = newMealTime(for: date)
            _name = State(initialValue: newMealName(for: time))
            _time = State(initialValue: time)
        }
    }

    public var body: some View {
        quickForm
            .presentationDetents([.height(370)])
            .presentationDragIndicator(.hidden)
            .sheet(isPresented: $showingNameForm) { nameForm }
            .task { getExistingMealTimes() }
            .sheet(isPresented: $showingTimeForm) { timeForm }
    }
    
    func getExistingMealTimes() {
        guard let existingMealTimesFunction else { return }
        Task {
            let existingMealTimes = try await existingMealTimesFunction(date)
            await MainActor.run {
                self.existingMealTimes = existingMealTimes
                if existingMeal == nil {
                    /// We're assuming that the fetch of the existing meals happens quickly enough that
                    /// `time` hasn't been changed yet—if it ends up taking long enough for the user to make
                    /// a change, only do this if the user hasn't changed the value already.
                    self.time = newMealTime(for: date, existingMealTimes: existingMealTimes)
                }
            }
        }
    }

    
    var nameForm: some View {
        NameForm(name: $name)
    }
    
    var timeForm: some View {
        TimeForm(
            date: date,
            time: $time,
            existingMealTimes: $existingMealTimes
        )
    }

    var quickForm: some View {
        QuickForm(
            title: existingMeal == nil ? "New Meal" : "Edit Meal",
            deleteAction: deleteActionBinding
        ) {
            nameCell
            timeCell
//            legacySection
            saveButton
        }
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }

    var nameCell: some View {
        var label: some View {
            ZStack {
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Spacer().frame(width: 2)
                            HStack(spacing: 4) {
                                Text("Name")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                            Spacer()
                            disclosureArrow
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            if !name.isEmpty {
                                Text(name)
                                    .foregroundColor(.primary)
                                    .font(.system(size: 28, weight: .medium, design: .rounded))
                            } else {
                                Text("Required")
                                    .foregroundColor(Color(.tertiaryLabel))
                                    .font(.system(size: 28, weight: .medium, design: .rounded))
                            }
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 13)
            .padding(.top, 13)
    //        .background(Color(.secondarySystemGroupedBackground))
            .background(FormCellBackground())
            .cornerRadius(10)
            .padding(.bottom, 10)
            .padding(.horizontal, 20)
        }
        
        return Button {
            Haptics.feedback(style: .soft)
            showingNameForm = true
        } label: {
            label
        }
    }

    var timeCell: some View {
        var label: some View {
            var timeString: String {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm"
                return formatter.string(from: time)
            }
            
            var amPmString: String {
                let formatter = DateFormatter()
                formatter.dateFormat = "a"
                return formatter.string(from: time).lowercased()
            }
            
            return ZStack {
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Spacer().frame(width: 2)
                            HStack(spacing: 4) {
                                Text("Time")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                            Spacer()
                            disclosureArrow
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text(timeString)
                                .foregroundColor(.primary)
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                            Text(amPmString)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .bold()
                                .foregroundColor(Color(.secondaryLabel))
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 13)
            .padding(.top, 13)
    //        .background(Color(.secondarySystemGroupedBackground))
            .background(FormCellBackground())
            .cornerRadius(10)
            .padding(.bottom, 10)
            .padding(.horizontal, 20)
        }
        
        return Button {
            Haptics.feedback(style: .soft)
            showingTimeForm = true
        } label: {
            label
        }
    }

//    var legacySection: some View {
//        FormStyledSection {
//            Grid(alignment: .leading) {
//                GridRow {
//                    Text("Name")
//                        .foregroundColor(.secondary)
//                    fieldButton(name, isRequired: true) {
//                        Haptics.feedback(style: .soft)
//                        showingNameForm = true
//                    }
//                }
//                GridRow {
//                    Text("Time")
//                        .foregroundColor(.secondary)
//                    datePicker
//                }
//                GridRow {
//                    timeSlider
//                        .gridCellColumns(2)
//                }
//            }
//        }
//    }
    
    var deleteActionBinding: Binding<FormConfirmableAction?> {
        Binding<FormConfirmableAction?>(
            get: {
                guard existingMeal != nil else {
                    return nil
                }
                return FormConfirmableAction(
                    shouldConfirm: true,
                    confirmationMessage: "Are you sure you want to delete this meal?",
                    confirmationButtonTitle: "Delete Meal",
                    isDisabled: false,
                    buttonImage: "trash.fill",
                    handler: {
                        guard let existingMeal else {
                            return
                        }
                        do {
                            try DataManager.shared.deleteMeal(existingMeal)
                        } catch {
                            print("Couldn't delete meal: \(error)")
                        }
                    }
                )
            },
            set: { _ in }
        )
    }

    func tappedSave() {
        /// This is to ensure that the date picker is dismissed if a confirmation button
        /// is tapped while it's presented (otherwise causing the dismissal to fail)
        Haptics.successFeedback()
        didSaveMeal(name, time, nil)
        dismiss()
    }
    
    var saveIsDisabled: Bool {
        if name.isEmpty {
            return true
        }
        
        if let existingMeal {
            if existingMeal.name == name
                && existingMeal.timeDate.equalsIgnoringSeconds(time) {
                return true
            }
        }
        
        return false
    }
    
    var saveButton: some View {
        var buttonWidth: CGFloat {
            UIScreen.main.bounds.width - (20 * 2.0)
        }
        
        var xPosition: CGFloat {
            UIScreen.main.bounds.width / 2.0
        }
        
        var yPosition: CGFloat {
            (52.0/2.0) + 16.0
        }
        
        var shadowOpacity: CGFloat {
            0
        }
        
        var buttonHeight: CGFloat {
            52
        }
        
        var buttonCornerRadius: CGFloat {
            10
        }
        
        var shadowSize: CGFloat {
            2
        }

        return Button {
            tappedSave()
        } label: {
            Text(existingMeal == nil ? "Add" : "Save")
                .bold()
                .foregroundColor((colorScheme == .light && saveIsDisabled) ? .black : .white)
                .frame(width: buttonWidth, height: buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .foregroundStyle(Color.accentColor.gradient)
                    //                    .foregroundColor(.accentColor)
                        .shadow(color: Color(.black).opacity(shadowOpacity), radius: shadowSize, x: 0, y: shadowSize)
                )
        }
        .buttonStyle(.borderless)
        .position(x: xPosition, y: yPosition)
        .disabled(saveIsDisabled)
        .opacity(saveIsDisabled ? (colorScheme == .light ? 0.2 : 0.2) : 1)
    }
    
    func fieldButton(_ string: String, isRequired: Bool = false, action: @escaping () -> ()) -> some View {
        let fill: Color = colorScheme == .light
        ? Color(hex: "EFEFF0")
        : Color(.secondarySystemFill)
        
        return Button {
//            Haptics.feedback(style: .soft)
            action()
        } label: {
            Text(!string.isEmpty ? string : (isRequired ? "Required" : "Optional"))
                .foregroundColor(!string.isEmpty ? .primary : Color(.tertiaryLabel))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(fill)
                )
        }
    }
}

public func newMealTime(for date: Date, existingMealTimes: [Date] = []) -> Date {
    if date.isToday {
        return Date()
    } else {
        return date.h(12, m: 0, s: 0)
    }
}
