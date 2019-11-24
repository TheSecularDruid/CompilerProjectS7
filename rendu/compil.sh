if [ $# <> 1 ]
then
    echo "Specify an entry file"
    quit
else
    cat $1 | ./myc > $1.c 2> $1.h
fi
     
