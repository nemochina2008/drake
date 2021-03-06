% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprecate.R
\name{workflow}
\alias{workflow}
\title{Function \code{workflow}}
\usage{
workflow(..., list = character(0), file_targets = FALSE,
  strings_in_dots = c("filenames", "literals"))
}
\arguments{
\item{...}{same as for \code{drake::\link{workplan}()}}

\item{list}{same as for \code{drake::\link{workplan}()}}

\item{file_targets}{same as for \code{drake::\link{workplan}()}}

\item{strings_in_dots}{same as for \code{drake::\link{workplan}()}}
}
\value{
A data frame of targets and commands.
}
\description{
Turns a named collection of command/target pairs into
a workflow plan data frame for \code{\link{make}} and
\code{\link{check}}.
}
\details{
Deprecated on 2017-10
}
\examples{
# See ?workplan for examples.
}
\keyword{internal}
