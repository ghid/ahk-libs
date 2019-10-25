; ahk: console
#NoEnv
#Warn All, StdOut

#Include <ansi>
#Include <console>
#Include <datatable>
#Include <math>
#Include <object>
#Include <string>
#Include <testcase>

#Include %A_ScriptDir%\..\arrays.ahk

class ArraysTest extends TestCase {

	@Test_class() {
		this.assertTrue(IsObject(Arrays))
		this.assertException(Arrays, "__new")
		this.assertTrue(IsFunc(Arrays.equal))
		this.assertTrue(IsFunc(Arrays.intersection))
		this.assertTrue(IsFunc(Arrays.countOccurences))
		this.assertTrue(IsFunc(Arrays.keys))
		this.assertTrue(IsFunc(Arrays.values))
		this.assertTrue(IsFunc(Arrays.distinct))
		this.assertTrue(IsFunc(Arrays.removeValue))
		this.assertTrue(IsFunc(Arrays.shift))
		this.assertTrue(IsFunc(Arrays.append))
		this.assertTrue(IsFunc(Arrays.copyOf))
		this.assertTrue(IsFunc(Arrays.flatten))
		this.assertTrue(IsFunc(Arrays.forEach))
		this.assertTrue(IsFunc(Arrays.map))
		this.assertTrue(IsFunc(Arrays.reduce))
	}

	@Test_equal() {
		this.assertException(Arrays, "equal",,, 0, [])
		this.assertException(Arrays, "equal",,, [], 0)
		this.assertTrue(Arrays.equal([], []))
		this.assertTrue(Arrays.equal([0], [0]))
		this.assertFalse(Arrays.equal([0, 1], [0]))
		this.assertFalse(Arrays.equal([1], [2, 3]))
		this.assertFalse(Arrays.equal([0, 1], [1, 0]))
		this.assertTrue(Arrays.equal([3, 4], [3, 4]))
	}

	@Test_intersection() {
		this.assertException(Arrays, "intersection",,, 0, [])
		this.assertException(Arrays, "intersection",,, [], 0)
		this.assertTrue(Arrays.equal(Arrays.intersection([], []), []))
		this.assertTrue(IsObject(Arrays.intersection([1], [2])))
		this.assertTrue(Arrays.equal(Arrays.intersection([1,2,3,4], [3,4,5,6])
				, [3,3,4,4]))
		a1 := [1,2,3,4], a2 := [3,4,5,6]
		a3 := Arrays.intersection(a1, a2)
		this.assertTrue(Arrays.equal(a1, [1,2,3,4]))
		this.assertTrue(Arrays.equal(a2, [3,4,5,6]))
		this.assertTrue(Arrays.equal(a3, [3,3,4,4]))
		this.assertTrue(Arrays.equal(Arrays
				.intersection(["abc", "def", "ghi", "jkl"], ["abc", "mno"])
				, ["abc", "abc"]))
		this.assertTrue(Arrays.equal(Arrays.intersection([1,2,3,4], [5,6,7])
				, []))
		this.assertTrue(Arrays.equal(Arrays.intersection([2,2,3], [2,3,3])
				, [2,2,3,3]))
		this.assertTrue(Arrays.equal(Arrays
				.intersection([2,11,23,31,41], [2,3,7,41,601]), [2,2,41,41]))
		this.assertTrue(Arrays.equal(Arrays.intersection(["g", "h", "I"]
				, ["h", "i", "j"], String.COMPARE_AS_STRING)
				, ["h", "h", "I", "i"]))
	}

	@Test_union() {
		this.assertTrue(Arrays.equal(Arrays.union([], []), []))
		this.assertTrue(Arrays.equal(Arrays.union([1], [2]), [1,2]))
		this.assertTrue(Arrays.equal(Arrays.union([1,2,3,4], [3,4,5,6])
				, [1,2,3,3,4,4,5,6]))
		this.assertTrue(Arrays.equal(Arrays
				.union(["abc","def","ghi","jkl"], ["abc","mno"])
				, ["abc","abc","def","ghi","jkl","mno"]))
		this.assertTrue(Arrays.equal(Arrays.union([1,2,3,4], [5,6,7])
				, [1,2,3,4,5,6,7]))
		this.assertTrue(Arrays.equal(Arrays.union([2,2,3], [2,3,3])
				, [2,2,2,3,3,3]))
	}

