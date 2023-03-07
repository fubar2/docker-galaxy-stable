GALAXY_URL=http://localhost:8080
GALAXY_VENV=/home/ross/rossgit/galaxytf/venv
APIK=1450870775459037184
UAPIK=803593569864928256
# for test@bx.psu.edu user
# for sed to edit at installation
# must pass toolname outdir as cl params in that order...
. $GALAXY_VENV/bin/activate
echo "toolfactory_fast_test.sh executing galaxy-tool-test -u $GALAXY_URL -a $APIK  -k $UAPIK -t  $1 -o  $2 --publish-history  --no-history-cleanup --test-data $3"
#galaxy-tool-test -u $GALAXY_URL -a $APIK -k $UAPIK -t  $1 -o  $2 --publish-history  --no-history-cleanup --test-data $3
galaxy-tool-test -u $GALAXY_URL -a $APIK  -k $UAPIK -t  $1 -o  $2 --publish-history  --no-history-cleanup --test-data $3
