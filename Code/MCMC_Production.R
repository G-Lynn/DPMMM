rm(list=ls())
FIRST_USE = T

burnIn = 25e3
N.MC = 25e3
thin = 1
nCores = 1
if(FIRST_USE) install.packages(c("BayesLogit", "parallel", "ggplot2"), repos = "http://cran.us.r-project.org")

library(BayesLogit)
library(parallel)
library(ggplot2)
library(MASS)

## rdirichlet and rinvgamma scraped from MCMCpack
rDirichlet <- function(n, alpha){
  l <- length(alpha)
  x <- matrix(rgamma(l * n, alpha), ncol = l, byrow = TRUE)
  sm <- x %*% rep(1, l)
  return(x/as.vector(sm))
}

rinvgamma <-function(n,shape, scale = 1) return(1/rgamma(n = n, shape = shape, rate = scale))

directory = "~/DPMMM/"

Code_dir = paste(directory,"Code/",sep="")
Fig_dir = paste(directory,"Figures/",sep="")
Triplet_dir = paste(directory,"Post_Summaries/",sep="")


source(paste(Code_dir,"A_step.R",sep="") )
source(paste(Code_dir,"A_star_step.R",sep="") )
source(paste(Code_dir,"B_star_step.R",sep="") )
source(paste(Code_dir,"lambda_A_step.R", sep="") )
source(paste(Code_dir,"lambda_B_step.R",sep="") )
source(paste(Code_dir,"Omega_step.R",sep="") )
source(paste(Code_dir,"K_Matern.R",sep="") )
source(paste(Code_dir,"eta_Matern.R", sep="") )
source(paste(Code_dir,"ell_prior_step.R",sep="") )
source(paste(Code_dir,"sigma2_Matern_step.R", sep="") )
source(paste(Code_dir,"p_step.R",sep="") )
source(paste(Code_dir,"gamma_step.R",sep="") )
source(paste(Code_dir,"m_gamma_step.R",sep="") )
source(paste(Code_dir,"sigma2_gamma_step.R",sep="") )
source(paste(Code_dir,"pi_gamma_step.R",sep="") )
source(paste(Code_dir,"Bincounts.R",sep="") )
source(paste(Code_dir,"Data_Pre_Proc.R", sep="") )
source(paste(Code_dir,"MCMC_Triplet.R", sep="") )
#parameters for mixture components
K = 5
m_0= 0 
sigma2_0 = 1 #.01
r_gamma = 101
s_gamma = 1

ell = c(1,2,3,4,5,15)
L = length(ell)
ell_0 = c( rep(.5/(L-1),(L-1) ), .5)

#sampling for sigma2
delta = 2
r_0 = 51
s_0 = (r_0 - 1)*(1-exp(-delta^2/ell^2)) 

#parameters for pi_gamma
alpha_gamma = 1/K


Triplet_meta = read.csv("http://www2.stat.duke.edu/~st118/Jenni/STCodes/ResultsV2/All-HMM-Poi-selected.csv", stringsAsFactors=F)
Triplet_meta = unique(Triplet_meta)
Triplet_meta = Triplet_meta[order(Triplet_meta[,"SepBF"], decreasing=T),]
triplets = 2

source(paste(Code_dir,"eta_bar_mixture.R",sep="") )
source(paste(Code_dir,"MinMax_Prior.R",sep="") )
#triplets is the index (or row number) of the triplet in the Triplet_Meta dataframe
pt = proc.time()[3]
mclapply(triplets, function(triplet) MCMC.triplet(triplet, ell_0, ETA_BAR_PRIOR, MinMax.Prior), mc.cores = nCores)
proc.time()[3] - pt




