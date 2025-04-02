## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/nextflow-logo.png">

### Chapter 2. Hello channels

In Part 1 of this course (Hello World), we showed you how to provide a variable input to a process by providing the input in the process call directly: `sayHello(params.greet)`. That was a deliberately simplified approach. In practice, that approach has major limitations; namely that it only works for very simple cases where we only want to run the process once, on a single value. In most realistic workflow use cases, we want to process multiple values (experimental data for multiple samples, for example), so we need a more sophisticated way to handle inputs.

That is what Nextflow **channels** are for. Channels are queues designed to handle inputs efficiently and shuttle them from one step to another in multi-step workflows, while providing built-in parallelism and many additional benefits.

In this part of the course, you will learn how to use a channel to handle multiple inputs from a variety of different sources. You will also learn to use **operators** to transform channel contents as needed.

### Warmup: Run `hello_channels.nf` script

We're going to use the workflow script `hello_channels.nf` as a starting point. It is equivalent to the script produced by working through Part 1 of this training course. Just to make sure everything is working, run the script once before making any changes:

Write the following code which reproduces the exercise we did in the last chapter
Let's begin by creating a file called `hellow_channels.nf`.

```bash
touch hello_channels.nf
```

And open it with our text editor `VSCode`.

```bash
code hello_channels.nf
```

Now let's put together the following syntax.

```nextflow
#!/usr/bin/env nextflow

// Use echo to print 'Hello World!' to a file
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path 'output.txt'

    script:
    """
    echo '$greeting' > output.txt
    """

}

// Pipeline parameters
params.greeting = 'Hola mundo!'

// Workflow
workflow {

    // emit a greeting
    sayHello(params.greeting)

}
```

And run it on your terminal:

```bash
nextflow run hello_channels.nf --greeting "Hello Channels"
```

As previously, you will find the output file named `output.txt` in the `results` directory, as specified by the `publishDir` directive.

### 1. Provide variable inputs with a channel

We are going to create a **channel** to pass the variable input to the `sayHello()` process instead of relying on the implicit handling, which has certain limitations.

#### 1.1. Create an input channel

There are a variety of channel factories that we can use to set up a channel. To keep things simple for now, we are going to use the most basic channel factory, called Channel.of, which will create a channel containing a single value. Functionally this will be similar to how we had it set up before, but instead of having Nextflow create a channel implicitly, we are doing this explicitly now.

This creates a channel called greeting_ch using the Channel.of() channel factory, which sets up a simple queue channel, 
and loads the string 'Hello Channels!' to use as the greeting value. In the workflow block, add the channel factory code:

*Before:*
```nextflow
workflow {

    // emit a greeting
    sayHello(params.greeting)

}
```

*After:*
```nextflow
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello Channels!')

    // emit a greeting
    sayHello(params.greeting)

}
```

This is not yet functional since we haven't yet switched the input to the process call.

#### 1.2. Add the channel as input to the process call

Now we need to actually plug our newly created channel into the sayHello() process call, replacing the CLI parameter which we were providing directly before. 
In the workflow block, make the following code change:

*Before:*
```nextflow
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello Channels!')

    // emit a greeting
    sayHello(params.greeting)
}
```

*After:*
```nextflow
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello Channels!')

    // emit a greeting
    sayHello(greeting_ch)
}
```

This tells Nextflow to run the `sayHello` process on the contents of the `greeting_ch` channel.
Now our workflow is properly functional; it is the explicit equivalent of writing `sayHello('Hello Channels!')`.

#### 1.3. Run the workflow command again

And run it again:

```bash
nextflow run hello_channels.nf
```

You can check the results directory to satisfy yourself that the outcome is still the same as previously.
So far we're just progressively tweaking the code to increase the flexibility of our workflow while achieving the same end result.
This may seem like we're writing more code for no tangible benefit, but the value will become clear as soon as we start handling more inputs.

### 2. Modify workflow to run on multiple input values

Workflows typically run on batches of inputs that are meant to be processed in bulk, so we want to upgrade the workflow to accept multiple input values.

#### 2.1. Load multiple greetings into the input channel

Conveniently, the `Channel.of()` channel factory we've been using is quite happy to accept more than one value, so we don't need to modify that at all. 
We just have to load more values into the channel.

