package sonyflake

from std import unittest.*
from std import unittest.testmacro.*

@Test
func testAll():Unit {
    let st = Setting(1)
    let sf = Sonyflake(st)
    for (i in 0..10) {
        let id = sf.NextID()
        println(Decompose(id))
    }
}

@Test
func testDecompose():Unit {
    let id:UInt64 = 106997944976736257
    let m = Decompose(id)
    @Assert(m["id"], id)
    @Assert(m["msb"], 0)
    @Assert(m["time"], 6377574502)
    @Assert(m["sequence"], 9)
    @Assert(m["machine-id"], 1)
}