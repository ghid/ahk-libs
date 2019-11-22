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
		loop % VarSetCapacity(data) {
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
					,   limit: structMember[3]
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
					, member.type, member.value, member.limit)
		}
		return currentValue
	}

	sizeOfMember(accumulator, memberName, memberType, value, limit) {
		return accumulator + this.isWide(limit > 0
				? limit
				: Structure.typeLength(memberType)
				, memberType)
	}

	putData(aByteArray, memberName, memberType, value, limit) {
		len := Structure.typeLength(memberType)
		if (len == 0) {
			len := (limit > 0 ? limit : StrLen(value)) * (A_IsUnicode ? 2 : 1)
			VarSetCapacity(data, len, 0)
			StrPut(value, &data, len)
		} else {
			VarSetCapacity(data, len, 0)
			NumPut(value, data, 0, memberType)
		}
		loop % len {
			aByteArray.push(NumGet(data, A_Index-1, "UChar"))
		}
		return aByteArray
	}

	getData(aByteArray, memberName, memberType, anInstance, limit) {
		len := Structure.typeLength(memberType)
		if (len == 0) {
			len := this.isWide(limit > 0
					? limit
					: aByteArray.count()
					, memberType)
			VarSetCapacity(data, len + 1, 0)
		} else {
			VarSetCapacity(data, len, 0)
		}
		loop % len {
			NumPut(aByteArray[1], data, A_Index-1, "UChar")
			aByteArray.removeAt(1)
		}
		switch memberType {
		case "Str", "AStr", "WStr", "StrP", "AStrP", "WStrP"
				, "Str*", "AStr*", "WStr*":
			anInstance[memberName] := StrGet(&data, len)
		default:
			anInstance[memberName] := NumGet(data, 0, memberType)
		}
		return aByteArray
	}

	isWide(size, memberType="") {
		switch memberType {
		case "WStr", "WStrP", "WStr*":
			return size * 2
		case "AStr", "AStrP", "AStr*":
			return size
		case "Str", "StrP", "Str*":
			return size * (A_IsUnicode ? 2 : 1)
		default:
			return size
		}
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
		case "Str", "AStr", "WStr", "StrP", "AStrP", "WStrP"
				, "Str*", "AStr*", "WStr*":
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