; ahk: console
#NoEnv
SetBatchLines -1
#Warn All, StdOut

#Include <testcase-libs>

#Include %A_ScriptDir%\..\bitset.ahk

class BitSetTest extends TestCase {

	@Test_BitSetClass() {
		this.assertEquals(BitSet.ADDRESS_BITS_PER_WORD, 6)
		This.assertEquals(BitSet.BITS_PER_WORD, 64)
		this.assertEquals(BitSet.BIT_INDEX_MASK, 63)
		this.assertEquals(BitSet.WORD_MASK, 0xffffffffffffffff)
		this.assertTrue(IsFunc(BitSet.wordIndex))
		this.assertTrue(IsFunc(BitSet.checkInvariants))
		this.assertTrue(IsFunc(BitSet.recalculateWordsInUse))
		this.assertTrue(IsFunc(BitSet.__new))
		this.assertTrue(IsFunc(BitSet.initWords))
		this.assertTrue(IsFunc(BitSet.valueOfLong))
		this.assertTrue(IsFunc(BitSet.toLongArray))
		this.assertTrue(IsFunc(BitSet.expandTo))
		this.assertTrue(IsFunc(BitSet.checkRange))
		this.assertTrue(IsFunc(BitSet.flip))
		this.assertTrue(IsFunc(BitSet.length))
		this.assertTrue(IsFunc(BitSet.nextSetBit))
	}

	@Test_NextSetBit() {
		bs := new BitSet([102])
		;        76543210
		;        --------
		; 102b = 01100110
		this.assertEquals(bs.nextSetBit(0), 1)
		this.assertEquals(bs.nextSetBit(1), 1)
		this.assertEquals(bs.nextSetBit(2), 2)
		this.assertEquals(bs.nextSetBit(3), 5)
		this.assertEquals(bs.nextSetBit(4), 5)
		this.assertEquals(bs.nextSetBit(5), 5)
		this.assertEquals(bs.nextSetBit(6), 6)
		this.assertEquals(bs.nextSetBit(7), -1)
	}

	@Test_NextClearBit() {
		bs := new BitSet([102])
		;        76543210
		;        --------
		; 102b = 01100110
		this.assertEquals(bs.nextClearBit(0), 0)
		this.assertEquals(bs.nextClearBit(1), 3)
		this.assertEquals(bs.nextClearBit(2), 3)
		this.assertEquals(bs.nextClearBit(3), 3)
		this.assertEquals(bs.nextClearBit(4), 4)
		this.assertEquals(bs.nextClearBit(5), 7)
		this.assertEquals(bs.nextClearBit(6), 7)
		this.assertEquals(bs.nextClearBit(7), 7)
		this.assertEquals(bs.nextClearBit(8), 8)
	}

	@Test_ToString() {
		bs := new BitSet()
		this.assertEquals(bs.toString(), "{}")
		this.assertEquals(bs.length(), 0)
		bs := new BitSet([102])
		this.assertEquals(bs.toString(), "{1, 2, 5, 6}")

		bs := new BitSet([1454, 102])
		this.assertEquals(bs.toString()
				, "{1, 2, 3, 5, 7, 8, 10, 65, 66, 69, 70}")
	}

	@Test_New() {
		bs := new BitSet()
		this.assertTrue(IsObject(bs))
		this.assertEquals(bs.length(), 0)
		bs := new BitSet(0)
		this.assertTrue(IsObject(bs))
		this.assertEquals(bs.length(), 0)
		bs := new BitSet(16)
	    this.assertEquals(bs.length(), 0)
		bs.set(0)
		this.assertEquals(bs.length(), 1)
		bs.set(1)
		this.assertEquals(bs.length(), 2)
		bs.set(2)
		this.assertEquals(bs.length(), 3)
		bs.set(127)
		this.assertEquals(bs.length(), 128)
		bs := BitSet.valueOfLong([42])
		bs := BitSet.valueOfLong([0])
	}

