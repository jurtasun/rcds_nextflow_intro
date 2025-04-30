#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */
params.greeting = 'greetings.csv'
params.batch = 'test-batch'

// Include modules
include { say_hello } from './modules/say_hello.nf'
include { convert_to_upper } from './modules/convert_to_upper.nf'
include { collect_greetings } from './modules/collect_greetings.nf'

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
