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
    tuple val(meta), path("*__output_warp.nii.gz"), emit: transform
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def suffix = task.ext.suffix ?: "${meta.}"

    def header = task.ext.header ? "-H "  + task.ext.header : ""
    def threads = task.ext.threads ? "-j "  + task.ext.threads : ""
    def gpu = task.ext.gpu ? "-g "  + task.ext.gpu : ""
    def smooth = task.ext.smooth ? "-s "  + task.ext.smooth : ""
    def extent = task.ext.extent ? "-e "  + task.ext.extent : ""
    def weight = task.ext.weight ? "-w "  + task.ext.weight : ""

    def interp = task.ext.interp ? "-n "  + task.ext.interp : ""
    def dimensionality = task.ext.dimensionality ? "-d "  + task.ext.dimensionality : ""
    def imagetype = task.ext.imagetype ? "-e "  + task.ext.imagetype : ""

    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    mri_synthmorph -m affine -t init.txt $moving $fixed
    mri_synthmorph -m deform -i init.txt -t ${prefix}__output_warp.mgz -o ${prefix}__${suffix}_output_warped.nii.gz $moving $fixed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def suffix = task.ext.suffix ?: "${meta.}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    mri_synthmorph -h

    touch ${prefix}__${suffix}_output_warped.nii.gz
    touch ${prefix}__output_warp.mgz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
