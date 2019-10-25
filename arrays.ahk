; ahk: console
class Arrays {

	#Include %A_LineFile%\..\modules\arrays\
	#Include Venn.ahk

	; ahklint-ignore-begin: W002,W007,W004
	class Quicksort {

		sort(poData, paSortOrder, piLeft, piRight) {
			if (piLeft < piRight) {
				iPivot := Arrays.Quicksort.Divide(poData, paSortOrder, piLeft, piRight)
				Arrays.Quicksort.Sort(poData, paSortOrder, piLeft, iPivot-1)
				Arrays.Quicksort.Sort(poData, paSortOrder, iPivot+1, piRight)
			}
		}

		Divide(poData, paSortOrder, piLeft, piRight) {
			i := piLeft
			j := piRight - 1
			_pivot := poData[piRight]

			loop {
				while (Arrays.compare(paSortOrder, poData[i], _pivot)
						<= 0 && i < piRight) {
					i++
				}
				while (Arrays.compare(paSortOrder, poData[j], _pivot)
						>= 0 && j > piLeft) {
					j--
				}
				if (i < j) {
					Arrays.Quicksort.Swap(poData, i, j)
				} else {
					break
				}
			}

			Arrays.Quicksort.Swap(poData, i, piRight)

			return i
		}

		Swap(poData, pi, pj) {
			_temp := poData[pi]
			poData[pi] := poData[pj]
			poData[pj] := _temp
		}
	}
	; ahklint-ignore-end

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' ist not allowed", -1)
	}

	equal(anArray, anArrayToCompareWith) {
		Arrays.isArray(anArray)
		Arrays.isArray(anArrayToCompareWith)
		if (!(anArray.count() == anArrayToCompareWith.count())) {
			return false
		}
		loop % anArray.count() {
			if (!(anArray[A_Index] == anArrayToCompareWith[A_Index])) {
				return false
			}
		}
		return true
	}

	union(anArray, anArrayToUnionWith, compareAsType=0) {
		return Arrays.Venn.operation(anArray, anArrayToUnionWith
				, Arrays.Venn.OPERATION_UNION, compareAsType)
	}

	intersection(anArray, anArrayToIntersectWith, compareAsType=0) {
		return Arrays.Venn.operation(anArray, anArrayToIntersectWith
				, Arrays.Venn.OPERATION_INERSECTION, compareAsType)
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
		Arrays.isArray(anArray)
		Arrays.isArray(anotherArray)
		for _, value in anotherArray {
			anArray.push(value)
		}
		return anArray.maxIndex()
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
		resultString := ""
		while (index <= anArray.maxIndex()) {
			element := anArray[index++]
			resultString .= Arrays.appendElementToString(resultString
					, separateWithText, element)
		}
		return resultString
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

	sort(anArray) {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" pArray ">")
		}
	}

	flatten(anArray, reset=true) {
		static flatArray

		if (reset) {
			flatArray := []
		}
		index := anArray.minIndex()
		loop {
			if (anArray[index].minIndex() != "") {
				Arrays.flatten(anArray[index], false)
			} else {
				flatArray.push(anArray[index])
			}
			index++
		} until (index > anArray.maxIndex())
		return flatArray
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
