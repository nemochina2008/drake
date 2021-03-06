#' @title Function \code{build_drake_graph}
#' @description Make a graph of the dependency structure of your workplan.
#' @details This function returns an igraph object representing how
#' the targets in your workplan depend on each other.
#' (\code{help(package = "igraph")}). To plot the graph, call
#' to \code{\link{plot.igraph}()} on your graph, or just use
#' \code{\link{vis_drake_graph}()} from the start.
#' @seealso \code{\link{vis_drake_graph}}
#' @export
#' @return An igraph object representing
#' the workflow plan dependency network.
#'
#' @param plan workflow plan data frame, same as for function
#' \code{\link{make}()}.
#'
#' @param targets names of targets to build, same as for function
#' \code{\link{make}()}.
#'
#' @param envir environment to import from, same as for function
#' \code{\link{make}()}.
#'
#' @param verbose logical, whether to output messages to the console.
#'
#' @param jobs number of jobs to accelerate the construction
#' of the dependency graph. A light \code{mclapply}-based
#' parallelism is used if your operating system is not Windows.
#'
#' @examples
#' \dontrun{
#' load_basic_example() # Load the canonical example for drake.
#' # Make the igraph network connecting all the targets and imports.
#' g <- build_drake_graph(my_plan)
#' class(g) # "igraph"
#' }
build_drake_graph <- function(
  plan = workplan(),
  targets = drake::possible_targets(plan),
  envir = parent.frame(),
  verbose = TRUE,
  jobs = 1
){
  force(envir)
  plan <- sanitize_plan(plan)
  targets <- sanitize_targets(plan, targets)
  imports <- as.list(envir)
  assert_unique_names(
    imports = names(imports),
    targets = plan$target,
    envir = envir,
    verbose = verbose
  )
  true_import_names <- setdiff(names(imports), targets)
  imports <- imports[true_import_names]
  console_many_targets(
    targets = names(imports),
    pattern = "connect",
    type = "import",
    config = list(verbose = verbose)
  )
  import_deps <- lightly_parallelize(
    imports, import_dependencies, jobs = jobs)
  console_many_targets(
    targets = plan$target,
    pattern = "connect",
    type = "target",
    config = list(verbose = verbose)
  )
  command_deps <- lightly_parallelize(
    plan$command, command_dependencies, jobs = jobs)
  names(command_deps) <- plan$target
  dependency_list <- c(command_deps, import_deps)
  keys <- names(dependency_list)
  vertices <- c(keys, unlist(dependency_list)) %>% unique
  from <- unlist(dependency_list) %>%
    unname()
  times <- vapply(
    X = dependency_list,
    FUN = length,
    FUN.VALUE = integer(1),
    USE.NAMES = TRUE
  )
  to <- rep(keys, times = times)
  edges <- rbind(from, to) %>%
    as.character()
  graph <- make_empty_graph() +
    vertex(vertices) +
    edge(edges)
  graph <- prune_drake_graph(graph = graph, to = targets, jobs = jobs)
  if (!is_dag(graph)){
    stop("Workflow is circular (chicken and egg dilemma).")
  }
  return(graph)
}

#' @title Function prune_drake_graph
#' @export
#' @seealso \code{\link{build_drake_graph}}, \code{\link{config}},
#' \code{\link{make}}
#' @description Prune an igraph object. Igraph objects are used
#' internally to represent the dependency network of your workflow.
#' See \code{\link{config}(my_plan)$graph} from the basic example.
#' @details For a supplied graph, take the subgraph of all combined
#' incoming paths to the vertices in \code{to}. In other words,
#' remove the vertices after \code{to} from the graph.
#' @return A pruned igraph object representing the dependency network
#' of the workflow.
#' @param graph An igraph object to be pruned.
#' @param to Character vector, names of the vertices that draw
#' the line for pruning. The pruning process removes all vertices
#' downstream of \code{to}.
#' @param jobs Number of jobs for light parallelism (on non-Windows machines).
#' @examples
#' \dontrun{
#' load_basic_example() # Load the canonical example.
#' # Build the igraph object representing the workflow dependency network.
#' # You could also use drake_config(my_plan)$graph
#' graph <- build_drake_graph(my_plan)
#' # The default plotting is not the greatest,
#' # but you will get the idea.
#' plot(graph)
#' # Prune the graph: that is, remove the nodes downstream
#' # from 'small' and 'large'
#' pruned <- prune_drake_graph(graph = graph, to = c("small", "large"))
#' plot(pruned)
#' }
prune_drake_graph <- function(
  graph, to = igraph::V(graph)$name, jobs = 1
){
  if (!inherits(graph, "igraph")){
    stop(
      "supplied graph must be an igraph object",
      call. = FALSE
    )
  }
  unlisted <- setdiff(to, V(graph)$name)
  if (length(unlisted)){
    warning(
      "supplied targets not in the workflow graph:\n",
      multiline_message(unlisted),
      call. = FALSE
    )
    to <- setdiff(to, unlisted)
  }
  if (!length(to)){
    warning(
      "cannot prune graph: no valid destination vertices supplied",
      call. = FALSE
    )
    return(graph)
  }
  ignore <- lightly_parallelize(
    X = to,
    FUN = function(vertex){
      subcomponent(graph = graph, v = vertex, mode = "in")$name
    },
    jobs = jobs
  ) %>%
    unlist() %>%
    unique() %>%
    setdiff(x = igraph::V(graph)$name)
  delete_vertices(graph = graph, v = ignore)
}

assert_unique_names <- function(imports, targets, envir, verbose){
  if (anyDuplicated(targets)){
    duplicated <- which(table(targets) > 1) %>%
      names()
    stop(
      "Duplicate targets in workflow plan:\n",
      multiline_message(duplicated)
      )
  }
  common <- intersect(imports, targets)
  if (verbose & length(common)){
    message(
      "Unloading targets from environment:\n",
      multiline_message(common), sep = ""
    )
  }
  remove(list = common, envir = envir)
}

trim_graph <- function(config){
  if (!length(config$from)){
    return(config)
  }
  config <- sanitize_from(config)
  if (!length(config$order)){
    config$order <- length(V(config$graph))
  }
  config$graph <- igraph::make_ego_graph(
    graph = config$graph,
    order = config$order,
    nodes = config$from,
    mode = config$mode
  ) %>%
    do.call(what = igraph::union)
  config
}
