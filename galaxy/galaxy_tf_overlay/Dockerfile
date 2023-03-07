# build ToolFactory image from the latest and greatest
FROM bgruening/galaxy-stable
MAINTAINER Ross Lazarus ross.lazarus@gmail.com
ADD galaxy_tf_overlay/local /galaxy-central/local
ADD galaxy_tf_overlay/local_tools /galaxy-central/local_tools
ADD galaxy_tf_overlay/scripts/* /galaxy-central/scripts/
ADD galaxy_tf_overlay/config_docker/post-start-actions.sh /galaxy-central
ADD galaxy_tf_overlay/config_docker/job_conf.xml /etc/galaxy/job_conf.xml
ADD galaxy_tf_overlay/config/tool_conf.xml /etc/galaxy/tool_conf.xml
ENV GALAXY_CONFIG_BRAND "ToolFactory Docker"
ENV GALAXY_CONFIG_TOOL_CONFIG_FILE "/etc/galaxy/tool_conf.xml,/galaxy-central/local_tools/local_tool_conf.xml"
ENV GALAXY_CONFIG_ADMIN_USERS "admin@galaxy.org,toolfactory@galaxy.org"
RUN chown -R galaxy:galaxy /galaxy-central/local /galaxy-central/local_tools \
&& . /galaxy_venv/bin/activate && pip3 install -U bioblend

#ENTRYPOINT ["/sbin/tini", "--"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
#EXPOSE :21
#EXPOSE :8800
#VOLUME ["/export/", "/data/", "/var/lib/docker"]
# Autostart script that is invoked during container start
#CMD ["/usr/bin/startup"]
