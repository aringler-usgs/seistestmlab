seistestmlab
============

Matlab Seismometer Testing Scripts


Usage
============

To run this code open matlab and run the program noisemainplot.m.
When you do this a GUI should open and you can select data to plot.  All the 
response and digitizer values are nominal.  The idea is to avoid making the user
create a response file.

Example
===========

I have added an example of PFO data provided by Carl.  This is in the example folder.


To Do
===========

Need to link selfnoisemainplot.m with noisemainplot.m to avoid upkeeping 
both files.  

Need to add a spectral ratio program to allow for response estimates.

Need to produce better documentation.

Need to add decimation routines for mixed data types.

Need to verify the rdmseed deals with the bitcmp better.
