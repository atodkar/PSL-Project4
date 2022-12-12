library(recommenderlab)
library(Matrix)

# For the recommender used in production, we use the entire dataset
train = ratings

# First create a utility matrix stored as a sparse matrix.

# Prefix userId and movieId with different prefixes to avoid duplication
i = paste0('u', train$UserID)
j = paste0('m', train$MovieID)

# X is rating value
x = train$Rating

# Create a temp dataframe to store rating for the User_Movie
tmp = data.frame(i, j, x, stringsAsFactors = T)

# Create a sparse matrix of size |users| by |movies|
Rmat = sparseMatrix(as.integer(tmp$i), as.integer(tmp$j), x = tmp$x)

# Change the sparse matrix row and col names to be corresponding Ids.
rownames(Rmat) = levels(tmp$i)
colnames(Rmat) = levels(tmp$j)

Rmat = new('realRatingMatrix', data = Rmat)

# reduced to 500 based on suggestion on Campuswire
rec_UBCF = Recommender(Rmat[1:500,], method = 'UBCF',
                       parameter = list(normalize = 'Z-score', 
                                        method = 'Cosine', 
                                        nn = 25))
#rec_IBCF = rec_UBCF

# Create a new user
movieIDs = colnames(Rmat)
n.item = ncol(Rmat)


getRecommendedMovies = function(new.ratings) {
  ## Grabage collect some memory
  ## gc(verbose = FALSE)
  new.user = matrix(new.ratings, 
                    nrow=1, ncol=n.item,
                    dimnames = list(
                      user=paste('unknown-user'),
                      item=movieIDs
                    ))
  new.Rmat = as(new.user, 'realRatingMatrix')
  
  mod = rec_UBCF

  pred = predict(mod, new.Rmat, type = "topN")
  pred.top = as(pred, "matrix")[,order(as(pred, "matrix"), decreasing = TRUE)[1:20]]
  pred.movieids = names(pred.top)
  
  pred.movieids = sub('.', '', pred.movieids)
  idx = which(ratingsPerMovie$MovieID %in% pred.movieids)
  cat(paste(idx))
  cat("\n")
  cat(paste(pred.movieids))
  cat("\n")
  cat(paste(ratingsPerMovie$Title[pred.movieids]))
  ratingsPerMovie[idx, ]
}


