class STARTUPINFO extends Structure {

	cb[] {
	get {
		return this.sizeOf()
	}}

	struct := [["cb", "Ptr"]
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
			,  ["flags", "UInt"]
			,  ["showWindow", "UShort"]
			,  ["cbReserved2", "UShort"]
			,  ["lpReserved2", "UInt"]
			,  ["stdInput", "Ptr"]
			,  ["stdOutput", "Ptr"]
			,  ["stdErr", "Ptr"]]
}
