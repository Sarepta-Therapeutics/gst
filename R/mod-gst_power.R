#' Sidebar Effect Size UI
#'
#' This module is for computing GST Power for >=2 joint
#' endpoints based on O-Brien OLS
#'
#' @param id namespaced ID (character/scalar)
#'
#' @import shiny
#' @import rhandsontable
#' @importFrom DT DTOutput
#'
#' @export
esWidgetUI <- function(id) {
  ns <- NS(id)

  card(
    card_header(
      class = "d-flex justify-content-between",
      "Power Analysis Results",
      downloadLink(ns("download"), style = "color:#FFF")
    ),
    full_screen = TRUE,
    layout_sidebar(

      sidebar = sidebar(
        width = 500,

        h5("Step 1: Set number of endpoints (m)"),
        sliderInput(
          ns("numberEP"),
          "Number of Endpoints",
          value = 2,
          min = 2,
          max = 8,
          step = 1
        ),

        #hr(style = "border-top: 1px solid black;"),
        h5("Step 2: Enter effect sizes"),
        uiOutput(ns("sUI")),


        #hr(style = "border-top: 1px solid black;"),
        h5("Step 3: Enter correlation matrix, only upper triangular needed"),

        rHandsontableOutput(ns("corMatrix")),
        textOutput(ns("errorMsg")),

        #hr(style = "border-top: 1px solid black;"),
        h5("Step 4: Enter other assumptions"),

        fluidRow(
          column(
            width = 6,
            numericInput(
              ns("n0"),
              "# Patients in pcb arm (n0)",
              value = 66,
              min = 10,
              step = 5
            ) ),
          column(
            width = 6,
            numericInput(
              ns("n1"),
              "# Patients in trt arm (n1)",
              value = 132,
              min = 10,
              step = 5
            )
          ),
          column(
            width = 6,
            numericInput(
              ns("alpha"),
              "2-side alpha",
              value = .05,
              min = .025,
              max = .2,
              step = .005
            )
          ),
          column(
            width = 6,
            selectInput(
              ns("method"),
              "Method:",
              choices = c("OLS" =  "ols", "GLS" = "gls"),
              selected = "ols"
            )
          ),
          column(
            width = 12,
            selectInput(
              ns("df"),
              "Degrees of freedom:",
              choices = c(
                "Dallow (2008): n0 + n1 - 2 " = "vd",
                "O'Brien (1984): n0 + n1 - 2*m" = "vob",
                "Logan and Tamhane (2004): (n0 + n1 - 2)/2*(1 + 1/m^2)" = "vlt"
              ),
              selected = "vd"
            )
          )
        ),
        # numericInput(
        #   ns("Nsim"),
        #   "Number of simulations",
        #   value = 50,
        #   min = 1,
        #   max = 100, # limit the use of simulation for now
        #   step = 100
        # ),

        #hr(style = "border-top: 1px solid black;"),
        h5("Click on Calculate button"),
      #   actionButton(ns("run"), "Calculate GST Power", style = "color: white; background-color: #661b62; padding: 5px 20px; border: none;"),
      #   actionButton(ns("clear"), "Clear Table", style = "color: white; background-color: #CDA349; padding: 5px 20px; border: none;")
      # ),
      #
      fluidRow(
        column(6,
               actionButton(ns("run"), "Calculate GST Power",
                            style = "color: white; background-color: #349B6A; padding: 5px 20px; border: none; width: 100%;")
        ),
        column(6,
               actionButton(ns("clear"), "Clear Table",
                            style = "color: white; background-color: #CDA349; padding: 5px 20px; border: none; width: 100%;")
        )
      )


    ),
    reactable::reactableOutput(ns("powerTable"))
  )
  )
}


