# Installation Notes

## Configuration

At present, one has to set configuration parameters in 2 different places.

1. matlab (paths)

        cp matlab/get_config_sample.m matlab/get_config.m
        edit matlab/get_config.php

2. php (paths and database settings)

        cp php/config-sample.php php/config.php
        edit php/config.php

## Permissions

Folders that require special permissions:

/InputScript/Failed
/InputScript/Input
/InputScript/Running
/InputScript/TooLong
/Results

## Running WebFR3D

    cd path/to/webfr3d
    perl webfr3d_queue.pl

## Database

4 tables from the RNA 3D Hub database are used:

* pdb_info
* pdb_coordinates
* nr_releases
* nr_pdbs