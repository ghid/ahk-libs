print(objects*) {
    static stdOut := 0
    if (stdOut == 0) {
        stdOut := FileOpen("*", "w")
    }
    for each, thing in objects {
        if (A_Index > 1) {
            stdOut.write(";")
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
    isArray := a.__class = "_Array"
            || (a.minIndex() == 1 && a.maxIndex() == a.count())
    result := isArray ? "[ " : "{ "
    for each, value in a {
        result .= A_Index > 1 ? ", " : ""
        if (IsObject(value)) {
            result .= (isArray ? "" : each ": ") print#objectToString(value)
        } else {
            resultValue := (value + 0 == value ? value : """" value """")
            result .= isArray ? resultValue : each ": " resultValue
        }
    }
    return result .= isArray ? " ]" : " }"
}
