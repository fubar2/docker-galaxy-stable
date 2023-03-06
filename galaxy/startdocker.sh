# please adjust as needed and save as start.sh
## -p 9009:9009 \
dockergid=`getent group docker | cut -d: -f3`
docker run -d -p 8080:80 -p 8021:21 -p 8800:8800 -p 9009:9009 \
-e GALAXY_CONFIG_ENABLE_BETA_MULLED_CONTAINERS=True
    -v /home/ross/rossgit/docker-galaxy-stable/galaxy/export:/export \

    bgruening/galaxy-stable:latest

