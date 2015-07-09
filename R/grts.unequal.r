grts.unequal <- function( n, over.n, unequal.var, shp, alloc.type, fn, dir, outobj ){
  
  # Inputs: 
  # n = vector of sample sizes, one element per category
  # over.n = scalar (vector length 1) of number of units to add per category.  Constant across category
  # unequal.var = string nameing category variable IF shape contains points or lines
  # shp = the SpatialXDataFrame object (the frame)
  
  options(useFancyQuotes = FALSE)
  cat(print(outobj))
  cat(print(dir))
  cat(print(fn))
  log_con <- file(paste0(outobj,".log"),open="a")     # write selected pieces of code to a file
  cat("# Utilization of this code without first installing R packages rgdal and spsurvey will result in error.\n",sep="",file=log_con)

  cat("# This output results from the SDraw package, WEST Inc., 2014, Version 1.04.\n
library(rgdal)
library(spsurvey)\n\n",sep="",file=log_con)


  
  cat("# Read in the shapefile of interest from which sampling occurs.\n
shp <- readOGR( ",dQuote(dir),", ",dQuote(fn)," ) \n\n",sep="",file=log_con)
  close(log_con)
  
  # Get category level names from shape file
  category.levels <- names(table(data.frame(shp)[,unequal.var]))
  # For debuggin
#   cat("---- n -----\n")
#   print(n)
#   cat("---- over.n -----\n")
#   print(over.n)
#   cat("---- unequal.var -----\n")
#   print(unequal.var)
#   cat("---- category.levels -----\n")
#   print(category.levels) 
#   cat("---- head(shp) -----\n")
#   print(head(data.frame(shp)))
  
  if(alloc.type == "constant"){
    
    #make caty.n
    the.caty.n <- n
    names(the.caty.n) <- category.levels
  
    #this makes a list of elements to be passed to the grts function
    selType="Unequal"
    IDHelper <- "Site" 
    Unequaldsgn <- list(None=list(panel=c(PanelOne=sum(n)),seltype=selType,caty.n=the.caty.n,over=over.n))
  
    # prepare category string for printing
    for(i in 1:length(the.caty.n)){
      if(i == 1){
        string <- paste("c(",dQuote(names(the.caty.n[1])),"=",the.caty.n[1],sep="")
      } else {
        string <- paste(string,",",dQuote(names(the.caty.n[i])),"=",the.caty.n[i],sep="")
      }
    }
    string <- paste(string,")",sep="")
    
    log_con <- file(paste0(outobj,".log"),open="a")
  cat("# Prepare the design of the sampling for use in the grts function.\n
Unequaldsgn <- list(None=list(panel=c(PanelOne=(",sum(get("n")),")),
seltype=",dQuote(get("selType")),",
caty.n=",string,",
over=",get("over.n"),"))\n\n", sep="", append = TRUE, file = log_con)
    close(log_con)
    
  } else if(alloc.type == "continuous"){

    #this makes a list of elements to be passed to the grts function
    selType="Continuous"
    IDHelper <- "Site" 
    Unequaldsgn <- list(None=list(panel=c(PanelOne=sum(n)),
                               seltype=selType,
                               over=over.n))
    
    log_con <- file(paste0(outobj,".log"),open="a")
  cat("# Prepare the design of the sampling for use in the grts function.\n
Unequaldsgn <- list(None=list(panel=c(PanelOne=(",sum(get("n")),")),
seltype=",dQuote(get("selType")),",
over=",get("over.n"),"))\n\n", sep="", append = TRUE, file = log_con)
    close(log_con)
    
  } else if(alloc.type == "uneqproportion"){
    
    #make caty.n
    the.caty.n <- n
    names(the.caty.n) <- category.levels
    
    #this makes a list of elements to be passed to the grts function
    selType="Unequal"
    IDHelper <- "Site" 
    Unequaldsgn <- list(None=list(panel=c(PanelOne=sum(n)),
                                  seltype=selType,
                                  caty.n=the.caty.n,
                                  over=over.n))
    
    # prepare category string for printing
    for(i in 1:length(the.caty.n)){
      if(i == 1){
        string <- paste("c(",dQuote(names(the.caty.n[1])),"=",the.caty.n[1],sep="")
      } else {
        string <- paste(string,",",dQuote(names(the.caty.n[i])),"=",the.caty.n[i],sep="")
      }
    }
    string <- paste(string,")",sep="")
    
    log_con <- file(paste0(outobj,".log"),open="a")
  cat("# Prepare the design of the sampling for use in the grts function.\n
Unequaldsgn <- list(None=list(panel=c(PanelOne=(",sum(get("n")),")),
seltype=",dQuote(get("selType")),",
caty.n=",string,",
over=",get("over.n"),"))\n\n", sep="", append = TRUE, file = log_con)
    close(log_con)
  }
  
  if( regexpr("SpatialPoints", class(shp)[1]) > 0 ){
    sframe.type = "finite"
  } else if( regexpr("SpatialLines", class(shp)[1]) > 0 ){
    sframe.type = "linear"
  } else if( regexpr("SpatialPolygons", class(shp)[1]) > 0 ){
    sframe.type = "area"
  }


  Unequalsites <- grts(design=Unequaldsgn,
                     DesignID=IDHelper,
                     type.frame=sframe.type,    # added to file
                     att.frame=data.frame(shp),
                     src.frame="sp.object",
                     sp.object=shp,
                     mdcaty=unequal.var,   #need to use category/continuous variable name as taken from GUI
                     shapefile=FALSE)
  
  log_con <- file(paste0(outobj,".log"),open="a")
  cat("# Draw the sample via the grts function in package spsurvey.\n
Unequalsites <- grts(design=Unequaldsgn,
DesignID=",dQuote(get("IDHelper")),",
type.frame=",dQuote(get("sframe.type")),",
att.frame=data.frame(shp),
src.frame='sp.object',
sp.object=shp,
mdcaty=",dQuote(get("unequal.var")),",   
shapefile=FALSE)\n\n", sep="", append = TRUE, file = log_con)
  cat("# Plot the original shapefile, along with the sample.\n
plot(shp)
plot(Unequalsites,col='red',pch=19,add=TRUE)", sep="", append = TRUE, file = log_con)
  close(log_con)

  cat("Success.\n")
  
  #   Toss some variables that are not important for equal probability designs
  #Equalsites <- Equalsites[,!(names(Equalsites) %in% c("mdcaty","wgt","stratum","panel"))]
  
  #   Add a column of sample/oversample for convieneince
  # Equalsites$pointType <- c(rep("Sample",n), rep("OverSample",over.n))
  
  #   Copy over the projection from the input spatial object
  proj4string(Unequalsites) <- CRS(proj4string(shp))
  
  #   Store some attributes
  attr(Unequalsites, "sample.type") <- "GRTS"
  attr(Unequalsites, "n") <- n
  attr(Unequalsites, "over.n") <- over.n
  attr(Unequalsites, "sp.object") <- deparse(substitute(shp))
  attr(Unequalsites, "frame.type") <- sframe.type
  attr(Unequalsites, "unequal.var") <- unequal.var
  attr(Unequalsites, "alloc.type") <- selType

  options(useFancyQuotes = TRUE)

  Unequalsites
}
