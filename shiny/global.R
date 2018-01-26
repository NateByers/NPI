library(shiny)
library(leaflet)
library(dplyr)

load("home_infusion.rda")

home_infusion <- home_infusion %>%
  dplyr::rename(Name = Provider_Organization_Name__Legal_Business_Name_,
                Longitude = lon, Latitude = lat) %>%
  dplyr::mutate(Address = toupper(address),
                popup = paste0("<b>", Name, "</b><br/>", 
                               Provider_First_Line_Business_Practice_Location_Address,
                               "<br/>", Provider_Business_Practice_Location_Address_City_Name,
                               ", ", Provider_Business_Practice_Location_Address_State_Name,
                               " ", Provider_Business_Practice_Location_Address_Postal_Code)) %>%
  dplyr::select(NPI, Name, Address, Longitude, Latitude, popup)

