class Convert < ActiveJob::Base
  queue_as :default

  after_perform :split, :cleanup

  attr_reader :path

  def perform(path)
    @path = path
    @media ||= FFMPEG::Movie.new(@path)
    transcode
  end

  private

  def cleanup
    FileUtils.rm(path)
  end

  def split
    Split.perform_later(transcode_path.to_s)
  end

  def transcode
    @media.transcode(transcode_path, '-b:a 128k -strict experimental -c:a aac')
  end

  def transcode_path
    @transcode_path ||= Rails.root.join(File.dirname(path), File.basename(path, '.*') + '.m4a')
  end
end
