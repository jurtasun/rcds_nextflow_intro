## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/nextflow-logo.png">

### Chapter 4. Hello modules

This section covers how to organize your workflow code to make development and maintenance of your pipeline more efficient and sustainable. Specifically, we are going to demonstrate how to use **modules**. In Nextflow, a **module** is a single process definition that is encapsulated by itself in a standalone code file. To use a module in a workflow, you just add a single-line import statement to your workflow code file; then you can integrate the process into the workflow the same way you normally would.

When we started developing our workflow, we put everything in one single code file. Putting processes into individual modules makes it possible to reuse process definitions in multiple workflows without producing multiple copies of the code. This makes the code more shareable, flexible and maintainable.

### 0. Warmup: Run `hello-modules.nf`

We're going to use the workflow script `hello-modules.nf` as a starting point. It is equivalent to the script produced by working through Part 3 of this training course. Just to make sure everything is working, run the script once before making any changes:

### 1. Create a directory to store modules

It is best practice to store your modules in a specific directory. You can call that directory anything you want, but the convention is to call it `modules/`.

### 2. Create a module for `sayHello()`

In its simplest form, turning an existing process into a module is little more than a copy-paste operation. We're going to create a file stub for the module, copy the relevant code over then delete it from the main workflow file. Then all we'll need to do is add an import statement so that Nextflow will know to pull in the relevant code at runtime.

### 3. Modularize the `convertToUpper()` process

Create an empty file for the module called `convertToUpper.nf`.

### 4. Modularize the `collectGreetings()` process

Create an empty file for the module called `collectGreetings.nf`.