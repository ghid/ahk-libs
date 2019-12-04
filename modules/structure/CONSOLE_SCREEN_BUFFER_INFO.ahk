class CONSOLE_SCREEN_BUFFER_INFO extends Structure {

	requires() {
		return [COORD, SMALL_RECT]
	}
	
	size := new COORD()
	cursorPosition := new COORD()
	windows := new SMALL_RECT()
	maximumWindowSize := new COORD()

	struct := [["size", "COORD"]
			,  ["cursorPosition", "COORD"]
			,  ["attributes", "UShort"]
			,  ["windows", "SMALL_RECT"]
			,  ["maximumWindowSize", "COORD"]]
}
