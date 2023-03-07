DEST="/home/ross/rossgit/galaxy_tf_overlay"
cp -vu config/*.xml $DEST/config
rm -fv $DEST/config/integrated_tool_panel.xml
cp -uv config/*.yml $DEST/config
cp -uvr config/local_tool_config/ $DEST/config
cp -ruv local_tools/tacrev $DEST/local_tools
cp -ruv local_tools/toolfactory $DEST/local_tools/
cp -vu scripts/tfsetup.py $DEST/scripts
cp -vu scripts/clonelocaltf.sh $DEST/scripts
cp -vu scripts/toolfactory_fast_test.sh $DEST/scripts/
cp -vu scripts/tfupdatebits.sh $DEST/scripts

