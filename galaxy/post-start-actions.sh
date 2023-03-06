#!/bin/bash
. $GALAXY_VIRTUAL_ENV/bin/activate
python3 $GALAXY_ROOT/scripts/tfsetup.py --galaxy_root $GALAXY_ROOT --force
