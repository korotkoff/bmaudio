require 'rails_helper'

describe Convert do
  describe '#transcode_path' do
    before do
      allow(subject).to receive(:path).and_return('/test_path/file_name.mp3')
    end

    specify do
      expect(subject.send(:transcode_path).to_s).to eq('/test_path/file_name.m4a')
    end
  end

  describe '#perform' do
    let(:path) { Rails.root.join('spec', 'fixtures', 'toreador.mp3') }
    before do
      allow(subject).to receive(:transcode_path)
        .and_return(Rails.root.join('tmp', 'convert', 'toreador.m4a'))

      FileUtils.mkdir_p(File.dirname(subject.send(:transcode_path)))

      subject.perform(path)
    end

    after do
      FileUtils.rm_r(Rails.root.join('tmp', 'convert'))
    end

    specify do
      expect(File.exist?(subject.send(:transcode_path))).to be true
    end
  end
end
