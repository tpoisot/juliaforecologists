---
title: Models of competition
author: Timothée Poisot
order: 1
...

In this example, we will build simple models of competition between two species.

# One population

Let us first define a function for logistic growth. This function will return
the growth rate of a population of size `N` as a function of its growth rate `r`
and intraspecific competition rate `q`.

```julia
function dNdt(N::Float64, r::Float64, q::Float64)
  return N * (r - q * N)
end
```

## Testing the model

How much would a population of size 1 grow over a single timestep, if there is
no intraspecific competition at all?

```julia
dNdt(1.0, 1.1, 0.0)
```

Let us simulate this model over 10 timesteps:

```julia
N = Array(Float64, 10)
N[1] = 1.0
for i = 2:length(N)
  N[i] = N[i-1] + dNdt(N[i-1], 1.1, 0.3)
end
```

Note that we *pre-allocate* the resulting array (`N = Array(Float64, 10)`). This
lines creates an array of `10` elements (of the `Float64` type). Pre-allocating
is recommended, since it essentially "informs" the

## Solving integration issues

# Two populations
