class Ldap {

	requires() {
		return [Ansi, String, System, Structure, LDAPAPIINFO, LDAPMod]
	}

	static hWldap32 := 0

	#Include %A_LineFile%\..\modules\ldap
	#Include constants.ahk
	#Include Helper.ahk

	hLdap := 0

	AW[] {
		get {
			return (A_IsUnicode ? "W" : "A")
		}
	}

	__new(hostname, port=389) {
		if (!Ldap.hWldap32) {
			Ldap.hWldap32 := DllCall("LoadLibrary", "Str", "Wldap32.dll", "Ptr")
		}
		this.hLdap := DllCall("wldap32\ldap_init" Ldap.AW
				, "Str", hostname, "UInt", port, "CDecl Ptr")
		return this
	}

	setOption(option, invalue) {
		return DllCall("wldap32\ldap_set_option" (Ldap.AW = "W" ? "W":"")
				, "Ptr", this.hLdap, "Int", option, "Ptr", invalue, "CDecl")
	}

	getOption(option, ByRef value) {
		return DllCall("wldap32\ldap_get_option" (Ldap.AW = "W" ? "W":"")
				, "Ptr", this.hLdap, "Int", option, "Ptr", &value, "CDecl")
	}

	connect(timeout=0) {
		return DllCall("wldap32\ldap_connect", "Ptr", this.hLdap
				, "Ptr", 0, "CDecl")
	}

	search(ByRef searchResult, basedn, filter, scope=2, attrs=0
			, attrs_only=false) {
		if (attrs != 0 && !IsObject(attrs)) {
			throw Exception("attrs must be 0 or a string array")
		}
		if (attrs) {
			l := System.strArrayToPtrList(attrs, _attrs)
		} else {
			_attrs := ""
		}
		VarSetCapacity(res, A_PtrSize, 0)
		result := DllCall("wldap32\ldap_search_s" Ldap.AW
				, "Ptr", this.hLdap
				, "Str", basedn
				, "UInt", scope
				, "Str", filter
				, "Ptr", &_attrs
				, "UInt", attrs_only
				, "Ptr", &res
				, "CDecl UInt")

		searchResult := NumGet(res, 0, "Ptr")
		return result
	}

	formatFilter(filter, hilightSyntax=true) {
		return Ldap.Helper.hilightFilter(Ldap.Helper.indentFilter(filter)
				, hilightSyntax)
	}

	countEntries(searchResult) {
		return DllCall("wldap32\ldap_count_entries", "Ptr", this.hLdap
				, "Ptr", searchResult, "CDecl")
	}

	firstEntry(searchResult) {
		return DllCall("wldap32\ldap_first_entry", "Ptr", this.hLdap
				, "UInt", searchResult, "CDecl")
	}

	nextEntry(entry) {
		return DllCall("wldap32\ldap_next_entry", "Ptr", this.hLdap
				, "Ptr", entry, "CDecl")
	}

	firstAttribute(entry) {
		VarSetCapacity(pBer, A_PtrSize, 0)
		ret := DllCall("wldap32\ldap_first_attribute" Ldap.AW, "Ptr", this.hLdap
				, "UInt", entry, "Ptr", &pBer, "CDecl")
		if (ret) {
			this._p_ber := NumGet(pBer, 0, "Ptr")
		}
		return ret
	}

	nextAttribute(entry) {
		return DllCall("wldap32\ldap_next_attribute" Ldap.AW, "Ptr", this.hLdap
				, "UInt", entry, "Ptr", this._p_ber, "CDecl")
	}

	getValues(entry, attr) {
		return DllCall("wldap32\ldap_get_values" Ldap.AW, "Ptr", this.hLdap
				, "Ptr", entry, "Ptr", attr, "CDecl Ptr")
	}

	countValues(values) {
		return DllCall("wldap32\ldap_count_values" Ldap.AW
				, "Ptr", values, "CDecl")
	}

	getDn(entry) {
		return DllCall("wldap32\ldap_get_dn" Ldap.AW, "Ptr", this.hLdap
				, "Ptr", entry, "CDecl Str")
	}

	getLastError() {
		return DllCall("wldap32\LdapGetLastError", "CDecl")
	}

	err2String(err="") {
		if (err = "") {
			err := this.getLastError()
		}
		return DllCall("wldap32\ldap_err2string" this.AW, "UInt"
				, err, "CDecl Str")
	}

	simpleBind(dn, passwd) {
		return DllCall("wldap32\ldap_simple_bind_s" Ldap.AW, "Ptr", this.hLdap
				, "Str", dn, "Str", passwd, "Cdecl")
	}

	unbind() {
		ret := 0
		if (this.hLdap) {
			ret := DllCall("wldap32\ldap_unbind", "Ptr", this.hLdap, "CDecl")
		}
		this.hLdap := 0
		return ret
	}

	add(entry_dn, ByRef ldap_mod)  {
		return DllCall("wldap32\ldap_add_s" Ldap.AW, "Ptr", this.hLdap
				, "Str", entry_dn, "Ptr", &ldap_mod, "CDecl UInt")
	}

	delete(dn) {
		return DllCall("wldap32\ldap_delete_s" Ldap.AW, "Ptr", this.hLdap
				, "Str", dn, "CDecl UInt")
	}

	modify(dn, ByRef ldap_mod) {
		return DllCall("wldap32\ldap_modify_s" Ldap.AW, "Ptr", this.hLdap
				, "Str", dn, "Ptr", &ldap_mod, "CDecl UInt")
	}
}
