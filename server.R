## server.R


#source('functions/cf_algorithm.R')
#source('functions/similarity_measures.R') # similarity measures
source('scripts/preprocess.R')
source('scripts/recommender.R')

get_user_ratings <- function(value_list) {
  dat <- data.table(movie_id = sapply(strsplit(names(value_list), "_"), function(x) ifelse(length(x) > 1, x[[2]], NA)),
                    rating = unlist(as.character(value_list)))
  dat <- dat[!is.null(rating) & !is.na(movie_id)]
  dat[rating == " ", rating := 0]
  dat[, ':=' (movie_id = paste("m", movie_id, sep = ""), rating = as.numeric(rating))]
  dat <- dat[rating > 0]
  
  idx = which(dat$movie_id %in% movieIDs)
  new.ratings = rep(NA, n.item)
  new.ratings[idx] = dat$rating
  
  new.ratings
}

shinyServer(function(input, output, session) {
  
  # show the movies to be rated based on genre list
  output$selectGenre <- renderUI({
    selectInput(
      "selectGenre",
      "Genre",
      genre_list,
      selected = NULL
    )
  })
  
  # radio button to show the sorting options
  output$selectSortBy <- renderUI({
    radioButtons(
      "selectSortBy",
      "Sort By",
      c("Average Rating", "Popularity")
    )
  })
  
  #radio button to choose the recommendation engine
  output$selectRecommendation <- renderUI({
    radioButtons(
      "selectRecommendation",
      "Recommendation Method",
      c("UBCF", "IBCF")
    )
  })
  
  handleButtonResetRecommendation <- eventReactive(input$btnSubmitRating, {
    removeUI("#recommendations")
    
    moviesToRate = getRecommendedGenreMovies("", "Popularity")
    getMovieRatingTiles(moviesToRate)
  })
  
  observeEvent(input$btnResetRecommendation, {
    removeUI("#recommendations")
    
    # Get personalized recommendations
    value_list <- reactiveValuesToList(input)
    user_ratings <- get_user_ratings(value_list)
    cat(str(input$selectRecommendation))
    movies = getRecommendedMovies(user_ratings, input$selectRecommendation)

    insertUI(
      "#placeholder",
      "afterEnd",
      ui = div(
        id = 'recommendations',
        box(
          width = 12,
          title = "We found these movies that you might like",
          getMovieTiles(movies)
        )
      )
    )
  })

  handleEventGenreFilterChange <- eventReactive(
    {
      input$selectGenre
      input$selectSortBy
    },
    {
      getRecommendedGenreMovies(input$selectGenre, input$selectSortBy)
    }
  )

  # display the recommendations
  output$recommendationResultsSystem1 <- renderUI({
    getMovieTiles(handleEventGenreFilterChange())
  })
  
  # show the movies to be rated
  output$recommendationResultsSystem2 <- renderUI({
    box(
      width = 12,
      title = "Rate these movies to get movie recommendations based on your preference",
      handleButtonResetRecommendation()
    )
  })
}) # server function
