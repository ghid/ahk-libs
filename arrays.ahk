; ahk: console
#Include %A_LineFile%\..\modules\arrays\
#Include VennData.ahk

class Arrays {

	static OPERATION_INERSECTION := 1
	static OPERATION_UNION := 2
	static OPERATION_SYMMETRIC_DIFFERENCE := 3
	static OPERATION_RELAVIVE_COMPLEMENT := 4

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

	equal(anArray="", arrayToCompareWith="") {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array", -1)
		}
		if (!IsObject(arrayToCompareWith)) {
			throw Exception("Parameter #2 is no valid array", -1)
		}
		if (!(anArray.maxIndex() == arrayToCompareWith.maxIndex())) {
			return false
		}
		loop % anArray.maxIndex() {
			if (!(anArray[A_Index] == arrayToCompareWith[A_Index])) {
				return false
			}
		}
		return true
	}

	union(anArray="", arrayToUnionWith="", compareAsType=0) {
		return Arrays.venn(anArray, arrayToUnionWith
				, Arrays.OPERATION_UNION, compareAsType)
	}

	intersection(anArray="", arrayToIntersectWith="", compareAsType=0) {
		return Arrays.venn(anArray, arrayToIntersectWith
				, Arrays.OPERATION_INERSECTION, compareAsType)
	}

	venn(setA, setB, operation, compareAsType=0) {
		if (!IsObject(setA)) {
			throw Exception("Parameter #1 is no valid array", -1)
		}
		if (!IsObject(setB)) {
			throw Exception("Parameter #2 is no valid array", -1)
		}
		VennData.setA := setA.clone()
		VennData.setB := setB.clone()
		VennData.indexA := VennData.setA.minIndex()
		VennData.indexB := VennData.setB.minIndex()
		VennData.operation := operation
		VennData.compareAsType := compareAsType
		VarSetCapacity(HIGH, 64, 0xff)
		VennData.setA.push(HIGH)
		VennData.setB.push(HIGH)
		return Arrays.processSetAAndSetB()
	}

	processSetAAndSetB() {
		result := []
		while ((VennData.indexA != "" && VennData.indexB != "")
				&& (VennData.indexA < VennData.setA.maxIndex()
				|| VennData.indexB < VennData.setB.maxIndex())) {
			result := Arrays.catchUpSetA(result)
			result := Arrays.catchUpSetB(result)
			result := Arrays.processElementsContainedInBothSets(result)
		}
		return result
	}

	catchUpSetA(result) {
		while (VennData.indexA < VennData.setA.maxIndex()
				&& (VennData.setA[VennData.indexA])
				.compare(VennData.setB[VennData.indexB]
				, VennData.compareAsType) < 0) {
			if (VennData.operation == Arrays.OPERATION_UNION
					|| VennData.operation
					== Arrays.OPERATION_SYMMETRIC_DIFFERENCE
					|| VennData.operation
					== Arrays.OPERATION_RELAVIVE_COMPLEMENT) {
				result := Arrays
						.pushToResultSet(VennData.setA[VennData.indexA]
						, result, "A")
			}
			VennData.indexA++
		}
		return result
	}

	catchUpSetB(result) {
		while (VennData.indexB < VennData.setB.maxIndex()
				&& (VennData.setB[VennData.indexB])
				.compare(VennData.setA[VennData.indexA]
				, VennData.compareAsType) < 0) {
			if (VennData.operation == Arrays.OPERATION_UNION
					|| VennData.operation
					== Arrays.OPERATION_SYMMETRIC_DIFFERENCE) {
				result := Arrays
						.pushToResultSet(VennData.setB[VennData.indexB]
						, result, "B")
			}
			VennData.indexB++
		}
		return result
	}

	processElementsContainedInBothSets(resultSet) {
		while ((VennData.indexA < VennData.setA.maxIndex()
				|| VennData.indexB < VennData.setB.maxIndex())
				&& (VennData.setA[VennData.indexA])
				.compare(VennData.setB[VennData.indexB]
				, VennData.compareAsType) == 0) {
			if (VennData.operation == Arrays.OPERATION_INERSECTION
					|| VennData.operation == Arrays.OPERATION_UNION) {
				resultSet := Arrays
						.pushToResultSet(VennData.setA[VennData.indexA]
						, resultSet, "A")
				resultSet := Arrays
						.pushToResultSet(VennData.setB[VennData.indexB]
						, resultSet, "B")
			}
			if (VennData.operation != Arrays.OPERATION_RELAVIVE_COMPLEMENT) {
				VennData.indexB++
			}
			VennData.indexA++
		}
		return resultSet
	}

	pushToResultSet(element, resultSet, source="") {
		resultSet.push((VennData.printSource ? "(" source ") " : "") element)
		return resultSet
	}

	countOccurences(anArray="", lookUpValue="", caseSensitive=false) {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" anArray ">")
		}
		count := 0
		for i, value in anArray {
			if ((!caseSensitive && value = lookUpValue)
					|| (caseSensitive && value == lookUpValue)) {
				count++
			}
		}
		return count
	}

	keys(anArray="") {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" anArray ">")
		}
		allKeysInArray := []
		for key, value in anArray {
			allKeysInArray.push(key)
		}
		return allKeysInArray
	}

	values(anArray="") {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" anArray ">")
		}
		allValuesInArray := []
		for key, value in anArray {
			allValuesInArray.push(value)
		}
		return allValuesInArray
	}

	distinct(pArray="") {
		if (!IsObject(pArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" pArray ">")
		}
		distinctValuesInArray := []
		for i, value in pArray {
			if (!distinctValuesInArray.hasKey(value)) {
				distinctValuesInArray[value] := true
			}
		}
		return Arrays.keys(distinctValuesInArray)
	}

	removeValue(anArray="", valueToRemove="", caseSensitive=false) {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" anArray ">")
		}
		numberOfRemovedValues := 0
		index := anArray.minIndex()
		while (index <= anArray.maxIndex()) {
			if ((!caseSensitive && anArray[index] = valueToRemove)
					|| (caseSensitive && anArray[index] == valueToRemove)) {
				anArray.remove(index)
				numberOfRemovedValues++
			} else {
				index++
			}
		}
		return numberOfRemovedValues
	}

	shift(anArray, shiftByElements=1) {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" anArray ">")
		}
		if (shiftByElements < 1) {
			numberOfShifts := 1
		} else if (shiftByElements > anArray.maxIndex()) {
			numberOfShifts := anArray.maxIndex()
		} else {
			numberOfShifts := shiftByElements
		}
		shiftedElements := []
		loop %numberOfShifts% {
			shiftedElements.push(anArray.remove(anArray.minIndex()))
		}
		if (shiftByElements != 1) {
			return shiftedElements
		}
		return shiftedElements[1]
	}

	append(anArray, anotherArray) {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" anArray ">")
		}
		if (!IsObject(anotherArray)) {
			throw Exception("Parameter #2 is no valid array"
					, -1, "<" anotherArray ">")
		}
		for key, value in anotherArray {
			anArray.push(value)
		}
		return anArray.maxIndex()
	}

	wrap(anArray, textWidth, indentWithText="", indent1stElementWithText=""
			, replace1stIndent=false) {
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" anArray ">")
		}
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
		if (!IsObject(anArray)) {
			throw Exception("Parameter #1 is no valid array"
					, -1, "<" anArray ">")
		}
		if (!anArray.maxIndex()) {
			return ""
		}
		index := anArray.minIndex()
		resultString := ""
		while (index <= anArray.maxIndex()) {
			element := anArray[index++]
			if (element.maxIndex() == "") {
				resultString .= (resultString != ""
						? separateWithText
						: "") element
			} else {
				resultString .= (resultString != ""
						? separateWithText
						: "") Arrays.toString(element, separateWithText)
			}
		}
		return resultString
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
