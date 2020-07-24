#!/usr/bin/env bash

# Determine the MIME media type of the file to be printed.
MIMETYPE=$(file --mime-type -b "$TEADATAFILE")

# Directory for the output file.
DIR="/tmp/PDF"
CF1=cupsfilter
CF2="cupsfilter -m application/vnd.cups-pdf -o"
TU="$TEAUSERNAME"
TD="$TEADATAFILE"

CONFIG_DIR=/home/${TU}/.config/dpt-virtual-printer

# Check if configuration file exists
if [ ! -e "$CONFIG_DIR" ] ; then
  mkdir ${CONFIG_DIR}
  chown "$TU":"$TU" "$CONFIG_DIR"
  CONTENT = "dptaddr=0.0.0.0\ndeviceid=path/to/deviceid.dat\ndevicekey=path/to/privatekey.dat" \ 
    > ${CONFIG_DIR}/config
  chown "$TU":"$TU" "$CONFIG_DIR/config"
else
  # ${DPTADDR} is sourced here
  source ${CONFIG_DIR}/config
fi

# Default configurations
dptrp1=${dptrp1:-/usr/local/bin/dptrp1}

# Get any page-ranges. Useful for jobs submitted with lp but not for
# jobs from most GTK/QT apps. The latter pre-process jobs to sort out
# the pages to be printed and do not send "-o pages-ranges" to pdftopdf.
TO=$(echo "$TEAOPTIONS" | grep -o 'page-ranges[^ [:space:]]\+')

# $TEATITLE might be file:///etc/services.
TT=$(basename "$TEATITLE")

# Create directory for PDFs if it does not exist.
if [ ! -e "$DIR" ] ; then
   mkdir "$DIR"
   chown "$TU":"$TU" "$DIR"
fi

# Put a PDF in $DIR. Make those produced from text files searchable with
# pdftocairo.
transfer () {
  if [ ! -z "$TO" ] ; then
    PAGES=$(echo $TO | cut -d"=" -f2)
    PDF="$(echo $PDF | cut -d"." -f1)_(pages_numbers_$PAGES).pdf"
      case "$MIMETYPE" in
             application/pdf) $CF2 "$TO" "$TD" > "$DIR/$PDF"                    ;;
                  text/plain) $CF2 "$TO" "$TD" | pdftocairo -pdf - $DIR/$PDF    ;;
      application/postscript) $CF2 "$TO" "$TD" > "$DIR/$PDF"
      esac
  else
      case "$MIMETYPE" in
             application/pdf) $CF1 "$TD" > "$DIR/$PDF"                    ;;
                  text/plain) $CF1 "$TD" | pdftocairo -pdf - $DIR/$PDF    ;;
      application/postscript) $CF1 "$TD" > "$DIR/$PDF"
      esac
  fi
  chown "$TU":"$TU" "$DIR/$PDF"
}

# Check existence of a .pdf extension. Provide one if necessary. Replace
# a space with a "_". Remove last "_" in a filename.
print_pdf () {
  if [ ${TT: -4} == ".pdf" ] ; then
     PDF=$(echo $TT | tr [:space:] '_' | sed 's/.$//')
  else
     PDF=$(echo $TT | tr [:space:] '_' | sed 's/.$//').pdf
  fi
  transfer
}

# Replace a space with a "_". Remove last "_" and .txt in a filename.
print_txt () {
  if [ ${TT: -4} == ".txt" ] ; then
    PDF=$(echo $TT | tr [:space:] '_' | sed 's/.....$//').pdf
  else
    PDF=$(echo $TT | tr [:space:] '_' | sed 's/.$//').pdf
  fi
  transfer
}

# Replace a space with a "_". Remove last "_" and .ps in a filename.
print_ps () {
  if [ ${TT: -3} == ".ps" ] ; then
    PDF=$(echo $TT | tr [:space:] '_' | sed 's/....$//').pdf
  else
    PDF=$(echo $TT | tr [:space:] '_' | sed 's/.$//').pdf
  fi
  transfer
}

case "$MIMETYPE" in
          application/pdf) print_pdf    ;;
               text/plain) print_txt    ;;
   application/postscript) print_ps
esac

${dptrp1} --addr=${dptaddr} --client-id=${deviceid} --key=${devicekey} \
    upload "$DIR/$PDF" Document/Printed/$PDF

exit 0
