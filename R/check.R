#' @title Function \code{check_plan}
#' @description Check a workflow plan, etc. for obvious
#' errors such as circular dependencies and
#' missing input files.
#' @seealso \code{ink{workplan}}, \code{\link{make}}
#' @export
#' @return Invisibly return \code{plan}.
#' @param plan workflow plan data frame, possibly from
#' \code{\link{workplan}()}.
#' @param targets character vector of targets to make
#' @param envir environment containing user-defined functions
#' @param cache optional drake cache. See \code{\link{new_cache}()}
#' @param verbose logical, whether to log progress to the console.
#' @examples
#' \dontrun{
#' load_basic_example() # Load drake's canonical example.
#' check_plan(my_plan) # Check the workflow plan dataframe for obvious errors.
#' unlink('report.Rmd') # Remove an import file mentioned in the plan.
#' check_plan(my_plan) # check_plan() tells you that 'report.Rmd' is missing.
#' }
check_plan <- function(
  plan = workplan(),
  targets = drake::possible_targets(plan),
  envir = parent.frame(),
  cache = drake::get_cache(verbose = verbose),
  verbose = TRUE
){
  force(envir)
  config <- drake_config(
    plan = plan,
    targets = targets,
    envir = envir,
    verbose = verbose,
    cache = cache
  )
  check_drake_config(config)
  check_strings(config$plan)
  invisible(plan)
}

check_drake_config <- function(config) {
  if (config$skip_safety_checks){
    return(invisible())
  }
  stopifnot(is.data.frame(config$plan))
  if (!all(c("target", "command") %in% colnames(config$plan)))
    stop("The columns of your workflow plan data frame ",
      "must include 'target' and 'command'.")
  stopifnot(nrow(config$plan) > 0)
  stopifnot(length(config$targets) > 0)
  missing_input_files(config = config)
  assert_standard_columns(config = config)
  warn_bad_symbols(config$plan$target)
  parallelism_warnings(config = config)
}

assert_standard_columns <- function(config){
  x <- setdiff(colnames(config$plan), workplan_columns())
  if (length(x)){
    warning(
      "Non-standard columns in workflow plan:\n",
      multiline_message(x),
      call. = FALSE
    )
  }
}

missing_input_files <- function(config) {
  missing_files <- V(config$graph)$name %>%
    setdiff(y = config$plan$target) %>%
    Filter(f = is_file) %>%
    drake_unquote %>%
    Filter(f = function(x) !file.exists(x))
  if (length(missing_files))
    warning("missing input files:\n", multiline_message(missing_files),
      call. = FALSE)
  invisible(missing_files)
}

warn_bad_symbols <- function(x) {
  x <- drake_unquote(x)
  bad <- which(!is_parsable(x)) %>% names
  if (!length(bad))
    return(invisible())
  warning("Possibly bad target names:\n", multiline_message(bad),
    call. = FALSE)
  invisible()
}

check_strings <- function(plan) {
  x <- stri_extract_all_regex(plan$command, "(?<=\").*?(?=\")")
  names(x) <- plan$target
  x <- x[!is.na(x)]
  if (!length(x))
    return()
  x <- lapply(x, function(y) {
    if (length(y) > 2)
      return(y[seq(from = 1, to = length(y), by = 2)]) else return(y)
  })
  message("Double-quoted strings were found in plan$command.\n",
    "Should these be single-quoted instead?\n",
    "Remember: single-quoted strings are file target dependencies\n",
    "and double-quoted strings are just ordinary strings.")
  for (target in seq_len(length(x))) {
    message("\ntarget: ", names(x)[target])
    message("strings in command:\n",
      multiline_message(drake::drake_quotes(x[[target]],
      single = FALSE)), sep = "")
  }
}
