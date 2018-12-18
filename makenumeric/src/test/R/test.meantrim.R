library("com.mydomain:meantrim")
library("hamcrest")
assertThat(meanTrim(1:10), identicalTo(5.5))
create the NAMESPACE file and export your function
export(meanTrim)