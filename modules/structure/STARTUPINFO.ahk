class STARTUPINFO extends Structure {

	version() {
		return ["1.0.0"]
	}

	implode(ByRef data) {
		this.cb := this.sizeOf()
		return base.implode(data)
	}

	struct := [["cb", "UPtr"]
			,  ["reserved", "Ptr"]
			,  ["desktop", "Ptr"]
			,  ["title", "Ptr"]
			,  ["x", "UInt"]
			,  ["y", "UInt"]
			,  ["xSize", "UInt"]
			,  ["ySize", "UInt"]
			,  ["xCountChars", "UInt"]
			,  ["yCountChars", "UInt"]
			,  ["fillAttribute", "UInt"]
			,  ["flags", "Short"]
			,  ["showWindow", "Short"]
			,  ["cbReserved2", "Ptr"]
			,  ["lpReserved2", "Ptr"]
			,  ["stdInput", "Ptr"]
			,  ["stdOutput", "Ptr"]
			,  ["stdErr", "Ptr"]]
}
