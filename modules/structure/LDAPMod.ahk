class LDAPMod extends Structure {

	version() {
		return "1.0.0"
	}

	requires() {
		return [Structure]
	}

	mod_valsPtrList := " "
	mod_valsList := []

	mod_vals[] {
		get {
			if (this.getAddress("mod_valsPtrList")
					!= this.mod_vals_ptr) {
				this.mod_vals
						:= this.ptrListToStrArray(this.mod_vals_ptr)
				this.mod_vals_ptr
						:= this.getAddress("mod_valsPtrList")
			}
			return this.mod_valsList
		}
		set {
			this.mod_valsList := value
			result := this.strArrayToPtrList(this.mod_valsList
					, "mod_valsPtrList")
			this.mod_vals_ptr := this.getAddress("mod_valsPtrList")
			return result
		}
	}

	struct := [["mod_op", "UInt"]
			,  ["mod_type", "Str*"]
			,  ["mod_vals_ptr", "Ptr"]]
}
