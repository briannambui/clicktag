#!/bin/bash

DIR="/Users/brianbui/PycharmProjects/clicktag/in"

for file in $DIR/*; do

	title=$(echo "cat //html/head/title" |  xmllint --html --shell --nodefdtd $file 2>/dev/null | sed '/^\/ >/d' | sed 's/<[^>]*.//g' | xargs)

	# Dimensions of image
	first=$(echo $title | egrep -o '[[:digit:]]+')

	data=$(echo $first | sed 's/ /,/g')
	IFS=', ' read -r -a array <<< "$data"

	width=${array[0]}
	height=${array[1]}
	extra=${array[2]}

	sed -i -e "\@<title>@i\\
	<meta name=\"ad.size\" content=\"width=${width},height=${height}\">
	" $file

	sed -i -e "/fnStartAnimation();/a\\
	\function getParameterByName(name) {\\
  \  name = name.replace(/[\\\\[]/, \"\\\\\\\\[\").replace(/[\\\\]]/, \"\\\\\\\\]\");\\
  \  var regex = new RegExp(\"[\\\\\\\\?&]\" + name + \"=([^&#]*)\"),\\
  \    results = regex.exec(location.search);\\
  \  return results === null ? \"\" :\\
  \    decodeURIComponent(results[1].replace(/\\\\+/g, \" \"));\\
  \}\\
  \var clickTag = getParameterByName(\"clickTag\");}
	" $file

	sed -i -e "/<body onload/a\\
	<a href=\"javascript:window.open(window.clickTag);void(0);\">
	" $file

	sed -i -e "\@</body>@i\\
	</a>
	" $file

	sed -i -e 'H;1h;$!d;g;s_\(.*\)}_\1_' $file

done

rm -rf $DIR/*.html-e