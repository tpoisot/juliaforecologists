---
title: Julia for ecologists
author: Timothée Poisot
order: 1
...

The [Julia][julia] programming language is a new initiative to provide an
efficient, easy to write, high-performance language for users of computing
environments. Julia is simple to learn, easy to write, and runs extremely fast.

[julia]: http://julialang.org/

Ecology, evolution, and many other life sciences are dominated by R, and to a
lesser extent, Python. Both are excellent languages. Julia is a good complement
to both. It is less statistic-oriented than R, and built on modern principles.
It is also *really* easy to learn.

# What will I find here?

More or less, an introduction to Julia, using examples from ecology. There will
be a lot of code, covering things from dynamical models, to data analysis, to
parallel computing.

Every "chapter" can be covered in between 10 and 30 minutes, and there is no
assumption that they are going to be read in order.

# What do I need?

Having the latest stable version of Julia would be fine. You can get it from the
[download page][dl] of the Julia project. On most GNU/Linux distributions, you
can install it using your usual package manager.

[dl]: http://julialang.org/downloads/

If you don't want to install anything on your machine, I recommend you use
[JuliaBox][jb]. It is a free cloud-based service in which you can run Julia code
in an interactive environment.

[jb]: http://www.juliabox.org/

If you are looking for resources, there are two pages you should bookmark. The
first is [Learn Julia in Y minutes][ymin]. It is a very good overview of the
language. The second is [The Fast Track to Julia][ft]. Both would be good things
to keep around when reading this document.

[ymin]: http://learnxinyminutes.com/docs/julia/
[ft]: https://dl.dropboxusercontent.com/u/8252984/julia.html

The [official documentation][odoc] is also excellent, and remarkably easy to
read. The [Julia for R programmers][jfru] by Douglas Bates is also an excellent
overview of how R and Julia have complementary strengths.

[odoc]: http://julia.readthedocs.org/en/stable/
[jfru]: http://www.stat.wisc.edu/~bates/JuliaForRProgrammers.pdf

What you should probably *not* read is the countless number of "R is better than
Julia", "Julia is better than R", "R is better than Python", "Python is barely
better than pulling out your own teeth with a rusty plier" threads. Very few are
about the qualities of the languages themselves; they instead tend to be about
people finding justifications for not learning new things. Languages are tools.
Find one you know how to use.

# List of chapters

At all times, these chapters can be accessed from the navigation bar at the top
of the page.

[1][ch1] A Julia primer
: This chapter is a general purpose introduction to both the Julia language, and
some of the writing conventions in this document.

[2][ch2] Models of competition
: This chapter uses models of intraspecific and interspecific competitions to
present the declaration of functions, loops, and accessing parts of arrays.

[3][ch3] Leslie matrices
: This chapters uses Leslie matrices to present some of the linear algebra
abilities of Julia.

[4][ch4] Generalized Lotka-Volterra model
: This chapters will use some points from chapter 2 and 3, to discuss how to
make Julia code *fast*, and how to declare macros.


[ch1]: 01_primer.html
[ch2]: 02_competition.html
[ch3]: 03_leslie.html
[ch4]: 04_glvm.html
