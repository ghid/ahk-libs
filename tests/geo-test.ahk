; ahk: console

#Include <testcase-libs>
#Include <system>
#Include %A_ScriptDir%\..\geo.ahk

class GeoTest extends TestCase {

	requires() {
		return [TestCase, Geo]
	}

	@Test_Datum() {
		d := new Geo.Datum(Geo.VERTICAL, 46.235194)
		this.assertEquals(d.decimalDegrees, 46.235194)
		this.assertEquals(d.getDegrees(), 46)
		this.assertEquals(d.getMinutes(), 14)
		this.assertEquals(d.getSeconds(), 6.698400)
		this.assertEquals(d.getCardinalPoint(), "E")
	}

	@Test_cardinalPoint() {
		this.assertEquals(new Geo.Datum(GEO.VERTICAL, 1)
				.getCardinalPoint(), "E")
		this.assertEquals(new Geo.Datum(GEO.VERTICAL, -1)
				.getCardinalPoint(), "W")
		this.assertEquals(new Geo.Datum(GEO.HORIZONTAL, 1)
				.getCardinalPoint(), "N")
		this.assertEquals(new Geo.Datum(GEO.HORIZONTAL, -1)
				.getCardinalPoint(), "S")
	}

	@Test_setCardinalPoint() {
		d := new Geo.Datum()
		d.setCardinalPoint("N")
		this.assertEquals(d.cardinalPoint, Geo.HORIZONTAL)
		d.setCardinalPoint("W")
		this.assertEquals(d.cardinalPoint, Geo.VERTICAL)
		d.setCardinalPoint("s")
		this.assertEquals(d.cardinalPoint, Geo.HORIZONTAL)
		d.setCardinalPoint(1)
		this.assertEquals(d.cardinalPoint, Geo.HORIZONTAL)
		d.setCardinalPoint(0)
		this.assertEquals(d.cardinalPoint, Geo.VERTICAL)
		this.assertException(d, "setCardinalPoint",,, "x")
	}

	@Test_setDatum() {
		d := new Geo.Datum(Geo.VERTICAL, 46.235194)
		d.setDegrees(47)
		this.assertEquals(d.getDegrees(), 47)
		d.setMinutes(34)
		this.assertEquals(d.getMinutes(), 34)
		d.setSeconds(06.7)
		this.assertEquals(d.getSeconds(), 6.7)
	}

	@Test_parseDatum() {
		d := new Geo.Datum(Geo.VERTICAL, 46.235194)
		d.parseDMS("47°34'06.7""N")
		this.assertEquals(d.getDegrees(), 47)
		this.assertEquals(d.getMinutes(), 34)
		this.assertEquals(d.getSeconds(), 6.7)
		this.assertEquals(d.getCardinalPoint(), "N")
	}

	@Test_Coordinate() {
		c := new Geo.Coordinate(51.029167, 8.677222, 270.0)
		this.assertEquals(c.latitude.decimalDegrees, 51.029167)
		this.assertEquals(c.longitude.decimalDegrees, 8.677222)
		this.assertEquals(c.elevation, 270.0)
		this.assertEquals(c.asDMS()
				, "51°1'45""N 8°40'38""E 270.0m")
		this.assertEquals(c.asDMS("{:02i}d {:02i}m {:05.3f}s {:s} ", "~{:i}m")
				, "51d 01m 45.001s N 08d 40m 37.999s E ~270m")
	}
}

exitapp GeoTest.runTests()
