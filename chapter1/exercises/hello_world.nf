#!/usr/bin/env nextflow

// Use echo to print 'Hello World!' to a file
process say_hello {

    output:
        path 'output.txt'

    script:
    """
    echo 'Hello World!' > output.txt
    """
    
}

// Workflow
workflow {

    // emit a greeting
    say_hello()

}
