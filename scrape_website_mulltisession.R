#library needed
library(rvest)
library(dplyr)
library(purrr)
library(furrr)

#Create function to scrape data from web
#change adresses for yours
scrape_page <- function(url) {
  page <- read_html(url)
  
  items <- page %>% html_nodes(".item-content")
  
  data <- map_dfr(items, function(item) {
    title <- item %>% html_node(".title a") %>% html_text(trim = TRUE)
    link <- item %>% html_node(".title a") %>% html_attr("href")
    date <- item %>% html_node(".item-meta-data") %>% html_text(trim = TRUE)
    description <- item %>% html_node("p") %>% html_text(trim = TRUE)
    
    return(tibble(Title = title, Date = date, Link = link, Description = description))
  })
  
  return(data)
}

#Create a list from your address you want to scrape
page_numbers <- 1:141
urls <- paste0("https://atu.ac.ir/fa/news?page=", page_numbers)

#Set multi session scraping
plan(multisession)

#Start scraping
all_data <- future_map_dfr(urls, scrape_page, .progress = TRUE)


#Save data on CSV
write.csv(all_data, "atu_news.csv", row.names = FALSE, fileEncoding = "UTF-8")
