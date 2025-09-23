#' Draw forest plot
#'
#' @param dt input data (columns: {Endpoint, Group, Comparator, Control, LSMean, low, hi, p, invert)})
#' @param indent_subgroups indent subgroup labels (logical/scalar; default = TRUE)
#' @param indent_keyword indent keyword (is this useful)
#' @param standardize_plot normalize/standardize point estimate and CI plot display (logical/scalar)
#' @param flip_arrows flip directional arrows below forestplot (logical/scalar)
#' @param font_size font size (numeric/scalar)
#' @param footnote_size footnote font size (numeric/scalar)
#' @param plot_pch plotting character (numeric/scalar)
#' @param plot_point_size size of plotted point estimate (numeric/scalar)
#' @param plot_zoom zoom level for forestplot (numeric/scalar, range: 0 - 100)
#' @param plot_x_ticks vector of x-axis tick marks for forestplot (numeric/vector)
#' @param plot_symmetric should the forestplot have a symmetric x-axis? (logical/scalar)
#' @param ci_t_height size of confidence interval T endpoint (numeric/scalar; range: 0 - 1)
#' @param ci_color color used for normal forestplot confidence intervals (character/scalar; hex color code)
#' @param ci_color_inverted color used for inverted forestplot confidence intervals (character/scalar; hex color code)
#' @param row_height row height (numeric/scalar)
#' @param color_by_endpoint add coloring for each endpoint (logical/scalar)
#' @param significance_level significance level (alpha) for two-sided confidence interval
#' @param display_cols names of columns to display, in order (character/vector; use NULL for defaults)
#' @param display_widths column widths for the `display_cols` (numeric/vector; use NULL for defaults)
#' @param forest_label label for forest plot column (character/scalar; use NULL for defaults)
#' @param digits number of digits to round estimate + CI column to (scalar/integer; default = 2; use NULL for no rounding)
#' @param arrow_prefix prefix to use for favor arrows (character/scalar; default = "Favors")
#' @param arrow_label_left label for the left-facing arrow (character/scalar; default = NULL (header for control column))
#' @param arrow_label_right label for the left-facing arrow (character/scalar; default = NULL (header for comparator column))
#' @param ... additional arguments passed on to \code{\link[forestploter]{forest_theme}}
#'
#' @section Input Data Requirements:
#'
#' The format of the input data `dt` is rigid and must include all columns in order,
#' even when specifying the `display_cols` and only using a subset.  See \code{\link{forest_data}}
#' for example input data with the required columns in the correct order.
#'
#' @section Customizing columns:
#'
#' Columns can be customized using the `display_cols` argument, a character vector
#' with column names in the desired display order.  In additional to columns in
#' the input data (`dt`), two special column names are:
#' - `est+ci`: the estimate and confidence interval column
#' - `forest`: forestplot image column
#'
#' Note that when including additional columns, they should be placed after the
#' required columns in the input data (`dt`).
#'
#' By default, if `display_cols` is non-NULL then all column widths will be set to equal.
#' Use `display_widths` to further customize column widths; it should be a numeric
#' vector with length equal to `display_cols`.
#'
#' @importFrom stats setNames qnorm
#'
#' @return A \code{\link[gtable]{gtable}} object
#' @export
#'
#' @examples
#' # draw forestplot
#' forest_data() |> forest_plot()
#'
#' # standardize forest CIs
#' forest_data() |>
#'   forest_plot(
#'     standardize_plot = TRUE
#'   )
#'
#' # custom x-ticks
#' forest_data() |>
#'   forest_plot(
#'     row_height = 1.75,
#'     plot_x_ticks = c(-1, 0, 1),
#'     plot_zoom = 100
#'   )
#'
#' # custom columns
#' gst::forest_data() |>
#' dplyr::mutate(
#'   newcol1 = "A",
#'   newcol2 = "B"
#' ) |>
#' gst::forest_plot(
#'   display_cols = c("Group", "forest", "est+ci", "p", "newcol1", "newcol2"),
#'   display_widths = c(0.15, 0.2, 0.15, 0.15, 0.1, 0.1)
#' )
#'
forest_plot <- function(dt,
                        indent_subgroups = TRUE,
                        indent_keyword = "Overall",
                        standardize_plot = FALSE,
                        flip_arrows = FALSE,
                        font_size = NULL,
                        footnote_size = NULL,
                        plot_pch = 16,
                        plot_point_size = NULL,
                        plot_zoom = 80,
                        plot_x_ticks = NULL,
                        plot_symmetric = TRUE,
                        ci_t_height = 0.2,
                        ci_color = "#000000",
                        ci_color_inverted = "#4226bd",
                        row_height = NULL,
                        color_by_endpoint = FALSE,
                        significance_level = 0.05,
                        display_cols = NULL,
                        display_widths = NULL,
                        forest_label = NULL,
                        digits = 2,
                        arrow_prefix = "Favors",
                        arrow_label_left = NULL,
                        arrow_label_right = NULL,
                        ...) {

  # Suggest row_height and font_size
  suggested <- dt |> forest_suggest_params()
  font_size <- dplyr::coalesce(font_size, suggested$font_size)
  footnote_size <- dplyr::coalesce(footnote_size, suggested$footnote_size)
  row_height <- dplyr::coalesce(row_height, suggested$row_height)
  plot_point_size <- dplyr::coalesce(plot_point_size, suggested$plot_point_size)
  rm(suggested)  # so not stored in 'param_list' (used for forest_reprex())

  # Store parameters
  param_list <- c(as.list(environment()), list(...))

  # Check input data
  # -- column ordering is what matters most here (TODO)
  # -- invert and p-value columns are optional
  if (ncol(dt) == 7 & !is.element("p", names(dt)))
    dt$p <- NA_real_
  if (ncol(dt) == 8 & !is.element("invert", names(dt)))
    dt$invert <- FALSE

  # Check parameter values
  if (!is.null(plot_x_ticks) && !all(is.numeric(plot_x_ticks)))
    stop("You must provide a vector of numeric values for `plot_x_ticks` parameter.")
  if (!is.null(digits) && (length(digits) > 1 || digits != as.integer(digits) || digits < 0))
    stop("`digits` must be a scalar and non-negative whole number (or NULL).")

  # Indent Subgroups (optional)
  if (indent_subgroups) {
    keyword <- tolower(indent_keyword)
    dt[[2]] <- ifelse(grepl(keyword, tolower(dt[[2]]), ignore.case = TRUE),
                                  dt[[2]],
                                  paste0("   ", dt[[2]]))
  }

  # Identify endpoints with inverted favorable direction
  dt[[2]] <- paste0(dt[[2]], ifelse(dt$invert, "*", ""))

  # Create a color palette
  color_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

  # Assign colors based on the Endpoint column
  unique_endpoints <- unique(dt[[1]])
  color_map <- setNames(color_palette[1:length(unique_endpoints)], unique_endpoints)
  row_colors <- color_map[dt[[1]]]

  # grab column headers (for display purposes)
  comparator_header <- names(dt)[3]
  control_header <- names(dt)[4]
  est_header <- names(dt)[5]

  # Favor arrows
  left_label <- paste(arrow_prefix, dplyr::coalesce(arrow_label_left, control_header))
  right_label <- paste(arrow_prefix, dplyr::coalesce(arrow_label_right, comparator_header))
  arrow_labels <- c(left_label, right_label)
  if (flip_arrows)
    arrow_labels <- rev(arrow_labels)

  # Modify/align arrows (if using line-breaks)
  n_breaks1 <- purrr::map_int(arrow_labels, ~stringr::str_count(.x, stringr::fixed("\n")))   # console
  n_breaks2 <- purrr::map_int(arrow_labels, ~stringr::str_count(.x, stringr::fixed("\\n")))  # w/in shiny
  n_breaks <- pmax(n_breaks1, n_breaks2)
  n_to_add <- max(n_breaks) - n_breaks
  id_to_add <- which(n_to_add > 0)
  if (length(id_to_add) == 1) {
    arrow_labels[id_to_add] <-
      paste0(
        arrow_labels[id_to_add],
        paste0(rep("\n", n_to_add[id_to_add]), collapse = "")
      )
  }

  # Define the barName column dynamically
  barName <- paste0(comparator_header, " - ", control_header)
  if (!is.null(forest_label))
    barName <- forest_label

  # Calculate standard error
  z_stat <- qnorm(1 - (significance_level / 2)) # two-sided CI (assume normal dist'n?)
  dt$se <- (dt[[7]] - dt[[5]]) / z_stat

  # Compute standardized estimate + ci
  if (standardize_plot) {
    dt$std_mean <- dt[[5]] / dt$se
    dt$std_low <- dt$std_mean - z_stat
    dt$std_high <- dt$std_mean + z_stat
  }

  # Add space to center the barName
  centered_barName <-  paste0(strrep(" ", 20), barName, strrep(" ", 5))

  # Add placeholder text to the new column
  dt[[centered_barName]] <- paste(rep(" ", 300), collapse = " ")

  # Create confidence interval column
  ci_header <- paste0(est_header, " (", 100 * (1 - significance_level), "% CI)")
  fval <- ifelse(is.null(digits), "%g", paste0("%.", digits, "f"))
  dt[[ci_header]] <- ifelse(is.na(dt$se), "",
                            sprintf(paste0(fval, " (", fval, ", ", fval, ")"), dt[[5]], dt[[6]], dt[[7]]))

  # Define the custom theme
  custom_theme <- forestploter::forest_theme(
    base_size = font_size,
    refline_gp = grid::gpar(col = "red"),
    footnote_gp = grid::gpar(col = "#636363", fontface = "italic", fontsize = footnote_size),
    arrow_length = grid::unit(0.25, "cm"),
    arrow_type = "open",
    ci_pch = plot_pch,
    ci_col = ci_color,
    ci_lwd = 2,
    ci_Theight = ci_t_height,
    ...
  )

  # Calculate symmetrical range for x-axis
  # -- compute data range (account for inverted status)
  est_vals <- ifelse(dt$invert, -1, 1) * (if (standardize_plot) dt$std_mean else dt[[5]])
  low_vals <- if (standardize_plot) ifelse(dt$invert, -dt$std_high, dt$std_low) else ifelse(dt$invert, -dt[[7]], dt[[6]])
  hi_vals <- if (standardize_plot) ifelse(dt$invert, -dt$std_low, dt$std_high) else ifelse(dt$invert, -dt[[6]], dt[[7]])
  range_vec <- c(est_vals, low_vals, hi_vals)
  # -- adjust range to fit custom x-tick-marks
  if (!is.null(plot_x_ticks))
    range_vec <- c(range_vec, plot_x_ticks)
  # -- apply symmetry (or not)
  if (plot_symmetric) {
    max_abs_value <- max(abs(range_vec), na.rm = TRUE)
    plot_range <- c(-max_abs_value, max_abs_value)
  } else {
    plot_range <- range(range_vec, na.rm = TRUE)
  }

  # Add padding to the range -- (100 - {plot_zoom})% on each side
  padding <- diff(plot_range) * ((100 - plot_zoom) / 100)
  expanded_range <- c(plot_range[1] - padding, plot_range[2] + padding)

  # Only include p-value if any column values are non-missing
  include_pvalue <- any(!is.na(dt[[8]]))

  # Locate column headers for forestplot
  forest_col_id <- which(names(dt) == centered_barName)
  ci_col_id <- which(names(dt) == ci_header)
  if (is.null(display_cols)) {
    tbl_cols <- c(2, 3, 4, forest_col_id, ci_col_id)
    if (include_pvalue)
      tbl_cols <- c(tbl_cols, 8)
  } else {
    tbl_cols <-
      purrr::map_int(
        display_cols,
        function(v) {
          if (v == "forest") {
            id <- forest_col_id
          } else if (v == "est+ci") {
            id <- ci_col_id
          } else {
            id <- which(names(dt) == v)
          }
          id
        }
      )
  }

  # Get relevant columns; handle \n when using in Shiny app
  dtt <- dt[, tbl_cols]
  dtt <- replace(dtt, is.na(dtt), "")
  names(dtt) <- purrr::map_chr(names(dtt), ~stringr::str_replace_all(.x, stringr::fixed("\\n"), "\n"))
  arrow_labels <- stringr::str_replace_all(arrow_labels, stringr::fixed("\\n"), "\n")

  # Create forest plot with adjusted column widths and symmetrical x-axis
  p0 <- forestploter::forest(
    dtt,
    est = est_vals,
    lower = low_vals,
    upper = hi_vals,
    #sizes = dt$se,
    sizes = plot_point_size,
    ci_column = which(tbl_cols == forest_col_id),
    ref_line = 0,
    footnote = if (any(dt$invert)) "  * Sign reversed to align favorable directions among effect endpoints" else NULL,
    arrow_lab = arrow_labels,
    xlim = expanded_range,  # Use the symmetrical range here
    ticks_at = plot_x_ticks,
    theme = custom_theme
  )

  # Extract the gtable from the plot
  gt <- p0

  # Modify the heights of the rows (increase to make them taller)
  if (length(gt$heights) > 0)
    gt$heights <- grid::unit(rep(row_height, length(gt$heights)), "lines")

  # Modify heights for arrows (if using line-breaks)
  if (max(n_breaks) > 0) {
    arrow_row <- length(gt$heights) - 1
    gt$heights[arrow_row] <- max(n_breaks) * gt$heights[arrow_row]
  }

  # Modify the widths of the columns (shrink comparator/control and increase forest plot column)
  if (is.null(display_cols) & is.null(display_widths)) {
    gt$widths[2] <- grid::unit(0.2, "npc")   # Comparator column (reduced)
    gt$widths[3] <- grid::unit(0.1, "npc")  # Control column (reduced)
    #gt$widths[4] <- grid::unit(0, "npc")     # Empty column
    gt$widths[5] <- grid::unit(0.35, "npc")   # Forest plot column (increased)
    if (include_pvalue)
      gt$widths[6] <- grid::unit(0.2, "npc") # P-values
  } else if (is.null(display_cols) & !is.null(display_widths)) {
    my_widths <- rep_len(display_widths, length.out = length(gt$widths) - 2)
    for (i in seq_along(my_widths))
      gt$widths[i + 1] <- grid::unit(my_widths[i], "npc")
  } else if (!is.null(display_cols)) {
    if (is.null(display_widths))
      display_widths <- 1 / length(display_cols)
    if (length(display_widths) == 1)
      display_widths <- rep(display_widths, length(display_cols))
    stopifnot(length(display_cols) == length(display_widths))
    for (i in seq_along(display_widths))
      gt$widths[i+1] <- grid::unit(display_widths[i], "npc")
  }


  p <- gt

  # Edit row colors
  if (color_by_endpoint) {
    for (i in seq_along(row_colors)) {
      p <- forestploter::edit_plot(p, row = i, col = 1:length(tbl_cols), which = "background",
                                   gp = grid::gpar(fill = row_colors[i]))
    }
  }

  # Edit CIs colors for inverted outcomes
  if (any(dt$invert)) {
    p <- p |>
      forestploter::edit_plot(
        row = which(dt$invert),
        col = which(tbl_cols == forest_col_id),
        which = "ci",
        gp = grid::gpar(col = ci_color_inverted)
      )
  }

  # get plot dimensions (for saving as png)
  attr(p, "dims") <- forestploter::get_wh(p, unit = "in")

  # Store parameter list
  attr(p, "params") <- param_list

  return(p)
}
