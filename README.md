## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png">
<img src="/readme_figures/nextflow-logo.png">

### Find the content of the course in GitHub:
[https://github.com/jurtasun/rcds_nextflow_intro](https://github.com/jurtasun/rcds_nextflow_intro)

This course provides an introduction to nextflow and nf-core automated pipelines.
The topics covered will include basic concepts on bash scripting and linux OS, containers and environments.
Then we will show how nextflow can be used to build automatized and reproducible workflows for data analysis.
Even though it is commonly used in biological sciences, such as genomics and bioinformatics, 
nextflow is a multi-purpose, versatile and powerful scripting language that can be applied to many different fields and tasks.

The course is organized in six chapters, covering topics listed below. All will be followed by a practical session and hands-on coding.
No prior experience on programming or statistics is required for the attendance of this course, as all topics will be properly introduce as the course progresses.

## Roadmap of the course

### Chapter 1. Hello world with nextflow.

- Hello world with nexftlow.
- Processes and workflow.
- General structure of nextflow pipeline.

### Chapter 2. Channels and operators.

- Provide variable inputs via a channel explicitly.
- Adapt workflow to run on multiple input values.
- Use an operator to transform the contents of a channel.

### Chapter 3. General workflow.

- Add steps to make more flexible workflow.
- Add a batch command-line parameter.
- Add an output to the collector step.

### Chapter 4. Modularization.

- Create a directory to store modules.
- Modularize the process on the workflow.
- Run and compare with no modularized version.

### Chapter 5. Containers.

- The idea of containers: docker and singularity.
- Use a container 'manually' and pull image.
- Use containers in Nextflow.

### Chapter 6. Config nextflow.

- Config nextflow.
- The `hello-config` directory.
- Symbolic links, containers, submission script.

### Setup

We will be working with the terminal of Linux OS, Visual Studio Code as main editor, and Nextflow.
Although recommended, they do not need to be installed in your local computer, since we will use `Codespaces` provided by Github, 
which already implement an interface ready to program an execute the code.

### Getting Started

1. Download this repository to your computer as a ZIP file and unpack it.

2. Open the terminal and navigate to the unpacked directory to work with the .nf examples.

3. Open a `Codespace` where we will be using either Visual Studio Code fro the practical sessions.

### Install and run nextflow locally in your machine

1. Install homebrew
Go to the homebrew site [https://brew.sh](https://brew.sh) and run the following command.
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install java development kit (open source implementation of java)
Check the latest jdk relase [https://formulae.brew.sh/formula/openjdk#default](https://formulae.brew.sh/formula/openjdk#default) and run the following command.
```bash
brew install openjdk@21
```

3. Install nextflow
Visit the nextdlow site [https://www.nextflow.io](https://www.nextflow.io) and follow the steps for installation.
Run the following command to check java version.
```bash
java -version
```
Run the following command to download nextflow.
```bash
curl -s https://get.nextflow.io | bash
```
Check the path variable on your computer.
```bash
echo $PATH
```
Here is where all sotfwares installed with homebrew are stored. Move the downloaded `nextflow` executable file there.
```bash
sudo mv nextflow /opt/homebrew/bin/
```
Move to the previous address and run the executable file there.
```bash
cd /opt/homebrew/bin/ && ./nextflow run hello
```
Run the same thing connecting to the `hello` repository of `nextflow`.
```bash
nextflow run hello
```
Congrats! You have nextflow succesfully installed in your computer.

4. Install docker (outside of HPC)
Visit the docker website [https://www.docker.com](https://www.docker.com) and follow the installation instrunctions.
Move docker.dmg file to Applicatinos folder.
Check successfull installation of docker, and run nextflow adding the `-with-docker` argument.
```bash
nextflow run hello -with-docker
```

5. Install singularity (for HPC)
Visit the singularity website [https://docs.sylabs.io/guides/3.5/admin-guide/installation.html](https://docs.sylabs.io/guides/3.5/admin-guide/installation.html) and follow the installation instructions.
Check successfull installation of singulariy.
```bash
nextflow run hello -with-docker
```

### Evaluation

Your feedback is very important to the Graduate School as we are continually trying to improve the training we offer.
At the end of the course, please help us by completing the evaluation form at [...]

<hr>
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
