#!/bin/sh
#
# Copyright (C) 2012 Alexander Heinlein
# This program is free software blah GNU GPL version 3+ blah.
#
# converts POIs from a OpenLayers style text file to a Garmin waypoint XML file
#
# note: files with CRLF line terminators may cause problems, use fromdos or dos2unix to convert them first
#
 
set -e
 
OUTFILE="openLayersPOIs.gpx"
IGNORE="^$|^#" # ignore these lines (egrep expression), here: empty line, comment
REPLACE="s/&/and/g; s/_/ /g" # replace these strings (sed expression), e.g. XML doesn't like '&' so we replace it with 'and'
 
if [ "$#" -lt "1" ]; then
    echo "usage: $0 file1 [file2...]"
    exit 1
fi
 
echo '<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' > $OUTFILE
echo '<gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:wptx1="http://www.garmin.com/xmlschemas/WaypointExtension/v1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" creator="openLayersPOIsToGarminWaypoints.sh" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www8.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/WaypointExtension/v1 http://www8.garmin.com/xmlschemas/WaypointExtensionv1.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd">' >> $OUTFILE
 
for FILE in $*; do
    echo "processing $FILE ..."
    while read LINE; do
        echo "$LINE" | egrep -q "$IGNORE" && continue
 
        LAT=$(echo -n "$LINE" | awk -F "\t" '{print $1}')
        LON=$(echo -n "$LINE" | awk -F "\t" '{print $2}')
        NAME=$(echo -n "$LINE" | awk -F "\t" '{print $3}' | sed "$REPLACE")
        DESC=$(echo -n "$LINE" | awk -F "\t" '{print $4}' | sed "$REPLACE")
        CAT=$(basename "$FILE" .txt | sed "$REPLACE")
 
        echo " writing waypoint $NAME"
 
        echo " <wpt lat=\"$LAT\" lon=\"$LON\">" >> $OUTFILE
        echo "  <name>$NAME</name>" >> $OUTFILE
        echo "  <desc>$DESC</desc>" >> $OUTFILE
        echo "  <cmt>$DESC</cmt>" >> $OUTFILE
        echo "  <extensions>" >> $OUTFILE
        echo "   <gpxx:WaypointExtension>" >> $OUTFILE
        echo "    <gpxx:Categories>" >> $OUTFILE
        echo "     <gpxx:Category>$CAT</gpxx:Category>" >> $OUTFILE
        echo "    </gpxx:Categories>" >> $OUTFILE
        echo "   </gpxx:WaypointExtension>" >> $OUTFILE
        echo "  </extensions>" >> $OUTFILE
        echo " </wpt>" >> $OUTFILE
    done < "$FILE"
done
 
echo "</gpx>" >> $OUTFILE
 
echo "done."
