module EmojiURL
  extend self
  @active_emojis = Array.new
  def get_online_emoji(url)
    file_id = "emoji_" + [rand(0..100), rand(0..100), rand(0..100), ("a".."z").to_a[rand(0..26)], ("A".."Z").to_a[rand(0..26)], ("a".."z").to_a[rand(0..26)], ("A".."Z").to_a[rand(0..26)]].shuffle.join
    
    `mkdir assets/temp` unless Dir.exist? "assets/temp"
    `cd assets/temp; curl -s #{url} > #{file_id}.png`
    
    @active_emojis << file_id
    return file_id
  end

  def dispose
    @active_emojis.each do |image|
      `cd assets/temp; rm #{image}.png`
    end
    @active_emojis.clear
    if (`rmdir assets/temp`).include? "Directory not empty"
      return false
    else
      return true
    end
  end
end
