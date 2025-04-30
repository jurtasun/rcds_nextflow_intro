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

### Warmup: Check that Docker is enabled and run the Hello Config workflow

First, a quick check. There is a `nextflow.config` file in the current directory that contains the line `docker.enabled = <setting>`, 
where `<setting>` is either `true` or `false` depending on whether or not you've worked through Part 5 of this course in the same environment.

- If it is set to `true`, you don't need to do anything.
- If it is set to `false`, switch it to true now.

```nextflow
docker.enabled = true
```

Once you've done that, verify that the initial workflow runs properly:

```bash
nextflow run hello-config.nf
```

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-config.nf` [reverent_heisenberg] DSL2 - revision: 028a841db1

executor >  local (8)
[7f/0da515] say_hello (1)       | 3 of 3 ✔
[f3/42f5a5] convert_to_upper (3) | 3 of 3 ✔
[04/fe90e4] collect_greetings   | 1 of 1 ✔
[81/4f5fa9] cowpy              | 1 of 1 ✔
There were 3 greetings in this batch
```
If everything works, you're ready to learn how to modify basic configuration properties to adapt to your compute environment's requirements.

### 1. Determine what software packaging technology to use

The first step toward adapting your workflow configuration to your compute environment is specifying where the software packages that will get run in each step are going to be coming from. Are they already installed in the local compute environment? Do we need to retrieve images and run them via a container system? Or do we need to retrieve Conda packages and build a local Conda environment?

In the very first chapters of the course we just used locally installed software in our workflow. 
Then chapter 5, we introduced Docker containers and the `nextflow.config` file, which we used to enable the use of Docker containers.
In the warmup to this section, you checked that Docker was enabled in `nextflow.config` file and ran the workflow, which used a Docker container to execute the `cowpy()` process.

#### 1.1. Disable Docker and enable Conda in the config file

Let's pretend we're working on an HPC cluster and the admin doesn't allow the use of Docker for security reasons.
Fortunately for us, Nextflow supports multiple other container technologies such as including Singularity (which is more widely used on HPC), 
and software package managers such as Conda.

We can change our configuration file to use Conda instead of Docker. 
To do so, we switch the value of `docker.enabled` to `false`, and add a directive enabling the use of Conda:

```nextflow
docker.enabled = false
conda.enabled = true
```

This will allow Nextflow to create and utilize Conda environments for processes that have Conda packages specified. 
Which means we now need to add one of those to our `cowpy` process.

#### 1.2. Specify a Conda package in the process definition

We've already retrieved the URI for a Conda package containing the `cowpy` tool: `conda-forge::cowpy==1.1.5`

Note that there are a few different ways to get the URI for a given conda package. We recommend using the Seqera Containers [...] search query, 
which will give you a URI that you can copy and paste, even if you're not planning to create a container from it.

Now we add the URI to the cowpy process definition using the conda directive in the `modules/cowpy.nf` file:

```nextflow
process cowpy {

    container 'community.wave.seqera.io/library/cowpy:1.1.5--3db457ae1977a273'
    conda 'conda-forge::cowpy==1.1.5'

    publishDir 'results', mode: 'copy'
```

To be clear, we're not *replacing* the `docker` directive, we're adding an alternative option.

#### 1.3. Run the workflow to verify that it can use Conda

Let's try it out.

```bash
nextflow run hello-config.nf
```

This should work without issue.

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-config.nf` [trusting_lovelace] DSL2 - revision: 028a841db1

executor >  local (8)
[ee/4ca1f2] say_hello (3)       | 3 of 3 ✔
[20/2596a7] convert_to_upper (1) | 3 of 3 ✔
[b3/e15de5] collect_greetings   | 1 of 1 ✔
[c5/af5f88] cowpy              | 1 of 1 ✔
There were 3 greetings in this batch
```
Behind the scenes, Nextflow has retrieved the Conda packages and created the environment.

Note that this runs quickly because the `cowpy` package is quite small, but if you're working with large packages, it may take a bit longer than usual the first time, 
and you might see the console output stay 'stuck' for a minute or so before completing. 
This is normal and is due to the extra work Nextflow does the first time you use a new package.

From our standpoint, it looks like it works exactly the same as running with Docker, even though on the backend the mechanics are a bit different.

This means we're all set to run with Conda environments if needed. We will learn now how to change the executor used by Nextflow to actually do the work.

### 2. Allocate compute resources with process directives

