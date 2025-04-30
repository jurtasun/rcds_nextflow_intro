## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png">
<img src="/readme_figures/nextflow-logo.png">

### Chapter 4. Modularization

This section covers how to organize your workflow code to make development and maintenance of your pipeline more efficient and sustainable. Specifically, we are going to demonstrate how to use **modules**. In Nextflow, a **module** is a single process definition that is encapsulated by itself in a single file. To use a module in a workflow, you just add a single-line import statement to your workflow code file; then you can integrate the process into the workflow the same way you normally would.

When we started developing our workflow, we put everything in one single code file. Putting processes into individual modules makes it possible to reuse process definitions in multiple workflows without producing multiple copies of the code. This makes the code more shareable, flexible and maintainable.

We're going to use the workflow script `hello-modules.nf` as a starting point. It is equivalent to the script produced by working through Part 3 of this training course. Just to make sure everything is working, run the script once before making any changes:

### Warmup: Run hello-modules.nf

We're going to use the workflow script hello-modules.nf as a starting point. It is equivalent to the script produced by working through Part 3 of this training course.
Just to make sure everything is working, run the script once before making any changes:

```bash
nextflow run hello_modules.nf
```

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-modules.nf` [festering_nobel] DSL2 - revision: eeca64cdb1

executor >  local (7)
[25/648bdd] say_hello (2)       | 3 of 3 ✔
[60/bc6831] convert_to_upper (1) | 3 of 3 ✔
[1a/bc5901] collect_greetings   | 1 of 1 ✔
There were 3 greetings in this batch
```

As previously, you will find the output files in the `results` directory, as specified by the `publishDir` directive.

### 1. Create a directory to store modules

It is best practice to store your modules in a specific directory. You can call that directory anything you want, but the convention is to call it `modules/`.

```bash
mkdir modules
```

Here we are showing how to use local modules, meaning modules stored locally in the same repository as the rest of the workflow code, 
in contrast to remote modules, which are stored in other (remote) repositories.

### 2. Create a module for `say_hello()`

In its simplest form, turning an existing process into a module is little more than a copy-paste operation. We're going to create a file stub for the module, copy the relevant code over then delete it from the main workflow file. Then all we'll need to do is add an import statement so that Nextflow will know to pull in the relevant code at runtime.

#### 2.1 Create a file for the new module

Let's create an empty file for the module called say_hello.nf.

```bash
touch modules/say_hello.nf
```

This gives us a place to put the process code.

#### 2.2. Move the say_hello process code to the module file

Copy the whole process definition over from the workflow file to the module file, making sure to copy over the `#!/usr/bin/env` nextflow shebang too.

```nextflow
#!/usr/bin/env nextflow
// Use echo to print 'Hello World!' to a file
process say_hello {

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

Once that is done, delete the process definition from the workflow file, but make sure to leave the shebang in place.

#### 2.3. Add an import declaration before the workflow block

The syntax for importing a local module is fairly straightforward:

```nextflow
include { <MODULE_NAME> } from '<path_to_module>'
```

Let's insert that above the workflow block and fill it out appropriately.

```nextflow
// Include modules
include { say_hello } from './modules/say_hello.nf'

