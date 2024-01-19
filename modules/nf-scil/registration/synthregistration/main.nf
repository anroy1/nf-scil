process REGISTRATION_SYNTHREGISTRATION {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
    tuple val(meta), path(moving), path(fixed)


    output:
    tuple val(meta), path("*__*_output_warped.nii.gz"), emit: warped_image
    tuple val(meta), path("*__deform_warp.nii.gz"), emit: deform_transform
    tuple val (meta), path("*__init_warp.txt"), emit: affine_transform
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when_output_warped

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def suffix = task.ext.suffix ?: ""

    def header = task.ext.header ? "-H "  + task.ext.header : ""
    def threads = task.ext.threads ? "-j "  + task.ext.threads : ""
    def gpu = task.ext.gpu ? "-g "  + task.ext.gpu : ""
    def smooth = task.ext.smooth ? "-s "  + task.ext.smooth : ""
    def extent = task.ext.extent ? "-e "  + task.ext.extent : ""
    def weight = task.ext.weight ? "-w "  + task.ext.weight : ""

    //For argument definition, mri_warp_convert -h
    def out = task.ext.out ? "--out" + task.ext.out : "--outlps"

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    mri_synthmorph -m affine -t ${prefix}__init_warp.txt $moving $fixed
    mri_synthmorph -m deform -i ${prefix}__init_warp.txt  -t temp.mgz -o ${prefix}__${suffix}_output_warped.nii.gz $moving $fixed

    mri_warp_convert -g $moving --inras temp.mgz $out ${prefix}__deform_warp.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def suffix = task.ext.suffix ?: "${meta.}"

    def header = task.ext.header ? "-H "  + task.ext.header : ""
    def threads = task.ext.threads ? "-j "  + task.ext.threads : ""
    def gpu = task.ext.gpu ? "-g "  + task.ext.gpu : ""
    def smooth = task.ext.smooth ? "-s "  + task.ext.smooth : ""
    def extent = task.ext.extent ? "-e "  + task.ext.extent : ""
    def weight = task.ext.weight ? "-w "  + task.ext.weight : ""

    def out = task.ext.out ? "--out" + task.ext.out : "lps"
    """
    mri_synthmorph -h

    mri_warp_convert -h

    touch ${prefix}__${suffix}_output_warped.nii.gz
    touch ${prefix}__deform_warp.nii.gz
    touch ${prefix}__init_warp.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
