## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png">
<img src="/readme_figures/nextflow-logo.png">

### Chapter 6. Hello config

A "Hello, World!" is a minimalist example that is meant to demonstrate the basic syntax and structure of a programming language or software framework.
The example typically consists of printing the phrase "Hello, World!" to the output device, such as the console or terminal, or writing it to a file.

In this first part of the Hello Nextflow training course, we ease into the topic with a very simple domain-agnostic Hello World example, 
which we'll progressively build up to demonstrate the usage of foundational Nextflow logic and components.

Let's start with a quick check. There is a `nextflow.config` file in the current directory that contains the line `docker.enabled = <setting>`, where `<setting>` is either `true` or `false` depending on whether or not you've worked through chapter 5 of this course in the same environment. If it is set to `true`, you don't need to do anything. If it is set to `false`, switch it to `true` now.

### 1. Determine what software packaging technology to use

The first step toward adapting your workflow configuration to your compute environment is specifying where the software packages that will get run in each step are going to be coming from. Are they already installed in the local compute environment? Do we need to retrieve images and run them via a container system? Or do we need to retrieve Conda packages and build a local Conda environment?

In the very first chapters of the course we just used locally installed software in our workflow. 
Then chapter 5, we introduced Docker containers and the `nextflow.config` file, which we used to enable the use of Docker containers.
In the warmup to this section, you checked that Docker was enabled in `nextflow.config` file and ran the workflow, which used a Docker container to execute the cowpy() process.

### 2. Allocate compute resources with process directives

Most high-performance computing platforms allow (and sometimes require) that you specify certain resource allocation parameters such as number of CPUs and memory.

By default, Nextflow will use a single CPU and 2GB of memory for each process. The corresponding process directives are called `cpus` and `memory`, so the following configuration is implied:

You can modify these values, either for all processes or for specific named processes, using additional process directives in your configuration file. Nextflow will translate them into the appropriate instructions for the chosen executor.


### 3. Use a parameter file to store workflow parameters

So far we've been looking at configuration from the technical point of view of the compute infrastructure. Now let's consider another aspect of workflow configuration that is very important for reproducibility: the configuration of the workflow parameters.

Currently, our workflow is set up to accept several parameter values via the command-line, with default values set in the workflow script itself. This is fine for a simple workflow with very few parameters that need to be set for a given run. However, many real-world workflows will have many more parameters that may be run-specific, and putting all of them in the command line would be tedious and error-prone.

Nextflow allows us to specify parameters via a parameter file in JSON format, which makes it very convenient to manage and distribute alternative sets of default values, for example, as well as run-specific parameter values.

We provide an example parameter file in the current directory, called `test-params.json`:

### 4. Determine what executors should be used to do the work

Until now, we have been running our pipeline with the local executor. This executes each task on the machine that Nextflow is running on. When Nextflow begins, it looks at the available CPUs and memory. If the resources of the tasks ready to run exceed the available resources, Nextflow will hold the last tasks back from execution until one or more of the earlier tasks have finished, freeing up the necessary resources.