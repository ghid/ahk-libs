; ahk: console

#Include <testcase-libs>
#Include <system>
#Include %ScriptDir%\..\geo.ahk

class GeoTest extends TestCase {

	requires() {
		return [TestCase, Geo]
	}

	@Test_new() {
		c := new Geo()
		this.assertEquals(c.longitude, 0)
		this.assertEquals(c.latitude, 0)
		this.assertEquals(c.elevation, 0)
		c2 := new Geo(1.23, 3.45, 6.789)
		this.assertEquals(c2.longitude, 1.23)
		this.assertEquals(c2.latitude, 3.45)
		this.assertEquals(c2.elevation, 6.789)
	}

	@Test_parse() {
		this.assertException(Geo, "parse",,, "51°01'45""")
		c := new Geo().parse("51°01'45""N").parse("08°40'38""E 270m")
		this.assertEquals(c.longitude, 8.677222)
		this.assertEquals(c.latitude, 51.029167)
		this.assertEquals(c.elevation, 270.0)
	}

	@Test_toDecimal() {
		this.assertEquals(Geo.toDecimal(0, 0, 0, "N"), 0.0)
		this.assertEquals(Geo.toDecimal(0, 0, 0, "S"), 0.0)
		this.assertEquals(Geo.toDecimal(46, 14, 6.70, "N"), 46.235194)
		this.assertEquals(Geo.toDecimal(46, 14.11182, 0, "N"), 46.235197)
		this.assertEquals(Geo.toDecimal(8, 0, 55.60, "E"), 8.015444)
		this.assertEquals(Geo.toDecimal(8, 0.92670, 0, "O"), 8.015445)
		this.assertEquals(Geo.toDecimal(46, 14, 6.70, "S"), -46.235194)
		this.assertEquals(Geo.toDecimal(8, 0, 55.60, "W"), -8.015444)
	}

	@Test_toGMS() {
		lon := Geo.toDecimal(8, 40, 38, "O")
		lat := Geo.toDecimal(51, 1, 45, "N")
		x := new Geo(lon, lat, 270)
		this.assertEquals(x.toGMS(), "51°01'45""N 08°40'38""E 270m")
		this.assertEquals(x.toGMS(1), "51°01'45.0""N 08°40'38.0""E 270.0m")
		this.assertEquals(x.toGMS(0, 2), "51°01'45""N 08°40'38""E 270.00m")
	}
}

exitapp GeoTest.runTests()
