LOCALTOOLDIR="/home/ross/rossgit/galaxytf/local_tools"
APIK="2068606201556084992"
GAL="http://localhost:8080"
# all unless a single id is passed in as $1
if [ -z "$1" ]; then
    for f in $LOCALTOOLDIR/*; do
        if [ -d "$f" ]; then
            TOOL=`basename "$f"`
            install_tool_deps -v -g $GAL -a $APIK -t  $LOCALTOOLDIR/$TOOL/$TOOL.xml
        fi
   done
else
     install_tool_deps -v -g $GAL -a $APIK -t  $LOCALTOOLDIR/$1/$1.xml
fi



