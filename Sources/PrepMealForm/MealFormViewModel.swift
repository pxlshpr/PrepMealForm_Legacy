import SwiftUI
import PrepDataTypes

public class MealFormViewModel: ObservableObject {
    
    let mealBeingEdited: DayMeal?
    let date: Date
    
    let recents: [String]
    let presets: [String]

    @Published var name = ""
    @Published var time: Date
    
    @Published var goalSet: GoalSet?
    
    let didSave: (String, Date, GoalSet?) -> ()
    let getTimelineItemsHandler: GetTimelineItemsHandler?

    public init(
        mealBeingEdited: DayMeal?,
        date: Date,
        recents: [String] = [],
        presets: [String]? = nil,
        getTimelineItemsHandler: GetTimelineItemsHandler? = nil,
        didSave: @escaping (String, Date, GoalSet?) -> ()
    ) {
        /// Keep in mind that this could be the day before what is indicated in `time`
        /// if we're adding a meal in the wee-hours
        self.date = date
        self.mealBeingEdited = mealBeingEdited
        
        if let mealBeingEdited {
            self.time = Date(timeIntervalSince1970: mealBeingEdited.time)
            self.name = mealBeingEdited.name
        } else {
            self.time = date
            self.name = newMealName(for: date)
        }
        
        self.recents = recents
        self.presets = presets ?? Presets
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
    
    var isEditing: Bool {
        mealBeingEdited != nil
    }
    
    var navigationTitle: String {
        isEditing ? "Edit Meal" : "Add Meal"
    }
    
    var saveButtonTitle: String {
        isEditing ? "Save" : "Add"
    }
    
    var isDirty: Bool {
        
        guard let mealBeingEdited else {
            return !name.isEmpty
        }
        return (mealBeingEdited.name != name && !name.isEmpty)
        || mealBeingEdited.time != time.timeIntervalSince1970
        || mealBeingEdited.goalSet?.id != goalSet?.id
    }
    
    var shouldDisableInteractiveDismiss: Bool {
        guard let mealBeingEdited else {
            return false
        }
        return isDirty
    }
}

let Presets = ["Breakfast", "Lunch", "Dinner", "Pre-workout Meal", "Post-workout Meal", "Intra-workout Snack", "Snack", "Dinner Out", "Supper", "Midnight Snack"]
