#!/bin/sh

# This program ensures that the LdLibraryLoader file is compiled with the correct classpath containing the OpenCv jar
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OPENCV_JAR="$DIR/lib/opencv-310.jar"
JAVA_FILE="helpers/org/opencv/LdLibraryLoader.java"
javac -cp "${OPENCV_JAR}" "${JAVA_FILE}"
