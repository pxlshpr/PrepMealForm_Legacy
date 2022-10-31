import SwiftUI
import SwiftHaptics
import NamePicker
import SwiftUISugar

public struct MealForm: View {

    @Environment(\.dismiss) var dismiss
    @State var name = ""
    @State var time: Date
    @State var path: [Route] = []

    let date: Date
    let recents: [String]
    let presets: [String]

    public init(
        date: Date = Date(),
        name: String = "",
        recents: [String] = [],
        presets: [String] = []
    ) {
        self.date = date
        self.recents = recents
        self.presets = presets

        //TODO: We need to assign time here based on the date provided
        _time = State(initialValue: date)
        _name = State(initialValue: name)
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            contents
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self, destination: navigationDestination)
        }
    }
    
    var contents: some View {
        VStack {
            form
            Spacer()
            if !name.isEmpty {
                addButton
                addTemplateButton
            }
        }
    }

    @ViewBuilder
    func navigationDestination(for route: Route) -> some View {
        switch route {
        case .name:
            namePicker
        case .time:
            timePicker
        }
    }
    

    var addButton: some View {
        FormPrimaryButton(title: "Add") {
            tappedAdd()
        }
//        Button {
//        } label: {
//            Text("Add")
//                .bold()
//                .foregroundColor(.white)
//                .padding(.vertical)
//                .frame(maxWidth: .infinity)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                        .foregroundColor(.accentColor)
//                )
//                .padding(.horizontal)
//                .padding(.horizontal)
//        }
    }
    
    var addTemplateButton: some View {
        FormSecondaryButton(title: "Add Preset Meal") {
        }
//        Button {
//
//        } label: {
//            Text("Add Preset Meal")
//                .bold()
//                .foregroundColor(.accentColor)
//                .padding(.vertical)
//                .frame(maxWidth: .infinity)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                        .foregroundColor(.clear)
//                )
//                .padding(.horizontal)
//                .padding(.horizontal)
//                .contentShape(Rectangle())
//        }
    }
    
    var bottomToolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                tappedAdd()
            } label: {
                Text("Add")
            }
        }
    }
    
    var form: some View {
        Form {
            Section("Name") {
                Button {
                    path.append(.name)
                } label: {
                    if name.isEmpty {
                        Text("Required")
                            .foregroundColor(.secondary)
                    } else {
                        Text(name)
                            .foregroundColor(.primary)
                    }
                }
            }
            Section("Time") {
                Button {
                    path.append(.time)
                } label: {
                    Text(timeString)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    var timePicker: some View {
        TimeForm(name: name, time: $time, date: date)
    }
    
    var namePicker: some View {
        NamePicker(
            name: $name,
            showClearButton: true,
            recentStrings: recents,
            presetStrings: presets
        )
        .navigationTitle("Meal Name")
        .navigationBarTitleDisplayMode(.large)
    }
    
    var timeString: String {
        if time.startOfDay == Date().startOfDay {
            return "Today \(time.shortTimeString)"
        } else {
            return time.shortString
        }
    }

    //MARK: - Actions
    func didTapAddMealButton(notification: Notification) {
        tappedAdd()
    }
    
    func tappedAdd() {
        //TODO: CoreData
//        Store.createMeal(at: time, named: name)
        Haptics.feedback(style: .soft)
        dismiss()
    }
    
    enum Route: Hashable {
        case name
        case time
    }
}

//extension Store {
//    static func createMeal(at date: Date, named name: String) {
//        let day = Store.shared.dayCreatingIfNeeded(forDate: date)
//        let meal = Meal(context: mainContext)
//        meal.id = UUID()
//        meal.user = Store.user
//        meal.name = name
//        meal.time = Int64(date.timeIntervalSince1970)
//        meal.day = day
//        meal.createdAt = Int64(Date().timeIntervalSince1970)
//        meal.updatedAt = Int64(Date().timeIntervalSince1970)
//
//        saveMainContext()
//    }
//}
