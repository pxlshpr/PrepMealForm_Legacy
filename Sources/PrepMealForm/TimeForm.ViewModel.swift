import SwiftUI
import Timeline

extension TimeForm {
    class ViewModel: ObservableObject {
        @Published var time: Date = Date()
    }
}

extension TimeForm.ViewModel: TimelineDelegate {
    func shouldRegisterTapsOnIntervals() -> Bool {
        true
    }
    
    func didTapInterval(between item1: TimelineItem, and item2: TimelineItem) {
        guard !(item1.isNew || item2.isNew) else {
            return
        }
        guard item2.date > item1.date else {
            return
        }
        let midPoint = ((item2.date.timeIntervalSince1970 - item1.date.timeIntervalSince1970) / 2.0) + item1.date.timeIntervalSince1970
        let midPointDate = Date(timeIntervalSince1970: midPoint)
        withAnimation {
            time = midPointDate
        }
    }
    
    func didTapNow() {
        time = Date()
    }
}
