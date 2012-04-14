#!/bin/bash

AUDAO_BIN=`dirname $0`
AUDAO_HOME=`dirname $AUDAO_BIN`

for i in $AUDAO_HOME/*.jar $AUDAO_HOME/lib/*.jar
do
    if [ -z "$AUDAO_CP" ]
    then
        AUDAO_CP=$i
    else
        AUDAO_CP=$AUDAO_CP:$i
    fi
done

java -cp $AUDAO_CP com.spoledge.audao.generator.Main $*

