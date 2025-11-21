
#' Search for a collection
#'
#' @param name If given, search for collections containing this word in the title
#' @param limit If given, maximum number of sources to display
#' @param offset If given, offset for source list
#'
#' @returns A tibble containing one collection per row, including an `id`
#' @export
#'
#' @examples
#' collection_list("college")
collection_list <- function(name=NULL, limit=0, offset=0) {
  params = list(limit=limit, offset=offset)
  if (!is.null(name)) params$name=name
  do_request("sources/collections/", params=params) |>
    purrr::pluck("results") |>
    purrr::list_transpose(default=NA_character_) |>
    tibble::as_tibble()
}

#' Search for a source
#'
#' @param name If given, search for source containing this word in the title
#' @param collection_id If given, search for sources within this collection
#' @param limit If given, maximum number of sources to display
#' @param offset If given, offset for source list
#'
#' @returns A tibble containing one collection per row, including an `id`
#' @export
#'
#' @examples
#' source_list(name="dailymail.co.uk")
#' source_list(collection_id=34412476)
#' source_list(name="dailymail.co.uk", collection_id=34412476)
source_list <- function(name=NULL, collection_id=NULL, limit=0, offset=0) {
  params = list(limit=limit, offset=offset)
  if (!is.null(name)) params$name=name
  if (!is.null(collection_id)) params$collection_id=collection_id
  do_request("sources/sources/", params=params) |>
    purrr::pluck("results") |>
    purrr::list_transpose(default=NA_character_) |>
    tibble::as_tibble()
}
