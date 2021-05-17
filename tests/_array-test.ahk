;@Ahk2Exe-ConsoleApp

#Include <testcase-libs>
#Include %ScriptDir%\..\_array.ahk

class _arrayTest extends TestCase {

    requires() {
        return [TestCase, _Array.Quicksort]
    }

    @Test__Array() {
        TestCase.assertTrue(IsFunc("_Array.of"))
        TestCase.assertTrue(IsFunc("_Array.equals"))
        TestCase.assertTrue(IsFunc("_Array.concat"))
        TestCase.assertTrue(IsFunc("_Array.copyWithin"))
        TestCase.assertTrue(IsFunc("_Array.every"))
        TestCase.assertTrue(IsFunc("_Array.fill"))
        TestCase.assertTrue(IsFunc("_Array.filter"))
        TestCase.assertTrue(IsFunc("_Array.find"))
        TestCase.assertTrue(IsFunc("_Array.findIndex"))
        TestCase.assertTrue(IsFunc("_Array.flat"))
        TestCase.assertTrue(IsFunc("_Array.flatMap"))
        TestCase.assertTrue(IsFunc("_Array.forEach"))
        TestCase.assertTrue(IsFunc("_Array.from"))
        TestCase.assertTrue(IsFunc("_Array.includes"))
        TestCase.assertTrue(IsFunc("_Array.indexOf"))
        TestCase.assertTrue(IsFunc("_Array.join"))
        TestCase.assertTrue(IsFunc("_Array.lastIndexOf"))
        TestCase.assertTrue(IsFunc("_Array.map"))
        TestCase.assertTrue(IsFunc("_Array.reduce"))
        TestCase.assertTrue(IsFunc("_Array.reduceRight"))
        TestCase.assertTrue(IsFunc("_Array.reverse"))
        TestCase.assertTrue(IsFunc("_Array.slice"))
        TestCase.assertTrue(IsFunc("_Array.some"))
        TestCase.assertTrue(IsFunc("_Array.sort"))
        TestCase.assertTrue(IsFunc("_Array.splice"))
        TestCase.assertTrue(IsFunc("_Array.spread"))
        TestCase.assertTrue(IsFunc("_Array.toString"))
        TestCase.assertTrue(IsFunc("_Array.unshift"))
        TestCase.assertTrue(IsFunc("_Array.Quicksort.sort"))
    }

    @Test_equals() {
        TestCase.assertFalse([].equals(""))
        TestCase.assertTrue([].equals([]))
        TestCase.assertFalse([1,2].equals([1,2,3]))
        TestCase.assertTrue([1,2,3].equals([1,2,3]))
        TestCase.assertFalse([1,2,3].equals([1,3,5]))
        TestCase.assertTrue([1,2,["a","b"],3].equals([1,2,["a","b"],3]))
        TestCase.assertTrue([1,2,["a","b", [42]],3]
                .equals([1,2,["a","b", [42]],3]))
        TestCase.assertFalse([1,2,["a","b", [42]],3]
                .equals([1,2,["a","b", [43]],3]))
        TestCase.assertFalse([1,2,["a","b"],3].equals([1,2,[],3]))
    }

    @Test_new() {
        TestCase.assertTrue(new _Array(3).equals(["", "", ""]))
    }

    @Test_of() {
        TestCase.assertTrue(_Array.of(3).equals([3]))
        TestCase.assertTrue(_Array.of(3,4).equals([3,4]))
    }

    @Test_concat() {
        TestCase.assertTrue(["a","b","c"].concat([1,2,3])
                .equals(["a","b","c",1,2,3]))
        TestCase.assertTrue([1,2,3].concat([4,5,6],[7,8,9])
                .equals([1,2,3,4,5,6,7,8,9]))
        TestCase.assertTrue(["a","b","c"].concat(1,[2,3])
                .equals(["a","b","c",1,2,3]))
        TestCase.assertTrue([[1]].concat([2,[3]]).equals([[1],2,[3]]))
    }

