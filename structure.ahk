class Structure {

	requires() {
		return [Object]
	}

	struct := []

	implode(ByRef data) {
		byteArray := this.traverse({onMember: Structure.putData.bind(this)
				, onMissingMember: Structure.putData.bind(this)}, [])
		VarSetCapacity(data, this.sizeOf(), 0)
		loop % byteArray.count() {
			NumPut(byteArray[A_Index], data, A_Index-1, "UChar")
		}
	}

	explode(ByRef data) {
		byteArray := []
		loop % this.sizeOf() {
			byteArray.push(NumGet(data, A_Index-1, "UChar"))
		}
		this.traverse({onMember: Structure.getData.bind(this)
				, onMissingMember: Structure.getData.bind(this)}, byteArray)
	}

	sizeOf() {
		return this.traverse({onMember: Structure.sizeOfMember.bind(this)
				, onMissingMember: Structure.sizeOfMember.bind(this)}, 0)
	}

	dump() {
		return this.traverse({onMember: Structure.dumpMember.bind(this)
				, onMissingMember: Structure.dumpMissingMember.bind(this)
				, onStructure: Structure.dumpStructureName.bind(this)
				, onEndOfStructure: Structure.dumpEndOfStructure.bind(this)}
				, "")
	}

	traverse(callbackFuncs, initialValue) {
		result := initialValue
		loop % this.struct.count() {
			structMember := this.struct[A_Index]
			member := { name: structMember[1]
					,   type: structMember[2]
					,   value: this[structMember[1]] }
			if (this.hasKey(member.name)) {
				result := this.handleMember(result, member, callbackFuncs)
			} else {
				member.value := this
				result := this.handleMissingMember(result, member
						, callbackFuncs)
			}
		}
		return result
	}

	handleMember(resultSoFar, member, callbackFuncs) {
		if (this.isOfTypeStructure(member.value)) {
			resultAfterTraverse := member.value.traverse(callbackFuncs
					, this.doCallback(callbackFuncs, "onStructure"
					, resultSoFar, member))
			result := this.doCallback(callbackFuncs, "onEndOfStructure"
					, resultAfterTraverse, member)
		} else {
			result := this.doCallback(callbackFuncs, "onMember"
					, resultSoFar, member)
		}
		return result
	}

	handleMissingMember(resultSoFar, member, callbackFuncs) {
		return this.doCallback(callbackFuncs, "onMissingMember", resultSoFar
				, member)
	}

	isOfTypeStructure(aStructure) {
		return IsObject(aStructure)
				&& Object.instanceOf(aStructure, "Structure")
	}

	doCallback(callbackFuncs, eventName, currentValue, member) {
		if (callbackFuncs.hasKey(eventName)) {
			return callbackFuncs[eventName].call(currentValue, member.name
					, member.type, member.value)
		}
		return currentValue
	}

	sizeOfMember(accumulator, memberName, memberType) {
		return accumulator + Structure.typeLength(memberType)
	}

	putData(aByteArray, memberName, memberType, value) {
		len := Structure.typeLength(memberType)
		VarSetCapacity(data, len, 0)
		NumPut(value, data, 0, memberType)
		loop % len {
			aByteArray.push(NumGet(data, A_Index-1, "UChar"))
		}
		return aByteArray
	}

	getData(aByteArray, memberName, memberType, anInstance) {
		len := Structure.typeLength(memberType)
		VarSetCapacity(data, len, 0)
		loop % len {
			NumPut(aByteArray[1], data, A_Index-1, "UChar")
			aByteArray.removeAt(1)
		}
		anInstance[memberName] := NumGet(data, 0, memberType)
		return aByteArray
	}

	dumpMember(accumulator, memberName, memberType, value) {
		return accumulator "`n" memberName " -> " value
	}

	dumpStructureName(accumulator, memberName) {
		return accumulator "`n" memberName " {"
	}

	dumpEndOfStructure(accumulator, memberName) {
		return accumulator "`n} " memberName
	}

	dumpMissingMember(accumulator, memberName) {
		return accumulator "`n" memberName " <not set>"
	}

	typeLength(type) {
		switch type {
		case "Str", "AStr", "WStr":
			return 0
		case "Char", "CharP", "Char*", "UChar", "UCharP", "UChar*":
			return 1
		case "Short", "ShortP", "Short*", "UShort", "UShortP", "UShort*":
			return 2
		case "Int", "IntP", "Int*", "UInt", "UIntP", "UInt*":
			return 4
		case "Int64", "Int64P", "Int64*", "UInt64", "UInt64P", "UInt64*":
			return 8
		case "Ptr", "PtrP", "Ptr*", "UPtr", "UPtrP", "UPtr*":
			return A_PtrSize
		case "Float":
			return 4
		case "Double":
			return 8
		default:
			throw Exception("Unknown type: " type)
		}
	}
}
