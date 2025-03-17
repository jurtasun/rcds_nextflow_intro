## RCDS 2025 - Introduction to Nextflow & nf-core

### Dr. Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/nextflow-logo.png">

### Chapter 1. Hello world with nextflow

A "Hello, World!" is a minimalist example that is meant to demonstrate the basic syntax and structure of a programming language or software framework.
The example typically consists of printing the phrase "Hello, World!" to the output device, such as the console or terminal, or writing it to a file.

In this first part of the Hello Nextflow training course, we ease into the topic with a very simple domain-agnostic Hello World example, 
which we'll progressively build up to demonstrate the usage of foundational Nextflow logic and components.

### 0. Warmup: run Hello world on terminal

Let's demonstrate this with a simple command that we run directly in the terminal, to show what it does before we wrap it in Nextflow.
```bash
echo 'Hello World!'
```
Now make it write the text output to a file.
```bash
echo 'Hello World!' > output.txt
```
Verify that the output file is there using the ls command.
```bash
ls
```
Show the file contents
```bash
less output.txt
```

You now know how to run a simple command in the terminal that outputs some text, and optionally, how to make it write the output to a file. 
Next, we will discover what that would look like written as a Nextflow workflow.

### 1. Run Hello world with nextflow script

#### 1.1. The code structure

As mentioned in the orientation, we provide you with a fully functional if minimalist workflow script named `hello-world.nf` 
that does the same thing as before (write out 'Hello World!') but with Nextflow.

To get you started, we'll first open up the workflow script so you can get a sense of how it's structured, 
then we'll run it (before trying to make any modifications) to verify that it does what we expect.

```nextflow
#!/usr/bin/env nextflow

// Use echo to print 'Hello World!' to standard out
process sayHello {

    output:
        stdout

    """
    echo 'Hello World!'
    """

}

workflow {

    // emit a greeting
    sayHello()

}
```

The first block of code describes a process. The process definition starts with the keyword `process`, 
followed by the process name and finally the process body delimited by curly braces. 
The process body must contain a script block which specifies the command to run, 
which can be anything you would be able to run in a command line terminal. 
Here we have a process called `sayHello` that writes its output to `stdout`.

The second block of code describes the workflow itself. The workflow definition starts with the keyword `workflow`, 
followed by an optional name, then the workflow body delimited by curly braces. 
Here we have a workflow that consists of one call to the `sayHello` process.

#### 1.2. Run the workflow

Run the following command in your terminal.

```bash
nextflow run hello-world.nf
```
The most important output here is the last line (line 6), which reports that the `sayHello` process was successfully executed once.

Okay, that's great, but where do we find the output? The `sayHello` process definition said that the output would be sent to standard out, 
but nothing got printed in the console, did it?

### 2. Send the output to a file

Instead of printing "Hello World!" to standard output, we'd prefer to save that output to a specific file, 
just like we did when running in the terminal earlier.
This is how most tools that you'll run as part of real-world pipelines typically behave; we'll see examples of that later.

To achieve this result, both the script and the output definition blocks need to be updated.

#### 2.1. Update the process command to output a named file

This is the same change we made when we ran the command directly in the terminal earlier.

*before*
```nextflow
    """
    echo 'Hello World!'
    """
```
*after*
```nextflow
    """
    echo 'Hello World!' > output.txt
    """
```

#### 2.2. Update the output declaration in the `sayHello` process

We need to tell Nextflow that it should now look for a specific file to be produced by the process execution.

*before*
```nextflow
    output:
        stdout
```
*after*
```nextflow
    output:
        path 'output.txt'
```

Run the updated file in your terminal.

```bash
nextflow run hello-world.nf
```

Like you did before, find the `work` directory in the file explorer. 
There, find the `output.txt` output file and verify that it contains the greeting as expected.

#### 2.3. Add a `publishDir` directive to the process

You'll have noticed that the output is buried in a working directory several layers deep. 
Nextflow is in control of this directory and we are not supposed to interact with it. 
To make the output file more accessible, we can utilize the `publishDir` directive. 
By specifying this directive, we are telling Nextflow to automatically copy the output file to a designated output directory. 
This allows us to leave the working directory alone, while still having easy access to the desired output file.

*before*
```nextflow
process sayHello {

    output:
        stdout
```
*after*
```nextflow
process sayHello {

    publishDir 'results', mode: 'copy'

    output:
        stdout
```

