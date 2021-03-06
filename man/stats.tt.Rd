% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stats.tt.r
\name{stats.tt}
\alias{stats.tt}
\title{Create statistics of Taxon table and reduces to target taxa}
\usage{
stats.tt(x, reads, by, cont, non_target)
}
\arguments{
\item{x}{A taxon table with all its colums}

\item{reads}{The subset of colums containing the reads}

\item{by}{The column containing the grouping names}

\item{cont}{A vector of contaminants taxon names}

\item{non_target}{A vector of non-target taxon names}
}
\value{
Table with summary statistics, the vectors of contanimants, non-target and target taxa
A reduced taxon table containing only target taxa
}
\description{
As input takes a taxon table and some vectors with names of contaminants and non-target taxa
}
\details{
TO be ...
}
\examples{
st.mf <- stats.tt(mf,mf[,9:27],mf$Group,cont,notbemet)

}
\seealso{
\code{\link{match2table}}
}
\author{
Pedro Martinez Arbizu
}
