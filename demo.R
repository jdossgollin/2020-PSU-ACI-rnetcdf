# http://iridl.ldeo.columbia.edu/
#  SOURCES .NOAA .NCEP-NCAR .CDAS-1 .MONTHLY .Intrinsic .PressureLevel .phi
# P (500) VALUES
# T (Jan 1980) (Dec 2010) RANGEEDGES
# Y (50N) (30N) RANGEEDGES
# [X Y ]average

phi500 <- "phi_500.nc"

# Step 1: Read in the netcdf data
library(RNetCDF)
nc <- open.nc(phi500)
print.nc(nc)
nc_data <- read.nc(nc)
print(nc_data)
close.nc(nc)

# Step 2: fit a stan model
library(rstan)
rstan_options(auto_write = TRUE)
stan_model <- "normal.stan"
stan_data <- list(N=length(nc_data$phi), y=nc_data$phi)
fit <- stan(file=stan_model, model_name="demo", iter=10000, chains=1, verbose=TRUE, data=stan_data)
print(fit)

# Now we can save these samples to file so we can plot them later
df_of_draws <- as.data.frame(fit)
write.csv(df_of_draws, "output.csv")
