
#' Get the story count for a specific query
#'
#' @param query A query string
#' @param start_date The start date, should be a Date object
#' @param end_date The end date, should be a Date object
#' @param collection_ids Optional collection IDs
#' @param source_ids Optional source IDs
#'
#' @returns the number of stories
#' @export
#'
#' @examples
#' # How many articles mention 'Jetten' in all sources in a specific time frame
#' story_count(query="jetten", start_date=as.Date("2024-01-01"), end_date=as.Date("2024-02-01"))
#' # Count articles with a word starting with `immigr` in the Daily Mail (source 19142)
#' story_count(query="immigr*", source_ids = 19142, start_date=as_date("2024-01-01"), end_date=as_date("2024-06-01"))
story_count <- function(query, start_date, end_date, collection_ids=NULL, source_ids=NULL) {
  params <- normalize_params(query=query,start_date=start_date, end_date=end_date, collection_ids=collection_ids, source_ids=source_ids)
  do_request("search/total-count", params=params) |> pluck("count")
}

#' Get the list of stories matching a query
#'
#' @param query A query string
#' @param start_date The start date, should be a Date object
#' @param end_date The end date, should be a Date object
#' @param collection_ids Optional collection IDs
#' @param source_ids Optional source IDs
#' @param max_pages Maximum number of pages to retrieve (set to Inf to retrieve all)
#'
#' @returns a tibble with one story per row
#' @export
#'
#' @examples
#' story_list(query="jetten", start_date=as.Date("2024-01-01"), end_date=as.Date("2024-06-01"), max_pages=10)

story_list <- function(query, start_date, end_date, collection_ids=NULL, source_ids=NULL, max_pages=1) {
  params <- normalize_params(query=query, start_date=start_date, end_date=end_date, collection_ids=collection_ids, source_ids=source_ids)
  pages <- list()
  for (i in 1:max_pages) {
    res <- do_request("search/story-list", params=params)
    stories <- purrr::map(res$stories, tibble::as_tibble) |> purrr::list_rbind()
    pages[[i]] <- stories
    message(paste0("Found ", nrow(stories), " stories on page ", i))
    if(is.null(res$pagination_token)) break
    params$pagination_token = res$pagination_token
  }
  purrr::list_rbind(pages)
}
