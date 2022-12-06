import SwiftUI
import SwiftHaptics
import NamePicker
import SwiftUISugar
import PrepGoalSetsList

public struct MealForm: View {

    @StateObject var viewModel: MealFormViewModel

    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    public init(
        mealBeingEdited: DayMeal? = nil,
        date: Date,
        recents: [String] = [],
        presets: [String]? = nil,
        getTimelineItemsHandler: GetTimelineItemsHandler? = nil,
        didSave: @escaping (String, Date, GoalSet?) -> ()
    ) {
        let viewModel = MealFormViewModel(
            mealBeingEdited: mealBeingEdited,
            date: date,
            recents: recents,
            presets: presets,
            getTimelineItemsHandler: getTimelineItemsHandler,
            didSave: didSave
        )
        
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            contents
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { navigationTrailingButton }
            .toolbar { navigationLeadingButton }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(viewModel.shouldDisableInteractiveDismiss)
        }
    }
    
    var navigationLeadingButton: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            closeButton
        }
    }
    
    var saveButton: some View {
        Button {
            saveAndDismiss()
        } label: {
            Text(viewModel.saveButtonTitle)
                .bold()
        }
        .disabled(!viewModel.isDirty)
    }
    
    var closeButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            dismiss()
        } label: {
            closeButtonLabel
        }
    }
    
    var navigationTrailingButton: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            saveButton
        }
    }
    var contents: some View {
        form
    }

    var form: some View {
        FormStyledScrollView {
            detailsSection
            goalSetSection
        }
    }
    
    var detailsSection: some View {
        var divider: some View {
            Divider()
                .padding(.vertical, 5)
                .padding(.leading, 20)
        }
        
        return FormStyledSection(horizontalPadding: 0) {
            VStack {
                nameRow
                    .padding(.horizontal, 17)
                divider
                timeRow
                    .padding(.horizontal, 17)
//                .padding(.bottom, 5)
            }
        }
    }
    
    var nameRow: some View {
        HStack {
            Text("Name")
                .foregroundColor(.secondary)
            Spacer()
            TextField("Name", text: $viewModel.name)
                .multilineTextAlignment(.trailing)
                .focused($isFocused)
//                    .font(.title2)
//                    .fontWeight(.semibold)
            NavigationLink {
                namePicker
            } label: {
                Image(systemName: "square.grid.3x2")
            }
        }
    }
    
    var timeRow: some View {
        HStack {
            Text("Time")
                .foregroundColor(.secondary)
            Spacer()
            datePickerTime
                .frame(maxWidth: .infinity, alignment: .trailing)
            NavigationLink {
                timePicker
            } label: {
                Image(systemName: "calendar.day.timeline.left")
            }
        }
    }
    
    var goalSetSection: some View {
        var pickerRow: some View {
            NavigationLink {
                goalSetPicker
            } label: {
                HStack {
                    Text("Type")
                        .foregroundColor(.secondary)
                    Spacer()
                    goalSetLabel
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
        }
        
        @ViewBuilder
        var goalSetLabel: some View {
            if let goalSet = viewModel.goalSet {
                Text("\(goalSet.emoji) \(goalSet.name)")
                    .foregroundColor(.primary)
            } else {
                Text("Select")
                    .foregroundColor(.accentColor)
//                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        
        var durationRow: some View {
            HStack {
                Text("Workout Duration")
                    .foregroundColor(.secondary)
                Spacer()
                durationPicker
            }
        }
        
        var durationPicker: some View {
            HStack {
                Text("1 hour")
                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote)
                    .foregroundColor(Color(.tertiaryLabel))
                Text("30 min.")
                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        
        var divider: some View {
            Divider()
                .padding(.vertical, 5)
                .padding(.leading, 20)
        }
        
        @ViewBuilder
        var footer: some View {
            if viewModel.shouldShowDurationPicker {
                Text("Workout duration is used to calculate the carbohydrate goal for this meal type.")
//                Text("Workout duration is used to calculate the carbohydrate, protein and sodium goals for this meal type.")
            }
        }
        
        return FormStyledSection(footer: footer, horizontalPadding: 0) {
            VStack {
                pickerRow
                    .padding(.horizontal, 17)
                if viewModel.shouldShowDurationPicker {
                    divider
                    durationRow
                        .padding(.horizontal, 17)
                }
            }
        }
    }
    
    func buttonLabel(_ string: String) -> some View {
        Text(string)
          .foregroundColor(Color(.secondaryLabel))
          .padding(.vertical, 6)
          .padding(.horizontal, 8)
          .background(
//            Capsule(style: .continuous)
            RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                  .fill(Color(.secondarySystemFill))
          )
    }
    
    func button(
        increment: Int? = nil,
        decrement: Int? = nil,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .soft
    ) -> some View {
        Button {
            Haptics.feedback(style: hapticStyle)
            viewModel.didTapTimeButton()
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
        .foregroundColor(Color(.tertiaryLabel))
        .buttonStyle(BorderlessButtonStyle())
    }
    
    var datePicker: some View {
        DatePicker(
            "",
            selection: $viewModel.time,
            in: viewModel.dateRangeForPicker,
            displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
        .labelsHidden()
    }
    var datePickerTime: some View {
        DatePicker(
            "",
            selection: $viewModel.time,
            in: viewModel.dateRangeForPicker,
            displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.compact)
        .labelsHidden()
        .onChange(of: viewModel.time, perform: onChangeOfTime)
    }
    
    func onChangeOfTime(_ time: Date) {
        /// For some reason, not having this `onChange` modifier doesn't update the `time` when we pick one using the `DatePicker`, so we're leaving it in here
    }

    var addButton: some View {
        FormPrimaryButton(title: "Add") {
            saveAndDismiss()
        }
        .animation(.none, value: isFocused)
    }
    
    //MARK: - Pickers
    
    var namePicker: some View {
        NamePicker(
            name: $viewModel.name,
            showTextField: false,
            showClearButton: true,
//            focusOnAppear: true,
            recentStrings: viewModel.recents,
            presetStrings: viewModel.presets
        )
        .navigationTitle("Meal Name")
        .navigationBarTitleDisplayMode(.large)
    }
    
    var timePicker: some View {
        TimeForm(
            name: viewModel.name,
            time: viewModel.timeBinding,
            date: viewModel.date,
            getTimelineItemsHandler: viewModel.getTimelineItemsHandler
        )
    }
    
    var goalSetPicker: some View {
        GoalSetPicker(
            meal: nil,
            showCloseButton: false,
            selectedGoalSet: viewModel.goalSet,
            didSelectGoalSet: didSelectGoalSet
        )
    }
    
    func didSelectGoalSet(_ goalSet: GoalSet?, day: Day?) {
        viewModel.goalSet = goalSet
    }
    
    //MARK: - Actions
    func didTapAddMealButton(notification: Notification) {
        saveAndDismiss()
    }
    
    func saveAndDismiss() {
        viewModel.tappedAdd()
        Haptics.feedback(style: .soft)
        dismiss()
    }
}

//MARK: - 👁‍🗨 Previews
import PrepDataTypes

struct MealFormPreview: View {
    
    @State var showingMealForm = true
    
    var body: some View {
        NavigationView {
            Color.clear
                .navigationTitle("Meal Form")
                .sheet(isPresented: $showingMealForm) { mealForm }
        }
    }
    
    var mealForm: some View {
        MealForm(
            date: Date(),
            recents: ["Recents", "go here"],
            presets: Presets,
            getTimelineItemsHandler: getTimelineItems
        ) { name, date, goalSet in
            
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    
    func getTimelineItems(_ date: Date) -> [TimelineItem] {
        var items: [TimelineItem] = []
        for i in 0...10 {
            items.append(TimelineItem(
                name: "Meal \(i)",
                date: Date().startOfDay.addingTimeInterval(Double(i*3600))
            ))
        }
        return items
    }
}

struct MealForm_Previews: PreviewProvider {
    static var previews: some View {
        MealFormPreview()
    }
}
