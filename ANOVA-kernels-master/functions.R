## kernel as in Durrande et al, JMA 2013
cppFunction(' NumericVector kanova0(NumericVector x, NumericVector y, NumericVector par){
	int d = x.size();
	double z, int1, int2, intint, dz_dpar3, dint1_dpar3, dint2_dpar3, dintint_dpar3;
	NumericVector K(1), ker(d), der_ker(2*d+1,1.),par2;
	double pi = 3.141592653589793238462643383280;
	double sqrt2pi = sqrt(2*pi);
	K[0] = par[0];
	der_ker[0] = 1/par[0];
	for(int i=0 ; i<d ; i++){
		par2 = par[i+d+1];
		// kernel value
		z = exp(-pow((x[i]-y[i])/par[i+d+1],2)/2);	
		int1 = sqrt2pi*par[i+d+1] * (pnorm((1-x[i])/par2)[0] - pnorm(-x[i]/par2)[0]);
		int2 = sqrt2pi*par[i+d+1] * (pnorm((1-y[i])/par2)[0] - pnorm(-y[i]/par2)[0]);
		intint = pow(par[i+d+1],2) * (sqrt2pi/par[i+d+1]*(2*pnorm(1/par2)[0]-1) + 2*exp(-.5/pow(par[i+d+1],2)) - 2);
		der_ker[i+1] = z-int1*int2/intint;
		ker[i] = 1 + par[i+1]*der_ker[i+1];
		K[0] = K[0] * ker[i];
		// kernel derivative
		dz_dpar3 = z*pow(x[i]-y[i],2)/pow(par[i+d+1],3);
		dint1_dpar3 = int1/par[i+d+1] + sqrt2pi * ((x[i]-1)/par[i+d+1]*dnorm((1-x[i])/par2)[0]-x[i]/par[i+d+1]*dnorm(-x[i]/par2)[0]);
		dint2_dpar3 = int2/par[i+d+1] + sqrt2pi * ((y[i]-1)/par[i+d+1]*dnorm((1-y[i])/par2)[0]-y[i]/par[i+d+1]*dnorm(-y[i]/par2)[0]);
		dintint_dpar3 = 2/par[i+d+1]*intint - sqrt2pi*(2*pnorm(1/par2)[0]-1) - 2*sqrt2pi/par[i+d+1]*dnorm(1/par2)[0] + 2/par[i+d+1] *exp(-1/pow(par[i+d+1],2)/2);
		der_ker[i+d+1] = par[i+1]*(dz_dpar3 - ((dint1_dpar3*int2 + int1*dint2_dpar3)*intint - int1*int2*dintint_dpar3)/pow(intint,2))/ker[i];
		der_ker[i+1] = der_ker[i+1]/ker[i];
	}
	// return
	der_ker = der_ker * K[0];
	K.attr("gradient") = der_ker;
	return K;
}' )


cppFunction(' NumericVector k0(NumericVector x, NumericVector y, NumericVector par){
	int d = x.size();
	double z, int1, int2, intint, dz_dpar3, dint1_dpar3, dint2_dpar3, dintint_dpar3;
	NumericVector K(1), ker(d), der_ker(d+1,1.),par2;
	double pi = 3.141592653589793238462643383280;
	double sqrt2pi = sqrt(2*pi);
	K[0] = par[0];
	der_ker[0] = 1/par[0];
	for(int i=0 ; i<d ; i++){
		par2 = par[i+1];
		// kernel value
		z = exp(-pow((x[i]-y[i])/par[i+1],2)/2);	
		int1 = sqrt2pi*par[i+1] * (pnorm((1-x[i])/par2)[0] - pnorm(-x[i]/par2)[0]);
		int2 = sqrt2pi*par[i+1] * (pnorm((1-y[i])/par2)[0] - pnorm(-y[i]/par2)[0]);
		intint = pow(par[i+1],2) * (sqrt2pi/par[i+1]*(2*pnorm(1/par2)[0]-1) + 2*exp(-.5/pow(par[i+1],2)) - 2);
		ker[i] = z-int1*int2/intint;
		K[0] = K[0] * ker[i];
		// kernel derivative
		dz_dpar3 = z*pow(x[i]-y[i],2)/pow(par[i+1],3);
		dint1_dpar3 = int1/par[i+1] + sqrt2pi * ((x[i]-1)/par[i+1]*dnorm((1-x[i])/par2)[0]-x[i]/par[i+1]*dnorm(-x[i]/par2)[0]);
		dint2_dpar3 = int2/par[i+1] + sqrt2pi * ((y[i]-1)/par[i+1]*dnorm((1-y[i])/par2)[0]-y[i]/par[i+1]*dnorm(-y[i]/par2)[0]);
		dintint_dpar3 = 2/par[i+1]*intint - sqrt2pi*(2*pnorm(1/par2)[0]-1) - 2*sqrt2pi/par[i+1]*dnorm(1/par2)[0] + 2/par[i+1] *exp(-1/pow(par[i+1],2)/2);
		der_ker[i+1] = (dz_dpar3 - ((dint1_dpar3*int2 + int1*dint2_dpar3)*intint - int1*int2*dintint_dpar3)/pow(intint,2))/ker[i];
	}
	// return
	der_ker = der_ker * K[0];
	K.attr("gradient") = der_ker;
	return K;
}' )


