#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../modules/nf-scil/load_test_data/main.nf'
include {
    REGISTRATION_SYNTHREGISTRATION as T1_FA; } from '../../../../../modules/nf-scil/registration/synthregistration/main.nf'

workflow test_registration_synthregistration {
    
    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_t1fa = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/t1.nii.gz"),
            file("${test_data_directory}/fa.nii.gz")
    ]}

    REGISTRATION_SYNTHREGISTRATION ( input_t1fa )

}
