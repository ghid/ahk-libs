class App {

	version() {
		return "1.0.0"
	}

	requires() {
		return []
	}

	; TODO: Handle cyclic dependencies
	checkRequiredClasses(forClass="") {
		forClass := (forClass != "" ? forClass : this)
		requiredClasses := forClass.requires()
		while (A_Index <= requiredClasses.maxIndex()) {
			requiredClass := requiredClasses[A_Index]
			if (IsObject(requiredClass)) {
				OutputDebug % Format("{:s} uses {:s} {:s}"
						, forClass.__Class, requiredClass.__Class
						, requiredClass.version())
				App.checkRequiredClasses(requiredClass)
			} else {
				OutputDebug % "Misses requirement #" A_Index
						. " for " forClass.__Class
				MsgBox % "Missing requirement #" A_Index
						. " for " forClass.__Class
				exitapp -1
			}
		}
		return forClass
	}
}
