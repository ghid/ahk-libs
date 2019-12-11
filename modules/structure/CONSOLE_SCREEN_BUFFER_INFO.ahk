class CONSOLE_SCREEN_BUFFER_INFO extends Structure {

	requires() {
		return [COORD, SMALL_RECT]
	}
	
	size := new COORD()
	cursorPosition := new COORD()
	window := new SMALL_RECT()
	maximumWindowSize := new COORD()

	struct := [["size", "COORD"]
			,  ["cursorPosition", "COORD"]
			,  ["attributes", "UShort"]
			,  ["window", "SMALL_RECT"]
			,  ["maximumWindowSize", "COORD"]]
}
