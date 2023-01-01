import SwiftUI
import SwiftHaptics
import NamePicker
import SwiftUISugar
import PrepGoalSetsList
import PrepViews

public struct MealForm: View {

    @StateObject var viewModel: MealFormViewModel

    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    @State var showingDeleteConfirmation = false
    @State var hasFocusedOnAppear: Bool = false
    @State var hasCompletedFocusedOnAppearAnimation: Bool = false
    
    @State var collapsedButtons: Bool = true
    
    let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)

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
            content
                .background(Color(.systemGroupedBackground))
                .navigationTitle(viewModel.navigationTitle)
                .navigationBarTitleDisplayMode(.large)
                .toolbar { navigationLeadingButton }
                .navigationBarTitleDisplayMode(.inline)
                .interactiveDismissDisabled(viewModel.shouldDisableInteractiveDismiss)
                .onReceive(keyboardWillHide, perform: keyboardWillHide)
                .onReceive(keyboardWillShow, perform: keyboardWillShow)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.interactiveSpring()) {
                self.collapsedButtons = false
            }
        }
    }

    func keyboardWillShow(_ notification: Notification) {
        guard hasCompletedFocusedOnAppearAnimation else { return }
        withAnimation(.interactiveSpring()) {
            self.collapsedButtons = true
        }
    }
    
    var navigationLeadingButton: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
//            closeButton
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
    
    var saveButtons: some View {
        var saveButton: some View {
            Button {
                Haptics.successFeedback()
                saveAndDismiss()
            } label: {
                Text(viewModel.saveButtonTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.accentColor)
                    )
                    .padding(.horizontal)
                    .padding(.horizontal)
            }
            .buttonStyle(.borderless)
            
//            FormPrimaryButton(title: viewModel.saveButtonTitle) {
//                Haptics.successFeedback()
//                saveAndDismiss()
//            }
        }
        
        var cancelButton: some View {
            FormSecondaryButton(title: "Cancel") {
                Haptics.feedback(style: .soft)
                dismiss()
//                actionHandler(.dismiss)
            }
        }

        var deleteButton: some View {
            FormSecondaryButton(title: "Delete", foregroundColor: NutrientMeter.ViewModel.Colors.Excess.fill) {
                Haptics.selectionFeedback()
                showingDeleteConfirmation = true
            }
        }
        
        @ViewBuilder
        var background: some View {
            if collapsedButtons {
                Color.clear
                    .background(.thinMaterial)
            }
        }
        
        var collapsedButtons: Bool {
            hasCompletedFocusedOnAppearAnimation && !isFocused
        }
        
        @ViewBuilder
        var divider: some View {
            if collapsedButtons {
                Divider()
            }
        }

        return VStack(spacing: 0) {
            divider
            VStack {
                saveButton
                    .padding(.top)
                HStack {
                    cancelButton
                    deleteButton
                }
                .padding(.horizontal, 50)
//                privateButton
//                    .padding(.vertical)
            }
//            .padding(.bottom, 30)
        }
        .background(background)
    }

    @ViewBuilder
    var buttonsLayer: some View {
//            if canBeSaved {
            VStack {
                Spacer()
                saveButtons
            }
//                .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
//            }
    }

    var content: some View {
        
        var deleteConfirmationActions: some View {
            Button("Delete Meal", role: .destructive) {
//                actionHandler(.delete)
//                actionHandler(.dismiss)
            }
        }

        var deleteConfirmationMessage: some View {
            Text("Are you sure you want to delete this meal?")
        }

        var formLayer: some View {
            form
//                .safeAreaInset(edge: .bottom) { bottomSafeAreaInset }
                .navigationTitle(viewModel.navigationTitle)
//                .toolbar { trailingContents }
                .scrollDismissesKeyboard(.interactively)
                .confirmationDialog(
                    "",
                    isPresented: $showingDeleteConfirmation,
                    actions: { deleteConfirmationActions },
                    message: { deleteConfirmationMessage }
                )
        }
        
        var tappedDelete: (() -> ())? {
            if viewModel.isEditing {
                return {
                    showingDeleteConfirmation = true
                }
            } else {
                return nil
            }
        }
        
        var tappedCancel: () -> () {
            return {
                dismiss()
            }
        }
        
        return ZStack {
            formLayer
            FormSaveLayer(
                collapsed: $collapsedButtons,
                tappedCancel: tappedCancel,
                tappedSave: saveAndDismiss,
                tappedDelete: tappedDelete
            )
//            buttonsLayer
        }
    }

    var form: some View {
        FormStyledScrollView {
            nameSection
            timeSection
//            detailsSection
//            goalSetSection
        }
    }
    
    var nameSection: some View {
        FormStyledSection(header: Text("Name")) {
            nameRow
        }
    }
    
    
    var timeSection: some View {
        FormStyledSection(header: Text("Time")) {
            timeRow
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
            TextField("Name", text: $viewModel.name)
                .multilineTextAlignment(.leading)
                .focused($isFocused)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
                .font(.title2)
                .fontWeight(.semibold)
            NavigationLink {
                namePicker
            } label: {
                Image(systemName: "square.grid.3x2")
            }
        }
        .introspectTextField { uiTextField in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if !hasFocusedOnAppear {
                    uiTextField.becomeFirstResponder()
                    hasFocusedOnAppear = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn) {
                            hasCompletedFocusedOnAppearAnimation = true
                        }
                    }
                }
