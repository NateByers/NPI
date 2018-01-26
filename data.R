# df_30 <- readr::read_csv("npidata_20050523-20180107.csv", n_max = 30)
# 
# 
# n_rows <- 10
# df_10 <- readr::read_csv("npidata_20050523-20180107.csv", n_max = n_rows)
# i <- 1
# 
# df_11_20 <- readr::read_csv("npidata_20050523-20180107.csv", skip = n_rows*i + 1,
#                             n_max = n_rows, col_names = FALSE)
# names(df_11_20) <- names(df_10)
# stopifnot(nrow(df_11_20) == 10)
# i <- 2
# 
# df_21_30 <- readr::read_csv("npidata_20050523-20180107.csv", skip = n_rows*i + 1,
#                             n_max = n_rows, col_names = FALSE)
# names(df_21_30) <- names(df_10)
# stopifnot(nrow(df_21_30) == 10)
# i <- 3
# # etc.
# 
# df_30$NPI
# df_10$NPI
# df_11_20$NPI
# df_21_30$NPI

con <- DBI::dbConnect(RSQLite::SQLite(), "npi.sqlite")

n_rows <- 10000
df <- readr::read_csv("npidata_20050523-20180107.csv", n_max = n_rows)
columns <- gsub(" {1,}", "_", names(df))
columns <- gsub("\\(|\\)", "_", columns)
names(df) <- columns
DBI::dbWriteTable(con, "npi", df)
r <- nrow(df)
i <- 1

while(r == n_rows) {
  print(paste("from", n_rows*i - n_rows, "to", n_rows*i))
  df <- readr::read_csv("npidata_20050523-20180107.csv", skip = n_rows*i + 1,
                        n_max = n_rows, col_names = FALSE)
  names(df) <- columns
  DBI::dbWriteTable(con, "npi", df, append = TRUE)
  r <- nrow(df)
  i <- i + 1
}

taxonomy_codes <- read.csv("http://nucc.org/images/stories/CSV/nucc_taxonomy_180.csv",
                           stringsAsFactors = FALSE)

DBI::dbWriteTable(con, "taxonomy", taxonomy_codes)
DBI::dbDisconnect(con)
