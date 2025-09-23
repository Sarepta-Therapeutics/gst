#' Suggest parameters for a forest_plot
#' @param dt forest data
forest_suggest_params <- function(dt) {

  # construct table with suggested values based on 'number of rows'
  # -- NOTE: works best for dt{number_of_rows} < 20
  N <- min(c(20, nrow(dt)))
  suggested <- tibble::tibble(n = 1:20) |>
    dplyr::mutate(
      row_height = 1.75 + 0.05 * (10 - n),
      font_size = dplyr::case_when(
        n < 5 ~ 13,
        n < 10 ~ 12,
        n < 15 ~ 11,
        TRUE ~ 10
      ),
      footnote_size = .data$font_size - 4,
      plot_point_size = 1 + 0.025 * (10 - n)
    )

  # get params corresponding to input data
  suggested <- suggested |>
    dplyr::filter(
      n == N
    )

  return(
    list(
      font_size = suggested$font_size,
      footnote_size = suggested$footnote_size,
      row_height = suggested$row_height,
      plot_point_size = suggested$plot_point_size
    )
  )

}
