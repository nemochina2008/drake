% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/outdated.R
\name{missed}
\alias{missed}
\title{Function \code{missed}}
\usage{
missed(plan = workplan(), targets = drake::possible_targets(plan),
  envir = parent.frame(), verbose = TRUE, jobs = 1,
  parallelism = drake::default_parallelism(), packages = rev(.packages()),
  prework = character(0), graph = NULL, config = NULL)
}
\arguments{
\item{plan}{workflow plan data frame, same as for function
\code{\link{make}()}.}

\item{targets}{names of targets to build, same as for function
\code{\link{make}()}.}

\item{envir}{environment to import from, same as for function
\code{\link{make}()}.}

\item{verbose}{logical, whether to output messages to the console.}

\item{jobs}{The \code{outdated()} function is called internally,
and it needs to import objects and examine your
input files to see what has been updated. This could take some time,
and parallel computing may be needed
to speed up the process. The \code{jobs} argument is number of parallel jobs
to use for faster computation.}

\item{parallelism}{Choice of parallel backend to speed up the computation.
See \code{?parallelism_choices} for details. The Makefile option is not
available here. Drake will try to pick the best option for your system by
default.}

\item{packages}{same as for \code{\link{make}}}

\item{prework}{same as for \code{\link{make}}}

\item{graph}{same as for \code{\link{make}}}

\item{config}{option internal runtime parameter list of
\code{\link{make}(...)},
produced with \code{\link{config}()}.
Overrides all other arguments except if not \code{NULL}.
For example, \code{config$plan} overrides \code{plan}.
Computing this
in advance could save time if you plan multiple calls to
\code{missed()}.}
}
\value{
Character vector of names of missing objects and files.
}
\description{
Report any import objects required by your workplan
plan but missing from your workspace.
IMPORTANT: you must be in the root directory of your project.
}
\examples{
\dontrun{
load_basic_example() # Load the canonical example.
missed(my_plan) # All the imported files and objects should be present.
rm(reg1) # Remove an import dependency from you workspace.
missed(my_plan) # Should report that reg1 is missing.
}
}
\seealso{
\code{\link{outdated}}
}
