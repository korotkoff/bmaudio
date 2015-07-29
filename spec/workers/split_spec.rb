require 'rails_helper'

describe Split do
  describe '#from' do
    specify do
      expect(subject.send(:from, 1)).to eq(60)
    end
  end

  describe '#to' do
    context 'when duration less than chunk_size' do
      before do
        allow(subject).to receive(:duration).and_return(100.0)
      end
      specify do
        expect(subject.send(:to, 1)).to eq(100)
      end
    end

    context 'when duration greater than chunk_size' do
      before do
        allow(subject).to receive(:duration).and_return(200.0)
      end

      specify do
        expect(subject.send(:to, 1)).to eq(120)
      end
    end
  end

  describe '#chunks_dir' do
    before do
      allow(subject).to receive(:path).and_return('/test_path/file_name.m4a')
    end

    subject { Split.new }

    specify do
      expect(subject.send(:chunks_dir).to_s).to eq('/test_path/chunks')
    end
  end

  describe '#number_of_chunks' do
    before do
      allow(subject).to receive(:duration).and_return(100.0)
    end

    specify do
      expect(subject.send(:number_of_chunks)).to eq(2)
    end
  end

  describe '#perform' do
    let(:path) { Rails.root.join('spec', 'fixtures', 'toreador.m4a') }
    let(:tmp_path) { Rails.root.join('tmp', 'split') }
    before do
      allow(subject).to receive(:chunks_dir).and_return(tmp_path)

      subject.perform(path)
    end

    after do
      FileUtils.rm_r(tmp_path)
    end

    let(:duration) { FFMPEG::Movie.new(path).duration }

    let(:files) { Dir[tmp_path.join('*.m4a')] }

    specify do
      # Duration: 00:01:00.04, start: 0.036281, bitrate: 129 kb/s
      expect(files.sum { |f| FFMPEG::Movie.new(f).duration }).to be_within(0.5).of(duration)
    end
  end
end
