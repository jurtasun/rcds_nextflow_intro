## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/nextflow-logo.png">

### Chapter 1. Hello world with nextflow

A "Hello, World!" is a minimalist example that is meant to demonstrate the basic syntax and structure of a programming language or software framework.
The example typically consists of printing the phrase "Hello, World!" to the output device, such as the console or terminal, or writing it to a file.

In this first part of the Hello Nextflow training course, we ease into the topic with a very simple domain-agnostic Hello World example, 
which we'll progressively build up to demonstrate the usage of foundational Nextflow logic and components.

### 0. Warmup: Hello World on terminal

Let's demonstrate this with a simple command that we run directly in the terminal, to show what it does before we wrap it in Nextflow.

### 1. Hello World with nextflow

As mentioned in the orientation, we provide you with a fully functional if minimalist workflow script named `hello-world.nf` that does the same thing as before (write out 'Hello World!') but with Nextflow. To get you started, we'll first open up the workflow script so you can get a sense of how it's structured.

### 2. Run the Hello World nextflow script

Looking at code is not nearly as fun as running it, so let's try this out in practice.

### 3. Manage nextflow executions

Knowing how to launch workflows and retrieve outputs is great, but you'll quickly find there are a few other aspects of workflow management that will make your life easier, especially if you're developing your own workflows.

Here we show you how to use the `publishDir` directive to store in an output folder all the main results from your pipeline run, the `resume` feature for when you need to re-launch the same workflow, and how to delete older work directories with `nextflow clean`.

### 4. Add variable input passed on the command line

In its current state, our workflow uses a greeting hardcoded into the process command. We want to add some flexibility by using an input variable, so that we can more easily change the greeting at runtime.