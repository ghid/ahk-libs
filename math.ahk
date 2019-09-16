class Math {

	requires() {
		return [Arrays]
	}

	static MIN_LONG  := -0x8000000000000000
	static MAX_LONG  :=  0x7FFFFFFFFFFFFFFF
	static MIN_INT   := -0x80000000
	static MAX_INT   :=  0x7FFFFFFF
	static MIN_SHORT := -0x8000
	static MAX_SHORT :=  0x7fff

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' is not allowed")
	}

	swap(ByRef p1, ByRef p2) {
		_temp := p1
		p1 := p2
		p2 := _temp
	}

	floor(p*) {
		return MathHelper.floorCeil("floor", Math.MAX_INT, p)
	}

	ceil(p*) {
		return MathHelper.floorCeil("ceil", Math.MIN_INT, p)
	}

	limitTo(pnValue, pnMin, pnMax) {
		if (pnValue >= pnMin && pnValue <= pnMax) {
			return pnValue
		}
		if (pnValue > pnMax) {
			return pnMax
		} else {
			return pnMin
		}
	}

	isEven(piValue) {
		if piValue is not integer
		{
			throw Exception("Invalid data type, integer expected"
					, -1, "<" piValue ">")
		}
		return Mod(piValue, 2) = 0
	}

	isOdd(piValue) {
		if piValue is not integer
		{
			throw Exception("Invalid data type, integer expected"
					, -1, "<" piValue ">")
		}
		return Mod(piValue, 2) != 0
	}

	isFractional(pnValue) {
		_ff := A_FormatFloat
		SetFormat Float, 0.0
		_intValue := pnValue + 0
		SetFormat Float, %_ff%
		return pnValue - _intValue != 0
	}

	root(piDegreeOfRoot, pnValue) {
		if piDegreeOfRoot is not integer
		{
			throw Exception("Invalid data type, integer excpected"
					, -1, "<" piDegreeOfRoot ">")
		}
		if pnValue is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" pnValue ">")
		}
		_floatFormat := A_FormatFloat
		SetFormat Float, 0.14 						; FIXME: with 0.15 Math.Root(5, 2476099) returns 19.000000000000004
		_root := pnValue**(1 / piDegreeOfRoot)
		SetFormat Float, %_floatFormat%
		return _root
	}

	log(piBase, pnValue) {
		if piBase is not integer
		{
			throw Exception("Invalid data type, integer excpected"
					, -1, "<" piBase ">")
		}
		if pnValue is not number
		{
			throw Exception("Invalid data type, number excpected"
					, -1, "<" pnValue ">")
		}
		_floatFormat := A_FormatFloat
		SetFormat Float, 0.16
		_n := Log(pnValue) / Log(piBase)
		SetFormat Float, %_floatFormat%
		return Log(pnValue) / Log(piBase)
	}

	isPrime(piValue) {
		if piValue is not integer
		{
			throw Exception("Invalid data type, integer excpected"
					, -1, "<" piValue ">")
		}
		if (piValue = 1) {
			return false
		}
		if (piValue >= 10) {
			cLastDigit := SubStr(piValue, 0)
			if cLastDigit not in 1,3,7,9
			{
				return false
			}
		}
		i := 2
		while (i * i <= piValue) {
			if (Mod(piValue, i) = 0) {
				return false
			}
			i++
		}
		return true
	}

	integerFactorization(pnValue) {
		if pnValue is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" pnValue ">")
		}
		if pnValue is not integer
		{
			return new PrimeFactorProduct(pnValue)
		}
		if (Math.isPrime(pnValue)) {
			return new PrimeFactorProduct(pnValue)
		}
		_pfp := new PrimeFactorProduct()
		i := 2
		while (pnValue > 1 && pnValue / i != 1) {
			while (Mod(pnValue, i) = 0) {
				_pfp.add(i)
				pnValue //= i
			}
		__FindNextPrime__:
			if (pnValue > 1) {
				loop {
					if (Math.isPrime(++i)) {
						break
					}
				}
			}
		}
		if (pnValue > 1) {	; something left?
			_pfp.add(i)		; add to factor list
		}
		return _pfp
	}

	greatestCommonDivisor(pnValue1="", pnValue2="", pbUseEuklid=true) {
		if pnValue1 is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" pnValue1 ">")
		}
		if pnValue2 is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" pnValue2 ">")
		}
		__ByEuklidAlgorithm__:
		if (pbUseEuklid) {
			return MathHelper.GCDEuklid(pnValue1, pnValue2)
		}
		__ByIntegerFactorization__:
		nGCD := 1
		_pf1 := Math.integerFactorization(pnValue1).getList()
		_pf2 := Math.integerFactorization(pnValue2).getList()
		_pfi := Arrays.distinct(Arrays.intersection(_pf1, _pf2))
		for i, _factor in _pfi {
			nGCD *= _factor
		}
		return nGCD
	}

	lowestCommonMultiple(pnValue1="", pnValue2="") {
		if pnValue1 is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" pnValue1 ">")
		}
		if pnValue2 is not number
		{
			throw Exception("Invalid data type, number expected"
					, -1, "<" pnValue2 ">")
		}
		nLCM := 1
		_pf1 := Math.integerFactorization(pnValue1).getList()
		_pf2 := Math.integerFactorization(pnValue2).getList()
		_dist1 := Arrays.distinct(_pf1)
		_count1 := 0, _count2 := 0
		for i, _factor in _dist1 {
			_count1 := Arrays.countOccurences(_pf1, _factor)
			_count2 := Arrays.countOccurences(_pf2, _factor)
			if (_count1 >= _count2) {
				nLCM *= _factor**_count1
				Arrays.removeValue(_pf2, _factor)
			} else {
				nLCM *= _factor**_count2
				Arrays.removeValue(_pf2, _factor)
			}
		}
		for i, _factor in _pf2 {
			nLCM *= _factor
		}
		return nLCM
	}

	zeroFillShiftR(num, shift) {
		if (shift = 0) {
			return num
		}
		if (shift < 0) {
			return ~(-1 << (shift*-1))
		}
		masklt := num<0
		num := num >> shift
		if (masklt) {
			num &= Math.MAX_LONG
		}
		return num
	}

	numberOfLeadingZeros(i) {
		if (i = 0) {
			return 64
		}
		n := 1
		x := UI(Math.zeroFillShiftR(i, 32))
		if (x = 0) {
			n += 32, x := I(i)
		}
		if (Math.zeroFillShiftR(x, 16) = 0) {
			n += 16, I(x <<= 16)
		}
		if (Math.zeroFillShiftR(x, 24) = 0) {
			n += 8, I(x <<= 8)
		}
		if (Math.zeroFillShiftR(x, 28) = 0) {
			n += 4, I(x <<= 4)
		}
		if (Math.zeroFillShiftR(x, 30) = 0) {
			n += 2, I(x <<= 2)
		}
		n -= I(Math.zeroFillShiftR(x, 31))
		return n
	}

	bitCount(i) {
		i := i - (Math.zeroFillShiftR(i, 1) & 0x5555555555555555)
		i := (i & 0x3333333333333333) + (Math.zeroFillShiftR(i, 2)
				& 0x3333333333333333)
		i := (i + Math.zeroFillShiftR(i, 4)) & 0x0f0f0f0f0f0f0f0f
		i := i + (Math.zeroFillShiftR(i, 8))
		i := i + (Math.zeroFillShiftR(i, 16))
		i := i + (Math.zeroFillShiftR(i, 32))
		return I(i & 0x7f)
	}

	numberOfTrailingZeros(i) {
		if (i = 0) {
			return 64
		}
		n := 63
		y := I(i)
		if (y != 0) {
			n := n -32, x := y
		} else {
			x := I(Math.zeroFillShiftR(i, 32))
		}
		y := I(x <<16)
		if (y != 0) {
			n := n -16, x := y
		}
		y := I(x << 8)
		if (y != 0) {
			n := n - 8, x := y
		}
		y := I(x << 4)
		if (y != 0) {
			n := n - 4, x := y
		}
		y := I(x << 2)
		if (y != 0) {
			n := n - 2, x := y
		}
		return n - (Math.zeroFillShiftR(UI(x << 1), 31))
	}
}

