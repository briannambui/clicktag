#!/bin/bash

DIR="/Users/brianbui/Sites/clicktags/in"

for file in $DIR/*; do

	title=$(echo "cat //html/head/title" |  xmllint --html --shell --nodefdtd $file 2>/dev/null | sed '/^\/ >/d' | sed 's/<[^>]*.//g' | xargs)

	# Dimensions of image
	first=$(echo $title | grep -o '[0-9][0-9][0-9]')
	data=$(echo $first | sed 's/ /,/g')
	IFS=', ' read -r -a array <<< "$data"

	width=${array[0]}
	height=${array[1]}

	# adsize="<meta name="ad.size" content="width=${width},height=${height}">"

	sed -i -e "\@<title>@i\\
	<meta name=\"ad.size\" content=\"width=${width},height=${height}\">
	" $file

	sed -i -e "/fnStartAnimation();/a\\
	\}\\
	\function getParameterByName(name) {\\
	\    name = name.replace(/[\\\\[]/, \"\\\\\\\\[\").replace(/[\\\\]]/, \"\\\\\\\\]\");\\
	\    var regex = new RegExp(\"[\\\\\\\\?&]\" + name + \"=([^&#]*)\"), results = regex.exec(location.search);\\
	\     return results === null ? \"\" : decodeURIComponent(results[1].replace(/\\\\+/g, \" \"));\\
	\var clickTAG = getParameterByName(\"clickTAG\") + encodeURIComponent(\"\"); 
	" $file

	sed -i -e "/<body onload/a\\
	<a href=\"javascript:window.open(window.clickTAG);void(0);\">
	" $file

	sed -i -e "\@</body>@i\\
	</a>
	" $file

done

rm -rf $DIR/*.html-e