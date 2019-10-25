class Venn {

	static OPERATION_INERSECTION := 1
	static OPERATION_UNION := 2
	static OPERATION_SYMMETRIC_DIFFERENCE := 3
	static OPERATION_RELAVIVE_COMPLEMENT := 4

	operation(setA, setB, operation, compareAsType=0) {
		if (!IsObject(setA)) {
			throw Exception("Parameter #1 is no valid array", -1)
		}
		if (!IsObject(setB)) {
			throw Exception("Parameter #2 is no valid array", -1)
		}
		Arrays.VennData.setA := setA.clone()
		Arrays.VennData.setB := setB.clone()
		Arrays.VennData.indexA := Arrays.VennData.setA.minIndex()
		Arrays.VennData.indexB := Arrays.VennData.setB.minIndex()
		Arrays.VennData.operation := operation
		Arrays.VennData.compareAsType := compareAsType
		VarSetCapacity(HIGH, 64, 0xff)
		Arrays.VennData.setA.push(HIGH)
		Arrays.VennData.setB.push(HIGH)
		return Arrays.Venn.processSetAAndSetB()
	}

	processSetAAndSetB() {
		result := []
		while ((Arrays.VennData.indexA != "" && Arrays.VennData.indexB != "")
				&& (Arrays.VennData.indexA < Arrays.VennData.setA.maxIndex()
				|| Arrays.VennData.indexB < Arrays.VennData.setB.maxIndex())) {
			result := Arrays.Venn.catchUpSetA(result)
			result := Arrays.Venn.catchUpSetB(result)
			result := Arrays.Venn.processElementsContainedInBothSets(result)
		}
		return result
	}

	catchUpSetA(result) {
		while (Arrays.VennData.indexA < Arrays.VennData.setA.maxIndex()
				&& (Arrays.VennData.setA[Arrays.VennData.indexA])
				.compare(Arrays.VennData.setB[Arrays.VennData.indexB]
				, Arrays.VennData.compareAsType) < 0) {
			if (Arrays.VennData.operation == Arrays.Venn.OPERATION_UNION
					|| Arrays.VennData.operation
					== Arrays.Venn.OPERATION_SYMMETRIC_DIFFERENCE
					|| Arrays.VennData.operation
					== Arrays.Venn.OPERATION_RELAVIVE_COMPLEMENT) {
				result := Arrays.Venn.pushToResultSet(Arrays.VennData
						.setA[Arrays.VennData.indexA]
						, result, "A")
			}
			Arrays.VennData.indexA++
		}
		return result
	}

	catchUpSetB(result) {
		while (Arrays.VennData.indexB < Arrays.VennData.setB.maxIndex()
				&& (Arrays.VennData.setB[Arrays.VennData.indexB])
				.compare(Arrays.VennData.setA[Arrays.VennData.indexA]
				, Arrays.VennData.compareAsType) < 0) {
			if (Arrays.VennData.operation == Arrays.Venn.OPERATION_UNION
					|| Arrays.VennData.operation
					== Arrays.Venn.OPERATION_SYMMETRIC_DIFFERENCE) {
				result := Arrays.Venn.pushToResultSet(Arrays.VennData
						.setB[Arrays.VennData.indexB]
						, result, "B")
			}
			Arrays.VennData.indexB++
		}
		return result
	}

	processElementsContainedInBothSets(result) {
		while ((Arrays.VennData.indexA < Arrays.VennData.setA.maxIndex()
				|| Arrays.VennData.indexB < Arrays.VennData.setB.maxIndex())
				&& (Arrays.VennData.setA[Arrays.VennData.indexA])
				.compare(Arrays.VennData.setB[Arrays.VennData.indexB]
				, Arrays.VennData.compareAsType) == 0) {
			if (Arrays.VennData.operation == Arrays.Venn.OPERATION_INERSECTION
					|| Arrays.VennData.operation
					== Arrays.Venn.OPERATION_UNION) {
				result := Arrays.Venn.pushToResultSet(Arrays.VennData
						.setA[Arrays.VennData.indexA]
						, result, "A")
				result := Arrays.Venn.pushToResultSet(Arrays.VennData
						.setB[Arrays.VennData.indexB]
						, result, "B")
			}
			if (Arrays.VennData.operation
					!= Arrays.Venn.OPERATION_RELAVIVE_COMPLEMENT) {
				Arrays.VennData.indexB++
			}
			Arrays.VennData.indexA++
		}
		return result
	}

	pushToResultSet(element, resultSet, source="") {
		resultSet.push((Arrays.VennData.printSource
				? "(" source ") "
				: "") element)
		return resultSet
	}
}

class VennData {

	static setA := []
	static setB := []
	static indexA := 0
	static indexB := 0
	static operation := ""
	static compareAsType := 0
	static printSource := false
}

