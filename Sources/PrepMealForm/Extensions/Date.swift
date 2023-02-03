import Foundation

extension Date {
    var minus5Minutes: Date {
        addingTimeInterval(-5 * 60)
    }
    
    var plus5Minutes: Date {
        addingTimeInterval(5 * 60)
    }
    
    func isLessThanBoundsFrom(_ date: Date) -> Bool {
        startOfDay < date.startOfDay
    }
    
    func isGreaterThanBoundsFrom(_ date: Date) -> Bool {
        if startOfDay > date.startOfDay {
            if timeIntervalSince(date.startOfDay) > 48 * 3600 {
                return true
            }
            if hour > 5 {
                return true
            }
        }
        return false
    }
    
    func isOutOfBoundsFrom(_ date: Date) -> Bool {
        isLessThanBoundsFrom(date) || isGreaterThanBoundsFrom(date)
    }
}

extension Date {
    func timeSlot(within date: Date) -> Int {
        guard self > date.startOfDay else { return 0 }
        let difference = self.timeIntervalSince1970 - date.startOfDay.timeIntervalSince1970
        let slots = Int(difference / (15 * 60.0))
        guard slots < K.numberOfSlots else { return 0 }
        return slots
    }
    
    func timeForTimeSlot(_ timeSlot: Int) -> Date {
        Date(timeIntervalSince1970: startOfDay.timeIntervalSince1970 + (Double(timeSlot) * 15 * 60))
    }
}

extension Date {
    var shortString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, h:mm a"
        return formatter.string(from: self)
    }
    
    var shortTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
