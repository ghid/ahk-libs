class TIME_ZONE_INFORMATION extends Structure {

	requires() {
		return [Structure, SYSTEMTIME]
	}

	StandardDate := new SYSTEMTIME()
	DaylightDate := new SYSTEMTIME()

	struct := [["Bias", "Int"]
			,  ["StandardName", "WStr", 32]
			,  ["StandardDate", "SYSTEMTIME"]
			,  ["StandardBias", "Int"]
			,  ["DaylightName", "WStr", 32]
			,  ["DaylightDate", "SYSTEMTIME"]
			,  ["DaylightBias", "Int"]]
}
