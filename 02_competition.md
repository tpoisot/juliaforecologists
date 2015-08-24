---
title: Models of competition
author: Timothée Poisot
order: 1
...

In this example, we will build simple models of competition between two species.
We will start from a single-population model, and add some complexity.

# One population

Let us first define a function for logistic growth. This function will return
the growth rate of a population of size `N` as a function of its growth rate `r`
and intraspecific competition rate `q`.

## Defining the model

The mathematical expression of this model is

$$
\frac{1}{N}\frac{dN}{dt} = r - qN
$$

```julia
function dNdt(N::Float64, r::Float64, q::Float64)
  return N * (r - q * N)
end
```

## Running the model

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

# Solving integration issues

This approach is what is known as *Euler* integration with a step size of 1,
*i.e.* the derivative $dN/dt$ is simply added to $N$. This gives rises to all
sorts of behavior very technical described as "funky"; we want to avoid them,
and this require a numerical integration scheme.

We will go for an easy to implement method: the midpoint method. Let us call $f$
the derivative, and $y$ the quantity of interest.

$$
y_{t+1} = y_{t} + h \times f\left(y_{t} + \frac{h}{2}f(y_{t})\right)
$$

This can be implemented in Julia:

```julia
function midpoint(f::Function)
  dxdt = (x) -> f(x+(1.0/2.0)*f(x))
  return dxdt
end
```

Wait, what? Yes, this returns a function, as opposed to performing the actual
operation. But fear not, for this makes no difference in the way you use it. Let
me demonstrate:

```julia
our_problem = (x) -> dNdt(x, 1.1, 0.3)
n0 = 2.0
midpoint(our_problem)
```

See, this returns a function. We can use it in any way we want:

```julia
n0 + midpoint(our_problem)(n0)
```

Compare this to the other solution:

```julia
n0 + our_problem(n0)
```

There are actually other, more elegant or more efficient, solutions to this
particular problem. Yet this solution efficiently demonstrate how you can use
functions to build other functions. The advantage of using as much functions as
you can is that they are re-usable (if we define a new `our_problem` function,
this approach will work just as well), and optimized by Julia's compiler.

# Two populations

# Conclusions

Here are the key points from this chapter:

1. Functions should be the basis of most, if not all, code.
2. Functions can return other functions.