	@Test_countOccurences() {
		this.assertException(Arrays, "countOccurences",,, 0, 1)
		this.assertEquals(Arrays.countOccurences([], ""), 0)
		this.assertEquals(Arrays.countOccurences([1], 1), 1)
		this.assertEquals(Arrays.countOccurences([1,1,1], 1), 3)
		this.assertEquals(Arrays
				.countOccurences([1,2,3,4,3,2,1,3,2,3,1,2,3,1,5,3], 1), 4)
		this.assertEquals(Arrays
				.countOccurences([1,2,3,4,3,2,1,3,2,3,1,2,3,1,5,3], 2), 4)
		this.assertEquals(Arrays
				.countOccurences([1,2,3,4,3,2,1,3,2,3,1,2,3,1,5,3], 3), 6)
		this.assertEquals(Arrays.countOccurences(["T", "e", "s", "t"], "t"), 2)
		this.assertEquals(Arrays
				.countOccurences(["T", "e", "s", "t"], "t", true), 1)
		this.assertEquals(Arrays
				.countOccurences(["T", "e", "s", "t"], "T", true), 1)
	}

	@Test_keys() {
		this.assertException(Arrays, "keys", "", "", "")
		this.assertTrue(Arrays.equal(Arrays.keys([0,3,6,9,12]), [1,2,3,4,5]))
		this.assertTrue(Arrays.equal(Arrays.keys({1: 3, 3: 6, 6: 9, 9: 12})
				, [1,3,6,9]))
	}

	@Test_values() {
		this.assertException(Arrays, "values", "", "", "")
		this.assertTrue(Arrays.equal(Arrays.values([0,3,6,9,12]), [0,3,6,9,12]))
		this.assertTrue(Arrays.equal(Arrays.values({1: 3, 3: 6, 6: 9, 9: 12})
				, [3,6,9,12]))
	}

	@Test_distinct() {
		this.assertException(Arrays, "distinct", "", "", "")
		this.assertTrue(Arrays.equal(Arrays
				.distinct([1,2,3,4,3,2,1,3,2,3,1,2,3,1,5,3]), [1,2,3,4,5]))
		this.assertTrue(Arrays.equal(Arrays
				.distinct([1,3,4,3,1,3,3,1,3,1,5,3]), [1,3,4,5]))
	}

	@Test_removeValue() {
		this.assertException(Arrays, "removeValue", "", "", "")
		a := [1,2,3,4,3,2,1,3,2,3,1,2,3,1,5,3]
		this.assertEquals(Arrays.removeValue(a, 2), 4)
		this.assertTrue(Arrays.equal(a, [1,3,4,3,1,3,3,1,3,1,5,3]))
		this.assertEquals(Arrays.removeValue([2,3,3], 3), 2)
		this.assertEquals(Arrays.removeValue([2,3,3,1,3,1], 3), 3)
	}

	@Test_shift() {
		this.assertEquals(Arrays.shift([1,3,0,3]), 1)
		this.assertTrue(Arrays.equal(Arrays.shift([1,3,0,3], 0), [1]))
		this.assertEquals(Arrays.shift([1,3,0,3], 1), 1)
		this.assertTrue(Arrays.equal(Arrays.shift([1,3,0,3], 2), [1,3]))
		this.assertTrue(Arrays.equal(Arrays.shift([1,3,0,3], 3), [1,3,0]))
		this.assertTrue(Arrays.equal(Arrays.shift([1,3,0,3], 4), [1,3,0,3]))
		a := [1,2,3,4,3,2,1,3,2,3,1,2,3,1,5,3]
		this.assertEquals(Arrays.shift(a), 1)
		this.assertEquals(Arrays.shift(a), 2)
		this.assertEquals(Arrays.shift(a), 3)
		this.assertTrue(Arrays.equal(Arrays.shift(a, false), [4]))
		this.assertTrue(Arrays.equal(Arrays.shift(a, 2), [3,2]))
		this.assertTrue(Arrays.equal(Arrays.shift(a, 5), [1,3,2,3,1]))
		this.assertTrue(Arrays.equal(a, [2,3,1,5,3]))
		a := ["a", "b"]
		this.assertEquals(Arrays.shift(a), "a")
		this.assertEquals(Arrays.shift(a), "b")
		this.assertEquals(Arrays.equal(Arrays.shift([1,3,0,3], 99), [1,3,0,3]))
	}

