require 'open-uri'
require 'time'

require 'text/checkm/checksum'

module Text
  module Checkm
    class Entry
      BASE_FIELDS = %w[sourcefileorurl alg digest length modtime targetfileorurl].freeze
      attr_reader :values

      def self.create(path, args = {}) # TODO: why is this in this class?
        base = args[:base] || Dir.pwd
        alg = args[:alg] || 'md5'
        file = File.new File.join(base, path)

        format('%s | %s | %s | %s | %s | %s', path, alg, Checkm.checksum(file, alg), File.size(file.path), file.mtime.utc.xmlschema, nil)
      end

      def initialize(line, manifest = nil)
        @line = line.strip
        @include = false
        @fields = BASE_FIELDS
        @fields = manifest.fields if manifest && manifest.fields
        @values = line.split('|').map(&:strip)
        @manifest = manifest
      end

      # rubocop:disable Style/MethodMissingSuper
      def method_missing(sym, *_args)
        # TODO: something less extreme
        @values[@fields.index(sym.to_s.downcase) || BASE_FIELDS.index(sym.to_s.downcase)]
      end
      # rubocop:enable Style/MethodMissingSuper

      def respond_to_missing?(sym, *)
        @fields.include?(sym.to_s.downcase) || BASE_FIELDS.include?(sym.to_s.downcase)
      end

      def valid?
        source_exists? && valid_checksum? && valid_multilevel? # xxx && valid_length? && valid_modtime?
      end

      private

      def source
        file = sourcefileorurl
        file = file[1..] if file =~ /^@/
        File.join(@manifest.path, file)
      end

      def source_exists?
        File.exist? source
      end

      def valid_checksum?
        file = File.new source
        checksum = Checkm.checksum(file, alg)
        [true, digest].include?(checksum) # TODO: something less counterintuitive
      end

      # def valid_length?
      #   throw NotImplementedError
      # end
      #
      # def valid_modtime?
      #   throw NotImplementedError
      # end

      def valid_multilevel?
        return true unless sourcefileorurl =~ /^@/

        Manifest.parse(URI.open(source).read, path: File.dirname(source))
      end
    end
  end
end
