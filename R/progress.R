#' @title Function \code{drake_session}
#' @description Load the \code{\link{sessionInfo}()}
#' of the last call to \code{\link{make}()}.
#' @seealso \code{\link{diagnose}}, \code{\link{built}}, \code{\link{imported}},
#' \code{\link{readd}}, \code{\link{workplan}}, \code{\link{make}}
#' @export
#' @return \code{\link{sessionInfo}()} of the last
#' call to \code{\link{make}()}
#' @param cache optional drake cache. See code{\link{new_cache}()}.
#' If \code{cache} is supplied,
#' the \code{path} and \code{search} arguments are ignored.
#' @param path Root directory of the drake project,
#' or if \code{search} is \code{TRUE}, either the
#' project root or a subdirectory of the project.
#' @param search If \code{TRUE}, search parent directories
#' to find the nearest drake cache. Otherwise, look in the
#' current working directory only.
#' @param verbose whether to print console messages
#' @examples
#' \dontrun{
#' load_basic_example() # Load drake's canonical example.
#' make(my_plan) # Run the project, build the targets.
#' drake_session() # Retrieve the cached sessionInfo() of the last make().
#' }
drake_session <- function(path = getwd(), search = TRUE,
  cache = drake::get_cache(path = path, search = search, verbose = verbose),
  verbose = TRUE
){
  if (is.null(cache)) {
    stop("No drake::make() session detected.")
  }
  return(cache$get("sessionInfo", namespace = "session"))
}

#' @title Function \code{in_progress}
#' @description List the targets that either
#' (1) are currently being built if \code{\link{make}()} is running, or
#' (2) were in the process of being built if the previous call to
#' \code{\link{make}()} quit unexpectedly.
#' @seealso \code{\link{diagnose}}, \code{\link{session}},
#' \code{\link{built}}, \code{\link{imported}},
#' \code{\link{readd}}, \code{\link{workplan}}, \code{\link{make}}
#' @export
#' @return A character vector of target names.
#' @param cache optional drake cache. See code{\link{new_cache}()}.
#' If \code{cache} is supplied,
#' the \code{path} and \code{search} arguments are ignored.
#' @param path Root directory of the drake project,
#' or if \code{search} is \code{TRUE}, either the
#' project root or a subdirectory of the project.
#' @param search If \code{TRUE}, search parent directories
#' to find the nearest drake cache. Otherwise, look in the
#' current working directory only.
#' @param verbose whether to print console messages
#' @examples
#' \dontrun{
#' load_basic_example() # Load the canonical example.
#' make(my_plan) # Kill before targets finish.
#' # If you interrupted make(), some targets will probably be listed:
#' in_progress()
#' }
in_progress <- function(path = getwd(), search = TRUE,
  cache = drake::get_cache(path = path, search = search, verbose = verbose),
  verbose = TRUE
){
  prog <- progress(path = path, search = search, cache = cache)
  which(prog == "in progress") %>%
    names() %>%
    as.character()
}

#' @title Function \code{failed}
#' @description List the targets that failed in the last call
#' to \code{\link{make}()}.
#' Together, functions \code{failed} and
#' \code{\link{diagnose}()} should eliminate the strict need
#' for ordinary error messages printed to the console.
#' @seealso \code{\link{diagnose}}, \code{\link{session}},
#' \code{\link{built}}, \code{\link{imported}},
#' \code{\link{readd}}, \code{\link{workplan}}, \code{\link{make}}
#' @export
#' @return A character vector of target names.
#' @param cache optional drake cache. See code{\link{new_cache}()}.
#' If \code{cache} is supplied,
#' the \code{path} and \code{search} arguments are ignored.
#' @param path Root directory of the drake project,
#' or if \code{search} is \code{TRUE}, either the
#' project root or a subdirectory of the project.
#' @param search If \code{TRUE}, search parent directories
#' to find the nearest drake cache. Otherwise, look in the
#' current working directory only.
#' @param verbose whether to print console messages
#' @examples
#' \dontrun{
#' load_basic_example() # Load drake's canonical example.
#' make(my_plan) # Run the project, build the targets.
#' failed() # Should show that no targets failed.
#' # Build a workflow plan doomed to fail:
#' bad_plan <- workplan(x = function_doesnt_exist())
#' make(bad_plan) # error
#' failed() # "x"
#' diagnose(x) # Retrieve the cached error log of x.
#' }
failed <- function(path = getwd(), search = TRUE,
  cache = drake::get_cache(path = path, search = search, verbose = verbose),
  verbose = TRUE
){
  prog <- progress(path = path, search = search, cache = cache)
  which(prog == "failed") %>%
    names() %>%
    as.character()
}