Run the updated file in your terminal.

```bash
nextflow run hello-world.nf
```

This time, Nextflow will have created a new directory called `results/`. In this directory is our `output.txt` file. 
If you check the contents it should match the output in our work/task directory. This is how we move results files outside of the working directories.
This way, you can send outputs to a specific named file and use the `publishDir` directive to move files outside of the Nextflow working directory.

### 3. Use the Nextflow resume feature

Nextflow has an option called -resume that allows you to re-run a pipeline you've already launched previously. 
When launched with -resume any processes that have already been run with the exact same code, settings and inputs will be skipped. 
Using this mode means Nextflow will only run processes that are either new, have been modified or are being provided new settings or inputs.

There are two key advantages to doing this:

- If you're in the middle of developing your pipeline, you can iterate more rapidly since you only effectively have to run the process(es) you're actively working on in order to test your changes.
- If you're running a pipeline in production and something goes wrong, in many cases you can fix the issue and relaunch the pipeline, 
and it will resume running from the point of failure, which can save you a lot of time and compute.

### 4. Add in variable inputs using a channel

Run the updated file in your terminal.

```bash
nextflow run hello-world.nf
```

Notice the additional `cached:` bit in the process status line, which means that Nextflow has recognized that it has already done this work and simply re-used the result from the last run.

### 5. Add in variable inputs using a channel

So far, we've been emitting a greeting hardcoded into the process command. 
Now we're going to add some flexibility by using an input variable, so that we can easily change the greeting.

This requires us to make a series of inter-related changes:

1. Tell the process about expected variable inputs using the `input:` block
2. Edit the process to use the input
3. Create a **channel** to pass input to the process (more on that in a minute)
4. Add the channel as input to the process call

#### 5.1. Add an input definition to the process block

First we need to adapt the process definition to accept an input.

*before*
```nextflow
process sayHello {

    output:
        stdout
```
*after*
```nextflow
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        stdout
```

#### 5.2. Edit the process command to use the input variable

Now we swap the original hardcoded value for the input variable.

*before*
```nextflow
    """
    echo 'Hello World!' > output.txt
    """
```
*after*
```nextflow
    """
    echo '$greeting' > output.txt
    """
```

#### 5.3. Create an input channel

Now that our process expects an input, we need to set up that input in the workflow body. This is where channels come in: 
Nextflow uses channels to feed inputs to processes and ferry data between processes that are connected together.

There are multiple ways to do this, but for now, we're just going to use the simplest possible channel, containing a single value.

We're going to create the channel using the `Channel.of()` factory, which sets up a simple value channel, 
and give it a hardcoded string to use as greeting by declaring `greeting_ch = Channel.of('Hello world!')`.

*before*
```nextflow
workflow {

    // emit a greeting
    sayHello()

}
```
*after*
```nextflow
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello world!')

    // emit a greeting
    sayHello()

}
```

#### 5.4. Add the channel as input to the process call

Now we need to actually plug our newly created channel into the `sayHello()` process call.

*before*
```nextflow

// emit a greeting
sayHello()

```
*after*
```nextflow

// emit a greeting
sayHello(greeting_ch)

```

Run the updated file in your terminal.

```bash
nextflow run hello-world.nf
```

Feel free to check the results directory to satisfy yourself that the outcome is still the same as previously; 
so far we're just progressively tweaking the internal plumbing to increase the flexibility of our workflow while achieving the same end result.
You know how to use a simple channel to provide an input to a process.

### 6. Use CLI parameters for inputs

We want to be able to specify the input from the command line, since that is the piece that will almost always be different in subsequent runs of the workflow. Good news: Nextflow has a built-in workflow parameter system called `params`, which makes it easy to declare and use CLI parameters.

#### 6.1. Edit the input channel declaration to use a parameter

Here we swap out the hardcoded string for `params.greeting` in the channel creation line.

*before*
```nextflow

// create a channel for inputs
greeting_ch = Channel.of('Hello world!')

```
*after*
```nextflow

// create a channel for inputs
greeting_ch = Channel.of(params.greeting)

```

This automatically creates a parameter called `greeting` that you can use to provide a value in the command line.

#### 6.2. Run the workflow again with the `--greeting parameter`

