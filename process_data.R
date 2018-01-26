library(dplyr)
query_npi <- function(sql, database = "/home/nbyers1/Repositories/NPI/npi.sqlite") {
  con <- DBI::dbConnect(RSQLite::SQLite(), database)
  dat <- try(DBI::dbGetQuery(con, sql))
  DBI::dbDisconnect(con)
  dat
}

query_npi("SELECT name FROM sqlite_master WHERE type='table'")
column_names <- query_npi("PRAGMA table_info(npi)")
npi <- query_npi("select * from npi limit 10")

indiana <- query_npi("select * from npi where Provider_Business_Practice_Location_Address_State_Name = 'IN'") %>%
  dplyr::filter(!(!is.na(NPI_Deactivation_Date) & is.na(NPI_Reactivation_Date)))

indiana_locations <- indiana %>%
  dplyr::select(NPI, Entity_Type_Code, Provider_First_Name, 
                Provider_Last_Name__Legal_Name_,
                Provider_Organization_Name__Legal_Business_Name_,
                Provider_First_Line_Business_Practice_Location_Address,
                Provider_Second_Line_Business_Practice_Location_Address,
                starts_with("Provider_Business_Practice_Location"))

indiana_taxonomies <- indiana %>%
  dplyr::select(NPI, starts_with("Healthcare_Provider_Taxonomy_Code")) %>%
  tidyr::gather(level, code, starts_with("Healthcare_Provider_Taxonomy_Code")) %>%
  dplyr::filter(!is.na(code))

taxonomy_codes <- query_npi("select * from taxonomy")

home_infusion <- indiana_taxonomies %>%
  dplyr::group_by(NPI) %>%
  dplyr::filter("3336H0001X" %in% code) %>%
  dplyr::ungroup() %>%
  dplyr::select(NPI) %>%
  dplyr::distinct() %>%
  dplyr::left_join(indiana_locations, "NPI") %>%
  dplyr::mutate(address = paste0(Provider_First_Line_Business_Practice_Location_Address,
                                ", ", Provider_Business_Practice_Location_Address_City_Name,
                                " ", Provider_Business_Practice_Location_Address_State_Name,
                                " ", Provider_Business_Practice_Location_Address_Postal_Code),
                address = tolower(address))

geocodes <- ggmap::geocode(home_infusion$addresses)
write.csv(cbind(address = home_infusion$address, geocodes),
          file = "geocodes.csv", row.names = FALSE)

# manually add lat/lons where needed

geocodes <- read.csv("geocodes.csv", stringsAsFactors = FALSE) %>%
  dplyr::select(-address)
unlink("geocodes.csv")

home_infusion <- cbind(home_infusion, geocodes)

save(home_infusion, file = "/home/nbyers1/Repositories/NPI/shiny/home_infusion.rda")
