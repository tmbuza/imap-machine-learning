# (PART) MODEL DEPLOYMENT {-}

# Model Deployment

Deploying the trained model such as the regularized logistic regression model and others is essential for predicting binary outcomes in microbiome studies. Additionally, implementing monitoring mechanisms is crucial to track model performance over time and detect any deviations or anomalies. This ensures continued reliability and accuracy in microbiome data analysis. Shiny applications serve as interfaces for machine learning models, providing users with a convenient platform to upload their data and test the model's performance efficiently.





## Shiny App components

### User Interface (UI)
- The User Interface (UI) component in a Shiny application serves as the visual representation of the app and dictates how users interact with it. It encompasses various elements like buttons, sliders, text inputs, plots, and tables, which are organized using layout functions such as fluidPage(), navbarPage(), tabPanel(), etc.
- In Shiny, UI elements are created using functions from the shiny package, each serving a specific purpose. For instance, textInput() creates a field where users can input text, sliderInput() generates a slider for selecting numeric values, and plotOutput() reserves a space for displaying plots.
- These UI components are typically structured within the ui function, which acts as a container for assembling the app's visual layout. Here's an example of how UI components are defined within the ui function:


```r
library(shiny)

load("models/models.rda", verbose = TRUE)
Loading objects:
  mod_glmnet_adcv
  mod_regLogistic_cv
  mod_rf_adcv
  mod_rf_reptcv
  mod_knn_adcv
  mod_knn_reptcv
```



```r
ui <- fluidPage(
  titlePanel("My Shiny App"),  # Adds a title panel at the top of the app
  sidebarLayout(               # Organizes content into a sidebar and main panel
    sidebarPanel(              # Defines content for the sidebar
      textInput("text_input", "Enter text:")  # Adds a text input field
    ),
    mainPanel(                 # Defines content for the main panel
      plotOutput("plot")       # Adds a placeholder for displaying plots
    )
  )
)
```


### Server for Shiny App

- The server component is responsible for processing user inputs from the UI and generating outputs dynamically.
- It contains the logic and calculations needed to update the UI in response to user actions.
- The server component is defined within the server function.
- It consists of reactive expressions and functions that specify how inputs should be handled and how outputs should be generated.
- Server functions typically involve observing input values and updating reactive values accordingly.

For example:

```r
server <- function(input, output) {
  output$plot <- renderPlot({
    text <- input$text_input
    hist(rnorm(100, mean = as.numeric(text)), main = "Histogram")
  })
}
```


## Shiny App deployment
Once you have defined both the UI and server components of your Shiny application, you can proceed with the deployment process. Here's what you can do next:

### Combine UI and Server
- Merge the UI and server components into a single Shiny application by passing them to the shinyApp() function.

### Deploy the Shiny App
- Deploy your Shiny application to make it accessible to users. There are various deployment options available, including:
  - Hosting the app on shinyapps.io
  - Deploying it on your own server
  - Embedding it within a larger web application

### Test and Monitor
- Before releasing the app to users, thoroughly test its functionality to ensure it behaves as expected.
- Implement monitoring mechanisms to track the app's performance and user interactions over time.
- Regularly update and maintain the app to address any issues or improvements.

### Gather Feedback
- Encourage users to provide feedback on the app's usability and features.
- Use this feedback to make iterative improvements and enhancements to the app.

### Documentation and Support
- Provide clear documentation and instructions on how to use the app.
- Offer support channels for users to seek assistance or report issues.

### Continuous Improvement
- Continuously iterate on the app based on user feedback and evolving requirements.
- Stay updated with Shiny and R developments to incorporate new features and best practices.

> By following these steps, you can successfully deploy your Shiny application and ensure its continued success and usefulness to your users.


## Extended user interface 

```r
library(shiny)
library(shinydashboard)
library(shinythemes)

# UI chunk
ui <- shinyUI(dashboardPage(
  skin = "black",
  dashboardHeader(
    title = em("Shiny Machine Learning App", style = "text-align:center;color:#006600;font-size:100%"),
    titleWidth = 800
  ),
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      br(),
      menuItem(em("Upload Test Data", style = "font-size:120%"), icon = icon("upload"), tabName = "data"),
      menuItem(em("Download Predictions", style = "font-size:120%"), icon = icon("download"), tabName = "download")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "data",
        br(),
        tags$h4(
          "This shiny app allows you to upload your data, do prediction, and download results.",
          em("This example demonstrates a Regularized Logistic Regression."),
          "You can predict whether an individual is healthy or unhealthy.",
          "By evaluating the results, you can make a decision if the model predicts correctly or poorly.",
          style = "font-size:150%"
        ),
        br(),
        tags$h4(
          "Start by uploading test data, preferably in ",
          code("csv format"),
          style = "font-size:150%"
        ),
        tags$h4(
          "Then, go to the ",
          tags$span("Download Predictions", style = "color:red"),
          " section in the sidebar to download the predictions.",
          style = "font-size:150%"
        ),
        br(),
        br(),
        br(),
        column(
          width = 4,
          fileInput(
            'file1',
            em('Upload test data in csv format', style = "text-align:center;color:blue;font-size:150%"),
            multiple = FALSE,
            accept = c('.csv')
          ),
          uiOutput("sample_input_data_heading"),
          tableOutput("sample_input_data"),
          br(),
          br()
        )
      ),
      tabItem(
        tabName = "download",
        fluidRow(
          br(),
          br(),
          br(),
          br(),
          column(
            width = 8,
            tags$h4(
              "After you upload a test dataset, you can download the predictions in csv format by clicking the button below.",
              style = "font-size:200%"
            ),
            br(),
            br()
          )
        ),
        fluidRow(
          column(
            width = 7,
            downloadButton(
              "downloadData",
              em('Download Predictions', style = "text-align:center;color:blue;font-size:150%")
            ),
            plotOutput('plot_predictions')
          ),
          column(
            width = 4,
            uiOutput("sample_prediction_heading"),
            tableOutput("sample_predictions")
          )
        )
      )
    )
  )
))
```


