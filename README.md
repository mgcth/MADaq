National Instruments (MAtlab) Data AcQuisition and Experimental Modal Analysis library.

Below follows a brief summary of the application.

Measurement functions:
- Monitor sensor activity
- Data logging
- Impact testing (in progress)
- Periodic input
- Stepped sinus
- Multisine (in progress)

Additional functionality:
- Report generation (in progress)
  - Possible to generate a report in HTML format (others possible too) including all measurement information and if images are available of the test object, test team and individual sensors, they are also included.
  - This feature includes the measurement details but the output is not styled and sometimes the images are not included.

Required MATLAB toolboxes:
- 

Required MATLAb version:
- 2015a
  - Developed mainly in this version.
- In 2014b AutoSyncDSA does not work.
- In 2014a some functions does not work and will generate errors due to missing functionality in the core MATLAB language.
- Older versions have not been tested.

Future features:
- Make it possible to use both Input and Output on the National Instruments PXI-4461 card. For some reason this does not work and the force sensor must be put on one of the National Instruments PXIe-4497 cards.
- Make the window resizeable with some intelligence to it.