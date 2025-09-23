#' Create reproducible code for current forestplot
#'
#' @param forestplot output from forest_plot()
#' @param unfold unfold the \code{\link{forest_plot}} function? (logical/scalar; default = FALSE)
#'
#' @note Unfolding the code (`unfold = T`) will generate a code snippet that uses the
#'  \code{\link{forestploter}} package functions directly; the resulting code
#'  does not require the `gst` package.
#'
#' @note WARNING: This function will not create a perfect reprex if you use the `...` argument in \code{\link{forest_plot}}
#'
#' @export
forest_reprex <- function(forestplot, unfold = FALSE) {

  # get parameters passed to forest_plot()
  param_list <- attr(forestplot, "params")
  if (is.null(param_list))
    stop("`forestplot` must have a 'param' attribute to generate a reprex!")

  # expand parameter list into string for function call
  param_str <-
    paste(
      purrr::map_chr(
        seq_along(param_list)[-1],  # ignore input data
        function(i) {
          paste0(
            ifelse(unfold, "", "    "),
            names(param_list)[i],
            ifelse(unfold, " <- ", " = "),
            ifelse(
              is.null(param_list[[i]]),
              "NULL",
              ifelse(
                class(param_list[[i]]) %in% c("character", "factor"),
                ifelse(
                  length(param_list[[i]]) > 1,
                  paste0("c(", paste0('"', param_list[[i]], '"', collapse = ", "), ")"),  # vector character
                  paste0('"', param_list[[i]], '"') # scalar character
                ),
                ifelse(
                  length(param_list[[i]]) > 1,
                  paste0("c(", paste(param_list[[i]], collapse = ", "), ")"),  # vector numeric
                  param_list[[i]] # scalar numeric
                )
              )
            )
          )
        }
      ),
      collapse = ifelse(unfold, "\n", ",\n")
    )

  # reprex code to generate forestplot
  if (unfold) {

    # unfold function
    txt <- gst::forest_plot |> body() |> deparse()
    txt <- txt[3:(length(txt) - 3)]    # ignore brackets + param_list storage + return
    txt <- stringr::str_replace(txt, "    ", "")

    # fix 'else' on newline
    txt2 <- stringr::str_trim(txt)
    txt_bracket <- stringr::str_sub(txt2, 1, 1) == "}"
    txt_else <- stringr::str_sub(txt2, 1, 4) == "else"
    ids <- which(txt_bracket & dplyr::lead(txt_else))
    txt[ids] <- paste(txt[ids], txt[ids + 1])
    txt <- txt[-(ids + 1)]

    # replace ... (TODO: replace with user inputs)
    txt <- stringr::str_replace(txt, stringr::fixed(", ..."), "")

    reprex_code <-
      c(
        "#see {forestploter} vignette: https://cran.r-project.org/web/packages/forestploter/vignettes/forestploter-intro.html",
        "",
        "library(forestploter)",
        "library(tibble)",
        "",
        "# Assign Parameter Values",
        param_str,
        "",
        "# Load Data",
        "dt <- ",
        param_list$dt |> datapasta::tribble_construct(),
        "",
        "# Draw Forest Plot",
        txt,
        "",
        "# Print Forestplot Object",
        "print(p)"
      )

  } else {

    reprex_code <-
      c(
        "#see {forestploter} vignette: https://cran.r-project.org/web/packages/forestploter/vignettes/forestploter-intro.html",
        "",
        "library(gst)",
        "library(tibble)",
        "",
        "# Load Data",
        "data <- ",
        #final_data() |> data_as_code(),
        param_list$dt |> datapasta::tribble_construct(),
        "",
        "# Draw Forest Plot",
        "forest_plot(",
        "    data, ",
        param_str,
        ")"
      )

  }

  reprex_code <- paste(reprex_code, collapse = "\n")

  return(reprex_code)
}
