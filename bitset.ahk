class BitSet {

	requires() {
		return [TestCase, Arrays, System, Math]
	}

	; @SeeAlso: http://www.docjar.com/html/api/java/util/BitSet.java.html

	static ADDRESS_BITS_PER_WORD := 6
	static BITS_PER_WORD := 1 << BitSet.ADDRESS_BITS_PER_WORD
	static BIT_INDEX_MASK := BitSet.BITS_PER_WORD - 1
	static WORD_MASK := 0xffffffffffffffff

	words := []
	wordsInUse := 0
	sizeIsSticky := false

	wordIndex(bitIndex) {
		return I(bitIndex >> BitSet.ADDRESS_BITS_PER_WORD)
	}

	checkInvariants() {
		words_length := (this.words.maxIndex() == ""
				? 0
				: this.words.maxIndex()+1)
		try {
			TestCase.assert(this.wordsInUse == 0
					|| this.words[this.wordsInUse - 1] != 0
					, A_ThisFunc ": Assertion 1 failed")
			TestCase.assert(this.wordsInUse >= 0
					&& this.wordsInUse <= words_length
					, A_ThisFunc ": Assertion 2 failed")
			TestCase.assert(this.wordsInUse == words_length
					|| this.words[this.wordsInUse] == 0
					, A_ThisFunc ": Assertion 3 failed")
		} catch gotException {
			throw gotException
		}
	}

	recalculateWordsInUse() {
		i := this.wordsInUse - 1
		while (i >= 0) {
			if (this.words[i] != 0) {
				break
			}
			i--
		}
		this.wordsInUse := i + 1
	}

	__new(arg="") {
		if (!arg) {
			this.initWords(BitSet.BITS_PER_WORD)
			this.sizeIsSticky := false
		} else if (IsObject(arg)) {
			words := arg
			loop % arg.maxIndex() {
				this.words[A_Index-1] := words[A_Index]
			}
			this.wordsInUse := (words.maxIndex() = "" ? 0 : words.maxIndex())
			this.checkInvariants()
		} else {
			nbits := arg
			if (nbits < 0) {
				throw Exception("NegativeArraySizeException: nbits < 0: " nbits)
			}
			this.initWords(nbits)
			this.sizeIsSticky := true
		}
		return this
	}

	initWords(nbits) {
		this.words := []
		loop % this.wordIndex(nbits-1)+1 {
			this.words[A_Index-1] := 0
		}
	}

	valueOfLong(longs) {
		n := longs.maxIndex()
		while (n > 0 && longs[n] = 0) {
			n--
		}
		return new BitSet(Arrays.copyOf(longs, n))
	}

	valueOfByte(bytes) {
		n := bytes.maxIndex()
		while (n > 0 && bytes[n - 1] == 0) {
			n--
		}
		return new BitSet(bytes)
	}

	toLongArray() {
		longArray := []
		loop % this.words.maxIndex()+1 {
			longArray.push(this.words[A_Index - 1])
		}
		return longArray
	}

	toByteArray() {
		byteArray := []
		loop % this.words.maxIndex()+1 {
			byteArray.push(this.words[A_Index - 1])
		}
		return byteArray
	}

	ensureCapacity(wordsRequired) {
		if (this.words.maxIndex()+1 < wordsRequired) {
			request := Math.ceil(2 * this.words.maxIndex()+1, wordsRequired)
			this.words := Arrays.copyOf(this.words, request)
			this.sizeIsSticky := false
		}
	}

	expandTo(wordIndex) {
		wordsRequired := wordIndex + 1
		if (this.wordsInUse < wordsRequired) {
			this.ensureCapacity(wordsRequired)
			this.wordsInUse := wordsRequired
		}
	}

	checkRange(fromIndex, toIndex) {
		if (fromIndex < 0) {
			throw Exception("IndexOutOfBoundsException: fromIndex < 0: "
					. fromIndex)
		}
		if (toIndex < 0) {
			throw Exception("IndexOutOfBoundsException: toIndex < 0: "
					. toIndex)
		}
		if (fromIndex > toIndex) {
			throw Exception("IndexOutOfBoundsException: fromIndex: "
					. fromIndex " > toIndex: " toIndex)
		}
	}

	flip(bitIndex) {
		if (bitIndex < 0) {
			throw Exception("IndexOutOfBoundsException: bitIndex < 0: "
					. bitIndex)
		}
		wordIndex := this.wordIndex(bitIndex)
		this.expandTo(wordIndex)
		this.words[wordIndex] ^= (1 << bitIndex)
		this.recalculateWordsInUse()
		this.checkInvariants()
	}

	flipRange(fromIndex, toIndex) {
		this.checkRange(fromIndex, toIndex)
		if (fromIndex = toIndex) {
			return
		}
		startWordIndex := this.wordIndex(fromIndex)
		endWordIndex := this.wordIndex(toIndex - 1)
		this.expandTo(endWordIndex)
		firstWordMask := I(BitSet.WORD_MASK << fromIndex)
		lastWordMask := Math.zeroFillShiftR(BitSet.WORD_MASK, 0-toIndex)
		if (startWordIndex = endWordIndex) {
			; Case 1: One word
			this.words[startWordIndex] ^= (firstWordMask & lastWordMask)
		} else {
			; Case 2: Multiple words
			; Handle first word
			this.words[startWordIndex] ^= firstWordMask

			; Handle intermediate words, if any
			i := I(startWordIndex+1)
			while (i < endWordIndex+1) {
				this.words[i] ^= BitSet.WORD_MASK
				i++
			}

			; Handle last word
			this.words[endWordIndex] ^= lastWordMask
		}

		this.recalculateWordsInUse()
		this.checkInvariants()
	}

	set(bitIndex) {
		if (bitIndex < 0) {
			throw Exception("IndexOutOfBoundsException: bitIndex < 0: "
					. bitIndex)
		}
		wordIndex := this.wordIndex(bitIndex)
		this.expandTo(wordIndex)
		this.words[wordIndex] |= (1 << bitIndex)
		this.checkInvariants()
	}

	setValue(bitIndex, value) {
		if (value) {
			this.set(bitIndex)
		} else {
			this.clear(bitIndex)
		}
	}

	setRange(fromIndex, toIndex) {
		if (fromIndex = toIndex) {
			return
		}
		startWordIndex := this.wordIndex(fromIndex)
		endWordIndex := this.wordIndex(toIndex - 1)
		this.expandTo(endWordIndex)
		firstWordMask := BitSet.WORD_MASK << fromIndex
		lastWordMask := Math.zeroFillShiftR(BitSet.WORD_MASK, -toIndex)
		if (startWordIndex = endWordIndex) {
			; Case 1: One word
			this.words[startWordIndex] |= (firstWordMask & lastWordMask)
		} else {
			; Case 2: Multiple words
			; Handle first word
			this.words[startWordIndex] |= firstWordMask
			; Handle intermediate words, if any
			i := I(startWordIndex+1)
			while (i < endWordIndex) {
				this.words[i] = BitSet.WORD_MASK
			}
			; Handle last word
			this.words[endWordIndex] |= lastWordMask
		}
		this.checkInvariants()
	}

	and(set) {
		if (this = set) {
			return
		}
		while (this.wordsInUse > set.wordsInUse) {
			this.words[--wordsInUse] := 0
		}
		i := 0
		while (i < this.wordsInUse) {
			this.words[i] &= set.words[i]
			i++
		}
		this.recalculateWordsInUse()
		this.checkInvariants()
	}

	or(set) {
		if (this = set) {
			return
		}
		wordsInCommon := Math.floor(this.wordsInUse, set.wordsInUse)
		if (this.wordsInUse < set.wordsInUse) {
			this.ensureCapacity(set.wordsInUse)
			this.wordsInUse := set.wordsInUse
		}

		i := 0
		while (i < wordsInCommon) {
			this.words[i] |= set.words[i]
			i++
		}
		if (wordsInCommon < set.wordsInUse) {
			System.arrayCopy(set.words, wordsInCommon, this.words, wordsInCommon
					, this.wordsInUse - wordsInCommon)
		}
		this.checkInvariants()
	}

	xor(set) {
		wordsInCommon := Math.floor(this.wordsInUse, set.wordsInUse)
		if (this.wordsInUse < set.wordsInUse) {
			this.ensureCapacity(set.wordsInUse)
			this.wordsInUse := set.wordsInUse
		}
		i := 0
		while (i < wordsInCommon) {
			this.words[i] ^= set.words[i]
			i++
		}
		if (wordsInCommon < set.wordsInUse) {
			System.arrayCopy(set.words, wordsInCommon, this.words, wordsInCommon
					, set.wordsInUse - wordsInCommon)
		}
		this.recalculateWordsInUse()
		this.checkInvariants()
	}

	andNot(set) {
		i := Math.floor(this.wordsInUse, set.wordsInUse) - 1
		while (i >= 0) {
			this.words[i] &= ~set.words[i]
			i--
		}
		this.recalculateWordsInUse()
		this.checkInvariants()
	}

	clear(bitIndex="") {
		if (bitIndex == "") {
			loop % this.wordsInUse {
				this.words[A_Index-1] := 0
			}
			return
		}
		if (bitIndex < 0) {
			throw Exception("IndexOutOfBoundsException: bitIndex < 0: "
					. bitIndex)
		}

		wordIndex := this.wordIndex(bitIndex)
		if (wordIndex >= this.wordsInUse) {
			return
		}
		this.words[wordIndex] &= ~(1 << bitIndex)
		this.recalculateWordsInUse()
		this.checkInvariants()
	}

	clearRange(fromIndex, toIndex) {
		if (fromIndex = toIndex) {
			return
		}
		startWordIndex := this.wordIndex(fromIndex)
		if (startWordIndex >= this.wordsInUse) {
			return
		}
		endWordIndex := this.wordIndex(toIndex - 1)
		if (endWordIndex >= this.wordsInUse) {
			toIndex := this.length()
			endWordIndex := this.wordsInUse - 1
		}
		firstWordMask := I(BitSet.WORD_MASK << fromIndex)
		lastWordMask := Math.zeroFillShiftR(BitSet.WORD_MASK, -toIndex)
		if (startWordIndex = endWordIndex) {
			; Case 1: One word
			this.words[startWordIndex] &= ~(firstWordMask & lastWordMask)
		} else {
			; Case 2: Multiple words
			; Handle first word
			this.words[startWordIndex+1] &= ~firstWordMask
			; Handle intermediate words, if any
			i := I(startWordIndex+1)
			while (i < endWordIndex+1) {
				this.words[i] = 0
			}
			; Handle last word
			this.words[endWordIndex] &= ~lastWordMask
		}
	}

	get(bitIndex) {
		if (bitIndex < 0) {
			throw Exception("IndexOutOfBoundsException: bitIndex < 0: "
					. bitIndex)
		}
		this.checkInvariants()
		wordIndex := this.wordIndex(bitIndex)
		return wordIndex < this.wordsInUse
				&& ((this.words[wordIndex] & (1 << bitIndex)) != 0)
	}

	getRange(fromIndex, toIndex) {
		this.checkRange(fromIndex, toIndex)
		this.checkInvariants()
		len := this.length()
		if (len <= fromIndex || fromIndex == toIndex) {
			return new BitSet(0)
		}
		if (toIndex > len) {
			toIndex := len
		}
		result := new BitSet(toIndex - fromIndex)
		targetWords := this.wordIndex(toIndex - fromIndex - 1) + 1
		sourceIndex := this.wordIndex(fromIndex)
		wordAligned := ((fromIndex & BitSet.BIT_INDEX_MASK) = 0)
		; Process all words but the last word
		i := 0
		while (i < targetWords - 1) {
			result.words[i] := wordAligned ? this.words[sourceIndex]
					: Math.zeroFillShiftR(this.words[sourceIndex], fromIndex)
					| I((this.words[sourceIndex+1] << -fromIndex))
			i++
			sourceIndex++
		}
		; Process the last word
		lastWordMask := mATH.zeroFillShiftR(BitSet.WORD_MASK, -toIndex)
		result.words[targetWords] := ((toIndex-1) & BitSet.BIT_INDEX_MASK)
				< (fromIndex & BitSet.BIT_INDEX_MASK)
				? ((Math.zeroFillShiftR(this.words[sourceIndex], fromIndex))
				| (I(this.words[sourceIndex+1] & lastWordMask) << -fromIndex))
				: (Math.zeroFillShiftR(this.words[sourceIndex] & lastWordMask
				, fromIndex))
		; Set wordsInuse correctly
		result.wordsInUse := targetWords
		result.recalculateWordsInUse()
		result.checkInvariants()
		return result
	}

	nextSetBit(fromIndex) {
		if (fromIndex < 0) {
			throw Exception("IndexOutOfBoundsException: fromIndex: " fromIndex)
		}
		this.checkInvariants()
		u := this.wordIndex(fromIndex)
		if (u >= this.wordsInUse) {
			return -1
		}
		word := this.words[u] & (BitSet.WORD_MASK << fromIndex)
		loop {
			if (word != 0) {
				return (u * BitSet.BITS_PER_WORD)
						+ Math.numberOfTrailingZeros(word)
			}
			if (++u == this.wordsInUse) {
				return -1
			}
			word := this.words[u]
		}
	}

	nextClearBit(fromIndex) {
		if (fromIndex < 0) {
			throw Exception("IndexOutOfBoundsException: fromIndex < 0: "
					. fromIndex)
		}
		this.checkInvariants()
		u := this.wordIndex(fromIndex)
		if (u >= this.wordsInUse) {
			return fromIndex
		}
		word := ~this.words[u] & (BitSet.WORD_MASK << fromIndex)
		loop {
			if (word != 0) {
				return u * BitSet.BITS_PER_WORD
						+ Math.numberOfTrailingZeros(word)
			}
			if (++u = this.wordsInUse) {
				return this.wordsInUse * BitSet.BITS_PER_WORD
			}
			word := ~this.words[u]
		}
	}

	length() {
		if (this.wordsInUse = 0) {
			return 0
		}
		return BitSet.BITS_PER_WORD * (this.wordsInUse - 1)
				+ (BitSet.BITS_PER_WORD
				- Math.numberOfLeadingZeros(this.words[this.wordsInUse - 1]))
	}

	cardinality() {
		sum := 0
		loop % this.wordsInUse {
			sum += Math.bitCount(this.words[A_Index])
		}
		return sum
	}

	toString() {
		this.checkInvariants()
		numBits := (this.wordsInUse > 128)
				? this.cardinality()
				: this.wordsInUse * BitSet.BITS_PER_WORD
		b := "{"
		i := I(this.nextSetBit(0))
		if (i != -1) {
			b .= i
			i := I(this.nextSetBit(i+1))
			while (i >= 0) {
				endOfRun := I(this.nextClearBit(i))
			    while (i < endOfRun) {
					b .= ", " i
					i++
				}
				i := I(this.nextSetBit(i+1))
			}
		}
		b .= "}"

		return b
	}
}
