import SwiftUI
import SwiftHaptics
import NamePicker
import SwiftUISugar

let Presets = ["Breakfast", "Lunch", "Dinner", "Pre-workout Meal", "Post-workout Meal", "Intra-workout Snack", "Snack", "Dinner Out", "Supper", "Midnight Snack"]

public struct MealForm: View {

    @Environment(\.dismiss) var dismiss
    @State var name = ""
    @State var path: [Route] = []

    @State var time: Date
//    @State var pickerTime: Date

    let date: Date
    let recents: [String]
    let presets: [String]
    
    let didSetValues: (String, Date) -> ()
    let getTimelineItemsHandler: GetTimelineItemsHandler?

    @FocusState var isFocused: Bool
    public init(
        date: Date = Date(),
        name: String = "",
        recents: [String] = [],
        presets: [String]? = nil,
        getTimelineItemsHandler: GetTimelineItemsHandler? = nil,
        didSetValues: @escaping (String, Date) -> ()
    ) {
        self.date = date
//        _pickerTime = State(initialValue: date)
        self.getTimelineItemsHandler = getTimelineItemsHandler
        self.recents = recents
        self.presets = presets ?? Presets
        self.didSetValues = didSetValues

        //TODO: We need to assign time here based on the date provided
        _time = State(initialValue: date)
        _name = State(initialValue: name)
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            contents
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Meal")
            .toolbar { navigationTrailingButton }
            .toolbar { navigationLeadingButton }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self, destination: navigationDestination)
//            .onChange(of: time, perform: onChangeOfTime)
        }
    }
    
//    func onChangeOfTime(_ time: Date) {
//        self.pickerTime = time
//    }
    
    var navigationLeadingButton: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button {
                Haptics.feedback(style: .soft)
                dismiss()
            } label: {
                closeButtonLabel
            }
        }
    }
    
    var navigationTrailingButton: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                tappedAdd()
            } label: {
                Text("Add")
                    .bold()
            }
        }
    }
    var contents: some View {
        form
    }

    var form: some View {
        FormStyledScrollView {
            nameSection
            timeSection
        }
    }
    
    var nameSection: some View {
        FormStyledSection(
            header: Text("Name"),
            horizontalPadding: 0,
            verticalPadding: 0
        ) {
            VStack {
                HStack {
                    TextField("Name", text: $name)
                        .focused($isFocused)
                    Spacer()
                    Button {
                        path.append(.name)
                    } label: {
                        Image(systemName: "square.grid.3x2")
                    }
                }
                
                .padding(.top, 15)
                .padding(.bottom, 5)
                .padding(.horizontal, 17)
//                Divider()
//                    .padding(.leading, 17)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Presets.indices, id: \.self) { index in
                            Button {
                                Haptics.feedback(style: .rigid)
                                name = Presets[index]
                            } label: {
                                buttonLabel(Presets[index])
                                    .padding(.leading, index == 0 ? 17 : 0)
                                    .padding(.trailing, index ==  Presets.count - 1 ? 17 : 0)
                            }
                        }
                    }
                }
                .listRowInsets(.init(top: 2, leading: 0, bottom: 2, trailing: 0))
                .padding(.top, 5)
                .padding(.bottom, 15)
            }
//            Button {
//                path.append(.name)
//            } label: {
//                if name.isEmpty {
//                    Text("Required")
//                        .foregroundColor(.secondary)
//                } else {
//                    Text(name)
//                        .foregroundColor(.primary)
//                }
//            }
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
    
    @ViewBuilder
    var timeSectionHeader: some View {
        if date.isToday {
            Text("Time, " + (time.isToday ? "Today" : "Tomorrow"))
        } else {
            Text("Time")
        }
    }
    
    var timeSection: some View {
        FormStyledSection(header: timeSectionHeader) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        datePickerTime
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                ZStack {
                    HStack {
                        Button("Now") {
                            self.time = Date()
//                            self.pickerTime = Date()
                        }
                        Spacer()
                        Button {
                            path.append(.time)
                        } label: {
                            Image(systemName: "calendar.day.timeline.left")
                        }
                    }
                    HStack(spacing: 0) {
                        button(decrement: 60, hapticStyle: .heavy)
                        button(decrement: 15)
                        Text("•")
                            .foregroundColor(Color(.quaternaryLabel))
                        button(increment: 15)
                        button(increment: 60, hapticStyle: .heavy)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    func button(increment: Int? = nil, decrement: Int? = nil, hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .soft) -> some View
    {
        Button {
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
        .foregroundColor(Color(.tertiaryLabel))
        .buttonStyle(BorderlessButtonStyle())
    }
    
    var datePicker: some View {
        let start = date.startOfDay
        let end = date.moveDayBy(1).atEndOfWeeHours
        let range = start...end
        return DatePicker(
            "",
            selection: $time,
            in: range,
            displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
        .labelsHidden()
    }
    var datePickerTime: some View {
        let start = date.startOfDay
        let end = date.moveDayBy(1).atEndOfWeeHours
        let range = start...end
        return DatePicker("",
                   selection: $time,
                   in: range,
                   displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
            .labelsHidden()
            .onChange(of: time, perform: onChangeOfTime)
    }
    
    func onChangeOfTime(_ time: Date) {
        /// For some reason, not having this `onChange` modifier doesn't update the `time` when we pick one using the `DatePicker`, so we're leaving it in here
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
        .animation(.none, value: isFocused)
    }
    
    var timePicker: some View {
        let binding = Binding<Date>(
            get: {
                return time
            },
            set: { newValue in
                time = newValue
            }
        )
        return TimeForm(
            name: name,
            time: binding,
            date: date,
            getTimelineItemsHandler: getTimelineItemsHandler
        )
    }
    
    var namePicker: some View {
        NamePicker(
            name: $name,
            showTextField: false,
            showClearButton: true,
//            focusOnAppear: true,
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
        didSetValues(name, time)
        Haptics.feedback(style: .soft)
        dismiss()
    }
    
    enum Route: Hashable {
        case name
        case time
    }
}

import PrepDataTypes

struct ContentView: View {
    
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
            name: "Meal 1",
            recents: ["Recents", "go here"],
            presets: Presets,
            getTimelineItemsHandler: getTimelineItems
        ) { name, date in
            
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
