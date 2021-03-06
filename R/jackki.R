#'@title Jackknife for Adonis  
#'
#'@description Calculates the relative importance of variables using jackknife 
#'
#'@param x Model formula. The LHS is either community matrix or dissimilarity matrix (eg. from vegdist or dist)
#' See adonis() for details. The RHS are factors that must be column names of a data frame specified with argument data.
#' 
#'@param data The data frame of independent variables having as column names the factors specified in formula.
#'
#'@param strata String. The name of the column with factors to be used as strata.  
#'
#'@param permutations Numer of permutation. Default is 1, as we are only interested in F value, not p value.    
#'
#'@param (...) Any other parameter passed to adonis 
#'
#'
#'@details
#' Community ecologist want to know how species contribute to dissimilarity between groups.
#' The routine simper() is commonly used to achive this task.
#' But simper is limmited to decomposition of the bray-curtis dissimilarity.
#' jackki() offers a more flexible alternative by analysing the relative contribution
#' of each species 
#' to observed adonis difference (value F.Model). adonis is calculated
#' by leaving out one species out each time and the resulting F value is recorded.
#' The unbiased F estimate and 95\% confidence intervals are used
#' to classify the species into following categories
#' \itemize{
#' \item segregating species: removal results in significantly lower F value
#' \item aggregating species: removal results in significantly higher F value
#' \item n.s.: removal does not change observed F value significantly 
#'}
#' As we are only interested in F value, permutations are set to 1 by default. 
#' Set permutations to higher value if you want to record the effect of species removal
#' to observed p-value. 
#'
#'
#'@return An object of class jackki.
#'
#' \itemize{
#' \item res: Table showing the results of adonis for each excluded species its final classification.
#' \item jackknife: unbiased F estimate, unbiased variance of F, upper and lower 95\% confidence intervals.
#'}
#'
#' The plot method displays a dotchart with the adonis F value for every excluded species.
#' A grey solid line represents the unbiased estimate of F and a dotted line to the left and to the rigth of it
#' the 95\% confidence intervals.
#' Segregating species use triangle as symbol, n.s. species a square and aggregating species a circle.
#' Plot can be confined to segregating and aggregating species only by using reduce = TRUE.
#' Graphical parameters can be passed to dotchart().
 
#'
#'@author Pedro Martinez Arbizu
#'
#'@import vegan graphics
#'
#'@examples
#' 
#' library(vegan)
#' data(dune)
#' data(dune.env)
#' x <- jackki(dune~Management,data=dune.env)
#'
#' plot(x)
#'
#'@export jackki plot.jackki
#'
#'@seealso \code{\link{simper}} \code{\link{adonis}} \code{\link{dotchart}}
#'


jackki <- function(x, data, strata = NULL, permutations=1, ... ){

#describe parent call function 
	ststri <- ifelse(is.null(strata),'Null',strata)
	fostri <- as.character(x)

#copy model formula
	x1 <- x
# extract left hand side of formula
	lhs <- x1[[2]]
# extract factors on right hand side of formula 
	rhs <- x1[[3]]
# create model.frame matrix  
	x1[[2]] <- NULL   
	rhs.frame <- model.frame(x1, data, drop.unused.levels = TRUE) 


# calculate the empirical cumulative distribution
# function and its quantiles according to alpha
#	null.ecdf <- ecdf(ad.null)
#	qlow <- quantile(null.ecdf,alpha)
#	qup <- quantile(null.ecdf,1-alpha)
 
# variable names
	sv <-  colnames(eval(lhs))

# results matrix
	res <- matrix(ncol=5,nrow=length(sv))

###########
########### exclude species one by one
	for (elem in (1:length(sv))){
	
	#reduce model elements  
	if(inherits(eval(lhs),'dist')){	
	    xred <- as.dist(as.matrix(eval(lhs))[-elem,-elem])
	}else{
	xred <- eval(lhs)[,-elem]
	}
		
# redefine formula
	if(length(rhs) == 1){
		xnew <- as.formula(paste('xred',as.character(rhs),sep='~'))	
		}else{
		xnew <- as.formula(paste('xred' , 
					paste(rhs[-1],collapse= as.character(rhs[1])),
					sep='~'))}
					
#pass new formula to adonis
	if(is.null(strata)){
	ad <- adonis(xnew,data=data, permutations=permutations, ... )
	}else{ad <- adonis(xnew,data=data,strata= mdat1[,strata], permutations=permutations, ... )}
	
	res[elem,1] <- ad$aov.tab[1,2]
	res[elem,2] <- ad$aov.tab[1,3]
	res[elem,3] <- ad$aov.tab[1,4]
	res[elem,4] <- ad$aov.tab[1,5]
	res[elem,5] <- ad$aov.tab[1,6]
	
	#calculate confidence intervals of null model
	
	}
	
#create results data frame	
 res <- data.frame(sv,res)
 colnames(res) <- c('variable','SumsOfSqs','MeanSqs','F.Model','R2','Pr(>F)')

# jackkniffe
	jm <- mean(res$F.Model) # this is the unbiased jk estimate of
							# mean F erosion when removing 1 variable
	jv <- var(res$F.Model)/length(res$F.Model) # variance of the unbiased estimator
	jkup <- mean(res$F.Model) + qt(0.975,length(res$F.Model)-1)*sqrt(var(res$F.Model)/length(res$F.Model)) # upper 95% c.i.
	jklow <- mean(res$F.Model) - qt(0.975,length(res$F.Model)-1)*sqrt(var(res$F.Model)/length(res$F.Model)) # lower 95% c.i.
	
	jackknife <- data.frame(unbiased.F=jm,unbiased.var.F=jv,'up95CI'=jkup,'low95CI'=jklow)	

# add some columns to results table
	func <- rep('n.s.',length(res$F.Model))
	func[res$F.Model < jklow] <- "segregating"
	func[res$F.Model > jkup] <- "aggregating"
	
	res <- cbind(res, diff.F = res$F.Model - jm)
	res <- cbind(res, rel.effect = func)
	res <- res[order(res$diff.F),]

res2 <- list(res=res,jackknife=jackknife)
class(res2) <- c("jackki", "list")
return(res2)		
}

#jackki(iris[,1:4]~Species,data=iris)
#jackki(dune~Management,data=dune.env)

plot.jackki <- function(x, reduce = FALSE, pch=rev(c(21,22,24)[x$res$rel.effect]), pt.cex=1.3, bg='white',  ... ){


xmin <-  min( c(x$res$F.Model,x$jackknife$low95CI))
xmax <- max( c(x$res$F.Model,x$jackknife$up95CI))

if(reduce){x$res <-  x$res[!(x$res$rel.effect == 'n.s.'),] }

dotchart(x$res$F.Model,1:nrow(x$res),
		labels=x$res$variable,xlab='F.Model',
		ylab='',
		xlim=c(xmin,xmax),
		pch=pch,
		bg=bg,
		... )

abline(v=x$jackknife[1],lty=1,lwd=4,col=rgb(20,20,100,alpha=50,max=255)) 
abline(v=c(x$jackknife[3],x$jackknife[4]),lty=2,col=rgb(20,20,100,alpha=50,max=255))

}




