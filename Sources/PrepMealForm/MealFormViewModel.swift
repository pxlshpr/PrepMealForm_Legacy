import SwiftUI
import PrepDataTypes

public class MealFormViewModel: ObservableObject {
    
    let date: Date
    
    let recents: [String]
    let presets: [String]

    @Published var name = ""
    @Published var time: Date
    
    @Published var goalSet: GoalSet?
    
    let didSave: (String, Date, GoalSet?) -> ()
    let getTimelineItemsHandler: GetTimelineItemsHandler?

    public init(
        date: Date = Date(),
        name: String = "",
        recents: [String] = [],
        presets: [String]? = nil,
        getTimelineItemsHandler: GetTimelineItemsHandler? = nil,
        didSave: @escaping (String, Date, GoalSet?) -> ()
    ) {
        self.date = date
        self.recents = recents
        self.presets = presets ?? Presets
        self.time = date
        self.name = name
        self.didSave = didSave
        self.getTimelineItemsHandler = getTimelineItemsHandler
    }
    
}

extension MealFormViewModel {
    func didTapTimeButton(
        increment: Int? = nil,
        decrement: Int? = nil
    ) {
        let interval: TimeInterval
        if let increment = increment {
            interval = TimeInterval(increment)
        } else if let decrement = decrement {
            interval = TimeInterval(-decrement)
        } else {
            interval = 0
        }
        let newTime = time.addingTimeInterval(interval * 60)
        self.time = newTime
//            self.pickerTime = newTime
    }
    
    var dateRangeForPicker: ClosedRange<Date> {
        let start = date.startOfDay
        let end = date.moveDayBy(1).atEndOfWeeHours
        return start...end
    }
    
    var timeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                return self.time
            },
            set: { newValue in
                self.time = newValue
            }
        )
    }
    
    var timeString: String {
        if time.startOfDay == Date().startOfDay {
            return "Today \(time.shortTimeString)"
        } else {
            return time.shortString
        }
    }
    
    func tappedAdd() {
        didSave(name, time, goalSet)
    }
    
    var shouldShowDurationPicker: Bool {
        guard let goalSet else { return false }
        return goalSet.containsWorkoutDurationDependentGoal
    }
}

let Presets = ["Breakfast", "Lunch", "Dinner", "Pre-workout Meal", "Post-workout Meal", "Intra-workout Snack", "Snack", "Dinner Out", "Supper", "Midnight Snack"]
