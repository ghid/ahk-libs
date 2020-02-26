; @todo: Refactor
class Cron {

	version() {
		return "1.0.1"
	}

	requires() {
		return [String, Arrays, Math, Calendar]
	}

	static cron_tab := "`n"
	static IsStarted := false
	static cron_job_num := 0

	__new() {
		throw Exception("Instatiation of class " this.__Class
				. " is not allowed", -1)
	}

	start() {
		delay := (((60 - A_Sec) * 1000) - A_MSec) * -1
		SetTimer CronTimer, %delay%
		Cron.isStarted := true
		return

		CronTimer:
			delay := (((60 - A_Sec) * 1000) - A_MSec) * -1
			Cron.scheduler(A_Min)
			SetTimer CronTimer, %delay%
		return
	}

	stop() {
		Cron.isStarted := false
		SetTimer CronTimer, Off
		return ErrorLevel
	}

	reset() {
		Cron.cron_tab := "`n"
		Cron.cron_job_num := 0
	}

	scheduler(current_min) {
		static last_runs_min := -1

		if (!Cron.isStarted) {
			return -1
		}
		if (last_runs_min = current_min) {
			while (last_runs_min = current_min) {
				sleep 500
				current_min := A_Min
			}
		}

		expr := Cron.buildExpression(current_min)

		num_jobs := 0
		start := 1
		loop {
			job_found_at := RegExMatch(Cron.cron_tab, expr, job_, start)
			if (job_found_at) {
				num_jobs++
				%job_name%(job_number)
				start := job_found_at + StrLen(job_name) - 1
			}
		} until (job_found_at = 0)

		last_runs_min := current_min

		return num_jobs
	}

	buildExpression(current_min) {
		lastDay := (A_DD == new Calendar(A_Year A_MM).daysInMonth() ? "|L" : "")
		return "\n(?P<number>\d+?):\s*"
				. "((\d+,)*" Cron.value2Expr(current_min) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_Hour) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_DD) "(,\d+)*|\*" lastDay ")\s+"
				. "((\d+,)*" Cron.value2Expr(A_MM) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_WDay) "(,\d+)*|\*)\s+"
				. "(?P<name>.+?)\s*\n"
	}

	addScheduler(cron_pattern, function_name) {
		this.cron_tab .= ++Cron.cron_job_num ":"
				. Cron.parseEntry(cron_pattern, function_name) "`n"
	}

	parseEntry(cron_pattern, function_name) {
		entry := cron_pattern.trimAll() " " function_name.trimAll()
		subExpr := "(((\d+,)*\d+|(\d+-\d+,)*\d+-\d+|\*)(\/\d+)*)\s+"
		subExprLast := "(L|((\d+,)*\d+|(\d+-\d+,)*\d+-\d+|\*)(\/\d+)*)\s+"
		expr := "S)^" subExpr.repeat(2)
				. subExprLast
				. subExpr.repeat(2) "(.+?)$"
		if (RegExMatch(entry, expr, cron_entry)) {
			minute := Cron.range2List(cron_entry1, 0, 59, A_Min)
			hour := Cron.range2List(cron_entry6, 0, 23, A_Hour)
			month := Cron.range2List(cron_entry16, 1, 12, A_Mon)
			wday := Cron.range2List(cron_entry21, 1, 7, A_WDay)
			day := cron_entry11 = "L"
					? cron_entry11
					: Cron.range2List(cron_entry11, 1, 31, A_MDay)
			function := cron_entry26
			effective_entry := minute " "
					. hour " "
					. day " "
					. month " "
					. wday " "
					. function
		} else {
			effective_entry := ""
			throw Exception("Entry '" entry "' is rejected: " ErrorLevel)
		}
		return effective_entry
	}

	range2List(range, lowerBound, upperBound, actual=0) {
		if (range = "*") {
			return range
		}
		intervals := []
		elements := StrSplit(Cron.asFromToRange(range, upperBound, actual), ",")
		loop % elements.count() {
			if (RegExMatch(elements[A_Index], "(?P<From>\d+)-(?P<To>\d+)"
					, $range)) {
				Cron.checkRanges([$rangeFrom, $rangeTo], lowerBound, upperBound)
				loop {
					intervals.push($rangeFrom++)
				} until ($rangeFrom > $rangeTo)
			} else if (RegExMatch(elements[A_Index], "\d+", range_val)) {
				Cron.checkRanges([range_val], lowerBound, upperBound)
				intervals.push(range_val)
			}
		}
		return Arrays.toString(Cron.setIntervals(intervals, range), ",")
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

