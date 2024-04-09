process REGISTRATION_SYNTHREGISTRATION {
    tag "$meta.id"
    label 'process_single'

    container "freesurfer/freesurfer:7.4.1"
    containerOptions "--entrypoint ''"

    input:
    tuple val(meta), path(moving), path(fixed), path(fs_license) /* optional, value = [] */


    output:
    tuple val(meta), path("*__output_warped.nii.gz"), emit: warped_image
    tuple val(meta), path("*__deform_warp.nii.gz"), emit: deform_transform
    tuple val (meta), path("*__init_warp.txt"), emit: init_transform
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    def init = task.ext.init ? "-m " + task.est.init : "-m affine"
    def warp = task.ext.warp ? "-m " + task.est.warp : "-m deform"
    def header = task.ext.header ? "-H" : ""
    def threads = task.ext.threads ? "-j " + task.ext.threads : ""
    def gpu = task.ext.gpu ? "-g" : ""
    def smooth = task.ext.smooth ? "-s " + task.ext.smooth : ""
    def extent = task.ext.extent ? "-e " + task.ext.extent : ""
    def weight = task.ext.weight ? "-w " + task.ext.weight : ""

    //For arguments definition, mri_warp_convert -h
    def out_format = task.ext.out_format ? "--out" + task.ext.out_format : "--outlps"

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    mri_synthmorph $init -t ${prefix}__init_warp.txt $moving $fixed
    mri_synthmorph $warp -i ${prefix}__init_warp.txt  -t temp.mgz -o ${prefix}__output_warped.nii.gz $moving $fixed

    mri_warp_convert -g $moving --inras temp.mgz $out_format ${prefix}__deform_warp.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Freesurfer: 7.4
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mri_synthmorph -h

    mri_warp_convert -h

    touch ${prefix}__output_warped.nii.gz
    touch ${prefix}__deform_warp.nii.gz
    touch ${prefix}__init_warp.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Freesurfer: 7.4
    END_VERSIONS
    """
}