	@Test_append() {
		a := ["Mo", "Di", "Mi", "Do", "Fr"]
		this.assertEquals(Arrays.append(a, ["Sa", "So"]), 7)
		this.assertTrue(Arrays.equal(a
				, ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]))
	}

	@Test_wrap() {
		this.assertEquals(Arrays.wrap(["this is a test", "this is another test"]
				, 10), "this is a`ntest`nthis is`nanother`ntest`n")
		this.assertEquals(Arrays.wrap(["term can have one of the following values", ". a - means A", ". b - represents a very long description which has to be wrapped at the end of the line"], 60, "     ", "--]", true), "--]term can have one of the following values`n     . a - means A`n     . b - represents a very long description which has to be`n     wrapped at the end of the line`n") ; ahklint-ignore: W002
		this.assertEquals(Arrays.wrap(["term can have one of the following values", ". a - means A", ". b - represents a very long description which has to be wrapped at the end of the line"], 60, "     ", "--]", false), "--]     term can have one of the following values`n     . a - means A`n     . b - represents a very long description which has to be`n     wrapped at the end of the line`n") ; ahklint-ignore: W002
	}

	@Test_toString() {
		this.assertEquals(Arrays.toString(["abc", "def", "ghi"])
				, "abc def ghi")
		this.assertEquals(Arrays.toString(["abc", "def", "ghi"], ", ")
				, "abc, def, ghi")
		this.assertEquals(Arrays.toString(["abc", ["def", "ghi"]], ", ")
				, "abc, def, ghi")
		this.assertEquals(Arrays.toString([]), "")
	}

	@Test_index() {
		a := Arrays.index({1: "a", 2: "b", 3: "c"})
		this.assertEquals(a["a"], 1)
		this.assertEquals(a["b"], 2)
		this.assertEquals(a["c"], 3)
		a := Arrays.index({1: "a", 2: "b", 3: "c", 4: "b"})
		this.assertEquals(a["a"], 1)
		this.assertTrue(Arrays.equal(a["b"], [2, 4]))
		this.assertEquals(a["c"], 3)
		a := Arrays.index({"a": "x", "b": "y", "c": "z", "d": "x"})
		this.assertTrue(Arrays.equal(a["x"], ["a", "d"]))
		this.assertEquals(a["y"], "b")
		this.assertEquals(a["z"], "c")
	}

	@Test_copyOf() {
		a := [0, 1, 2, 3]
		b := Arrays.copyOf(a, 4)
		this.assertTrue(Arrays.equal(a, b))
		b := Arrays.copyOf(a, 3)
		this.assertTrue(Arrays.equal(b, [0, 1, 2]))
		b := Arrays.copyOf(a, 6)
		this.assertTrue(Arrays.equal(b, [0, 1, 2, 3, 0, 0]))
		b := Arrays.copyOf(a, 6, -1)
		this.assertTrue(Arrays.equal(b, [0, 1, 2, 3, -1, -1]))
		b := Arrays.copyOf(a, 0)
		this.assertTrue(Arrays.equal(b, []))
	}

	@Test_flatten() {
		a := [1, [2, 3, [4, 5], 6, 7, 8], 9, 10]
		f := Arrays.flatten(a)
		this.assertEquals(f.minIndex(), 1)
		this.assertEquals(f.maxIndex(), 10)
		this.assertEquals(f[1], 1)
		this.assertEquals(f[2], 2)
		this.assertEquals(f[3], 3)
		this.assertEquals(f[4], 4)
		this.assertEquals(f[5], 5)
		this.assertEquals(f[6], 6)
		this.assertEquals(f[7], 7)
		this.assertEquals(f[8], 8)
		this.assertEquals(f[9], 9)
		this.assertEquals(f[10], 10)
	}

	@Test_unionWithSource() {
		Arrays.VennData.printSource := true
		this.assertTrue(Arrays.equal(Arrays
				.union(["abc","def","ghi","jkl"], ["abc","mno"])
				, ["(A) abc","(B) abc","(A) def"
				,"(A) ghi","(A) jkl","(B) mno"]))
		this.assertTrue(Arrays.equal(Arrays.union([1,2,3,4], [3,4,5,6])
				, ["(A) 1","(A) 2","(A) 3","(B) 3"
				,"(A) 4","(B) 4","(B) 5","(B) 6"]))
	}

	@Test_map() {
		invoice := { customer: "BigCo"
				, performances: [ { playID: "hamlet" }
				, { playID: "othello" } ] }

		this.assertException(Arrays, "map",,, 0, "enrich")
		this.assertException(Arrays, "map",,, invoice.performances
				, "aMissingFunction")

		result := Arrays.map(invoice.performances, Func("enrich"))
		this.assertEquals(result.count(), 2)
		this.assertEquals(result[1].playID, "hamlet")
		this.assertEquals(result[1].play, "Test")
		this.assertEquals(result[1].amount, 42)
		this.assertEquals(result[2].playID, "othello")
		this.assertEquals(result[2].play, "Test")
		this.assertEquals(result[2].amount, 42)

		result := Arrays.map(["a", "b"], Func("enrich"))
		this.assertEquals(result.count(), 2)
		this.assertEquals(result[1, 1], "a")
		this.assertEquals(result[1].play, "Test")
		this.assertEquals(result[1].amount, 42)
		this.assertEquals(result[2, 1], "b")
		this.assertEquals(result[2].play, "Test")
		this.assertEquals(result[2].amount, 42)

		result := Arrays.map([], "enrich")
		this.assertEquals(result.count(), 0)
	}

	@Test_isArray() {
		this.assertException(Arrays, "isArray",,, 0)
	}

	@Test_isCallbackFunction() {
		this.assertException(Arrays, "isCallbackFunction",,, "aMissingFunction")
	}

	@Test_reduce() {
		this.assertException(Arrays, "reduce",,, 0, "sum", 0)
		this.assertException(Arrays, "reduce",,, [], "aMissingFunction", 0)
		this.assertEquals(Arrays.reduce([1,2,3,4], Func("sum"), 5), 15)
		this.assertEquals(Arrays.reduce([1,2,3,4], Func("mult"), 5), 120)
		this.assertEquals(Arrays.reduce(["T", "e", "s", "t"]
				, Func("ArraysTest.enumeration").bind(ArraysTest), "A")
				, "A;T;e;s;t")
		this.assertEquals(Arrays.reduce(["T", "e", "s", "t"]
				, ArraysTest.enumeration.bind(ArraysTest), "A")
				, "A;T;e;s;t")
		this.assertEquals(Arrays.reduce(["T", "e", "s", "t"], Func("cat"), "A ")
				, "A Test")
		this.assertEquals(Arrays.reduce([15, 12, 10, 14], Func("Min"), +9999)
				, 10)
		this.assertEquals(Arrays.reduce([15, 12, 10, 14], Func("Max"), -9999)
				, 15)
	}

	enumeration(accumulator, element) {
		return accumulator ";" element
	}

	@Test_forEach() {
		this.assertException(Arrays, "forEach",,, 0, "copyItems")
		this.assertException(Arrays, "forEach",,, [], "aMissingFunction")
		items := ["item1", "item2", "item3"]
		copy := []
		Arrays.forEach(items, ArraysTest.copyItems.bind(ArraysTest, copy))
		this.assertEquals(copy.count(), 3)
		this.assertEquals(copy[1], items[1])
		this.assertEquals(copy[2], items[2])
		this.assertEquals(copy[3], items[3])
		; Just to demonstrate another use-case:
		Arrays.forEach(copy, ArraysTest.logItems.bind(ArraysTest))
	}

	copyItems(copy, item) {
		copy.push(item)
	}

	logItems(item, index) {
		OutputDebug % "`n" index ": " item
	}

	@Test_filter() {
		this.assertException(Arrays, "filter",,, 0, "findLongWords")
		this.assertException(Arrays, "filter",,, [], "aMissingFunction")
		words := ["spray", "limit", "elite", "exubertant", "destruction", "present"] ; ahklint-ignore: W002
		this.assertTrue(Arrays.equal(Arrays.filter(words
				, ArraysTest.findLongWords.bind(ArraysTest))
				, ["exubertant", "destruction", "present"]))
	}

	findLongWords(word) {
		return StrLen(word) > 6
	}
}

enrich(anArray) {
	result := anArray.clone()
	result.play := "Test"
	result.amount := 42
	return result
}

sum(accumulator, element) {
	return accumulator + element
}

mult(accumulator, element) {
	return accumulator * element
}

cat(accumulator, element) {
	return accumulator . element
}

exitapp ArraysTest.runTests()
