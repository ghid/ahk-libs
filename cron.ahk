class Cron {

	#Include %A_LineFile%\..\modules\cron
	#Include Entry.ahk

	version() {
		return "1.0.2"
	}

	requires() {
		return [String, Arrays, Math, Calendar]
	}

	static patternString
			:= "(?P<{:s}>{:s}((\d+,)*\d+|(\d+-\d+,)*\d+-\d+|\*)(\/\d+)*)\s+"
	static cronTab := "`n"
	static IsStarted := false
	static numberOfJobs := 0

	__new() {
		throw Exception("Instatiation of class " this.__Class
				. " is not allowed", -1)
	}

	start() {
		SetTimer CronTimer, % Cron.delay()
		Cron.isStarted := true
		return

		CronTimer:
			Cron.processJobs()
			SetTimer CronTimer, % Cron.delay()
		return
	}

	delay() {
		return (((60 - A_Sec) * 1000) - A_MSec) * -1
	}

	stop() {
		Cron.isStarted := false
		SetTimer CronTimer, Off
		return ErrorLevel
	}

	reset() {
		Cron.cronTab := "`n"
		Cron.numberOfJobs := 0
	}

	processJobs() {
		if (!Cron.isStarted) {
			return -1
		}
		Cron.sleepUntilNextMinute()
		numberOfJobsFound := 0
		startAt := 1
		loop {
			if (foundJobAt := RegExMatch(Cron.cronTab
					, Cron.buildExpression(A_Min), $job, startAt)) {
				numberOfJobsFound++
				%$jobName%($jobNumber)
				startAt := foundJobAt + StrLen($jobName) - 1
			}
		} until (foundJobAt = 0)
		return numberOfJobsFound
	}

	sleepUntilNextMinute() {
		static minuteOfPreviousRun := A_Min
		while (minuteOfPreviousRun == A_Min) {
			sleep 200
		}
		minuteOfPreviousRun := A_Min
	}

	buildExpression(current_min) {
		lastDay := (A_DD == new Calendar(A_Year A_MM).daysInMonth() ? "|L" : "")
		return "\n(?P<Number>\d+?):\s*"
				. "((\d+,)*" Cron.value2Expr(current_min) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_Hour) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_DD) "(,\d+)*|\*" lastDay ")\s+"
				. "((\d+,)*" Cron.value2Expr(A_MM) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_WDay) "(,\d+)*|\*)\s+"
				. "(?P<Name>.+?)\s*\n"
	}

	addScheduler(cronPattern, functionName) {
		this.cronTab .= ++Cron.numberOfJobs ":"
				. Cron.parseEntry(cronPattern, functionName) "`n"
	}

	parseEntry(cronPattern, functionName) {
		cronEntryString := cronPattern.trimAll() " " functionName.trimAll()
		if (RegExMatch(cronEntryString, Cron.pattern(), $cronEntry)) {
			cronEntryExpression := new Cron.Entry($cronEntry).asExpression()
		} else {
			cronEntryExpression := ""
			throw Exception("Entry '" cronEntryString
					. "' is rejected: " ErrorLevel)
		}
		return cronEntryExpression
	}

	pattern() {
		return "SO)^"
				. Format(Cron.patternString, "minute", "")
				. Format(Cron.patternString, "hour", "")
				. Format(Cron.patternString, "day", "L|")
				. Format(Cron.patternString, "month", "")
				. Format(Cron.patternString, "weekday", "")
				. "(?P<functionName>.+?)$"
	}

	asFromToRange(range, upperBound, currentValue) {
		RegExMatch(range, "(.+?)(\/(\d+))*$", $range)
		if ($range1 != "*" && $range3 != "") {
			return $range1 "-" upperBound
		}
		if ($range1 == "*" && $range3 != "") {
			return Mod(currentValue, $range3) "-" upperBound
		}
		if ($range1 != "" && $range3 != "") {
			return $range1 "-" upperBound
		}
		return range
	}

	checkRanges(currentValues, lowerBound, upperBound) {
		for _, currentValue in currentValues {
			if (currentValue < lowerBound || currentValue > upperBound) {
				throw Exception("Range out of bounds: " currentValue
						. " (" lowerBound "-" upperBound ")")
			}
		}
		return true
	}

	setIntervals(intervals, range) {
		distinctIntervals := Arrays.distinct(intervals)
		if (RegExMatch(range, "^(.+?)\/(\d+)$", $range)) {
			interval := 0
			i := 1
			while (i <= distinctIntervals.count()) {
				if (mod(interval, $range2) != 0) {
					distinctIntervals.remove(i)
				} else {
					i++
				}
				interval++
			}
		}
		return distinctIntervals
	}

	value2Expr(value) {
		return "0*" RegExReplace(value, "^0*", "")
	}
}
