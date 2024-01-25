             Instructions for working with the Eastern Tennessee event data set

  First I ran hypo2foc to convert the hypoellipse output file into
    a focmec input file.

  rhypo2foc
     The input file (read in automatically) is 8703270729.arc
     In the original version of the program, the output file included solutions
     for which there was no polarity and used the same symbol for eergent and
     impulsive arrivals.  In the 2017 version, only stations with polarities are
     included and emergent arrivals are so coded.  The output file is 
     8703270729.inp. The original output file, 8703270729.dat, is included in 
     ../doc/ETNEvent-doc/.

  Included are driver files for four runs of focmec and two runs of focplt.  See
  the scripts for the names of the output files.

     rfocmec_UW-4 (four unity-weighted errors) and rfocmec_RW-1.75 (RW cut-off 
     1.75) use 8703270729.inp as the input file including emergent arrivals
     (which is what was done by Chapman, et al., 1996).

     The chosen solution is not included in the relative-weighted solution, 
     which only kept solutions with 1.75 errors or less, so I did a focmec run 
     with relative weighting with a cut-off of 2.: rfocmec_RW-2.0.  Using the
     2.0 cut-off includes the chosen solution (1.97) and the other 12
     unity-weighting 4 solutions among the 168 solutions.

     Three of the four polarity errors for the 13 unity-weighting 4 solutions 
     are for emergent arrivals, so I did a focmec run not including emergent 
     arrivals  with only one polarity error: rfocmec_UW-1_ne for which there are 
     168 solutions.
     
     Input for the two focplt runs are for
     (1) the published  and best RW solutions plus data; and
     (2) all the unity-weighted 4-error solutions plus the four best RW 
         solutions

  Copies of successful output files, including the PDF version of plots, 
  are in ../../doc/ETNEvent-doc/
