#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { REGISTRATION_SYNTHREGISTRATION } from '../../../../../modules/nf-scil/registration/synthregistration/main.nf'

workflow test_registration_synthregistration {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['registration']['synthregistration']['t1'], checkIfExists: true),
        file(params.test_data['registration']['synthregistration']['fa'], checkIfExists: true),
        file(params.test_data['registration']['synthregistration']['fs_license'], checkIfExists: true)
    ]

    REGISTRATION_SYNTHREGISTRATION ( input )
}