    @Test_copyWithin() {
        array1 := ["a", "b", "c", "d", "e"]
        TestCase.assertTrue(array1.copyWithin(1, 4, 5)
                .equals(["d","b","c","d","e"]))
        TestCase.assertTrue(array1.copyWithin(2, 4)
                .equals(["d","d","e","d","e"]))
        TestCase.assertTrue([1,2,3,4,5].copyWithin(1).equals([1,2,3,4,5]))
        TestCase.assertTrue([1,2,3,4,5].copyWithin(1,1,6).equals([1,2,3,4,5]))
        TestCase.assertTrue([1,2,3,4,5].copyWithin(4,1).equals([1,2,3,1,2]))
        TestCase.assertTrue([1,2,3,4,5].copyWithin(-2).equals([1,2,3,1,2]))
        TestCase.assertTrue([1,2,3,4,5].copyWithin(1,4).equals([4,5,3,4,5]))
        TestCase.assertTrue([1,2,3,4,5].copyWithin(4,3,5).equals([1,2,3,3,4]))
        TestCase.assertTrue([1,2,3,4,5].copyWithin(-2,-3,-1)
                .equals([1,2,3,3,4]))
    }

    @Test_every() {
        TestCase.assertTrue([1,30,39,29,10,13]
                .every(_arrayTest.isBelowThreshold.bind(_arrayTest)))
        TestCase.assertFalse([12,5,8,130,44].every(Func("isBigEnough")))
        TestCase.assertTrue([12,54,18,130,44].every(Func("isBigEnough")))
    }
    isBelowThreshold(currentValue) {
        return currentValue < 40
    }

    @Test_fill() {
        TestCase.assertTrue([1,2,3].fill(4).equals([4,4,4]))
        TestCase.assertTrue([1,2,3].fill(4,2).equals([1,4,4]))
        TestCase.assertTrue([1,2,3].fill(4,2,3).equals([1,4,3]))
        TestCase.assertTrue([1,2,3].fill(4,2,4).equals([1,4,4]))
        TestCase.assertTrue([1,2,3].fill(4,-3,-2).equals([4,2,3]))
        TestCase.assertTrue([1,2,3].fill(4,2,99).equals([1,4,4]))
        table := new _Array(4).fill(0)
        TestCase.assertTrue(table.equals([0,0,0,0]))
    }

    @Test_filter() {
        TestCase.assertTrue([12,5,8,130,44].filter(Func("isBigEnough"))
                .equals([12,130,44]))
        fruits := ["Apple","Banana","Grapes","Mango","Orange"]
        TestCase.assertTrue(fruits
                .filter(_arrayTest.filterItems.bind(this, "ap"))
                .equals(["Apple","Grapes"]))
        TestCase.assertTrue(fruits
                .filter(Func("filterItemsFunc").bind("an"))
                .equals(["Banana","Mango","Orange"]))
    }
    filterItems(query, value) {
        return InStr(value, query) > 0
    }

    @Test_find() {
        TestCase.assertTrue([5,12,8,130,44].find(Func("isBigEnough"))
                .equals(12))
        inventory := [ {name: "Apples", quantity: 2}
                , {name: "Bananas", quantity: 0}
                , {name: "Cherries", quantity: 5} ]
        TestCase.assertEquals(inventory
                .find(_arrayTest.isCherries.bind(this)).quantity, 5)
    }
    isCherries(fruit) {
        return fruit.name == "Cherries"
    }

    @Test_findIndex() {
        TestCase.assertTrue([5,12,8,130,44].findIndex(Func("isBigEnough"))
                .equals(2))
        TestCase.assertTrue([5,2,8,3,4].findIndex(Func("isBigEnough"))
                .equals(0))
    }

