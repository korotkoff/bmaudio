class Download < ActiveJob::Base
  queue_as :default

  after_perform :convert

  attr_reader :url

  def perform(url)
    @url = url
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'wb') { |fp| fp.write(faraday.body) }
  end

  private

  def convert
    Convert.perform_later(path.to_s)
  end

  def faraday
    Faraday.get(url)
  end

  def path
    @path ||= Rails.root.join('tmp', 'audio', File.basename(url, '.*'), 'output.mp3')
  end

  class << self
    def all
      tracks.each do |track|
        Download.perform_later(track['url'])
      end
    end

    def oauth_url
      VK::Application.new(app_id: config['app_id'], app_secret: config['app_secret']).authorization_url(
        type: :site,
        scope: 'notify,audio,offline',
        redirect_url: config['redirect_url']
      )
    end

    private

    def config
      @config ||= YAML.load_file(Rails.root.join('config', 'vk.yml'))[Rails.env]
    end

    def tracks
      api.audio.search(q: config['query'], count: config['count'], sort: 0)['items']
    end

    def api
      @api ||= VK::Application.new(
        app_id: config['app_id'],
        app_secret: config['app_secret'],
        access_token: config['access_token']
      )
    end
  end
end
