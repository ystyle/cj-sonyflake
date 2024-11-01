package sonyflake

import std.sync.{ReentrantMutex, sleep}
import std.time.*
import std.random.*
import std.collection.HashMap

let BitLenTime: Int64 = 39
let BitLenSequence: Int64 = 8
let BitLenMachineID: Int64 = 63 - BitLenTime - BitLenSequence
let defaultTime = DateTime.of(year: 2020, month: 10, dayOfMonth: 1, hour: 0, minute: 0, second: 0, nanosecond: 0,
    timeZone: TimeZone.UTC)
let sonyflakeTimeUnit = 1e7

public struct Setting {
    let StartTime: DateTime
    let MachineID: UInt16

    public init(StartTime: DateTime, MachineID: UInt16) {
        this.StartTime = StartTime
        this.MachineID = MachineID
    }

    public init(MachineID: UInt16) {
        this.StartTime = defaultTime
        this.MachineID = MachineID
    }
}

public class Sonyflake {
    private let mutex: ReentrantMutex
    private let startTime: Int64
    private var elapsedTime: Int64 = 0
    private var sequence: UInt16
    private let machineID: UInt16

    public init(st: Setting) {
        this.mutex = ReentrantMutex()
        this.sequence = UInt16((1 << BitLenSequence - 1))
        if (st.StartTime > DateTime.now()) {
            throw Exception("StartTime can not after now")
        }
        this.startTime = toSonyflakeTime(st.StartTime)
        this.machineID = st.MachineID
    }
    public func NextID(): UInt64 {
        let maskSequence = UInt16((1 << BitLenSequence) - 1)
        this.mutex.lock()
        let current = currentElapsedTime(this.startTime)
        if (this.elapsedTime < current) {
            this.elapsedTime = current
            this.sequence = 0
        } else {
            this.sequence = (this.sequence + 1) & maskSequence
            if (this.sequence == 0) {
                println("==0")
                this.elapsedTime++
                let overtime = this.elapsedTime - current
                sleep(sleepTime(overtime))
            }
        }
        let id = this.toID()
        this.mutex.unlock()
        return id
    }
    private func toID(): UInt64 {
        if (this.elapsedTime >= 1 << BitLenTime) {
            throw Exception("over the time limit")
        }
        let t = UInt64(this.elapsedTime) << (BitLenSequence + BitLenMachineID)
        let s = UInt64(this.sequence) << BitLenMachineID
        let m = UInt64(this.machineID)
        return t | s | m
    }
}

func toSonyflakeTime(t: DateTime): Int64 {
    return t.inUTC().toUnixTimeStamp().toNanoseconds() / Int64(sonyflakeTimeUnit)
}

func currentElapsedTime(startTime: Int64): Int64 {
    return toSonyflakeTime(DateTime.now()) - startTime
}

func sleepTime(overtime: Int64): Duration {
    let d1 = Duration.nanosecond * (overtime * Int64(sonyflakeTimeUnit))
    let d2 = Duration.nanosecond * (DateTime.now().inUTC().toUnixTimeStamp().toNanoseconds() % Int64(sonyflakeTimeUnit))
    let d3 = d1 - d2
    return d3
}

public func Decompose(id: UInt64): HashMap<String, UInt64> {
    let m = HashMap<String, UInt64>()
    let maskSequence = UInt64(((1 << BitLenSequence) - 1) << BitLenMachineID)
    let maskMachineID = UInt64((1 << BitLenMachineID) - 1)
    m["id"] = id
    m["msb"] = id >> 63
    m["time"] = id >> (BitLenSequence + BitLenMachineID)
    m["sequence"] = (id & maskSequence) >> BitLenMachineID
    m["machine-id"] = id & maskMachineID
    return m
}