    @Test_flat() {
        arr1 := [1,2,[3,4]]
        arr1 := arr1.flat()
        this.assertTrue(arr1.equals([1,2,3,4]))
        arr1 := [1,2,[3,4]]
        this.assertTrue(arr1.flat(1).equals([1,2,3,4]))
        arr2 := [1,2,3,[1,2,3,4,[2,[1,2],3,4]]]
        this.assertTrue(arr2.flat(4).equals([1,2,3,1,2,3,4,2,1,2,3,4]))
        arr2 := [1,2,3,[1,2,3,4,[2,[1,2],3,4]]]
        this.assertTrue(arr2.flat(1).equals([1,2,3,1,2,3,4,[2,[1,2],3,4]]))
        arr3 := [1,2,[3,4,[5,6]]]
        this.assertTrue(arr3.flat(1).equals([1,2,3,4,[5,6]]))
    }

    @Test_flatMap() {
        arr1 := [1,2,3,4]
        TestCase.assertTrue(arr1.flatMap(Func("doubleIt")).equals([2,4,6,8]))
    }

    @Test_forEach() {
        items := ["item1", "item2", "item3"]
        copy := []
        items.forEach(_arrayTest.copyItems.bind(_arrayTest, copy))
        TestCase.assertTrue(copy.equals(items))
        items.forEach(_arrayTest.toUpper.bind(_arrayTest))
        testCase.assertTrue(items.equals(["ITEM1", "ITEM2", "ITEM3"]))
    }
    copyItems(copy, item) {
        copy.push(item)
    }
    toUpper(item, i, theArray) {
       theArray[i] := Format("{:U}", item)
    }

    @Test_from() {
        ascii := ["f","o","o"].from(Func("Asc"))
        TestCase.assertTrue(ascii.equals([102,111,111]))
        TestCase.assertTrue(ascii.from(Func("Chr")).equals(["F","o","o"]))
    }

    @Test_includes() {
        TestCase.assertTrue([1,2,3].includes(2))
        TestCase.assertFalse([1,2,3].includes(4))
        TestCase.assertFalse([1,2,3].includes(3,4))
        TestCase.assertTrue([1,2,3].includes(3,0))
        TestCase.assertTrue([1,2,3].includes(2,-1))
        TestCase.assertTrue([1,2,""].includes(""))
        TestCase.assertFalse(["a","b","c"].includes("c", 4))
        TestCase.assertFalse(["a","b","c"].includes("c", 100))
        TestCase.assertTrue(["a","b","c"].includes("a", -100))
        TestCase.assertTrue(["a","b","c"].includes("c", -100))
    }

    @Test_indexOf() {
        TestCase.assertEquals(["ant", "bison", "camel", "duck", "bison"]
                .indexOf("bison"), 2)
        TestCase.assertEquals(["ant", "bison", "camel", "duck", "bison"]
                .indexOf("giraffe"), 0)
        TestCase.assertEquals(["ant", "bison", "camel", "duck", "bison"]
                .indexOf("bison", 2), 2)
        TestCase.assertEquals(["ant", "bison", "camel", "duck", "bison"]
                .indexOf("bison", 3), 5)
        TestCase.assertEquals(["ant", "bison", "camel", "duck", "bison"]
                .indexOf("bison", 0), 5)
        TestCase.assertEquals(["ant", "bison", "camel", "duck", "bison"]
                .indexOf("bison", -3), 2)
        TestCase.assertEquals(["ant", "bison", "camel", "duck", "bison"]
                .indexOf("bison", 100), 0)
    }

    @Test_join() {
        TestCase.assertEquals([].join(), "")
        TestCase.assertEquals(["Fire","Air","Water"].join(), "Fire,Air,Water")
        TestCase.assertEquals(["Fire","Air","Water"].join("-")
                , "Fire-Air-Water")
        TestCase.assertEquals(["Fire","Air","Water"].join(" + ")
                , "Fire + Air + Water")
        TestCase.assertEquals(["Fire","Air","Water"].join(""), "FireAirWater")
        TestCase.assertEquals(["Fire","Air",["Earth",["Rain","Wind"]],"Water"]
                .join(), "Fire,Air,Earth,Rain,Wind,Water")
        TestCase.assertEquals(["Fire","Air",["Earth",["Rain","Wind"]],"Water"]
                .join("-"), "Fire-Air-Earth,Rain,Wind-Water")
    }

