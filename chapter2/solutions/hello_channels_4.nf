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

// Pipeline parameters
params.greeting = 'greetings.csv'

// Workflow
workflow {

    greetings_array = ['Hello','Bonjour','Hola']

    // create a channel for inputs from a CSV file
    greeting_ch = Channel.fromPath(params.greeting)
                        .view { "Before splitCsv: $it" }
                        .splitCsv()
                        .view { "After splitCsv: $it" }
                        .map { line -> line[0] }
                        .view { "After map: $it" }

    // emit a greeting
    say_hello(greeting_ch)
    
}
