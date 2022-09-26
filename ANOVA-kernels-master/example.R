library(kergp)
library(DiceDesign)
library(rgl)

source("functions.R")

## params
ftest <- function(x){
	10*sin(pi*x[,1]*x[,2]) + 20*(x[,3]-0.5)^2 + 10*x[,4] + 5*x[,5]+rnorm(dim(x)[1])
}

d <- 6		# dimension
n <- 64		# nb points plan d'exp
X <- lhsDesign(n,d)$design
X <- data.frame(maximinSA_LHS(X)$design)
names(X)<-paste("x",1:d,sep="")
Y <- data.frame(ftest(X))
names(Y)<-"Y"

## créer objet de classe covariance
kas <- covMan(kernel = kanova0,
			d = 6,
			hasGrad = TRUE,
			parLower = c(0,rep(c(0.001,0.01),d)),
			parUpper = c(100,rep(c(100,5),d)),
			parNames = c( "sig2", paste("alpha",1:d,sep="_"), paste("theta",1:d,sep="_")),
			par = c(1,rep(c(1,.5),d))
			)

# tps calcul matrice de cov
system.time(K <- covMat(kas,data.frame(X)))

## créer et optimiser le modèle de krigeage 
m <- gp(Y ~ 1, data = data.frame(Y, X),
               inputs = names(X), cov = kas, 
               noise = TRUE, varNoiseLower=1e-3,
               beta=0,
               parCovIni=coef(kas))

## tracer les effets principaux
#pdf("effprin.pdf",width=10,height=6,paper='special') 
x <- matrix(0:100/100,101)
par(mfrow=c(2,3))
for(ind in 1:d){
	pred <- predPart(x,m,ind)
	effPrinAn <- ftest_effprin(x, ind, mean(pred[,1]))
	plotGPR(x, pred, ylim=c(-5,4))
	lines(x, effPrinAn, col="red", type='l', lty=2)
	text(0.95, -4.8, paste0("x", ind), cex=2)
}
#dev.off()


# plot interactions
ind <- c(1,2)
ngrid <- 26
grid <- 0:(ngrid-1)/(ngrid-1)
Xnew <- expand.grid(grid,grid)
names(Xnew)<-paste("x",ind,sep="")

pred <- predPart(Xnew,m,ind)
effPrinAn <- ftest_effprin(Xnew,ind,mean(pred[,1]))

open3d()
persp3d(grid,grid,matrix(pred$mean,ngrid),color=darkBlue,xlab='x1',ylab='x2',zlab='',zlim=c(-7,5))
surface3d(grid,grid,matrix(effPrinAn,ngrid),color='red')
surface3d(grid,grid,matrix(pred$lower95,ngrid),color=lightBlue,alpha=0.75)
surface3d(grid,grid,matrix(pred$upper95,ngrid),color=lightBlue,alpha=0.75)

#snapshot3d("interaction.png")

# Sobol Indices
IND <- list(1,2,3,4,5,6,c(1,2))
SI <- SobolIndices(m,IND)
names(SI) <- paste("S",c(1,2,3,4,5,6,12),sep="_")
print(round(SI,2))
