---
title: A model of interspecific competition
author: Timothée Poisot
order: 1
...

In this example, we will build simple models of competition between two species.

# Setting up the model

Let us first define a function for logistic growth. This function will return
the growth rate of a population of size `N` as a function of its growth rate `r`
and intraspecific competition rate `q`.

```julia
function dNdt(N::Float64, r::Float64, q::FLoat64)
  return N * (r - q * N)
end
```
