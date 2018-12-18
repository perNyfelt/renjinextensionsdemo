library("se.alipsa:meantrim")
library("hamcrest")
assertThat(meanTrim(1:10), identicalTo(5.5))