*Before:*
```nextflow
// create a channel for inputs
greeting_ch = Channel.of('Hello Channels')
```

*After:*
```nextflow
// create a channel for inputs
greeting_ch = Channel.of('Hello','Bonjour','Hola')
```

And run it again:

```bash
nextflow run hello_channels.nf
```

It certainly seems to run just fine:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-channels.nf` [suspicious_lamport] DSL2 - revision: 778deadaea

executor >  local (3)
[cd/77a81f] sayHello (3) | 3 of 3 ✔
```
However... This seems to indicate that '3 of 3' calls were made for the process, which is encouraging, but this only shows us a single run of the process, with one subdirectory path `(cd/77a81f)`. What's going on?

By default, the ANSI logging system writes the logging from multiple calls to the same process on the same line. Fortunately, we can disable that behavior to see the full list of process calls.

To expand the logging to display one line per process call, add `-ansi-log` false to the command.

```bash
nextflow run hello_channels.nf -ansi-log false
```

This time we see all three process runs and their associated work subdirectories listed in the output:

```bash
N E X T F L O W  ~  version 24.10.0
Launching `hello-channels.nf` [pensive_poitras] DSL2 - revision: 778deadaea
[76/f61695] Submitted process > sayHello (1)
[6e/d12e35] Submitted process > sayHello (3)
[c1/097679] Submitted process > sayHello (2)
```

That's much better; at least for a simple workflow. For a complex workflow, or a large number of inputs, having the full list output to the terminal might get a bit overwhelming, so you might not choose to use -ansi-log false in those cases.

The way the status is reported is a bit different between the two logging modes. In the condensed mode, Nextflow reports whether calls were completed successfully or not. In this expanded mode, it only reports that they were submitted.

That being said, we have another problem. If you look in the results directory, there is only one file: `output.txt`! 
What's up with that? Shouldn't we be expecting a separate file per input greeting, so three files in all? Did all three greetings go into a single file?
You can check the contents of `output.txt`; you will find only one of the three, containing one of the three greetings we provided.

You may recall that we hardcoded the output file name for the `sayHello` process, so all three calls produced a file called `output.txt`. 
You can check the work subdirectories for each of the three processes; each of them contains a file called output.txt as expected.

As long as the output files stay there, isolated from the other processes, that is okay. 
But when the `publishDir` directive copies each of them to the same `results` directory, whichever got copied there first gets overwritten by the next one, and so on.

#### 2.2. Ensure the output file names will be unique

We can continue publishing all the outputs to the same results directory, but we need to ensure they will have unique names. Specifically, we need to modify the first process to generate a file name dynamically so that the final file names will be unique.

So how do we make the file names unique? A common way to do that is to use some unique piece of metadata from the inputs (received from the input channel) as part of the output file name. Here, for convenience, we'll just use the greeting itself since it's just a short string, and prepend it to the base output filename.

Let's construct a dynamic output file name¶

In the process block, make the following code changes:

*Before:*
```nextflow
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path 'output.txt'

    script:
    """
    echo '$greeting' > output.txt
    """
}
```

*After:*
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

Make sure to replace `output.txt` in both the output definition and in the `script:` command block.
In the output definition, you MUST use double quotes around the output filename expression (NOT single quotes), otherwise it will fail.

And run it again:

```bash
nextflow run hello_channels.nf
```

Check we have now three new files in addition to the one we already had in the `results` directory.
Success! Now we can add as many greetings as we like without worrying about output files being overwritten.
In practice, naming files based on the input data itself is almost always impractical. 
The better way to generate dynamic filenames is to pass metadata to a process along with the input files.
The metadata is typically provided via a 'sample sheet' or equivalents. You'll learn how to do that later in your Nextflow training.

### 3. Use an operator to transform the contents of a channel

In Nextflow, operators allow us to transform the contents of a channel. We just showed you how to handle multiple input elements that were hardcoded directly in the channel factory. What if we wanted to provide those multiple inputs in a different form?

For example, imagine we set up an input variable containing an array of elements like this: `greetings_array = ['Hello','Bonjour','Holà']`. Can we load that into our output channel and expect it to work? Let's find out. 

### 4. Use an operator to parse input values from a csv file

It's often the case that, when we want to run on multiple inputs, the input values are contained in a file. As an example, we prepared a CSV file called `greetings.csv` containing several greetings, one on each line (like a column of data).