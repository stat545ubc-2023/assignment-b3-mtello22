# Load libraries 
# library(shiny)
library(tidyverse)
library(RColorBrewer)
library(ggplot2)
library(scales)

# Load data 
tsne_list <- readRDS("tSNEviz/data/tsneout.RDS")
tsne_meta <- tsne_list$sample_metadata

# Format and factor
tsne_plot <- tsne_list$plot_df %>%
  mutate(Celltype = factor(Celltype, levels = sort(unique(Celltype))))

color_df <- data.frame(
  Celltype = factor(sort(unique(tsne_plot$Celltype))),
  Color = factor(brewer.pal(7, "Set2"))
)

# Define UI for the Shiny app
ui <- fluidPage(
  titlePanel("tSNE - scRNA-seq melanoma samples"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "var",
        label = "Choose a variable to color cells",
        choices = c("Malignant", "Celltype"),
        selected = "Celltype"
      ),
      selectInput(
        "tumor_id",
        label = "Choose a tumor to localize",
        choices = sort(unique(tsne_plot$tumor_id)),
        selected = "53"
      )
    ),
    mainPanel(
      # The current shiny app has the following graphic elements:
      plotOutput("Tumor_composition"),
      # Provides the proportion of cells from all tumors classified into cell types or malignant status depending on the "var" selected.
      # This feature is aimed to provide a by-tumor reference to guide the selection of tumors 
      plotOutput("tSNEref"),
      # Provides the tSNE colored by the selected "var" of interest: cell types or malignancy status
      # This feature is intended as a reference of the different cell clusters to compare cells from individual tumors to other cells in the similar tSNE coordinates
      plotOutput("tSNEtumor")
      # Provides a visualization of a given tumor of interest, colors the corresponding cells by the "var" of interest and sets the color of other cells to a gray background. 
      # This feature provides a way to localize cells from the same tumor samples in the context of other cell clusters.
    )
  )
)

# Define server logic for the Shiny app
server <- function(input, output) {
  output$Tumor_composition <- renderPlot({
    data_plot <- merge(tsne_plot, color_df, by = "Celltype", all.x = TRUE)
    if (input$var == "Celltype") {
      ggplot(data_plot, aes(x = tumor_id, fill = Celltype)) +
        geom_bar(position = "fill") +
        labs(title = element_blank(), y = "Fraction", x = "Tumor ID") +
        scale_y_continuous(labels = percent) +
        theme_classic() +
        scale_fill_manual(values = levels(data_plot$Color),
                          labels = levels(data_plot$Celltype))
    } else {
      ggplot(data_plot, aes(x = tumor_id, fill = Malignant)) +
        geom_bar(position = "fill") +
        scale_y_continuous(labels = percent) +
        labs(title = element_blank(), y = "Fraction", x = "Tumor ID") +
        theme_classic()
    }
  })
  
  output$tSNEref <- renderPlot({
    data_plot <- merge(tsne_plot, color_df, by = "Celltype", all.x = TRUE) %>%
      droplevels()
    if (input$var == "Celltype") {
      var <- "Color"
      ggplot(data_plot, aes(x, y)) +
        geom_point(aes(color = Celltype)) +
        labs(title = element_blank(), y = "tSNE2", x = "tSNE1") +
        scale_color_manual(values = levels(data_plot$Color),
                           labels = levels(data_plot$Celltype)) +
        theme_classic()
    } else {
      var <- input$var
      ggplot(data_plot, aes(x, y)) +
        geom_point(aes(color = Malignant)) +
        labs(title = element_blank(), y = "tSNE2", x = "tSNE1") +
        theme_classic()
    }
  })
  
  output$tSNEtumor <- renderPlot({
    sub_data <- tsne_plot %>%
      filter(tumor_id == input$tumor_id) %>%
      droplevels()
    data_plot <- merge(sub_data, color_df, by = "Celltype", all.x = TRUE)
    
    if (input$var == "Celltype") {
      ggplot(tsne_plot, aes(x, y)) +
        geom_point(color = "gray", alpha = 0.8) +
        geom_point(data = data_plot, aes(x, y, color = Celltype)) +
        scale_color_manual(values = levels(color_df$Color),  
                           labels = levels(color_df$Celltype),
                           breaks = levels(color_df$Celltype)) +
        labs(title = paste("Cell type structure of tumor", input$tumor_id, sep = " "), y = "tSNE2", x = "tSNE1") +
        theme_classic()
    } else {
      ggplot(tsne_plot) +
        geom_point(aes(x, y), color = "gray", alpha = 0.5) +
        geom_point(data = data_plot, aes(x, y, color = Malignant)) +
        labs(title = paste("Cell type structure of tumor", input$tumor_id, sep = " "), y = "tSNE2", x = "tSNE1") +
        theme_classic()
    }
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
