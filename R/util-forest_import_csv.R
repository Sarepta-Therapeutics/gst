#' Import forest plot data from csv file
#' @param filename full path to csv file (character/scalar)
#'
forest_import_csv <- function(filename) {

  # Read csv
  df <- readr::read_csv(filename, col_types = "ccnnnnncl")

  # Data checks
  if (nrow(df) == 0)
    stop("Input data must have at least 1 row.")
  if (ncol(df) < 8)
    stop("Input data must have at least 8 columns")
  if (!all(c("low", "hi") %in% names(df)))
    stop("Input data must include 'low' and 'hi' columns for confidence interval limits.")

  # Invert column
  if (!is.element("invert", names(df)))
    df$invert <- F     # add 'invert' column if not provided; assume none are inverted
  df$invert[is.na(df$invert)] <- F     # by default, do not invert

  return(df)
}
