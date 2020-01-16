; @todo: Refactor! Move helper classes inside of Pager class
#Include %A_LineFile%\..\modules\pager\
#Include actions.ahk

class Pager {

	version() {
		return "1.0.0"
	}

	requires() {
		return [Structure, CONSOLE_SCREEN_BUFFER_INFO]
	}

	static TEST_CONSOLE_HEIGHT := 24
	static TEST_CONSOLE_WIDTH := 80

	static handleOfCurrentConsoleWindow := WinExist("A")
	static lineCounter := 0
	static enablePager := true
	static scrollOneLine := false
	static runInTestMode := false
	static breakMessage := "<Press space to continue or q to quit>"

	writeHardWrapped(text) {
		wrappedText := Ansi.wrap(text, Pager.getConsoleWidth())
		Pager.lineCounter := Pager.writeText(wrappedText
				, Pager.lineCounter)
		return Pager.lineCounter
	}

	writeWordWrapped(text) {
		wordWrappedText := Ansi.wordWrap(text, Pager.getConsoleWidth())
		Pager.lineCounter := Pager.writeText(wordWrappedText
				, Pager.lineCounter)
		return Pager.lineCounter
	}

	writeText(wrappedText, lineCounter) {
		listOfLines := StrSplit(wrappedText, Ansi.NEWLINE)
		loop % listOfLines.maxIndex() {
			lineCounter := Pager.printLineAndBreak(listOfLines[A_Index]
					, lineCounter)
		}
		return lineCounter
	}

	printLineAndBreak(textToPrint, lineCounter) {
		lineCounter++
		if (Pager.enablePager && (Pager.scrollOneLine
				|| lineCounter = Pager.getConsoleHeight())) {
			Pager.break(Pager.breakMessage)
			lineCounter := 1
		}
		if (Pager.getMaxConsoleWidth()
				&& ((A_IsCompiled
				&& Ansi.plainStrLen(textToPrint) >= Pager.getMaxConsoleWidth())
				|| (Ansi.plainStrLen(textToPrint)
				> Pager.getMaxConsoleWidth()))) {
			Ansi.write(textToPrint)
		} else {
			Ansi.writeLine(textToPrint)
		}
		return lineCounter
	}

	break(breakMessage, resetLineCounter=false) {
		if (resetLineCounter) {
			Pager.lineCounter := 0
		}
		if (Pager.runInTestMode) {
			Ansi.write(Pager.breakMessage)
			Ansi.flush()
			return
		}
		Ansi.write(Ansi.saveCursorPosition() Ansi.cursorHorizontalAbs(1)
				. Ansi.reset() Ansi.eraseLine()
				. Ansi.setGraphic(Ansi.ATTR_REVERSE) breakMessage Ansi.reset()
				. Ansi.eraseLine())
		_handleOfCurrentConsoleWindow := Pager.handleOfCurrentConsoleWindow
		HotKey, IfWinActive, ahk_id %_handleOfCurrentConsoleWindow%
		HotKey, q, pagerActionQuit
		HotKey, c, pagerActionContinue
		HotKey, Space, pagerActionNextPage
		HotKey, Enter, pagerActionNextLine
		Ansi.flush()
		Pause On
	}

	; @todo: Fix access to the bufferInfo properties; these aren't correct if
	; the new Structure class is used @19-4818F
	getConsoleHeight() {
		if (Pager.runInTestMode) {
			return Pager.TEST_CONSOLE_HEIGHT
		}
		conHeight := 1 + Console.bufferInfo.window.bottom
				- Console.bufferInfo.window.top
		return conHeight
	}

	getConsoleWidth() {
		if (Pager.runInTestMode) {
			return Pager.TEST_CONSOLE_WIDTH
		}
		conWidth := 1 + Console.bufferInfo.window.right
				- Console.bufferInfo.window.left
		return conWidth
	}

	getMaxConsoleWidth() {
		if (Pager.runInTestMode) {
			return Pager.TEST_CONSOLE_WIDTH
		}
		return Console.bufferInfo.maximumWindowSize.X
	}
}
