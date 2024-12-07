#!/usr/bin/env bash

# Set number of Galaxy handlers via GALAXY_HANDLER_NUMPROCS or default to 2
ansible localhost -m ini_file -a "dest=/etc/supervisor/conf.d/galaxy.conf section=program:handler option=numprocs value=${GALAXY_HANDLER_NUMPROCS:-2}" &> /dev/null

# If the Galaxy config file is not in the expected place, copy from the sample
# and hope for the best (that the admin has done all the setup through env vars.)
if [ ! -f $GALAXY_CONFIG_FILE ]
  then
  # this should succesfully copy either .yml or .ini sample file to the expected location
  cp /export/config/galaxy${GALAXY_CONFIG_FILE: -4}.sample $GALAXY_CONFIG_FILE
fi


cd $GALAXY_ROOT
. $GALAXY_VIRTUAL_ENV/bin/activate

if [[ ! -z $STARTUP_EXPORT_USER_FILES ]]; then
    # If /export/ is mounted, export_user_files file moving all data to /export/
    # symlinks will point from the original location to the new path under /export/
    # If /export/ is not given, nothing will happen in that step
    echo "Checking /export..."
    export GALAXY_UID=`id -u $GALAXY_USER`
    export GALAXY_GID=`id -g $GALAXY_USER`
    python3 /usr/local/bin/export_user_files.py $PG_DATA_DIR_DEFAULT
    chown -R galaxy:galaxy /export
fi

# Enable Test Tool Shed
if [[ ! -z $ENABLE_TTS_INSTALL ]]
    then
        echo "Enable installation from the Test Tool Shed."
        export GALAXY_CONFIG_TOOL_SHEDS_CONFIG_FILE=$GALAXY_HOME/tool_sheds_conf.xml
fi

# If auto installing conda envs, make sure bcftools is installed for __set_metadata__ tool
if [[ ! -z $GALAXY_CONFIG_CONDA_AUTO_INSTALL ]]
    then
        if [ ! -d "/tool_deps/_conda/envs/__bcftools@1.5" ]; then
            su $GALAXY_USER -c "/tool_deps/_conda/bin/conda create -y --override-channels --channel iuc --channel conda-forge --channel bioconda --channel defaults --name __bcftools@1.5 bcftools=1.5"
            su $GALAXY_USER -c "/tool_deps/_conda/bin/conda clean --tarballs --yes"
        fi
fi


# Waits until postgres is ready
function wait_for_postgres {
    echo "Checking if database is up and running"
    until /usr/local/bin/check_database.py 2>&1 >/dev/null; do sleep 1; echo "Waiting for database"; done
    echo "Database connected"
}

# $NONUSE can be set to include cron, proftp, reports or nodejs
# if included we will _not_ start these services.
function start_supervisor {
    supervisord -c /etc/supervisor/supervisord.conf
    sleep 5

    if [[ ! -z $SUPERVISOR_MANAGE_POSTGRES && ! -z $SUPERVISOR_POSTGRES_AUTOSTART ]]; then
        if [[ $NONUSE != *"postgres"* ]]
        then
            echo "Starting postgres"
            supervisorctl start postgresql
        fi
    fi

    wait_for_postgres

    # Make sure the database is automatically updated
    if [[ ! -z $GALAXY_AUTO_UPDATE_DB ]]
    then
        echo "Updating Galaxy database"
        sh manage_db.sh -c /etc/galaxy/galaxy.yml upgrade
    fi

    if [[ ! -z $SUPERVISOR_MANAGE_CRON ]]; then
        if [[ $NONUSE != *"cron"* ]]
        then
            echo "Starting cron"
            supervisorctl start cron
        fi
    fi
}

if [[ ! -z $SUPERVISOR_POSTGRES_AUTOSTART ]]; then
    if [[ $NONUSE != *"postgres"* ]]
    then
        # Change the data_directory of postgresql in the main config file
        ansible localhost -m lineinfile -a "line='data_directory = \'$PG_DATA_DIR_HOST\'' dest=$PG_CONF_DIR_DEFAULT/postgresql.conf backup=yes state=present regexp='data_directory'" &> /dev/null
    fi
fi

# If there is a need to execute actions that would require a live galaxy instance, such as adding workflows, setting quotas, adding more users, etc.
# then place a file with that logic named post-start-actions.sh on the /export/ directory, it should have access to all environment variables
# visible here.
# The file needs to be executable (chmod a+x post-start-actions.sh)
if [ -x /export/post-start-actions.sh ]
    then
   # uses ephemeris, present in docker-galaxy-stable, to wait for the local instance
   /tool_deps/_conda/bin/galaxy-wait -g http://127.0.0.1 -v --timeout 120 > $GALAXY_LOGS_DIR/post-start-actions.log &&
   /export/post-start-actions.sh >> $GALAXY_LOGS_DIR/post-start-actions.log # &
fi


# Reinstall tools if the user want to
if [[ ! -z $GALAXY_AUTO_UPDATE_TOOLS ]]
    then
        /tool_deps/_conda/bin/galaxy-wait -g http://127.0.0.1 -v --timeout 120 > /home/galaxy/logs/post-start-actions.log &&
        OLDIFS=$IFS
        IFS=','
        for TOOL_YML in `echo "$GALAXY_AUTO_UPDATE_TOOLS"`
        do
            echo "Installing tools from $TOOL_YML"
            /tool_deps/_conda/bin/shed-tools install -g "http://127.0.0.1" -a "$GALAXY_DEFAULT_ADMIN_KEY" -t "$TOOL_YML"
            /tool_deps/_conda/bin/conda clean --tarballs --yes
        done
        IFS=$OLDIFS
fi

# Enable verbose output
if [ `echo ${GALAXY_LOGGING:-'no'} | tr [:upper:] [:lower:]` = "full" ]
    then
        tail -f /var/log/supervisor/* /var/log/nginx/* $GALAXY_LOGS_DIR/*.log
    else
        tail -f $GALAXY_LOGS_DIR/*.log
fi
