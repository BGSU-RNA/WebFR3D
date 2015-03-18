# About

**WebFR3D** is the on-line version of ‘Find RNA 3D’
([FR3D](http://rna.bgsu.edu/FR3D)), a program for annotating atomic-resolution
RNA 3D structure files and searching them efficiently to locate and compare RNA
3D structural motifs.

WebFR3D provides on-line access to the central features of FR3D, including
geometric and symbolic search modes, without need for installing programs or
downloading and maintaining 3D structure data locally.

In **_geometric search mode_**, WebFR3D finds all motifs similar to a
user-specified query structure. In **_symbolic search mode_**, WebFR3D finds
all sets of nucleotides making user-specified interactions. In both modes,
users can specify sequence, sequence–continuity, base pairing, base-stacking
and other constraints on nucleotides and their interactions.

WebFR3D can be used to locate hairpin, internal or junction loops, list all
base pairs or other interactions, or find instances of recurrent RNA 3D motifs
(such as sarcin–ricin and kink-turn internal loops or T- and GNRA hairpin
loops) in any PDB file or across a whole set of 3D structure files.

The output page provides facilities for comparing the instances returned by the
search by superposition of the 3D structures and the alignment of their
sequences annotated with pairwise interactions. WebFR3D is available at
[http://rna.bgsu.edu/webfr3d](http://rna.bgsu.edu/webfr3d).

WebFR3D was published in the [2011 NAR Webserver
Issue](http://nar.oxfordjournals.org/content/39/suppl_2/W50).


# Implementation #

This is flask application that uses background workers in python to do the
actual processing. We use beanstalk as the queue to talk to the workers.
Results are stored in a mysql database for future lookups. Queries are never
repeated on the same data.