Most high-performance computing platforms allow (and sometimes require) that you specify certain resource allocation parameters such as number of CPUs and memory.

By default, Nextflow will use a single CPU and 2GB of memory for each process. The corresponding process directives are called `cpus` and `memory`, so the following configuration is implied:

```nextflow
process {
    cpus = 1
    memory = 2.GB
}
```

You can modify these values, either for all processes or for specific named processes, using additional process directives in your configuration file. Nextflow will translate them into the appropriate instructions for the chosen executor.

#### 2.1. Run the workflow to generate a resource utilization report

If you don't know up front how much CPU and memory your processes are likely to need, you can do some resource profiling, meaning you run the workflow with some default allocations, record how much each process used, and from there, estimate how to adjust the base allocations.

Conveniently, Nextflow includes built-in tools for doing this, and will happily generate a report for you on request.

To do so, add `-with-report <filename>.html` to your command line.

```nextflow
nextflow run hello-config.nf -with-report report-config-1.html
```

The report is an html file, which you can download and open in your browser. 
You can also right click it in the file explorer on the left and click on `Show preview` in order to view it in the training environment.

Take a few minutes to look through the report and see if you can identify some opportunities for adjusting resources. Make sure to click on the tabs that show the utilization results as a percentage of what was allocated. There is some documentation [...] describing all the available features.

#### 2.2. Set resource allocations for all processes

The profiling shows that the processes in our training workflow are very lightweight, so let's reduce the default memory allocation to 1GB per process.

Add the following to your `nextflow.config` file:

```nextflow
process {
    memory = 1.GB
}
```

#### 2.3. Set resource allocations for an individual process

At the same time, we're going to pretend that the `cowpy` process requires more resources than the others, 
just so we can demonstrate how to adjust allocations for an individual process.

```nextflow
process {
    memory = 1.GB
    withName: 'cowpy' {
        memory = 2.GB
        cpus = 2
    }
}
```

With this configuration, all processes will request 1GB of memory and a single CPU (the implied default), except the `cowpy` process, which will request 2GB and 2 CPUs.

Note that, if you have a machine with few CPUs and you allocate a high number per process, you might see process calls getting queued behind each other. 
This is because Nextflow ensures we don't request more CPUs than are available.

#### 2.4. Run the workflow with the modified configuration

Let's try that out, supplying a different filename for the profiling report so we can compare performance before and after the configuration changes.

```nextflow
nextflow run hello-config.nf -with-report report-config-2.html
```

You will probably not notice any real difference since this is such a small workload, but this is the approach you would use to analyze the performance and resource requirements of a real-world workflow.

It is very useful when your processes have different resource requirements. It empowers you to right-size the resource allocations you set up for each process based on actual data, not guesswork.

#### 2.5. Add resource limits

Depending on what computing executor and compute infrastructure you're using, there may be some constraints on what you can (or must) allocate. For example, your cluster may require you to stay within certain limits.

You can use the `resourceLimits` directive to set the relevant limitations. The syntax looks like this when it's by itself in a process block:

```nextflow
process {
    resourceLimits = [
        memory: 750.GB,
        cpus: 200,
        time: 30.d
    ]
}
```
Nextflow will translate these values into the appropriate instructions depending on the executor that you specified.

We're not going to run this, since we don't have access to relevant infrastructure in the training environment. However, if you were to try running the workflow with resource allocations that exceed these limits, then look up the `sbatch` command in the `.command.run` script file, you would see that the requests that actually get sent to the executor are capped at the values specified by `resourceLimits`.

Let's now learn how to use a parameter file to store workflow parameters.

### 3. Use a parameter file to store workflow parameters

So far we've been looking at configuration from the technical point of view of the compute infrastructure. Now let's consider another aspect of workflow configuration that is very important for reproducibility: the configuration of the workflow parameters.

Currently, our workflow is set up to accept several parameter values via the command-line, with default values set in the workflow script itself. This is fine for a simple workflow with very few parameters that need to be set for a given run. However, many real-world workflows will have many more parameters that may be run-specific, and putting all of them in the command line would be tedious and error-prone.

Nextflow allows us to specify parameters via a parameter file in JSON format, which makes it very convenient to manage and distribute alternative sets of default values, for example, as well as run-specific parameter values.

We provide an example parameter file in the current directory, called `test-params.json`:

```json
{
  "greeting": "greetings.csv",
  "batch": "Trio",
  "character": "turkey"
}
```
This parameter file contains a key-value pair for each of the inputs our workflow expects.

