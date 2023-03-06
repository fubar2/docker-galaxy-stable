# ansible command calls this to do most of the work
# no need to make this into playbooks
HERE=`pwd`
echo "$HERE"
GALAXY_VIRTUAL_ENV=$HERE/venv
echo $GALAXY_VIRTUAL_ENV
sudo -u postgres psql -c "create role $USER;"
sudo -u postgres psql -c "drop database galaxydev;"
sudo -u postgres psql -c "create database galaxydev;"
sudo -u postgres psql -c "grant all privileges on database galaxydev to $USER;"
python3 -m venv $GALAXY_VIRTUAL_ENV
sh scripts/common_startup.sh --no-create-venv
. venv/bin/activate
pip3 install bioblend ephemeris planemo
python3 scripts/tfsetup.py --galaxy_root $HERE
echo "Your dev server is ready to run. \
Use GALAXY_VIRTUAL_ENV=$HERE/venv && sh run.sh --skip-client-build --daemon for example. \
Local web browser url is http://localhost:8080. Admin already exists.\
Admin login is toolfactory@galaxy.org with ChangeMe! as the temporary password. \
Please do change it. Do not expose this development server on the open internet please.
It has none of the layers of isolation that a secure public server needs."
