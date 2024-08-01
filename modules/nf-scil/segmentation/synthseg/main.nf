process SEGMENTATION_SYNTHSEG {
    tag "$meta.id"
    label 'process_single'

    container "freesurfer/freesurfer:7.4.1"
    containerOptions "--entrypoint ''"

    input:
    tuple val(meta), path(image), path(lesion)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    def gpu = task.ext.gpu ? "" : "--cpu"
    def parc = task.ext.parc ? "--parc" : ""
    def robust = task.ext.robust ? "--robust" : ""
    def fast = task.ext.fast ? "--fast" : ""
    def ct = task.ext.ct ? "--ct" : ""
    //TODO add all the others parameter with the corresponding optional outputs

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    mri_synthseg --i $image --o t1.nii.gz $--threads 1 gpu $parc $robust $fast $ct

    # WM Mask
    mri_binarize --i t1.nii.gz \
                --match 2 7 12 16 28 41 46 49 51 60 \
                --o ${prefix}__mask_wm.ni.gz

    # GM Mask
    mri_binarize --i t1.nii.gz \
                --match 3 8 11 17 18 26 42 47 50 \
                --o ${prefix}__mask_wm.ni.gz

    # CSF Mask
    mri_binarize --i t1.nii.gz \
                --match 4 5 14 15 24 43 44 \
                --o ${prefix}__mask_wm.ni.gz

    if [[ -f "$lesion" ]];
    then
        mri_binarize --i ${prefix}__mask_wm.ni.gz --union $lesion --o ${prefix}__mask_wm.ni.gz
    fi

    mri_convert --i ${prefix}__mask_wm.ni.gz --out_data_type uchar --o ${prefix}__mask_wm.ni.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        segmentation: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        segmentation: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
