class Datum {

	axis := ""
	decimalDegrees := 0.0

	__new(axis, decimalDegrees=0.0) {
		this.axis := axis
		this.decimalDegrees := decimalDegrees
	}

	getDegrees() {
		return Format("{:i}", this.decimalDegrees)
	}

	getMinutes() {
		return Format("{:i}", Mod(Abs(this.decimalDegrees) * 60, 60))
	}

	getSeconds() {
		return Format("{:f}", Mod(Abs(this.decimalDegrees) * 3600, 60))
	}

	getCardinalPoint() {
		return GEO.CARDIAL_POINTS[this.axis == GEO.HORIZONTAL
				, this.decimalDegrees > 0]
	}

	setDegrees(degrees) {
		this.decimalDegrees := (this.decimalDegrees - this.getDegrees())
				+ degrees
	}

	setMinutes(minutes) {
		this.decimalDegrees := (this.decimalDegrees - this.getMinutes() / 60.0)
				+ minutes / 60.0
	}

	setSeconds(seconds) {
		this.decimalDegrees
				:= (this.decimalDegrees - this.getSeconds() / 3600.0)
				+ seconds / 3600.0
	}

	setCardinalPoint(cardinalPoint) {
		switch cardinalPoint {
		case "N", "S":
			this.axis := Geo.HORIZONTAL
		case "E", "O", "W":
			this.axis := Geo.VERTICAL
		}
	}

	parseDMS(dmsString, parsingExpressions="") {
		if (parsingExpressions == "") {
			parsingExpressions := new Geo.Datum.ParsingExpressions()
		}
		this.setDegrees(this.parseDegrees(dmsString, parsingExpressions))
		this.setMinutes(this.parseMinutes(dmsString, parsingExpressions))
		this.setSeconds(this.parseSeconds(dmsString, parsingExpressions))
		this.setCardinalPoint(this.parseCardinalPoint(dmsString
				, parsingExpressions))
	}

	parseDegrees(dmsString, parsingExpressions) {
		currentDegrees := this.getDegrees()
		result := this.parse(dmsString, parsingExpressions.degreesExpr)
		if (result != "") {
			return 0 + result
		}
		return currentDegrees
	}

	parseMinutes(dmsString, parsingExpressions) {
		currentMinutes := this.getMinutes()
		result := this.parse(dmsString, parsingExpressions.minutesExpr)
		if (result != "") {
			return 0 + result
		}
		return currentMinutes
	}

	parseSeconds(dmsString, parsingExpressions) {
		currentSeconds := this.getSeconds()
		result := this.parse(dmsString, parsingExpressions.secondsExpr)
		if (result != "") {
			return 0 + result
		}
		return currentSeconds
	}

	parseCardinalPoint(dmsString, parsingExpressions) {
		result := this.parse(dmsString
				, parsingExpressions.cardinalPointExpr)
		if (result) {
			if (InStr("NS", result)) {
				this.axis := Geo.HORIZONTAL
			} else {
				this.axis := Geo.VERTICAL
			}
		}
	}

	parse(dmsString, parsingExpression) {
		if (RegExMatch(parsingExpression
				, "^\/(?<Pattern>.+?(?<!\\))\/(?<Options>.*)$", regex)) {
			if (!RegExMatch(regexOptions, "\d+", regexGroup)) {
				regexGroup := 0
			}
			regexOptions := RegExReplace(regexOptions, "\d", "")
			if (RegExMatch(dmsString, regexOptions "O)" regexPattern, result)) {
				return result[regexGroup]
			}
		}
		return ""
	}

	asDMS(formatString) {
		return Format(formatString
				, this.getDegrees(), this.getMinutes()
				, this.getSeconds(), this.getCardinalPoint())
	}

	class ParsingExpressions {
		degreesExpr := "/([+-]?\d+)°/1"
		minutesExpr := "/(\d+)'/1"
		secondsExpr := "/(\d+(\.\d+)?)""/1"
		elevationExpr := "/([+-]?\d+(\.\d+)?)m/1"
		cardinalPointExpr := "/[NnSsWwEeOo]/0"
	}
}
