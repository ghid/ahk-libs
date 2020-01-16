class Calendar {

	#Include %A_LineFile%\..\modules\calendar
	#Include Helper.ahk
	#Include SunriseSunset.ahk
	#Include TimeZone.ahk
	#Include Units.ahk
	
	version() {
		return "1.0.0"
	}

	requires() {
		return [Structure
				, Object
				, TIME_ZONE_INFORMATION
				, DYNAMIC_TIME_ZONE_INFORMATION]
	}

	static SUNDAY    := 1
	static MONDAY    := 2
	static TUESDAY   := 3
	static WEDNESDAY := 4
	static THURSDAY  := 5
	static FRIDAY    := 6
	static SATURDAY  := 7

	static JANUARY   :=  1
	static FEBRUARY  :=  2
	static MARCH     :=  3
	static APRIL     :=  4
	static MAY       :=  5
	static JUNE      :=  6
	static JULY      :=  7
	static AUGUST    :=  8
	static SEPTEMBER :=  9
	static OCTOBER   := 10
	static NOVEMBER  := 11
	static DECEMBER  := 12

	static FIND_NEXT   := +0.1
	static FIND_RECENT := -0.1
	static FIND_NEXT_OR_FIRST_OCCURENCE_OF_WEEKDAY := 0

	timeStamp := A_Now
	deviationFromUTC := ""

	__new(dateTime="", deviationFromUTC="") {
		try {
			this.timeStamp := Calendar.Helper.validTime(dateTime)
			this.deviationFromUTC
					:= Calendar.Helper.validTimeZone(deviationFromUTC)
		} catch _ex {
			throw _ex
		}
	}

	get() {
		return this.timeStamp
	}

	isLeapYear() {
		yearToTest := SubStr(this.timeStamp, 1, 4)
		return (Mod(yearToTest, 4) == 0 && Mod(yearToTest, 100) != 0)
				|| Mod(yearToTest, 400) == 0
	}

	long(piLong="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asLong()/Calendar.setAsLong() instead ; ahklint-ignore: W002
		if (piLong = "") {
			return this.asLong()
		}
		return this.setAsLong(piLong)
	} ; notest-end

	asLong() {
		dateTime := this.timeStamp
		dateTime -= 19700101000000, Seconds
		return dateTime
	}

	setAsLong(newLongDateTime) {
		dateTime := 19700101000000
		dateTime += newLongDateTime, Seconds
		this.timeStamp := dateTime
		return this
	}

	julian(piJulian="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asJulian()/Calendar.setAsJulian() instead ; ahklint-ignore: W002
		if (piJulian = "") {
			return this.asJulian()
		}
		return this.setAsJulian(piJulian)
	} ; notest-end

	asJulian() {
		julianDateTime := 0
		loop % this.asMonth() - 1 {
			julianDateTime += Calendar.Helper.daysInMonth(this.timeStamp
					, A_Index)
		}
		julianDateTime += this.asDay()
		return julianDateTime
	}

	setAsJulian(newJulianDateTime) {
		if (!RegExMatch(newJulianDateTime, "^\d+$")) {
			throw Exception("Invalid data type - integer expected"
					, -1 , "<" newJulianDateTime ">")
		}
		daysInYear := 337 + Calendar.Helper.daysInMonth(this.timeStamp, 2)
		if (newJulianDateTime < 1 || newJulianDateTime > daysInYear) {
			throw Exception("Julian day must be between 1 and " daysInYear
					, -1, "<" newJulianDateTime ">")
		}
		dayOfJulianDateTime := newJulianDateTime
		while (dayOfJulianDateTime > Calendar.Helper.daysInMonth(this.timeStamp
				, A_Index)) {
			dayOfJulianDateTime -= Calendar.Helper.daysInMonth(this.timeStamp
					, A_Index)
			monthOfJulianDateTime := A_Index + 1
		}
		this.setAsMonth(monthOfJulianDateTime)
		this.setAsDay(dayOfJulianDateTime)
		return this
	}

	date(pDate="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asDate()/Calendar.setAsDate() instead ; ahklint-ignore: W002
		if (pDate = "") {
			return this.asDate()
		}
		return this.setAsDate(pDate)
	} ; notest-end

	asDate() {
		return SubStr(this.timeStamp, 1, 8)
	}

	setAsDate(newDate) {
		validNewDate := Calendar.Helper.validTime(newDate)
		this.timeStamp := SubStr(validNewDate, 1, 8) SubStr(this.timeStamp, 9)
		return this
	}

	time(pTime="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asTime()/Calendar.setAsTime() instead ; ahklint-ignore: W002
		if (pTime = "") {
			return this.asTime()
		}
		return this.setAsTime(pTime)
	} ; notest-end

	asTime() {
		return SubStr(this.timeStamp, 9)
	}

	setAsTime(newTime) {
		validNewTime := Calendar.Helper.validTime(16010101 newTime)
		this.timeStamp := SubStr(this.timeStamp, 1, 8) SubStr(validNewTime, 9)
		return this
	}

	year(piYear="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asYear()/Calendar.setAsYear() instead ; ahklint-ignore: W002
		if (piYear = "") {
			return this.asYear()
		}
		return this.setAsYear(piYear)
	} ; notest-end

	asYear() {
		return SubStr(this.timeStamp, 1, 4)
	}

	setAsYear(newYear) {
		validNewYear := Calendar.Helper.validTime(newYear)
		this.timeStamp := SubStr(validNewYear, 1, 4) SubStr(this.timeStamp, 5)
		return this
	}

	month(piMonth="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asMonth()/Calendar.setAsMonth() instead ; ahklint-ignore: W002
		if (piMonth = "") {
			return this.asMonth()
		}
		return this.setAsMonth(piMonth)
	} ; notest-end

	asMonth() {
		return SubStr(this.timeStamp, 5, 2)
	}

	setAsMonth(newMonth) {
		validNewMonth := Calendar.Helper.validTime(1601
				. SubStr("0" newMonth, -1))
		this.timeStamp := SubStr(this.timeStamp, 1, 4)
				. SubStr(validNewMonth, 5, 2)
				. SubStr(this.timeStamp, 7)
		return this
	}

	day(piDay="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asDay()/Calendar.setAsDay() instead ; ahklint-ignore: W002
		if (piDay = "") {
			return this.asDay()
		}
		return this.setAsDay(piDay)
	} ; notest-end

	asDay() {
		return SubStr(this.timeStamp, 7, 2)
	}

	setAsDay(newDay) {
		validNewDay := Calendar.Helper.validTime(160101 SubStr("0" newDay, -1))
		this.timeStamp := SubStr(this.timeStamp, 1, 6)
				. SubStr(validNewDay, 7, 2)
				. SubStr(this.timeStamp, 9)
		return this
	}

	hour(piHour="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asHour()/Calendar.setAsHour() instead ; ahklint-ignore: W002
		if (piHour = "") {
			return this.asHour()
		} else {
			return this.setAsHour(piHour)
		}
	} ; notest-end

	asHour() {
		return SubStr(this.timeStamp, 9, 2)
	}

	setAsHour(newHour) {
		newValidHour := Calendar.Helper.validTime(16010101
				. SubStr("0" newHour, -1))
		this.timeStamp := SubStr(this.timeStamp, 1, 8)
				. SubStr(newValidHour, 9, 2)
				. SubStr(this.timeStamp, 11)
		return this
	}

	minutes(piMinutes="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asMinutes()/Calendar.setAsMinutes() instead ; ahklint-ignore: W002
		if (piMinutes = "") {
			return this.asMinutes()
		}
		return this.setAsMinutes(piMinutes)
	} ; notest-end

	asMinutes() {
		return SubStr(this.timeStamp, 11, 2)
	}

	setAsMinutes(newMinutes) {
		validNewMinutes := Calendar.Helper.validTime(1601010100
				. SubStr("0" newMinutes, -1))
		this.timeStamp := SubStr(this.timeStamp, 1, 10)
				. SubStr(validNewMinutes, 11, 2)
				. SubStr(this.timeStamp, 13)
		return this
	}

	seconds(piSeconds="") { ; notest-begin
		OutputDebug %A_ThisFunc% is deprecated: Use Calendar.asSeconds()/Calendar.setAsSeconds() instead ; ahklint-ignore: W002
		if (piSeconds = "") {
			return this.asSeconds()
		}
		return this.setAsSeconds(piSeconds)
	} ; notest-end

	asSeconds() {
		return SubStr(this.timeStamp, 13, 2)
	}

	setAsSeconds(newSeconds) {
		newValidSeconds := Calendar.Helper.validTime(160101010000
				. SubStr("0" newSeconds, -1))
		this.timeStamp := SubStr(this.timeStamp, 1, 12)
				. SubStr(newValidSeconds, 13, 2)
		return this
	}

	easterSunday() {
		X := this.asYear()
		A := Mod(X, 19)
		K := X // 100
		M := 15 + (3 * K + 3) // 4 - (8 * K + 13) // 25
		D := Mod((19 * A + M), 30)
		S := 2 - (3 * K + 3) // 4
		R := D // 29 + (D // 28 - D // 29) * (A // 11)
		OG := 21 + D - R
		SZ := 7 - Mod((X + X // 4 + S), 7)
		OE := 7 - Mod((OG - SZ), 7)
		OS := OG + OE
		return new Calendar(this.asYear() ((OS <= 31)
				? "03" SubStr("0" OS, -1)
				: "04" SubStr("0" (OS - 31), -1)))
	}

	daysInMonth() {
		return Calendar.Helper.daysInMonth(this.timeStamp, this.asMonth())
	}

	dayOfWeek() {
		FormatTime weekDay, % this.timeStamp, WDay
		return weekDay
	}

	week() {
		FormatTime weekOfYear, % this.timeStamp, YWeek
		return SubStr(weekOfYear, -1)
	}

	compare(anotherCalendar, unit="", precision="") {
		if (unit != "" && !Calendar.Units.isValid(unit)) {
			throw Exception("Invalid calendar unit", -1, "<" unit ">")
		}
		if (precision != "") {
			if (!RegExMatch(precision, "^[+-]?(\d+|\d*?\.\d+)$")) {
				throw Exception("Invalid datatype - number expected"
						, -1, "<" precision ">")
			}
			compareInUnit := Calendar.Units.SECONDS
		} else {
			compareInUnit := unit
		}
		timeStampToCompare := anotherCalendar.get()
		thisTimeStamp := this.get()
		difference := timeStampToCompare
		difference -= thisTimeStamp, %compareInUnit%
		if (precision != "" && !(unit == Calendar.Units.SECONDS)) {
			currentFloatFormat := A_FormatFloat
			SetFormat Float, %precision%
			if (unit == Calendar.Units.MINUTES) {
				difference /= 60.0
			} else if (unit == Calendar.Units.HOURS) {
				difference /= 3600.0
			} else if (unit == Calendar.Units.DAYS) {
				difference /= 86400.0
			}
			 SetFormat Float, %currentFloatFormat%
		}
		return difference
	}

	duration(seconds) {
		days := seconds // 86400
		seconds -= days * 86400
		hours := seconds // 3600
		seconds -= hours * 3600
		minutes := seconds // 60
		seconds := seconds - minutes * 60
		return [days, hours, minutes, seconds]
	}

	adjust(adjustYears=0, adjustMonths=0, adjustDays=0, adjustHours=0
			, adjustMinutes=0, adjustSeconds=0) {
		Calendar.Helper.testForValidInteger(adjustYears, "Invalid years")
		Calendar.Helper.testForValidInteger(adjustMonths, "Invalid months")
		Calendar.Helper.testForValidInteger(adjustDays, "Invalid days")
		Calendar.Helper.testForValidInteger(adjustHours, "Invalid hours")
		Calendar.Helper.testForValidInteger(adjustMinutes, "Invalid minutes")
		Calendar.Helper.testForValidInteger(adjustSeconds, "Invalid seconds")
		yearsToAdjust := adjustYears + adjustMonths // 12
		this.setAsYear(this.asYear() + yearsToAdjust)
		monthsToAdjust := Mod(adjustMonths, 12)
		Calendar.Helper.adjustMonthAndHandleUnderFlowOrOverFlow(this
				, monthsToAdjust)
		ts := this.timeStamp
		ts += adjustDays, Days
		ts += adjustHours, Hours
		ts += adjustMinutes, Minutes
		ts += adjustSeconds, Seconds
		this.timeStamp := ts
		return this
	}

	findWeekDay(dayOfWeek=1, occurenceAndDirection=0.1) {
		Calendar.Helper.testForValidWeekDay(dayOfWeek)
		Calendar.Helper.testForValidNumber(occurenceAndDirection)
		if (Calendar.Helper
				.findNextOrFirstOccurenceOfWeekDay(occurenceAndDirection)) {
			occurenceOfWeekDay
					:= Calendar.Helper.findNextOccurenceOfWeekDay(this.clone()
					, dayOfWeek, occurenceAndDirection)
		} else {
			occurenceOfWeekDay
					:= Calendar.Helper.findRecentOccurenceOfWeekDay(this.clone()
					, dayOfWeek, occurenceAndDirection)
		}
		return occurenceOfWeekDay
	}

	formatTime(pattern="") {
		dateTime := this.timeStamp
		FormatTime dateTime, %dateTime%, %pattern%
		return dateTime
	}

	sunrise(aGeoCoordinate, differenceToUTC="") {
		sunriseSeconds := new Calendar.SunriseSunset(this, aGeoCoordinate
				, differenceToUTC).sunrise() * 3600
		return this.setAsTime(0).adjust(0, 0, 0, 0, 0, Floor(sunriseSeconds))
	}

	sunset(aGeoCoordinate, differenceToUTC="") {
		sunsetSeconds := new Calendar.SunriseSunset(this, aGeoCoordinate
				, differenceToUTC).sunset() * 3600
		return this.setAsTime(0).adjust(0, 0, 0, 0, 0, Floor(sunsetSeconds))
	}

	timeLocal(timeShift="") {
		timeShift := (timeShift == ""
				? new Calendar.TimeZone().getBias() * -1
				: Calendar.Helper.validTimeZone(timeShift) * 60)
		return this.adjust(0, 0, 0, 0, timeShift)
	}

	timeUTC() {
		timeShift := (this.deviationFromUTC == ""
				? new Calendar.TimeZone().getBias()
				: this.deviationFromUTC * -60)
		return this.adjust(0, 0, 0, 0, timeShift)
	}
}
