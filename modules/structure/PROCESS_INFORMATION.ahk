class PROCESS_INFORMATION extends Structure {

	version() {
		return "1.0.0"
	}

	struct := [["process"  , "Ptr"]
			,  ["thread"   , "Ptr"]
			,  ["processId", "UInt"]
			,  ["threadId" , "UInt"]]
}
