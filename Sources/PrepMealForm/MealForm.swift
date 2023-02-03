import SwiftUI
import SwiftUISugar
import PrepDataTypes

public struct MealForm: View {

    public init(
        mealBeingEdited: DayMeal? = nil,
        date: Date,
        recents: [String] = [],
        presets: [String]? = nil,
        getTimelineItemsHandler: GetTimelineItemsHandler? = nil,
        didSave: @escaping (String, Date, GoalSet?) -> ()
    ) {
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
        QuickForm(title: "New Meal") {
            Text("here we go")
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.hidden)
    }
}
