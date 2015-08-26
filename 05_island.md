---
title: Neutral dynamics on islands
author: Timothée Poisot
order: 1
...

In this chapter, we will use the example of neutral dynamics in a
mainland/island system to approach how to do stochastic simulations with Julia.

# The ecological scenario

There is a mainland, on which $S$ species live. Close to this mainland is an
island, on which up to $k$ individuals can live. All of these individuals have a
probability $e$ of dying, which frees up a spot. Any spot can be filled by
immigration from the mainland, with probability $m$, or is filled by local
reproduction from the island.

Let us go through the different solutions. A spot occupied by a species $x$ can
remain occupied by a species $x$ if there is no mortality event, which happens
with probability $(1-e)$. It can be replaced by one of the local species if
there is a mortality event *but* no immigration event (with probability
$e(1-m)$), or by one of the mainland species if there is both mortality *and*
immigration ($em$).

This is essentially Hubbell's zero-sum drift model, as all species have equal
chance of dying, reproducing, and immigrating.

# Setting up the model

## Data structure

We will need to define a few global variables, for the number of species, and
the number of individuals on the island.

```julia
const S, k = 100, 400
```

Ain't this a cool notation? Julia is able to *unpack* the different arguments,
so you can assign more than one variable per line. This comes at a cost in terms
of readability.

The island can be modeled by an array of size `k`, which will hold an integer
representing the number of the species to which every individual belongs. We
will therefore pre-allocate this array. We will also pre-allocate a temporary
array, which will be used to store the intermediate steps.

```julia
island, buffer = zeros(Int64, k), zeros(Int64, k)
```

Finally, we will allocate the mainland, which is a pool of `S` unique species:

```julia
const mainland = vec([1:S])
```

Note that `mainland` will not be modified, so it can be made a constant.

## Simulation loop

Now, we can start simulating. The first step is to populate the `island`, from
the `mainland`. This can be done by using the `sample` function from the
`StatsBase` package.

```julia
using StatsBase
sample!(mainland, island)
```

Why do we `sample!`? It is a convention in Julia that functions ending with a `!`
*modify one of their arguments*. A look at the documentation of `sample!` will
reveal that it will fill its second argument with randomly sampled elements from
the first. This avoids writing a loop, and is aggressively optimized.

# Running the model

# Conclusions

1. Functions that end with `!` modify their input.