predPart <- function(x,m,ind){
	kpart <- covMan(kernel = k0,  d=length(ind), hasGrad = TRUE, parNames = c( "sig2", paste("theta",ind,sep="_")))
	coef(kpart)[1] <- coef(m$covariance)[1]*prod(coef(m$covariance)[1+ind])
	coef(kpart)[1+1:length(ind)] <- coef(m$covariance)[1+m$dim$d+ind]
	Xpart <- as.matrix(m$X[,ind],ncol=length(ind))
	kpartx <- covMat(kpart,x,Xpart)
	Kpart <- covMat(kpart,x)
	K <- covMat(m$covariance,m$X) 
	if(!is.null(m$varNoise)){
		K <-  K + diag(rep(m$varNoise,m$dim$n))
	}
	K_1 <- solve(K)
	mp <- kpartx %*% K_1 %*% m$y
	covp <- Kpart - kpartx %*% K_1 %*% t(kpartx)
	sdp=sqrt(abs(diag(covp)))
	return(data.frame(mean=mp,cov=covp,lower95=mp-1.96*sdp,upper95=mp+1.96*sdp))
}

pred <- function(x,m,ind){
	kx <- covMat(m$covariance,x,m$X)
	Kx <- covMat(m$covariance,x) 
	K <- covMat(m$covariance,m$X) 
	if(!is.null(m$varNoise)){
		K <-  K + diag(rep(m$varNoise,m$dim$n))
	}
	K_1 <- solve(K)
	mp <- kx %*% K_1 %*% m$y
	covp <- Kx - kx %*% K_1 %*% t(kx)
	sdp=sqrt(abs(diag(covp)))
	return(data.frame(mean=mp,cov=covp,lower95=mp-1.96*sdp,upper95=mp+1.96*sdp))
}


plotGPR <- function(x,pred,xlab="",ylab="",ylim=NULL,add=FALSE){
  m <- pred$mean
  low95 <- pred$lower95
  upp95 <- pred$upper95
  if(is.null(ylim)) ylim <- range(low95-0.5,upp95+0.5)
  par(mar=c(4.5,5.1,1.5,1.5))
  if(!add){
    plot(x, m, type="n", xlab=xlab,ylab=ylab, ylim=ylim, cex.axis=1.5,cex.lab=2)
  }
  #plot(x, m, type="n", xlab="$x$",ylab=ylab, ylim=range(7.5,13.5),cex.axis=1.5,cex.lab=2)
  polygon(c(x,rev(x)),c(upp95,rev(low95)),border=NA,col=lightblue)
  lines(x,m,col=darkblue,lwd=3)
  lines(x,low95,col=darkbluetr)  
  lines(x,upp95,col=darkbluetr)  
}



SobolIndices <- function(m,IND){
  d <- m$dim$d
	x <- matrix(0:100/100,ncol=1)
	Gamma <- array(0,c(m$dim$n,m$dim$n,d))
	prodGammaNum <- matrix(1,m$dim$n,m$dim$n)
	prodGammaDen <- matrix(1,m$dim$n,m$dim$n)
	for(i in 1:d){
		#kpart <- covMan(kernel = k0,  kernName = "kpart", gradFlag = TRUE, parNames = c( "sig2", paste("theta",i,sep="_")))
		kpart <- covMan(kernel = k0,  d=1, hasGrad = TRUE, parNames = c( "sig2", paste("theta",ind,sep="_")))
		coef(kpart)[1] <- coef(m$covariance)[1+i]
		coef(kpart)[2] <- coef(m$covariance)[1+m$dim$d+i]
		kx <- covMat(kpart,data.frame(x1=x),data.frame(x1=m$X[,i]))
		for(j in 1:m$dim$n){
			for(k in 1:j){
				Gamma[j,k,i] <- Gamma[k,j,i] <- mean(kx[,k]*kx[,j])  
			}
		}
		prodGammaDen <- prodGammaDen * (Gamma[,,i] + 1) 
	}
	K <- covMat(m$covariance,m$X) 
	if(!is.null(m$varNoise)){
	K <-  K + diag(rep(m$varNoise,m$dim$n))
	}
	K_1 <- solve(K)
	K_1Y <- K_1 %*% m$y
	den <- t(K_1Y) %*% (prodGammaDen - 1) %*% K_1Y
	S <- rep(0,length(IND))
	for(j in 1:length(IND)){
		prodGammaNum <- matrix(1,m$dim$n,m$dim$n)
		for(i in 1:d){
			if(sum(i==IND[[j]])) prodGammaNum <- prodGammaNum * Gamma[,,i]
		}
		S[j] <- t(K_1Y) %*% prodGammaNum %*% K_1Y /  den
	}
	return(S)
}

