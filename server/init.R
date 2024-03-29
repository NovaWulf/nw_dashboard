my_packages = c("data.table","urca","lubridate","digest","lattice","latticeExtra","jsonlite")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, dependencies=TRUE, repos='http://cran.us.r-project.org')
  }
}

invisible(sapply(my_packages, install_if_missing))