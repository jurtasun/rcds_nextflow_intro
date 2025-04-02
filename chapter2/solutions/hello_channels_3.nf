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
params.greeting = 'Hola mundo'

// Workflow
workflow {

    greetings_array = ['Hello','Bonjour','Hola']

    // create a channel for inputs
    greeting_ch = Channel.of(greetings_array)
                    .view { "Before flatten: $it" }
                    .flatten()
                    .view { "After flatten: $it" }

    // emit a greeting
    say_hello(greeting_ch)
    
}
