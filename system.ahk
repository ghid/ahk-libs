class System {

	version() {
		return "1.0.0"
	}

	requires() {
		return []
	}

	static FORMAT_MESSAGE_ALLOCATE_BUFFER := 0x00000100
	static FORMAT_MESSAGE_ARGUMENT_ARRAY  := 0x00002000
	static FORMAT_MESSAGE_FROM_HMODULE    := 0x00000800
	static FORMAT_MESSAGE_FROM_STRING     := 0x00000400
	static FORMAT_MESSAGE_FROM_SYSTEM     := 0x00001000
	static FORMAT_MESSAGE_IGNORE_INSERTS  := 0x00000200
	static FORMAT_MESSAGE_MAX_WIDTH_MASK  := 0x000000FF

	static vArgs = System.__vArgs()

	__new() {
		throw Exception("Instantiation of class '"
				. System.__Class "' is not allowed")
	}

	__vArgs() {
		global
		OutputDebug %A_ThisFunc%: Use `A_Args` instead
		local _argList := []

		loop %0% {
			_argList.push(%A_Index%)
		}

		return _argList
	}

	getLastError() {
		return DllCall("GetLastError", UInt)
	}

	formatMessage(dwFlags=0, lpSource=0, dwMessageId=0, dwLanguageId=0
			, ByRef lpBuffer="", nSize=0, va_list*) {
		nSize := (A_IsUnicode ? 2 * nSize : nSize)
		VarSetCapacity(lpBuffer, nSize, 0)

		if (dwFlags & System.FORMAT_MESSAGE_ARGUMENT_ARRAY) {
			VarSetCapacity(pArgs, va_list.maxIndex() * A_PtrSize, 0)
			_ofs := 0
			loop % va_list.maxIndex() {
				NumPut(va_list[A_Index], pArgs, _ofs, "Ptr")
				_ofs += A_PtrSize
			}
		} else {
			pArgs := 0
		}

		nChars := DllCall("FormatMessage"
				, "UInt", dwFlags
				, "Ptr", lpSource
				, "UInt", dwMessageId
				, "UInt", dwLanguageId
				, "Ptr", &lpBuffer
				, "UInt", nSize
				, "Ptr", &pArgs
				, "UInt")

		VarSetCapacity(lpBuffer, -1)
		return nChars
	}

	newUuid() {
		try {
			VarSetCapacity(_uuid,16)
			DllCall("Rpcrt4\UuidCreate","Str", _uuid)
			DllCall("Rpcrt4\UuidToString", "Ptr", &_uuid
					, "Ptr *", pStr := 0, "Int")
			System.strCpy(pStr, stUuid)
		} catch _ex {
			throw _ex
		}
		return stUuid
	}

	arrayCopy(ByRef src, srcPos, ByRef dest, destPos, length) {
		if (!IsObject(src)) {
			throw Exception("InvalidArrayException: src: " src)
		}
		if (!IsObject(dest)) {
			throw Exception("InvalidArrayException: dest: " dest)
		}
		if (srcPos < src.minIndex()) {
			throw Exception("IndexOutOfBoundsException: srcPos < "
					. src.minIndex() ": " srcPos)
		}
		if (srcPos > src.maxIndex()) {
			throw Exception("IndexOutOfBoundsException: srcPos > "
					. src.maxIndex() ": " srcPos)
		}
		if (destPos < dest.minIndex()) {
			throw Exception("IndexOutOfBoundsException: destPos < "
					. dest.minIndex() ": " destPos)
		}
		if (destPos > dest.maxIndex()) {
			throw Exception("IndexOutOfBoundsException: destPos > "
					. dest.maxIndex() ": " destPos)
		}
		loop %length% {
			dest[destPos + (A_Index - 1)] := src[srcPos + (A_Index - 1)]
		}
	}

	strCpy(ByRef ptr, ByRef string) {
		if (A_IsUnicode) {
			ptrLen := DllCall("lstrlenW", "Ptr", ptr)
			VarSetCapacity(string, ptrLen * 2)
			return DllCall("lstrcpyW", "WStr", string, "Ptr", ptr)
		}
		ptrLen := DllCall("lstrlenA", "Ptr", ptr)
		VarSetCapacity(string, ptrLen)
		return DllCall("lstrcpyA", "AStr", string, "Ptr", ptr)
	}

	strPut(st, ByRef var, encoding, ret_as_str=false) {
		VarSetCapacity(var, StrPut(st, encoding)
				* ((encoding = "utf-16" || encoding = "cp1200") ? 2 : 1))
		length := StrPut(st, &var, encoding)
		if (!ret_as_str) {
			return length
		}
		VarSetCapacity(var, -1)
		return var
	}

	ptrListToStrArray(ptrListAddress, addEmptyElement=true) {
		ofs := 0
		strArray :=  []
		loop {
			if (addr := NumGet(ptrListAddress+ofs, "Ptr")) {
				strArray.push(StrGet(addr))
			}
			ofs += A_PtrSize
		} until (addr == 0)
		if (addEmptyElement) {
			strArray.push("")
		}
		return strArray
	}

	strArrayToPtrList(anArray, ByRef ptrList) {
		size := 0
		if (anArray.count() != "") {
			size := VarSetCapacity(ptrList, (anArray.count()+1)*A_PtrSize)
			ofs := 0
			for k, _ in anArray {
				addr := anArray.getAddress(k)
				NumPut(addr, &ptrList+ofs, "Ptr")
				ofs += A_PtrSize
			}
			NumPut(0, &ptrList+ofs, "Ptr")
		}
		return size
	}

	strArrayToStrArrayList(ByRef a, ByRef ptr) {
		i := a.minIndex()
		l := 1
		while (i <= a.maxIndex()) {
			l += StrLen(a[i++]) + 1
		}
		s := VarSetCapacity(ptr, l * (A_IsUnicode ? 2 : 1), 0)
		i := a.minIndex()
		_ofs := 0
		while (i <= a.maxIndex()) {
			l := (StrLen(a[i]) + 1)*(A_IsUnicode ? 2 : 1)
			StrPut(a[i], &ptr+_ofs, l)
			_ofs+=l
			i++
		}
		return s
	}

	ptrList(ByRef p, a*) {
		s := VarSetCapacity(p, (a.maxIndex() - a.minIndex() + 1) * A_PtrSize, 0)
		ofs := 0
		i := a.minIndex()
		while (i <= a.maxIndex()) {
			NumPut(a[i++], p, ofs, "Ptr")
			ofs += A_PtrSize
		}
		return s
	}

	envGet(var_name) {
		EnvGet content, %var_name%
		return content
	}

	; @todo: Refactor!
	which(file, dirs=".", exts="*", all_matches=false) {
		SplitPath file, file_name, file_dir, file_ext, file_name_no_ext
		if (!file_ext) {
			if (!IsObject(exts) && exts != "") {
				exts := StrSplit(exts, ";")
			}
		} else {
			exts := [ file_ext ]
		}
		if (!file_dir) {
			if (!IsObject(dirs) && dirs != "") {
				dirs := StrSplit(dirs, ";")
			}
		}
		loop % exts.maxIndex() {
			if (SubStr(exts[A_Index], 1, 1) != ".") {
				exts[A_Index] := "." exts[A_Index]
			}
		}

		found := []
		if (file_dir = "") {
			loop % dirs.maxIndex() {
				search_path := dirs[A_Index]
				loop % exts.maxIndex() {
					search_file := search_path
							. "\" file_name_no_ext exts[A_Index]
					if (RegExMatch(FileExist(search_file), "[RASHNOCT]")) {
						found.push(search_file)
						if (!all_matches) {
							break
						}
					}
				}
			}
		} else {
			loop % exts.maxIndex() {
				search_file := file_dir "\" file_name_no_ext exts[A_Index]
				if (RegExMatch(FileExist(search_file), "[RASHNOCT]")) {
					found.push(search_file)
					if (!all_matches) {
						break
					}
				}
			}
		}
		if (!all_matches) {
			return found[1]
		}
		return found
	}

	runProcess(Command, Stream_To="", Working_Dir="", Input_Data=""
			, timeoutMSecs=5000) {
		S_Temp := ""
		N_Temp := ""
		Output := ""
		H_StdIn_Reader := 0
		H_StdIn_Writer := 0
		H_StdOut_Reader := 0
		H_StdOut_Writer := 0
		DllCall("CreatePipe"
				, "Ptr*", H_StdIn_Reader
				, "Ptr*", H_StdIn_Writer
				, "UInt", 0
				, "UInt", 0)

		DllCall("CreatePipe"
				, "Ptr*", H_StdOut_Reader
				, "Ptr*", H_StdOut_Writer
				, "UInt", 0
				, "UInt" ,0)

		DllCall("SetHandleInformation"
				, "Ptr", H_StdIn_Reader
				, "UInt", 1
				, "UInt", 1)

		DllCall("SetHandleInformation"
				, "Ptr", H_StdOut_Writer
				, "UInt", 1
				, "UInt", 1)

		if (A_PtrSize = 4) {
			VarSetCapacity(Process_Info, 16, 0)
			Startup_Info_Size := VarSetCapacity(Startup_Info, 68, 0)
			NumPut(Startup_Info_Size,	Startup_Info,	 0, "UInt")
			NumPut(0x100,					Startup_Info,	44, "UInt")
			NumPut(H_StdIn_Reader,		Startup_Info,	56, "Ptr")
			NumPut(H_StdOut_Writer,		Startup_Info,	60, "Ptr")
			NumPut(H_StdOut_Writer,		Startup_Info,	64, "Ptr")
		} else if (A_PtrSize = 8) {
			VarSetCapacity(Process_Info, 24, 0)
			Startup_Info_Size := VarSetCapacity(Startup_Info, 104, 0)
			NumPut(Startup_Info_Size,	Startup_Info,	 0, "UInt")
			NumPut(0x100,					Startup_Info,	60, "UInt")
			NumPut(H_StdIn_Reader,		Startup_Info,	80, "Ptr")
			NumPut(H_StdOut_Writer,		Startup_Info,	88, "Ptr")
			NumPut(H_StdOut_Writer,		Startup_Info,	96, "Ptr")
		}

		DllCall("CreateProcess"
				, "UInt", 0
				, "Ptr", &Command
				, "UInt", 0
				, "UInt", 0
				, "Int", true
				, "UInt", 0x08000000
				, "UInt", 0
				, "Ptr", Working_Dir ? &Working_Dir : 0
				, "Ptr", &Startup_Info
				, "Ptr", &Process_Info)

		if (Input_Data != "") {
			FileOpen(H_StdIn_Writer, "h", "CP0").write(Input_Data)
		}

		Stream_To+0 ? (Alloc_Console := DllCall("AllocConsole")
				, H_Console := DllCall("CreateFile"
				, "Str", "CON"
				, "UInt", 0x40000000
				, "UInt", Alloc_Console ? 0 : 3
				, "UInt", 0
				, "UInt", 3
				, "UInt", 0
				, "UInt", 0
				, "Ptr"))
				: ""
		DllCall("CloseHandle", "Ptr", H_StdOut_Writer)
		timeoutTickCount := A_TickCount + timeoutMSecs
		loop {
			; hStdOutRd := H_StdOut_Reader
			; fout := FileOpen(hStdOutRd, "h", A_FileEncoding)
			sleep 200
			hStdOutRd := H_StdOut_Reader
			fout := FileOpen(hStdOutRd, "h", A_FileEncoding)
			data := fout.read()
			if (fout.AtEOF && data != "") {
				output .= data
				break
			}
			if (A_TickCount > timeoutTickCount) {
				Msgbox Timeout
				throw Exception("Timeout")
			}
			/*
			Result := DllCall("ReadFile"
					, "Ptr", H_StdOut_Reader
					, "Ptr", &S_Temp
					, "UInt", N_Temp
					, "UIntP", N_Size := 0
					, "UInt", 0)
			if (Result = 0) {
				break
			} else {
				NumPut(0, S_Temp, N_Size, "UChar")
				VarSetCapacity(S_Temp, -1)
				Output .= StrGet(&S_Temp, N_Size, "CP0")
				if (Stream_To != "") {
					loop {
						if (RegExMatch(Output, "[^\r\n]*\r?\n", S_Trim, N_Trim)) {
							Stream_To+0 ? DllCall("WriteFile"
									, "Ptr", H_Console
									, "Ptr", &S_Trim
									, "UInt", StrLen(S_Trim)
									, "UIntP", 0
									, "UInt", 0)
									: %Stream_To%(S_Trim)
									, N_Trim += StrLen(S_Trim)
						} else {
							break
						}
					}
				}
			}
			*/
		}

		; Stream_To+0 ? (DllCall("Sleep", "UInt", 1000)
				; , H_Console+1 ? DllCall("CloseHandle", "Ptr", H_Console)
				; : "", Alloc_Console ? DllCall("FreeConsole") : "") : ""

		; Wait_Result := DllCall("WaitForSingleObject"
				; , "Ptr", NumGet(Process_Info, 0, "Ptr")
				; , "UInt", 0xFFFFFFFF	; INFINITE
				; , "UInt")

		DllCall("CloseHandle", "Ptr", NumGet(Process_Info, 0, "Ptr"))

		DllCall("CloseHandle", "Ptr", NumGet(Process_Info, A_PtrSize, "Ptr"))

		DllCall("CloseHandle", "Ptr", H_StdIn_Writer)

		DllCall("CloseHandle", "Ptr", H_StdIn_Reader)

		DllCall("CloseHandle", "UInt", H_StdOut_Reader)

		return Output
	}

	typeOf(var, type="") {
		types := []

		if (type) {
			if (type = "object" && IsObject(var)) {
				return true
			}
			if var is %type%
			{
				return true
			} else {
				return false
			}
		} else {
			type_list := ["integer", "float", "number", "digit", "xdigit"
					, "alpha", "upper", "lower", "alnum", "space", "time"]
			for i, t in type_list {
				if var is %t%
				{
					types.push(t)
				}
			}
			if (IsObject(var)) {
				types.push("object")
			}
			return types
		}
	}
}
; vim: ts=4:sts=4:sw=4:tw=0:noet
