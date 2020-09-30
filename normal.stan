// Fit a normal distribution
data{
  int N;
  vector[N] y;
}
parameters{
  real mu;
  real<lower=0> sigma;
}
model{
  // data generating process
  y ~ normal(mu, sigma);
  // priors
  mu ~ normal(0, 10000); // mid-troposphere geopotential heights are generally in the thousands of meters
  sigma ~ normal(0, 1000);
}
