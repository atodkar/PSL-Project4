
source('scripts/preprocess.R')
source('scripts/recommender.R')

#rsconnect::configureApp("PSL-Project4", size="xlarge")



##
## Read ratings selected by user
get_user_ratings <- function(value_list) {
  dat <- data.table(movie_id = sapply(strsplit(names(value_list), "_"), function(x) ifelse(length(x) > 1, x[[2]], NA)),
                    rating = unlist(as.character(value_list)))
  dat <- dat[!is.null(rating) & !is.na(movie_id)]
  dat[rating == " ", rating := 0]
  dat[, ':=' (movie_id = paste("m", movie_id, sep = ""), rating = as.numeric(rating))]
  dat <- dat[rating > 0]
  
  idx = match(dat$movie_id, movieIDs)
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
  
  
  handleButtonResetRecommendation <- eventReactive(input$btnSubmitRating, {
    removeUI("#recommendations")
    
    moviesToRate = getRecommendedGenreMovies("")
    getMovieRatingTiles(moviesToRate)
  })
  
  observeEvent(input$btnResetRecommendation, {
    removeUI("#recommendations")
    
    # Get personalized recommendations
    value_list <- reactiveValuesToList(input)
    user_ratings <- get_user_ratings(value_list)

    movies = getRecommendedMovies(user_ratings)

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
    },
    {
      getRecommendedGenreMovies(input$selectGenre)
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
})
