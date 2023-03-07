#!/usr/bin/bash
echo "First run takes a while. Go for a walk, read the manual, or do something else more useful than watching"
OURDIR="../galaxytf"
# assume run from the git galaxy_tf_overlay clone directory
REL="release_23.0"
GALZIP="https://github.com/galaxyproject/galaxy/archive/refs/heads/$REL.zip"
if [ -f "$REL.zip" ]; then
  echo "$REL.zip exists"
else
   echo "No $REL.zip. Getting"
   wget $GALZIP
fi
if [ -d "$OURDIR" ]; then
  echo "Deleting existing $OURDIR"
  rm -rf $OURDIR
fi
unzip $REL.zip
mv  galaxy-$REL $OURDIR
cd $OURDIR
cp -rvu ../galaxy_tf_overlay/* ./
HERE=`pwd`
GALAXY_VIRTUAL_ENV=$HERE/venv
echo $GALAXY_VIRTUAL_ENV
python3 -m venv $GALAXY_VIRTUAL_ENV
GALAXY_VIRTUAL_ENV=$GALAXY_VIRTUAL_ENV && sh scripts/common_startup.sh --no-create-venv
. venv/bin/activate
pip3 install bioblend ephemeris planemo
GALAXY_VIRTUAL_ENV=$GALAXY_VIRTUAL_ENV && python3 scripts/tfsetup.py --galaxy_root $HERE
echo "Your dev server is ready to run. \
Use GALAXY_VIRTUAL_ENV=$HERE/venv && sh run.sh --skip-client-build --daemon for example. \
Local web browser url is http://localhost:8080. Admin already exists.\
Admin login is toolfactory@galaxy.org with ChangeMe! as the temporary password. \
Please do change it. Do not expose this development server on the open internet please. \
It has none of the layers of isolation that a secure public server needs."
