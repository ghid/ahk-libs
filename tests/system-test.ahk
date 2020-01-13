; ahk: console
#NoEnv
#Warn All, StdOut

#Include <testcase-libs>

#Include %A_ScriptDir%\..\system.ahk

global G_target, G_target_addr, G_1st_addr

class SystemTest extends TestCase {

	@BeforeClass_Setup() {
		FileAppend % "Test for " A_ScriptFullPath
				, %A_Temp%\SystemTest_File1.txt
	}

	@AfterClass_Teardown() {
		FileDelete %A_Temp%\SystemTest_*.*
	}

	@Test_FormatMessage_Constants() {
		this.assertEquals(System.FORMAT_MESSAGE_ALLOCATE_BUFFER, 0x00000100)
		this.assertEquals(System.FORMAT_MESSAGE_ARGUMENT_ARRAY, 0x00002000)
		this.assertEquals(System.FORMAT_MESSAGE_FROM_HMODULE, 0x00000800)
		this.assertEquals(System.FORMAT_MESSAGE_FROM_STRING, 0x00000400)
		this.assertEquals(System.FORMAT_MESSAGE_FROM_SYSTEM, 0x00001000)
		this.assertEquals(System.FORMAT_MESSAGE_IGNORE_INSERTS, 0x00000200)
		this.assertEquals(System.FORMAT_MESSAGE_MAX_WIDTH_MASK, 0x000000FF)
	}

	@Test__New() {
		this.assertException(System, "__New")
		this.assertTrue(IsObject(System))
	}

	@Test_GetLastError() {
		this.assertTrue(System.getLastError() >= 0)
		this.assertEquals(System.getLastError(), A_LastError)
	}

	@Test_FormatMessage_FROM_SYSTEM() {
		nChars := System.formatMessage(System.FORMAT_MESSAGE_FROM_SYSTEM
				, 0, 133, 0x0407, buffer, 150)
		this.assertEquals(nChars, 127)
		this.assertEquals(buffer, "Ein JOIN- oder SUBST-Befehl kann nicht für "
				. "ein Laufwerk verwendet werden, das bereits mit JOIN "
				. "zugeordnete Laufwerke enthält.`r`n")

		nChars := System.formatMessage(System.FORMAT_MESSAGE_FROM_SYSTEM
				, 0, 133, 0x0407, buffer, 50)
		this.assertEquals(nChars, 0)
		this.assertEquals(buffer, "Ein JOIN- oder SUBST-Befehl kann nicht für "
				. "ein Laufwerk verwendet werden, das bereits mit JOIN zuge")

		nChars := System.formatMessage(System.FORMAT_MESSAGE_FROM_SYSTEM
				, 0, 133, 0x0409, buffer, 150)
		this.assertEquals(nChars, 92)
		this.assertEquals(buffer, "A JOIN or SUBST command cannot be used for "
				. "a drive that contains previously joined drives.`r`n")
	}

	@Test_FormatMessage_FROM_STRING() {
		pMessage := "My Test Message"
		nChars := System.formatMessage(System.FORMAT_MESSAGE_FROM_STRING
				| System.FORMAT_MESSAGE_ARGUMENT_ARRAY
				, &pMessage
				, 0
				, 0
				, buffer
				, 101)
		this.assertEquals(nChars, 15)
		this.assertEquals(buffer, pMessage)

		pMessage := "%1 %2 %3 %4 %5 %6"
		nChars := System.formatMessage(System.FORMAT_MESSAGE_FROM_STRING
				| System.FORMAT_MESSAGE_ARGUMENT_ARRAY
				, &pMessage
				, 0
				, 0
				, buffer
				, 101
				, &P1:=4, &P2:=2, &P3:="Bill", &P4:="Bob", &P5:=6, &P6:="Bill")
		this.assertEquals(nChars, 19)
		this.assertEquals(buffer, "4 2 Bill Bob 6 Bill")

		pMessage := "%1!*.*s! %4 %5!*s!"
		nChars := System.formatMessage(System.FORMAT_MESSAGE_FROM_STRING
				| System.FORMAT_MESSAGE_ARGUMENT_ARRAY
				, &pMessage
				, 0
				, 0
				, buffer
				, 101
				, 4, 2, &P3:="Bill", &P4:="Bob", 6, &P6:="Bill")
		this.assertEquals(nChars, 15)
		this.assertEquals(buffer, "  Bi Bob   Bill")

		nChars := System.formatMessage(System.FORMAT_MESSAGE_FROM_STRING
				| System.FORMAT_MESSAGE_ARGUMENT_ARRAY
				, &pMessage
				, 0
				, 0
				, buffer
				, 5
				, 4, 2, &P3:="Bill", &P4:="Bob", 6, &P6:="Bill")
		this.assertEquals(nChars, 0)
		this.assertEquals(buffer, "  Bi Bob ")
	}

