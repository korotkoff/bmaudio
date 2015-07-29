require 'rails_helper'
require 'webmock/rspec'

describe Download do
  describe '#path' do
    before do
      allow(subject).to receive(:url).and_return('https://vk.com/audio/file.mp3?no_cache_params')
    end

    specify do
      expect(subject.send(:path).to_s).to end_with('/tmp/audio/file/output.mp3')
    end
  end

  describe '#perform' do
    let(:file) { Rails.root.join('spec', 'fixtures', 'toreador.mp3') }
    let(:expect_path) { Rails.root.join('tmp', 'audio', File.basename(file, '.*'), 'output.mp3') }
    let(:url) { 'http://vk.com/toreador.mp3' }

    before do
      stub_request(:get, url).to_return(body: File.read(file))
      subject.perform(url)
    end
    subject { Download.new }

    specify do
      expect(File.exist?(expect_path)).to be true
    end
  end
end
