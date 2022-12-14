

# Load ratings data
myurl = "https://liangfgithub.github.io/MovieData/"

# Need to use offline data for shinyapp
ratings = read.csv(paste0(myurl, 'ratings.dat?raw=true'),
                   sep = ':',
                   colClasses = c('integer', 'NULL'), 
                   header = FALSE)
colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
ratings$Timestamp = NULL

# Clean movies data from local
movies = readLines(paste0(myurl, 'movies.dat?raw=true')) 
movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
movies = data.frame(movies, stringsAsFactors = FALSE)
colnames(movies) = c('MovieID', 'Title', 'Genres')
movies = movies[!duplicated(movies$MovieID), ]
movies$MovieID = as.integer(movies$MovieID)

# convert accented characters
movies$Title = iconv(movies$Title, "latin1", "UTF-8")

# extract year
movies$Year = as.numeric(unlist(
  lapply(movies$Title, function(x) substr(x, nchar(x)-4, nchar(x)-1))))


# Get thumbnail urls for movie
base_image_url = "https://liangfgithub.github.io/MovieImages/"
movies$image_url = sapply(movies$MovieID, 
                          function(x) paste0(base_image_url, x, '.jpg?raw=true'))


# Genre list
genre_list = c("Action", "Adventure", "Animation", 
               "Children's", "Comedy", "Crime",
               "Documentary", "Drama", "Fantasy",
               "Film-Noir", "Horror", "Musical", 
               "Mystery", "Romance", "Sci-Fi", 
               "Thriller", "War", "Western")


# Ratings per Movie
ratingsPerMovie = ratings %>%
  group_by(MovieID) %>% 
  summarize(ratings_per_movie = n(), ave_ratings = mean(Rating)) %>%
  inner_join(movies, by = 'MovieID')


movieSortedByNumRatings = arrange(ratingsPerMovie, desc(ratingsPerMovie$ratings_per_movie))


