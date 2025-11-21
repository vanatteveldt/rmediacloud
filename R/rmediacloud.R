library(tidyverse)
library(httr2)

Sys.setenv("MEDIACLOUD_API_TOKEN"="6a5e41bab175f03d2142441199fb3fa6167a70a8")

BASE_API_URL = "https://search.mediacloud.org/api/"

do_request <- function(endpoint, params=NULL) {
  auth_token = Sys.getenv("MEDIACLOUD_API_TOKEN")
  if (is.null(auth_token) || nchar(auth_token) == 0) {
    stop("Please set MEDIACLOUD_API_TOKEN in your .Renviron.")
  }
  
  req <- httr2::request(BASE_API_URL) |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_headers(
      "Authorization" = paste("Token", auth_token),
      "User-Agent" = "R httr2 client (MediaCloud mimic)"
    )
  if (!is.null(params)) 
    req <- req |> httr2::req_url_query(!!!params)
  retry_cooldown <- 1
  repeat {

    resp <- req |> 
      httr2::req_error(is_error = ~httr2::resp_is_error(.) && httr2::resp_status(.) != 429) |>
      httr2::req_perform()
    if (httr2::resp_status(resp) == 429) {
      sleep = 5 * retry_cooldown
      retry_cooldown <- retry_cooldown * 2
      message(paste0("Received a HTTP 429 Too many requests, sleeping ", sleep, " seconds and retrying"))
      Sys.sleep(sleep)
      next
    }
    return(httr2::resp_body_json(resp))
  }
    
}

normalize_params <- function (query, start_date, end_date, collection_ids=NULL, source_ids=NULL) {
  if (class(start_date) != "Date") stop("Please provide start date as Date object")
  if (class(end_date) != "Date") stop("Please provide end date as Date object")
  list(q=query, start=format_ISO8601(start_date), end=format_ISO8601(end_date))
}

story_count <- function(query, start_date, end_date, collection_ids=NULL, source_ids=NULL) {
  params <- normalize_params(query=query,start_date=start_date, end_date=end_date, collection_ids=collection_ids, source_ids=source_ids)
  do_request("search/total-count", params=params) |> pluck("count")
}

story_list <- function(query, start_date, end_date, collection_ids=NULL, source_ids=NULL, max_pages=1) {
  params <- normalize_params(query=query, start_date=start_date, end_date=end_date, collection_ids=collection_ids, source_ids=source_ids)
  pages <- list()
  for (i in 1:max_pages) {
    res <- do_request("search/story-list", params=params)
    stories <- map(res$stories, as_tibble) |> list_rbind()
    pages[[i]] <- stories
    message(paste0("Found ", nrow(stories), " stories on page ", i))
    if(is.null(res$pagination_token)) break
    params$pagination_token = res$pagination_token
  }
  list_rbind(pages)
}

ry
map(res$stories, as_tibble) |> list_rbind()

story_list(query="jetten", start_date=as_date("2024-01-01"), end_date=as_date("2024-06-01"), max_pages=10)
story_count(query="jetten", start_date=as_date("2024-01-01"), end_date=as_date("2024-02-01"))
  
  
