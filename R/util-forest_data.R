#' Forestplot Example Data
#'
#' @return A data.frame that can be passed to \code{\link{forest_plot}}
#' @export
forest_data <- function() {
  data.frame(
    Endpoint = c("Endpoint 1", "Endpoint 1", "Endpoint 1",
                 "Endpoint 2", "Endpoint 2", "Endpoint 2",
                 "Endpoint 3", "Endpoint 3", "Endpoint 3"),
    Group = c("Endpoint 1 Overall", "Endpoint 1 4-5yo", "Endpoint 1 6-7yo",
              "Endpoint 2 Overall", "Endpoint 2 4-5yo", "Endpoint 2 6-7yo",
              "Endpoint 3 Overall", "Endpoint 3 4-5yo", "Endpoint 3 6-7yo"),
    Comparator = rep(20, 9),
    Control = rep(20, 9),
    LSMean = c(0.5, 0.6, 0.4,0.5, 0.6, 0.4,0.5, 0.75, 0.4 )-.5,
    low = c(0.3, 0.35, 0.25, 0.3, 0.35, 0.25,0.3, 0.55, 0.25)-.5,
    hi = c(0.7, 0.85, 0.55, 0.7, 0.85, 0.55, 0.7, 0.95, 0.55)-.5,
    p = as.character(c(0.33, 0.33, 0.21, 0.26, 0.13, 0.31, 0.37, "<0.001", 0.14)),
    invert = c(rep(F, 8), T)
  )
}
