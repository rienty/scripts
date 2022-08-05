#!/bin/bash
exit_justify () {
	if [ -z "$1" ]
	then
		exit 0
	fi
}

#web="$(echo -e "qutebrowser\nfirefox" | dmenu -p "Which Browser?" -l 20 -i)"

#exit_justify "$web"
web="qutebrowser"

nu=$(echo -e "^3\n^4\n^5\n^6\n^7\n^8" | dmenu -p "Which desktop?" -l 20 -i -x 200 -y 800 -z 2100)

exit_justify "$nu"

engine="$(echo -e "Google\nArXiv\nWiki\nScihub\nZbmath\nOverflow\nGithub\nYoutube\nCNU\nURL" | dmenu -p "Which Engine?" -l 20 -i -x 200 -y 800 -z 2100)"

exit_justify "$engine"


case "$engine" in

	Google)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		text="$(echo -e $txt | sed -r 's/[[:space:]]+/+/g' )"
		bspc desktop -f ${nu}
		$web https://www.google.com/search?q=$text ;;

	DuckDuckgo)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		text="$(echo -e $txt | sed -r 's/[[:space:]]+/+/g' )"
		bspc desktop -f $nu
		$web https://duckduckgo.com/?q=$text&ia=web ;;

	ArXiv)
	do="$(echo -e "Search\nList" | dmenu -p "What do you want to do?" -i -l 3 -x 200 -y 1100 -z 2125)"
		case "$do" in
			Search)
				type="$(echo -e "all\ntitle\nauthor\nabstract\ncomments" | dmenu -p "Type|" -i -l 10 -x 200 -y 1000 -z 2125)"
				txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1000 -z 2125)"
				exit_justify "$txt"
				if [ $type == "author" ]
				then
					where="$(echo -e "Chinese\nOthers" | dmenu -p "Where|" -i -l 3 -x 200 -y 1000 -z 2125)"
					if [ $where == Chinese ]
					then
						text="$(echo -e $txt | sed -r 's/[[:space:]]+/,/g' )"
					else
						text="$(echo -e $txt | sed -r 's/[[:space:]]+/+/g' )"
					fi
				else
					text="$(echo -e $txt | sed -r 's/[[:space:]]+/+/g' )"
				fi
				result="https://arxiv.org/search/?query=$text&searchtype=$type&abstracts=show&order=-announced_date_first&size=50"
		bspc desktop -f $nu
				$web $result ;;
			List)
				type="$(echo -e "math.DG\nmath.MG" | dmenu -p "Field|" -i -l 4 -x 200 -y 1000 -z 2125)"
				result="https://arxiv.org/list/$type/recent"
		bspc desktop -f $nu
				$web $result ;;
		esac ;;

	Wiki)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		bspc desktop -f $nu
		$web https://en.wikipedia.org/wiki/"$txt" ;;

	Scihub)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		text="$(echo -e $txt | sed -r 's/[[:space:]]+/,/g' )"
		bspc desktop -f $nu
		$web https://sci-hub.se/"$text" ;;

	Zbmath)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		text="$(echo -e $txt | sed -r 's/[[:space:]]+/,/g' )"
		bspc desktop -f $nu
		$web https://zbmath.org/?q="$txt" ;;


	Github)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		text="$(echo -e $txt | sed -r 's/[[:space:]]+/+/g' )"
		bspc desktop -f $nu
		$web https://github.com/search/?q=$text ;;

	Youtube)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		text="$(echo -e $txt | sed -r 's/[[:space:]]+/+/g' )"
		bspc desktop -f $nu
		$web https://youtube.com/search?q=$text ;;

	Overflow)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		text="$(echo -e $txt | sed -r 's/[[:space:]]+/+/g' )"
		bspc desktop -f $nu
		$web https://mathoverflow.com/search?q=$text ;;

	Nyaa)
		txt="$(echo -e " " | dmenu -p "What you want to know?" -i -x 200 -y 1200 -z 2125)"
		exit_justify "$txt"
		text="$(echo -e $txt | sed -r 's/[[:space:]]+/+/g' )"
		bspc desktop -f $nu
		$web https://nyaa.si/?f=0&c=0_0&q="$text" ;;

	URL)
		txt="$(echo -e "" | dmenu -p "What do you want to go?" -i -x 200 -y 1200 -z 2125)"
		bspc desktop -f $nu
		$web https://$txt ;;
	CNU)
		bspc desktop -f $nu
		$web 192.168.1.91 ;;
esac

exit 0