    @Test_lastIndexOf() {
        TestCase.assertEquals([].lastIndexOf(1), 0)
        TestCase.assertEquals(["Dodo","Tiger","Penguin","Dodo"]
                .lastIndexOf("Dodo"), 4)
        TestCase.assertEquals(["Dodo","Tiger","Penguin","Dodo"]
                .lastIndexOf("Dodo", -5), 0)
        numbers := [2,5,9,2]
        TestCase.assertEquals(numbers.lastIndexOf(2), 4)
        TestCase.assertEquals(numbers.lastIndexOf(7), 0)
        TestCase.assertEquals(numbers.lastIndexOf(2, 4), 4)
        TestCase.assertEquals(numbers.lastIndexOf(2, 3), 1)
        TestCase.assertEquals(numbers.lastIndexOf(2, -2), 1)
        TestCase.assertEquals(numbers.lastIndexOf(2, 0), 4)
        TestCase.assertEquals(numbers.lastIndexOf(2, -100), 0)
    }

    @Test_map() {
        TestCase.assertTrue([1,4,9].map(Func("Sqrt")).equals([1,2,3]))

        invoice := { customer: "BigCo"
                , performances: [ { playID: "hamlet" }
                , { playID: "othello" } ] }
        result := invoice.performances.map(Func("enrich"))
        TestCase.assertEquals(result.count(), 2)
        TestCase.assertEquals(result[1].playID, "hamlet")
        TestCase.assertEquals(result[1].play, "Test")
        TestCase.assertEquals(result[1].amount, 42)
        TestCase.assertEquals(result[2].playID, "othello")
        TestCase.assertEquals(result[2].play, "Test")
        TestCase.assertEquals(result[2].amount, 42)

        result := ["a", "b"].map(Func("enrich"))
        TestCase.assertEquals(result.count(), 2)
        TestCase.assertEquals(result[1, 1], "a")
        TestCase.assertEquals(result[1].play, "Test")
        TestCase.assertEquals(result[1].amount, 42)
        TestCase.assertEquals(result[2, 1], "b")
        TestCase.assertEquals(result[2].play, "Test")
        TestCase.assertEquals(result[2].amount, 42)

        kvArray := [{key: 1, value: 10}
                , {key: 2, value: 20}
                , {key: 3, value:30 }]
        rfArray := kvArray.map(Func("reformattedArray"))
        TestCase.assertEquals(rfArray[1,1], 10)
        TestCase.assertEquals(rfArray[2,2], 20)
        TestCase.assertEquals(rfArray[3,3], 30)

        arr1 := [1,2,3,4]
        TestCase.assertTrue(arr1.map(Func("doubleIt"))
                .equals([[2],[4],[6],[8]]))
    }

    @Test_reduce() {
        TestCase.assertEquals([1,2,3,4].reduce(Func("reducer"), 0), 10)
        TestCase.assertEquals([{x:1},{x:2},{x:3}]
                .reduce(_arrayTest.reducerX.bind(this), 0), 6)
        TestCase.assertTrue([[0,1],[2,3],[4,5]]
                .reduce(_arrayTest.flattend.bind(this), [])
                .equals([0,1,2,3,4,5]))
        names := ["Alice","Bob","Tiff","Bruce","Alice"]
        countedNames := names.reduce(_arrayTest.countNames.bind(this), {})
        TestCase.assertEquals(countedNames.Alice, 2)
        TestCase.assertEquals(countedNames.Bob, 1)
        TestCase.assertEquals(countedNames.Tiff, 1)
        TestCase.assertEquals(countedNames.Bruce, 1)
        people := [{name:"Alice",age:21},{name:"Max",age:20},{name:"Jane",age:20}] ; ahklint-ignore: W002
        groupedPeople := people.reduce(_arrayTest.groupBy.bind(this, "age"), {})
        TestCase.assertEquals(groupedPeople[20][1].name, "Max")
        TestCase.assertEquals(groupedPeople[20][1].age, 20)
        TestCase.assertEquals(groupedPeople[20][2].name, "Jane")
        TestCase.assertEquals(groupedPeople[20][2].age, 20)
        TestCase.assertEquals(groupedPeople[21][1].name, "Alice")
        TestCase.assertEquals(groupedPeople[21][1].age, 21)
    }
    reducerX(accumulator, currentValue) {
        return accumulator + currentValue.x
    }
    flattend(flatArray, currentValue) {
        return flatArray.concat(currentValue)
    }
    countNames(allNames, name) {
        if (allNames[name] != "") {
            allNames[name]++
        } else {
            allNames[name] := 1
        }
        return allNames
    }
    groupBy(property, acc, obj) {
        key := obj[property]
        if (!acc.hasKey(key)) {
            acc[key] := []
        }
        (acc[key]).push(obj)
        return acc
    }

