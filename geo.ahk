class Geo {

	static VERTICAL := 0
	static HORIZONTAL := 1

	static CARDINAL_POINTS
			:= {1: {1: "N", 0: "S"}
			,   0: {1: "E", 0: "W"}}

	requires() {
		return [TestCase, Object]
	}

	#Include %A_LineFile%\..\modules\geo
	#Include datum.ahk

	class Coordinate {

		latitude := new Geo.Datum()
		longitude := new Geo.Datum()
		elevation := ""

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

		; @todo: what are these methods for good? Won't be getter/setter a better alternative?
		setLatitude(aGeoDatum) {
			this.checkForExpectedObjectType(aGeoDatum)
			this.latitude := aGeoDatum
			return this
		}

		setLongitude(aGeoDatum) {
			this.checkForExpectedObjectType(aGeoDatum)
			this.longitude := aGeoDatum
			return this
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
