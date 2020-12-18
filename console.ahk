class Console {

	version() {
		return "1.0.1"
	}

	requires() {
		return [Structure, CONSOLE_SCREEN_BUFFER_INFO]
	}

	static STD_INPUT_HANDLE  = -10
	static STD_OUTPUT_HANDLE = -11
	static STD_ERROR_HANDLE  = -12

	static ANSI_SEQ_REGEX := "\x1b\[([0-9a-fA-FxX;]+)*([HfABCDEFGsuJKmn])"

	static hStdOut := Console.__initHandle(Console.STD_OUTPUT_HANDLE)
	static hStdErr := Console.__initHandle(Console.STD_ERROR_HANDLE)
	static hStdIn  := Console.__initHandle(Console.STD_INPUT_HANDLE)

	static bufferInfo := Console.__initBufferInfo()

	static SavedPos := [0, 0]

	static Encoding := "cp850"

	class Color {
		attributes := 0
		strText := ""

		static FOREGROUND_BLUE := 0x0001
		static FOREGROUND_GREEN := 0x0002
		static FOREGROUND_RED := 0x0004
		static BACKGROUND_BLUE := 0x0010
		static BACKGROUND_GREEN := 0x0020
		static BACKGROUND_RED := 0x0040
		static FOREGROUND_INTENSITY := 0x0008
		static BACKGROUND_INTENSITY := 0x0080
		static COMMON_LVB_LEADING_BYTE := 0x0100
		static COMMON_LVB_TRAILING_BYTE := 0x0200
		static COMMON_LVB_GRID_HORIZONTAL := 0x0400
		static COMMON_LVB_GRID_LVERTICAL := 0x0800
		static COMMON_LVB_GRID_RVERTICAL := 0x1000
		static COMMON_LVB_REVERSE_VIDEO := 0x4000
		static COMMON_LVB_UNDERSCORE := 0x8000
		static COLOR_REVERSE := 0x10000
		static COLOR_BOLD := 0x20000
		static COLOR_HIGHLIGHT	:= 0x40000
		static COLOR_NORMAL := 0x80000

		class Foreground {
			static BLACK := 0
			static BLUE := Console.Color.FOREGROUND_BLUE
			static GREEN := Console.Color.FOREGROUND_GREEN
			static TURQUOISE := Console.Color.FOREGROUND_GREEN
					| Console.Color.FOREGROUND_BLUE
			static RED := Console.Color.FOREGROUND_RED
			static PURPLE := Console.Color.FOREGROUND_RED
					| Console.Color.FOREGROUND_BLUE
			static OCHER := Console.Color.FOREGROUND_RED
					| Console.Color.FOREGROUND_GREEN
			static LIGHTGREY := Console.Color.FOREGROUND_RED
					| Console.Color.FOREGROUND_GREEN
					| Console.Color.FOREGROUND_BLUE
			static DARKGREY := Console.Color.FOREGROUND_INTENSITY
			static LIGHTBLUE := Console.Color.FOREGROUND_INTENSITY
					| Console.Color.FOREGROUND_BLUE
			static LIME := Console.Color.FOREGROUND_INTENSITY
					| Console.Color.FOREGROUND_GREEN
			static AUQA := Console.Color.FOREGROUND_INTENSITY
					| Console.Color.FOREGROUND_GREEN
					| Console.Color.FOREGROUND_BLUE
			static LIGHTRED := Console.Color.FOREGROUND_INTENSITY
					| Console.Color.FOREGROUND_RED
			static MAGENTA := Console.Color.FOREGROUND_INTENSITY
					| Console.Color.FOREGROUND_RED
					| Console.Color.FOREGROUND_BLUE
			static YELLOW := Console.Color.FOREGROUND_INTENSITY
					| Console.Color.FOREGROUND_RED
					| Console.Color.FOREGROUND_GREEN
			static WHITE := Console.Color.FOREGROUND_INTENSITY
					| Console.Color.FOREGROUND_RED
					| Console.Color.FOREGROUND_GREEN
					| Console.Color.FOREGROUND_BLUE
		}

		class Background {
			static BLACK := 0
			static BLUE := Console.Color.BACKGROUND_BLUE
			static GREEN := Console.Color.BACKGROUND_GREEN
			static TURQUOISE := Console.Color.BACKGROUND_GREEN
					| Console.Color.BACKGROUND_BLUE
			static RED := Console.Color.BACKGROUND_RED
			static PURPLE := Console.Color.BACKGROUND_RED
					| Console.Color.BACKGROUND_BLUE
			static OCHER := Console.Color.BACKGROUND_RED
					| Console.Color.BACKGROUND_GREEN
			static LIGHTGREY := Console.Color.BACKGROUND_RED
					| Console.Color.BACKGROUND_GREEN
					| Console.Color.BACKGROUND_BLUE
			static DARKGREY := Console.Color.BACKGROUND_INTENSITY
			static LIGHTBLUE := Console.Color.BACKGROUND_INTENSITY
					| Console.Color.BACKGROUND_BLUE
			static LIME := Console.Color.BACKGROUND_INTENSITY
					| Console.Color.BACKGROUND_GREEN
			static AUQA := Console.Color.BACKGROUND_INTENSITY
					| Console.Color.BACKGROUND_GREEN
					| Console.Color.BACKGROUND_BLUE
			static LIGHTRED := Console.Color.BACKGROUND_INTENSITY
					| Console.Color.BACKGROUND_RED
			static MAGENTA := Console.Color.BACKGROUND_INTENSITY
					| Console.Color.BACKGROUND_RED
					| Console.Color.BACKGROUND_BLUE
			static YELLOW := Console.Color.BACKGROUND_INTENSITY
					| Console.Color.BACKGROUND_RED
					| Console.Color.BACKGROUND_GREEN
			static WHITE := Console.Color.BACKGROUND_INTENSITY
					| Console.Color.BACKGROUND_RED
					| Console.Color.BACKGROUND_GREEN
					| Console.Color.BACKGROUND_BLUE
		}

		__new(pwAttributes, pstrText="") {
			this.attributes := pwAttributes
			this.strText := pstrText
			return this
		}

		reverse(pwAttributes="") {
			if (pwAttributes = "") {
				pwAttributes := Console.getBufferInfo().attributes
			}
			return ((pwAttributes & 0x0f)<<4) | ((pwAttributes & 0xf0)>>4)
		}

		bold(pwAttributes="") {
			if (pwAttributes = "") {
				pwAttributes := Console.getBufferInfo().attributes
			}
			return pwAttributes & 0x0f | Console.Color.FOREGROUND_INTENSITY
		}

		highlight() {
			bi := Console.getBufferInfo()
			return bi.attributes | Console.Color.BACKGROUND_INTENSITY
		}

		normal() {
			bi := Console.getBufferInfo()
			return (bi.foregroundColor()
					& ~Console.Color.FOREGROUND_INTENSITY)
					| (bi.backgroundColor()
					& ~Console.Color.BACKGROUND_INTENSITY)
		}
	}

	__initHandle(piHandle) {
		return DllCall("GetStdHandle", "UInt", piHandle, "Ptr")
	}

	__initBufferInfo() {
		; @see: https://docs.microsoft.com/en-us/windows/console/setconsolemode
		try {
			Console.setConsoleMode(Console.getConsoleMode() | 0x0004)
			return Console.getBufferInfo()
		} catch e {
			OutputDebug % A_ThisFunc ": " e.message ": " e.extra
		}
		return ""
	}

	getConsoleMode() {
		result := DllCall("GetConsoleMode"
				, "Ptr", Console.hStdOut, "ShortP", mode := 0)
		if (result) {
			return mode
		}
		throw Exception(Format("{:s}: {:i}", A_ThisFunc, A_LastError))
	}

	setConsoleMode(mode) {
		result := DllCall("SetConsoleMode"
				, "Ptr", Console.hStdOut, "UInt", mode)
		if (result) {
			return result
		}
		throw Exception(Format("{:s}: {:i}", A_ThisFunc, A_LastError))
	}

	__new() {
		throw Exception("Instantiation of class '" this.__Class
				. "' ist not allowed", -1)
	}

	write(pBuffer*) {
		n := 0
		for i, _item in pBuffer {
			if (_item.maxIndex() != "") {
				return n += Console.writeList(_item)
			}
			if (_item.__Class = "Console.Color") {
				if (_item.strText != "") {
					_currentAttributes := Console.bufferInfo.attributes
					Console.setTextAttribute(_item.attributes)
					if (Console.bufferInfo) {
						FileAppend % _item.strText, CONOUT$, % Console.encoding
					} else {
						FileAppend % _item.strText, *
					}
					Console.setTextAttribute(_currentAttributes)
				} else {
					Console.setTextAttribute(_item.attributes)
					if (Console.bufferInfo) {
						FileAppend % _item.strText, CONOUT$, % Console.encoding
					} else {
						FileAppend % _item.strText, *
					}
				}
				n += StrLen(_item.strText)
			} else {
				if (Console.bufferInfo) {
					FileAppend %_item%, CONOUT$, % Console.encoding
				} else {
					FileAppend %_item%, *
				}
				n += StrLen(_item)
			}
		}
		return n
	}

	writeAndTranslateAnsiSequences(string) {
		p := 1
		n := 0
		while (RegExMatch(string, "(.*?)" Console.ANSI_SEQ_REGEX, $, p)) {
			p += StrLen($)
			OutputDebug ::: %A_ThisFunc% ::: p=%p% -- $=%$% / $1=%$1% / $2=%$2% / $3=%$3% ; ahklint-ignore: W002
			n += Console.write($1)
			if ($3 == "H" || $3 == "f" ) {
				values := StrSplit($2, ";")
				if (values.maxIndex() > 2) {
					continue
				}
				Console.setCursorPos(values[2] = "" || values[2] = 0
						? 0 : values[2] - 1
						, values[1] = "" || values[1] = 0
						? 0 : values[1] - 1)
			} else if ($3 == "A") {
				Console.setCursorPos(0, $2 = "" ? -1 : $2 = 0 ? 0 : $2*(-1)
						, true)
			} else if ($3 == "B") {
				Console.setCursorPos(0, $2 = "" ? 1 : $2 = 0 ? 0 : $2, true)
			} else if ($3 == "C") {
				Console.setCursorPos($2 = "" ? 1 : $2 = 0 ? 0 : $2, 0, true)
			} else if ($3 == "D") {
				Console.setCursorPos($2 = "" ? -1 : $2 = 0 ? 0 : $2*(-1), 0
						, true)
			} else if ($3 == "E") {
				Console.setCursorPos("", $2 = "" ? 1 : $2 = 0 ? 0 : $2, true)
				Console.setCursorPos(0)
			} else if ($3 == "F") {
				Console.setCursorPos("", $2 = "" ? -1 : $2 = 0 ? 0 : $2*(-1)
						, true)
				Console.setCursorPos(0)
			} else if ($3 == "G") {
				Console.setCursorPos($2 - 1)
			} else if ($3 == "s") {
				Console.savePosition()
			} else if ($3 == "u") {
				Console.restorePosition()
			} else if ($3 == "J") {
				Console.clearSCR()
			} else if ($3 == "K") {
				Console.clearEOL()
			} else if ($3 = "m") {
				values := StrSplit($2, ";")
				consoleColor := new Console.Color(Console.bufferInfo.attributes)
				loop % values.maxIndex() {
					value := values[A_Index]
					OutputDebug ::: %A_ThisFunc% ::: value=%value%
					if (value = 0) {
						consoleColor.attributes := Console.bufferInfo.attributes
					} else if (value = 1) {
						consoleColor.attributes := consoleColor.attributes
								| Console.Color.FOREGROUND_INTENSITY ; ahklint-ignore: W002
					} else if (value = 7) {
						hb := consoleColor.attributes & 0xf0
						lb := consoleColor.attributes & 0xf
						consoleColor.attributes := lb<<4 | hb>>4
					} else if ((value >= 30 && value <= 37)
							|| (value >= 90 && value <= 97)) {
						consoleColor.attributes
								:= consoleColor.attributes & 0xf8
								| Console.mapColor(value)
					} else if ((value >= 40 && value <= 47)
							|| (value >= 100 && value <= 107)) {
						consoleColor.attributes
								:= consoleColor.attributes & 0xf
								| Console.mapColor(value)
					}
				}
				OutputDebug % "::: " A_ThisFunc " ::: consoleColor="
						. consoleColor.attributes
				Console.write(consoleColor, "")
			} else if ($3 = "n" && $2 = "6") {
				bi := Console.getBufferInfo()
				SendRaw % "^[[" bi.dwCursorPosition.Y+1
						. ";" bi.dwCursorPosition.X+1 "R"
			}
		}
		return n + Console.write(SubStr(string, p))
	}

	writeList(pList) {
		n := 0
		for i, _item in pList {
			n += Console.write(_item)
		}
		return n
	}

	resetColor() {
		return Console.setTextAttribute(Console.bufferInfo.attributes)
	}


	setTextAttribute(psAttributes=0, phHandle="") {
		if (phHandle = "") {
			phHandle := Console.hStdOut
		}

		_rbhn := psAttributes & 0xf0000 ; Reverse, Bold, Highlight, Normal
		if (_rbhn) {
			psAttributes := psAttributes & ~_rbhn
			if (_rbhn & Console.Color.COLOR_BOLD) {
				psAttributes := Console.Color.bold(psAttributes)
			}
			if (_rbhn & Console.Color.COLOR_HIGHLIGHT) {
				psAttributes := Console.Color.highlight(psAttributes)
			}
			if (_rbhn & Console.Color.COLOR_REVERSE) {
				psAttributes := Console.Color.reverse(psAttributes)
			}
			if (_rbhn & Console.Color.COLOR_NORMAL) {
				psAttributes := Console.Color.normal(psAttributes)
			}
		}
		if (phHandle) {
			return DllCall("SetConsoleTextAttribute", "Ptr", phHandle
					, "UShort", psAttributes, "Int")
		}
	}

	read(ByRef pBuffer, pNumberOfCharsToRead=1, pInputControlObject="") {
		if (!Console.hStdIn) {
			return throw Exception("No Standard Input availalbe", 1)
		}

		if (IsObject(pInputControlObject)) {
			pInputControlObject.get(pInputControl)
		}

		VarSetCapacity(pBuffer, pNumberOfCharsToRead * (A_IsUnicode ? 2 : 1), 0)
		VarSetCapacity(lpNumberOfCharsRead, 4, 0)
		DllCall("FlushConsoleInputBuffer", "Ptr", Console.hStdIn, "Int")
		DllCall("ReadConsole" (A_IsUnicode ? "W" : "A"), "Ptr", Console.hStdIn
				, "Ptr", &pBuffer
				, "UInt", pNumberOfCharsToRead
				, "UInt", &lpNumberOfCharsRead
				, "UInt", &pInputControl
				, "Int")
		return NumGet(lpNumberOfCharsRead, 0, "UInt")
	}

	;{{{ ReadInput
	/*
	BOOL WINAPI ReadConsoleInput(
	  _In_   HANDLE hConsoleInput,
	  _Out_  PINPUT_RECORD lpBuffer,
	  _In_   DWORD nLength,
	  _Out_  LPDWORD lpNumberOfEventsRead
	);
	*/
	readInput(ByRef pBuffer, pnLength=1) {
		if (!Console.hStdIn) {
			return throw Exception("No Standard Input availalbe", 1)
		}

		VarSetCapacity(pBuffer, 2 * pnLength, 0)
		VarSetCapacity(_noer, 4, 0)
		DllCall("ReadConsoleInput" (A_IsUnicode ? "W" : "A")
				, "Ptr", Console.hStdIn
				, "Ptr", &pBuffer
				, "UInt", pnLength
				, "Ptr", &_noer
				, "Int")

		return NumGet(_noer, 0, "UInt")
	}

	setCursorPos(piX="", piY="", pbRelative=false) {
		bi := Console.getBufferInfo()
		if (pbRelative) {
			piX := piX != "" ? bi.dwCursorPosition.X + piX : ""
			piY := piY != "" ? bi.dwCursorPosition.Y + piY : ""
		}
		piX := piX = "" ? bi.dwCursorPosition.X : piX
		piY := piY = "" ? bi.dwCursorPosition.Y : piY

		VarSetCapacity(_cp, 4, 0)
		NumPut(piX, _cp, 0, "UShort")
		NumPut(piY, _cp, 2, "UShort")
		return DllCall("SetConsoleCursorPosition", "Ptr", Console.hStdOut
				, "UInt", NumGet(_cp, 0, "UInt"), "Int")
	}

	savePosition() {
		bi := Console.getBufferInfo()
		Console.savedPos := [bi.dwCursorPosition.X, bi.dwCursorPosition.Y]
	}

	restorePosition() {
		Console.setCursorPos(Console.savedPos[1], Console.savedPos[2])
	}

	clearEOL() {
		bi := Console.getBufferInfo()
		Console.fillWithCharacter(" ", bi.dwSize.X - bi.dwCursorPosition.X
				, bi.dwCursorPosition.X, bi.dwCursorPosition.Y)
		Console.fillWithAttribute(bi.attributes
				, bi.dwSize.X - bi.dwCursorPosition.X, bi.dwCursorPosition.X
				, bi.dwCursorPosition.Y)
		Console.setCursorPos(0, bi.dwCursorPosition.Y)
	}

	clearSCR() {
		bi := Console.getBufferInfo()
		Console.fillWithCharacter(" ", bi.dwSize.X * bi.dwSize.Y, 0, 0)
		Console.fillWithAttribute(bi.attributes, bi.dwSize.X * bi.dwSize.Y
				, 0, 0)
		Console.setCursorPos(0, 0)
	}

	getBufferInfo() {
		csbi := new CONSOLE_SCREEN_BUFFER_INFO().implode(_csbi)
		if (DllCall("GetConsoleScreenBufferInfo", "Ptr", Console.hStdOut
				, "Ptr", &_csbi, "Int") != 0) {
			csbi.explode(_csbi)
			return csbi
		}
		return ""
	}

	fillWithCharacter(pcChar=" ", pnLength=1, piX=0, piY=0) {
		VarSetCapacity(dwWriteCoord, 4, 0)
		NumPut(piX, dwWriteCoord, 0, "UShort")
		NumPut(piY, dwWriteCoord, 2, "UShort")
		_dwWriteCoord := NumGet(dwWriteCoord, 0, "UInt")
		VarSetCapacity(_nocw, 4, 0)
		if (A_IsUnicode) {
			VarSetCapacity(_c, 2, 0), NumPut(Chr(SubStr(pcChar, 1, 1))
					, _c, 0, "Short")
		} else {
			VarSetCapacity(_c, 1, 0), NumPut(Chr(SubStr(pcChar, 1, 1))
					, _c, 0, "Char")
		}
		DllCall("FillConsoleOutputCharacter" (A_IsUnicode ? "W" : "A")
				, "Ptr", Console.hStdOut
				, (A_IsUnicode ? "Short" : "Char")
				, NumGet(pcChar, 0, (A_IsUnicode ? "Short" : "Char"))
				, "UInt", pnLength
				, "UInt", _dwWriteCoord
				, "UInt", &_nocw
				, "Int")
		return NumGet(_nocw, 0, "UInt")
	}

	fillWithAttribute(pwAttributes=7, pnLength=1, piX=0, piY=0) {
		VarSetCapacity(dwWriteCoord, 4, 0)
		NumPut(piX, dwWriteCoord, 0, "UShort")
		NumPut(piY, dwWriteCoord, 2, "UShort")
		_dwWriteCoord := NumGet(dwWriteCoord, 0, "UInt")
		VarSetCapacity(_noaw, 4, 0)

		DllCall("FillConsoleOutputAttribute", "Ptr", Console.hStdOut
				, "UShort", pwAttributes
				, "UInt", pnLength
				, "UInt", _dwWriteCoord
				, "UInt", &_noaw
				, "Int")

		return NumGet(_noaw, 0, "UInt")
	}

	refreshBufferInfo() {
		Console.bufferInfo := Console.__InitBufferInfo()
	}

	mapColor(colorCode) {
		static COLOR_MAPPING
				:= {30: Console.Color.Foreground.BLACK
				, 31: Console.Color.Foreground.RED
				, 32: Console.Color.Foreground.GREEN
				, 33: Console.Color.Foreground.OCHER
				, 34: Console.Color.Foreground.BLUE
				, 35: Console.Color.Foreground.PURPLE
				, 36: Console.Color.Foreground.TURQUOISE
				, 37: Console.Color.Foreground.LIGHTGREY
				, 40: Console.Color.Background.BLACK
				, 41: Console.Color.Background.RED
				, 42: Console.Color.Background.GREEN
				, 43: Console.Color.Background.OCHER
				, 44: Console.Color.Background.BLUE
				, 45: Console.Color.Background.PURPLE
				, 46: Console.Color.Background.TURQUOISE
				, 47: Console.Color.Background.LIGHTGREY
				, 90: Console.Color.Foreground.BLACK
				| Console.Color.FOREGROUND_INTENSITY
				, 91: Console.Color.Foreground.RED
				| Console.Color.FOREGROUND_INTENSITY
				, 92: Console.Color.Foreground.GREEN
				| Console.Color.FOREGROUND_INTENSITY
				, 93: Console.Color.Foreground.OCHER
				| Console.Color.FOREGROUND_INTENSITY
				, 94: Console.Color.Foreground.BLUE
				| Console.Color.FOREGROUND_INTENSITY
				, 95: Console.Color.Foreground.PURPLE
				| Console.Color.FOREGROUND_INTENSITY
				, 96: Console.Color.Foreground.TURQUOISE
				| Console.Color.FOREGROUND_INTENSITY
				, 97: Console.Color.Foreground.LIGHTGREY
				| Console.Color.FOREGROUND_INTENSITY
				, 100: Console.Color.Background.BLACK
				| Console.Color.BACKGROUND_INTENSITY
				, 101: Console.Color.Background.RED
				| Console.Color.BACKGROUND_INTENSITY
				, 102: Console.Color.Background.GREEN
				| Console.Color.BACKGROUND_INTENSITY
				, 103: Console.Color.Background.OCHER
				| Console.Color.BACKGROUND_INTENSITY
				, 104: Console.Color.Background.BLUE
				| Console.Color.BACKGROUND_INTENSITY
				, 105: Console.Color.Background.PURPLE
				| Console.Color.BACKGROUND_INTENSITY
				, 106: Console.Color.Background.TURQUOISE
				| Console.Color.BACKGROUND_INTENSITY
				, 107: Console.Color.Background.LIGHTGREY
				| Console.Color.BACKGROUND_INTENSITY}

		if (!COLOR_MAPPING.hasKey(colorCode)) {
			throw Exception("Invalid color code",, colorCode)
		}
		return COLOR_MAPPING[colorCode]
	}
}
