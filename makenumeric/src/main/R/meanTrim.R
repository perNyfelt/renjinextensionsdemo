# Title     : TODO
# Objective : TODO
# Created by: pernyf
# Created on: 2018-12-18
meanTrim <- function(x) {
    x <- x[x != max(x)]
    x <- x[x != min(x)]
    return(mean(x))
}