//                }
        }
//        .onAppear {
//            isFocused = true
//        }
    }
    
    var timeRow: some View {
        HStack {
            datePickerTime
                .frame(maxWidth: .infinity, alignment: .leading)
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
//        Haptics.feedback(style: .soft)
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
            getTimelineItemsHandler: getTimelineItems) { name, date, goalSet in
                
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

//MARK: To be moved

import SwiftUI

struct FormSaveLayer: View {
    
    @Binding var collapsed: Bool
    let tappedCancel: () -> ()
    let tappedSave: () -> ()
    let tappedDelete: (() -> ())?
    
    init(
        collapsed: Binding<Bool>,
        tappedCancel: @escaping () -> (),
        tappedSave: @escaping () -> (),
        tappedDelete: (() -> ())? = nil
    ) {
        _collapsed = collapsed
        self.tappedSave = tappedSave
        self.tappedCancel = tappedCancel
        self.tappedDelete = tappedDelete
    }

    var body: some View {
        VStack {
            Spacer()
            buttonsLayer
        }
    }

    var buttonHeight: CGFloat {
        collapsed ? 38 : 52
    }
    
    var buttonCornerRadius: CGFloat {
        collapsed ? 19 : 10
    }
    
    var height: CGFloat {
        collapsed ? 70 : 128
    }

    var saveButton: some View {
        var buttonWidth: CGFloat {
            collapsed ? 100 : UIScreen.main.bounds.width - 60
        }
        
        var xPosition: CGFloat {
            collapsed
            ? (100.0 / 2.0) + 20.0 + 38.0 + 10.0
            : UIScreen.main.bounds.width / 2.0
        }

        var yPosition: CGFloat {
            collapsed
            ? (38.0 / 2.0) + 16.0
            : (52.0/2.0) + 16.0
        }

        var shadowOpacity: CGFloat {
            collapsed ? 0.2 : 0
        }
        return Button {
            tappedSave()
        } label: {
            Text("Save")
            .bold()
            .foregroundColor(.white)
            .frame(width: buttonWidth, height: buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    .foregroundColor(.accentColor)
                    .shadow(color: Color(.black).opacity(shadowOpacity), radius: 3, x: 0, y: 3)
            )
        }
        .buttonStyle(.borderless)
        .position(x: xPosition, y: yPosition)
    }
    
    var dismissButton: some View {
        var image: some View {
            Image(systemName: "chevron.down")
                .imageScale(.medium)
                .fontWeight(.medium)
                .foregroundColor(Color(.secondaryLabel))
        }
        
        var text: some View {
            Text("Cancel")
                .foregroundColor(.secondary)
        }
        
        var buttonWidth: CGFloat {
            collapsed ? 38 : UIScreen.main.bounds.width - 60
        }
        
        var xPosition: CGFloat {
            collapsed
            ? (38.0 / 2.0) + 20.0
            : UIScreen.main.bounds.width / 2.0
        }

        var yPosition: CGFloat {
            collapsed
            ? (38.0 / 2.0) + 16.0
            : (52.0/2.0) + 16.0 + 52 + 8
        }

        var label: some View {
            HStack {
                if collapsed {
                    image
                }
                if !collapsed {
                    text
                }
            }
            .frame(width: buttonWidth, height: buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    .foregroundStyle(.ultraThinMaterial)
                    .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                    .opacity(collapsed ? 1 : 0)
            )
            .position(x: xPosition, y: yPosition)
        }
        
        return Button {
            tappedCancel()
        } label: {
            label
        }
    }
    
    func deleteButton(_ action: @escaping () -> ()) -> some View {
        var xPosition: CGFloat {
            collapsed
            ? (38.0 / 2.0) + 20.0
            : UIScreen.main.bounds.width / 2.0
        }

        var yPosition: CGFloat {
            collapsed
            ? (38.0 / 2.0) + 16.0
            : (52.0/2.0) + 16.0 + 52 + 8
        }

        var label: some View {
            HStack {
                Image(systemName: "trash")
                    .imageScale(.medium)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                Text("Delete")
                    .foregroundColor(.red)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 5)
            }
            .frame(width: 100, height: 38)
            .background(
                RoundedRectangle(cornerRadius: 19)
                    .foregroundStyle(.ultraThinMaterial)
                    .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
            )
        }
        
        return Button {
            action()
        } label: {
            label
        }
    }
    
    @ViewBuilder
    var deleteButtonLayer: some View {
        if let tappedDelete {
            HStack {
                Spacer()
                deleteButton(tappedDelete)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .offset(y: collapsed ? (38/2.0) - 3 : -38 - 10)
        }
    }

    var buttonsLayer: some View {
        @ViewBuilder
        var background: some View {
            if !collapsed {
                Color.clear
                    .background(.thinMaterial)
            }
        }
        
        @ViewBuilder
        var divider: some View {
            if !collapsed {
                Divider()
            }
        }
        
        var buttons: some View {
            ZStack(alignment: .topLeading) {
                saveButton
                dismissButton
                deleteButtonLayer
            }
            .frame(height: height)
//            .background(.green)
        }
        
        return VStack(spacing: 0) {
            divider
            buttons
        }
        .background(background)
    }
}
