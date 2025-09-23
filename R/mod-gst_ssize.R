#' OLS Power UI
#'
#' This module is for GST 2-endpoint module
#'
#' @param id namespaced ID (character/scalar)
#'
#' @import shiny
#' @import bslib
#' @importFrom DT DTOutput
#' @importFrom plotly plotlyOutput
#'
#' @export
power2_ui <- function(id) {
  ns <- NS(id)
  theme = bs_theme(version = 5, bootswatch = "flatly")
  layout_column_wrap(
    width = 1 / 2,
    #height = 400,
    min_height = 800,
    card(
      full_screen = TRUE,
      card_header("Operating Effect Size"),
      layout_sidebar(
        sidebar = sidebar(
          title = "options",
          open = TRUE,
          selectInput(
            ns("mth"),
            "Method:",
            choices = c("OLS" =  "ols", "GLS" = "gls"),
            selected = "ols"
          ),
          numericInput(
            ns("rho"),
            "Correlation",
            value = .3,
            min = -0.9,
            max = 1,
            step = .1
          )
        ),
        plotlyOutput(ns("oes_plot"))
      )
    ),
    card(
      full_screen = TRUE,
      card_header("P-value combination"),
      layout_sidebar(
        sidebar = sidebar(
          title = "options",
          open = TRUE,
          numericInput(
            ns("rho1"),
            "Correlation",
            value = .5,
            min = -0.9,
            max = 1,
            step = .1
          ),
          selectInput(
            ns("mthd2"),
            "Methods",
            choices = c(
              "Fisher's method" = "fisher",
              "Stouffer's method" = "stouffer"
            ),
            selected = "fisher"
          )
        ),
        plotlyOutput(ns("pv_plot"))
      )
    ),

    card(
      full_screen = TRUE,
      card_header("Power"),
      layout_sidebar(
        sidebar = sidebar(
          title = "options",
          open = TRUE,
          numericInput(
            ns("n0"),
            "n in pcb",
            value = 50,
            min = 10,
            step = 5
          ),
          numericInput(
            ns("n1"),
            "n in trt",
            value = 43,
            min = 10,
            step = 5
          ),
          numericInput(
            ns("alpha"),
            "2-side alpha",
            value = .05,
            min = .025,
            max = .2,
            step = .005
          ),
          selectInput(
            ns("df"),
            "Degrees of freedom:",
            choices = c(
              "Dallow (2008)" = "vd",
              "O'Brien (1984)" = "vob",
              "Logan and Tamhane (2004)" = "vlt"
            ),
            selected = "vd"
          ),
          sliderInput(
            ns("oes_range"),
            "OES Range",
            min = .1,
            max = 2,
            value = c(.1, 1)
          )
        ),
        plotlyOutput(ns("power_plot"))
      )
    ),



    card(
      full_screen = TRUE,
      card_header("Sample Size"),
      layout_sidebar(
        sidebar = sidebar(
          title = "options",
          open = TRUE,
          numericInput(
            ns("es0"),
            "Endpoint1",
            value = .5,
            min = -0.9,
            max = 2,
            step = .1
          ),
          numericInput(
            ns("es1"),
            "Endpoint2",
            value = .5,
            min = -0.9,
            max = 2,
            step = .1
          ),
          numericInput(
            ns("rho3"),
            "Correlation",
            value = .5,
            min = -0.9,
            max = 2,
            step = .1
          ),
          numericInput(
            ns("kk"),
            "trt:pcb ratio",
            value = 1,
            min = 0.1,
            max = 5,
            step = 1
          ),
          numericInput(
            ns("pwr"),
            "Target power",
            value = .8,
            min = 0.2,
            max = 1,
            step = .1
          ),
          selectInput(
            ns("df2"),
            "Degrees of freedom:",
            choices = c(
              "Dallow (2008)" = "vd",
              "O'Brien (1984)" = "vob",
              "Logan and Tamhane (2004)" = "vlt"
            ),
            selected = "vd"
          ),
          selectInput(
            ns("mth3"),
            "Method:",
            choices = c("OLS" =  "ols", "GLS" = "gls"),
            selected = "ols"
          ),
        ),
        plotlyOutput(ns("tp_plot")),
        verbatimTextOutput(ns("res")),
      )
    )
  )


}





