import SwiftUI
import SwiftHaptics
import Timeline
import SwiftSugar

struct TimeForm: View {
    
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel = ViewModel()
    
    let name: String
    let date: Date
    @Binding var time: Date
    @State var pickerTime: Date
    @StateObject var newMeal: TimelineItem

    init(name: String, time: Binding<Date>, date: Date) {
        self.date = date
        self.name = name
        _time = time
        _pickerTime = State(initialValue: time.wrappedValue)
        
        let newMeal = TimelineItem(id: UUID().uuidString,
                                   name: name,
                                   date: time.wrappedValue,
                                   type: .meal,
                                   isNew: true)
        _newMeal = StateObject(wrappedValue: newMeal)
    }
    
    var body: some View {
        timeline
//            .background(Color(.tertiarySystemGroupedBackground))
            .toolbar { bottomToolbarContent }
//            .toolbar { navigationTrailingContent }
            .toolbar { navigationLeadingContent }
//            .navigationTitle("Time:")
//            .toolbar { navigationTitleContent }
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: pickerTime) { newValue in
                attemptToChangeTimeTo(newValue)
            }
            .onChange(of: time) { newValue in
                withAnimation {
                    newMeal.date = newValue
                }
            }
            .onChange(of: viewModel.time) { newValue in
                attemptToChangeTimeTo(newValue)
                Haptics.feedback(style: .soft)
//                time = newValue
            }
    }
    
    var timelineItems: [TimelineItem] {
        //TODO: CoreData
        []
//        Store.timelineItems(for: pagerController.currentDate)
    }
    
    var timeline: some View {
        Timeline(
            items: timelineItems,
            newItem: newMeal,
            delegate: viewModel
        )
        .background(Color(.systemGroupedBackground))
    }
    
    //MARK: - UI Components
//    var navigationTrailingContent: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
//            if pagerController.currentDateIsToday {
//                nowButton
//            }
//        }
//    }
    
    var navigationTitleContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            datePicker
        }
    }

    var navigationLeadingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            timePicker
        }
    }

    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
//            ZStack {
//                HStack {
//                    button(decrement: 60)
//                    button(decrement: 15)
//                    Spacer()
//                }
//                HStack {
//                    Spacer()
//                    button(increment: 15)
//                    button(increment: 60)
//                }
//                HStack {
//                    Spacer()
//                    Button("Now") {
//                        attemptToChangeTimeTo(Date())
//                    }
//                    Spacer()
//                }
//            }
            button(decrement: 60, hapticStyle: .heavy)
            button(decrement: 15)
            Text("•")
                .foregroundColor(Color(.quaternaryLabel))
            button(increment: 15)
            button(increment: 60, hapticStyle: .heavy)
            Spacer()
            if !time.isNowToTheMinute {
                nowButton
            }
        }
    }
    
    var nowButton: some View {
        Button("Now") {
            Haptics.successFeedback()
            attemptToChangeTimeTo(Date())
        }
//        Button {
//            attemptToChangeTimeTo(Date())
////            time = Date()
////            viewModel.time = time
//            Haptics.feedback(style: .soft)
//        } label: {
//            Text("Now")
////            Image(systemName: "clock")
////                .font(.title2)
////                .padding(.horizontal, 7)
//        }
//        .buttonStyle(BorderlessButtonStyle())
    }
    
    func button(increment: Int? = nil, decrement: Int? = nil, hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .soft) -> some View {
        Button {
            let interval: TimeInterval
            if let increment = increment {
                interval = TimeInterval(increment)
            } else if let decrement = decrement {
                interval = TimeInterval(-decrement)
            } else {
                interval = 0
            }
            attemptToChangeTimeTo(time.addingTimeInterval(interval * 60))
//            time = time.addingTimeInterval(interval * 60)
//            viewModel.time = time
            Haptics.feedback(style: hapticStyle)
        } label: {
            let systemName: String
            if let increment = increment {
                systemName = "goforward.\(increment)"
            } else if let decrement = decrement {
                systemName = "gobackward.\(decrement)"
            } else {
                systemName = "questionmark.circle"
            }
            return Image(systemName: systemName)
                .font(.title2)
                .padding(.horizontal, 7)
//                .padding(3)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    var datePicker: some View {
        let start = date.startOfDay
        let end = date.moveDayBy(1).atEndOfWeeHours
        let range = start...end
        return DatePicker(
            "",
            selection: $pickerTime,
            in: range,
            displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
        .labelsHidden()
    }
    
    var timePicker: some View {
        let start = date.startOfDay
        let end = date.moveDayBy(1).atEndOfWeeHours
        let range = start...end
        return DatePicker("",
                   selection: $pickerTime,
                   in: range,
                   displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
            .labelsHidden()
    }
}

//MARK: - ViewModel

//MARK: - Extensions

//TODO: CoreData
//extension Store {
//    static func timelineItems(for date: Date) -> [TimelineItem] {
//        /// get meals
//        let meals = Self.shared.meals(on: date)
//        var timelineItems = meals.map { meal in
//            TimelineItem(id: (meal.id ?? UUID()).uuidString,
//                         name: meal.nameString,
//                         date: meal.timeDate,
//                         emojis: meal.timelineEmojis,
//                         type: .meal)
//        }
//
//        /// Get and create TimelineItems from workouts
//        let workouts = Self.workouts(onDate: date)
//        timelineItems.append(contentsOf: workouts.map({ workout in
//            TimelineItem(id: (workout.id ?? UUID()).uuidString,
//                         name: workout.name ?? "Workout",
//                         date: workout.startDate,
//                         duration: TimeInterval(workout.duration),
//                         emojiStrings: [workout.emoji],
//                         type: .workout)
//        }))
//
//        return timelineItems
//    }
//}

