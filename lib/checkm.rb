require 'checkm/manifest'
require 'checkm/entry'
require 'digest'

module Checkm
  class << self
    # Size (in bytes) to read (in chunks) to compute checksums
    CHUNK_SIZE = 8 * 1024 * 1024

    # Compute the checksum 'alg' for a file
    # @param [File] file
    # @param [String] alg md5, sha1, sha256, dir
    def checksum(file, alg)
      return true unless alg # TODO: something less counterintuitive
      return File.directory?(file) if alg =~ /dir/

      digest_alg = digest_for(alg)
      return false unless digest_alg # TODO: something less counterintuitive

      while !file.eof? && (chunk = file.readpartial(CHUNK_SIZE))
        digest_alg << chunk
      end
      digest_alg.hexdigest
    end

    private

    def digest_for(alg)
      case alg
      when /md5/
        Digest::MD5.new
      when /sha1/
        Digest::SHA1.new
      when /sha256/
        Digest::SHA2.new(256)
      end
    end

  end
end
