

process REGISTRATION_EASYREG {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.0.2.sif':
        'scilus/scilus:2.0.2' }"

    input:
    tuple val(meta), path(reference), path(floating), path(ref_segmentation), path(flo_segmentation)

    output:
    tuple val(meta), path("${prefix}_reference_segmentation.nii.gz") , emit: ref_seg
    tuple val(meta), path("${prefix}_floating_segmentation.nii.gz")  , emit: flo_seg
    tuple val(meta), path("${prefix}_reference_registered.nii.gz")   , emit: ref_reg
    tuple val(meta), path("${prefix}_floating_registered.nii.gz")    , emit: flo_reg
    tuple val(meta), path("${prefix}_forward_field.nii.gz")          , emit: fwd_field
    tuple val(meta), path("${prefix}_backward_field.nii.gz")         , emit: bak_field
    path "versions.yml"                                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def threads = task.ext.threads ? "--threads " + task.ext.threads : ""
    def affine = task.ext.affine ? "--affine_only " : ""

    """
    if [[ -f "$ref_segmentation" ]];
    then
        reference_segmentation = $ref_segmentation
    else
        reference_segmentation = ${prefix}_reference_segmentation.nii.gz
    fi

        if [[ -f "$flo_segmentation" ]];
    then
        floating_segmentation = $flo_segmentation
    else
        floating_segmentation = ${prefix}_floating_segmentation.nii.gz
    fi

    mri_easyreg --ref $reference --flo $floating --ref_seg \${reference_segmentation} --flo_seg --ref_seg \${reference_segmentation} \
        --flo_reg ${prefix}_floating_registered.nii.gz --ref_reg ${prefix}_reference_registered.nii.gz --fwd_field ${prefix}_forward_field.nii.gz \
        --bak_field ${prefix}_backward_field.nii.gz $threads $affine

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freesurfer: 7.4
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mri_easyreg -h

    touch ${prefix}_reference_segmentation.nii.gz
    touch ${prefix}_floating_segmentation.nii.gz
    touch ${prefix}_reference_registered.nii.gz
    touch ${prefix}_floating_registered.nii.gz
    touch ${prefix}_forward_field.nii.gz
    touch ${prefix}_backward_field.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freesurfer: 7.4
    END_VERSIONS
    """
}
