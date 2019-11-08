class SunriseSunset {
	timeDifference := 0
	timeEquation := 0
	localMeanTime := 0

	__new(timeDate, longitude, latitude) {
		static Pi := 3.14159
		T := timeDate.asJulian()
		B := Pi * latitude / 180
		sunsetHour := -50 / 60 / 57.29578
		declinationOfTheSun := 0.4095 * Sin(0.016906 * (T - 80.086))
		this.timeDifference := 12 * ACos((Sin(sunsetHour) - Sin(B)
				* Sin(declinationOfTheSun))
				/ (Cos(B) * Cos(declinationOfTheSun))) / Pi
		this.timeEquation := -0.171 * Sin(0.0337 * T + 0.456)
				- 0.1299 * Sin(0.01787 * T - 0.168)
		this.localMeanTime := -longitude / 15
	}

	sunrise() {
		return 12 - this.timeDifference - this.timeEquation + this.localMeanTime
	}

	sunset() {
		return 12 + this.timeDifference - this.timeEquation + this.localMeanTime
	}
}
