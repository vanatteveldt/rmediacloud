library(tidyverse)
library(httr2)

#' Helper function to do an actual request to a specific endpoint
#' @param endpoint a url path
#' @param params a named list of query parameters
do_request <- function(endpoint, params=NULL, api = "https://search.mediacloud.org/api/"
) {
  auth_token = Sys.getenv("MEDIACLOUD_API_TOKEN")
  if (is.null(auth_token) || nchar(auth_token) == 0) {
    stop("Please set MEDIACLOUD_API_TOKEN in your .Renviron.")
  }

  req <- httr2::request(api) |>
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

#' Helper function to check and normalize parameters
normalize_params <- function (query, start_date, end_date, collection_ids=NULL, source_ids=NULL) {
  if (class(start_date) != "Date") stop("Please provide start date as Date object")
  if (class(end_date) != "Date") stop("Please provide end date as Date object")
  params <- list(q=query, start=format_ISO8601(start_date), end=format_ISO8601(end_date))
  if (!is.null(collection_ids)) params$cs = collection_ids
  if (!is.null(source_ids)) params$ss = source_ids
  params
}