To provide a value for this parameter, simply add `--greeting <value>` to your command line.

```bash
nextflow run hello-world.nf --greeting 'Bonjour le monde!'
```

#### 6.3. Set a default value for a command line paramete

In many cases, it makes sense to supply a default value for a given parameter so that you don't have to specify it for every run.

Let's initialize the greeting parameter with a default value by adding the parameter declaration at the top of the script.

```nextflow

// Pipeline parameters
params.greeting = "Holà mundo!"

```

Now that you have a default value set, you can run the workflow again without having to specify a value in the command line.

```bash
nextflow run hello-world.nf
```

Check the output in the results directory, and... Tadaa! It works! Nextflow used the default value to name the output. 
But wait, what happens now if we provide the parameter in the command line?

Run the workflow again with the `--greeting` parameter on the command line using a different greeting

```bash
nextflow run hello-world.nf --greeting 'Konnichiwa!
```

Check the results directory and look at the contents of `output.txt`. Tadaa again!

The value of the parameter we passed on the command line overrode the value we gave the variable in the script.
Now you know how to set up an input variable for a process and supply a value in the command line.
Learn how to add in a second process and chain them together.

### 7. Add a second step to the workflow

Most real-world workflows involve more than one step. Here we introduce a second process that converts the text to uppercase (all-caps), 
using the classic UNIX one-liner:

```bash
tr '[a-z]' '[A-Z]'
```

We're going to run the command by itself in the terminal first to verify that it works as expected, just like we did at the start with echo `'Hello World'`.
Then we'll write a process that does the same thing, and finally we'll connect the two processes so the output of the first serves as input to the second.

#### 7.1. run the command in the terminal

Run the following command in the terminal.

```bash
echo 'Hello World' | tr '[a-z]' '[A-Z]'
```

Modify it to take a file as input and write the output in another one.

```bash
cat output.txt | tr '[a-z]' '[A-Z]' > UPPER-output.txt
```

Now the `HELLO WORLD` output is in the new output file, `UPPER-output.txt.`

#### 7.2. Wrap the command in a nextflow process definition

Write the following nextlflow process.

```nextflow

// Use a text replace utility to convert the greeting to uppercase
process convertToUpper {

    publishDir 'results', mode: 'copy'

    input:
        path input_file

    output:
        path "UPPER-${input_file}"

    script:
    """
    cat '$input_file' | tr '[a-z]' '[A-Z]' > UPPER-${input_file}
    """

}

```

You will notice that here we composed the second output filename based on the first one.
Now modify the workflow accordingly, adding a call to the new process.

```nextflow

workflow {

    // create a channel for inputs
    greeting_ch = Channel.of(params.greeting)

    // emit a greeting
    sayHello(greeting_ch)

    // convert the greeting to uppercase
    convertToUpper()

}

```

Looking good! But we still need to wire up the `convertToUpper` process call to run on the output of `sayHello`.
The output of the `sayHello` process is automatically packaged as a channel called `sayHello.out`, 
so all we need to do is pass that as the input to the `convertToUpper process`.

```nextflow

// convert the greeting to uppercase
convertToUpper(sayHello.out)

}

```

Let's make sure this works. Run the following command in the terminal.

```bash
nextflow run hello-world.nf --greeting 'Hello World!'
```

Oh, how exciting! There is now an extra line in the log output, which corresponds to the new process we just added.
You'll notice that this time the workflow produced two new work subdirectories; one per process call. 
Check out the work directory of the call to the second process, where you should find two different output files listed. 
If you look carefully, you'll notice one of them (the output of the first process) has a little arrow icon on the right; that signifies it's a symbolic link. 
It points to the location where that file lives in the work directory of the first process. 
By default, Nextflow uses symbolic links to stage input files whenever possible, to avoid making duplicate copies.

### 8. Run workdlow with many input values

Workflows typically run on batches of inputs that are meant to be processed in bulk, so we want to upgrade the workflow to accept multiple input values.
Conveniently, the `Channel.of()` factory we've been using is quite happy to accept more than one value, so we don't need to modify that at all; 
we just have to load more values into the channel.

#### 8.1. Load multiple greetings into the input channel

To keep things simple, we go back to hardcoding the greetings in the channel factory instead of using a parameter for the input, but we'll improve on that shortly.

*before*
```nextflow

// create a channel for inputs
greeting_ch = Channel.of(params.greeting)

```

