class Geo {

	requires() {
		return [System, TestCase]
	}

	static GMS := "GMS"
			, Rational := "RATIONAL"
			, Dir := "DIR"

	lon := 0.0
	lat := 0.0
	ele := 0.0

	longitude[flag="", precision=0] {
		get {
			if (!flag) {
				return this.lon
			} else if (flag == Geo.GMS) {
				return Geo.__ToGMS(this.lon
						, dirs := {0: "E", 1: "W"}
						, precision)
			}
			else if (flag == Geo.Rational) {
				return Geo.__ToRational(this.lon, precision)
			} else if (flag == Geo.Dir) {
				return (this.lon < 0 ? "W" : "E")
			} else {
				throw Exception(A_ThisFunc ": Invalid flag: " flag)
			}
		}
		set {
			TestCase.assertTrue(System.typeOf(value, "number")
					, "Longitude must be floating point number")
			TestCase.assertTrue(value >= -180.0 && value <= +180.0
					, "Longitude must be between -180° and +180°")
			this.lon := value
		}
	}

	latitude[flag="", precision=0] {
		get {
			if (!flag) {
				return this.lat
			} else if (flag == Geo.GMS) {
				return Geo.__ToGMS(this.lat
						, dirs := {0: "N", 1: "S"}
						, precision)
			} else if (flag == Geo.Rational) {
				return Geo.__ToRational(this.lat, precision)
			} else if (flag == Geo.Dir) {
				return (this.lat < 0 ? "S" : "N")
			} else {
				throw Exception(A_ThisFunc ": Invalid flag: " flag)
			}
		}
		set {
			TestCase.assertTrue(System.typeOf(value, "number")
					, "Latitude must be floating point number")
			TestCase.assertTrue(value >= -90.0 && value <= +90.0
					, "Latitude must be between -90° and +90°")
			this.lat := value
		}
	}

	elevation[flag="", precision=0] {
		get {
			if (!flag) {
				return this.ele
			} else if (flag == Geo.GMS) {
				return Format("{:." precision "f}m", this.ele)
			} else {
				throw Exception(A_ThisFunc ": Invalid flag: " flag)
			}
		}
		set {
			TestCase.assertTrue(System.typeOf(value, "number")
					, "Elevation must be floating point number")
			this.ele := value
		}
	}

	__new(longitude=0.0, latitude=0.0, elevation=0.0) {
		this.longitude := longitude
		this.latitude := latitude
		this.elevation := elevation
	}

	parse(geoLocation) {
		cardinalPoint := "?"
		degrees := 0
		minutes := 0
		seconds := 0
		elevation := 0
		if (RegExMatch(geoLocation, "i)[NSEOW]", $)) {
			cardinalPoint := $
		}
		if (RegExMatch(geoLocation, "(\d+)°", $)) {
			degrees += $1
		}
		if (RegExMatch(geoLocation, "(\d+)'", $)) {
			minutes += $1
		}
		if (RegExMatch(geoLocation, "(\d+(\.\d+)?)""", $)) {
			seconds += $1
		}
		if (RegExMatch(geoLocation, "i)(\d+(\.\d+)?)m", $)) {
			elevation += $1
		}
		decimal := Geo.toDecimal(degrees, minutes, seconds, cardinalPoint)
		if (InStr("WEO", cardinalPoint)) {
			this.longitude := decimal
		} else if (InStr("NS", cardinalPoint)) {
			this.latitude := decimal
		} else {
			throw Exception("Invalid or missing direction: " cardinalPoint)
		}
		this.elevation := elevation
		return this
	}

	__ToGMS(decimal, cardinalPoint, precision) {
		absoluteDecimal := Abs(decimal)
		min := Mod(absoluteDecimal * 60, 60)
		sec := Mod(absoluteDecimal * 3600, 60)
		dir := cardinalPoint[(decimal < 0)]
		return Format("{:02i}°{:02i}'{:02." precision "f}""{:s}"
				, absoluteDecimal, min, sec, dir)
	}

	__ToRational(decimal, precision) {
		absoluteDecimal := Abs(decimal)
		min := Mod(absoluteDecimal * 60, 60)
		sec := Mod(absoluteDecimal * 3600, 60) * 10**precision
		return Format("{:i}/1 {:i}/1 {:i}/{:i}"
				, absoluteDecimal, min, sec, 10**precision)
	}

	toDecimal(degrees, minutes, seconds, cardinalPoint) {
		; @todo: Check for valid 'direction'
		return (degrees + minutes / 60 + seconds / 3600)
				* (cardinalPoint = "W" || cardinalPoint = "S" ? -1 : 1)
	}

	toGMS(precision=0, precisionForElevation="") {
		gms := this.latitude(Geo.GMS, precision)
				. " "
				. this.longitude(Geo.GMS, precision)
				. " "
				. this.elevation(Geo.GMS
				, (precisionForElevation != ""
				? precisionForElevation : precision))
		return gms
	}
}
