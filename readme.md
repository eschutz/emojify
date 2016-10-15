# Emojify
-
Emojify is a simple command line tool to replace all of the faces in a PNG image with a random facial emoji.

![obama](https://cloud.githubusercontent.com/assets/17667220/19406986/1841ac26-92db-11e6-95eb-8ad3cc9c2cb8.png)


## Usage
In the project directory, execute `./emojify.sh [image-path]`. 
Currently, emojify only accepts PNG images.

## Installation
```bash
git clone https://github.com/eschutz/emojify emojify
cd emojify
./configure
```

## Troubleshooting
* `man emojify`
* The most likely issues will be within the path configurations, so look at `build.sh` and `emojify.sh`.