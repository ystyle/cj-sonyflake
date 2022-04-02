package sonyflake

from std import unittest.*
from std import unittest.testmacro.*

@Test
func testAll():Unit {
    let st = Setting(1)
    let sf = Sonyflake(st)
    for (i in 0..10) {
        let id = sf.NextID()
        println("id: ${id}")
        println(Decompose(id))
    }
}
