# Simple Shiny app

The simple Shiny app is intended for the visualization of single cell RNA-seq data generated in the study "*Dissecting the multicellular ecosystem of metastatic melanoma by single-cell RNA-seq*" by Tirosh, and collaborators 2016.

The deployed version of the app can be accessed at <https://mtello.shinyapps.io/tsneviz/>

The data is freely available at [GSE72056](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72056).

The tSNE coordinates were calculated using the following code:

```         
library(data.table)
library(Rtsne)
scexp <- fread("GSE72056_melanoma_single_cell_revised_v2.tsv", header = TRUE)
scexp <- scexp[4:nrow(scexp),]
setnames(scexp, "Cell", "Gene")
scexp <- as.matrix(scexp[, .SD, .SDcols = !"Gene"])
scexp <- t(scexp)
tsne_coord <- Rtsne(scexp, partial_pca  = TRUE)
```

The current shiny app has the following graphic elements:

-   **Tumor_composition**: Provides the proportion of cells from all tumors classified into cell types or malignant status depending on the "var" selected. This feature is aimed to provide a by-tumor reference to guide the selection of tumors

-   **tSNEref**: Provides the tSNE colored by the selected "var" of interest: cell types or malignancy status. This feature is intended as a reference of the different cell clusters to compare cells from individual tumors to other cells in the similar tSNE coordinates.

-   **tSNEtumor**: Provides a visualization of a given tumor of interest, colors the corresponding cells by the "var" of interest and sets the color of other cells to a gray background. This feature provides a way to localize cells from the same tumor samples in the context of other cell clusters.

# Reactive version

The previous Shiny app was also updated to provide a platform to explore the dataset and filter it based on user-defined requirements. The document to run the reactive version can be found at

"./tSNEviz/reactive_doc.Rmd"

Once the document is loaded in an Rstudio session, its possible to runt it by clicking the "Run document" button.

The deployed version can be found at <https://mtello.shinyapps.io/reactive_doc/>

In this version, I only included non-malignant cells from two donors due to computational and storage limitations. by GitHub and ShinyApps.io. However, the code is able to run for the full dataset in a local computer with the following specs:

**Processor:** 11th Gen Intel(R) Core(TM) i5-11400H \@ 2.70GHz, 2688 Mhz, 6 Core(s), 12 Logical Processor(s)\
**Installed Physical Memory (RAM)**: 16.0 GB

Therefore it is a good template to develop a local platform to analyze and filter single cell RNA-seq data.
