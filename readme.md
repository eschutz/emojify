# Jruby OpenCV Project Generator
## ropencv generated:
* Project directory
* `src` & `lib` directories
* directory structure `helpers/org/opencv`
* OpenCV java library loader `helpers/org/opencv/LdLibraryLoader.java`
* Buildfile `build.sh`
* Main executable `run.sh`
* Main JRuby file `main.rb`

### __Build file__
**NOTE:** this file must be executed as a final step of project generation - do so before executing `run.sh` or editing any other files
* Compiles `LdLibraryLoader.java` into a class file with a classpath pointing to the OpenCV jar
* **If this file is edited, ensure it is executed before running run.sh**

### __Main executable__
* Executes main.rb with the `java.library.path` set to the location of `opencv-java310.dylib`
**When executing the project, run `./run.sh` __NOT__ `./main.rb` or `jruby main.rb` so JRuby can load the library**

### __Main JRuby File__
* Area for all your project-central code - the main project file
* Other JRuby/Ruby files should be placed in `src`
* Do not delete the code that already exists within the file - this code loads in all the appropriate libraries correctly so OpenCV and JRuby will work nicely

### src directory
* Use this for other JRuby files to be required within the main

### lib directory
* Use this for other external `.jar` libraries

### Library Loader
* This loads the OpenCV java library so you don't have to go through the pain in the JRuby file execution
* Located within `helpers/org/opencv` so can be loaded as a java package of the same name when helpers is in the classpath

## Troubleshooting
* Firstly, ensure that the variables in `build.sh` point to the correct installation and variables of OpenCV
* If the version number is incorrect, you will have to change the version number in main.rb and run.sh also
