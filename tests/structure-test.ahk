; ahk: console
#NoEnv
#Warn All, StdOut

#Include <testcase-libs>
#Include %ScriptDir%\..\structure.ahk

#Include %ScriptDir%\..\modules\structure
;#Include SMALL_RECT.ahk

class StructureTest extends TestCase {

	requires() {
		return [Structure, Arrays]
	}

	@Test_typeLength() {
		this.assertEquals(Structure.typeLength("Str"), 0)
		this.assertEquals(Structure.typeLength("str"), 0)
		this.assertEquals(Structure.typeLength("wStr"), 0)
		this.assertEquals(Structure.typeLength("AStr"), 0)
		this.assertEquals(Structure.typeLength("Char"), 1)
		this.assertEquals(Structure.typeLength("CharP"), 1)
		this.assertEquals(Structure.typeLength("Char*"), 1)
		this.assertEquals(Structure.typeLength("UChar"), 1)
		this.assertEquals(Structure.typeLength("UCharP"), 1)
		this.assertEquals(Structure.typeLength("UChar*"), 1)
		this.assertEquals(Structure.typeLength("Short"), 2)
		this.assertEquals(Structure.typeLength("ShortP"), 2)
		this.assertEquals(Structure.typeLength("Short*"), 2)
		this.assertEquals(Structure.typeLength("UShort"), 2)
		this.assertEquals(Structure.typeLength("UShortP"), 2)
		this.assertEquals(Structure.typeLength("UShort*"), 2)
		this.assertEquals(Structure.typeLength("Int"), 4)
		this.assertEquals(Structure.typeLength("IntP"), 4)
		this.assertEquals(Structure.typeLength("Int*"), 4)
		this.assertEquals(Structure.typeLength("UInt"), 4)
		this.assertEquals(Structure.typeLength("UIntP"), 4)
		this.assertEquals(Structure.typeLength("UInt*"), 4)
		this.assertEquals(Structure.typeLength("Int64"), 8)
		this.assertEquals(Structure.typeLength("Int64P"), 8)
		this.assertEquals(Structure.typeLength("Int64*"), 8)
		this.assertEquals(Structure.typeLength("UInt64"), 8)
		this.assertEquals(Structure.typeLength("UInt64P"), 8)
		this.assertEquals(Structure.typeLength("UInt64*"), 8)
		this.assertEquals(Structure.typeLength("Ptr"), A_PtrSize)
		this.assertEquals(Structure.typeLength("PtrP"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Ptr*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UPtr"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UPtrP"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UPtr*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Float"), 4)
		this.assertEquals(Structure.typeLength("Double"), 8)
		this.assertException(Structure, "typeLength",,, "Long")
		this.assertException(Structure, "typeLength",,, "UDouble")
		this.assertException(Structure, "typeLength",,, "")
	}

	@Test_sizeOfMember() {
		this.assertEquals(Structure.sizeOfMember(5, "test", "Ptr")
				, 5 + A_PtrSize)
		this.assertException(Structure, "sizeOfMember",,, 5, "test", "Long")
	}

	@Test_putData() {
		ba := [1]
		ba := Structure.putData(ba, "x", "Short", 770)
		this.assertTrue(Arrays.equal(ba, [1,2,3]))
		ba := Structure.putData(ba, "x", "UInt", 42)
		this.assertTrue(Arrays.equal(ba, [1,2,3,42,0,0,0]))
		ba := Structure.putData(ba, "x", "Short", -1303)
		this.assertTrue(Arrays.equal(ba, [1,2,3,42,0,0,0,233,250]))
	}

	@Test_getData() {
		obj := {}
		ba := [1,2,3,42,0,0,0,233,250]
		ba := Structure.getData(ba, "x", "UChar", obj)
		this.assertEquals(obj.x, 1)
		this.assertTrue(Arrays.equal(ba, [2,3,42,0,0,0,233,250]))
		ba := Structure.getData(ba, "y", "Short", obj)
		this.assertEquals(obj.y, 770)
		this.assertTrue(Arrays.equal(ba, [42,0,0,0,233,250]))
		ba := Structure.getData(ba, "z", "UInt", obj)
		this.assertEquals(obj.z, 42)
		this.assertTrue(Arrays.equal(ba, [233,250]))
		ba := Structure.getData(ba, "q", "Short", obj)
		this.assertEquals(obj.q, -1303)
		this.assertTrue(Arrays.equal(ba, []))
	}

	@Test_doCallback() {
		value := "foo"
		value := Structure.doCallback({onTest: StructureTest.cat.bind(StructureTest)} ; ahklint-ignore: W002
				, "onTest", value, {name: "x", type: "UInt", value: "bar"})
		this.assertEquals(value, "foobar")
		value := Structure.doCallback({onTest: StructureTest.cat.bind(StructureTest)} ; ahklint-ignore: W002
				, "onSomeEvent", value, {name: "x", type: "UInt", value: "bar"})
		this.assertEquals(value, "foobar")
	}

	@Test_traverse() {
		z := new TESTSTRUCT_B()
		z.x.a := 1
		z.x.b := 2
		z.c := 3
		z.d := 4
		this.assertEquals(z.traverse({onMember: StructureTest.cat.bind(StructureTest)}, "foobar:") ; ahklint-ignore: W002
				, "foobar:1234")
	}
	cat(currentValue, memberName, memberType, memberValue) {
		return currentValue . memberValue
	}

	@Test_sizeOf() {
		z := new TESTSTRUCT_B()
		z.x.a := 1
		z.x.b := 2
		z.c := 3
		z.d := 4
		this.assertEquals(z.sizeOf(), 14)
	}

	@Test_dump() {
		z := new TESTSTRUCT_B()
		this.assertEquals(z.dump()
				, "`nx {`na <not set>`nb <not set>`n} x`n"
				. "c <not set>`nd <not set>")
		z.x.a := 1
		z.d := 4
		this.assertEquals(z.dump()
				, "`nx {`na -> 1`nb <not set>`n} x`n"
				. "c <not set>`nd -> 4")
	}

	@Test_dumpMember() {
		this.assertEquals(Structure.dumpMember("xxx", "test", "UInt"
				, "foobar"), "xxx`ntest -> foobar")
	}

	@Test_dumpStructureName() {
		this.assertEquals(Structure.dumpStructureName("xxx", "blah")
				, "xxx`nblah {")
	}

	@Test_dumpMissingMember() {
		this.assertEquals(Structure.dumpMissingMember("xxx", "blubb")
				, "xxx`nblubb <not set>")
	}

	@Test_dumpEndOfStructure() {
		this.assertEquals(Structure.dumpEndOfStructure("xxx", "blah")
				, "xxx`n} blah")
	}

	@Test_implodeExplode() {
		z := new TESTSTRUCT_B()
		z.x.a := 1
		z.x.b := 2
		z.d := 4
		z.implode(_z)
		this.assertEquals(NumGet(_z, 0, "Short"), 1)
		this.assertEquals(NumGet(_z, 2, "Int"), 2)
		this.assertEquals(NumGet(_z, 6, "UInt"), 0)
		this.assertEquals(NumGet(_z, 10, "UInt"), 4)
		NumPut(3, _z, 6, "UInt")
		z2 := new TESTSTRUCT_B()
		z2.explode(_z)
		this.assertEquals(z2.x.a, 1)
		this.assertEquals(z2.x.b, 2)
		this.assertEquals(z2.c, 3)
		this.assertEquals(z2.d, 4)
	}

	@Test_SMALL_RECT() {
		sr := new SMALL_RECT()
	}
}

class TESTSTRUCT_A extends Structure {
	
	struct := [["a", "Short"], ["b", "Int"]]
}

class TESTSTRUCT_B extends Structure {

	x := new TESTSTRUCT_A()

	struct := [["x", "TESTSTRUCT_A"]
			,  ["c", "UInt"]
			,  ["d", "UInt"]]
}

exitapp StructureTest.runTests()
