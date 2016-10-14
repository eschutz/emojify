# Main JRuby OpenCV File
# Execute with run.sh
# As it contains the appropriate alterations to java.library.path

# If this file's name changes, ensure that it is also changed in run.sh

HOME_DIR = `echo $HOME`.chomp # Gets home directory of the account in which the program is being run
EXE_DIR = File.expand_path(File.dirname(__FILE__))

$CLASSPATH << "#{EXE_DIR}/helpers" # JRuby line that adds the helpers directory to the classpath so LdLibraryLoader can be called

require "#{EXE_DIR}/lib/opencv-310.jar"
require 'chunky_png' # ChunkyPNG is being used instead of the built in OpenCV image processing functions as OpenCV does not easily support transparency
require 'logger'
require 'optparse' # Parses options given to the program
require_relative 'src/emojis.rb' # Emojis module containing an array constant of urls pointing to emoji images
require_relative 'src/emoji_url.rb' # EmojiURL module that contains methods for downloading the emojis and disposing of them after use
require_relative 'src/image_processor.rb' # Simple ImageProcessor class that uses ChunkyPNG to resize and compose the emoji and source images

Java::OrgOpencv::LdLibraryLoader # Loads in the main OpenCV library from a java file

java_import org.opencv.core.Mat
java_import org.opencv.core.MatOfRect
java_import org.opencv.core.Size
java_import org.opencv.imgcodecs.Imgcodecs
java_import org.opencv.imgproc.Imgproc
java_import org.opencv.objdetect.CascadeClassifier

# Logfile, as there can be a tonne of errors in OpenCV and occasionally ChunkyPNG
$logger = Logger.new("#{EXE_DIR}/logs/emoji_face_#{Time.now.year}-#{Time.now.month}-#{Time.now.day}.log", 10, 'weekly')


# Parses any command line options into a hash
options = Hash.new
OptionParser.new do |opt|
  opt.banner = "Usage: ./run.sh [-fn] {path to file}"
  opt.on('-f', '--fast') { |f| options[:fast_rgba] = true }
  opt.on('-n NAME', '--name=NAME') {|n| options[:name] = n}
end.parse!

# Helper method to get the emojis for both image libraries
def get_emoji
  begin
  rand_emoji = EmojiURL::get_online_emoji(Emojis::APPLE_FACES[rand(0...(Emojis::APPLE_FACES.length))]) # Downloads a random emoji
  return [Imgcodecs.imread("#{EXE_DIR}/assets/temp/#{rand_emoji}.png"), # Emoji as OpenCV matrix
          ChunkyPNG::Image.from_file("#{EXE_DIR}/assets/temp/#{rand_emoji}.png")] # Emoji as ChunkyPNG matrix
  rescue ChunkyPNG::SignatureMismatch => e
    $logger.debug "Emoji Signature Mismatch, likely network error:"
    $logger.error "Full error message: #{e.message}"
    puts "Emoji unable to be found! This is most likely and error with the network, so try again later."
    exit
  end
end


# Checks if command called with arguments
unless ARGV[0].nil? || ARGV[0].empty?
  image_file = ARGV.join(" ")
else
  $logger.error "No image path specified!"
  puts "No image path specified!"
  exit
end

puts "Starting..." # Communication is key

face_detector = CascadeClassifier.new("#{HOME_DIR}/opencv-3.1.0/data/haarcascades/haarcascade_frontalface_alt.xml") # Face detector

image = Imgcodecs.imread(image_file) # Main source image as OpenCV matrix


# Checks if the image loaded correctly
if image.cols == 0
  errors = Array.new
  unless image_file[0] == "/"
    errors << "Image path not absolute" << "Argument not a valid file path" # Will add more errors here as they come up
  end

  $logger.debug "Invalid command line arguments given: #{ARGV}"
  $logger.error "Image not found!\nPossible causes: #{errors.join(", ")}"
  puts "Image not found! Possible causes: #{errors.join(", ")}"

  exit
end

face_detections = MatOfRect.new


# Detects faces, the program is rescued from crashing if the image is too large to analyse properly
begin
  face_detector.detectMultiScale(image, face_detections) # Where the face deteciton magic happens
rescue org.opencv.core::CvException => exception
  $logger.debug "OpenCV failed in face_detector.detectMultiScale(image, face_detections)"
  $logger.fatal "Full error message: #{exception.message}"
  puts "Face detection failed! The program was unable to process the image."
  puts "Try using a smaller image."
  puts "For a full error log, check #{EXE_DIR}/logs"

  exit
end

# Ensures that OpenCV has detected faces before continuing
if face_detections.to_array.length == 0
  puts "No faces detected :/\nAborting..."
  exit
end

puts "Detected #{face_detections.to_array.length} faces"


# Loads in the source image as ChunkyPNG matrix, rescues and exits if the file is not a PNG
begin
  combined_image = ChunkyPNG::Image.from_file(image_file)
rescue ChunkyPNG::SignatureMismatch => e
  $logger.debug "Image not a PNG file"
  $logger.error "Full error message #{e.message}"
  puts "Image not a PNG file!"
  exit
end


# Iterates over the faces in the source image, applying a random emoji onto each face
# and re-looping with the new 'emojified' image until all faces are emojified
face_detections.to_array.each do |rect|
  overlays = get_emoji # Array containing both the OpenCV and ChunkyPNG matrices, assigned to a variable so that the both libraries are working with the same image
  overlay_opencv = overlays[0]
  overlay_chunky = overlays[1]
  overlay_resized = Mat.new # Creates a destination for the emoji's resizing

  Imgproc.resize(overlay_opencv, overlay_resized, Size.new(rect.width, rect.height))

  # Figures for enlarging the emoji by a certain value
  # Currently unimplemented, may implement later as optional command line specifications
  ### x_offset, y_offset = (rect.width * 0.15).round.to_i, (rect.height * 0.15).round.to_i

  overlay_chunky_resized = ImageProcessor::resize(overlay_chunky, rect.width, rect.height) # Resizes the image for ChunkyPNG

  # Where the emojifying takes place
  combined_image = ImageProcessor::combine_images(combined_image, overlay_chunky_resized, rect.x, rect.y)

end

# Filename defaults to the name of the given image, or the value of the name argument if specified
if options[:name]
  if options[:name].split(".").last =~ /png/i
    filename = options[:name]
  else
    filename = options[:name] + ".png"
  end
else
  filename = "#{Dir.pwd}/#{image_file.split("/").last}"
end


# Saves the image with command line options
image_options = options.keys.collect{|o| o if o == options[:fast_rgba] && options[o] == true}
unless image_options.length == 0
  combined_image.save(filename, *image_options.keys)
else
  combined_image.save(filename)
end

puts "Done. Writing #{filename}"

EmojiURL::dispose # Deletes all the images from the temp directory