	@Test_NewUUID() {
		this.assertTrue(RegExMatch(System.newUUID()
				, "i)^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$"))
	}

	@Test_ptrListToStrArray() {
		VarSetCapacity(pList, A_PtrSize*(6), 0)
		s1 := "Anne"
		s2 := "Bob"
		s3 := "Charlie"
		s4 := "David"
		s5 := "Eddie"
		_ofs := 0
		NumPut(&s1, pList, _ofs, "Ptr")
		NumPut(&s2, pList, _ofs+=A_PtrSize, "Ptr")
		NumPut(&s3, pList, _ofs+=A_PtrSize, "Ptr")
		NumPut(&s4, pList, _ofs+=A_PtrSize, "Ptr")
		NumPut(&s5, pList, _ofs+=A_PtrSize, "Ptr")
		; OutputDebug % LoggingHelper.HexDump(&pList, 0, A_PtrSize*6)
		a := System.ptrListToStrArray(&pList)
		this.assertEquals(a.maxIndex(), 6)
		this.assertEquals(a[1], s1)
		this.assertEquals(a[2], s2)
		this.assertEquals(a[3], s3)
		this.assertEquals(a[4], s4)
		this.assertEquals(a[5], s5)
	}

	@Test_StrArrayToPtrList() {
		a := ["Anne", "Bob", "Charlie", "David", "Eddie"]
		s := System.strArrayToPtrList(a, ptr)
		_ofs := 0
		a1 := NumGet(&ptr, _ofs, "Ptr")
		a2 := NumGet(&ptr, _ofs+=A_PtrSize, "Ptr")
		a3 := NumGet(&ptr, _ofs+=A_PtrSize, "Ptr")
		a4 := NumGet(&ptr, _ofs+=A_PtrSize, "Ptr")
		a5 := NumGet(&ptr, _ofs+=A_PtrSize, "Ptr")
		this.assertEquals(s, (a.count()+1)*A_PtrSize)
		this.assertEquals(StrGet(a1), "Anne")
		this.assertEquals(StrGet(a2), "Bob")
		this.assertEquals(StrGet(a3), "Charlie")
		this.assertEquals(StrGet(a4), "David")
		this.assertEquals(StrGet(a5), "Eddie")
	}

	@Test_StrArrayToPtrListAndBack() {
		a1 := ["Arthur", "Ford", "Trillian", "Marvin", "Zaphod", ""]
		System.strArrayToPtrList(a1, pl)
		a2 := System.ptrListToStrArray(&pl)
		this.assertEquals(a2.maxIndex(), a1.maxIndex())
		this.assertEquals(a2[1], a1[1])
		this.assertEquals(a2[2], a1[2])
		this.assertEquals(a2[3], a1[3])
		this.assertEquals(a2[4], a1[4])
		this.assertEquals(a2[5], a1[5])
		this.assertEquals(a2[6], a1[6])
	}

	@Test_StrArrayToPtrListAndBack1() {
		a1 := ["Arthur"]
		System.strArrayToPtrList(a1, pl)
		a2 := System.ptrListToStrArray(&pl)
		this.assertEquals(a2.maxIndex(), 2)
		this.assertEquals(a2[1], a1[1])
		this.assertEquals(a2[2], "")
	}

	@Test_StrArrayToPtrListAndBackAsObject() {
		o := { d: "Dummy"
				, a: ["Merkur", "Venus", "Erde", "Mars", "Jupiter", "Saturn"
				, "Uranus", "Neptun", "Pluto", ""]
				, x: 42 }
		System.strArrayToPtrList(o.a, pl)
		a := System.ptrListToStrArray(&pl)
		this.assertEquals(a.maxIndex(), o.a.maxIndex())
		this.assertEquals(a[1], o.a[1])
		this.assertEquals(a[2], o.a[2])
		this.assertEquals(a[3], o.a[3])
		this.assertEquals(a[4], o.a[4])
		this.assertEquals(a[5], o.a[5])
		this.assertEquals(a[6], o.a[6])
		this.assertEquals(a[7], o.a[7])
		this.assertEquals(a[8], o.a[8])
		this.assertEquals(a[9], o.a[9])
	}

	@Test_StrArrayToStrArrayList() {
		a := ["Alpha", "Bravo", "Charlie", "Echo"]
		s := System.strArrayToStrArrayList(a, sal)
		this.assertTrue(s = (A_IsUnicode ? 52 : 26))

		a2 := ["One"]
		s2 := System.strArrayToStrArrayList(a2, sal2)
		this.assertTrue(s2 = (A_IsUnicode ? 10 : 6))
	}

