% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprecate.R
\name{plan}
\alias{plan}
\title{Deprecated function \code{plan}}
\usage{
plan(..., list = character(0), file_targets = FALSE,
  strings_in_dots = c("filenames", "literals"))
}
\arguments{
\item{...}{Same as for \code{\link{workplan}()}.}

\item{list}{Same as for \code{\link{workplan}()}.}

\item{file_targets}{Same as for \code{\link{workplan}()}.}

\item{strings_in_dots}{Same as for \code{\link{workplan}()}.}
}
\value{
A data frame of targets and commands.
}
\description{
Use \code{\link{workplan}()} instead.
}
\details{
Deprecated on 2017-10.
}
\examples{
# See ?workplan for examples.
}
\seealso{
\code{\link{workplan}}
}
\keyword{internal}
