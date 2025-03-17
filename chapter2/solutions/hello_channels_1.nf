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
params.greeting = 'Holà mundo!'

// Workflow
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello Channels!')

    // emit a greeting
    sayHello(greeting_ch)
    
}
