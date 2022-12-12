library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

source('functions/helpers.R')

tab1 = tabItem(
  "system1",
  fillPage(
    box(
      class = "rateditems",
      title = "Movies Sorted By: Popularity",
      width = 12,
      solidHeader = T,
      status = "info",
      box(
        uiOutput('selectGenre')
      ),
      box(
        width = 12,
        uiOutput('recommendationResultsSystem1')
      )
    ),
  )
)

tab2 = tabItem(
  "system2",
  fillPage(
    useShinyjs(),
    box(
      title = "Recommended Movies using algorithm: UBCF",
      width = 12,
      solidHeader = T,
      status = "info",
      class = "rateditems",
      box(
        #uiOutput('selectRecommendation'),
        fluidRow(
          width = 12,
          actionButton("btnSubmitRating", "Get Movies To Rate", class = "btn-primary"),
          actionButton("btnResetRecommendation", "Submit and Get Recommendations", class = "btn-primary")
        )
      ),
      tags$div(id = "placeholder"),
      uiOutput("recommendationResultsSystem2")
    )
  )
)

sidebar = dashboardSidebar(
  sidebarMenu(
    id = "tabs",
    menuItem("System 1: Recommended Genre Movies", tabName = "system1"),
    menuItem("System 2: Personalized Recommendations", tabName = "system2")
  ),
  disable = FALSE
)

body = dashboardBody(
  includeCSS("css/style.css"),
  tabItems(tab1, tab2)
)

header = dashboardHeader(title = "Movie Recommender")

shinyUI(
  dashboardPage(
    skin = "purple",
    header,
    sidebar,
    body
  )
) 