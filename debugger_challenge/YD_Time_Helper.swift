import Foundation

class YD_Time_Helper {
    var raw_date: Date
    var readable_date: String
    var epoch_time: Int
    
    convenience init(raw_date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "EEEE H:mm.ss"       // "yyyyMMdd"
        let easy_date = formatter.string(from: raw_date)
        let easy_epoch = Int(raw_date.timeIntervalSince1970)
        self.init(raw_date: raw_date, readable_date: easy_date, epoch_time: easy_epoch)
    }
    
    init(raw_date: Date, readable_date: String, epoch_time: Int) {
        self.raw_date = raw_date
        self.readable_date = readable_date
        self.epoch_time = epoch_time
    }
}