class MathHelper {

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' ist not allowed", -1)
	}

	floorCeil(pstrType, pnFloorCeil, p*) {
		for i, v in p {
			if (v.maxIndex() != "") {
				for j, v1 in v {
					if (!IsObject(v1)) {
						if v1 is not number
						{
							throw Exception("Invalid data type", -1, "<" v1 ">")
						}
						if ((pstrType = "ceil" && v1 > pnFloorCeil)
								|| (pstrType = "floor" && v1 < pnFloorCeil)) {
							pnFloorCeil := v1
						}
					} else {
						pnFloorCeil := MathHelper.floorCeil(pstrType
								, pnFloorCeil, v1)
					}
				}
			} else {
				if v is not number
				{
					throw Exception("Invalid data type", -1, "<" v ">")
				}
				if ((pstrType = "ceil" && v > pnFloorCeil)
						|| (pstrType = "floor" && v < pnFloorCeil)) {
					pnFloorCeil := v
				}
			}
		}
		return pnFloorCeil
	}

	GCDEuklid(pnValue1, pnValue2) { ; ahklint-ignore: W007
		if (pnValue1 < pnValue2) {
			Math.swap(pnValue1, pnValue2)
		}
		return MathHelper.GCDEuklidRecursion(pnValue1, pnValue2)
	}

	GCDEuklidRecursion(pnValue1, pnValue2) { ; ahklint-ignore: W007
		_remain := Mod(pnValue1, pnValue2)
		if (_remain > 0) {
			return MathHelper.GCDEuklidRecursion(pnValue2, _remain)
		}
		return pnValue2
	}
}

