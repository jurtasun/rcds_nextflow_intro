## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png">
<img src="/readme_figures/nextflow-logo.png">

### Chapter 3. General worlflow

Most real-world workflows involve more than one step. In this training module, you'll learn how to connect processes together in a multi-step workflow. This will teach you the Nextflow way of achieving the following:

1. Making data flow from one process to the next
2. Collecting outputs from multiple process calls into a single process call
3. Passing more than one input to a process
3. Handling multiple outputs coming out of a process

To demonstrate, we will continue building on the domain-agnostic Hello World example from Parts 1 and 2. This time, we're going to make the following changes to our workflow to better reflect how people build actual workflows:

1. Add a second step that converts the greeting to uppercase.
2. Add a third step that collects all the transformed greetings and writes them into a single file.
3. Add a parameter to name the final output file and pass that as a secondary input to the collection step.
4. Make the collection step also output a simple statistic about what was processed.

### Warmup: Run `hello-workflow.nf`

We're going to use the workflow script `hello-workflow.nf` as a starting point. It is equivalent to the script produced by working through Part 2 of this training course. Just to make sure everything is working, run the script once before making any changes:

### 1. Add a second step to the workflow

We're going to add a step to convert the greeting to uppercase. To that end, we need to do three things:

- Define the command we're going to use to do the uppercase conversion.
- Write a new process that wraps the uppercasing command.
- Call the new process in the workflow block and set it up to take the output of the `sayHello()` process as input.

### 2. Add a third step to collect all the greetings

When we use a process to apply a transformation to each of the elements in a channel, like we're doing here to the multiple greetings, we sometimes want to collect elements from the output channel of that process, and feed them into another process that performs some kind of analysis or summation. In the next step we're simply going to write all the elements of a channel to a single file, using the UNIX `cat` command.

### 3. Pass multiple input to a process and uniquely name the final output

We want to be able to name the final output file something specific in order to process subsequent batches of greetings without overwriting the final results. To that end, we're going to make the following refinements to the workflow:

- Modify the collector process to accept a user-defined name for the output file
- Add a command-line parameter to the workflow and pass it to the collector process

### 4. Add an output to the collector step

When a process produces only one output, it's easy to access it (in the workflow block) using the `<process>.out` syntax. When there are two or more outputs, the default way to select a specific output is to use the corresponding (zero-based) index; for example, you would use `<process>.out[0]` to get the first output. This is not terribly convenient; it's too easy to grab the wrong index. Let's have a look at how we can select and use a specific output of a process when there are more than one.

For demonstration purposes, let's say we want to count and report the number of greetings that are being collected for a given batch of inputs. To that end, we're going to make the following refinements to the workflow:

- Modify the process to count and output the number of greetings
- Once the process has run, select the count and report it using view (in the workflow block)
