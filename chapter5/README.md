## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/nextflow-logo.png">

### Chapter 5. Hello containers

In Parts 1-4 of this training course, you learned how to use the basic building blocks of Nextflow to assemble a simple workflow capable of processing some text, parallelizing execution if there were multiple inputs, and collecting the results for further processing. However, you were limited to basic UNIX tools available in your environment. Real-world tasks often require various tools and packages not included by default. Typically, you'd need to install these tools, manage their dependencies, and resolve any conflicts.

That is all very tedious and annoying, so we're going to show you how to use **containers** to solve this problem much more conveniently. A **container** is a lightweight, standalone, executable unit of software created from a container **image** that includes everything needed to run an application including code, system libraries and settings.

### 0. Warmup: Run hello-containers.nf

We're going to use the workflow script `hello-containers.nf` as a starting point for the second section. It is equivalent to the script produced by working through Part 4 of this training course. Just to make sure everything is working, run the script once before making any changes:

```bash
nextflow run hello_containers.nf
```

### 1. Use a container manually

What we want to do is add a step to our workflow that will use a container for execution. However, we are first going to go over some basic concepts and operations to solidify your understanding of what containers are before we start using them in Nextflow.

### 2. Use containers in Nextflow

Nextflow has built-in support for running processes inside containers to let you run tools you don't have installed in your compute environment. This means that you can use any container image you like to run your processes, and Nextflow will take care of pulling the image, mounting the data, and running the process inside it.

To demonstrate this, we are going to add a `cowpy` step to the pipeline we've been developing, after the `collectGreetings` step.