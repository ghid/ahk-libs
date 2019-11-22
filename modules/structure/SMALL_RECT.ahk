class SMALL_RECT extends Structure {

	requires() {
		return [Structure]
	}

	struct := [["left", "Short"]
			,  ["top", "Short"]
			,  ["right", "Short"]
			,  ["bottom", "Short"]]
}