#' @title Function \code{progress}
#' @description Get the build progress (overall or individual targets)
#' of the last call to \code{\link{make}()}.
#' Objects that drake imported, built, or attempted
#' to build are listed as \code{"finished"} or \code{"in progress"}.
#' Skipped objects are not listed.
#' @seealso \code{\link{diagnose}}, \code{\link{session}},
#' \code{\link{built}}, \code{\link{imported}},
#' \code{\link{readd}}, \code{\link{workplan}}, \code{\link{make}}
#' @export
#'
#' @return The build progress of each target reached by
#' the current \code{\link{make}()} so far.
#'
#' @param ... objects to load from the cache, as names (unquoted)
#' or character strings (quoted). Similar to \code{...} in
#' \code{\link{remove}(...)}.
#'
#' @param list character vector naming objects to be loaded from the
#' cache. Similar to the \code{list} argument of \code{\link{remove}()}.
#'
#' @param no_imported_objects logical, whether to only return information
#' about imported files and targets with commands (i.e. whether to ignore
#' imported objects that are not files).
#'
#' @param imported_files_only logical, deprecated. Same as
#' \code{no_imported_objects}.  Use the \code{no_imported_objects} argument
#' instead.
#'
#' @param cache optional drake cache. See code{\link{new_cache}()}.
#' If \code{cache} is supplied,
#' the \code{path} and \code{search} arguments are ignored.
#'
#' @param path Root directory of the drake project,
#' or if \code{search} is \code{TRUE}, either the
#' project root or a subdirectory of the project.
#'
#' @param search If \code{TRUE}, search parent directories
#' to find the nearest drake cache. Otherwise, look in the
#' current working directory only.
#'
#' @param verbose whether to print console messages
#'
#' @examples
#' \dontrun{
#' load_basic_example() # Load the canonical example.
#' make(my_plan) # Run the project, build the targets.
#' # Watch the changing progress() as make() is running.
#' progress() # List all the targets reached so far.
#' progress(small, large) # Just see the progress of some targets.
#' progress(list = c("small", "large")) # Same as above.
#' progress(no_imported_objects = TRUE) # Ignore imported R objects.
#' }
progress <- function(
  ...,
  list = character(0),
  no_imported_objects = FALSE,
  imported_files_only = logical(0),
  path = getwd(),
  search = TRUE,
  cache = drake::get_cache(path = path, search = search, verbose = verbose),
  verbose = TRUE
){
  # deprecate imported_files_only
  if (length(imported_files_only)){
    warning(
      "The imported_files_only argument to progress() is deprecated ",
      "and will be removed the next major release. ",
      "Use the no_imported_objects argument instead.",
      call. = FALSE
    )
    no_imported_objects <- imported_files_only
  }
  if (is.null(cache)){
    return(character(0))
  }
  dots <- match.call(expand.dots = FALSE)$...
  targets <- targets_from_dots(dots, list)
  if (!length(targets)){
    return(list_progress(
        no_imported_objects = no_imported_objects,
        cache = cache
        ))
  }
  return(get_progress(targets, cache))
}

list_progress <- function(no_imported_objects, cache){
  all_marked <- cache$list(namespace = "progress")
  all_progress <- get_progress(target = all_marked, cache = cache)
  plan <- read_drake_plan(cache = cache)
  abridged_marked <- Filter(
    all_marked,
    f = function(target){
      is_built_or_imported_file(target = target, plan = plan)
    }
  )
  abridged_progress <- all_progress[abridged_marked]
  if (no_imported_objects){
    out <- abridged_progress
  } else{
    out <- all_progress
  }
  if (!length(out)){
    out <- as.character(out)
  }
  return(out)
}

get_progress <- Vectorize(
  function(target, cache){
    if (target %in% cache$list("progress")){
      cache$get(key = target, namespace = "progress")
    } else{
      "not built or imported"
    }
  },
  "target",
  SIMPLIFY = TRUE,
  USE.NAMES = TRUE
)
