#!/bin/bash

# Main JRuby OpenCV project executable

# Ensure that build.sh is run before this program if it is the first time being executed, or if any changes have been made to build.sh

# This program ensures that JRuby can see the OpenCv .dylib file so LdLibraryLoader can run correctly.
# The option -W0 turns off warnings from JRuby, e.g. "Ignored <gem-name> because its extensions are not built.  Try: gem pristine <gem-name> --version x.y.z"
# Warnings such as these can be particularly prevalent in JRuby
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
jruby -W0 -J-Djava.library.path="$DIR"/lib/ "$DIR"/main.rb "$@"
