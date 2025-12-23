# Changelog

## gst 0.3.0

Last release on GitLab. `gst` will move to GitHub for all future
development

### Major Changes

- Added
  [`obrien_plus()`](https://sarepta-therapeutics.github.io/gst/reference/obrien_plus.md)
  to compute power for joint endpoints and any individual endpoint

- Added
  [`obt()`](https://sarepta-therapeutics.github.io/gst/reference/obt.md)
  to perform O’Brien truncated closed testing

### Minor Changes

- Improved functionality and UI of
  [`make_forestplot_app()`](https://sarepta-therapeutics.github.io/gst/reference/make_forestplot_app.md)
  and
  [`gst_power_app()`](https://sarepta-therapeutics.github.io/gst/reference/gst_power_app.md)

## gst 0.2.0

### Major Changes

- Custom columns feature with option to reorder/resize columns

- Improved downloads: preview/adjust the image in real-time

### Minor Changes

- Improved R code generator: more robust to future changes; added
  options to remove `gst` dependency, ‘copy to clipboard’, or ‘download’

- Added dynamic default parameters based on input data

- Axes: customize tick marks; toggle symmetry on/off

- Arrows: customize/reverse arrow labels

### Bug Fixes

- Fixed infinite loop when selecting ‘Number of Trees’

- Fixed issue with `invert` column when copy/pasting data

## gst 0.1.0

Initial release.

Includes functions to launch two shiny applications:

- GST Power App:
  [`gst_power_app()`](https://sarepta-therapeutics.github.io/gst/reference/gst_power_app.md)
- Make Forestplot App:
  [`make_forestplot_app()`](https://sarepta-therapeutics.github.io/gst/reference/make_forestplot_app.md)

GST Power App can be used to run power and sample size calculations for
the Global Statistical Test under a variety of scenarios. Additional
details can be found in the vignette.

Make Forestplot App allows users to easily generate a forestplot by
uploading data, copy/pasting from a spreadsheet, or manually typing. The
resulting plot can be resized and visually customized in a variety of
ways. Also included are options to handle endpoints with inverted
directionality and different scales. See the vignette for additional
details.
