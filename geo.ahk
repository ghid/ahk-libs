class Geo {

	static VERTICAL := 0
	static HORIZONTAL := 1

	static CARDIAL_POINTS
			:= {1: {1: "N", 0: "S"}
			,   0: {1: "E", 0: "W"}}

	requires() {
		return [System, TestCase]
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
			this.latitude := new Geo.Datum(GEO.HORIZONTAL, latitude)
			this.longitude := new Geo.Datum(GEO.VERTICAL, longitude)
			this.elevation := elevation
		}
	}
}
