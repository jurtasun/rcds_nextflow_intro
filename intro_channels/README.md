## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png">
<img src="/readme_figures/nextflow-logo.png">

### Introduction: Channels.

### 1 Channel types

Channels are a key data structure of Nextflow that allows the implementation of reactive-functional oriented computational workflows based on the Dataflow programming paradigm. They are used to logically connect tasks to each other or to implement functional style data transformations. Nextflow distinguishes two different kinds of channels: **queue** channels and **value** channels.

#### 1.1 Queue channel

A **queue** channel is an *asynchronous* unidirectional FIFO queue that connects two processes or operators.

- asynchronous means that operations are non-blocking.
- unidirectional means that data flows from a producer to a consumer.
- FIFO means that the data is guaranteed to be delivered in the same order as it is produced. First In, First Out.
A queue channel is implicitly created by process output definitions or using channel factories such as `Channel.of()` or `Channel.fromPath()`.

Try the following code:
```nextflow
ch = Channel.of(1, 2, 3)
ch.view()
```

### 1.2 Value channels

A *value* channel (a.k.a. a singleton channel) is bound to a single value and it can be read unlimited times without consuming its contents. A `value` channel is created using the `value` channel factory or by operators returning a single value, such as `first`, `last`, `collect`, `count`, `min`, `max`, `reduce`, and `sum`.

To see the difference between value and queue channels, you can try the following:

```nextflow
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.of(1)

process SUM {
    input:
    val x
    val y

    output:
    stdout

    script:
    """
    echo \$(($x+$y))
    """
}

workflow {
    SUM(ch1, ch2).view()
}
```

This workflow creates two channels, `ch1` and `ch2`, and then uses them as inputs to the SUM process. The SUM process sums the two inputs and prints the result to the standard output.

When you run this script, it only prints `2`.

A process will only instantiate a task when there are elements to be consumed from all the channels provided as input to it. Because `ch1` and `ch2` are queue channels, and the single element of `ch2` has been consumed, no new process instances will be launched, even if there are other elements to be consumed in `ch1`.

To use the single element in `ch2` multiple times, you can either use the `Channel.value` channel factory, or use a channel operator that returns a single element, such as `first()`:

```nextflow
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.value(1)

process SUM {
    input:
    val x
    val y

    output:
    stdout

    script:
    """
    echo \$(($x+$y))
    """
}

workflow {
    SUM(ch1, ch2).view()
}
```
In many situations, Nextflow will implicitly convert variables to value channels when they are used in a process invocation.

For example, when you invoke a process with a workflow parameter (`params.ch2`) which has a string value, it is automatically cast into a value channel:

```nextflow
ch1 = Channel.of(1, 2, 3)
params.ch2 = "1"

process SUM {
    input:
    val x
    val y

    output:
    stdout

    script:
    """
    echo \$(($x+$y))
    """
}

workflow {
    SUM(ch1, params.ch2).view()
}
```

### 2. Channel factories

Channel factories are Nextflow commands for creating channels that have implicit expected inputs and functions. There are several different Channel factories which are useful for different situations. The following sections will cover the most common channel factories. 

Tip: Since version 20.07.0, `channel` was introduced as an alias of `Channel`, allowing factory methods to be specified as `channel.of()` or `Channel.of()`, and so on.

#### 2.1 `value()`

The `value` channel factory is used to create a *value* channel. An optional not `null` argument can be specified to bind the channel to a specific value. For example:

```nextflow
ch1 = Channel.value() 
ch2 = Channel.value('Hello there') 
ch3 = Channel.value([1, 2, 3, 4, 5])
```

#### 2.1 `of()`

The `Channel.of` factory allows the creation of a *queue* channel with the values specified as arguments.

```nextflow
Channel
    .of(1, 3, 5, 7)
    .view()
```

The `Channel.of` channel factory works in a similar manner to `Channel.from` (which is now deprecated), fixing some inconsistent behaviors of the latter and providing better handling when specifying a range of values. For example, the following works with a range from 1 to 23:

```nextflow
Channel
    .of(1..23, 'X', 'Y')
    .view()
```

#### 2.1 `fromList()`

The `Channel.fromList` factory creates a channel emitting the elements provided by a list object specified as an argument:

```nextflow
list = ['hello', 'world']

Channel
    .fromList(list)
    .view()
```

#### 2.1 `fromPath()`

The `Channel.fromPath` factory creates a queue channel emitting one or more files matching the specified glob pattern.

```nextflow
Channel
    .fromPath('./data/meta/*.csv')
```

This example creates a channel and emits as many items as there are files with a `csv` extension in the `./data/meta` folder. 
Each element is a file object implementing the Path interface.

