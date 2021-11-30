class Entry {
	minuteValue := 0
	hourValue := 0
	dayValue := 0
	monthValue := 0
	weekdayValue := 0
	functionNameValue := ""

	minute[] {
		get {
			return this.minuteValue
		}
		set {
			this.minuteValue := this.range2List(value, 0, 59, A_Min)
			return this
		}
	}

	hour[] {
		get {
			return this.hourValue
		}
		set {
			this.hourValue := this.range2List(value, 0, 23, A_Hour)
			return this
		}
	}

	day[] {
		get {
			return this.dayValue
		}
		set {
			this.dayValue := value = "L"
					? value
					: this.range2List(value, 1, 31, A_MDay)
			return this
		}
	}

	month[] {
		get {
			return this.monthValue
		}
		set {
			this.monthValue := this.range2List(value, 1, 12, A_Mon)
			return this
		}
	}

	weekday[] {
		get {
			return this.weekdayValue
		}
		set {
			this.weekdayValue := this.range2List(value, 1, 7, A_WDay)
			return this
		}
	}

	functionName[] {
		get {
			return this.functionNameValue
		}
		set {
			this.functionNameValue := value
			return this
		}
	}

	__new(aCronEntry) {
		this.minute := aCronEntry.minute
		this.hour := aCronEntry.hour
		this.day := aCronEntry.day
		this.month := aCronEntry.month
		this.weekday := aCronEntry.weekday
		this.functionName := aCronEntry.functionName
		return this
	}

	range2List(range, lowerBound, upperBound, currentValue=0) {
		if (range = "*" || RegExMatch(range, "[1-7]#[1-5]")) {
			return range
		}
		intervals := []
		elements := StrSplit(Cron.asFromToRange(range
				, upperBound, currentValue), ",")
		loop % elements.count() {
			if (RegExMatch(elements[A_Index], "(?P<From>\d+)-(?P<To>\d+)"
					, $range)) {
				Cron.checkRanges([$rangeFrom, $rangeTo]
						, lowerBound, upperBound)
				loop {
					intervals.push($rangeFrom++)
				} until ($rangeFrom > $rangeTo)
			} else if (RegExMatch(elements[A_Index], "\d+", $rangeInterval)) {
				Cron.checkRanges([$rangeInterval], lowerBound, upperBound)
				intervals.push($rangeInterval)
			}
		}
		return Arrays.toString(Cron.setIntervals(intervals, range), ",")
	}

	asExpression() {
		return Format("{:s} {:s} {:s} {:s} {:s} {:s}", this.asArray()*)
	}

	asArray() {
		return [this.minute, this.hour, this.day, this.month, this.weekday
				, this.functionName]
	}
}
