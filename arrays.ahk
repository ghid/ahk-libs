; ahk: console
class Arrays {

	requires() {
		return [String]
	}

	#Include %A_LineFile%\..\modules\arrays\
	#Include Venn.ahk
	#Include Quicksort.ahk

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' ist not allowed", -1)
	}

	equal(anArray, anArrayToCompareWith) {
		Arrays.isArray(anArray)
		Arrays.isArray(anArrayToCompareWith)
		if (anArray.count() != anArrayToCompareWith.count()) {
			return false
		}
		loop % anArray.count() {
			currentValue := anArray[A_Index]
			currentOtherValue := anArrayToCompareWith[A_Index]
			if (currentValue.count() != currentOtherValue.count()) {
				return false
			}
			if (currentValue.count() != "") {
				return Arrays.equal(currentValue, currentOtherValue)
			}
			if (!currentValue == currentOtherValue) {
				return false
			}
		}
		return true
	}

	countOccurences(anArray, lookUpValue, caseSensitive=false) {
		Arrays.isArray(anArray)
		result := 0
		loop % anArray.count() {
			result += Arrays.areValuesEqual(anArray[A_Index], lookUpValue
					, caseSensitive)
		}
		return result
	}

	areValuesEqual(aValue, anotherValue, caseSensitive) {
		return (!caseSensitive && aValue = anotherValue)
				|| (caseSensitive && aValue == anotherValue)
				? 1 : 0
	}

	keys(anArray) {
		Arrays.isArray(anArray)
		result := []
		for key in anArray {
			result.push(key)
		}
		return result
	}

	values(anArray) {
		Arrays.isArray(anArray)
		result := []
		for _, value in anArray {
			result.push(value)
		}
		return result
	}

	distinct(anArray) {
		Arrays.isArray(anArray)
		distinctValuesInArray := []
		for _, value in anArray {
			if (!distinctValuesInArray.hasKey(value)) {
				distinctValuesInArray[value] := true
			}
		}
		return Arrays.keys(distinctValuesInArray)
	}

	removeValue(anArray, theValueToRemove, caseSensitive=false) {
		Arrays.isArray(anArray)
		result := 0
		index := anArray.minIndex()
		while (index <= anArray.maxIndex()) {
			if (Arrays.areValuesEqual(anArray[index], theValueToRemove
					, caseSensitive)) {
				anArray.removeAt(index)
				result++
			} else {
				index++
			}
		}
		return result
	}

	shift(anArray, shiftByElements=1) {
		Arrays.isArray(anArray)
		if (shiftByElements < 1) {
			numberOfShifts := 1
		} else if (shiftByElements > anArray.maxIndex()) {
			numberOfShifts := anArray.maxIndex()
		} else {
			numberOfShifts := shiftByElements
		}
		shiftedElements := []
		loop %numberOfShifts% {
			shiftedElements.push(anArray.removeAt(anArray.minIndex()))
		}
		if (shiftByElements != 1) {
			return shiftedElements
		}
		return shiftedElements[1]
	}

	append(anArray, anotherArray) {
		OutputDebug %A_ThisFunc% is deprecated. Use Arrays.concat() instead
		Arrays.isArray(anArray)
		Arrays.isArray(anotherArray)
		for _, value in anotherArray {
			anArray.push(value)
		}
		return anArray.maxIndex()
	}

	concat(anArray, anotherValue) {
		Arrays.isArray(anArray)
		result := anArray.clone()
		if (anotherValue.count() != "") {
			for _, value in anotherValue {
				result.push(value)
			}
		} else {
			result.push(anotherValue)
		}
		return result
	}

	wrap(anArray, textWidth, indentWithText="", indent1stElementWithText=""
			, replace1stIndent=false) {
		Arrays.isArray(anArray)
		wrappedText := ""
		index := anArray.minIndex()
		while (index <= anArray.maxIndex()) {
			if (A_Index = 1) {
				wrappedElement := anArray[index++].wrap(textWidth
						, indentWithText, indent1stElementWithText
						, replace1stIndent)
			} else {
				wrappedElement := anArray[index++].wrap(textWidth
						, indentWithText, "", false)
			}
			wrappedText .= wrappedElement "`n"
		}
		return wrappedText
	}

	toString(anArray, separateWithText=" ") {
		Arrays.isArray(anArray)
		if (!anArray.maxIndex()) {
			return ""
		}
		index := anArray.minIndex()
		result := ""
		while (index <= anArray.maxIndex()) {
			result .= Arrays.appendElementToString(result, separateWithText
					, anArray[index++])
		}
		return result
	}

	appendElementToString(currentString, separateWithText, element) {
		result := (currentString != "" ? separateWithText : "")
		if (element.maxIndex() == "") {
			result .= element
		} else {
			result .= Arrays.toString(element, separateWithText)
		}
		return result
	}

	index(anArray) {
		indexOfArray := []
		for key, value in anArray {
			indexKey := value
			indexValue := key
			if (!indexOfArray.hasKey(indexKey)) {
				indexOfArray[indexKey] := indexValue
			} else {
				previousValues := [indexOfArray[indexKey]]
				previousValues.push(indexValue)
				indexOfArray[indexKey] := previousValues
			}
		}
		return indexOfArray
	}

	copyOf(anArray, newLength, padWith=0) {
		copyOfArray := []
		startIndex := anArray.minIndex()
		endIndex := anArray.maxIndex()
		index := startIndex
		loop %newLength% {
			copyOfArray[index] := (index <= endIndex ? anArray[index] : padWith)
			index++
		}
		return copyOfArray
	}

	sort(anArray, compareFunc="") {
		Arrays.isArray(anArray)
		if (compareFunc == "") {
			compareFunc := Arrays.Quicksort.compareStrings.bind(Arrays)
		}
		Arrays.isCallbackFunction(compareFunc)
		return Arrays.Quicksort.sort(anArray, compareFunc
				, anArray.minIndex(), anArray.maxIndex())
	}

	flat(anArray, depth=1) {
		static currentDepth := 0
		Arrays.isArray(anArray)
		result := []
		currentDepth++
		for _, currentValue in anArray {
			result := (currentValue.count() != "" && currentDepth < depth
					? Arrays.concat(result, Arrays.flat(currentValue, depth))
					: Arrays.concat(result, currentValue))
		}
		currentDepth--
		return result
	}
	
	map(anArray, callbackFunc) {
		Arrays.isArray(anArray)
		Arrays.isCallbackFunction(callbackFunc)
		result := []
		for _, currentValue in anArray {
			if (!IsObject(currentValue)) {
				currentValue := {1: currentValue}
			}
			result.push(callbackFunc.call(currentValue))
		}
		return result
	}

	reduce(anArray, callbackFunc, initialValue) {
		Arrays.isArray(anArray)
		Arrays.isCallbackFunction(callbackFunc)
		result := initialValue
		for _, currentValue in anArray {
			result := callbackFunc.call(result, currentValue)
		}
		return result
	}

	forEach(anArray, callbackFunc) {
		Arrays.isArray(anArray)
		Arrays.isCallbackFunction(callbackFunc)
		for _, currentValue in anArray {
			callbackFunc.call(currentValue, A_Index, anArray)
		}
	}

	filter(anArray, callbackFunc) {
		Arrays.isArray(anArray)
		Arrays.isCallbackFunction(callbackFunc)
		result := []
		for _, currentValue in anArray {
			if (callbackFunc.call(currentValue, A_Index, anArray)) {
				result.push(currentValue)
			}
		}
		return result
	}

	isArray(anArray) {
		if (anArray.count() == "") {
			throw Exception("Argument has to be an array")
		}
	}

	isCallbackFunction(callbackFunc) {
		if (!IsFunc(callbackFunc) && !IsObject(callbackFunc)) {
			throw Exception("Callback function not found " callbackFunc)
		}
	}
}
