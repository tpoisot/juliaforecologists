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

There are a few things going on in this snippet. Let's look at them line by
line.

`N = Array(Float64, 10)`
: We know that we want 10 timesteps, and that the type
of data returned by our `dNdt` function is `Float64`. This line creates an
*empty* array of the right size and data type. It is not, strictly speaking,
necessary. But, *pre-allocation* of arrays (this is what we're doing here) can
increase performance significantly. It is good practice.

`N[1] = 1.0`
: We need to define an *initial* value for the population size. Since Julia
indexes arrays starting from 1 (like R, unlike Python or C), we put the initial
population size in `N[1]`.

`for i = 2:length(N)`
: This line will start a *loop*. The variable `i` will be incremented from `2`
(because we know the population size at time 1) to `length(N)` (which we know is
10, but this is safer in case we want to change the number of timesteps).

`N[i] = N[i-1] + dNdt(N[i-1], 1.1, 0.3)`
: This is the core of our loop. It will look at the population state at time
`i-1` (since the loop start at 2, it will first look at 1, and so on). This line
essentially performs the operation of *N(t+1) = N(t) + dN(t)/dt*.

`end`
: Finally, this line indicates that this is the end of the loop. Blocks in Julia
are delimited by a final `end`.

## Solving integration issues

# Two populations
