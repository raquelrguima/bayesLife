\name{run.e0.mcmc}
\alias{run.e0.mcmc}
\alias{continue.e0.mcmc}
\alias{bayesLife.mcmc.set}

\title{
Running Markov Chain Monte Carlo for Parameters of Life Expectancy
}
\description{
Runs (or continues running) MCMCs for simulating the life expectancy for all countries of the world, using a Bayesian hierarchical model.
}
\usage{
run.e0.mcmc(gender = "M", nr.chains = 3, iter = 1e+05, 
    output.dir = file.path(getwd(), "bayesLife.output"), 
    thin = 10, replace.output = FALSE, 
    start.year = 1950, present.year = 2010, wpp.year = 2008, 
    my.e0.file = NULL, buffer.size = 100, 
    a = c(15.7669391, 40.9658241, 0.2107961, 
          19.8188061, 2.9306625, 0.400688628), 
    delta = c(1.887, 1.982, 1.99, 1.949, 0.995, 0.4), 
    tau = c(15.5976503, 23.650006, 14.5056919, 
            14.718598, 3.4514285, 0.5667531), 
    Triangle.ini = list(NULL, NULL, NULL, NULL), k.ini = NULL, 
    z.ini = NULL, lambda.ini = list(NULL, NULL, NULL, NULL), 
    lambda.k.ini = NULL, lambda.z.ini = NULL, omega.ini = NULL, 
    Triangle.ini.low = c(10, 30, 0.1, 10), 
    Triangle.ini.up = c(30, 50, 10, 30), k.ini.low = 1, k.ini.up = 5, 
    z.ini.low = 1e-04, z.ini.up = 1.1, 
    lambda.ini.low = c(1e-04, 1e-04, 1e-04, 1e-04), 
    lambda.ini.up = c(0.1, 0.1, 0.1, 0.1), 
    lambda.k.ini.low = 0.1, lambda.k.ini.up = 1, 
    lambda.z.ini.low = 1, lambda.z.ini.up = 40, 
    omega.ini.low = 0.1, omega.ini.up = 5, 
    Triangle.c.ini.norm = list(round(
    	Triangle.ini.low + (Triangle.ini.up - Triangle.ini.low)/2), 
                               c(2, 2, 2, 2)), 
    k.c.ini.norm = c(round(k.ini.low + (k.ini.up - k.ini.low)/2), 2), 
    z.c.ini.norm = c(round(z.ini.low + (z.ini.up - z.ini.low)/2, 2), 0.2), 
    Triangle.c.width = c(4, 6, 3, 4), k.c.width = 1, z.c.width = 0.2, 
    nu = 4, dl.p1 = 9, dl.p2 = 9, seed = NULL, 
    parallel = FALSE, nr.nodes = nr.chains, verbose = FALSE, \dots)
    
continue.e0.mcmc(iter, chain.ids = NULL, 
    output.dir = file.path(getwd(), "bayesLife.output"), 
    parallel = FALSE, nr.nodes = NULL, verbose = FALSE, \dots)
}

