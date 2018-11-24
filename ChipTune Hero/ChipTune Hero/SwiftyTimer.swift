//
// SwiftyTimer
//
// Copyright (c) 2015 Radosław Pietruszewski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

private class NSTimerActor {
    var block: () -> ()
    
    init(_ block: @escaping () -> ()) {
        self.block = block
    }
    
    @objc dynamic func fire() {
        block()
    }
}

extension Timer {
    // NOTE: `new` class functions are a workaround for a crashing bug when using convenience initializers (18720947)
    
    /// Create a timer that will call `block` once after the specified time.
    ///
    /// **Note:** the timer won't fire until it's scheduled on the run loop.
    /// Use `NSTimer.after` to create and schedule a timer in one step.
    
    public class func new(after interval: TimeInterval, _ block: @escaping () -> ()) -> Timer {
        let actor = NSTimerActor(block)
        return self.init(timeInterval: interval, target: actor, selector: #selector(NSTimerActor.fire), userInfo: nil, repeats: false)
    }
    
    /// Create a timer that will call `block` repeatedly in specified time intervals.
    ///
    /// **Note:** the timer won't fire until it's scheduled on the run loop.
    /// Use `NSTimer.every` to create and schedule a timer in one step.
    
    public class func new(every interval: TimeInterval, _ block: @escaping () -> ()) -> Timer {
        let actor = NSTimerActor(block)
        return self.init(timeInterval: interval, target: actor, selector: #selector(NSTimerActor.fire), userInfo: nil, repeats: true)
    }
    
    /// Create and schedule a timer that will call `block` once after the specified time.
    
    public class func after(interval: TimeInterval, _ block: @escaping () -> ()) -> Timer {
        let timer = Timer.new(after: interval, block)
        RunLoop.current.add(timer, forMode: .default)
        return timer
    }
    
    /// Create and schedule a timer that will call `block` repeatedly in specified time intervals.
    
    public class func every(interval: TimeInterval, _ block: @escaping () -> ()) -> Timer {
        let timer = Timer.new(every: interval, block)
        RunLoop.current.add(timer, forMode: .default)
        return timer
    }
}

extension Int {
    public var second:  TimeInterval { return TimeInterval(self) }
    public var seconds: TimeInterval { return TimeInterval(self) }
    public var minute:  TimeInterval { return TimeInterval(self * 60) }
    public var minutes: TimeInterval { return TimeInterval(self * 60) }
    public var hour:    TimeInterval { return TimeInterval(self * 3600) }
    public var hours:   TimeInterval { return TimeInterval(self * 3600) }
}

extension Double {
    public var second:  TimeInterval { return self }
    public var seconds: TimeInterval { return self }
    public var minute:  TimeInterval { return self * 60 }
    public var minutes: TimeInterval { return self * 60 }
    public var hour:    TimeInterval { return self * 3600 }
    public var hours:   TimeInterval { return self * 3600 }
}
