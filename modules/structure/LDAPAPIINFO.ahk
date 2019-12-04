class LDAPAPIINFO extends Structure {

	extensionsPtrList := " "
	extensionsList := []

	requires() {
		return [Structure]
	}

	ldapai_extensions[] {
		get {
			if (this.getAddress("extensionsPtrList")
					!= this.ldapai_extensions_ptr) {
				this.extensionsList
						:= this.ptrListToStrArray(this.ldapai_extensions_ptr)
				this.ldapai_extensions_ptr
						:= this.getAddress("extensionsPtrList")
			}
			return this.extensionsList
		}
		set {
			this.extensionsList := value
			result := this.strArrayToPtrList(this.extensionsList
					, "extensionsPtrList")
			this.ldapai_extensions_ptr := this.getAddress("extensionsPtrList")
			return result
		}
	}

	struct := [["ldapai_info_version", "Int"]
			,  ["ldapai_api_version", "Int"]
			,  ["ldapai_protocol_version", "Int"]
			,  ["ldapai_extensions_ptr", "Ptr"]
			,  ["ldapai_vendor_name", "Str*"]
			,  ["ldapai_vendor_version", "Int"]]
}