\arguments{
  \item{gender}{Gender for which to run the simulation. Possible values are \dQuote{M} for male and \dQuote{F} for female.}
  \item{nr.chains}{Number of MCMC chains to run.}
  \item{iter}{Number of iterations to run in each chain.}
  \item{output.dir}{Directory which the simulation output should be written into.}
  \item{thin}{Thinning interval between consecutive observations to be stored on disk.}
  \item{replace.output}{If \code{TRUE}, existing outputs in \code{output.dir} will be replaced by results of this simulation.}
  \item{start.year}{Start year for using historical data.}
  \item{present.year}{End year for using historical data.}
  \item{wpp.year}{Year for which WPP data is available (see also \link{UN2008e0}).}
  \item{my.e0.file}{File name containing user-specified e0 time series for one or more countries. It can include a subset of countries contained in the UN WPP file, as well as a set of new countries. In the former case,
  	the function replaces the corresponding country data from the UN WPP file by values in this file. Only columns are replaced that match column names of the WPP file, and in addition, columns \sQuote{last.observed} and \sQuote{include_code} are used, if present. Countries are matched using the column \sQuote{country_code} (see also \link{UN2008e0}). In addition, in order the countries to be included in the simulation, in both cases (whether they are included in the UN data file or not), they must be contained in the UN table of locations and the \sQuote{include_code} in that table must be set to 2 (see \link{WPP2008_LOCATIONS}). If the column \sQuote{include_code} is present in \code{my.e0.file}, its value overwrites the corresponding include code in the location file, unless is -1.  See also Details below.}
  \item{buffer.size}{Buffer size (in number of [thinned] iterations) for keeping data in the memory. The smaller the \code{buffer.size} the more often will the process access the hard disk and thus, the slower the run. On the other hand, the smaller the \code{buffer.size} the less data will be lost in case of failure.}
  \item{a}{A vector of the \eqn{a_1}, \dots ,\eqn{a_6} parameters, which are the prior means of the world-level parameters 
  			(\eqn{\Delta_1}{Triangle_1}, \dots, \eqn{\Delta_4}{Triangle_4}, \eqn{k}, \eqn{z}).}
  \item{delta}{A vector of the \eqn{\delta_1}{delta_1}, \dots ,\eqn{\delta_6}{delta_6} parameters, 
  	which are the prior standard deviations of the world-level parameters 
  			(\eqn{\Delta_1}{Triangle_1}, \dots, \eqn{\Delta_4}{Triangle_4}, \eqn{k}, \eqn{z}).}
  \item{tau}{A vector of the \eqn{\tau_1}{tau_1}, \dots ,\eqn{\tau_6}{tau_6} parameters, which is the square root rate of the prior Gamma distribution of the world-level parameters 
  			(\eqn{\lambda_1}{lambda_1}, \dots, \eqn{\lambda_4}{lambda_4}, \eqn{\lambda_k}{lambda_k}, \eqn{\lambda_z}{lambda_z}).}
  \item{Triangle.ini}{List (of length four) of initial values for \eqn{\Delta_1}{Triangle_1}, \dots, \eqn{\Delta_4}{Triangle_4}. Each list item should be of the length \code{nr.chains}. If a list item is \code{NULL}, the initial values are equally spaced between \code{Triangle.ini.low} and \code{Triangle.ini.up}. By default, if there is just one chain, the value is the middle point of the interval.}
  \item{k.ini}{An array of length \code{nr.chains} of initial values for \eqn{k}. By default, the initial values are equally spaced between \code{k.ini.low} and \code{k.ini.up}. If \code{nr.chains=1} and \code{k.ini} is \code{NULL}, the initial value is the middle point of the interval.}
  \item{z.ini}{An array of length \code{nr.chains} of initial values for \eqn{z}. By default, the initial values are equally spaced between \code{z.ini.low} and \code{z.ini.up}. If \code{nr.chains=1} and \code{z.ini} is \code{NULL}, the initial value is the middle point of the interval.}
  \item{lambda.ini}{List (of length four) of initial values for \eqn{\lambda_1}{lambda_1}, \dots, \eqn{\lambda_4}{lambda_4}. Each list item should be of the length \code{nr.chains}. If a list item is \code{NULL}, the initial values are equally spaced between \code{lambda.ini.low} and \code{lambda.ini.up}. By default, if there is just one chain, the value is the middle point of the interval.}
  \item{lambda.k.ini}{An array of length \code{nr.chains} of initial values for \eqn{\lambda_k}{lambda_k}. By default, the initial values are equally spaced between \code{lambda.k.ini.low} and \code{lambda.k.ini.up}. If \code{nr.chains=1} and \code{lambda.k.ini} is \code{NULL}, the initial value is the middle point of the interval.}
  \item{lambda.z.ini}{An array of length \code{nr.chains} of initial values for \eqn{\lambda_z}{lambda_z}. By default, the initial values are equally spaced between \code{lambda.z.ini.low} and \code{lambda.z.ini.up}. If \code{nr.chains=1} and \code{lambda.z.ini} is \code{NULL}, the initial value is the middle point of the interval.}
  \item{omega.ini}{An array of length \code{nr.chains} of initial values for \eqn{\omega}{omega}. By default, the initial values are equally spaced between \code{omega.ini.low} and \code{omega.ini.up}. If \code{nr.chains=1} and \code{omega.ini} is \code{NULL}, the initial value is the middle point of the interval.}
  \item{Triangle.ini.low, Triangle.ini.up}{A vector of length four. They are the lower and upper bounds for initial values of \eqn{\Delta_1}{Triangle_1}, \dots, \eqn{\Delta_4}{Triangle_4}. An \eqn{i}-th item is only used if \code{Triangle.ini[[i]]} is \code{NULL}.}
  \item{k.ini.low, k.ini.up}{Single value giving the lower and upper bounds for initial values of \eqn{k}. It is only used if \code{k.ini} is \code{NULL}.}
  \item{z.ini.low, z.ini.up}{Single value giving the lower and upper bounds for initial values of \eqn{z}. It is only used if \code{z.ini} is   
  	\code{NULL}.}
 \item{lambda.ini.low, lambda.ini.up}{A vector of length four. They are the lower and upper bounds for initial values of \eqn{\lambda_1}{lambda_1}, \dots, \eqn{\lambda_4}{lambda_4}. An \eqn{i}-th item is only used if \code{lambda.ini[[i]]} is \code{NULL}.}
  \item{lambda.k.ini.low, lambda.k.ini.up}{Single value giving the lower and upper bounds for initial values of \eqn{\lambda_k}{lambda_k}. It is only used if \code{lambda.k.ini} is \code{NULL}.}
  \item{lambda.z.ini.low, lambda.z.ini.up}{Single value giving the lower and upper bounds for initial values of \eqn{\lambda_z}{lambda_z}. It is only used if \code{lambda.z.ini} is \code{NULL}.}
  \item{omega.ini.low, omega.ini.up}{Single value giving the lower and upper bounds for initial values of \eqn{\omega}{omega}. It is only used if \code{omega.ini} is \code{NULL}.}
  \item{Triangle.c.ini.norm}{A list with two elements, each of them being a vector of size four. The first and second element in the list corresponds to the means and standard deviation, respectively, for the initial values of the country-specific parameters \eqn{\Delta_1^c}{Triangle_1_c}, \dots, \eqn{\Delta_4^c}{Triangle_4_c} which are drawn from a normal distribution.}
  \item{k.c.ini.norm}{A vector of length two. The first and second element corresponds to the means and standard deviation, respectively, for the initial values of the country-specific parameters \eqn{k^c} which are drawn from a normal distribution truncted at zero.}
  \item{z.c.ini.norm}{A vector of length two. The first and second element corresponds to the means and standard deviation, respectively, for the initial values of the country-specific parameters \eqn{z^c} which are drawn from a normal distribution truncted at zero.}
  \item{Triangle.c.width}{Width for slice sampling used when updating the country-specific parameters \eqn{\Delta_i^c}{Triangle_i_c} with \eqn{i=1,\dots,4}.}
  \item{k.c.width}{Width for slice sampling used when updating the country-specific parameters \eqn{k^c}.}
  \item{z.c.width}{Width for slice sampling used when updating the country-specific parameters \eqn{z^c}.}
  \item{nu}{The shape parameter of the Gamma distributions of all \eqn{\lambda}{lambda} parameters is \code{nu/2}.}
  \item{dl.p1, dl.p2}{Values of the parameters \eqn{p_1} and \eqn{p_2} of the double logistic function.}
  \item{seed}{Seed of the random number generator. If \code{NULL} no seed is set. It can be used to generate reproducible results.}
  \item{parallel}{Logical determining if the simulation should run multiple chains in parallel. If it is \code{TRUE}, the package \pkg{\link[snowFT]{snowFT}} is required.}
  \item{nr.nodes}{Relevant only if \code{parallel} is \code{TRUE}. It gives the number of nodes for running the simulation in parallel. By default it equals to the number of chains.}
  \item{verbose}{Logical switching log messages on and off.}
  \item{\dots}{Additional parameters to be passed to the function \code{\link[snowFT]{performParallel}}, if \code{parallel} is \code{TRUE}.}
  \item{chain.ids}{Array of chain identifiers that should be resumed. If it is \code{NULL}, all existing chains in \code{output.dir} are resumed.}
}
\details{
	The function \code{run.e0.mcmc} creates an object of class \code{\link{bayesLife.mcmc.meta}} and stores it in \code{output.dir}.  It launches \code{nr.chains} MCMCs, either sequentially or in parallel.  Parameter traces of each chain are stored (as ASCII files) in a subdirectory of \code{output.dir}, called \code{mc}\emph{x} where \emph{x} is the identifier of that chain.  There is one file per parameter, named after the parameter with the suffix \dQuote{.txt}.  Country-specific parameters have the suffix \code{_country}\emph{c} where \emph{c} is the country code.  In addition to the trace files, each \code{mc}\emph{x} directory contains the object \code{\link{bayesLife.mcmc}} in binary format.  All chain-specific files  are written into disk after the first, last and each \code{buffer.size}-th (thinned) iteration.
	
Using the function \code{continue.e0.mcmc} one can continue simulating an existing MCMCs by \code{iter} iterations for either all or selected chains.

For simulation of the hyperparameters of the Bayesian hierarchical model, all countries are used that are included in the UN WPP file (\link{UN2008e0}), possibly complemented by the \code{my.e0.file}, that have \code{include_code} (in the UN location file) equal to 2. The hyperparameters are used to simulate country-specific parameters, which is done for all countries with \code{include_code} equal 1 or 2. Note that users can overwrite the UN include code by including the column \code{include_code} into the the \code{my.e0.file}. The following values are recognized: -1 (do not overwrite the UN WPP include code), 0 (ignore), 1 (include in prediction but not estimation), 2 (include in both, estimation and prediction). Thus, the set of countries included in the estimation and prediction can be fully specified by the user.
}
\value{
	An object of class \code{bayesLife.mcmc.set} which is a list with two components:
	\item{meta}{An object of class \code{\link{bayesLife.mcmc.meta}}.}
	\item{mcmc.list}{A list of objects of class \code{\link{bayesLife.mcmc}}, one for each MCMC.}
}
\references{
J. L. Chunn, A. E. Raftery, P. Gerland (2010): Bayesian Probabilistic Projections of Life Expectancy for All Countries.  Working Paper nr. 105, Center for Statistics and the Social Sciences, University of Washington. \url{http://www.csss.washington.edu/Papers}
}
\author{
Hana Sevcikova
}
%%\note{
%%  ~~further notes~~
%%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{get.e0.mcmc}}, \code{\link{summary.bayesLife.mcmc.set}}.
}
\examples{
\dontrun{
m <- run.e0.mcmc(nr.chains=1, iter=5, thin=1, verbose=TRUE)
summary(m)
m <- continue.e0.mcmc(iter=5, verbose=TRUE)
summary(m)}
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{distribution}
\keyword{multivariate}