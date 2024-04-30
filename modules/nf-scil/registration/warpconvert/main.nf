process REGISTRATION_WARPCONVERT {
    tag "$meta.id"
    label 'process_single'

    container "freesurfer/synthmorph:latest"
    containerOptions "--entrypoint ''"

    input:
    tuple val(meta), path(deform), path(affine), path(source) /* optional, value = [] */, path(target) /* optional, value = [] */, path(fs_license) /* optional, value = [] */

    output:
    tuple val(meta), path("*.txt"), emit: init_transform
    tuple val(meta), path("*.nii.gz"), emit: deform_transform
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    //For arguments definition, lta_convert -h
    def invert = task.ext.invert ? "--invert" : ""
    def source_geometry_init = "$source" ? "--src" + "$source" : ""
    def target_geometry_init = "$target" ? "--trg" + "$target" : ""
    def out_format_init = task.ext.out_format_init ? "--out" + task.ext.out_format_init : "--outitk"

    //For arguments definition, mri_warp_convert -h
    def source_geometry_deform = "$source" ? "--insrcgeom" + "$source" : ""
    def in_format_deform = task.ext.in_format_deform ? "--in" + task.ext.in_format_deform : "--inras"
    def out_format_deform = task.ext.out_format_deform ? "--out" + task.ext.out_format_deform : "--outitk"
    def downsample = task.ext.downsample ? "--downsample" : ""


    """
    lta_convert $source_geometry_init $target_geometry_init $out_format_init ${prefix}__init_warp.txt
    mri_warp_convert $source_geometry_deform $downsample $out_format_deform  ${prefix}__deform_warp.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Freesurfer: 7.4.1
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    lta_convert -h
    mri_warp_convert -h

    touch ${prefix}__init_transform.txt
    touch ${precix}__deform_transform.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Freesurfer: 7.4.1
    END_VERSIONS
    """
}
