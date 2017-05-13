Environment: OS X El Capitan
Language: Matlab R2016b

Note: You should run files in the order as following.

Feature Detection and Description:
  msop.m:
    Pictures should be put under input_image/, and you may need to change the
    variable END for your own pictures. Also, remember that you need to create a
    directory msop/. This program will generate files of feature vectors and
    images with red points which is feature points.

Warping:
  warping.m:
    After msop, you need to do cylindrical warping in order to get a better
    panorama. Before running this file, you should create a directory, warping/.

Feature Matching:
  exhaustive_match.m:
    This file do exhaustive feature matching. Note that you should create a
    directory, exhaustive/, and it will output files that stores positions of
    matching points.
  hash_match.m
    This file do wavelet-based hash feature matching. Note that you should
    create a directory, make_pair/, and it will output files that stores positions
    of matching points.

Alignment:
  ransac.m ( ransac_exhaustive.m ):
    This two files do ransac on each feature matching pairs in different
    directory. Note that you should create a directory named offset/. And it
    will output X and Y offsets for each pair of images.

Blending:
  blend.m:
  1) linear_blending
  2) multi-band blending

Recognizing Panoramas:
  If you want to do recognizing panorama, execute the following files in the
  order. Your images for recognizing should be put under the directory
  recognizing_image/.

  msop_recognizing.m:
    Just msop under recognizing_image/. You should create a directory,
    msop_recognizing/ to store outputs.

  exhaustive_match_for_recognizing.m:
    do the exhaustive feature matching on all pairs of images. You should create
    a directory, exhaustive_recognizing/.

  ransac_recognizing.m:
    ransac on all results of feature matching, and count inliers and outliers
    that are in the overlapping area. You should create a directory,
    offset_recognizing/.

  recognizing.m:
    Based on the results under offset_recognizing/, find the order of original
    images. The rule is followed ther paper of recognizing panoramas.

Rectangling Panoramas:
  seam_carving.m:
    You can use this file to resize your image in a better way, comparing to
    scaling and cropping. You should create a directory, carving/. And name the
    image you want to resize source.jpg. And the resized file will be named
    result.jpg.