#' OLS Power Server
#'
#' @param id namespaced ID (character/scalar)
#'
#' @import shiny
#' @import plotly
#' @import dplyr
#'
#' @importFrom DT renderDT datatable
#'
#' @export
#'
#' @importFrom rlang .data
power2_sever <- function(id) {
  moduleServer(id,function(input, output, session) {

    output$oes_plot = renderPlotly({
      es <- seq(0, 1.5, by = .05)
      d <- expand.grid(d1 = es, d2 = es) %>%
        filter(
          !(.data$d1 == 0 & .data$d2 == 0)
        ) %>%
        rowwise() %>%
        mutate(
          oes =
            get_oes(
              c(.data$d1, .data$d2),
              method = input$mth,
              R = cor_cs(input$rho, 2)
            )
        ) %>%
        ungroup()

      plot_ly(
        data = d,
        x = ~ d1,
        y = ~ d2,
        z = ~ oes,
        type = "contour",
        contours = list(
          start = 0.1,
          end = 1.5,
          size = 0.1,
          showlabels = TRUE,
          labelfont = list(size = 12, color = "white")
        ),
        hovertemplate = paste(
          'Effect Size 1: %{x}',
          '<br>Effect Size 2: %{y}',
          '<br>GST OES: %{z:.2f}<extra></extra>'
        ),
        colorbar = list(title = "OES")
      ) %>%
        layout(
          title = "Contour Plot of Operating Effect Size (OES)",
          xaxis = list(title = "Effect Size 1"),
          yaxis = list(title = "Effect Size 2"),
          hoverlabel = list(font = list(
            family = 'Courier New',
            size = 12,
            color = 'white'
          ))
        )
    })


    output$power_plot = renderPlotly({
      oes <- seq(input$oes_range[1], input$oes_range[2], by = .01)
      df <-
        switch(
          input$df,
          "vd" = input$n0 + input$n1 - 2,
          "vob" = input$n0 + input$n1 - 2 * 2,
          "vlt" = round((input$n0 + input$n1 - 2) / 2 * (1 + 1 / 4))
        )

      power <-
        get_power(
          n0 = input$n0 ,
          n1 = input$n1,
          df = df,
          oes = oes,
          alpha = input$alpha
        )

      tibble(oes, power) |>
        plot_ly(
          x = ~ oes,
          y = ~ power,
          type = 'scatter',
          mode = 'lines'
        ) |>
        layout(
          title = "Power Curves VS OES",
          xaxis = list(title = "OES"),
          yaxis = list(title = "Power"),
          hoverlabel =
            list(
              font =
                list(
                  family = 'Courier New',
                  size = 12,
                  color = 'white'
                )
            )
        )



    })



    output$pv_plot = renderPlotly({
      pv <- seq(0, 1, by = 0.01)
      rho <- c(input$rho1)

      df <- expand.grid(p1 = pv, p2 = pv) %>%
        as_tibble() %>%
        rowwise() %>%
        mutate(
          p3 =
            p_combine(
              p = c(.data$p1, .data$p2),
              R = cor_cs(rho, 2),
              method = input$mthd2
            )
        )
      z <- matrix(df$p3, nrow = length(pv), ncol = length(pv))

      t1 <- c(0, 0.01, 0.025, 0.05, 0.1, 0.3, 0.5, 0.8, 1)
      tick_positions <- sqrt(t1)
      tick_labels <- as.character(t1)

      plot_ly(
        x = ~ sqrt(pv),
        y = ~ sqrt(pv),
        z = ~ z,
        type = "contour",
        contours = list(
          start = 0,
          end = 1,
          size = 0.01,
          showlabels = F
        )

      ) |>
        add_contour(
          ncontours = 1,
          contours =
            list(
              start = 0.05,
              end = 0.05,
              showlabels = TRUE,
              showlines = TRUE,
              coloring = "lines"
            ),
          showlegend = F
        ) |>
        add_contour(
          ncontours = 1,
          contours =
            list(
              start = 0.01,
              end = 0.01,
              colorscale = 'reds',
              showlabels = TRUE,
              showlines = TRUE,
              coloring = "lines"
            ),
          showlegend = F
        ) |>
        layout(
          title = "P-value Combination",
          hoverlabel =
            list(
              font =
                list(
                  family = 'Courier New',
                  size = 12,
                  color = 'white'
                )
            ),
          xaxis =
            list(
              title = "p-value in endpoint 1",
              tickvals = tick_positions,
              ticktext = tick_labels,
              range = c(0, 1),
              type = "linear"
            ),
          yaxis =
            list(
              title = "p-value in endpoint 2",
              tickvals = tick_positions,
              ticktext = tick_labels,
              range = c(0, 1),
              type = "linear"
            )
        ) |>
        add_segments(
          x = sqrt(0.05),
          xend = sqrt(0.05),
          y = 0,
          yend = 1,
          line =
            list(
              dash = "dash",
              width = 1,
              color = "white"
            ),
          inherit = FALSE,
          showlegend = F
        ) |>
        add_segments(
          x = 0,
          xend = 1,
          y = sqrt(0.05),
          yend = sqrt(0.05),
          line =
            list(
              dash = "dash",
              width = 1,
              color = "white"
            ),
          inherit = FALSE,
          showlegend = F
        )  |>
        hide_guides()
    })


    output$tp_plot = renderPlotly({
      df = switch(
        input$df2,
        "vd" = input$n0 + input$n1 - 2,
        "vob" = input$n0 + input$n1 - 4,
        "vlt" = round((input$n0 + input$n1 - 2) / 2 * (1 + 1 / 4))
      )

      nn_rv = get_n(
        power = input$pwr,
        es0 = input$es0,
        es1 = input$es1,
        alpha = input$alpha,
        R = cor_cs(input$rho3, 2),
        k = input$kk,
        method = input$method,
        df_method = input$df2,
        n0_range = c(5, 1000)
      )

      n0 = nn_rv$n0
      n1 = nn_rv$n1


      n_seq = seq(1, max(n0, n1) * 2, 1)
      oes = get_oes(c(input$es0, input$es1),
                    R = cor_cs(input$rho3, 2),
                    method = input$mth3)
      power = get_power(
        oes,
        n0 = n_seq,
        n1 = n_seq * input$kk,
        df = df,
        alpha = input$alpha
      )


      pww = get_power(
        oes = oes,
        n0 = n0,
        n1 = n1,
        df = df,
        alpha = input$alpha
      )

      #pww = get_power(oes = oes,n0 = n0,n1=n1,alpha = 0.05)
      tx = paste(
        "sample size in pcb:",
        n0,
        "\n",
        "sample size in trt:",
        n1,
        "\n",
        "operating effect size:",
        round(oes, 3),
        "\n",
        "power:",
        round(pww, 3)
      )

      plot_ly(
        x = n_seq,
        y = power,
        type = 'scatter',
        mode = 'lines+points'
      ) |>
        add_segments(
          x = n0,
          xend = n0,
          y = 0,
          yend = 1,
          line = list(
            dash = "dash",
            width = 1,
            color = "red"
          ),
          inherit = FALSE,
          showlegend = F
        ) |>
        layout(
          title = "Power VS Sample Size",
          hoverlabel = list(font = list(
            family = 'Courier New',
            size = 12,
            color = 'white'
          )),
          xaxis = list(title = "N in Placebo"),
          yaxis = list(title = "Power")
        ) |>
        add_annotations(
          x = max(n_seq),
          y = 0.5,
          text = tx,
          showarrow = FALSE,
          xanchor = 'right',
          yanchor = 'bottom',
          xref = 'x',
          yref = 'y',
          font = list(size = 15)
        )

    })

  })
}
