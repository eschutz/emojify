
// This file exists to be compiled with a classpath pointing to the OpenCV jar
// Look at build.sh for further reference
// run.sh executes the JRuby file with a different library path, as would happen
// with a conventional java file

package org.opencv;

import org.opencv.core.Core;

public class LdLibraryLoader {
    static {
        java.lang.System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    }
}
