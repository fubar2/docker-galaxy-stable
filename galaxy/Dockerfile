# ToolFactory
# docker-galaxy-unstable
# march 2 2023
# ross lazarus me fecit
# VERSION   0.01

FROM ubuntu:22.04

MAINTAINER ross.lazarus@gmail.com
# derived from Docker galaxy stable from Björn A. Grüning, bjoern.gruening@gmail.com
# runs a very poorly secured dev server. please do not expose publicly.
#
# NOTES
# nginx is not installed as this should not be run publicly
# all the proxy/ie stuff is removed - not useful for this dev server

ARG GALAXY_RELEASE=release_23.0
ARG GALAXY_REPO

## MOVED config out of image /etc/galaxy

ENV GALAXY_RELEASE=${GALAXY_RELEASE:-release_23.0} \
    GALAXY_REPO=${GALAXY_REPO:-https://github.com/galaxyproject/galaxy} \
    GALAXY_ROOT=/galaxy-central \
    GALAXY_CONFIG_DIR=/etc/galaxy \
    EXPORT_DIR=/export \
    DEBIAN_FRONTEND=noninteractive \
    PG_VERSION=14

ENV NONUSE="reports,nodejs,proftp" \
    GALAXY_CONFIG_FILE=$GALAXY_CONFIG_DIR/galaxy.yml \
    GALAXY_CONFIG_JOB_CONFIG_FILE=$GALAXY_CONFIG_DIR/job_conf.xml \
    GALAXY_CONFIG_JOB_METRICS_CONFIG_FILE=$GALAXY_CONFIG_DIR/job_metrics_conf.xml \
    GALAXY_CONFIG_TOOL_DATA_TABLE_CONFIG_PATH=/etc/galaxy/tool_data_table_conf.xml \
    GALAXY_CONFIG_WATCH_TOOL_DATA_DIR=True \
    GALAXY_CONFIG_WATCH_TOOLS=True \
    GALAXY_CONFIG_TOOL_DEPENDENCY_DIR=$EXPORT_DIR/tool_deps \
    GALAXY_CONFIG_TOOL_PATH=$EXPORT_DIR/galaxy-central/tools \
    GALAXY_VIRTUAL_ENV=/galaxy_venv \
    GALAXY_USER=galaxy \
    GALAXY_HOME=/home/galaxy \
    GALAXY_LOGS_DIR=/home/galaxy/logs \
    GALAXY_DESTINATIONS_DEFAULT=slurm_cluster \
    GALAXY_RUNNERS_ENABLE_SLURM=True \
    GALAXY_RUNNERS_ENABLE_CONDOR=False \
    GALAXY_CONFIG_DATABASE_CONNECTION=postgresql://galaxy:galaxy@localhost:5432/galaxy?client_encoding=utf8 \
    #GALAXY_CONFIG_MASTER_API_KEY=HSNiugRFvgT574F43jZ7N9F3 \
    GALAXY_CONFIG_BRAND="ToolFactory Docker" \
    GALAXY_CONFIG_TOOL_CONFIG_FILE=/etc/galaxy/tool_conf.xml,/galaxy-central/local_tools/local_tool_conf.xml \
    GALAXY_CONFIG_ADMIN_USERS=admin@galaxy.org,toolfactory@galaxy.org \
    GALAXY_CONFIG_STATIC_ENABLED=False \
    # Define the default postgresql database path
    PG_DATA_DIR_DEFAULT=/var/lib/postgresql/$PG_VERSION/main/ \
    PG_CONF_DIR_DEFAULT=/etc/postgresql/$PG_VERSION/main/ \
    PG_DATA_DIR_HOST=$EXPORT_DIR/postgresql/$PG_VERSION/main/ \
    # The following 2 ENV vars can be used to set the number of uwsgi processes and threads
    UWSGI_PROCESSES=2 \
    UWSGI_THREADS=4 \
    # Set HTTPS to use a self-signed certificate (or your own certificate in $EXPORT_DIR/{server.key,server.crt})
    USE_HTTPS=False \
    # Set USE_HTTPS_LENSENCRYPT and GALAXY_CONFIG_GALAXY_INFRASTRUCTURE_URL to a domain that is reachable to get a letsencrypt certificate
    USE_HTTPS_LETSENCRYPT=False \
    GALAXY_CONFIG_GALAXY_INFRASTRUCTURE_URL=http://localhost \
    # Set the number of Galaxy handlers
    GALAXY_HANDLER_NUMPROCS=2 \
    # Setting a standard encoding. This can get important for things like the unix sort tool.
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    NODE_OPTIONS=--max-old-space-size=4096 \
    GALAXY_CONDA_PREFIX=/tool_deps/_conda \
    GRAVITY_GALAXY_ROOT=$GALAXY_ROOT \
    GRAVITY_GALAXY_USER=$GALAXY_USER \
    GALAXY_CONFIG_JOB_WORKING_DIRECTORY=$EXPORT_DIR/galaxy-central/database/job_working_directory \
    GALAXY_CONFIG_FILE_PATH=$EXPORT_DIR/galaxy-central/database/files \
    GALAXY_CONFIG_NEW_FILE_PATH=$EXPORT_DIR/galaxy-central/database/files \
    GALAXY_CONFIG_TEMPLATE_CACHE_PATH=$EXPORT_DIR/galaxy-central/database/compiled_templates \
    GALAXY_CONFIG_CITATION_CACHE_DATA_DIR=$EXPORT_DIR/galaxy-central/database/citations/data \
    GALAXY_CONFIG_CLUSTER_FILES_DIRECTORY=$EXPORT_DIR/galaxy-central/database/pbs \
    GALAXY_CONFIG_FTP_UPLOAD_DIR=$EXPORT_DIR/ftp \
    GALAXY_CONFIG_FTP_UPLOAD_SITE=galaxy.docker.org \
    GALAXY_CONFIG_USE_PBKDF2=False \
    GALAXY_CONFIG_NGINX_X_ACCEL_REDIRECT_BASE=/_x_accel_redirect \
    GALAXY_CONFIG_NGINX_X_ARCHIVE_FILES_BASE=/_x_accel_redirect \
    GALAXY_CONFIG_DYNAMIC_PROXY_MANAGE=False \
    GALAXY_CONFIG_VISUALIZATION_PLUGINS_DIRECTORY=config/plugins/visualizations \
    GALAXY_CONFIG_TRUST_IPYTHON_NOTEBOOK_CONVERSION=True \
    GALAXY_CONFIG_TOOLFORM_UPGRADE=True \
    GALAXY_CONFIG_SANITIZE_ALL_HTML=False \
    GALAXY_CONFIG_TOOLFORM_UPGRADE=True \
    GALAXY_CONFIG_WELCOME_URL=$GALAXY_CONFIG_DIR/web/welcome.html \
    GALAXY_CONFIG_OVERRIDE_DEBUG=False \
    GALAXY_CONFIG_ENABLE_QUOTAS=True \
    # We need to set $HOME for some Tool Shed tools (e.g Perl libs with $HOME/.cpan)
    HOME=$GALAXY_HOME \
    GALAXY_CONDA_PREFIX=$GALAXY_CONFIG_TOOL_DEPENDENCY_DIR/_conda

RUN apt-get -qq update && apt-get install --no-install-recommends -y locales apt-utils software-properties-common gpg-agent curl sudo \
   && locale-gen en_US.UTF-8 && dpkg-reconfigure locales \
   && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
   && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
   && sudo add-apt-repository ppa:natefoo/slurm-drmaa \
   && apt-get update -qq \
   # && apt-get install nginx-extras nginx-common --no-install-recommends -y \
   && apt-get install -y postgresql-14 \
   && apt-get install docker-ce-cli --no-install-recommends -y \
   && apt-get install cron -y \
   && apt-get install slurm-client slurmd slurmctld slurm-drmaa1 --no-install-recommends -y \
   && ln -s /usr/lib/slurm-drmaa/lib/libdrmaa.so.1 /usr/lib/slurm-drmaa/lib/libdrmaa.so \
   && apt-get install proftpd proftpd-mod-pgsql --no-install-recommends -y \
   && apt-get install munge libmunge-dev --no-install-recommends -y \
   && apt-get install nano --no-install-recommends -y \
   && apt-get install git --no-install-recommends -y \
   && apt-get install gridengine-common gridengine-drmaa1.0 --no-install-recommends -y \
   && apt-get install rabbitmq-server --no-install-recommends -y \
   && apt-get install --no-install-recommends -y libswitch-perl supervisor \
   && apt-get purge -y software-properties-common apt-transport-https   \
   && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && rm -rf ~/.cache/ \
   && mkdir -p /etc/supervisor/conf.d/ /var/log/supervisor/ \
   && groupadd $GALAXY_USER \
  && useradd  -r -g $GALAXY_USER -d $GALAXY_HOME -c "Galaxy user" --shell /bin/bash $GALAXY_USER \
  && mkdir -p $EXPORT_DIR $GALAXY_HOME $GALAXY_LOGS_DIR && chown -R $GALAXY_USER:$GALAXY_USER $GALAXY_HOME $EXPORT_DIR $GALAXY_LOGS_DIR \
  # cleanup dance
  && find /usr/lib/ -name '*.pyc' -delete \
  && rm -rf /tmp/* /root/.cache/ /var/cache/* $GALAXY_ROOT/client/node_modules/ $GALAXY_VIRTUAL_ENV/src/ /home/galaxy/.cache/ /home/galaxy/.npm/

RUN mkdir -p /var/cache/apt/archives/partial \
    && apt update && apt install -y python3-venv unzip wget  \
    && wget https://github.com/galaxyproject/galaxy/archive/refs/heads/$GALAXY_RELEASE.zip \
    && unzip $GALAXY_RELEASE.zip \
    && mv  galaxy-$GALAXY_RELEASE $GALAXY_ROOT \
    && python3 -m venv $GALAXY_VIRTUAL_ENV \
    && PATH=$GALAXY_CONDA_PREFIX/bin/:$PATH && python3 -m venv $GALAXY_VIRTUAL_ENV \
    && chown -R $GALAXY_USER:$GALAXY_USER $GALAXY_VIRTUAL_ENV \
    && chown -R $GALAXY_USER:$GALAXY_USER $GALAXY_ROOT \
    # Setup Galaxy configuration files.
    && mkdir -p $GALAXY_CONFIG_DIR $GALAXY_CONFIG_DIR/web \
    && chown -R $GALAXY_USER:$GALAXY_USER $GALAXY_CONFIG_DIR \
    && rm -rf /tmp/* /root/.cache/ /var/cache/* $GALAXY_ROOT/client/node_modules/ $GALAXY_VIRTUAL_ENV/src/ /home/galaxy/.cache/ /home/galaxy/.npm \
    && su $GALAXY_USER -c "cp $GALAXY_ROOT/config/galaxy.yml.sample $GALAXY_CONFIG_FILE" \
    && mkdir -p /etc/galaxy \
    && chown -R galaxy:galaxy /etc/galaxy \
    # cleanup dance
    && find $GALAXY_ROOT -name '*.pyc' -delete | true \
    && find /usr/lib/ -name '*.pyc' -delete | true \
    && find $GALAXY_VIRTUAL_ENV -name '*.pyc' -delete | true \
    && rm -rf /tmp/* /root/.cache/ /var/cache/* $GALAXY_ROOT/client/node_modules/ $GALAXY_VIRTUAL_ENV/src/ /home/galaxy/.cache/ /home/galaxy/.npm


ADD ./reports_wsgi.ini.sample $GALAXY_CONFIG_DIR/reports_wsgi.ini
ADD sample_tool_list.yaml $GALAXY_HOME/ephemeris/sample_tool_list.yaml
ADD galaxy_tf_overlay/local /galaxy-central/local
ADD galaxy_tf_overlay/local_tools /galaxy-central/local_tools
ADD galaxy_tf_overlay/scripts/* /galaxy-central/scripts/
ADD galaxy_tf_overlay/config_docker/post-start-actions.sh /galaxy-central
ADD galaxy_tf_overlay/config_docker/job_conf.xml /etc/galaxy/job_conf.xml
ADD galaxy_tf_overlay/config/tool_conf.xml /etc/galaxy/tool_conf.xml
ADD galaxy_tf_overlay/config_docker/local_tool_conf.xml /galaxy-central/local_tools/local_tool_conf.xml
ADD ./setup_postgresql.py /usr/local/bin/setup_postgresql.py
ADD check_database.py /usr/local/bin/check_database.py
ADD roles/ /ansible/roles
ADD tfpg.yml /ansible/tfpg.yml
ADD tfpg/ /ansible/tfpg/
# use https://github.com/krallin/tini/ as tiny but valid init and PID 1
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /sbin/tini


RUN chmod +x /sbin/tini \
    && mkdir -p /shed_tools $EXPORT_DIR/ftp/ \
    && mkdir -p $GALAXY_CONFIG_TOOL_DEPENDENCY_DIR \
    && chown $GALAXY_USER:$GALAXY_USER /shed_tools $EXPORT_DIR/ftp \
    && ln -s /tool_deps/ $EXPORT_DIR/tool_deps \
    # Configure Galaxy to use the Tool Shed
    && chown $GALAXY_USER:$GALAXY_USER $EXPORT_DIR/tool_deps \
    && apt update -qq && apt install -y ansible g++ make python3-pkg-resources unzip tar gpg dirmngr\
    && . $GALAXY_VIRTUAL_ENV/bin/activate \
    && pip install WeasyPrint wheel \
    && pip install -U bioblend ephemeris \
    # see if apt works 'cos this don't :( && /usr/bin/ansible-playbook /ansible/postgresql_provision.yml \
    && . $GALAXY_VIRTUAL_ENV/bin/activate \
    && service postgresql stop \
    && rm -rf $PG_DATA_DIR_DEFAULT \
    && python /usr/local/bin/setup_postgresql.py --dbuser galaxy --dbpassword galaxy --db-name galaxy --dbpath $PG_DATA_DIR_DEFAULT --dbversion $PG_VERSION \
    && service postgresql start \
    && /usr/bin/ansible-playbook -b -i /ansible/tfpg/hosts /ansible/tfpg.yml  \
    && cd $GALAXY_ROOT \
    && find . -name '.cache' -type d -prune -exec rm -rf '{}' + \
    && cd / \
    && apt-get autoremove -y g++ make unzip gpg && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && rm -rf ~/.cache/ \
    # cleanup dance
    && find $GALAXY_ROOT/ -name '*.pyc' -delete | true \
    && find /usr/lib/ -name '*.pyc' -delete | true \
    && find /var/log/ -name '*.log' -delete | true \
    && find $GALAXY_VIRTUAL_ENV -name '*.pyc' -delete | true \
    && rm -rf /tmp/* /root/.cache/ /var/cache/* $GALAXY_ROOT/client/node_modules/ $GALAXY_VIRTUAL_ENV/src/ /home/galaxy/.cache/ /home/galaxy/.npm


ADD startuptf.sh /usr/bin/startup
# Script that enables easier downstream installation of tools (e.g. for different Galaxy Docker flavours)
ADD install_tools_wrapper.sh /usr/bin/install-tools
# script to install BioJS visualizations
ADD install_biojs_vis.sh /usr/bin/install-biojs
# https://stackoverflow.com/questions/62250160/uwsgi-runtimeerror-cannot-release-un-acquired-lock
ADD run.sh $GALAXY_ROOT/run.sh
RUN chmod +x /usr/bin/install-tools /usr/bin/install-biojs  /usr/bin/startup \
    && cd /usr/bin/ && curl https://git.embl.de/grp-gbcs/galaxy-dir-sync/raw/master/src/galaxy-dir-sync.py > galaxy-dir-sync.py \
    && chmod +x galaxy-dir-sync.py \
    && chmod a+x /usr/local/bin/check_database.py \
    && chmod +x $GALAXY_ROOT/run.sh \
    && chown -R galaxy:galaxy $GALAXY_ROOT/local_tools $GALAXY_ROOT/local $GALAXY_VIRTUAL_ENV \
    && cp $GALAXY_ROOT/config/tool_data_table_conf.xml.sample /etc/galaxy/tool_data_table_conf.xml

# This needs to happen here and not above, otherwise the Galaxy start
# (without running the startup.sh script) will crash because integrated_tool_panel.xml could not be found.
ENV GALAXY_CONFIG_INTEGRATED_TOOL_PANEL_CONFIG $EXPORT_DIR/galaxy-central/integrated_tool_panel.xml

USER $GALAXY_USER

RUN git config --global --add safe.directory $GALAXY_ROOT   \
 && cd $GALAXY_ROOT \
 && sh ./scripts/common_startup.sh
# break for sanity while testing
RUN sh $GALAXY_ROOT/scripts/firstrun.sh

USER root

# cleanup jig
RUN find $GALAXY_ROOT/ -name '*.pyc' -delete | true \
    && find $GALAXY_ROOT -name 'node_modules' -type d -prune -exec rm -rf '{}' + \
    && find /usr/lib/ -name '*.pyc' -delete | true \
    && find /var/log/ -name '*.log' -delete | true \
    && find $GALAXY_VIRTUAL_ENV -name '*.pyc' -delete | true \
    && rm -rf /tmp/* /root/.cache/ /var/cache/* $GALAXY_ROOT/client/node_modules/ $GALAXY_VIRTUAL_ENV/src/ /home/galaxy/.cache/ /home/galaxy/.npm
# Expose port 80, 443 (webserver), 21 (FTP server), 8800 (Proxy), 9002 (supvisord web app)
EXPOSE :21
EXPOSE :8080
EXPOSE :443
EXPOSE :8800
EXPOSE :9002

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]


ENV SUPERVISOR_POSTGRES_AUTOSTART=True \
    SUPERVISOR_MANAGE_POSTGRES=True \
    SUPERVISOR_MANAGE_CRON=True \
    SUPERVISOR_MANAGE_PROFTP=True \
    SUPERVISOR_MANAGE_REPORTS=True \
    SUPERVISOR_MANAGE_IE_PROXY=False \
    SUPERVISOR_MANAGE_SLURM=True \
    HOST_DOCKER_LEGACY= \
    GALAXY_EXTRAS_CONFIG_POSTGRES=True \
    STARTUP_EXPORT_USER_FILES=True

ENTRYPOINT ["/sbin/tini", "--"]

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]