#### 3.1. Run the workflow using a parameter file

To run the workflow with this parameter file, simply add `-params-file <filename>` to the base command.

```bash
nextflow run hello-config.nf -params-file test-params.json
```
It works! And as expected, this produces the same outputs as previously.

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-config.nf` [disturbed_sammet] DSL2 - revision: ede9037d02

executor >  local (8)
[f0/35723c] say_hello (2)       | 3 of 3 ✔
[40/3efd1a] convert_to_upper (3) | 3 of 3 ✔
[17/e97d32] collect_greetings   | 1 of 1 ✔
[98/c6b57b] cowpy              | 1 of 1 ✔
There were 3 greetings in this batch
```
This may seem like overkill when you only have a few parameters to specify, but some pipelines expect dozens of parameters. In those cases, using a parameter file will allow us to provide parameter values at runtime without having to type massive command lines and without modifying the workflow script.

Learn how to use profiles to conveniently switch between alternative configurations.

### 4. Determine what executors should be used to do the work

Until now, we have been running our pipeline with the local executor. This executes each task on the machine that Nextflow is running on. When Nextflow begins, it looks at the available CPUs and memory. If the resources of the tasks ready to run exceed the available resources, Nextflow will hold the last tasks back from execution until one or more of the earlier tasks have finished, freeing up the necessary resources.

For very large workloads, you may discover that your local machine is a bottleneck, either because you have a single task that requires more resources than you have available, or because you have so many tasks that waiting for a single machine to run them would take too long. The local executor is convenient and efficient, but is limited to that single machine. Nextflow supports many different execution backends [...], including HPC schedulers (Slurm, LSF, SGE, PBS, Moab, OAR, Bridge, HTCondor and others) as well as cloud execution backends such (AWS Batch, Google Cloud Batch, Azure Batch, Kubernetes and more).

Each of these systems uses different technologies, syntaxes and configurations for defining how a job should be defined. For example, /if we didn't have Nextflow/, a job requiring 8 CPUs and 4GB of RAM to be executed on the queue "my-science-work" would need to include the following configuration on SLURM and submit the job using sbatch:


#SBATCH -o /path/to/my/task/directory/my-task-1.log
#SBATCH --no-requeue
#SBATCH -c 8
#SBATCH --mem 4096M
#SBATCH -p my-science-work
If I wanted to make the workflow available to a colleague running on PBS, I'd need to remember to use a different submission program qsub and I'd need to change my scripts to use a new syntax for resources:


#PBS -o /path/to/my/task/directory/my-task-1.log
#PBS -j oe
#PBS -q my-science-work
#PBS -l nodes=1:ppn=5
#PBS -l mem=4gb
If I wanted to use SGE, the configuration would be slightly different again:


#$ -o /path/to/my/task/directory/my-task-1.log
#$ -j y
#$ -terse
#$ -notify
#$ -q my-science-work
#$ -l slots=5
#$ -l h_rss=4096M,mem_free=4096M
Running on a single cloud execution engine would require a new approach again, likely using an SDK that uses the cloud platform's APIs.

Nextflow makes it easy to write a single workflow that can be run on each of these different infrastructures and systems, without having to modify the workflow. The executor is subject to a process directive called executor. By default it is set to local, so the following configuration is implied:

Built-in configuration

process {
    executor = 'local'
}

#### 4.1. Targeting a different backend

By default, this training environment does not include a running HPC schedulder, but if you were running on a system with SLURM installed, for example, you can have Nextflow convert the cpus, memory, queue and other process directives into the correct syntax at runtime by adding following lines to the nextflow.config file:

nextflow.config

process {
    executor = 'slurm'
}
And... that's it! As noted before, this does assume that Slurm itself is already set up for you, but this is really all Nextflow itself needs to know.

Basically we are telling Nextflow to generate a Slurm submission script and submit it using an sbatch command.

Takeaway¶

You now know how to change the executor to use different kinds of computing infrastructure.

What's next?¶

Learn how to control the resources allocated for executing processes.

### 5. Use profiles to select preset configurations

You may want to switch between alternative settings depending on what computing infrastructure you're using. For example, you might want to develop and run small-scale tests locally on your laptop, then run full-scale workloads on HPC or cloud.

Nextflow lets you set up profiles that describe different configurations, which you can then select at runtime using a command-line argument, rather than having to modify the configuration file itself.

#### 5.1. Create profiles for switching between local development and execution on HPC

