process SEGMENTATION_SYNTHSEG {
    tag "$meta.id"
    label 'process_single'

    container "freesurfer/freesurfer:7.4.1"
    containerOptions "--entrypoint ''"

    input:
    tuple val(meta), path(image), path(lesion) /* optional, input = [] */, path(fs_license) /* optional, input = [] */

    output:
    tuple val(meta), path("*__mask_wm.nii.gz")                , emit: wm_mask
    tuple val(meta), path("*__mask_gm.nii.gz")                , emit: gm_mask
    tuple val(meta), path("*__mask_csf.nii.gz")               , emit: csf_mask
    tuple val(meta), path("*__vol.csv")                       , emit: vol, optional: true
    tuple val(meta), path("*__qc.csv")                        , emit: qc, optional: true
    tuple val(meta), path("*__resampled_image.nii.gz")        , emit: resample, optional: true
    path "versions.yml"                                       , emit: versions

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
    def output_vol = task.ext.output_vol ?  "--vol ${prefix}__vol.csv" : ""
    def output_qc = task.ext.output_qc ?  "--qc ${prefix}__qc.csv" : ""
    def output_resample = task.ext.output_resample ? "--resample ${prefix}__resampled_image.nii.gz": ""
    def crop = task.ext.crop ? "--crop " + task.ext.crop: ""

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    cp $fs_license \$FREESURFER_HOME/license.txt

    mri_synthseg --i $image --threads $task.cpus --o t1.nii.gz $gpu $parc $robust $fast $ct $output_vol $output_qc $output_resample $crop

    # WM Mask
    mri_binarize --i t1.nii.gz \
                --match 2 7 12 16 28 41 46 49 51 60 \
                --o ${prefix}__mask_wm.nii.gz

    # GM Mask
    mri_binarize --i t1.nii.gz \
                --match 3 8 11 17 18 26 42 47 50 \
                --o ${prefix}__mask_gm.nii.gz

    # CSF Mask
    mri_binarize --i t1.nii.gz \
                --match 4 5 14 15 24 43 44 \
                --o ${prefix}__mask_csf.nii.gz

    if [[ -f "$lesion" ]];
    then
        mri_binarize --i ${prefix}__mask_wm.nii.gz --union $lesion --o ${prefix}__mask_wm.nii.gz
    fi

    mri_convert -i ${prefix}__mask_wm.nii.gz --out_data_type uchar -o ${prefix}__mask_wm.nii.gz
    mri_convert -i ${prefix}__mask_gm.nii.gz --out_data_type uchar -o ${prefix}__mask_gm.nii.gz
    mri_convert -i ${prefix}__mask_csf.nii.gz --out_data_type uchar -o ${prefix}__mask_csf.nii.gz

    rm \$FREESURFER_HOME/license.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Freesurfer: 7.4.1
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mri_synthseg -h
    mri_binarize -h
    mri_convert -h

    touch ${prefix}__mask_wm.nii.gz
    touch ${prefix}__mask_gm.nii.gz
    touch ${prefix}__mask_csf.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Freesurfer: 7.4.1
    END_VERSIONS
    """
}
