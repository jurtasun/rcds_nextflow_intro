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

// Pipeline parameters
params.greeting = 'greetings.csv'
params.batch = 'test-batch'

// Include modules
include { say_hello } from './modules/say_hello.nf'
include { convert_to_upper } from './modules/convert_to_upper.nf'

// Workflow
workflow {

    // create a channel for inputs from a CSV file
    greeting_ch = Channel.fromPath(params.greeting)
                        .splitCsv()
                        .map { line -> line[0] }

    // emit a greeting
    say_hello(greeting_ch)

    // convert the greeting to uppercase
    convert_to_upper(say_hello.out)

    // collect all the greetings into one file
    collect_greetings(convert_to_upper.out.collect(), params.batch)

    // emit a message about the size of the batch
    collect_greetings.out.count.view { "There were $it greetings in this batch" }

}
