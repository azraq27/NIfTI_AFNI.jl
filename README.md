Take a NIfTI extension object and parse the AFNI header extensions.

Usage:

    using NIfTI,NIfTI_AFNI
    
    d = niread("dataset.nii.gz")
    a = AFNIExtension(d.extensions[1])
    
    a.header # a Dict containing all of the AFNI fields
    
    a.header["BRICK_LABS"] # => Vector of brick label names
    a.header["BRICK_STATSYM"] # => Vector of the stat parameters