	@Test_PtrList() {
		a1 := "a"
		a2 := "bb"
		a3 := "ccc"
		a4 := "dddd"
		s := System.ptrList(pl, &a1, &a2, &a3, &a4, 0)
		this.assertEquals(s, 5 * A_PtrSize)
		_ofs := 0
		p1 := NumGet(&pl+0, _ofs, "Ptr")
		p2 := NumGet(&pl+0, _ofs+=A_PtrSize, "Ptr")
		p3 := NumGet(&pl+0, _ofs+=A_PtrSize, "Ptr")
		p4 := NumGet(&pl+0, _ofs+=A_PtrSize, "Ptr")
		p5 := NumGet(&pl+0, _ofs+=A_PtrSize, "Ptr")
		this.assertEquals(p1, &a1)
		this.assertEquals(p2, &a2)
		this.assertEquals(p3, &a3)
		this.assertEquals(p4, &a4)
		this.assertEquals(p5, 0)
		this.assertEquals(StrGet(p1), "a")
		this.assertEquals(StrGet(p2), "bb")
		this.assertEquals(StrGet(p3), "ccc")
		this.assertEquals(StrGet(p4), "dddd")
	}

	@Test_Which() {
		EnvGet path, PATH
		EnvGet pathext, PATHEXT
		this.assertEqualsIgnoreCase(System.which("cmd", path, pathext)
				, A_WinDir "\system32\cmd.EXE")
		this.assertEquals(System.which(A_WinDir "\system32\cmd", path, pathext)
				, A_WinDir "\system32\cmd.EXE")
		this.assertEquals(System.which("SystemTest_File1.txt", A_Temp)
				, A_Temp "\SystemTest_File1.txt")
		this.assertEquals(System.which("SystemTest_File1", A_Temp, "txt")
				, A_Temp "\SystemTest_File1.txt")
	}

	@Test_EnvGet() {
		EnvGet path, PATH
		this.assertEquals(System.envGet("PATH"), path)
	}

	@Test_TypeOf() {
		this.assertTrue(Arrays.equal(System.typeOf(13)
				, ["integer", "number", "digit", "xdigit", "alnum"]))
		this.assertTrue(System.typeOf(13, "integer"))
		this.assertTrue(System.typeOf(13, "number"))
		this.assertTrue(System.typeOf(13, "digit"))
		this.assertTrue(System.typeOf(13, "xdigit"))
		this.assertFalse(System.typeOf(13, "float"))
		this.assertTrue(Arrays.equal(System.typeOf(" 13 ")
				, ["integer", "number"]))
		this.assertTrue(Arrays.equal(System.typeOf(-42), ["integer", "number"]))
		this.assertTrue(Arrays.equal(System.typeOf(3.14), ["float", "number"]))
		this.assertTrue(System.typeOf(3.14, "float"))
		this.assertTrue(Arrays.equal(System.typeOf(.5), ["float", "number"]))
		this.assertTrue(Arrays.equal(System.typeOf(-123.456)
				, ["float", "number"]))
		this.assertTrue(Arrays.equal(System.typeOf("0x1234567890abcdef")
				, ["integer", "number", "xdigit", "alnum"]))
		this.assertTrue(System.typeOf("0x1234567890abcdef", "xdigit"))
		this.assertTrue(Arrays.equal(System.typeOf("abc")
				, ["xdigit", "alpha", "lower", "alnum"]))
		this.assertTrue(System.typeOf("abc", "alpha"))
		this.assertTrue(System.typeOf("abc", "alnum"))
		this.assertTrue(System.typeOf("abc", "lower"))
		this.assertTrue(Arrays.equal(System.typeOf("Xyz"), ["alpha", "alnum"]))
		this.assertTrue(Arrays.equal(System.typeOf("SRP")
				, ["alpha", "upper", "alnum"]))
		this.assertTrue(System.typeOf("SRP", "upper"))
		this.assertTrue(Arrays.equal(System.typeOf(" `t`n`r`v"), ["space"]))
		this.assertTrue(System.typeOf("   ", "space"))
		this.assertTrue(System.typeOf(A_Now, "time"))
		this.assertTrue(System.typeOf({}, "object"))
	}

	@Test_ArrayCopy() {
		a1 := [ 0, 1, 2, 3, 4, 5 ]
		a2 := [ 5, 10, 20, 30, 40, 50 ]
		System.arrayCopy(a1, 1, a2, 1, 3)
		this.assertEquals(a2[1], 0)
		this.assertEquals(a2[2], 1)
		this.assertEquals(a2[3], 2)
		this.assertEquals(a2[4], 30)
		this.assertEquals(a2[5], 40)
		this.assertEquals(a2[6], 50)
		this.assertEquals(a2[7], "")
	}

	@Test_runProcess() {
		this.assertEquals(System.runProcess("hostname")
				, System.envGet("COMPUTERNAME") "`r`n")
	}
}

exitapp SystemTest.runTests()
; vim: ts=4:sts=4:sw=4:tw=0:noet