class PrimeFactorProduct {

	FactorList := []
	iFactors   := 0

	__new(piFactor="") {
		if (piFactor != "") {
			this.factorList.push(piFactor)
			this.iFactors := 1
		}
		return this
	}

	count() {
		return this.iFactors
	}

	add(piFactor) {
		this.factorList.push(piFactor)
		this.iFactors++
		return this.factorList.maxIndex()
	}

	getList() {
		return this.factorList
	}

	toString(pbCompact=false, pstrPower="**") {
		_string := ""
		if (!pbCompact) {
			for i, _factor in this.factorList {
				_string .= (_string = "" ? "" : "*") _factor
			}
		} else {
			_count := 0
			_lastFactor := this.factorList[1]
			for i, _factor in this.factorList {
				if (i = 1 || _factor = _lastFactor) {
					_count++
				} else {
					_string .= (_string = "" ? "" : "*") _lastFactor
							. (_count > 1 ? pstrPower _count : "")
					_lastFactor := _factor
					_count := 1
				}
			}
			_string .= (_string = "" ? "" : "*") _lastFactor
					. (_count > 1 ? pstrPower _count : "")
		}
		return _string
	}
}

; ahklint-ignore-begin: W007
I(i) {
	; return (i > 0x7fffffff ? -(~i) - 1 : i < -0x80000000 ? i & ~0x80000000 : i)
	return i << 32 >> 32
}

S(s) {
	return s << 48 >> 48
}

L(l) {
	return l << 64 >> 64
}

UI(i) {
	return i & 0xffffffff
}

US(s) {
	return s & 0xffff
}

UL(l) {
	return l & 0xffffffffffffffff
}
; ahklint-ignore-end
