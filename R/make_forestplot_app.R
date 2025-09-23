#' A Shiny app to make a forest plot
#'
#' @param runApp should the app be run on completion, default is TRUE
#' @param plot_width Width of the plot in pixels, default is 1200
#' @param plot_height Height of the plot in pixels, default is 800
#'
#' @return A Shiny app
#' @export
#'
#' @importFrom grDevices png dev.off
#'
#' @examples
#' if (interactive()) {
#'   make_forestplot_app()
#' }
make_forestplot_app <- function(runApp=TRUE, plot_width=1000, plot_height=500) {

  # Define default data
  default_data <- forest_data()


  sar_purple <- '#661b62'

  app <- shiny::shinyApp(

    # Define UI
    ui = shiny::tagList(
      rclipboard::rclipboardSetup(),
      page_navbar(
        id = "master_nav",
        title =
          div(
            style = "display: flex; align-items: center; margin-bottom: -32px; margin-right: 20px",
            img(
              src = "www/logo.png",
              style = "width: 40px; margin-right: 10px"
            ),
            h3(strong("Make Forestplot App"), style = "margin-bottom:0px; margin-top:0px")
          ),
        # -- customize boostrap theme
        theme = bs_theme(
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
          "input-border-color" = "rgb(134, 202, 198)",
          "navbar-bg" = "white",
          "navbar-dark-color" = sar_purple,
          "nav-link-padding-y" = "0.2rem",
          "tooltip-opacity" = 1
        ),

        # -- include CSS and JS files
        header = tags$head(
          htmltools::htmlDependency(
            name = "gst",
            package = "gst",
            version = utils::packageVersion("gst"),
            src = "www",
            script = paste0(
              "js/",
              list.files(app_sys("www/js"), pattern = ".js$")
            ),
            stylesheet = paste0(
              "css/",
              list.files(app_sys("www/css"), pattern = ".css$")
            )
          )
        ),

        # -- main content
        nav_panel(
          title = "Forest Plot",

          # layout_sidebar(
          #
          #   # -- left sidebar (data input)
          #   sidebar = sidebar(
          #     title = "Input Data",
          #     position = "left",
          #     open = TRUE,
          #     width = "25%",
          #     accordion(
          #       id = "data_input_method",
          #       multiple = FALSE,
          #
          #       # --- (Method 1) Manually enter data
          #       accordion_panel(
          #         title = "Option 1: Manual Data Entry",
          #         value = "manual",
          #         icon = icon("table"),
          #         div(style = "display: flex; align-items: center;",
          #             bslib::tooltip(
          #               bsicons::bs_icon("info-circle", size = "1.5em"),
          #               "Click cell to edit; drag rows to reorder; add/remove rows by setting number or using the right-click menu"
          #             ),
          #             " Enter the data for ",
          #             bsicons::bs_icon("tree-fill", size = "2em") |> bslib::tooltip("Number of Trees in Forest") ,
          #             bsicons::bs_icon("x", size = "2em"),
          #             numericInput("numTrees", label = NULL, 9, min = 1, max = 20, width = "25%"),
          #         ),
          #         rHandsontableOutput("hot", width = "100%")
          #         # div(
          #         #   style = "height: 250px; overflow-y: auto; overflow-x: hidden;",
          #         #   rHandsontableOutput("hot", width = "100%")
          #         # )
          #       ),
          #
          #       # --- (Method 2) Upload data
          #       accordion_panel(
          #         title = "Option 2: Upload CSV",
          #         value = "upload",
          #         icon = icon("upload"),
          #         fileInput("file1",
          #                   tags$span("Choose CSV File (", downloadLink("template", tags$span("template ", icon("download"))), ")"),
          #                   accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
          #         uiOutput("import_status"),
          #         br(),
          #         rHandsontableOutput("import_preview")
          #       )
          #
          #
          #     )
          #   ),

          # -- right sidebar (plot options)
          layout_sidebar(
            sidebar = sidebar(
              title = "Options",
              position = "right",
              open = TRUE,
              width = 300,

              tags$span(
                style = "margin-bottom: -20px; margin-top: -30px",
                ""
              ),

              accordion(
                multiple = FALSE,
                open = NULL,
                accordion_panel(
                  "Required",
                  icon = bsicons::bs_icon("exclamation-octagon"),
                  bslib::input_switch(
                    "flip_arrows",
                    label = tooltip_label(
                      "Flip Arrow Labels",
                      info =
                        p(
                          "Flip the directional arrows below the forestplot that indicate which group is better; ",
                          "should only be used if higher values indicate worse outcomes for all endpoints"
                        )
                    ),
                    value = FALSE
                  ),

                  radioButtons(
                    "conf_level",
                    label = tooltip_label(
                      "Confidence Level ",
                      "Must match the confidence level used to compute the input data 'low' and 'high' values"
                    ),
                    inline = TRUE,
                    selected = 0.95,
                    choiceNames = c("90%", "95%", "99%"),
                    choiceValues = c(0.9, 0.95, 0.99)
                  )
                ),
                accordion_panel(
                  "Headers",
                  icon = bsicons::bs_icon("alphabet-uppercase"),
                  textInput(
                    "groupHeader",
                    label = tooltip_label(
                      "Group",
                      "Display name for the 'Group' column in the forest plot"
                    ),
                    value = "Group"
                  ),
                  textInput(
                    "comparatorHeader",
                    label = tooltip_label(
                      "Comparator",
                      "Display name for the 'Comparator' column in the forest plot"
                    ),
                    value = "Comparator"
                  ),
                  textInput(
                    "controlHeader",
                    label = tooltip_label(
                      "Control",
                      "Display name for the 'Control' column in the forest plot"
                    ),
                    value = "Control"
                  ),
                  textInput(
                    "estHeader",
                    label = tooltip_label(
                      "Estimate",
                      "Display name for the 'Estimate' column in the forest plot"
                    ),
                    value = "LSMeans"
                  ),
                  textInput(
                    "pvalHeader",
                    label = tooltip_label(
                      "P-Value",
                      "Display name for the 'P-Value' column in the forest plot"
                    ),
                    value = "p"
                    ),
                  textInput(
                    "forestHeader",
                    label = tooltip_label(
                      "Forest",
                      "Display name for the 'Forest' column in the forest plot"
                    ),
                    value = "Comparator - Control"
                  )
                ),
                accordion_panel(
                  "Columns",
                  icon = bsicons::bs_icon("arrow-left-right"),
                  bslib::input_switch(
                    "customize_columns",
                    label = tooltip_label(
                      "Customize Columns",
                      "Toggle ON to customize the forest plot display columns and their ordering"
                    ),
                    value = FALSE
                  ),
                  conditionalPanel(
                    condition = "input.customize_columns == true",
                    uiOutput("selected_columns")
                  ),
                  bslib::input_switch(
                    "customize_width",
                    label = tooltip_label(
                      "Customize Widths",
                      "Toggle ON to customize the width of the forest plot display columns"
                    ),
                    value = FALSE
                  ),
                  conditionalPanel(
                    condition = "input.customize_width == true",
                    uiOutput("column_widths"),
                  )
                ),
                accordion_panel(
                  "Subgroups",
                  icon = bsicons::bs_icon("layers"),
                  bslib::input_switch(
                    "indentSubgroups",
                    label = tooltip_label(
                      "Indent Subgroups",
                      "Toggle ON to indent all subgroups, as defined below"
                    ),
                    value = TRUE
                  ),
                  conditionalPanel(
                    condition = "input.indentSubgroups == true",
                    textInput(
                      "overallKeyword",
                      label = tooltip_label(
                        "Keyword for nonsubgroups",
                        "Any groups (i.e., 'Group' column) containing this keyword will not be indented"
                      ),
                      value = "overall"
                    )
                  )
                ),
                accordion_panel(
                  "Colors",
                  icon = bsicons::bs_icon("palette"),
                  bslib::input_switch(
                    "colorByEndpoint",
                    label = tooltip_label(
                      "Color by Endpoint",
                      "Toggle ON to add background coloring to rows based on the 'Endpoint' column"
                    ),
                    value = FALSE
                  ),
                  # TODO: add styling
                  strong("Confidence Intervals"),
                  layout_column_wrap(
                    width = NULL,
                    style = htmltools::css(grid_template_columns = "1fr 1fr"),
                    shinyWidgets::colorPickr(
                      "ci_color",
                      label = tooltip_label(
                        "Normal",
                        "Forest plot color to use for normal endpoints"
                      ),
                      selected = "#000",
                      update = "changestop",
                      interaction = list(clear = FALSE, save = FALSE)
                    ),
                    shinyWidgets::colorPickr(
                      "ci_color_inverted",
                      label = tooltip_label(
                        "Inverted",
                        "Forest plot color to use for inverted endpoints"
                      ),
                      selected = "#5826bd",
                      update = "changestop",
                      interaction = list(clear = FALSE, save = FALSE)
                    )
                  )
                ),
                accordion_panel(
                  "Sizing",
                  icon = bsicons::bs_icon("aspect-ratio"),
                  sliderInput(
                    "rowHeight",
                    label = tooltip_label(
                      "Row Height",
                      "Adjust individual row heights for each endpoint in the forest plot"
                    ),
                    min = 1,
                    max = 10,
                    value = 1.75,
                    step = 0.25
                  ),
                  sliderInput(
                    "baseFontSize",
                    label = tooltip_label(
                      "Base Font Size",
                      "Adjust the base font size of the text in the forest plot"
                    ),
                    min = 8,
                    max = 24,
                    value = 14,
                    step = 1
                  ),
                  sliderInput(
                    "footnoteFontSize",
                    label = tooltip_label(
                      "Footnote Font Size",
                      "Adjust the font size of the footnote below the forest plot"
                    ),
                    min = 4,
                    max = 20,
                    value = 10,
                    step = 1
                  ),
                  sliderInput(
                    "ciTheight",
                    label = tooltip_label(
                      "CI T-Height",
                      "Adjust the length of the vertical lines that mark the lower/upper confidence intervals in the forest plot"
                    ),
                    min = 0,
                    max = 1,
                    value = 0.2,
                    step = 0.1
                  )
                ),
                accordion_panel(
                  "Point Estimate",
                  icon = bsicons::bs_icon("circle-fill"),
                  radioButtons(
                    "plot_pch",
                    label = tooltip_label(
                      "Shape",
                      "Adjust the shape used for the forest plot point estimates"
                    ),
                    inline = TRUE,
                    choiceNames = paste0("<span style='font-size:24px;'>&#", c(9632, 9679, 9650, 9670), ";</span>") |> lapply(HTML),
                    choiceValues = c(15, 16, 17, 18)  # square, circle, triangle, diamond
                  ),
                  sliderInput(
                    "plot_point_size",
                    label = tooltip_label(
                      "Size",
                      "Adjust the size of the forest plot point estimates"
                    ),
                    min = 0.1,
                    max = 3,
                    value = 1,
                    step = 0.1
                  )
                ),
                accordion_panel(
                  "Axes",
                  icon = bsicons::bs_icon("arrows-move"),
                  sliderInput(
                    "plot_zoom",
                    label = tooltip_label(
                      "Zoom Level",
                      "Adjust the limits of the forest plot x-axis to control the relative size of the confidence intervals"
                    ),
                    min = 0,
                    max = 100,
                    value = 80,
                    step = 10,
                    post = "%"
                  ),
                  bslib::input_switch(
                    "plot_symmetric",
                    label = tooltip_label(
                      "Symmetric Range",
                      "Toggle ON to force the forest plot x-axis to be symmetric with respect to 0 (i.e., equal length on both sides of 0)"
                    ),
                    value = TRUE
                  ),
                  bslib::input_switch(
                    "plot_x_ticks_toggle",
                    label = tooltip_label(
                      "Customize Forest Ticks",
                      "Toggle ON to manually define x-axis tick marks on the forest plot"
                    ),
                    value = FALSE
                  ),
                  conditionalPanel(
                    condition = "input.plot_x_ticks_toggle == true",
                    textInput(
                      "plot_x_ticks",
                      label = tooltip_label(
                        "Forest Ticks",
                        "Accepts a comma-separated list of tick mark values"
                      ),
                      value = "-0.5, 0, 0.5"
                    )
                  ),
                ),
                accordion_panel(
                  "Arrows",
                  icon = bsicons::bs_icon("arrows"),
                  textInput(
                    "arrow_prefix",
                    label = tooltip_label(
                      "Arrow Prefix",
                      "Set the prefix for each of the forest plot arrows"
                    ),
                    value = "Favors"
                  ),
                  bslib::input_switch(
                    "arrow_custom",
                    label = tooltip_label(
                      "Customize Arrow Labels",
                      "By default, arrow labels are based on the column headers.  Toggle ON to provide custom labels."
                    ),
                    value = FALSE
                  ),
                  conditionalPanel(
                    condition = "input.arrow_custom == true",
                    textInput(
                      "arrow_label_left",
                      label = tooltip_label(
                        "Left Arrow Label",
                        "Customize the text for the left-facing arrow on the forest plot"
                      ),
                      value = ""
                    ),
                    textInput(
                      "arrow_label_right",
                      label = tooltip_label(
                        "Right Arrow Label",
                        "Customize the text for the right-facing arrow on the forest plot"
                      ),
                      value = ""
                    )
                  )
                ),
                accordion_panel(
                  "Statistical",
                  icon = bsicons::bs_icon("calculator"),
                  bslib::input_switch(
                    "standardize_plot",
                    label = tooltip_label(
                      "Standardize Plot",
                      "Toggle ON to standardize forest plots by dividing each by their standard error so all confidence intervals have equal lengths, which can improve interpretability when numeric results are on very different scales"
                    ),
                    value = FALSE
                  ),
                  bslib::input_switch(
                    "digits_toggle",
                    label = tooltip_label(
                      "Rounding",
                      "Toggle ON to round estimates and confidence intervals"
                    ),
                    value = TRUE
                  ),
                  conditionalPanel(
                    condition = "input.digits_toggle == true",
                    sliderInput(
                      "digits",
                      label = tooltip_label(
                        "Number of Digits",
                        "Number of digits to round to for estimates and confidence intervals"
                      ),
                      min = 0,
                      max = 5,
                      value = 2
                    )
                  )
                )

              )
            ),

            # -- main page content (plot preview)

            card(
              full_screen = FALSE,
              card_header(
                "Input data",
                class = "d-flex justify-content-between"
              ),

              accordion(
                id = "data_input_method",
                multiple = FALSE,
                open = FALSE,
                # --- (Method 1) Manually enter data
                accordion_panel(
                  title = "Option 1: Manual Data Entry",
                  value = "manual",
                  icon = icon("table"),
                  card(
                    card_header(
                      popover(
                        span(
                          "Number of Trees ",
                          bsicons::bs_icon("gear")
                        ),
                        div(style = "display: flex; align-items: center;",
                            bsicons::bs_icon("tree-fill", size = "2em") |> bslib::tooltip("Number of Trees in Forest") ,
                            bsicons::bs_icon("x", size = "2em"),
                            numericInput("numTrees", label = NULL, 9, min = 1, max = 20, width = "80px")
                        )
                      ),
                      tooltip_label(
                        "Help",
                        "Click cell to edit; drag rows to reorder; add/remove rows by setting number or using the right-click menu"
                      ),
                      popover(
                        span(
                          "Custom Columns ",
                          bsicons::bs_icon("pencil-square")
                        ),
                        textInput("add_column_name", "New Column Name", value = "Custom1", width = "200px"),
                        actionButton("add_column", "Add Column", icon = icon("plus")),
                        actionButton("remove_column", "Remove Last Column", icon = icon("minus")),
                        placement = "left"
                      ),
                      class = "d-flex justify-content-between"
                    ),
                    rHandsontableOutput("hot", width = "100%")
                  )
                ),

                # --- (Method 2) Upload data
                accordion_panel(
                  title = "Option 2: Upload CSV",
                  value = "upload",
                  icon = icon("upload"),
                  layout_column_wrap(
                    width = 1/2,
                    card(
                      card_header("Upload"),
                      fileInput("file1",
                                tags$span("Choose CSV File (", downloadLink("template", tags$span("template ", icon("download"))), ")"),
                                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
                      uiOutput("import_status")
                    ),
                    card(
                      full_screen = TRUE,
                      card_header("Preview"),
                      rHandsontableOutput("import_preview")
                    )
                  )
                )

            ),


              card(
                full_screen = TRUE,
                height = 600,
                card_header(
                  "Forest Plot Preview",
                  textOutput("data_source"),
                  tags$div(
                    actionLink("show_code", label = HTML('<i class="fa fa-code"></i> R Code')),
                    " | ",
                    actionLink("save_plot", label = HTML('<i class="fa fa-download"></i> Save Plot')),
                    " | ",
                    downloadLink("saveRDS", label = HTML('<i class="fa fa-download"></i> RDS')),
                    " | ",
                    downloadLink("saveCSV", label = HTML('<i class="fa fa-download"></i> CSV'))
                  ),
                  class = "d-flex justify-content-between"
                ),

                plotOutput("forestPlot", height = "100%")

              ),
              border = FALSE
            ),
            border_radius = FALSE,
            fillable = FALSE,
            class = "p-0"
          )
        ),

        nav_spacer(),

        nav_item(
          tags$a(
            shiny::icon("circle-question"),
            "User Guide",
            href = "https://connect.sarepta.com/gst-pkgdown/articles/forestplot.html",
            target = "_blank"
          )
        )

      )
    ),


    # Define server logic
    server = function(input, output, session) {

      rv <- reactiveValues(
        data = default_data,
        headers = c("Endpoint", "Group", "Comparator", "Control", "LSMean", "low", "hi", "p", "invert"),
        headers_updated = 0,
        headers_final = NULL,
        ignore_next_update = FALSE,
        plot_width = 12,
        plot_height = 6,
        data_source = NULL,
        extra_cols = 0,
        n = 0
      )

      # Capture sorted table from rhandsontable and update forest plot order
      observeEvent(input$hot, {
        if (!is.null(input$hot) && !rv$ignore_next_update) {
          new_data <- hot_to_r(input$hot)
          if (!identical(new_data, rv$data)) {
            rv$ignore_next_update <- TRUE
            rv$data <- new_data
            rv$ignore_next_update <- FALSE
          }
        }
      }, ignoreInit = TRUE)

      # data entry table
      output$hot <- renderRHandsontable({
        rv$headers_updated  # Depend on this to trigger updates when headers change
        isolate({
          rhandsontable(rv$data, readOnly = FALSE, width = "100%", height = "100%") %>%
            hot_col(col = rv$headers[1], readOnly = FALSE) %>%
            hot_col(col = rv$headers[2], readOnly = FALSE) %>%
            hot_col(col = rv$headers[3], readOnly = FALSE) %>%
            hot_col(col = rv$headers[4], readOnly = FALSE) %>%
            hot_col(col = rv$headers[5], readOnly = FALSE) %>%
            hot_col(col = rv$headers[6], readOnly = FALSE) %>%
            hot_col(col = rv$headers[7], readOnly = FALSE) %>%
            hot_cols(columnSorting = TRUE) %>%
            hot_table(stretchH = "all", manualRowMove = TRUE)

        })
      })

      # add/remove extra columns
      observeEvent(input$add_column, {
        #rv$data[[paste0("Var", rv$extra_cols + 1)]] <- rep("", nrow(rv$data))
        rv$data[[input$add_column_name]] <- rep("", nrow(rv$data))
        rv$headers_updated <- rv$headers_updated + 1
        rv$extra_cols <- rv$extra_cols + 1
      })
      observeEvent(input$remove_column, {
        id <- ncol(rv$data)
        if (names(rv$data)[id] != "invert")   ## only remove extra columns
          rv$data <- rv$data[-id]
        rv$headers_updated <- rv$headers_updated + 1
        rv$extra_cols <- rv$extra_cols - 1
      })

      # Column Selection
      observeEvent(final_data(), {
        rv$headers_final <- names(final_data())
      })
      output$selected_columns <- renderUI({
        req(rv$headers_final)

        var_choices <- rv$headers_final
        var_choices <- setdiff(var_choices, c("invert", input$estHeader, "low", "hi"))  # ignore calc-columns
        var_choices <- c(var_choices, "forest", "est+ci")
        var_init <- c(2, 3, 4, which(var_choices == "forest"), which(var_choices == "est+ci"), which(var_choices == input$pvalHeader))

        sortable::bucket_list(
          header = "",
          group_name = "bucket_list_group",
          orientation = "horizontal",
          sortable::add_rank_list(
            text = "Hidden Columns",
            labels = var_choices[-var_init],
            input_id = "hidden_cols"
          ),
          sortable::add_rank_list(
            text = "Display Columns",
            labels = var_choices[var_init],
            input_id = "display_cols"
          )
        )
      })
      # -- column widths
      display_cols <- reactiveVal()
      observeEvent(c(input$display_cols, input$customize_columns), {
        if (input$customize_columns) {
          display_cols(input$display_cols)
        } else {
          display_cols(c("Group", "Comparator", "Control", "forest", "est+ci", "p"))
        }
      })
      output$column_widths <- renderUI({
        layout_column_wrap(
          width = 1/2,
          !!!purrr::map(
            seq_along(display_cols()),
            function(i)
              numericInput(
                paste0("width_", i),
                label = tooltip_label(
                  display_cols()[i],
                  paste0("Display width for the '", display_cols()[i], "' column in the forest plot")
                ),
                value = 0.15,
                min = 0.05,
                max = 0.5,
                step = 0.05
              )
          )
        )
      })
      display_widths <- reactive({

        if (input$customize_width) {
          x <-
            purrr::map_dbl(
              seq_along(display_cols()),
              function(i)
                req(input[[paste0("width_", i)]])
            )
        } else {
          x <- NULL
        }
        x
      })

      # Update size of data-entry table
      n_trees <- reactive(input$numTrees) |> debounce(500)

      observeEvent(n_trees(), {
        req(is.numeric(n_trees()) && n_trees() >= 0)
        numTrees <- n_trees()
        current_names <- rv$headers

        if (numTrees > nrow(rv$data)) {
          additional_rows <- numTrees - nrow(rv$data)
          new_data <- rbind(rv$data,
                            data.frame(matrix(NA,
                                              nrow = additional_rows,
                                              ncol = ncol(rv$data),
                                              dimnames = list(NULL, current_names))))
        } else {
          new_data <- rv$data[1:numTrees, ]
        }
        rownames(new_data) <- 1:nrow(new_data)   # handle row-numbering issues
        rv$data <- new_data
        rv$headers_updated <- rv$headers_updated + 1  # Add this line to trigger table update
      })

      # Keep `# Trees` input in-sync with rhandsontable size
      observeEvent(input$hot, {
        df <- hot_to_r(input$hot)
        if (input$numTrees != nrow(df))
          updateNumericInput(session, "numTrees", value = nrow(df))
      })

      # Import data from CSV file
      uploaded_data <- reactive({
        inFile <- input$file1
        tryCatch({
          forest_import_csv(inFile$datapath)
        },
        error = function(e) {
          NULL
        })
      })
      # -- update headers based on csv file
      observeEvent(uploaded_data(), {
        nms <- names(uploaded_data())
        updateTextInput(session, "groupHeader", value = nms[2])
        updateTextInput(session, "comparatorHeader", value = nms[3])
        updateTextInput(session, "controlHeader", value = nms[4])
        updateTextInput(session, "estHeader", value = nms[5])
        updateTextInput(session, "pvalHeader", value = nms[8])
        updateTextInput(session, "forestHeader", value = paste(nms[3], "-", nms[4]))
      })
      # -- reset custom columns when updating headers (bc headers need to be updated prior to adjusting order)
      core_headers <- reactive({
        c(input$groupHeader, input$comparatorHeader, input$controlHeader, input$pvalHeader)
      })
      observeEvent(core_headers(), ignoreInit = TRUE, {
        if (input$customize_columns) {
          showNotification(
            "Custom column selection is reset when column headers are updated",
            type = "warning"
          )
        }
        update_switch("customize_columns", value = FALSE)
      })

      # User-feedback for data import process
      output$import_status <- renderUI({
        req(nchar(input$file1) > 0)
        if (is.null(uploaded_data())) {
          msg <- tags$div(
            class = "data-import-fail animate pop",
            tags$i(class = "fas fa-multiply"),
            tags$span("Import failed!")
          )
        } else {
          msg <- tags$div(
            class = "data-import-success animate pop",
            tags$i(class = "fas fa-check"),
            tags$span("Import successful!")
          )
        }
        msg
      })

      # Preview the imported data (not editable)
      output$import_preview <- renderRHandsontable({
        validate(
          need(!is.null(uploaded_data()), "Waiting for valid input data...")
        )
        rhandsontable(uploaded_data(), readOnly = TRUE, width = "100%", height = "100%")
      })

      # Track last used data-input-method
      observeEvent(input$data_input_method, ignoreInit = FALSE, ignoreNULL = FALSE, {
        if (!is.null(input$data_input_method))
          rv$data_source <- input$data_input_method
      })
      # -- provide user-feedback on source data (upload or manual)
      output$data_source <- renderText({
        paste0("Input data: ", rv$data_source)
      })

      # Data used for plotting (depends on input method)
      final_data <- reactive({

        validate(
          need(rv$data_source, "Please select a method to input data.")
        )

        # -- target data -- depends on input method
        if (rv$data_source == "manual") {
          df <- rv$data  # Return reactive data (this will reflect the latest sorting)
        } else if (rv$data_source == "upload") {
          validate(
            need(uploaded_data(), "Please select a valid file to import.  If you are having trouble, download the template to see the appropriate format.")
          )
          df <- uploaded_data()
        }

        # -- handle missing data; set default values
        df <- df %>%
          dplyr::filter(
            dplyr::if_any(
              -"invert",                          # ignore 'invert' (logical)
              function(x) !is.na(x) & x != ""     # remove rows with all NA
            )
          ) %>%
          dplyr::mutate(
            invert = dplyr::coalesce(as.logical(.data$invert), F)   # replace missing 'invert' with FALSE
          )

        # update column names (for display)
        names(df)[2] <- input$groupHeader
        names(df)[3] <- input$comparatorHeader
        names(df)[4] <- input$controlHeader
        names(df)[5] <- input$estHeader
        names(df)[8] <- input$pvalHeader

        df
      })

      # suggest forestplot size parameters based {# rows} in the input data
      observeEvent(final_data(), {
        rv$n <- nrow(final_data())
      })
      observeEvent(rv$n, {
        suggested <- final_data() |> forest_suggest_params()
        updateSliderInput(session, "rowHeight", value = suggested$row_height)
        updateSliderInput(session, "baseFontSize", value = suggested$font_size)
        updateSliderInput(session, "footnoteFontSize", value = suggested$footnote_size)
        updateSliderInput(session, "plot_point_size", value = suggested$plot_point_size)
      })

      # customize_digits
      digits <- reactive({
        if (!input$digits_toggle) {
          NULL
        } else {
          input$digits
        }
      })

      # draw forestplot + store as reactive
      # -- forestplot tick marks (user-defined)
      plot_x_ticks <- reactive({
        xt <- NULL
        if (input$plot_x_ticks_toggle) {
          xt <- stringr::str_split(input$plot_x_ticks, ",")[[1]] |>
            stringr::str_trim() |>
            as.numeric()
          xt <- xt[!is.na(xt)]  # ignore non-numeric values (after parsing)
          if (length(xt) == 0)
            xt <- NULL
        }
        xt
      }) |>
        debounce(1000)
      # -- draw forestplot
      plot_data <- reactive({
        req(final_data())
        dt <- final_data()

        validate(
          need(
            !input$customize_columns | length(input$display_cols) >= 2,
            "You must select at least 2 columns to display"
          ),
          need(
            !input$customize_columns | "forest" %in% input$display_cols,
            "You must include 'forest' as a display column."
          )
        )

        p <- gst::forest_plot(
          dt,
          indent_subgroups = input$indentSubgroups,
          indent_keyword = input$overallKeyword,
          standardize_plot = input$standardize_plot,
          flip_arrows = input$flip_arrows,
          font_size = input$baseFontSize,
          footnote_size = input$footnoteFontSize,
          plot_pch = as.numeric(input$plot_pch),
          plot_point_size = input$plot_point_size,
          plot_zoom = input$plot_zoom,
          plot_x_ticks = plot_x_ticks(),
          plot_symmetric = input$plot_symmetric,
          ci_t_height = input$ciTheight,
          ci_color = input$ci_color,
          ci_color_inverted = input$ci_color_inverted,
          row_height = input$rowHeight,
          color_by_endpoint = input$colorByEndpoint,
          significance_level = (1 - as.numeric(input$conf_level)),
          display_cols = if (input$customize_columns) input$display_cols else NULL,
          display_widths = display_widths(),
          forest_label = input$forestHeader,
          digits = digits(),
          arrow_prefix = input$arrow_prefix,
          arrow_label_left = if (input$arrow_custom) input$arrow_label_left else NULL,
          arrow_label_right = if (input$arrow_custom) input$arrow_label_right else NULL
        )

        # get plot dimensions (for saving as png)
        plot_dims <- attr(p, "dims")
        rv$plot_width <- plot_dims[1]
        rv$plot_height <- plot_dims[2]

        return(p)
      })


 #     observeEvent(input$plot, {

        output$forestPlot <- renderPlot({
          # # -- get plot size (pixels) for saving
          # info <- getCurrentOutputInfo()
          # rv$plot_width <- info$width()
          # rv$plot_height <- info$height()

          p <- plot_data()
          p |> need("Waiting for valid input data...") |> validate()
          plot(p)
        # }, width = input$plot_width, height = input$plot_height)
        #
        #
        # output[["forestPanel"]] <- renderUI({
        #
        #   wellPanel(plotOutput("forestPlot", width = input$plot_width, height = input$plot_height) )

        })

  #    })

      # download input data as RDS file
      output$saveRDS <- downloadHandler(
        filename = function() {
          paste("forest_data", Sys.Date(), ".rds", sep = "")
        },
        content = function(file) {
          saveRDS(final_data(), file)
        }
      )

      # download input data as CSV file
      output$saveCSV <- downloadHandler(
        filename = function() {
          paste("forest_data", Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
          readr::write_csv(final_data(), file, na = "")
        }
      )

      # 'Save Plot' Modal
      observeEvent(input$save_plot, {
        showModal(modalDialog(
          title = "Save Forestplot",
          size = "l",
          layout_columns(
            col_widths = c(3, 3, 3, 3),
            numericInput("plot_width", "Width (in.)", min = 1, max = 50, value = round(rv$plot_width, 1), step = 1),
            numericInput("plot_height", "Height (in.)", min = 1, max = 50, value = round(rv$plot_height, 1), step = 1),
            selectInput("file_ext", "Image Format", choices = c("png", "jpeg")),   # NOTE: pdf doesn't work with renderImage()
            downloadButton("plot_save", "Download")
          ),
          plotOutput("plot_preview"),
          easyClose = TRUE,
          footer = NULL
        ))
      })
      # -- render saved ggplot2 (so view mimics downloaded image)
      output$plot_preview <- renderImage(deleteFile = TRUE, {
        tmp_plot <- tempfile(fileext = paste0(".", input$file_ext))
        plot_data() |>
          ggplot2::ggsave(
            filename = tmp_plot,
            width = input$plot_width,
            height = input$plot_height,
            device = input$file_ext,
            units = "in"
          )
        list(
          src = tmp_plot,
          width = "100%",
          height = "100%",
          alt = "Forestplot Preview"
        )
      })
      # -- download plot
      output$plot_save <- downloadHandler(
        filename = function() {
          format(Sys.time(), paste0("forestplot-%y%m%d-%H%M%S.", input$file_ext))
        },
        content = function(file) {
          plot_data() |>
            ggplot2::ggsave(
              filename = file,
              width = input$plot_width,
              height = input$plot_height,
              device = input$file_ext,
              units = "in"
            )
        }
      )

      # Download Template CSV (for import)
      output$template <- downloadHandler(
        filename = function() {
          paste0("forestplot_data_template.csv")
        },
        content = function(file) {
          readr::write_csv(default_data, file, na = "")
        }
      )

      # R Code generator
      plot_code <- reactive({
        req(plot_data())
        plot_data() |>
          forest_reprex(unfold = input$unfold_code)
      })
      output$code <- renderPrint({
        plot_code() |>
          cat(sep = "\n")
      })
      observeEvent(input$show_code, {
        showModal(modalDialog(
          title = "R Code for Forest Plot",
          size = "l",
          bslib::layout_columns(
            col_widths = c(3, -1, 3, -1, 3, -1),
            bslib::input_switch(
              "unfold_code",
              label = tooltip_label(
                "Unfold Code",
                "Toggle to remove dependence on the `gst` package"
              ),
              value = FALSE
            ),
            uiOutput("clip"),
            downloadButton("download_code", label = "Save Code")
          ),
          div(
            style = "overflow-y: scroll; max-height: 400px",
            verbatimTextOutput("code")
          ),
          easyClose = TRUE,
          footer = NULL
        ))
      })
      # -- copy code to clipboard
      output$clip <- renderUI({
        rclipboard::rclipButton(
          inputId = "clipbtn",
          label = "Copy Code",
          clipText = plot_code(),
          modal = TRUE,
          icon = icon("clipboard"),
          #tooltip = "Click to copy code to your clipboard",
          options = list(delay = list(show = 800, hide = 100), trigger = "hover")
        )
      })
      # -- save code
      output$download_code <- downloadHandler(
        filename = format(Sys.time(), "forestplot-code-%y%m%d-%H%M%S.R"),
        content = function(file) {
          plot_code() |> write(file)
        }
      )
    }
  )

  # run build app
  if (runApp)
    runApp(app)
  else
    app
}
