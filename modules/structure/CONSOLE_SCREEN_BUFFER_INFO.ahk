class CONSOLE_SCREEN_BUFFER_INFO2 extends Structure {
	
	size := new COORD2()
	cursorPosition := new COORD2()
	windows := new SMALL_RECT2()
	maximumWindowSize := new COORD2()

	struct := [["size", "COORD2"]
			,  ["cursorPosition", "COORD2"]
			,  ["attributes", "UShort"]
			,  ["windows", "SMALL_RECT2"]
			,  ["maximumWindowSize", "COORD2"]]
}
