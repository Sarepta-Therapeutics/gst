
#' Custom label with optional tooltip icons
#'
#' @param label text label (character/scalar)
#' @param info info hover tooltip text (character/scalar)
#' @param alert alert hover tooltip text (character/scalar)
#'
tooltip_label <- function(label, info = NULL, alert = NULL) {
  x <- list(label)
  if (!is.null(info))
    x <- list(x, info_icon() |> bslib::tooltip(info))
  if (!is.null(alert))
    x <- list(x, alert_icon() |> bslib::tooltip(alert))

  tags$span(x)
}

#' Info icon
info_icon <- function() {
  bsicons::bs_icon("info-circle")
}

#' Alert icon
alert_icon <- function() {
  bsicons::bs_icon("exclamation-circle", color = "darkred")
}