*after*
```nextflow

// create a channel for inputs
greeting_ch = Channel.of('Hello','Bonjour','Holà')

```

Again, run the following code

```bash
nextflow run hello-world.nf
```

However... This seems to indicate that '3 of 3' calls were made for each process, which is encouraging, 
but this only give us one subdirectory path for each. What's going on?

By default, the ANSI logging system writes the logging from multiple calls to the same process on the same line.
Fortunately, we can disable that behavior.

#### 8.2. Run the command again with the `-ansi-log` false option

To expand the logging to display one line per process call, just add `-ansi-log false` to the command.

```bash
nextflow run hello-world.nf -ansi-log false
```

This time we see all six work subdirectories listed in the output:
That's much better; at least for this number of processes. For a complex workflow, or a large number of inputs, 
having the full list output to the terminal might get a bit overwhelming.
That being said, we have another problem. If you look in the `results` directory, there are only two files: `output.txt` and `UPPER-output.txt!`

What's up with that? Shouldn't we be expecting two files per input greeting, so six files in all?
You may recall that we hardcoded the output file name for the first process. This was fine as long as there was only a single call made per process, 
but when we start processing multiple input values and publishing the outputs into the same directory of results, it becomes a problem. 
For a given process, every call produces an output with the same file name, so Nextflow just overwrites the previous output file every time a new one is produced.

#### 8.3. Ensure the output file names will be unique

Since we're going to be publishing all the outputs to the same results directory, we need to ensure they will have unique names. 
Specifically, we need to modify the first process to generate a file name dynamically so that the final file names will be unique.

So how do we make the file names unique? A common way to do that is to use some unique piece of metadata as part of the file name. 
Here, for convenience, we'll just use the greeting itself.

*before*
```nextflow

process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path "output.txt"

    script:
    """
    echo '$greeting' > "output.txt"
    """

}

```

*after*
```nextflow

process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path "${greeting}-output.txt"

    script:
    """
    echo '$greeting' > '$greeting-output.txt'
    """

}

```

This should produce a unique output file name for every call of each process.
Run the workflow and check the result.

```bash
nextflow run hello-world.nf
```

Now we have six new files in addition to the two we already had in the results directory.
Success! Now we can add as many greetings as we like without worrying about output files being overwritten.

### 9. Modify the workflow to take a file as its source of input values

#### 9.1. Set up a CLI parameter with a default value pointing to an input file

It's often the case that, when we want to run on a batch of multiple input elements, the input values are contained in a file.
As an example, we have provided you with a CSV file called `greetings.csv` in the `data/` directory, containing several greetings separated by commas.

*before*
```nextflow

// Pipeline parameters
params.greeting = "Bonjour le monde!"

```

*after*
```nextflow

// Pipeline parameters
params.input_file = "data/greetings.csv"

```

#### 9.2. Update the channel declaration to handle the input file

At this point we introduce a new channel factory, `Channel.fromPath()`, which has some built-in functionality for handling file paths.
We're going to use that instead of the `Channel.of()` factory we used previously; the base syntax looks like this:

Now, we are going to deploy a new concept, an 'operator' to transform that CSV file into channel content. 
You'll learn more about operators later, but for now just understand them as ways of transforming channels in a variety of ways.

Since our goal is to read in the contents of a `.csv` file, we're going to add the `.splitCsv()` operator to make Nextflow parse the file contents accordingly, 
as well as the `.flatten()` operator to turn the array element produced by `.splitCsv()` into a channel of individual elements.

So the channel construction instruction becomes:

*before*
```nextflow

// create a channel for inputs
greeting_ch = Channel.of('Hello','Bonjour','Holà')

```

*after*
```nextflow

// create a channel for inputs from a CSV file
greeting_ch = Channel.fromPath(params.input_file)
                     .splitCsv()
                     .flatten()

```

Run the workflow and check the result.

```bash
nextflow run hello-world.nf
```

Looking at the outputs, we see each greeting was correctly extracted and processed through the workflow. 
We've achieved the same result as the previous step, but now we have a lot more flexibility to add more elements to the channel of greetings we want to process.

You know how to provide the input values to the workflow via a file. More generally, you've learned how to use the essential components of Nextflow 
and you have a basic grasp of the logic of how to build a workflow and manage inputs and outputs.