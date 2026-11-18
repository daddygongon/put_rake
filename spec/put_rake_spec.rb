# frozen_string_literal: true

require "tmpdir"

RSpec.describe PutRake do
  it "has a version number" do
    expect(PutRake::VERSION).not_to be nil
  end

  describe PutRake::CLI do
    around do |example|
      original_path = ENV["PUT_RAKE_PATH"]
      example.run
    ensure
      ENV["PUT_RAKE_PATH"] = original_path
    end

    it "lists both current and legacy template names" do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "current.rake"), "desc 'current task'\ntask :current\n")
        File.write(File.join(dir, "Rakefile_legacy"), "desc 'legacy task'\ntask :legacy\n")
        ENV["PUT_RAKE_PATH"] = dir

        expect { described_class.start(["list"]) }
          .to output(/(?=.*current.*current task)(?=.*legacy.*legacy task)/m).to_stdout
      end
    end

    it "migrates legacy templates without overwriting existing files" do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "Rakefile_old"), "old")
        File.write(File.join(dir, "Rakefile_kept"), "legacy")
        File.write(File.join(dir, "kept.rake"), "current")
        ENV["PUT_RAKE_PATH"] = dir

        expect { described_class.start(["migrate"]) }
          .to output(/(?=.*Rakefile_old -> old\.rake)(?=.*skipped: Rakefile_kept)/m).to_stdout

        expect(File.read(File.join(dir, "old.rake"))).to eq("old")
        expect(File).not_to exist(File.join(dir, "Rakefile_old"))
        expect(File.read(File.join(dir, "kept.rake"))).to eq("current")
        expect(File.read(File.join(dir, "Rakefile_kept"))).to eq("legacy")
      end
    end

    it "supports a dry run" do
      Dir.mktmpdir do |dir|
        source = File.join(dir, "Rakefile_old")
        File.write(source, "old")
        ENV["PUT_RAKE_PATH"] = dir

        expect { described_class.start(["migrate", "--dry-run"]) }
          .to output(/Template migration \(dry run\).*Rakefile_old -> old\.rake/m).to_stdout

        expect(File).to exist(source)
        expect(File).not_to exist(File.join(dir, "old.rake"))
      end
    end
  end
end