	@Test_ValueOfLongs() {
		bs := new BitSet().valueOfLong([1527])
		this.assertTrue(Arrays.equal(bs.toLongArray(), [1527]))
	}

	@Test_ValueOfBytes() {
		bs := new BitSet().valueOfByte([15, 27])
		this.assertTrue(Arrays.equal(bs.toByteArray(), [15, 27]))
	}

	@Test_Flip() {
		bs := new BitSet([102])
		bs.flip(0)
		this.assertEquals(bs.words[0], 103)
		bs.flip(1)
		this.assertEquals(bs.words[0], 101)
		bs.flip(1)
		this.assertEquals(bs.words[0], 103)
		this.assertException(bs, "Flip", "", "IndexOutOfBoundsException", -1)

		bs := new BitSet([102])
		bs.flipRange(0, 7)
		this.assertEquals(bs.words[0], 25)
	}

	@Test_Set() {
		bs := new BitSet([102])
		bs.set(0)
		this.assertEquals(bs.words[0], 103)
		bs.set(4)
		this.assertEquals(bs.words[0], 119)
		bs.set(1)
		this.assertEquals(bs.words[0], 119)
		this.assertException(bs, "Set", "", "IndexOutOfBoundsException", -1)

		bs := new BitSet([102])
		bs.setRange(2, 6)
		this.assertEquals(bs.words[0], 126)

		bs := new BitSet()
		bs.set(127)
		this.assertTrue(bs.get(127))
		this.assertEquals(bs.length(), 128)
	}

	@Test_Clear() {
		bs := new BitSet([102])
		bs.clear(1)
		this.assertEquals(bs.words[0], 100)
		bs.clear(6)
		this.assertEquals(bs.words[0], 36)
		bs.clear(3)
		this.assertEquals(bs.words[0], 36)
		this.assertException(bs, "Set", "", "IndexOutOfBoundsException", -1)

		bs := new BitSet([102])
		bs.clearRange(2, 6)
		this.assertEquals(bs.words[0], 66)

		bs.clear()
		this.assertEquals(bs.words[0], 0)
	}

	@Test_SetValue() {
		bs := new BitSet([102])
		bs.setValue(0, true)
		this.assertEquals(bs.words[0], 103)
		bs.setValue(0, false)
		this.assertEquals(bs.words[0], 102)
		this.assertException(bs, "Set", "", "IndexOutOfBoundsException", -1)
	}

	@Test_Get() {
		bs := new BitSet([102])
		this.assertEquals(bs.get(0), 0)
		this.assertEquals(bs.get(1), 1)
		this.assertEquals(bs.get(2), 1)
		this.assertEquals(bs.get(3), 0)
		this.assertEquals(bs.get(4), 0)
		this.assertEquals(bs.get(5), 1)
		this.assertEquals(bs.get(6), 1)
		this.assertEquals(bs.get(7), 0)
	}

	@Test_GetRange() {
		bs := new BitSet([102])
		bs2 := bs.getRange(1, 6)
		this.assertEquals(bs2.words[1], 19)
	}

	@Test_UseCase() {
		bits1 := new BitSet(16)
		bits2 := new BitSet(16)
		loop 16 {
			i := A_Index-1
			if (Mod(i, 2) = 0) {
				bits1.set(i)
			}
			if (Mod(i, 5) != 0) {
				bits2.set(i)
			}
		}
		this.assertEquals(bits1.toString(), "{0, 2, 4, 6, 8, 10, 12, 14}")
		this.assertEquals(bits2.toString()
				, "{1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14}")

		bits2.and(bits1)
		this.assertEquals(bits2.toString(), "{2, 4, 6, 8, 12, 14}")

		bits2.or(bits1)
		this.assertEquals(bits2.toString(), "{0, 2, 4, 6, 8, 10, 12, 14}")

		bits2.xor(bits1)
		this.assertEquals(bits2.toString(), "{}")

		bits2.set(1)
		bits2.andNot(bits1)
		this.assertEquals(bits2.toString(), "{1}")
	}
}

exitapp BitSetTest.runTests()
