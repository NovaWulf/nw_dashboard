my_packages = c("data.table","RODBC","urca","lubridate","digest","lattice","latticeExtra")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, repos='http://cran.us.r-project.org')
  }
}

invisible(sapply(my_packages, install_if_missing))