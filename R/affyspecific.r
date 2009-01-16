##Methods to prepare the data
aqm.prepaffy = function(expressionset, sN)
{
  pp1 = try(preprocess(expressionset))
  dataPLM = try(fitPLM(pp1, background = FALSE, normalize = FALSE))
  if(class(pp1)=='try-error' || class(dataPLM)=='try-error')
    warning("RLE and NUSE plots from the package 'affyPLM' cannot be produced for this data set.")

  Affyobject = list("dataPLM" = dataPLM, "sN" = sN)
  class(Affyobject) = "aqmobj.prepaffy"
  return(Affyobject)
}


##RLE
aqm.rle = function(affyproc, ...)
  {   
    rle = try(Mbox(affyproc$dataPLM, ylim = c(-1, 1),
      names = affyproc$sN, col = brewer.pal(9, "Set1")[2],
      whisklty = 0, staplelty = 0,
      main = "RLE", las = 3, cex.axis = 0.8, plot = FALSE, ...))

    legend = "<b>Figure FIG</b> is a Relative Log Expression (RLE) plot and an array that has problems will either have larger spread, or will not be centered at M = 0, or both. RLE are performed on preprocessed data (background correction and quantile normalization. This diagnostic plot is based on tools provided in the affyPLM package."

    title = "Relative Log Expression plot"

    type = "Affymetrix specific plots"
    
    rlemed = rle$stats[3,]
    rleout = which(abs(rlemed) > 0.1)

    out = list("plot" = rle, "type" = type, "title" = title, "legend" = legend, "scores" = rlemed, "outliers" = rleout)
    class(out) = "aqmobj.rle"
    return(out)
  }

##NUSE
aqm.nuse = function(affyproc, ...)
{ 
  nuse = try(boxplot(affyproc$dataPLM, ylim = c(0.95, 1.5), names = affyproc$sN,
    outline = FALSE, col =  brewer.pal(9, "Set1")[2], main = "NUSE",
    las = 2, cex.axis = 0.8), ...)

  legend = "<b>Figure FIG</b> is a Normalized Unscaled Standard Error (NUSE) plot. Low quality arrays are those that are substantially elevated or more spread out, relative to the other arrays. NUSE values are not comparable across data sets. NUSE are performed on preprocessed data (background correction and quantile normalization. This diagnostic plot is based on tools provided in the affyPLM package."

  title = "Normalized Unscaled Standard Error plot"
  type = "Affymetrix specific plots"

  nusemean = nuse$stat[3,]
  nusemeanstat = boxplot.stats(nusemean)
  nusemeanout = sapply(seq_len(length(nusemeanstat$out)), function(x) which(nuse$stat[3,] == nusemeanstat$out[x]))
  
  nuseiqr = nuse$stat[4,] -  nuse$stat[2,] 
  nuseiqrstat = boxplot.stats(nuseiqr)
  nuseiqrout = sapply(seq_len(length(nuseiqrstat$out)), function(x) which(nuseiqr == nuseiqrstat$out[x]))
  
  out = list("plot" = nuse, "type" = type, "title" = title, "legend" = legend, "scores" = list(mean = nusemean, iqr = nuseiqr), "outliers" = list(mean = nusemeanout, iqr = nuseiqrout))
  class(out) = "aqmobj.nuse"
  return(out) 
}

##RNA Degradation
aqm.rnadeg =function(expressionset, ...)
  {
    numArrays = dim(exprs(expressionset))[2]
    
    acol = sample(brewer.pal(8, "Dark2"), numArrays, replace = (8<numArrays))
    rnaDeg = try(AffyRNAdeg(expressionset, log.it = TRUE, ...))
    if(class(rnaDeg)=='try-error')
      warning("RNA degradation plot from the package 'affy' cannot be produced for this data set.")

    legend = "In <b>Figure FIG</b> a RNA digestion plot is computed on normalized data (so that standard deviation is equal to 1). In this plot each array is represented by a single line. It is important to identify any array(s) that has a slope which is very different from the others. The indication is that the RNA used for that array has potentially been handled quite differently from the other arrays. This diagnostic plot is based on tools provided in the affy package."

    title = "RNA degradation plot"
    type = "Affymetrix specific plots"
    
    out = list("plot" = rnaDeg, "type" = type, "title" = title, "legend" = legend)
    class(out) = "aqmobj.rnadeg"
    return(out)
  }

##QCStats
aqm.qcstats = function(expressionset, ...)
  {                
    qcStats = try(qc(expressionset, ...))

    if(class(qcStats)=='try-error')
      warning("'plot(qcStats)' from the package 'simpleaffy' failed for this dataset.")


    legend = "<b>Figure FIG</b> represents the diagnostic plot recommended by Affymetrix. It is fully described in the simpleaffy.pdf vignette of the package simpleaffy. Any metrics that is shown in red is out of the manufacturer's specific boundaries and suggests a potential problem, any metrics shown in blue is fine."

    title = "Diagnostic plot recommended by Affymetrix"
    type = "Affymetrix specific plots"

    out = list("plot" = qcStats, "type" = type, "title" = title, "legend" = legend)
    class(out) = "aqmobj.qcs"
    return(out)    
  }

##PM / MM
aqm.pmmm = function(expressionset, ...)
{  
  PM = density(as.matrix(log2(pm(expressionset))), ...)
  MM = density(as.matrix(log2(mm(expressionset))), ...)
  PMMM = list(PM = PM, MM = MM)

  legend = "<b>Figure FIG</b> shows the density distributions of the log<sub>2</sub> intensities grouped by the matching of the probes. Blue, density estimate of intensities of perfect match probes (PM) and gray the mismatch probes (MM). We expect that, MM probes having poorer hybridization than PM probes, the PM curve should be shifted to the right of the MM curve."

  title = "Perfect matchs and mismatchs"
  type = "Affymetrix specific plots"
  out = list("plot" = PMMM, "type" = type, "title" = title, "legend" = legend)
  class(out) = "aqmobj.pmmm"
  return(out)    
}

