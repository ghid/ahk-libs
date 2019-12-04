; ahk: console
#Warn All, StdOut

#Include <ansi>
#Include <arrays>
#Include <datatable>
#Include <object>
#Include <math>
#Include <string>
#Include <structure>
#Include <testcase>

#Include %A_ScriptDir%\..\modules\structure
#Include CONSOLE_SCREEN_BUFFER_INFO.ahk
#Include COORD.ahk
#Include SMALL_RECT.ahk

#Include %A_ScriptDir%\..\console.ahk

class ConsoleTest extends TestCase {

	requires() {
		return [TestCase, Console]
	}

	@Test_Constants() {
		this.assertEquals(Console.STD_INPUT_HANDLE,  -10)
		this.assertEquals(Console.STD_OUTPUT_HANDLE, -11)
		this.assertEquals(Console.STD_ERROR_HANDLE,  -12)
	}

	@Test_Class() {
		this.assertTrue(IsFunc("Console.__New"), 0)
		this.assertTrue(IsFunc("Console.SetTextAttribute"), 1)
		this.assertException(Console, "__New")
		this.assertFalse(Console.hConsoleHandle = 0)
	}

	@Test_Write() {
		this.assertEquals(Console.write("TEST"), 4)
	}
}

exitapp ConsoleTest.runTests()
