class Geo {

	#Include %A_LineFile%\..\modules\geo
	#Include datum.ahk

	version() {
		return "1.0.1"
	}

	requires() {
		return [TestCase, Object]
	}

	static VERTICAL := 0
	static HORIZONTAL := 1

	static CARDINAL_POINTS
			:= {1: {1: "N", 0: "S"}
			,   0: {1: "E", 0: "W"}}

	class Coordinate {

		latitudeValue := new Geo.Datum()
		longitudeValue := new Geo.Datum()
		elevation := ""

		latitude[] {
			get {
				return this.latitudeValue
			}
			set {
				this.checkForExpectedObjectType(value)
				this.latitudeValue := value
				return this
			}
		}

		longitude[] {
			get {
				return this.longitudeValue
			}
			set {
				this.checkForExpectedObjectType(value)
				this.longitudeValue := value
				return this
			}
		}

		asDMS(dmsFormatString="{:i}°{:i}'{:.0f}""{:s} "
				, elevationFormatString="{:.1f}m") {
			dmsCoordinates := this.latitude.asDMS(dmsFormatString)
					. this.longitude.asDMS(dmsFormatString)
			return dmsCoordinates (this.elevation != ""
					? Format(elevationFormatString, this.elevation) : "")
		}

		__new(latitude, longitude, elevation="") {
			this.latitude := new Geo.Datum(Geo.HORIZONTAL, latitude)
			this.longitude := new Geo.Datum(Geo.VERTICAL, longitude)
			this.elevation := elevation
		}

		checkForExpectedObjectType(anObject) {
			if (!Object.instanceOf(anObject, "Geo.Datum")) {
				throw Exception("Object of type 'Geo.Datum' expected "
						. "but got: " (IsObject(anObject) ? anObject.__Class
						: "no object"))
			}
		}
	}
}
