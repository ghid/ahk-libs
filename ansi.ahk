﻿class Ansi {
	
	version() {
		return "1.0.3"
	}

	requires() {
		return [Console, Math, Arrays]
	}

	static codePage := Ansi.__initCodePage()
	static ansiExit := Ansi.__onExit()
	static stdOut := Ansi.__initStdOut()
	static stdErr := Ansi.__initStdErr()
	static stdIn := Ansi.__initStdIn()
	static hasAnsiSupport := Ansi.__initAnsiSupport()
	static ESC := ""
	static ANSI_SEQ_REGEX := "\x1b\[([0-9a-fA-FxX;]+)*([HfABCDEFGsuJKmn])"
	static NEWLINE := "`n"
	static EMPTY_STRING := ""
	static RANGE_OF_UNREADABLE_CHARS_REGEX := "[\x{0000}-\x{001a}"
			. "\x{001c}-\x{001f}"
			. "\x{007f}-\x{ffff}]"
	static NO_BUFFER := false
	static CURSOR_HIDDEN := false

	static ATTR_OFF := 0
	static ATTR_BOLD := 1
	static ATTR_ITALIC := 3
	static ATTR_UNDERSCORE := 4
	static ATTR_UNDERLINE := 4
	static ATTR_BLINK := 5
	static ATTR_REVERSE := 7
	static ATTR_IMAGE_NEG := 7
	static ATTR_CONCEALED := 8
	static ATTR_IMAGE_POS := 27
	static FOREGROUND_BLACK := 30
	static FOREGROUND_RED := 31
	static FOREGROUND_GREEN := 32
	static FOREGROUND_YELLOW := 33
	static FOREGROUND_BLUE := 34
	static FOREGROUND_MAGENTA := 35
	static FOREGROUND_CYAN := 36
	static FOREGROUND_WHITE := 37
	static BACKGROUND_BLACK := 40
	static BACKGROUND_RED := 41
	static BACKGROUND_GREEN := 42
	static BACKGROUND_YELLOW := 43
	static BACKGROUND_BLUE := 44
	static BACKGROUND_MAGENTA := 45
	static BACKGROUND_CYAN := 46
	static BACKGROUND_WHITE := 47
	static FOREGROUND_BRIGHT_BLACK := 90
	static FOREGROUND_BRIGHT_RED := 91
	static FOREGROUND_BRIGHT_GREEN := 92
	static FOREGROUND_BRIGHT_YELLOW := 93
	static FOREGROUND_BRIGHT_BLUE := 94
	static FOREGROUND_BRIGHT_MAGENTA := 95
	static FOREGROUND_BRIGHT_CYAN := 96
	static FOREGROUND_BRIGHT_WHITE := 97
	static BACKGROUND_BRIGHT_BLACK := 100
	static BACKGROUND_BRIGHT_RED := 101
	static BACKGROUND_BRIGHT_GREEN := 102
	static BACKGROUND_BRIGHT_YELLOW := 103
	static BACKGROUND_BRIGHT_BLUE := 104
	static BACKGROUND_BRIGHT_MAGENTA := 105
	static BACKGROUND_BRIGHT_CYAN := 106
	static BACKGROUND_BRIGHT_WHITE := 107

	__initStdOut() {
		OutputDebug % A_ThisFunc ": Ansi.codePage = " Ansi.codePage
		h := FileOpen("*", "w `n", Ansi.codePage)
		h.read(0)
		return h
	}

	__initStdErr() {
		h := FileOpen("**", "w", Ansi.codePage)
		h.read(0)
		return h
	}

	__initStdIn() {
		if (Console.hStdIn) {
			Console.hStdIn.close()
		}
		h := FileOpen("*", "r `n", Ansi.codePage)
		h.write(0)
		return h
	}

	__initCodePage() {
		codePage := DllCall("GetConsoleCP", "UInt")
		if (codePage == 0) {
			OutputDebug %A_ThisFunc%: Windows-Error: %A_LastError%
			codePage := 850
		}
		return "cp" codepage
	}

	__initAnsiSupport() {
		EnvGet da, DISABLE_ANSI
		EnvGet shell, SHELL
		if (RegExMatch(A_OSVersion, "^10\.") || shell != "") {
			return true && (!da)
		}
		EnvGet ansicon_version, ANSICON_VER
		return ansicon_version && (!da)
	}

	__new() {
		throw Exception("Instantiation of class 'a"
				. this.__Class "' ist not allowed", -1)
	}

	__onExit() {
		OnExit("Ansi.ExitFunc")
		return "Ansi.ExitFunc"
	}

	setEncoding(codePage) {
		Ansi.codePage := codePage
		Ansi.setOut.close()
		Ansi.stdOut := Ansi.__initStdOut()
		Ansi.stdErr.close()
		Ansi.stdErr := Ansi.__initStdErr()
		Ansi.stdIn.close()
		Ansi.stdIn := Ansi.__initStdIn()
	}

	exitFunc(reason=0, code=0) {
		if (Ansi.CURSOR_HIDDEN) {
			Ansi.write(Ansi.showCursor())
		}
		Ansi.flush()
		Ansi.stdOut.close()
	}

	write(string, writeTo="") {
		output := writeTo != "" ? writeTo : Ansi.stdOut
		if (Ansi.hasAnsiSupport) {
			output.write(string)
			if (Ansi.NO_BUFFER) {
				Ansi.flush()
			}
			return Ansi.plainStrLen(string)
		}
		return Console.writeAndTranslateAnsiSequences(string)
	}

	writeLine(string="", flushImmediate=false, writeTo="") {
		stringWithNewLine := Ansi.write(string "`n", writeTo)
		if (flushImmediate || Ansi.NO_BUFFER) {
			Ansi.flush()
		}
		return stringWithNewLine
	}

	writeError(string) {
		return Ansi.write(string, Ansi.stdErr)
	}

	writeErrorLine(string) {
		return Ansi.write(string "`n", Ansi.stdErr)
	}

	wordWrap(inputString, desiredWidth) {
		return Ansi.wrap(inputString, desiredWidth, true)
	}

	wrap(inputString, desiredWidth, useWordWrapping=false) {
		resultString := inputString
		startAt := 1
		while (startAt < Ansi.plainStrLen(resultString) - desiredWidth + 1) {
			lookAtString := SubStr(Ansi.plainStr(resultString)
					, startAt, desiredWidth + 1)
			newLineAt := RegExMatch(lookAtString, "O).*?[\r\n]", newLine)
			if (newLineAt) {
				resultString .= newLine
				startAt += (newLineAt + newLine.len - 1)
			} else {
				aSpaceToReplaceWithNewlineAt
						:= RegExMatch(lookAtString, "\s+[^\s]*$")
				if (useWordWrapping && aSpaceToReplaceWithNewlineAt) {
					replaceAt := startAt + aSpaceToReplaceWithNewlineAt - 1
					resultString := Ansi.plainStrReplaceStr(resultString
							, replaceAt, Ansi.NEWLINE)
					startAt += aSpaceToReplaceWithNewlineAt
				} else {
					insertAt := startAt + desiredWidth
					resultString := Ansi.plainStrInsert(resultString, insertAt
							, Ansi.NEWLINE)
					startAt += desiredWidth + 1
				}
			}
		}
		return resultString
	}

	readLine(pbMultiLine=false, ByRef pstLine="") {
		pstLine := ""
		loop {
			Ansi.stdOut.read(0)
			line := RTrim(Ansi.stdIn.readLine(), "`n`r")
			pstLine .= line
			Ansi.stdOut.read(0)
		} until (StrLen(line) = 0 || pbMultiLine = false)
		return line
	}

	readable(st, emph=true) {
		while (RegExMatch(st, Ansi.RANGE_OF_UNREADABLE_CHARS_REGEX, $)) {
			if (emph) {
				subst := Ansi.setGraphic(Ansi.ATTR_IMAGE_NEG)
						. "<" (Asc($)).asHex(String.ASHEX_NOPREFIX, 2)
						. ">" Ansi.setGraphic(Ansi.ATTR_IMAGE_POS)
			} else {
				subst := "<" (Asc($)).asHex(String.ASHEX_NOPREFIX, 2) ">"
			}
			st := StrReplace(st, $, subst)
		}
		return st
	}

	cursorPosition(line=0, column=0) {
		return Ansi.ESC "[" line ";" column "H"
	}

	cursorUp(value=1) {
		return Ansi.ESC "[" value "A"
	}

	cursorDown(value=1) {
		return Ansi.ESC "[" value "B"
	}

	cursorForward(value=1) {
		return Ansi.ESC "[" value "C"
	}

	cursorBackward(value=1) {
		return Ansi.ESC "[" value "D"
	}

	cursorNexLine(value=1) {
		return Ansi.ESC "[" value "E"
	}

	cursorPreviousLine(value=1) {
		return Ansi.ESC "[" value "F"
	}

	cursorHorizontalAbs(value) {
		return Ansi.ESC "[" value "G"
	}

	saveCursorPosition() {
		return Ansi.ESC "[s"
	}

	restoreCursorPosition() {
		return Ansi.ESC "[u"
	}

	eraseDisplay(value=2) {
		return Ansi.ESC "[" value "J"
	}

	eraseLine(value="") {
		return Ansi.ESC "[" value "K"
	}

	setGraphic(value*) {
		ansiGraphicCodes := ""
		listOfValues := Arrays.flat(value, Math.MAX_INT)
		while (A_Index <= listOfValues.maxIndex()) {
			ansiGraphicCodes .= (A_Index = 1 ? "" : ";") listOfValues[A_Index]
		}
		return Ansi.ESC "[" ansiGraphicCodes "m"
	}

	hideCursor() {
		Ansi.CURSOR_HIDDEN := true
		return Ansi.ESC "[?25l"
	}

	showCursor() {
		Ansi.CURSOR_HIDDEN := false
		return Ansi.ESC "[?25h"
	}

	reset() {
		return Ansi.ESC "[0m"
	}

	flush() {
		Ansi.stdOut.read(0)
		Ansi.stdErr.read(0)
	}

	flushInput() {
		return DllCall("FlushConsoleInputBuffer"
				, "Ptr", Ansi.stdIn.__Handle, "Int")
	}

	plainStr(inputString) {
		return RegExReplace(inputString, Ansi.ANSI_SEQ_REGEX, "")
	}

	plainStrLen(inputString) {
		return StrLen(Ansi.plainStr(inputString))
	}

	plainSubStr(inputString, start, length="") {
		textParts := inputString.split(Ansi.ANSI_SEQ_REGEX)
		plainText := Arrays.toString(textParts.surround, "")
		return SubStr(plainText, start, length)
	}

	plainStrInsert(inputString, atPosition, newSubstring) {
		atPosition := Math.limitTo(atPosition, 1, StrLen(inputString) + 1)
		replaceAt := Ansi.findPositionToReplaceAt(inputString, atPosition)
		resultString := SubStr(inputString, 1, replaceAt - 1)
				. newSubstring
				. SubStr(inputString, replaceAt)
		return resultString
	}

	plainStrReplaceStr(inputString, atPosition, newSubstring) {
		atPosition := Math.limitTo(atPosition, 1, StrLen(inputString))
		replaceAt := Ansi.findPositionToReplaceAt(inputString, atPosition)
		resultString := SubStr(inputString, 1, replaceAt - 1)
				. newSubstring
				. SubStr(inputString, replaceAt + StrLen(newSubstring))
		return resultString
	}

	findPostionsOfAnsiSequences(inputString) {
		startAt := 1
		positionsOfAnsiSequences := []
		while (ansiSequenceFoundAt := RegExMatch(inputString
				, "O)" Ansi.ANSI_SEQ_REGEX
				, ansiSequence, startAt)) {
			startAt := ansiSequenceFoundAt + ansiSequence.len
			positionsOfAnsiSequences.push({position: ansiSequence.pos
					, length: ansiSequence.len})
		}
		return positionsOfAnsiSequences
	}

	findPositionToReplaceAt(inputString, atPosition) {
		positionsOfAnsiSequences
				:= Ansi.findPostionsOfAnsiSequences(inputString)
		replaceAt := Ansi.transistPosition(inputString, atPosition
				, positionsOfAnsiSequences)
		return replaceAt
	}

	transistPosition(inputString, position, positionsOfAnsiSequences) {
		if (positionsOfAnsiSequences.maxIndex()) {
			while (position >= positionsOfAnsiSequences[A_Index].position
					&& position < StrLen(inputString)
					&& A_Index <= positionsOfAnsiSequences.maxIndex()) {
				position += positionsOfAnsiSequences[A_Index].length
			}
		}
		return position
	}
}
