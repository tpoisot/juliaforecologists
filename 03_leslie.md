---
title: Leslie matrices
author: Timothée Poisot
order: 1
...

A Leslie matrix is a way to represent the dynamics of a structured population.
For example, a population in which individuals are juveniles, adults, then old,
can be represented with three classes. The demographically relevant parameters
are the rate of transition between each of them. We will use Leslie matrices to
present some of Julia's linear algebra facilities.

# Setting up our example

Let us assume that there is a population of flowers, that can live for up to
three years, but only reproduce during the second year. We can define a
time-discrete model of the growth of this population, using a Leslie matrix.
$f_x$ is the fecundity of age class $x$ (number of offspring per individual),
and $s_x$ is the probability that an individual in age class $x$ will survive
until age class $x+1$. The matrix representing our population is:

$$
\mathbf{L} = \begin{bmatrix}
   0 & f_2 & 0 \\
   s_1 & 0 & 0 \\
   0 & s_2 & 0
\end{bmatrix}
$$

At any given time, a field survey of this population can give a measure of the
abundances in each class $x$, which we will note $n_x$:

$$
\mathbf{n} = \begin{bmatrix}
   n_1 \\
   n_2 \\
   n_3
\end{bmatrix}
$$

With these informations, we will be able to start working on a Julia
implementation.

# Implementing the model

## Transition matrix

The first step is to declare a matrix `L`:

```julia
L = [0 2.9 0; 0.4 0 0; 0 0.9 0]
```

In Julia, arrays are noted row-wise, and every row is separated by a semi-colon.
Note that arrays are *stored* column-wise in memory. This is of little
importance at first, but it means that it is always better to access arrays by
columns, rather than by rows.

## Population

The second step is of course to declare a starting population state:

```julia
n = [120 30 10]
```

Wait. That's not quite right. Arrays should be stored alongside columns. The
correct syntax is:

```julia
n = vec([120.0 30.0 10.0])
```

Note that using `vec` transforms our row into a column. In the first
declaration, `n` is a `3x1` array, whereas as in the second, it is a `3-element`
array. Note also that instead of `120`, we used `120.0` (*i.e.* the floating
point version). Again, Julia is more than able of doing the conversion at
runtime, but it is good practice to have arguments of the same type. These
precious microseconds we save add up!

# Running the model

## Single timestep

A model based on a Leslie matrix is actually really easy to run. The number of
individuals in each age class at the next timestep is $\mathbf{L}\mathbf{n}$. In Julia,
this is:

```julia
L * n
```

How many individuals were present at the initial time?

```julia
sum(n)
```

And how many after the next timestep?

```julia
sum(L*n)
```

## Several timesteps

The general solution after $t$ timesteps is that $\mathbf{n}_t =
\mathbf{L}^t\mathbf{n}_0$, where $\mathbf{L}^t$ is the transition matrix
multiplied $t$ times. We can easily write this as a function:

```julia
function lesliematrix(L::Array{Float64, 2}, n::Array{Float64, 1}, t::Int64)
  return (L^t)*n
end
lesliematrix(L, n, 10) # Age structure after 10 timesteps
```

Why, you ask, go through the trouble of writing a function for a single
operation? It is because Julia is a compiled language, and one that is great at
compiling functions to make the *fast*. The same set of instructions written as
functions can be orders of magnitude faster than the same code written without
functions. Functions are also re-usable, testable, and tidier to read.

# Making predictions

There are two (well, *at least*) two interesting facts about Leslie matrices.
First, the dominant eigenvalue of the matrix is the asymptotic growth rate of
the population. Second, the corresponding eigenvector is the expected age
distribution at the age distribution equilibrium. Let's test this.

## Asymptotic growth rate

In Julia, we can get the eigenvalues of a (square) matrix using (the `real`
function works on the real parts, and `imag` on the imaginary):

```julia
Λ = real(eigvals(L))
```

This is a good time to mention that Julia uses UTF-8 to encode characters, so it
is perfectly acceptable to use Greek letters (and a variety of other symbols).
Julia uses LaTeX symbol codes, so to write λ, you need to write `\lambda` then
press Tab.

Now we want to find the *leading*, or largest one. This is quite simply done with:

```julia
λ = maximum(Λ)
```

A value larger than unity means that this population will keep on growing
exponentially. Note that this asymptotic growth rate is only valid when the
population has reached its stable age-structure. Which we can *also* estimate
from the Leslie matrix.

## Stable age-structure

The stable age-structure is the distribution of ages that is expected at any
timestep. It is given by the eigenvector corresponding to the leading eigenvalue
of the Leslie matrix.

To get this, we need (i) to identify the largest eigenvalue (which we have done
previously) and (ii) to get the corresponding eigenvector. Eigenvectors are
simply to get:

```julia
ev = eigvecs(L)
```

Now, we know that the leading eigenvalue is `λ`, but what is its position in the `Λ`
array of all eigenvalues? This can quite easily be done using the `filter`
function. The `filter` function will take an array of objects, and return only
those that match a given condition.

We will want to know which *position* in the `Λ` array is the greatest one. This
is `Λ[i] == λ`. The positions of `Λ` are `1:length(Λ)`. We have enough to write
our filter!

```julia
leading = filter((i) -> Λ[i] == λ, 1:length(Λ))
```

Wait, what is this `(i) -> Λ[i] == λ` business? Well, `filter`, like `map` and
`reduce` (which we will use later) takes a function as its first argument, and
applies it to its second argument. So we need a function to express `Λ[i] == λ`.
The `(i) -> Λ[i] == λ` notation is an *anonymous* function. They usually can't
be optimized as much as regular functions (so they decrease performance), but
they are more than acceptable for inline use.

Note that `filter` returns an array, so we need to get the first position of it:

```julia
ages = ev[:,leading[1]]
```

Excellent! Now, we need to make this array sum to unity (because it should be
interpreted as proportions).

```julia
structure = ages ./ sum(ages)
```

Note the `./` notation. When dealing with matrices, arrays, etc..., adding a `.`
in front of an operation means element-wise. For example, `L*L` is the matrix
multiplication, and `L .* L` is the dot-product, or Hadamard product. This is
*very important*: Julia does the linear algebra stuff first, as opposed to R. So
R's `*` is Julia's `.*`, and R's `%*%` is Julia's `*`.

Now, we can check that this distribution matches the one that we observe after a
few timesteps:

```julia
trial = lesliematrix(L, n, 50)
trial ./ sum(trial)
```

Close enough!

# Conclusions

Here are the key points from this chapter:

1. Arrays are stored as columns
2. By default, Julia does linear algebra, not element-wise operations
3. The `filter` function is a powerful interface to work on arrays ...
4. ... and it sometimes require anonymous functions
