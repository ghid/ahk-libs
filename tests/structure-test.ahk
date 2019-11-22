; ahk: console
#NoEnv
#Warn All, StdOut

#Include <testcase-libs>
#Include %ScriptDir%\..\structure.ahk

#Include %ScriptDir%\..\modules\structure
#Include CONSOLE_SCREEN_BUFFER_INFO.ahk
#Include SMALL_RECT.ahk
#Include SYSTEMTIME.ahk
#Include TIME_ZONE_INFORMATION.ahk

class StructureTest extends TestCase {

	requires() {
		return [Structure, Arrays
				, CONSOLE_SCREEN_BUFFER_INFO, SMALL_RECT, SYSTEMTIME
				, TIME_ZONE_INFORMATION]

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
		this.assertEquals(Structure.sizeOfMember(0, "test", "Str", "", 32)
				, 32 * (A_IsUnicode ? 2 : 1))
		this.assertEquals(Structure.sizeOfMember(0, "test", "WStr", "", 32), 64)
		this.assertEquals(Structure.sizeOfMember(5, "test", "Ptr", "", "")
				, 5 + A_PtrSize)
		this.assertException(Structure, "sizeOfMember",,
				, 5, "test", "Long", "", "")
	}

	@Test_putData() {
		ba := [1]
		ba := Structure.putData(ba, "x", "Short", 770, "")
		this.assertTrue(Arrays.equal(ba, [1,2,3]))
		ba := Structure.putData(ba, "x", "UInt", 42, "")
		this.assertTrue(Arrays.equal(ba, [1,2,3,42,0,0,0]))
		ba := Structure.putData(ba, "x", "Short", -1303, "")
		this.assertTrue(Arrays.equal(ba, [1,2,3,42,0,0,0,233,250]))
		ba := []
		ba := Structure.putData(ba, "x", "Str", "foo bar", "")
		this.assertTrue(Arrays.equal(ba
				, [102,0,111,0,111,0,32,0,98,0,97,0,114,0]))
		ba := []
		ba := Structure.putData(ba, "x", "Str", "foo bar", 3)
		this.assertTrue(Arrays.equal(ba, [102,0,111,0,111,0]))
	}

	@Test_getData() {
		obj := {}
		ba := [1,2,3,42,0,0,0,233,250]
		ba := Structure.getData(ba, "x", "UChar", obj, "")
		this.assertEquals(obj.x, 1)
		this.assertTrue(Arrays.equal(ba, [2,3,42,0,0,0,233,250]))
		ba := Structure.getData(ba, "y", "Short", obj, "")
		this.assertEquals(obj.y, 770)
		this.assertTrue(Arrays.equal(ba, [42,0,0,0,233,250]))
		ba := Structure.getData(ba, "z", "UInt", obj, "")
		this.assertEquals(obj.z, 42)
		this.assertTrue(Arrays.equal(ba, [233,250]))
		ba := Structure.getData(ba, "q", "Short", obj, "")
		this.assertEquals(obj.q, -1303)
		this.assertTrue(Arrays.equal(ba, []))
		ba := [102,0,111,0,111,0,32,0,98,0,97,0,114,0]
		ba := Structure.getData(ba, "f", "Str", obj, "")
		this.assertEquals(obj.f, "foo bar")
		this.assertTrue(Arrays.equal(ba, []))
		ba := [102,0,111,0,111,0,32,0]
		ba := Structure.getData(ba, "f", "Str", obj, 4)
		this.assertEquals(obj.f, "foo ")
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
		this.assertEquals(z.sizeOf(), 14)
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
		sr1 := new SMALL_RECT()
		this.assertEquals(sr1.sizeOf(), 8)
		sr1.left := 1
		sr1.top := 2
		sr1.right := 3
		sr1.bottom := 4
		sr1.implode(_sr1)
		sr2 := new SMALL_RECT()
		sr2.explode(_sr1)
		this.assertEquals(sr2.left, 1)
		this.assertEquals(sr2.top, 2)
		this.assertEquals(sr2.right, 3)
		this.assertEquals(sr2.bottom, 4)
	}

	@Test_TIME_ZONE_INFORMATION() {
		this.assertEquals(SYSTEMTIME.base.__Class, "Structure")
		this.assertEquals(TIME_ZONE_INFORMATION.base.__Class, "Structure")
		tzi := new TIME_ZONE_INFORMATION()
		this.assertEquals(tzi.sizeOf(), 172)
		tzi.implode(_tzi)
		if (DllCall("GetTimeZoneInformation", "UInt", &_tzi, "UInt")) {
			; TestCase.writeLine("`n" LoggingHelper.hexDump(&_tzi, 0, tzi.sizeOf())) ; ahklint-ignore: W002
			tzi.explode(_tzi)
			this.assertEquals(tzi.Bias, -60)
			this.assertEquals(tzi.StandardName, "Mitteleuropäische Zeit")
			this.assertEquals(tzi.StandardDate.wYear, 0)
			this.assertEquals(tzi.StandardDate.wMonth, 10)
			this.assertEquals(tzi.StandardDate.wDayOfWeek, 0)
			this.assertEquals(tzi.StandardDate.wDay, 5)
			this.assertEquals(tzi.StandardDate.wHour, 3)
			this.assertEquals(tzi.StandardDate.wMinute, 0)
			this.assertEquals(tzi.StandardDate.wSecond, 0)
			this.assertEquals(tzi.StandardDate.wMilliseconds, 0)
			this.assertEquals(tzi.StandardBias, 0)
			this.assertEquals(tzi.DaylightName, "Mitteleuropäische Sommerzeit")
			this.assertEquals(tzi.DaylightDate.wYear, 0)
			this.assertEquals(tzi.DaylightDate.wMonth, 3)
			this.assertEquals(tzi.DaylightDate.wDayOfWeek, 0)
			this.assertEquals(tzi.DaylightDate.wDay, 5)
			this.assertEquals(tzi.DaylightDate.wHour, 2)
			this.assertEquals(tzi.DaylightDate.wMinute, 0)
			this.assertEquals(tzi.DaylightDate.wSecond, 0)
			this.assertEquals(tzi.DaylightDate.wMilliseconds, 0)
			this.assertEquals(tzi.DaylightBias, -60)
		}
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