---
title: Generalized Lotka-Volterra
author: Timothée Poisot
order: 1
...

In this chapter, we will use the generalized Lotka-Volterra model to discuss how
Julia code can be optimized. Most of the key elements have been covered in
chapters [2] and [3].

[2]: 02_competition.html
[3]: 03_leslie.html

# The generalized Lotka-Volterra model

## Model definition

The GLVM is a way to model interactions between an arbitrarily large number of
species. At its core, it requires two elements: a community matrix $\mathbf{A}$,
and a vector of growth rates $\mathbf{r}$. The community matrix describes the
*per capita* effects of species on one another. The diagonal elements are the
intra-specific competition, and the rest of the matrix is all other effects.

<!-- TODO model -->

## Notes on measuring performance

Before we start, a note on compilation in Julia. As mentioned in the primer,
Julia is compiled *Just In Time*. It means that the first execution of
*anything* will trigger the compilation, which in turn will take more time. The
correct result is estimated from the subsequent run steps.

We will try to wrap things up a bit, using a new macro. The comments in the code
will help understand what is going on.

```julia
# This next line defines a macro. A macro is a special type of function, called
# with a @ before its name.
macro benchmark(e)
   quote
      # We will start by running the expression once, to trigger compilation.
      eval($e)
      # Then we pre-allocate the output, which at this point should be automatic!
      times = zeros(Float64, 50)
      # Now, we start a loop of 50 iterations
      for i in 1:length(times)
         # and during each iteration, we record the time it took to evaluate e.
         # The ; at the end of the line means "do not show me the output of e".
         times[i] = @elapsed eval($e);
      end
      # And we get back the average.
      return mean(times)
   end
end
```

Then we can test it:

```julia
@benchmark 2 + 2
```

The output is the *average* time needed, in seconds, to run this particular
expression, over 50 replicate runs.

## Defining the testing dataset

We will use a large number of species, to be able to tell whether we can improve
the performance of the function.

```julia
# Using const for global variables improves performance
const n_species = 1000;
const A = rand((n_species, n_species)) .- 0.5;
const r = rand(n_species) .+ 0.2;
const n = rand(n_species);
```

It is unlikely that these values are going to have any sort of ecological
relevance, but this is not really what this example is about.

# First attempt

## Implementation

We will try to write the most *naive* implementation of this model possible.
Using loops, creating objects, and not caring very much about efficiency. The
objective is to have a baseline, and see how much we can improve on it.

```julia
function glvm_1(n::Array{Float64, 1}, r::Array{Float64, 1}, A::Array{Float64, 2})
   dndt = zeros(Float64, length(n))
   for i = 1:length(n)
      dndt[i] = r[i] * n[i]
      cumulative_effect = 0.0
      for j = 1:length(n)
         cumulative_effect += A[i,j]*n[j]
      end
      dndt[i] += cumulative_effect * n[i]
   end
   return dndt
end
```

## Is it fast?

Let's see.

```julia
@benchmark glvm_1(n, r ,A)
```

Not bad. On the order of $10^{-3}$ seconds. It's a poorly written baseline, and
it's already not too bad. Remember we are talking about 1000 species.

# Second attempt

## Implementation

Ideally, we could avoid the `dndt[i] = r[i] * n[i]` step, because we know how to
multiply arrays element-wise. This is what we will try with this second
approach.

```julia
function glvm_2(n::Array{Float64, 1}, r::Array{Float64, 1}, A::Array{Float64, 2})
   dndt = n .* r
   for i = 1:length(n)
      cumulative_effect = 0.0
      for j = 1:length(n)
         cumulative_effect += A[i,j]*n[j]
      end
      dndt[i] += cumulative_effect * n[i]
   end
   return dndt
end
```

## Is it fast?

Let's see.

```julia
@benchmark glvm_2(n, r ,A)
```

How about that? It performs the same as the previous version. Almost exactly the
same in fact. Well, this can mean one of two things. Either our naive
interpretation was the most efficient, or we are not optimizing the right thing.

# Third attempt

## Implementation

Of course, the GLVM is a linear algebra problem. So let us solve it this way.

```julia
function glvm_3(n::Array{Float64, 1}, r::Array{Float64, 1}, A::Array{Float64, 2})
   return n .* (r - A * n)
end
```

This version has, in addition, the advantage of being so much more readable.
Without having to read through the loops, understanding which variables are
created when and what they do, this code is *intuitive*.

## Is it fast?

Let's see.

```julia
@benchmark glvm_3(n, r ,A)
```

*It's SO FAST YOU GUYS!*

Almost an order of magnitude faster than the loop-based solutions.

# Conclusions

Here are the key points from this chapter:

1. Macros can be defined to evaluate code when needed.
2. Linear algebra is faster than using loops.
3. Using `const` for global variables is a way to improve performance.
