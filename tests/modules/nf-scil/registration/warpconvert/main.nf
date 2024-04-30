#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'
include { REGISTRATION_WARPCONVERT } from '../../../../../modules/nf-scil/registration/warpconvert/main.nf'

workflow test_registration_warpconvert {

    input_fetch = Channel.from( [ "freesurfer.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input = LOAD_TEST_DATA.out.test_data_directory
        .map{ test_data_directory -> [
        [ id:'test', single_end:false ], // meta map
        file("${test_data_directory}/deform.nii.gz"),
        file("${test_data_directory}/affine.nii.gz"),
        file("${test_data_directory}/t1.nii.gz"),
        file("${test_data_directory}/fa.nii.gz"),
        file("${test_data_directory}/license.txt")

    ]}

    REGISTRATION_WARPCONVERT ( input )
}
