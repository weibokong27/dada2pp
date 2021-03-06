% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multiadonis.r
\name{multiadonis}
\alias{multiadonis}
\title{Multiple Adonis Test for Taxon Table}
\usage{
multiadonis(
  datasets,
  fac,
  nboot = 1,
  rarefy = TRUE,
  frac = 0.5,
  balance = FALSE,
  loghell = TRUE,
  distance = "euclidean",
  ...
)
}
\arguments{
\item{datasets}{a list of datasets}

\item{fac}{factor for adonis (groups)}

\item{nboot}{number of rarefied community datasets (bootstrap without replacement) to produce}

\item{frac}{used to estimate the argument sample to be passed to rrarefy. Fraction (e.g.0.3) value corresponding to the minimum number of reads/obeservations per sample.}

\item{...}{additional arguments for adonis (e.g permutations)}
}
\value{
A dataframe with results of adonis and results of adonis on rarefied dataset
}
\description{

}
\details{

}
\examples{
datasets <- list('meio'= t(meio[,9:27]),'crust'= t(crust[,9:27]),'NeHaCyMi'= t(NeHaCyMi[,9:27]))
multiadonis(datasets,area,nboot=10,frac=0.5)
multiadonis(list('ir'=irc),fac=fac,loghell=TRUE,rarefy=FALSE,frac=1,nboot=1,balance=TRUE


}
\seealso{
\code{\link{adonis}}
}
\author{
Pedro Martinez Arbizu
}
