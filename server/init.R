my_packages = c("RODBC")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, repos='http://cran.us.r-project.org')
  }
}

invisible(sapply(my_packages, install_if_missing))