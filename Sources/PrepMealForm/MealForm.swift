import SwiftUI
import SwiftUISugar
import PrepDataTypes

public struct MealForm: View {

    @Environment(\.colorScheme) var colorScheme
    
    let date: Date
    let existingMealTimes: [Date]
    @State var name: String = ""
    
    @State var time: Date = Date()
    @State var lastTime: Date = Date()
    
    public init(
        mealBeingEdited: DayMeal? = nil,
        date: Date,
        recents: [String] = [],
        presets: [String]? = nil,
        existingMealTimes: [Date] = [],
        getTimelineItemsHandler: GetTimelineItemsHandler? = nil,
        didSave: @escaping (String, Date, GoalSet?) -> ()
    ) {
        self.date = date
        self.existingMealTimes = existingMealTimes
//        let viewModel = MealFormViewModel(
//            mealBeingEdited: mealBeingEdited,
//            date: date,
//            recents: recents,
//            presets: presets,
//            getTimelineItemsHandler: getTimelineItemsHandler,
//            didSave: didSave
//        )
//
//        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        quickForm
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.hidden)
            .onChange(of: time, perform: timeChanged)
    }
    
    var quickForm: some View {
        QuickForm(title: "New Meal") {
            FormStyledSection {
                Grid(alignment: .leading) {
                    GridRow {
                        Text("Name")
                            .foregroundColor(.secondary)
                        fieldButton(name, isRequired: true) {
                        }
                    }
                    GridRow {
                        Text("Time")
                            .foregroundColor(.secondary)
                        DatePicker(
                            "",
                            selection: $time,
//                            in: viewModel.dateRangeForPicker,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
//                        .onChange(of: viewModel.time, perform: onChangeOfTime)
//                        .id(refreshDatePicker)
                    }
                    GridRow {
                        TimeSlider(
                            date: self.date,
                            existingTimeSlots: existingTimeSlots,
                            currentTime: $time,
                            currentTimeSlot: currentTimeSlot
                        )
                            .gridCellColumns(2)
                    }
                }
            }
            saveButton
        }
    }
    
    func nearestAvailableTimeSlot(to timeSlot: Int) -> Int? {
        
        func timeSlotIsAvailable(_ timeSlot: Int) -> Bool {
            timeSlot != self.currentTimeSlot && !existingTimeSlots.contains(timeSlot)
        }
        
        /// First search forwards till the end
        for t in timeSlot..<K.numberOfSlots {
            if timeSlotIsAvailable(t) {
                return t
            }
        }
        /// If we still haven't find one, go backwards
        for t in (0..<timeSlot-1).reversed() {
            if timeSlotIsAvailable(t) {
                return t
            }
        }
        return nil
    }
    
    var currentTimeSlot: Int {
        time.timeSlot(within: date)
    }
    
    var existingTimeSlots: [Int] {
        existingMealTimes.map {
            $0.timeSlot(within: date)
        }
    }
    
    func timeChanged(_ newTime: Date) {
        let timeSlot = newTime.timeSlot(within: date)
        if existingTimeSlots.contains(timeSlot) {
            guard let nearestAvailable = nearestAvailableTimeSlot(to: timeSlot) else {
                self.time = lastTime
                return
            }
            self.time = date.timeForTimeSlot(nearestAvailable)
        }
    }
    
    var saveButton: some View {
        var confirmationActions: some View {
            Button("Save", role: .destructive) {
//                saveAction.handler()
//                cancelAction.handler()
            }
        }

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
        
        var saveIsDisabled: Bool {
            name.isEmpty
        }
        
        var shadowSize: CGFloat {
            2
        }

        return Button {
        } label: {
            Text("Save")
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
