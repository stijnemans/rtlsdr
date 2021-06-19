
## system command ##
## sudo tshark -i lo -Y "e212.imsi" -V | sed 's/^[ \t]*//;s/[ \t]*$//' | grep --color=never --line-buffered "IMSI:" > test_dump3.txt 

## grgsm_livemon -f 926.0M

##sudo tshark -i lo -Y "e212.imsi" -V | sed 's/^[ \t]*//;s/[ \t]*$//' | grep --color=never --line-buffered -e "IMSI:" -e "Arrival Time:" -e "(MCC):" -e "(MNC):" -e "(dBm):" > fist_dump_030621.txt

## export PYTHONPATH=/usr/local/lib/python3/dist-packages/:$PYTHONPATH