ftest_effprin <- function(x,ind,mean){
	if(length(ind)==1){
		if(ind==1 || ind==2){
			fpa <- 10/pi/x*(1-cos(pi*x))
			fpa[1] <- 0
			fpa <- fpa-mean(fpa)+mean(mean)
		}
		if(ind==3) fpa <- 20*(x-0.5)^2 - 20/12
		if(ind==4) fpa <- 10*x -5 
		if(ind==5) fpa <- 5*x- 2.5
		if(ind>5) fpa <- 0*x
	}
	if(length(ind)==2){
		if(sum(c(ind==1,ind==2))==2){
			aa <- 10/pi/x[,1]*(1-cos(pi*x[,1]))
			aa[is.nan(aa)] <- 0
			bb <- 10/pi/x[,2]*(1-cos(pi*x[,2]))
			bb[is.nan(bb)] <- 0
			inta <- 10*sin(pi*x[,1]*x[,2]) - aa - bb
			fpa <- inta- mean(inta) + mean(mean)
		}else fpa <- 0*x[,1]
	}
	return(fpa)
}




#########################################
## colors

lightblue <- rgb(114/255,159/255,207/255,.3) ; darkblue <- rgb(32/255,74/255,135/255,1) ; darkbluetr <- rgb(32/255,74/255,135/255,.3)
darkPurple <- "#5c3566" ; darkBlue <- "#204a87" ; darkGreen <- "#4e9a06" ; darkChocolate <- "#8f5902" ; darkRed  <- "#a40000" ; darkOrange <- "#ce5c00" ; darkButter <- "#c4a000"


Aluminium1 <- "#eeeeec" ; 
Aluminium2 <- "#d3d7cf" ; 
Aluminium3 <- "#babdb6" ; 
Aluminium4 <- "#888a85" ; 
Aluminium5 <- "#555753" ; 
Aluminium6 <- "#2e3436" ; 

lightPurple <- "#ad7fa8" ; 
lightBlue <- "#729fcf" ; 
lightGreen <- "#8ae234" ; 
lightChocolate <- "#e9b96e" ; 
lightRed <- "#ef2929" ; 
lightOrange <- "#fcaf3e" ; 
lightButter <- "#fce94f" ; 

mediumPurple <- "#75507b" ; 
mediumBlue <- "#3465a4" ; 
mediumGreen <- "#73d216" ; 
mediumChocolate <- "#c17d11" ; 
mediumRed <- "#cc0000" ; 
mediumOrange <- "#f57900" ; 
mediumButter <- "#edd400" ; 

darkPurple <- "#5c3566" ; 
darkBlue <-  "#204a87" ; 
darkGreen <- "#4e9a06" ; 
darkChocolate <- "#8f5902" ; 
darkRed <- "#a40000" ; 
darkOrange <- "#ce5c00" ; 
darkButter <- "#c4a000"

Tango <- c(Aluminium3, darkPurple, darkChocolate, mediumRed, lightBlue, darkOrange, Aluminium2, lightOrange, Aluminium4, mediumBlue, darkButter, lightPurple, Aluminium6, lightChocolate, lightGreen, darkRed, darkGreen, mediumChocolate, mediumOrange, Aluminium1, mediumGreen, mediumPurple, lightRed, mediumButter, Aluminium5, lightButter, darkBlue )
lightTango <- c(lightBlue, lightRed, lightGreen, lightChocolate, lightPurple, lightOrange, lightButter)
mediumTango <- c(mediumBlue, mediumRed, mediumGreen, mediumChocolate, mediumPurple, mediumOrange, mediumButter)
darkTango <- c(darkBlue, darkRed, darkGreen, darkChocolate, darkPurple, darkOrange, darkButter)









