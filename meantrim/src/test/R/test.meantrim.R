library("se.alipsa:meantrim")
library("hamcrest")

test.meantrim <- function() {
    assertThat(meantrim(1:10), identicalTo(5.5))
}