    @Test_reduceRight() {
        TestCase.assertTrue([[0,1],[2,3],[4,5]]
                .reduceRight(_arrayTest.concat.bind(this), [])
                .equals([4,5,2,3,0,1]))
        TestCase.assertTrue(["a","b","","d","e"]
                .reduceRight(_arrayTest.concat.bind(this), [])
                .equals(["e","d","","b","a"]))
    }
    concat(acc, value) {
        return acc.concat(value)
    }

    @Test_reverse() {
        TestCase.assertTrue([1,2,3].reverse().equals([3,2,1]))
        TestCase.assertTrue(["one","two","three"].reverse()
                .equals(["three","two","one"]))
        TestCase.assertTrue(["one","two","","three"].reverse()
                .equals(["three","","two","one"]))
    }

    @Test_shift() {
        myFish := ["angel","clown","mandarin","surgeon"]
        TestCase.assertEquals(myFish.shift(), "angel")
        TestCase.assertEquals(myFish.shift(), "clown")
        TestCase.assertEquals(myFish.shift(), "mandarin")
        TestCase.assertEquals(myFish.shift(), "surgeon")
        TestCase.assertEquals(myFish.shift(), "")
    }

    @Test_slice() {
        animals := ["ant","bison","camel","duck","elephant"]
        TestCase.assertTrue(animals.slice(3)
                .equals(["camel","duck","elephant"]))
        TestCase.assertTrue(animals.slice(3, 5).equals(["camel","duck"]))
        TestCase.assertTrue(animals.slice(2, 6)
                .equals(["bison","camel","duck","elephant"]))
        TestCase.assertTrue(animals.slice(-2).equals(["duck","elephant"]))
        TestCase.assertTrue(animals.slice(,2).equals(["ant"]))
        TestCase.assertTrue(animals.slice(,3).equals(["ant","bison"]))
        TestCase.assertTrue(animals.slice(99).equals([]))
        TestCase.assertTrue(animals.slice(-99).equals(animals))
        TestCase.assertTrue(animals.slice(3,-1).equals(["camel","duck"]))
        TestCase.assertTrue(animals.slice(-1,0).equals(["elephant"]))
        TestCase.assertTrue(animals.slice(3,99)
                .equals(["camel","duck","elephant"]))
        TestCase.assertTrue([].slice().equals([]))
    }

    @Test_some() {
        TestCase.assertFalse([2,5,8,1,4].some(Func("isBigEnough")))
        TestCase.assertTrue([12,5,8,1,4].some(Func("isBigEnough")))
    }

    @Test_sort() {
        months := ["Mar", "Jan", "Feb", "Dec"]
        this.assertFalse(months.sort().equals(["Dec", "Feb", "Jan", "Xxx"]))
        this.assertTrue(months.sort().equals(["Dec", "Feb", "Jan", "Mar"]))
        array1 := [1, 30, 4, 21, 100000]
        this.assertTrue(array1.sort().equals([1, 100000, 21, 30, 4]))
        this.assertTrue(months.sort(_arrayTest.sortDescending.bind(_arrayTest))
                .equals(["Mar", "Jan", "Feb", "Dec"]))
        months := ["Mar", "Jan", "Feb", "Dec"]
        this.assertTrue(months
                .sort(_arrayTest.sortDescending.bind(_arrayTest)*-1)
                .equals(["Dec", "Feb", "Jan", "Mar"]))
        this.assertTrue(array1.sort(_arrayTest.sortDescending.bind(_arrayTest))
                .equals([4, 30, 21, 100000, 1]))
        this.assertTrue(array1.sort(_arrayTest.compareNumbers.bind(_arrayTest))
                .equals([1, 4, 21, 30, 100000]))
    }
	sortDescending(firstElement, secondElement) {
		return _Array.Quicksort.compareStrings(firstElement, secondElement)*-1
	}
	compareNumbers(firstElement, secondElement) {
		return firstElement - secondElement
	}

