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

    // optional view statements
    //convert_to_upper.out.view { "Before collect: $it" }
    //convert_to_upper.out.collect().view { "After collect: $it" }
    
}
