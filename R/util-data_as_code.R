#' Convert data.frame to R code that creates identical dataset
#'
#' @param data data.frame to convert (data.frame)
#'
#' @return object containing code to generate data.frame (character/scalar)
#' @note TODO: handle missing data (currently using datapasta pkg instead for this)
data_as_code <- function(data) {
  paste(
    "data.frame(",
    paste0(
      purrr::map_chr(
        seq_along(data),
        function(i) {
          paste0(
            "    ",
            names(data)[i],
            " = c(",
            if (class(data[[i]]) %in% c("numeric", "logical")) {
              paste0(data[[i]], collapse = ", ")
            } else {
              paste0('"', data[[i]], '"', collapse = ", ")
            },
            ")"
          )
        }),
      collapse = ",\n"
    ),
    ")",
    sep = "\n"
  )
}
