class SMALL_RECT extends Structure {

	version() {
		return "1.0.0"
	}

	requires() {
		return [Structure]
	}

	struct := [["left", "Short"]
			,  ["top", "Short"]
			,  ["right", "Short"]
			,  ["bottom", "Short"]]
}