## Extended server 

```r

load("models/models.rda", verbose = TRUE)
Loading objects:
  mod_glmnet_adcv
  mod_regLogistic_cv
  mod_rf_adcv
  mod_rf_reptcv
  mod_knn_adcv
  mod_knn_reptcv

# Server chunk
server <- function(input, output) {
  
  # Set maximum web request size to 80MB
  options(shiny.maxRequestSize = 800 * 1024^2) 
  
  # Render UI elements for sample input data heading and table
  output$sample_input_data_heading <- renderUI({
    inFile <- input$file1
    if (is.null(inFile)) {
      return(NULL)
    } else {
      tags$h4('Sample Input Data')
    }
  })
  
  output$sample_input_data <- renderTable({
    inFile <- input$file1
    if (is.null(inFile)) {
      return(NULL)
    } else {
      input_data <- readr::read_csv(input$file1$datapath, col_names = TRUE)
      colnames(input_data) <- c("Label", "Test1", "Test2")
      input_data$Label <- factor(input_data$Label, labels = c("African American", "African"))
      head(input_data)
    }
  })
  
  # Perform predictions on uploaded data
  predictions <- reactive({
    inFile <- input$file1
    if (is.null(inFile)) {
      return(NULL)
    } else {
      withProgress(message = 'Predictions in progress. Please wait ...', {
        input_data <- readr::read_csv(input$file1$datapath, col_names = TRUE)
        colnames(input_data) <- c("Label", "Test1", "Test2")
        input_data$Label <- factor(input_data$Label, labels = c("African American", "African"))
        mapped <- feat_map(input_data)
        df_final <- cbind(input_data, mapped)
        prediction <- predict(mod_regLogistic_cv, df_final)
        input_data_with_prediction <- cbind(input_data, prediction)
        input_data_with_prediction
      })
    }
  })
  
  # Render UI elements for sample predictions heading and table
  output$sample_prediction_heading <- renderUI({
    inFile <- input$file1
    if (is.null(inFile)) {
      return(NULL)
    } else {
      tags$h4('Input with Predictions')
    }
  })
  
  output$sample_predictions <- renderTable({
    pred <- predictions()
    head(pred)
  })
  
  # Render plot of predictions
  output$plot_predictions <- renderPlot({
    pred <- predictions()
    cols <- c("African American" = "green4", "African" = "red")
    pred %>% 
      ggplot(aes(x = Test1, y = Test2, color = factor(prediction))) + 
      geom_point(size = 4, shape = 19, alpha = 0.6) +
      scale_colour_manual(values = cols, 
                          labels = c("African American", "African"), 
                          name = "Variable") +
      theme_bw()
  })
  
  # Downloadable CSV of predictions
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("input_data_with_predictions", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(predictions(), file, row.names = FALSE)
    }
  )
  
}
```

## Calling Shiny App

```{}

# Deployment chunk
shinyApp(ui = ui, server = server)
```


- **Using shinyApp function**


- **App directory:** If the application resides in a specific app_directory, you could launch it with:

```{}
runApp("app_directory")
  
```
  
- **Shiny app object:** If you’ve created a Shiny app object at the console by calling shinyApp(), you can pass that app object to runApp() like so:

```{}
# Create app object (assume ui and server are defined)
app <- shinyApp(ui, server)

runApp(app)
```


```{}
app

```


## Example APP with Qualitative data using Burro package

<div class="infoicon">
<p>library(burro)</p>
<p>library(NHANES)</p>
<p>data(NHANES)</p>
<p>NHANES %&gt;% mutate(gr = 1) %&gt;% ggplot(aes_string(x =
“AgeDecade”, fill = “AgeDecade”)) + geom_bar(aes(y = ..count..), color =
“black”) + viridis::scale_fill_viridis(discrete = TRUE, option =
“magma”) + geom_text(aes(group = gr, label = scales::percent(..prop..),
y = ..count..), stat = “count”, vjust = -0.5) + theme(axis.text.x =
element_text(angle = 90), legend.position = “none”)</p>
<p>data_dict &lt;-
readr::read_csv(system.file(“nhanes/data_dictionary.csv”,
package=“burro”))</p>
<p>outcome &lt;- c(“Depressed”)</p>
<p>explore_data(dataset=NHANES, data_dictionary=data_dict,
outcome_var=outcome)</p>
</div>