#### 2.1 `fromFilePairs()`

The `Channeld.fromFilePairs` factory creates a channel emitting the file pairs matching a glob pattern provided by the user. The matching files are emitted as tuples, in which the first element is the grouping key of the matching pair and the second element is the list of files (sorted in lexicographical order).

```nextflow
Channel
    .fromFilePairs('./data/ggal/*_{1,2}.fq')
    .view()
```

The glob pattern must contain at least an asterisk wildcard character `(*)`. It will produce an output similar to the following:

```bash
[liver, [/workspaces/training/nf-training/data/ggal/liver_1.fq, /workspaces/training/nf-training/data/ggal/liver_2.fq]]
[gut, [/workspaces/training/nf-training/data/ggal/gut_1.fq, /workspaces/training/nf-training/data/ggal/gut_2.fq]]
[lung, [/workspaces/training/nf-training/data/ggal/lung_1.fq, /workspaces/training/nf-training/data/ggal/lung_2.fq]]
```

#### 2.1 `fromSRA()`

The `Channel.fromSRA` channel factory makes it possible to query the **NCBI SRA** [https://www.ncbi.nlm.nih.gov/sra] archive and returns a channel emitting the FASTQ files matching the specified selection criteria.

The query can be project ID(s) or accession number(s) supported by the **NCBI ESearch API** [https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESearch].

Instructions for NCBI login and key acquisition
- Go to: https://www.ncbi.nlm.nih.gov/
- Click the top right "Log in" button to sign into NCBI. Follow their instructions.
- Once into your account, click the button at the top right, usually your ID.
- Go to Account settings
- Scroll down to the API Key Management section.
- Click on "Create an API Key".
- The page will refresh and the key will be displayed where the button was. Copy your key.

The following snippet will print the contents of an NCBI project ID:

```nextflow
params.ncbi_api_key = '<Your API key here>'
// 006b358f9e573c26b571813f5eb43decee09 example key

Channel
    .fromSRA(['SRP073307'], apiKey: params.ncbi_api_key)
    .view()
```

Replace `<Your API key here>` with your API key.

```bash
[SRR3383346, [/vol1/fastq/SRR338/006/SRR3383346/SRR3383346_1.fastq.gz, /vol1/fastq/SRR338/006/SRR3383346/SRR3383346_2.fastq.gz]]
[SRR3383347, [/vol1/fastq/SRR338/007/SRR3383347/SRR3383347_1.fastq.gz, /vol1/fastq/SRR338/007/SRR3383347/SRR3383347_2.fastq.gz]]
[SRR3383344, [/vol1/fastq/SRR338/004/SRR3383344/SRR3383344_1.fastq.gz, /vol1/fastq/SRR338/004/SRR3383344/SRR3383344_2.fastq.gz]]
[SRR3383345, [/vol1/fastq/SRR338/005/SRR3383345/SRR3383345_1.fastq.gz, /vol1/fastq/SRR338/005/SRR3383345/SRR3383345_2.fastq.gz]]
// (remaining omitted)
```

Multiple accession IDs can be specified using a list object:
```nextflow
ids = ['ERR908507', 'ERR908506', 'ERR908505']
Channel
    .fromSRA(ids, apiKey: params.ncbi_api_key)
    .view()
```

```bash
[ERR908507, [/vol1/fastq/ERR908/ERR908507/ERR908507_1.fastq.gz, /vol1/fastq/ERR908/ERR908507/ERR908507_2.fastq.gz]]
[ERR908506, [/vol1/fastq/ERR908/ERR908506/ERR908506_1.fastq.gz, /vol1/fastq/ERR908/ERR908506/ERR908506_2.fastq.gz]]
[ERR908505, [/vol1/fastq/ERR908/ERR908505/ERR908505_1.fastq.gz, /vol1/fastq/ERR908/ERR908505/ERR908505_2.fastq.gz]]
```

Read pairs are implicitly managed and are returned as a list of files.
It’s straightforward to use this channel as an input using the usual Nextflow syntax.
The code below creates a channel containing two samples from a public SRA study and runs `FASTQC` on the resulting files. See:

```nextflow
params.ncbi_api_key = '<Your API key here>'

params.accession = ['ERR908507', 'ERR908506']

process FASTQC {
    input:
    tuple val(sample_id), path(reads_file)

    output:
    path("fastqc_${sample_id}_logs")

    script:
    """
    mkdir fastqc_${sample_id}_logs
    fastqc -o fastqc_${sample_id}_logs -f fastq -q ${reads_file}
    """
}

workflow {
    reads = Channel.fromSRA(params.accession, apiKey: params.ncbi_api_key)
    FASTQC(reads)
}
```