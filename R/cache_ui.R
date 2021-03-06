#' @title Function \code{cached}
#' @description Check whether targets are in the cache.
#' If no targets are specified with \code{...} or \code{list},
#' then \code{cached()} lists
#' all the items in the drake cache.
#' Read/load a cached item with \code{\link{readd}()} or
#' \code{\link{loadd}()}.
#' @seealso \code{\link{built}}, \code{\link{imported}},
#' \code{\link{readd}}, \code{\link{loadd}},
#' \code{\link{workplan}}, \code{\link{make}}
#' @export
#' @return Either a named logical indicating whether the given
#' targets or cached or a character vector listing all cached
#' items, depending on whether any targets are specified
#'
#' @param ... objects to load from the cache, as names (unquoted)
#' or character strings (quoted). Similar to \code{...} in
#' \code{\link{remove}(...)}.
#'
#' @param list character vector naming objects to be loaded from the
#' cache. Similar to the \code{list} argument of \code{\link{remove}()}.
#'
#' @param no_imported_objects logical, applies only when
#' no targets are specified and a list of cached targets is returned.
#' If \code{no_imported_objects} is \code{TRUE}, then \code{cached()}
#' shows built targets (with commands) plus imported files,
#' ignoring imported objects. Otherwise, the full collection of
#' all cached objects will be listed. Since all your functions and
#' all their global variables are imported, the full list of
#' imported objects could get really cumbersome.
#'
#' @param cache drake cache. See \code{\link{new_cache}()}.
#' If supplied, \code{path} and \code{search} are ignored.
#'
#' @param path Root directory of the drake project,
#' or if \code{search} is \code{TRUE}, either the
#' project root or a subdirectory of the project.
#' Ignored if a \code{cache} is supplied.
#'
#' @param search logical. If \code{TRUE}, search parent directories
#' to find the nearest drake cache. Otherwise, look in the
#' current working directory only.
#' Ignored if a \code{cache} is supplied.
#'
#' @param verbose whether to print console messages
#'
#' @param namespace character scalar, name of the storr namespace
#' to use for listing objects
#'
#' @examples
#' \dontrun{
#' load_basic_example() # Load drake's canonical example.
#' make(my_plan) # Run the project, build all the targets.
#' cached(list = 'reg1') # Is 'reg1' in the cache?
#' # List all the targets and imported files in the cache.
#' # Exclude R objects imported from your workspace.
#' cached(no_imported_objects = TRUE)
#' # List all targets and imports in the cache.
#' cached()
#' # Clean the main data.
#' clean()
#' # The targets and imports are gone.
#' cached()
#' # But there is still metadata.
#' build_times()
#' cached(namespace = "build_times")
#' # Clear that too.
#' clean(purge = TRUE)
#' cached(namespace = "build_times")
#' build_times()
#' }
cached <- function(
  ...,
  list = character(0),
  no_imported_objects = FALSE,
  path = getwd(),
  search = TRUE,
  cache = NULL,
  verbose = TRUE,
  namespace = NULL
){
  if (is.null(cache)){
    cache <- get_cache(path = path, search = search, verbose = verbose)
  }
  if (is.null(cache)){
    return(character(0))
  }
  if (is.null(namespace)){
    namespace <- cache$default_namespace
  }
  dots <- match.call(expand.dots = FALSE)$...
  targets <- targets_from_dots(dots, list)
  if (!length(targets))
    list_cache(no_imported_objects = no_imported_objects,
      cache = cache, namespace = namespace)
  else
    is_cached(targets = targets, no_imported_objects = no_imported_objects,
      cache = cache, namespace = namespace)
}

is_cached <- function(targets, no_imported_objects, cache, namespace) {
  if (no_imported_objects)
    targets <- no_imported_objects(targets = targets, cache = cache)
  inclusion <- targets %in% cache$list(namespace = namespace)
  names(inclusion) <- targets
  inclusion
}

list_cache <- function(no_imported_objects, cache, namespace) {
  targets <- cache$list(namespace = namespace)
  if (no_imported_objects){
    plan <- read_drake_plan(cache = cache)
    targets <- no_imported_objects(targets = targets, plan = plan)
  }
  targets
}

