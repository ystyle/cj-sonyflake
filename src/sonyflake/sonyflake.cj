package sonyflake

from std import sync.ReentrantMutex
from std import time.*
from std import random.*
from std import collection.HashMap

let BitLenTime:      Int64 = 39
let BitLenSequence:  Int64 = 8
let BitLenMachineID: Int64 = 63 - BitLenTime - BitLenSequence

let defaultTime       = Time(2020, Month.October, 1, loc: Location.UTC)
let sonyflackTime     = Duration.millisecond(10)
let sonyflakeTimeUnit = 1e7

public record Setting {
    let StartTime: Time
    let MachineID: UInt16

    public init(StartTime: Time, MachineID: UInt16) {
        this.StartTime = StartTime
        this.MachineID = MachineID
    }

    public init(MachineID: UInt16) {
        this.StartTime = defaultTime
        this.MachineID = MachineID
    }
}

public class Sonyflake {
    private let mutex:       ReentrantMutex
    private let startTime:   Int64
    private var elapsedTime: Int64 = 0
    private var sequence:    UInt16
    private let machineID:   UInt16

    public init(st: Setting) {
        this.mutex = ReentrantMutex()
        this.sequence = UInt16((1 << BitLenSequence - 1))
        if (st.StartTime > Time.now()) {
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

func toSonyflakeTime(t: Time): Int64 {
    return t.utc().unixNano() / Int64(sonyflakeTimeUnit)
}

func currentElapsedTime(startTime: Int64): Int64 {
    return toSonyflakeTime(Time.now()) - startTime
}

func sleepTime(overtime: Int64): Int64 {
    let d1 = Duration.microsecond(overtime * 10)
    let d2 = Duration.nanosecond(Time.now().utc().unixNano() % Int64(sonyflakeTimeUnit))
    let d3 = d1 - d2
    return d3.nanoseconds()
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
