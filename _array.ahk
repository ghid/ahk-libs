Array(args*) {
    args.base := _Array
    return args
}


class _Array {

    #Include %A_LineFile%\..\modules\arrays\Quicksort.ahk

	version() {
		return "1.0.0"
	}

    __new(noOfElements) {
        this := []
        loop % noOfElements {
          this.push("")
        }
        return this
    }

    of(elements*) {
        this := []
        for each, element in elements {
            this.push(element)
        }
        return this
    }

    concat(values*) {
        newArray := this.clone()
        for each, value in values {
            if (value.count() != "") {
                newArray.push(value*)
            } else {
                newArray.push(value)
            }
        }
        return newArray
    }

    copyWithin(target, start=1, end="") {
        if (end="") {
            end := this.count()+1
        }
        start += (start < 0 ? this.count()+1 : 0)
        end += (end < 0 ? this.count()+1 : 0)
        target += (target < 0 ? this.count()+1 : 0)
        noOfElements := end - (end - start + target > this.count()+1
                ? target : start)
        oldArray := this.clone()
        loop %noOfElements% {
            this[target++] := oldArray[start + A_Index-1]
        }
        return this
    }

    every(callbackFunc) {
        for each, currentValue in this {
            if (!callbackFunc.call(currentValue, each, this)) {
                return false
            }
        }
        return true
    }

    equals(anotherArray) {
        if (anotherArray.count() == "") {
            return false
        }
        if (this.count() != anotherArray.count()) {
            return false
        }
        for i, value in this {
            if (value.count() != "") {
                if (!value.equals(anotherArray[i])) {
                    return false
                }
            } else if (value != anotherArray[i]) {
                return false
            }
        }
        return true
    }

    fill(value="", start=1, end="") {
        if (end == "") {
            end := this.count()+1
        }
        start += (start < 0 ? this.count()+1 : 0)
        end += (end < 0 ? this.count()+1 : 0)
        i := Max(start, 1)
        while (i < Min(end, this.count()+1)) {
            this[i++] := value
        }
        return this
    }

    filter(callbackFunc) {
        result := []
        for each, currentValue in this {
            if (callbackFunc.call(currentValue, each, this)) {
                result.push(currentValue)
            }
        }
        return result
    }

    find(callbackFunc) {
        for each, currentValue in this {
            if (callbackFunc.call(currentValue, each, this)) {
                return currentValue
            }
        }
        return ""
    }

    findIndex(callbackFunc) {
        for each, currentValue in this {
            if (callbackFunc.call(currentValue, each, this)) {
                return each
            }
        }
        return 0
    }

	flat(depth=1) {
		static currentDepth := 0
		result := []
		currentDepth++
		for each, currentValue in this {
			result := (currentValue.count() != "" && currentDepth < depth
					? result.concat(currentValue.flat(depth))
					: result.concat(currentValue))
		}
		currentDepth--
		return result
	}

    flatMap(callbackFunc) {
        return this.map(callbackFunc).flat(1)
    }

    forEach(callbackFunc) {
        for each, currentValue in this {
            callbackFunc.call(currentValue, each, this)
        }
    }

    from(callbackFunc) {
        result := []
        for each, currentValue in this {
            result.push(callbackFunc.call(currentValue, each, this))
        }
        return result
    }

    includes(searchElement, fromIndex=1) {
        if (fromIndex > this.count()) {
            return false
        }
        if (fromIndex < 1) {
            fromIndex := Max(this.count() + fromIndex, this.minIndex())
        }
        while (fromIndex <= this.count()) {
            if (this[fromIndex++] == searchElement) {
                return true
            }
        }
        return false
    }

    indexOf(searchElement, fromIndex=1) {
        if (fromIndex > this.count()) {
            return false
        }
        if (fromIndex < 1) {
            fromIndex := Max(this.count() + fromIndex, this.minIndex())
        }
        while (fromIndex <= this.count()) {
            if (this[fromIndex] == searchElement) {
                return fromIndex
            }
            fromIndex++
        }
        return false
    }

    join(separator=",") {
        result := ""
        for each, currentValue in this {
            if (A_Index > 1) {
                result .= separator
            }
            if (currentValue.count() != "") {
                result .= currentValue.join(",")
            }
            result .= currentValue
        }
        return result
    }

    lastIndexOf(searchElement, fromIndex="") {
        if (this.count() == 0) {
            return false
        }
        if (fromIndex == "") {
            fromIndex := this.count()
        }
        if (fromIndex < 1) {
            fromIndex := this.count() + fromIndex
        }
        if (fromIndex < 0) {
           return false
        }
        while (fromIndex >= this.minIndex()) {
            if (this[fromIndex] == searchElement) {
                return fromIndex
            }
            fromIndex--
        }
        return false
    }

    map(callbackFunc) {
		result := []
		for each, currentValue in this {
			result.push(callbackFunc.call(currentValue, each, this))
		}
		return result
    }

    reduce(callbackFunc, initialValue="") {
        result := initialValue
        for each, currentValue in this {
            result := callbackFunc.call(result, currentValue, each, this)
        }
        return result
    }

    reduceRight(callbackFunc, initialValue="") {
        result := initialValue
        copyArray := this.clone()
        loop % copyArray.count() {
            result := callbackFunc.call(result, copyArray.pop()
                    , this.count()+1 - A_Index, this)
        }
        return result
    }

    reverse() {
        result := []
        loop % this.count() {
            result.push(this.pop())
        }
        return this := result
    }

    shift() {
        return this.removeAt(1)
    }

    slice(start=1, end="") {
        if (start == "") {
            start := 1
        }
        if (end == "") {
            end := this.count()+1
        }
        start += (start < 0 ? this.count()+1 : 0)
        end += (end < 1 ? this.count()+1 : 0)
        result := []
        i := Max(start, 1)
        while (i < Min(end, this.count()+1)) {
            result.push(this[i++])
        }
        return result
    }

    some(callbackFunc) {
        for each, currentValue in this {
            if (callbackFunc.call(currentValue, each, this)) {
                return true
            }
        }
        return false
    }

    sort(compareFunc="") {
		if (compareFunc == "") {
			compareFunc := _Array.Quicksort.compareStrings.bind(_Array)
		}
		return _Array.Quicksort.sort(this, compareFunc
				, this.minIndex(), this.maxIndex())
    }

    splice(start, deleteCount="", items*) {
        start += (start < 1 ? this.count() : 0)
        start := Max(start, 1)
        if (deleteCount == "") {
            deleteCount := this.count()+1 - start
        }
        removedElements := []
        if (deleteCount > 0) {
            loop % deleteCount {
                removedElements.push(this.removeAt(start))
            }
        }
        for each, item in items {
            this.insertAt(start++, item)
        }
        return removedElements
    }

    toString() {
        result := ""
        for each, value in this {
            if (A_Index > 1) {
                result .= ","
            }
            if (value.count() != "") {
                result .= value.toString()
            } else {
                result .= value
            }
        }
        return result
    }

    unshift(elements*) {
        for each, element in elements {
            this.insertAt(A_Index, element)
        }
        return this.count()
    }
}