workflow {
```   

#### 2.4. Run the workflow to verify that it does the same thing as before

We're running the workflow with essentially the same code and inputs as before, so let's run with the `-resume` flag and see what happens.

```bash
nextflow run hello-modules.nf -resume
```

This runs quickly very quickly because everything is cached.

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-modules.nf` [romantic_poisson] DSL2 - revision: 96edfa9ad3

[f6/cc0107] say_hello (1)       | 3 of 3, cached: 3 ✔
[3c/4058ba] convert_to_upper (2) | 3 of 3, cached: 3 ✔
[1a/bc5901] collect_greetings   | 1 of 1, cached: 1 ✔
There were 3 greetings in this batch
```
Nextflow recognized that it's still all the same work to be done, even if the code is split up into multiple files.

### 3. Modularize the `convert_to_upper()` process

#### 3.1. Create a file stub for the new module

Create an empty file for the module called `convert_to_upper.nf`.

```bash
touch modules/convert_to_upper.nf
```

#### 3.2. Move the convert_to_upper process code to the module file

Copy the whole process definition over from the workflow file to the module file, making sure to copy over the `#!/usr/bin/env` nextflow shebang too.

```nextflow
#!/usr/bin/env nextflow

// Use a text replacement tool to convert the greeting to uppercase
process convert_to_upper {

    publishDir 'results', mode: 'copy'

    input:
        path input_file

    output:
        path "UPPER-${input_file}"

    script:
    """
    cat '$input_file' | tr '[a-z]' '[A-Z]' > 'UPPER-${input_file}'
    """
}
```
Once that is done, delete the process definition from the workflow file, but make sure to leave the shebang in place.

#### 3.3. Add an import declaration before the workflow block

Insert the import declaration above the workflow block and fill it out appropriately.

```nextflow
// Include modules
include { say_hello } from './modules/say_hello.nf'
include { convert_to_upper } from './modules/convert_to_upper.nf'

workflow {
```

#### 3.4. Run the workflow to verify that it does the same thing as before

Run this with the `-resume` flag.

```bash
nextflow run hello-modules.nf -resume
```
This should still produce the same output as previously.

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-modules.nf` [nauseous_heisenberg] DSL2 - revision: a04a9f2da0

[c9/763d42] say_hello (3)       | 3 of 3, cached: 3 ✔
[60/bc6831] convert_to_upper (3) | 3 of 3, cached: 3 ✔
[1a/bc5901] collect_greetings   | 1 of 1, cached: 1 ✔
There were 3 greetings in this batch
```

Let's do it one last time fo have the code completely modularized.

### 4. Modularize the `collect_greetings()` process

#### 4.1. Create a file stub for the new module

Create an empty file for the module called `collect_greetings.nf`.

```bash
touch modules/collect_greetings.nf
```

#### 4.2. Move the collect_greetings process code to the module file

Copy the whole process definition over from the workflow file to the module file, making sure to copy over the `#!/usr/bin/env` nextflow shebang too.

```nextflow
#!/usr/bin/env nextflow

// Collect uppercase greetings into a single output file
process collect_greetings {

    publishDir 'results', mode: 'copy'

    input:
        path input_files
        val batch_name

    output:
        path "COLLECTED-${batch_name}-output.txt" , emit: outfile
        val count_greetings , emit: count

    script:
        count_greetings = input_files.size()
    """
    cat ${input_files} > 'COLLECTED-${batch_name}-output.txt'
    """
}
```

Once that is done, delete the process definition from the workflow file, but make sure to leave the shebang in place.

#### 4.3. Add an import declaration before the workflow block

Insert the import declaration above the workflow block and fill it out appropriately.

```nextflow
// Include modules
include { say_hello } from './modules/say_hello.nf'
include { convert_to_upper } from './modules/convert_to_upper.nf'
include { collect_greetings } from './modules/collect_greetings.nf'

workflow {
```

#### 4.4. Run the workflow to verify that it does the same thing as before

Run this with the `-resume` flag.

```bash
nextflow run hello-modules.nf -resume
```

This should still produce the same output as previously.


```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-modules.nf` [friendly_coulomb] DSL2 - revision: 7aa2b9bc0f

[f6/cc0107] say_hello (1)       | 3 of 3, cached: 3 ✔
[3c/4058ba] convert_to_upper (2) | 3 of 3, cached: 3 ✔
[1a/bc5901] collect_greetings   | 1 of 1, cached: 1 ✔
There were 3 greetings in this batch
```

You know how to modularize multiple processes in a workflow.

Congratulations, you've done all this work and absolutely nothing has changed to how the pipeline works!

Now your code is more modular, and if you decide to write another pipeline that calls on one of those processes, you just need to type one short import statement to use the relevant module. This is better than just copy-pasting the code, because if later you decide to improve the module, all your pipelines will inherit the improvements.

