class SYSTEMTIME extends Structure {

	version() {
		return "1.0.0"
	}

	requires() {
		return [Structure]
	}

	struct := [["wYear", "Short"]
			,  ["wMonth", "Short"]
			,  ["wDayOfWeek", "Short"]
			,  ["wDay", "Short"]
			,  ["wHour", "Short"]
			,  ["wMinute", "Short"]
			,  ["wSecond", "Short"]
			,  ["wMilliseconds", "Short"]]
}
