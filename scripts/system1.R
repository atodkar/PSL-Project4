###
### System 1 algorithm to get popular movies
getRecommendedGenreMovies = function(genre = "") {
  ## Grabage collect some memory
  ## gc(verbose = FALSE)
  
  sortedMovies = movieSortedByNumRatings
  
  idx = 1:20
  if (genre != "") {
    idx = which(grepl(genre, sortedMovies$Genres))[1:20]
  }
  sortedMovies[idx, ]  
}

