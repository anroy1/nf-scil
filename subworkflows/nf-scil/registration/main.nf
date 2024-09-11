include { REGISTRATION_ANATTODWI  } from '../../../modules/nf-scil/registration/anattodwi/main'
include { REGISTRATION_ANTS   } from '../../../modules/nf-scil/registration/ants/main'
include { REGISTRATION_EASYREG } from '../../../modules/nf-scil/registration/easyreg/main'

params.run_surgery = params.run_surgery?: false

workflow REGISTRATION {

    // ** The subworkflow requires at least ch_image and ch_ref as inputs to   ** //
    // ** properly perform the registration. Supplying a ch_metric will select ** //
    // ** the REGISTRATION_ANATTODWI module meanwhile NOT supplying a ch_metric    ** //
    // ** will select the REGISTRATION_ANTS (SyN or SyNQuick) module.          ** //

    take:
        ch_image                  // channel: [ val(meta), [ image ] ]
        ch_ref                    // channel: [ val(meta), [ ref ] ]
        ch_metric                 // channel: [ val(meta), [ metric ] ], optional
        ch_mask                   // channel: [ val(meta), [ mask ] ], optional
        ch_ref_segmentation       // channel: [ val(meta), [ ref_segmentation ] ], optional
        ch_flo_segmentation       // channel: [ val(meta), [ flo_segmentation ] ], optional

    main:

        ch_versions = Channel.empty()

        if ( ch_metric ) {
            // ** Set up input channel ** //
            ch_register =   ch_image.combine(ch_ref, by: 0)
                                    .combine(ch_metric, by: 0)

            // ** Registration using AntsRegistration ** //
            REGISTRATION_ANATTODWI ( ch_register )
            ch_versions = ch_versions.mix(REGISTRATION_ANATTODWI.out.versions.first())

            // ** Setting outputs ** //
            image_warped = REGISTRATION_ANATTODWI.out.t1_warped
            ref_warped = Channel.empty()
            transfo_image = REGISTRATION_ANATTODWI.out.transfo_image
            transfo_trk = REGISTRATION_ANATTODWI.out.transfo_trk
            ref_segmentation = Channel.empty()
            image_segmentation = Channel.empty()
        }
        else if ( params.run_surgery ) {
            // ** Set up input channel ** //
            ch_register = ch_ref.combine(ch_image, by: 0)
                                .combine(ch_ref_segmentation, by: 0)
                                .combine(ch_flo_segmentation, by: 0)

            // ** Registration using Easyreg ** //
            REGISTRATION_EASYREG ( ch_register )
            ch_versions = ch_versions.mix(REGISTRATION_EASYREG.out.versions.first())

            // ** Setting outputs ** //
            image_warped = REGISTRATION_EASYREG.out.flo_reg
            transfo_image = REGISTRATION_EASYREG.out.fwd_field
                                                    .map{ it + [[]] }
            transfo_trk = REGISTRATION_EASYREG.out.bak_field
                                                    .map{ [[]] + it }
            ref_warped - REGISTRATON_EASYREG.out.ref_reg

            // ** Setting optional outputs. If segmentations are not provided as inputs, ** //
            // ** easyreg will outputs synthseg segmentations ** //
            ref_segmentation = ch_ref_segmentation ? REGISTRATION_EASYREG.out.ref_seg : Channel.empty()
            flo_segmentation = ch_ref_segmentation ? REGISTRATION_EASYREG.out.flo_seg : Channel.empty()

        }
        else {
            // ** Set up input channel, input are inverted compared to REGISTRATION_ANATTODWI. ** //
            if ( ch_mask ) {
                ch_register = ch_ref.combine(ch_image, by: 0)
                                    .combine(ch_mask, by: 0)
            }
            else {
                ch_register = ch_ref.combine(ch_image, by: 0)
                                    .map{ it + [[]] }
            }

            // ** Registration using antsRegistrationSyN.sh or antsRegistrationSyNQuick.sh. ** //
            // ** Has to be defined in the config file or else the default (SyN) will be    ** //
            // ** used.                                                                     ** //
            REGISTRATION_ANTS ( ch_register )
            ch_versions = ch_versions.mix(REGISTRATION_ANTS.out.versions.first())

            // ** Setting outputs ** //
            image_warped = REGISTRATION_ANTS.out.image
            ref_warped = Channel.empty()
            transfo_image = REGISTRATION_ANTS.out.transfo_image
            transfo_trk = REGISTRATION_ANTS.out.transfo_trk
            ref_segmentation = Channel.empty()
            flo_segmentation = Channel.empty()
        }

    emit:
        image_warped  = image_warped           // channel: [ val(meta), [ image ] ]
        ref_warped = ref_warped                // channel: [ val(meta), [ ref ] ]
        transfo_image = transfo_image          // channel: [ val(meta), [ warp, affine ] ]
        transfo_trk   = transfo_trk            // channel: [ val(meta), [ inverseAffine, inverseWarp ] ]
        ref_segmentation = ref_segmentation    // channel: [ val(meta), [ ref_seg ] ]
        flo_segmentation = flo_segmentation    // channel: [ val(meta), [ flo_seg ] ]

        versions = ch_versions                 // channel: [ versions.yml ]
}
