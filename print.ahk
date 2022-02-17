print(objects*) {
    static printStdOut := 0

    if (!IsObject(printStdOut)) {
        printStdOut := FileOpen("*", "w", "utf-8")
    }
    for each, thing in objects {
        if (A_Index > 1) {
            printStdOut.write(" ")
        }
        if (IsObject(thing)) {
            printStdOut.write(objectToString(thing))
        } else {
            printStdOut.write(thing)
        }
    }
    printStdOut.writeLine("")

    objectToString(a) {
        static color := hasAnsiSupport()
                ? {on: "[32m", off: "[0m"}
                : {on: "", off: ""}

        if (a.__class = "Array") {
            result .= "[ "
            for (value in a) {
                result .= A_Index > 1 ? ", " : ""
                if (IsObject(value)) {
                    result .= objectToString(value)
                } else {
                    resultValue := (IsNumber(value)
                            ? value
                            : color.on "`"" value "`"" color.off)
                    result .= resultValue
                }
            }
            return result .= " ]"
        } else {
            result .= "{ "
            for (each, value in a.ownProps()) {
                result .= A_Index > 1 ? ", " : ""
                if (IsObject(value)) {
                    result .= each ": " objectToString(value)
                } else {
                    resultValue := (IsNumber(value)
                            ? value
                            : color.on "`"" value "`"" color.off)
                    result .= each ": " resultValue
                }
            }
            return result .= " }"
        }
    }

    hasAnsiSupport() {
        da := EnvGet("DISABLE_ANSI")
        shell := EnvGet("SHELL")
        if (RegExMatch(A_OSVersion, "^10\.") || shell != "") {
            return true && (!da)
        }
        ansicon_version := EnvGet("ANSICON_VER")
        return ansicon_version && (!da)
    }
}
