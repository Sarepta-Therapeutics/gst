#' Sarepta theming function (ported over from Sarappta)
sartheme <- function() {

  sar_purple <- '#661b62'

  bs_theme(
    # Controls the default grayscale palette
    bg = "#fff",
    fg = sar_purple,
    # Controls the accent (e.g., hyperlink, button, etc) colors
    primary = sar_purple,
    secondary = sar_purple,
    base_font = c("Poppins", "sans-serif"),
    code_font = c("Courier", "monospace"),
    heading_font = "'Poppins', Poppins, sans-serif",

    # Can also add lower-level customization
    #"input-border-color" = "rgb(134, 202, 198)",
    # "navbar-bg" = "white",
    # "navbar-dark-color" = sar_purple,
    # "nav-link-padding-y" = "0.1rem",
  ) |>
    bs_add_rules(".sidebar {font-size: 12px;  background-color:gray;}") |>
    bs_add_rules("h5 {color: #2E2E2E;size: 14px}") |>
    bs_add_rules(".bslib-gap-spacing {gap: 0.3rem !important; }") |>
    bs_add_rules(".nav-item .nav-link {
        font-size: 16px !important;
        color: #661b62 !important;
        padding: 10px 15px !important;
      }") |>
    #bs_add_rules(".handsontable{text-align: center;}") |>
    bs_add_rules(".card-header {background-color:#661b62;color: white;opacity: 0.8;}")



}