Let's set up two alternative profiles; one for running small scale loads on a regular computer, where we'll use Docker containers, and one for running on a university HPC with a Slurm scheduler, where we'll use Conda packages.

Add the following to your nextflow.config file:

nextflow.config

profiles {
    my_laptop {
        process.executor = 'local'
        docker.enabled = true
    }
    univ_hpc {
        process.executor = 'slurm'
        conda.enabled = true
        process.resourceLimits = [
            memory: 750.GB,
            cpus: 200,
            time: 30.d
        ]
    }
}
You see that for the university HPC, we're also specifying resource limitations.

#### 5.2. Run the workflow with a profile

To specify a profile in our Nextflow command line, we use the -profile argument.

Let's try running the workflow with the my_laptop configuration.


nextflow run hello-config.nf -profile my_laptop
This still produces the following output:


 N E X T F L O W   ~  version 24.10.0

Launching `hello-config.nf` [gigantic_brazil] DSL2 - revision: ede9037d02

executor >  local (8)
[58/da9437] say_hello (3)       | 3 of 3 ✔
[35/9cbe77] convert_to_upper (2) | 3 of 3 ✔
[67/857d05] collect_greetings   | 1 of 1 ✔
[37/7b51b5] cowpy              | 1 of 1 ✔
There were 3 greetings in this batch
As you can see, this allows us to toggle between configurations very conveniently at runtime.

Warning
The univ_hpc profile will not run properly in the training environment since we do not have access to a Slurm scheduler.

If in the future we find other elements of configuration that are always co-occurring with these, we can simply add them to the corresponding profile(s). We can also create additional profiles if there are other elements of configuration that we want to group together.

#### 5.3. Create a test profile

Profiles are not only for infrastructure configuration. We can also use them to set default values for workflow parameters, to make it easier for others to try out the workflow without having to gather appropriate input values themselves. This is intended as an alternative to using a parameter file.

The syntax for expressing default values is the same as when writing them into the workflow file itself, except we wrap them in a block named test:

Syntax example

    test {
        params.<parameter1>
        params.<parameter2>
        ...
    }
If we add a test profile for our workflow, the profiles block becomes:

nextflow.config

profiles {
    my_laptop {
        process.executor = 'local'
        docker.enabled = true
    }
    univ_hpc {
        process.executor = 'slurm'
        conda.enabled = true
        process.resourceLimits = [
            memory: 750.GB,
            cpus: 200,
            time: 30.d
        ]
    }
    test {
        params.greeting = 'greetings.csv'
        params.batch = 'test-batch'
        params.character = 'turkey'
    }
}
Just like for technical configuration profiles, you can set up multiple different profiles specifying parameters under any arbitrary name you like.

#### 5.4. Run the workflow locally with the test profile

Conveniently, profiles are not mutually exclusive, so we can specify multiple profiles in our command line using the following syntax -profile <profile1>,<profile2> (for any number of profiles).

Note
If you combine profiles that set values for the same elements of configuration and are described in the same configuration file, Nextflow will resolve the conflict by using whichever value it read in last (i.e. whatever comes later in the file). If the conflicting settings are set in different configuration sources, the default order of precedence applies.

Let's try adding the test profile to our previous command:


nextflow run hello-config.nf -profile my_laptop,test
This should produce the following:

Output

 N E X T F L O W   ~  version 24.10.0

Launching `hello-config.nf` [gigantic_brazil] DSL2 - revision: ede9037d02

executor >  local (8)
[58/da9437] say_hello (3)       | 3 of 3 ✔
[35/9cbe77] convert_to_upper (2) | 3 of 3 ✔
[67/857d05] collect_greetings   | 1 of 1 ✔
[37/7b51b5] cowpy              | 1 of 1 ✔
There were 3 greetings in this batch
This means that as long as we distribute any test data files with the workflow code, anyone can quickly try out the workflow without having to supply their own inputs via the command line or a parameter file.

Note
We can even point to URLs for larger files that are stored externally. Nextflow will download them automatically as long as there is an open connection.

Takeaway¶

You know how to use profiles to select a preset configuration at runtime with minimal hassle. More generally, you know how to configure your workflow executions to suit different compute platforms and enhance the reproducibility of your analyses.

What's next?¶

Celebrate and give yourself a big pat on the back! You have completed your very first Nextflow developer course.

Next, we ask you to complete a very short survey about your experience with this training course, then we'll take you to a page with links to further training resources and helpful links.