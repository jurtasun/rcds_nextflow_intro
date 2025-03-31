    ## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/nextflow-logo.png">

### Chapter 1. Hello world with nextflow

In this first part of the course, we will illustrate with h a very basic - and domain-agnostic - `Hello World` example, 
and we will progressively build up to demonstrate the usage of foundational Nextflow logic and components.

A "Hello, World!" is a minimalist example that is meant to demonstrate the basic syntax and structure of a programming language or software framework.
The example typically consists of printing the phrase "Hello, World!" to the output device, such as the console or terminal, or writing it to a file.

### 0. Warmup: Hello World on terminal

Let's demonstrate how to write a simple sentence with a `bash` command directly in the terminal, to show what it does before we wrap it in Nextflow.
Write the following command in your terminal:

```bash
echo 'Hello World!'
```

We can modify this command such that the message is stored in in a file with the pipe `>` character, rather than printed on screen.

```bash
echo 'Hello World!' > output.txt
```

And then check the content of the file with:

```bash
less output.txt
```

type `q` to quit the visualization mode. Equivalently, you can check the content of the file without entering the view mode with:

```bash
cat output.txt
```

Once we know how to run a simple command in the terminal that outputs some text, and how to write the output to a file,
we can see how this would look like written as a Nextflow workflow.

### 1. Hello World with nextflow

Let's create a file called `hellow_world.nf` with the `touch` command:

```bash
touch hello_world.nf
```

And open it with our text editor `VSCode`.

```bash
code hello_world.nf
```

Now let's put together the following syntax.

```nextflow
#!/usr/bin/env nextflow

// Use echo to print 'Hello World!' to a file
process sayHello {

    output:
        path 'output.txt'

    script:
    """
    echo 'Hello World!' > output.txt
    """
}

// Define workflow
workflow {

    // emit a greeting
    sayHello()

}
```
As you can see, a Nextflow script involves two main types of core components: one or more **processes**, and the **workflow** itself. 
Each **process** describes the operation - or operations - the corresponding step in the pipeline should perform, 
while the **workflow** describes the logic, the data flow that connects the various steps.

Let's take a closer look at the process block first, then we'll look at the workflow block.

#### 1.1 The `process` definition

The first block of code describes a **process**. Its definition starts with the keyword `process`, 
followed by the process name and finally the process body delimited by curly braces. 
The process body must contain a script block which specifies the command to run, which can be anything you would be able to run in a command line terminal.

Here we have a process called `sayHello` that writes its output to a file named `output.txt`.

```nextflow
// Use echo to print 'Hello World!' to a file
process sayHello {

    output:
        path 'output.txt'

    script:
    """
    echo 'Hello World!' > output.txt
    """

}
```

This is a very minimal process definition that just contains an `output` definition and the `script` to execute.

The `output` definition includes the `path` qualifier, which tells Nextflow this should be handled as a path 
(includes both directory paths and files). Another common qualifier is `val`, which we will use later in the example.

As a note, the output definition does not *determine* what output will be created. It simply *declares* what is the expected output, 
so that Nextflow can look for it once execution is complete. This is necessary for verifying that the command was executed successfully and for passing the output to downstream processes if needed. Output produced that doesn't match what is declared in the output block will not be passed to downstream processes.

Keep in mind that this is just an example, and we hardcoded the output filename in two separate places (the script and the output blocks). 
If we change one but not the other, the script will break. Later, you'll learn how to use variables to avoid this problem.

In a real-world pipeline, a process usually contains additional blocks such as directives and inputs, which we'll introduce in a little bit.

#### 1.2 The `workflow` definition

The second block of code describes the **workflow** itself. The definition starts with the keyword `workflow`, 
followed by an optional name, then the workflow body delimited by curly braces.

Here we have a **workflow** that consists of one call to the `sayHello` process.

```nextflow
// Define workflow
workflow {

    // emit a greeting
    sayHello()

}
```

This is a very minimal **workflow** definition. In a real-world pipeline, the workflow typically contains multiple calls to **processes** connected by **channels**, 
and the processes expect one or more variable input(s).

You'll learn how to add variable inputs later in this training module; and you'll learn how to add more processes and connect them by channels in chapter 3 of this course.

### 2. Run the Hello World nextflow script

Looking at code is not nearly as fun as running it, so let's try this out in practice. In the terminal, run the following command:

```nextflow
nextflow run hello_world.nf
```

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-world.nf` [goofy_torvalds] DSL2 - revision: c33d41f479

executor >  local (1)
[a3/7be2fa] sayHello | 1 of 1 ✔
```

Congratulations, you just ran your first Nextflow workflow! The most important output here is the last line (line 6):
```output
[a3/7be2fa] sayHello | 1 of 1 ✔
```

This tells us that the `sayHello` process was successfully executed once (`1 of 1 ✔`).
Importantly, this line also tells you where to find the output of the sayHello process call. Let's look at that now.

### 3. Manage nextflow executions

Knowing how to launch workflows and retrieve outputs is great, but you'll quickly find there are a few other aspects of workflow management that will make your life easier, especially if you're developing your own workflows.

Here we show you how to use the `publishDir` directive to store in an output folder all the main results from your pipeline run, the `resume` feature for when you need to re-launch the same workflow, and how to delete older work directories with `nextflow clean`.

### 4. Add variable input passed on the command line

In its current state, our workflow uses a greeting hardcoded into the process command. We want to add some flexibility by using an input variable, so that we can more easily change the greeting at runtime.