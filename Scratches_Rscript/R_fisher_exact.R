calcfisher <- function(data){
	  # input : four number used as fisher value
	  # How to use this: fisher.pvalue <- apply(gatk[c("G.tref","G.tvar","G.nref","G.nvar")],1,calcfisher2)
	  matrix <- matrix(as.numeric( data[c(1,2,3,4)] ) ,ncol = 2)
  if( sum(is.na(matrix)) >= 1 ){
	          return(NA)
    }
    else{
		        f1 <- fisher.test(as.table(matrix),alt="two.sided")
	          return(f1$p.value)
			    }
}
