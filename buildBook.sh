#!/bin/bash

usage() {
  echo "Usage: $0 [-l languageCode]" 1>&2
}

exit_abnormal() {
  usage
  exit 1
}

langName="en"

while getopts "l:" options; do
  case "${options}" in
    l)
      langName=${OPTARG}
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
  esac
done

shift $(($OPTIND - 1))
remainingArgs=$@

outputDir=generated

if [[ ! -d $outputDir ]];
then
    mkdir $outputDir
fi

./tools/commatrademark.sh $outputDir/boo.$langName.idx > trademarks.md

rm -f $outputDir/foo.$langName.* $outputDir/boo.$langName.*

filesToProcess=$(./tools/get_markdown_for_lang.sh -l $langName $(cat frontPages.txt mainPages.txt))
latexFilesToProcess=$(./tools/get_markdown_for_lang.sh -l $langName $(cat frontPages_latex.txt mainPages.txt backPages_latex.txt))


# We allow first person in the preface and second person in the Introduction.
# Elsewhere it is third person only.

ignoreFiles='Introduction|Preface|Acknowledgements'

echo Usages of "you" in the narrative
for file in $filesToProcess
do
	if [[ $file =~ $ignoreFiles ]]
	then
		echo -n .
	else
	        grep you $file | grep --color -v hammer | grep -i --color -v layout || echo -n .
	fi

done

scriptPath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

./tools/clean_gutter.sh -r $scriptPath $filesToProcess

echo

echo Processing foo.$langName.html
pandoc $filesToProcess pandocMetaData.yaml -s --citeproc --bibliography=bibliography.bib -f markdown+smart --standalone --toc -c style/gitHubStyle.css -o $outputDir/foo.$langName.html
echo Processing boo.$langName.latex
echo Performing pandoc $latexFilesToProcess pandocMetaData.yaml -s -F pandoc-crossref --natbib -f markdown+smart --standalone --toc --template=style/styleToCreateIndex.latex -V documentclass=book -o $outputDir/boo.$langName.latex
pandoc $latexFilesToProcess pandocMetaData.yaml -s -F pandoc-crossref --natbib -f markdown+smart --standalone --toc --template=style/styleToCreateIndex.latex -V documentclass=book -o $outputDir/boo.$langName.latex

echo Cleaning up csl indent remarks
sed -e '/if(csl-hanging-indent)/{N;d;}' -i.bak $outputDir/boo.$langName.latex


for pass in 0 1 2
do
    echo Indexing pass $pass
    ( cd $outputDir; bibtex boo.$langName; pdflatex boo.$langName.latex > boo.$langName.pass.$pass.log </dev/null )
done

echo "Check for errors"
egrep -n "LaTeX Error:|Error: Unicode character|Fatal error occurred" $outputDir/boo.$langName.pass.*.log

echo Processing foo.$langName.epub
pandoc $filesToProcess pandocMetaData.yaml -s -F pandoc-crossref --natbib -f markdown+smart --standalone --toc --css=style/ebook.css -o $outputDir/foo.$langName.epub

echo Processing foo.$langName.docx
pandoc $filesToProcess pandocMetaData.yaml -s -F pandoc-crossref --natbib -f markdown+smart --standalone --reference-doc=style/referenceWordDocumentTemplate.docx -o $outputDir/foo.$langName.docx

echo Constructing github pages

mkdir -p docs/$langName
cp $outputDir/foo.$langName.html docs/$langName/index.html
git add docs/$langName/index.html
rm -rf docs/$langName/screenshots docs/$langName/style
cp -pr screenshots docs/$langName/screenshots
cp -pr style docs/$langName/style

echo Checking in github pages changes
git add docs/$langName/screenshots docs/$langName/style
git commit -m"update published $langName book on github pages"
git push
