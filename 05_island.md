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

How many unique species on our island?

```julia
length(unique(island))
```

Note that we do not assign the result of this operation to `island`. Functions
with a `!` operate on the argument itself, so there is no need to assign
anything.

The next step, is to write a function that will take `island` and `mainland` as
its arguments, and modify `island` as a function of the `e` and `m` parameters.
Because this function will *modify* `island`, its name will end with a `!`.

```julia
function zerosumdrift!(is::Array{Int64,1}, ml::Array{Int64,1}, e::Float64, m::Float64)
  function singlecell(x)
    # Three choices: same species, one from the island, one from the mainland
    choices = vec([x, sample(is), sample(ml)])
    # And we know the probabilities for each
    return sample(choices, WeightVec([(1-e), e*(1-m), e*m]))
  end
  map!(singlecell, is)
end
```

## Don't panic

Oh wow, many new things here. Let's have a look at them in turn. First, we
define a `function` within a `function`.  Because we can, but also because it
will have its usefulness.

Our top-level function (`zerosumdrift!`) takes the island, the mainland, and the
parameters for arguments. In the description of the model, we have set up a
scenario for what will happen at each "cell" in this island. The function
`singlecell` is an implementation of this scenario. There are a three possible
situations: either the individual remains (`x`), it is replaced by a local
individual (`sample(is)`), or by a mainland individual (`sample(ml)`).

This function returns a species ID for *one* cell of our island. So what we need
to do now is apply this function to *all* cells. This is what `map` does.
Remember `filter`, from the chapter on [Leslie matrices](3_leslie.html)?

Let me remind you:

```julia
filter((x) -> x >= 3, vec([2 3 4 5 6]))
```

The `map` function is *really* similar, in that it takes a function, and apply
it to *all* elements of its second argument. Wanna see for yourself?

```julia
map((x) -> x + 1, vec([1 2 3]))
```

Its `map!` variant does the same thing, but *updates* the values of the argument
it iterates over. So in our situation, it replaces the species `x` by the result
of `singlecell(x)`. And everything that uses `map` is easy to use over several
CPUs (this will be discussed later).

# Running the model

## Simple tests

Let's test this:

```julia
zerosumdrift!(island, mainland, 0.4, 0.2)
length(unique(island))
```

Now, what happens over 100 timesteps?

```julia
for i = 1:100
  zerosumdrift!(island, mainland, 0.4, 0.2)
end
length(unique(island))
```

## Looking at the dynamics, version 1

What if we want to record the output of a given function, at each timestep? This
will be easy!

```julia
# Let's start again with a new island
sample!(mainland, island)
map((x) -> length(unique(zerosumdrift!(island, mainland, 0.4, 0.2))), 1:100)
```

This line will repeat the `zerosumdrift!` function 100 times, but because it is
wrapped in the measurement of how many species there are, it will instead return
the number of unique species. This is *one* way to store the dynamics.

## Looking at the dynamics, version 2

But the previous way may not be optimal, for a *lot* of reasons. We might want
to keep the output in a matrix, for example. So let us pre-allocate one, and
fill it step by step.

```julia
timesteps = 100
output = zeros(Int64, (k, timesteps))
output[:,1] = sample!(mainland, island)
for i in 2:timesteps
  output[:,i] = zerosumdrift!(island, mainland, 0.4, 0.2)
end
output[:,100]
```

We *can* do this, because Julia will still return the values of the object if
modifies. The `output` matrix is accessed by columns.

Now, can we do something *like* `map` on an array with more than one dimension?
Yes! We can use `mapslices`. As its name indicates, `mapslices` will `map` over
*slices* of an array, here meaning either rows or columns. When compared to
`map`, it takes an additional argument, which is the *dimension* on which to
slice. Since the different timesteps are columns, which are the first dimension
in Julia, we will use `1`.

```julia
mapslices((x) -> length(unique(x)), output, 1)
```

# Conclusions

1. Functions that end with `!` modify their input.
2. `map` applies a function to all elements of an iterable.
3. `map!` modifies the values it iterates over.
4. `mapslices`
5. Functions are great and you should use them all the time.
