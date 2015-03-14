# MADaq

National Instruments (MAtlab) Data AcQuisition and Experimental Modal Analysis library.

## Measurement functions:
- Monitor sensor activity
- Data logging
- Impact testing (in progress)
- Periodic input
- Stepped sinus
- Multisine (in progress)

## Additional functionality:
- Report generation (in progress)
  - Possible to generate a report in HTML format including all measurement information and if images are available of the test object, test team and individual sensors, they are also included.
  - This feature includes the measurement details but the output is not styled and sometimes the images are not included.

## Required MATLAB toolboxes:
- Data Acquisition Toolbox
- System Identification Toolbox
- Image Acquisition Toolbox (why?)
- Signal Processing Toolbox
- MATLAB Report Generator (if used)

## Required MATLAB version:
- 2015a
  - Developed mainly in this version.
- In 2014b AutoSyncDSA does not work.
- In 2014a some functions do not work and will generate errors due to missing functionality in the core MATLAB language.
- Older versions have not been tested.

## Future features:
- Make it possible to use both input and output on the National Instruments PXI-4461 card. For some reason this does not work and the force sensor must be put on one one of the inputs of the National Instruments PXIe-4497 cards.
- Make the window resizeable with some intelligence to it.
- Make the addition of input channels faster. For a large input array (over 30 inputs) it gradually slows down. So much that it becomes painful to watch.