#!/bin/bash

JAVA=java
JAVAC=javac
CP=$(for i in *.jar; do echo -n $i:; done).

$JAVAC -cp $CP JavaTest.java || exit 1
$JAVA -cp $CP JavaTest || exit 1