    @Test_splice() {
        month := ["Jan","Mar","Apr","Jun"]
        TestCase.assertTrue(month.splice(2, 0, "Feb").equals([]))
        TestCase.assertTrue(month.equals(["Jan","Feb","Mar","Apr","Jun"]))
        TestCase.assertTrue(month.splice(5, 1, "May").equals(["Jun"]))
        TestCase.assertTrue(month.equals(["Jan","Feb","Mar","Apr","May"]))
        myFish := ["angel","clown","trumpet","sturgeon"]
        TestCase.assertTrue(myFish.splice(1, 2, "parrot","anemone","blue")
                .equals(["angel","clown"]))
        TestCase.assertTrue(myFish
                .equals(["parrot","anemone","blue","trumpet","sturgeon"]))
        myFish := ["angel","clown","mandarin","sturgeon"]
        TestCase.assertTrue(myFish.splice(-1,1).equals(["mandarin"]))
        TestCase.assertTrue(myFish.equals(["angel","clown","sturgeon"]))
        myFish := ["angel","clown","mandarin","sturgeon"]
        TestCase.assertTrue(myFish.splice(3).equals(["mandarin","sturgeon"]))
        TestCase.assertTrue(myFish.equals(["angel","clown"]))
    }

    @Test_spread() {
        numbers := [1,2,3]
        TestCase.assertTrue(numbers.spread(4).equals([1,2,3,4]))
        TestCase.assertTrue(numbers.spread(4,5).equals([1,2,3,4,5]))
    }

    @Test_toString() {
        this.assertEquals([1,2,"a",["b","1b"],"1a"].toString(), "1,2,a,b,1b,1a")
    }

    @Test_unshift() {
        array1 := [1,2,3]
        this.assertEquals(array1.unshift(4,5), 5)
        this.assertTrue(array1.equals([4,5,1,2,3]))
        arr := [1,2]
        this.assertEquals(arr.unshift(0), 3)
        this.assertTrue(arr.equals([0,1,2]))
        this.assertEquals(arr.unshift(-2,-1), 5)
        this.assertTrue(arr.equals([-2,-1,0,1,2]))
        this.assertEquals(arr.unshift([-3,-4]), 6)
        this.assertTrue(arr.equals([[-3,-4],-2,-1,0,1,2]))
    }

    @Test_init2DArray() {
        table := new _Array(4).fill().map(_arrayTest.zeroInit.bind(this, 3))
        this.assertTrue(table.equals([[0, 0, 0],[0, 0, 0],[0, 0, 0],[0, 0, 0]]))
        table[1,1] := 1
        this.assertTrue(table.equals([[1, 0, 0],[0, 0, 0],[0, 0, 0],[0, 0, 0]]))
    }
    zeroInit(noOfElements) {
        return new _Array(noOfElements).fill(0)
    }
}

isBigEnough(element) {
    return element >= 10
}

doubleIt(value) {
    return [value * 2]
}

enrich(currentValue) {
    if (currentValue.count() != "") {
        result := currentValue.clone()
    } else {
        result := []
        result.push(currentValue)
    }
    result.play := "Test"
    result.amount := 42
    return result
}

reducer(accumulator, currentValue) {
    return accumulator + currentValue
}

reformattedArray(obj) {
    rObj := {}
    rObj[obj.key] := obj.value
    return rObj
}

filterItemsFunc(query, value) {
    return InStr(value, query) > 0
}

exitapp _arrayTest.runTests()
