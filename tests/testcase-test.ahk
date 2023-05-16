;@Ahk2Exe-ConsoleApp
#Warn All, StdOut

#Include <ansi>
#Include <arrays>
#Include <console>
#Include <datatable>
#Include <math>
#Include <string>
#Include <object>
#Include <structure>

#Include <modules\structure\CONSOLE_SCREEN_BUFFER_INFO>
#Include <modules\structure\COORD>
#Include <modules\structure\SMALL_RECT>

#IncludeAgain %A_ScriptDir%\..\testcase.ahk

class TestCaseTest extends TestCase {

	requires() {
		return [TestCase]
	}

	@BeforeClassDoSomething() {
		OutputDebug % A_ThisFunc "::Just for test issue"
	}

	@BeforeDoSomethingToo() {
		OutputDebug % A_ThisFunc "::Just for test issue"
	}

	@AfterClassDoSomeMore() {
		OutputDebug % A_ThisFunc "::Just for test issue"
	}

	@AfterDoEvenMoreStuff() {
		OutputDebug % A_ThisFunc "::Just for test issue"
	}

	@Test_new() {
		this.assertException(TestCase, "__new")
	}

	@Test_assert() {
		TestCase.assert(1 == 1)
		this.assertException(TestCase, "assert",,, (0 == 1))
	}

	@Test_assertSame() {
		testObjectA := {}
		testObjectB := {}
		testObjectA´ := testObjectA
		testObjectB´ := testObjectB.clone()
		TestCase.assertSame(testObjectA, testObjectA)
		TestCase.assertSame(testObjectA, testObjectA´)
		this.assertException(TestCase, "assertSame",,, testObjectA, testObjectB)
		this.assertException(TestCase, "assertSame"
				,,, testObjectB, testObjectB´)
		this.assertException(TestCase, "assertSame",,, "no object", testObjectB)
		this.assertException(TestCase, "assertSame",,, testObjectA, "no object")
		this.assertException(TestCase, "assertSame",,, "no object", "no object")
	}

	@Test_assertEquals() {
		TestCase.assertEquals("A", "A")
		TestCase.assertEquals(42, 42)
		TestCase.assertEquals(42, +42)
		TestCase.assertEquals(42, 042)
		TestCase.assertEquals(00042.0, 42)
		TestCase.assertEquals(00042, 42.000)
		TestCase.assertEquals("00042", "42.000")
		TestCase.assertEquals("   42", " 42.000 ")
		this.assertException(TestCase, "assertEquals",,, "A", "B")
		this.assertException(TestCase, "assertEquals",,, "A", "a")
		this.assertException(TestCase, "assertEquals",,, 42, 43)
		this.assertException(TestCase, "assertEquals",,, "6", "06"
				, TestCase.compareAsString.bind(TestCase))
	}

	@Test_assertEqualsIgnoreCase() {
		TestCase.assertEqualsIgnoreCase("A", "A")
		TestCase.assertEqualsIgnoreCase(42, 42)
		TestCase.assertEqualsIgnoreCase(42, +42)
		TestCase.assertEqualsIgnoreCase(42, 042)
		TestCase.assertEqualsIgnoreCase(00042.0, 42)
		TestCase.assertEqualsIgnoreCase(00042, 42.000)
		TestCase.assertEqualsIgnoreCase("00042", "42.000")
		TestCase.assertEqualsIgnoreCase("   42", " 42.000 ")
		this.assertException(TestCase, "assertEqualsIgnoreCase",,, "A", "B")
		TestCase.assertEqualsIgnoreCase("A", "a")
		TestCase.assertEqualsIgnoreCase("a", "A")
		this.assertException(TestCase, "assertEqualsIgnoreCase",,, 42, 43)
	}

	@Test_assertTrue() {
		TestCase.assertTrue(true)
		this.assertException(TestCase, "assertTrue",,, false)
	}

	@Test_assertFalse() {
		TestCase.assertFalse(false)
		this.assertException(TestCase, "assertFalse",,, true)
	}

	@Test_assertEmpty() {
		TestCase.assertEmpty("")
		TestCase.assertEmpty(Chr(0))
		this.assertException(TestCase, "assertEmpty",,, " ")
		this.assertException(TestCase, "assertEmpty",,, "0")
	}

	@Test_assertNotEmpty() {
		TestCase.assertNotEmpty("foo")
		TestCase.assertNotEmpty(" ")
		TestCase.assertNotEmpty(0)
		this.assertException(TestCase, "assertNotEmpty",,, "")
		this.assertException(TestCase, "assertNotEmpty",,, Chr(0))
	}

	@Test_getAssertionSource() {
		this.assertEquals(TestCase.getAssertionSource("@Test_assertNotEmpty", 6)
				, "118: this.assertException(TestCase, ""assertNotEmpty"",,, Chr(0))") ; ahklint-ignore: W002
		this.assertEquals(TestCase.getAssertionSource("@Test_assertNotEmpty", 7)
				, "118: this.assertException(TestCase, ""assertNotEmpty"",,, Chr(0))") ; ahklint-ignore: W002
	}

	@Test_fail() {
		this.assertException(TestCase, "fail",,, "error", 42)
	}

	@Test_stateName() {
		this.assertEquals(TestCase.stateName(TestCase.UNKNOWN), "Unknown test")
		this.assertEquals(TestCase.stateName(TestCase.NOT_RUN), "Did not run")
		this.assertEquals(TestCase.stateName(TestCase.SUCCESSFUL), "Successful")
		this.assertEquals(TestCase.stateName(TestCase.FAILED), "Failed")
		this.assertEquals(TestCase.stateName("X"), "Unknown state: X")
		this.assertEquals(TestCase.stateName(""), "Unknown test")
	}

    @Test_assertEqualsDeepObject() {
        TestCase.assertEquals({a:1,b:{x:42,z:[1,2,3]},u:"123"},{a:1,b:{x:42,z:[0,1,2,3]},u:"123"}, TestCase.compareDeepObject.bind(TestCase))
    }

}

exitapp TestCaseTest.runTests()
