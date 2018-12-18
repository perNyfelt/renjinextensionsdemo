library("se.alipsa:makenumeric")
library("hamcrest")

assertThat(extractDigits(c("5", "6Y8", "He", "02")), identicalTo(c("5", "68", "", "02")))
assertThat(makeNumber(c("5", "6Y8", "He", "02")), identicalTo(c(5, 68, NA, 2)))