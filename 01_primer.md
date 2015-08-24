---
title: A julia primer
author: Timothée Poisot
order: 1
...

# What is Julia?

Julia is a general purpose programming language (you can do *a lot* of things

with it), designed to maximize performance (you can do these things *fast*).
There are two ways to interact with Julia. Either by starting the *REPL* from
the command line,

```{execute="false"}
julia
```

, or by running a file:

```{execute="false"}
julia -e file.jl
```

## A typed language...

Julia is a *typed* language. For example, `2.0` is a floating point number, and
`2` is an integer number. Let's try.

```julia
typeof(2.0)
```

This is the way we will present most of the code blocks, or snippets, during
this document. The part with a dark border on the left is what you type, and the
part immediately below, with the light border, is the output.

Julia has a few different types, this table will give you a rundown of the most
important ones.

| Type          | What it is                            | Example |
|:--------------|:--------------------------------------|--------:|
| `Int64`       | Integer number with 64-bits precision |     `1` |
| `Float64`     | Floating point number                 |  `-1.0` |
| `Float64`     | Floating point number                 |  `-1.0` |
| `Char`        | Single character                      |   `'a'` |
| `ASCIIString` | ASCII string                          |   `"a"` |
| `UTF8String`  | UTF8 string                           |  `"éè"` |

<!-- TODO add some more types -->

## ... but not too much

Julia can do some type conversion:

```julia
2.0 + 2
```

```julia
integer(2.0)
```

## A compiled language ...

## ... that you don't have to compile

# Loops

# Functions

# Macros

Macros are an interesting feature of Julia, which are enabled by very strong
[meta-programming][mp] abilities. Macros in Julia are noted `@macro`. For
example, the `@elapsed` macro measures the time needed to perform an
instruction.

[mp]: http://julia.readthedocs.org/en/latest/manual/metaprogramming/

```julia
@elapsed rand((10, 10))^4.0 # A random matrix, to the power of 4
```

# Packages

## Installing packages

## Updating packages
