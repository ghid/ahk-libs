; ahk: console
#NoEnv
#Warn All, StdOut

; #Include <testcase-libs>
#Include <ansi>
#Include <arrays>
#Include <console>
#Include <datatable>
#Include <object>
#Include <string>
#Include <system>
#Include <testcase>

#Include %A_ScriptDir%\..\structure.ahk

#Include %A_ScriptDir%\..\modules\structure
#Include SMALL_RECT.ahk
#Include COORD.ahk
#Include CONSOLE_SCREEN_BUFFER_INFO.ahk
#Include SYSTEMTIME.ahk
#Include TIME_ZONE_INFORMATION.ahk
#Include DYNAMIC_TIME_ZONE_INFORMATION.ahk
#Include LDAPAPIINFO.ahk
#Include LDAPMod.ahk
#Include STARTUPINFO.ahk

class StructureTest extends TestCase {

	requires() {
		return [Structure, Arrays
				, CONSOLE_SCREEN_BUFFER_INFO
				, DYNAMIC_TIME_ZONE_INFORMATION
				, SMALL_RECT, SYSTEMTIME
				, TIME_ZONE_INFORMATION
				, LDAPAPIINFO
				, LDAPMod]

	}

	@Test_typeLength() {
		this.assertEquals(Structure.typeLength("Str"), 0)
		this.assertEquals(Structure.typeLength("str"), 0)
		this.assertEquals(Structure.typeLength("wStr"), 0)
		this.assertEquals(Structure.typeLength("AStr"), 0)
		this.assertEquals(Structure.typeLength("Char"), 1)
		this.assertEquals(Structure.typeLength("CharP"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Char*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UChar"), 1)
		this.assertEquals(Structure.typeLength("UCharP"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UChar*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Short"), 2)
		this.assertEquals(Structure.typeLength("ShortP"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Short*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UShort"), 2)
		this.assertEquals(Structure.typeLength("UShortP"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UShort*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Int"), 4)
		this.assertEquals(Structure.typeLength("IntP"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Int*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UInt"), 4)
		this.assertEquals(Structure.typeLength("UIntP"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UInt*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Int64"), 8)
		this.assertEquals(Structure.typeLength("Int64P"), A_PtrSize)
		this.assertEquals(Structure.typeLength("Int64*"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UInt64"), 8)
		this.assertEquals(Structure.typeLength("UInt64P"), A_PtrSize)
		this.assertEquals(Structure.typeLength("UInt64*"), A_PtrSize)
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
		ba := Structure.putData(ba, "x", "Short", 770, "", "")
		this.assertTrue(Arrays.equal(ba, [1,2,3]))
		ba := Structure.putData(ba, "x", "UInt", 42, "", "")
		this.assertTrue(Arrays.equal(ba, [1,2,3,42,0,0,0]))
		ba := Structure.putData(ba, "x", "Short", -1303, "", "")
		this.assertTrue(Arrays.equal(ba, [1,2,3,42,0,0,0,233,250]))
		ba := []
		ba := Structure.putData(ba, "x", "Str", "foo bar", "", "")
		this.assertTrue(Arrays.equal(ba
				, [102,0,111,0,111,0,32,0,98,0,97,0,114,0]))
		ba := []
		ba := Structure.putData(ba, "x", "Str", "foo bar", 3, "")
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
		this.assertSame(z.implode(_z), z)
		this.assertEquals(NumGet(_z, 0, "Short"), 1)
		this.assertEquals(NumGet(_z, 2, "Int"), 2)
		this.assertEquals(NumGet(_z, 6, "UInt"), 0)
		this.assertEquals(NumGet(_z, 10, "UInt"), 4)
		NumPut(3, _z, 6, "UInt")
		z2 := new TESTSTRUCT_B()
		this.assertSame(z2.explode(_z), z2)
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
		tzi := new TIME_ZONE_INFORMATION().implode(_tzi)
		if (DllCall("GetTimeZoneInformation", "UInt", &_tzi, "UInt")) {
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

	@Test_DYNAMIC_TIME_ZONE_INFORMATION() {
		dtzi := new DYNAMIC_TIME_ZONE_INFORMATION().implode(_dtzi)
		this.assertTrue(DllCall("api-ms-win-core-timezone-l1-1-0\"
				. "EnumDynamicTimeZoneInformation"
				, "UInt", 1
				, "Ptr", &_dtzi) == 0)
		dtzi.explode(_dtzi)
		this.assertEquals(dtzi.StandardName, "Alaska Normalzeit")
		this.assertEquals(dtzi.Bias, 540)
		this.assertEquals(dtzi.StandardDate.wYear, 0)
		this.assertEquals(dtzi.StandardDate.wMonth, 11)
		this.assertEquals(dtzi.StandardDate.wDayOfWeek, 0)
		this.assertEquals(dtzi.StandardDate.wDay, 1)
		this.assertEquals(dtzi.StandardDate.wHour, 2)
		this.assertEquals(dtzi.StandardDate.wMinute, 0)
		this.assertEquals(dtzi.StandardDate.wSecond, 0)
		this.assertEquals(dtzi.StandardDate.wMilliseconds, 0)
		this.assertEquals(dtzi.StandardBias, 0)
		this.assertEquals(dtzi.DaylightName, "Alaska Sommerzeit")
		this.assertEquals(dtzi.DaylightDate.wYear, 0)
		this.assertEquals(dtzi.DaylightDate.wMonth, 3)
		this.assertEquals(dtzi.DaylightDate.wDayOfWeek, 0)
		this.assertEquals(dtzi.DaylightDate.wDay, 2)
		this.assertEquals(dtzi.DaylightDate.wHour, 2)
		this.assertEquals(dtzi.DaylightDate.wMinute, 0)
		this.assertEquals(dtzi.DaylightDate.wSecond, 0)
		this.assertEquals(dtzi.DaylightDate.wMilliseconds, 0)
		this.assertEquals(dtzi.DaylightBias, -60)
		this.assertEquals(dtzi.TimeZoneKeyName, "Alaskan Standard Time")
		this.assertEquals(dtzi.DynamicDaylighTimeDisabled, 0)
	}

	@Test_LDAPAPIINFO() {
		lai := new LDAPAPIINFO()
		this.assertEquals(lai.sizeOf(), 16+2*A_PtrSize)
		lai.ldapai_info_version := 1
		lai.ldapai_api_version := 42
		lai.ldapai_protocol_version := 2
		lai.ldapai_extensions := ["FIRST EXT", "SECOND EXT"]
		lai.ldapai_vendor_name := "FooBar Inc."
		lai.ldapai_vendor_version := 567
		lai.implode(_lai)
		lai2 := new LDAPAPIINFO()
		lai2.explode(_lai)
		this.assertEquals(lai.ldapai_info_version, lai2.ldapai_info_version)
		this.assertEquals(lai.ldapai_api_version, lai2.ldapai_api_version)
		this.assertEquals(lai.ldapai_protocol_version
				, lai2.ldapai_protocol_version)
		this.assertEquals(lai.ldapai_extensions_ptr, lai2.ldapai_extensions_ptr)
		this.assertEquals(lai.ldapai_vendor_name, lai2.ldapai_vendor_name)
		this.assertEquals(lai.ldapai_vendor_version, lai2.ldapai_vendor_version)
		this.assertTrue(Arrays.equal(lai.ldapai_extensions
				, lai2.ldapai_extensions))
		lai2.ldapai_extensions.push("TEST2")
		this.assertFalse(Arrays.equal(lai.ldapai_extensions
				, lai2.ldapai_extensions))
	}

	@Test_LDAPMod() {
		lm := new LDAPMod()
		lm.mod_op := 2
		lm.mod_type := "title"
		lm.mod_vals := ["First Title", "Second Title", "Third Title"]
		lm.implode(_lm)
		this.assertEquals(StrGet(NumGet(lm.mod_vals_ptr+0))
				, (lm.mod_vals)[1])
		this.assertEquals(StrGet(NumGet(lm.mod_vals_ptr+A_PtrSize))
				, (lm.mod_vals)[2])
		this.assertEquals(StrGet(NumGet(lm.mod_vals_ptr+2*A_PtrSize))
				, (lm.mod_vals)[3])
		lm2 := new LDAPMod()
		lm2.explode(_lm)
		this.assertEquals(lm.mod_op, lm2.mod_op)
		this.assertEquals(lm.mod_type, lm2.mod_type)
		this.assertEquals(lm2.mod_vals.count(), 3)
		this.assertTrue(Arrays.equal(lm.mod_vals, lm2.mod_vals))
		lm3 := new LDAPMod({mod_op: 3, mod_type: "title"
				, mod_vals: ["Title One", "Title Two"]})
		this.assertEquals(lm3.mod_op, 3)
		this.assertEquals(lm3.mod_type, "title")
		this.assertEquals(Arrays.equal(lm3.mod_vals
				, ["Title One", "Title Two"]))
	}

	@Test_STARTUPINFO() {
		si := new STARTUPINFO()
		si.reserved := 1
		si.desktop := 2
		si.title := 3
		si.x := 4
		si.y := 5
		si.xSize := 6
		si.ySize := 7
		si.xCountChars := 8
		si.yCountChars := 9
		si.fillAttribute := 10
		si.flags := 11
		si.showWindow := 12
		si.cbReserved2 := 13
		si.lpReserved2 := 14
		si.stdInput := 15
		si.stdOutput := 16
		si.stdErr := 17
		si.implode(_si)
		si2 := new STARTUPINFO().implode(_si2)
		DllCall("GetStartupInfo" (A_IsUnicode ? "W" : "A"), "Ptr", &_si2)
		si2.explode(_si2)
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
