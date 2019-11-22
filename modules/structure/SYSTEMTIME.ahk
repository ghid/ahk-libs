class SYSTEMTIME extends Structure {

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
