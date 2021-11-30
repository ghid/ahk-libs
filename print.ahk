print(objects*) {
    static stdOut := 0
    if (stdOut == 0) {
        stdOut := FileOpen("*", "w")
    }
    for each, thing in objects {
        if (A_Index > 1) {
            stdOut.write(" ")
        }
        if (IsObject(thing)) {
            stdOut.write(print#objectToString(thing))
        } else {
            stdOut.write(thing)
        }
    }
    stdOut.writeLine("")
}

print#objectToString(a) {
    static color := print#hasAnsiSupport()
            ? {on: "[32m", off: "[0m"}
            : {on: "", off: ""}
    isArray := a.__class = "_Array"
            || (a.minIndex() == 1 && a.maxIndex() == a.count())
    result := isArray ? "[ " : "{ "
    for each, value in a {
        result .= A_Index > 1 ? ", " : ""
        if (IsObject(value)) {
            result .= (isArray ? "" : each ": ") print#objectToString(value)
        } else {
            resultValue := (value + 0 == value
                    ? value
                    : color.on """" value """" color.off)
            result .= isArray ? resultValue : each ": " resultValue
        }
    }
    return result .= isArray ? " ]" : " }"
}


print#hasAnsiSupport() {
    EnvGet da, DISABLE_ANSI
    EnvGet shell, SHELL
    if (RegExMatch(A_OSVersion, "^10\.") || shell != "") {
        return true && (!da)
    }
    EnvGet ansicon_version, ANSICON_VER
    return ansicon_version && (!da)
}
