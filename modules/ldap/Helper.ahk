class Helper {

	static HL_COL_LOGIC := "[0;32m"
	static HL_COL_OPERATOR := "[0;31m"
	static HL_COL_ATTR := "[0;35m"
	static HL_COL_VALUE := "[0;34m"

	indentFilter(filter) {
		indentedString := ""
		indent := 0
		i := 1
		while (i <= StrLen(filter)) {
			char := SubStr(filter, i, 1)
			st := SubStr(filter, i-1, 2)
			if (RegExMatch(st, "\([|&!]", $)) {
				indent++
				indentedString .= char Ldap.Helper.indentText("", indent)
			} else if (st = ")(") {
				indentedString .= Ldap.Helper.indentText(char, indent)
			} else if (st = "))") {
				indent--
				indentedString .= Ldap.Helper.indentText(char, indent)
			} else {
				indentedString .= char
			}
			i++
		}
		if (indent < 0) {
			throw Exception("Invalid LDAP filter")
		}
		return indentedString
	}

	indentText(text, num, indentWidth=2, indentChar=" ") {
		return "`n" (indentChar.repeat(indentWidth)).repeat(num) text
	}

	hilightFilter(filter, hilightSyntax) {
		if (hilightSyntax) {
			filter := RegExReplace(filter, "(\w*?)=([\w_-]+)"
					, Ldap.Helper.HL_COL_ATTR "${1}="
					. Ldap.Helper.HL_COL_VALUE "${2}[0m")
			filter := RegExReplace(filter, "[&|!]"
					, Ldap.Helper.HL_COL_LOGIC "${0}[0m")
			filter := RegExReplace(filter, "[<>~*=]"
					, Ldap.Helper.HL_COL_OPERATOR "${0}[0m")
		}
		return filter
	}
}