#' Sidebar Effect Size Server
#'
#' @param id namespaced ID (character/scalar)
#'
#' @import shiny
#' @import rhandsontable
#' @importFrom DT renderDT datatable
#'
#' @export
#'
#' @importFrom rlang .data
esWidgetServer <- function(id) {
  moduleServer(id, function(input, output, session, ...) {
    ns <- session$ns

    output$sUI <- renderUI({
      ui_tags <- tagList()

      for (i in 1:input$numberEP) {
        ui_tags <- ui_tags %>%
          tagAppendChild(
            column(
              width = 4,
              numericInput(
                ns(paste0("EP", i)),
                paste0("Endpoint ", i),
                step = .01,
                min = .1,
                max = 3,
                value = .5
              )
            )
          )
      }

      fluidRow(ui_tags)

    })

    corMatrix <- reactiveVal()
    rv <- reactiveValues(lambda = NULL, R = NULL)

    observe({
      req(input$numberEP)
      cor <- data.frame(diag(rep(1, input$numberEP)),
                        stringsAsFactors = FALSE)

      names(cor) <- paste0("EP", 1:input$numberEP)
      row.names(cor) <- paste0("EP", 1:input$numberEP)
      corMatrix(cor)

    })

    # Observe changes in the table and update the matrix accordingly
    observeEvent(input$corMatrix$changes, {
      changes <- input$corMatrix$changes
      if (!is.null(changes)) {
        for (change in changes$changes) {
          row <- change[[1]] + 1  # Convert from 0-indexed to 1-indexed
          col <- change[[2]] + 1
          value <- as.numeric(change[[4]])

          # Update the lower triangular part of the matrix
          if (row < col) {
            updatedMatrix <- corMatrix()
            updatedMatrix[col, row] <- value
            updatedMatrix[row, col] <-
              value  # Update the symmetric value
            corMatrix(updatedMatrix)
          }
        }
      }
    }, ignoreNULL = FALSE)

    # Heatmap renderer with readable text color
    heatmapRenderer <-
      "function (instance, td, row, col, prop, value, cellProperties) {
    Handsontable.renderers.TextRenderer.apply(this, arguments);
    value = parseFloat(value);
    var color = 'white';
    var textColor = 'black';
    if (!isNaN(value)) {
      if (value < 0) {
        color = 'rgba(0, 0, 255, ' + Math.abs(value) + ')';
        textColor = (Math.abs(value) > 0.5) ? 'white' : 'black'; // Adjust for readability
      } else {
        color = 'rgba(255, 0, 0, ' + value + ')';
      }
    }
    td.style.background = color;
    td.style.color = textColor;
    if (row >= col) {
      cellProperties.readOnly = true; // Make cell read-only
      td.style.background = '#EEEEEE'; // Grey out read-only cells
      td.style.color = 'black'; // Text color for grey cells
    }
  }"

    # Render the Handsontable
    output$corMatrix <- renderRHandsontable({
      req(corMatrix())

      cn <- names(corMatrix())
      rh <- rhandsontable(corMatrix(), readOnly = FALSE,stretchH = "all") %>%
        hot_validate_numeric(
          cols = cn,
          min = -1,
          max = 1 ,
          allowInvalid = T
        )

      ncols <- ncol(corMatrix())
      # Apply the heatmap renderer to each column
      for (col in seq_len(ncols)) {
        rh <- hot_col(rh, col, renderer = heatmapRenderer)
      }
      rh
    })


    # Observe changes in the table for validation
    observeEvent(input$corMatrix, {
      df <- data.frame(Value = c(as.matrix(corMatrix())))
      if (any(is.na(df$Value)) ||
          any(df$Value < -1) || any(df$Value > 1)) {
        # Display an error message
        output$errorMsg <-
          renderText("Error: All values must be between -1 and 1 and non-NA.")
      } else {
        output$errorMsg <- renderText("")

      }
    })


    # main panel

    data_df <- reactiveVal(data.frame())

    observeEvent(input$run, {
      req(corMatrix())
      rv$lambda <-
        unlist(purrr::map_dbl(1:input$numberEP, ~ input[[paste0("EP", .x)]]))
      rv$R <- as.matrix(corMatrix())
      OES = get_oes(
        lambda = rv$lambda,
        R = rv$R,
        method = input$method
      )

      ### df
      df <- switch(
        input$df,
        "vd" = input$n0 + input$n1 - 2,
        "vob" = input$n0 + input$n1 - 2 * input$numberEP,
        "vlt" = round((input$n0 + input$n1 - 2) / 2 * (1 + 1 / (
          input$numberEP
        ) ^ 2))
      )

      power_cal = get_power(
        n0 = input$n0 ,
        n1 = input$n1,
        df = df,
        oes = OES,
        alpha = input$alpha
      )

      power_plus <-
        obrien_plus(
          n1 = input$n0,
          n2 = input$n1,
          df = df,
          es_ind = rv$lambda,
          cor_mtx = rv$R,
          method = input$method,
          alpha = input$alpha / 2,
          one_sided = TRUE
        )

      # power_sim = sim_power(
      #   n0 = input$n0,
      #   n1 = input$n1,
      #   lambda = rv$lambda,
      #   R = rv$R,
      #   N = input$Nsim,
      #   method = input$method,
      #   alpha = input$alpha,
      #   ncore = 4
      # )
      power_uniMax = pwr::pwr.t2n.test(
        d = max(rv$lambda),
        n1 = input$n0,
        n2 = input$n1,
        sig.level = input$alpha
      )$power


      #esWidgetUI
      rs <- tibble::tibble(
        OES = round(OES, 2),
        #cor = paste("{", paste(rv$R[upper.tri(rv$R)], collapse = ", "), "}"),
        Correlation = list(rv$R),
        Method = toupper(input$method),
        n_pcb = input$n0,
        n_trt = input$n1,
        alpha = input$alpha,
        DoF = df,
        GST = round(power_cal, 2),
        Uni_Max = round(power_uniMax, 2),
        GST_Any = round(power_plus$power_joint_any, 2)
        #Power_Sim = round(power_sim, 2),
        #Num_sim = round(input$Nsim)
      )


      for (i in 1:input$numberEP) {
        rs[paste0("EP", i)] <- input[[paste0("EP", i)]]
      }


      data_df(bind_rows(data_df(), rs) %>%
                relocate(starts_with("EP"), .before = 1))
    })


    output[["powerTable"]] <- reactable::renderReactable({

      validate(
        need(
          nrow(data_df()) > 0,
          "Waiting for GST Power Calculation results..."
        )
      )

      id <- which(names(data_df()) == "OES") - 1
      reactable::reactable(
        data_df(),
        resizable = TRUE,
        bordered = TRUE,
        columns = list(
          Correlation = reactable::colDef(
            minWidth = 200,
            cell = function(value) {
              htmltools::tags$pre(paste(utils::capture.output(print(value)), collapse = "\n"))
            }),
          GST = reactable::colDef(
            format = reactable::colFormat(percent = TRUE, digits = 0)
          ),
          Uni_Max = reactable::colDef(
            format = reactable::colFormat(percent = TRUE, digits = 0)
          ),
          GST_Any = reactable::colDef(
            format = reactable::colFormat(percent = TRUE, digits = 0)
          )
        ),
        columnGroups = list(
          reactable::colGroup(name = "Endpoint Details", columns = c(paste0("EP", 1:id), "OES", "Correlation")),
          reactable::colGroup(name = "Assumptions", columns = c("Method", "n_pcb", "n_trt", "alpha", "DoF")),
          reactable::colGroup(name = "Power", columns = c("GST", "Uni_Max", "GST_Any"))
        )
      )
    })

    # Clear the table
    observeEvent(input$clear, {
      data_df(data.frame())
    })

    # Download table
    output$download <- downloadHandler(
      filename = function() {
        paste("gst_power_results_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        req(nrow(data_df()) > 0)
        data_df() |>
          dplyr::mutate(
            Correlation =
              purrr::map_chr(
                .data$Correlation,
                ~paste("{", paste(.x[upper.tri(.x)], collapse = ", "), "}")
              )
          ) |>
          dplyr::rename(
            Power_GST = .data$GST,
            Power_Uni_Max = .data$Uni_Max
          ) |>
          readr::write_csv(
            file,
            na = ""
          )
      }
    )
  })
}
