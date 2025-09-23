#' Launch the GST Power App
#'
#' @param runApp should the app be run on completion, default is TRUE
#'
#' @return A Shiny app
#' @export
#'
#' @import shiny
#' @import bslib
#' @examples
#' if (interactive()) {
#'   gst_power_app()
#' }
gst_power_app <- function(runApp = TRUE) {

  ### main app ###
  app <- shiny::shinyApp(

    # -- ui --
    ui <- {


      addResourcePath("www", system.file("www", package = "gst"))

     # navbarPage(
      page_navbar(
        title =
          div(
            style = "display: flex; align-items: center; margin-bottom: -32px; margin-right: 20px",
            img(
              src = "www/logo.png",
              style = "width: 40px; margin-right: 10px"
            ),
            h3(strong("GST Power App"), style = "margin-bottom:0px; margin-top:0px")
          ),
        theme = sartheme(),

        nav_panel(
          title = "Power Calculation",
          h5("GST Power for >=2 joint endpoints based on O'Brien Method"),
          esWidgetUI("ep")
        ),

        nav_panel(
          title = "Sample Size Calculation",
          h5("Sample Size Calculation and Exploration for Binary"),
          power2_ui("p1")
        ),

        nav_panel(
          title = "Effect Size Tipping Point",
          h5("Calculate joint GST effect size tipping point"),
          gstTippingPoint_ui("tp")
        ),

        nav_spacer(),

        nav_item(
          tags$a(
            shiny::icon("book"),
            "Reference",
            href = "https://connect.sarepta.com/gst-pkgdown/articles/reference.html",
            target = "_blank"
          )
        ),

        nav_item(
          tags$a(
            shiny::icon("circle-question"),
            "User Guide",
            href = "https://connect.sarepta.com/gst-pkgdown/articles/gst_power_app.html",
            target = "_blank"
          )
        )

      )
    },

    # -- server --
    server <- function(input, output, session) {

      ns <- session
      esWidgetServer("ep")
      power2_sever("p1")
      gstTippingPoint_server("tp")
    }

  )

  # run build app
  if (runApp)
    runApp(app)
  else
    app
}
