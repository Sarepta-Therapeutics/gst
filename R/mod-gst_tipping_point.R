#' Effect size tipping point calculation
#'
#' Given Endpoint 1 effect size ES1 and correlation with endpoint 2 Rho, calculate tipping point for Effect Size 2, such that the joint endpoint effect size dips
#' below the first (larger) Endpoint 1 ES1. This is based on Dallow (2016)
#'
#' @param id namespaced ID (character/scalar)
#'
#' @import shiny ggplot2
#' @importFrom plotly ggplotly renderPlotly plotlyOutput
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows
#'
#' @export

# UI
gstTippingPoint_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        width = 2,
        wellPanel(
          numericInput(ns("ep1_es"), "Endpoint 1 Effect Size", value=1, min=.1, max=5, step = .1),
          numericInput(ns("rho"), "Correlation", value=.5, min=0, max=1, step = .05),
          actionButton(ns("add_row"), "Add row"),
          actionButton(ns("clear_table"), "Clear table")
        )
      ),
      mainPanel(
        width=10,
        verbatimTextOutput(ns("res")),
        fluidRow(
          column(width=12, h4("Added Rows"), tableOutput(ns("saved_table")))
        ),
        fluidRow(
          column(width=12, tags$div(style = "color: blue; margin-bottom: 10px;", textOutput(ns("interpretation"))))
        ),
        fluidRow(
          column(width=6, plotlyOutput(ns("tpPlot"), width=400, height=400)),
          column(width=6, h4("All Correlation Values"), tableOutput(ns("all_rho_table")))
        )
      )
    )
  )
}

# Server
gstTippingPoint_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns

      base_rho_vec <- seq(0, 1, by = 0.1)

      user_rho <- reactive({
        validate(
          need(
            !is.null(input$rho) && (input$rho >= 0 & input$rho <= 1),
            "Please choose a correlation between 0 and 1"
          )
        )
        input$rho
      })

      saved_table <- reactiveVal(
        tibble(
          ES1 = numeric(0),
          Rho = numeric(0),
          TippingPoint = numeric(0)
        )
      )

      current_selected_row <- reactive({
        tp_value <- (sqrt(2*(1 + user_rho())) - 1) * input$ep1_es
        tibble(
          ES1 = input$ep1_es,
          Rho = user_rho(),
          TippingPoint = round(tp_value, 2)
        )
      })


      all_rho_table_data <- reactive({
        req(user_rho())
        req(input$ep1_es)
        plot_rho_vec <- sort(unique(c(base_rho_vec, user_rho())))
        tp_values <- (sqrt(2 * (1 + plot_rho_vec)) - 1) * input$ep1_es
        tibble(
          ES1 = rep(input$ep1_es, length(plot_rho_vec)),
          Rho = plot_rho_vec,
          TippingPoint = tp_values,
          Selected = ifelse(abs(plot_rho_vec - user_rho()) == 0, "Selected", "")
        )
      })

      output[["res"]] <- renderPrint({
        tp <- (sqrt(2*(1+user_rho())) - 1) * input$ep1_es
        cat("Tipping point for Endpoint 2 effect size at selected Rho:\n")
        cat(round(tp, 3), "\n")
      })

      output[["tpPlot"]] <- renderPlotly({
        validate(
          need(
            !is.null(input$ep1_es) && is.numeric(input$ep1_es),
            "Please choose a value for Endpoint 1 Effect Size"
          )
        )
        plot_rho_vec <- sort(unique(c(base_rho_vec, user_rho())))
        tp <- (sqrt(2 * (1 + plot_rho_vec)) - 1) * input$ep1_es
        df <- tibble(rho = plot_rho_vec, TippingPoint = round(tp, 2))

        closest_index <- which.min(abs(plot_rho_vec - user_rho()))
        TP_Rho <- round(tp[closest_index], 2)

        p1 <- ggplot(df, aes(x = rho, y = TippingPoint)) +
          geom_line(color = "blue") +
          geom_point() +
          geom_point(data = dplyr::filter(df, rho == user_rho()), color = "red", size = 4) +
          theme_bw() +
          ylab("Tipping Point") +
          xlab("Correlation") +
          geom_vline(xintercept = user_rho(), color = "red", linetype = "dashed", linewidth = 1) +
          annotate("text", x = user_rho(), y = TP_Rho,
                   label = paste0("Tipping point ES2=", TP_Rho),
                   color = "black", vjust = -1)

        ggplotly(p1)
      })

      observeEvent(input$add_row, {
        tbl <- saved_table()
        new_row <- current_selected_row()
        saved_table(bind_rows(tbl, new_row))
      })

      observeEvent(input$clear_table, {
        saved_table(
          tibble(
            ES1 = numeric(0),
            Rho = numeric(0),
            TippingPoint = numeric(0)
          )
        )
      })

      output[["saved_table"]] <- renderTable({
        saved_table()
      }, digits = 2)

      # -- show # of digits in table based on the length of user-input correlation
      n_digits <- reactive({
        req(user_rho())
        d <- stringr::str_split(user_rho(), stringr::fixed("."))[[1]] |>
          tail(1) |>
          nchar()
        max(c(d, 2))   # never go below 2 digits!
      })
      output[["all_rho_table"]] <- renderTable({
        all_rho_table_data()
      }, digits = n_digits)

      output[["interpretation"]] <- renderText({
        plot_rho_vec <- sort(unique(c(base_rho_vec, user_rho())))
        tp <- (sqrt(2 * (1 + plot_rho_vec)) - 1) * input$ep1_es
        closest_index <- which.min(abs(plot_rho_vec - user_rho()))
        TP_Rho <- round(tp[closest_index], 2)
        paste0("tipping point for Effect Size (EP2): ", TP_Rho, ", such that the joint endpoint effect size to dips\n               below the first (larger) effect size of ", input$ep1_es, " from Endpoint 1.")
      })
    }
  )
}