#' @title Function \code{built}
#' @description List all the built (non-imported) objects in the drake
#' cache.
#' @seealso \code{\link{cached}}, \code{\link{loadd}},
#' \code{link{imported}}
#' @export
#' @return Character vector naming the built targets in the cache.
#' @param cache drake cache. See \code{\link{new_cache}()}.
#' If supplied, \code{path} and \code{search} are ignored.
#' @param path Root directory of the drake project,
#' or if \code{search} is \code{TRUE}, either the
#' project root or a subdirectory of the project.
#' @param search logical. If \code{TRUE}, search parent directories
#' to find the nearest drake cache. Otherwise, look in the
#' current working directory only.
#' @param verbose whether to print console messages
#' @examples
#' \dontrun{
#' load_basic_example() # Load drake's canonical example.
#' make(my_plan) # Run the project, build all the targets.
#' built() # List all the cached targets (built objects and files).
#' # For file targets, only the fingerprints/hashes are stored.
#' }
built <- function(
  path = getwd(), search = TRUE,
  cache = drake::get_cache(path = path, search = search, verbose = verbose),
  verbose = TRUE
){
  if (is.null(cache)){
    return(character(0))
  }
  plan <- read_drake_plan(cache = cache)
  cache$list(namespace = cache$default_namespace) %>%
    Filter(
      f = function(target){
        !is_imported(target = target, plan = plan)
      }
    )
}

#' @title Function \code{imported}
#' @description List all the imported objects in the drake cache
#' @seealso \code{\link{cached}}, \code{\link{loadd}},
#' \code{\link{built}}
#' @export
#' @return Character vector naming the imports in the cache.
#' @param files_only logical, whether to show imported files only
#' and ignore imported objects. Since all your functions and
#' all their global variables are imported, the full list of
#' imported objects could get really cumbersome.
#' @param cache drake cache. See \code{\link{new_cache}()}.
#' If supplied, \code{path} and \code{search} are ignored.
#' @param path Root directory of the drake project,
#' or if \code{search} is \code{TRUE}, either the
#' project root or a subdirectory of the project.
#' @param search logical. If \code{TRUE}, search parent directories
#' to find the nearest drake cache. Otherwise, look in the
#' current working directory only.
#' @param verbose whether to print console messages
#' @examples
#' \dontrun{
#' load_basic_example() # Load the canonical example.
#' make(my_plan) # Run the project, build the targets.
#' imported() # List all the imported objects/files in the cache.
#' # For imported files, only the fingerprints/hashes are stored.
#' }
imported <- function(
  files_only = FALSE, path = getwd(), search = TRUE,
  cache = drake::get_cache(path = path, search = search, verbose = verbose),
  verbose = TRUE
){
  if (is.null(cache)){
    return(character(0))
  }
  plan <- read_drake_plan(cache = cache)
  targets <- cache$list(namespace = cache$default_namespace) %>%
    Filter(f = function(target){
      is_imported(target = target, plan = plan)
    })
  if (files_only)
    targets <- Filter(targets, f = is_file)
  targets
}

# from base::remove()
targets_from_dots <- function(dots, list) {
  if (length(dots) && !all(vapply(dots, function(x) is.symbol(x) ||
    is.character(x), NA, USE.NAMES = FALSE)))
    stop("... must contain names or character strings")
  names <- vapply(dots, as.character, "")
  if (length(names) == 0L)
    names <- character()
  .Primitive("c")(names, list) %>% unique
}

imported_only <- function(targets, plan) {
  Filter(targets, f = function(target) is_imported(target = target,
    plan = plan))
}

no_imported_objects <- function(targets, plan) {
  Filter(targets,
    f = function(target) is_built_or_imported_file(target = target,
      plan = plan))
}

is_imported <- Vectorize(function(target, plan) {
  !(target %in% plan$target)
},
"target", SIMPLIFY = TRUE)

is_built_or_imported_file <- Vectorize(function(target, plan) {
  imported <- is_imported(target = target, plan = plan)
  !imported | (imported & is_file(target))
},
"target", SIMPLIFY = TRUE)

file_target_exists <- function(target, config){
  config$cache$exists(key = target, namespace = "mtimes")
}

target_exists <- function(target, config){
  config$cache$exists(key = target, namespace = "kernels")
}
