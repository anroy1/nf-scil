#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_T1_SF } from '../../../../subworkflows/nf-scil//main.nf'

workflow test_preproc_t1_sf {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    PREPROC_T1_SF ( input )
}
