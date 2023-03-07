#!/usr/bin/bash
echo "First run takes a while. Go for a walk or do something else more useful than watching"
git clone --depth 1 https://github.com/fubar2/galaxy.git galaxytf
cd galaxytf
HERE=`pwd`
GALAXY_VIRTUAL_ENV=$HERE/venv
export GALAXY_VIRTUAL_ENV=$GALAXY_VIRTUAL_ENV
echo $GALAXY_VIRTUAL_ENV
python -m venv $GALAXY_VIRTUAL_ENV
sh scripts/common_startup.sh --no-create-venv
. venv/bin/activate
python3 scripts/create_galaxy_user.py --galaxy_root $HERE  db_url "sqlite:///<data_dir>/universe.sqlite?isolation_level=IMMEDIATE"
planemo test --biocontainers --galaxy_root=$HERE $HERE/local_tools/tacrev/tacrev.xml
echo "Your dev server is ready to run. \
Use sh run.sh --daemon for example. \
Local web browser url is http://localhost:8080. Admin already exists.\
Admin email is toolfactory@galaxy.org with ChangeMe! as the temporary password. \
Please do change it. Do not expose this development server on the open internet please"
