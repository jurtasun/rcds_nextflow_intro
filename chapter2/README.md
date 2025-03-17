## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/nextflow-logo.png">

### Chapter 2. Hello channels

In Part 1 of this course (Hello World), we showed you how to provide a variable input to a process by providing the input in the process call directly: `sayHello(params.greet)`. That was a deliberately simplified approach. In practice, that approach has major limitations; namely that it only works for very simple cases where we only want to run the process once, on a single value. In most realistic workflow use cases, we want to process multiple values (experimental data for multiple samples, for example), so we need a more sophisticated way to handle inputs.

That is what Nextflow **channels** are for. Channels are queues designed to handle inputs efficiently and shuttle them from one step to another in multi-step workflows, while providing built-in parallelism and many additional benefits.

In this part of the course, you will learn how to use a channel to handle multiple inputs from a variety of different sources. You will also learn to use **operators** to transform channel contents as needed.

### 0. Warmup: Run `hello-channels.nf` script

We're going to use the workflow script `hello-channels.nf` as a starting point. It is equivalent to the script produced by working through Part 1 of this training course. Just to make sure everything is working, run the script once before making any changes:

### 1. Provide variable inputs with a channel

We are going to create a **channel** to pass the variable input to the `sayHello()` process instead of relying on the implicit handling, which has certain limitations.

### 2. Modify workflow to run on multiple input values

Workflows typically run on batches of inputs that are meant to be processed in bulk, so we want to upgrade the workflow to accept multiple input values.

### 3. Use an operator to transform the contents of a channel

In Nextflow, operators allow us to transform the contents of a channel. We just showed you how to handle multiple input elements that were hardcoded directly in the channel factory. What if we wanted to provide those multiple inputs in a different form?

For example, imagine we set up an input variable containing an array of elements like this: `greetings_array = ['Hello','Bonjour','Holà']`. Can we load that into our output channel and expect it to work? Let's find out. 

### 4. Use an operator to parse input values from a csv file

It's often the case that, when we want to run on multiple inputs, the input values are contained in a file. As an example, we prepared a CSV file called `greetings.csv` containing several greetings, one on each line (like a column of data).