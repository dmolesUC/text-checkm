require 'text/checkm/entry'

module Text
  module Checkm
    class Manifest
      def self.parse(str, args = {})
        Manifest.new str, args
      end

      attr_reader :version, :entries, :fields, :path

      # rubocop:disable Metrics/MethodLength
      def initialize(checkm, args = {})
        @args = args
        @version = nil
        @checkm = checkm
        @lines = checkm.split "\n"
        @entries = []
        @eof = false
        @fields = nil
        @path = args[:path] # TODO: something less hacky
        @path ||= Dir.pwd

        parse_lines
        # xxx error on empty entries?
        @lines.unshift('#%checkm_0.7') and (@version = '0.7') if @version.nil?
      end

      # rubocop:enable Metrics/MethodLength

      def valid?
        return true if @entries.empty?

        @entries.map(&:valid?).none? { |b| b == false }
      end

      def add(path, args = {})
        line = Entry.create path, args

        Manifest.new [@lines, line].flatten.join("\n"), @args
      end

      def remove(path)
        Manifest.new @lines.reject { |x| x =~ /^@?#{path}/ }.join("\n"), @args
      end

      def to_s
        @lines.join("\n")
      end

      def to_h
        {}.tap do |h|
          entries.each do |e|
            source = e.sourcefileorurl
            (h[source] ||= []) << e
          end
        end
      end

      private

      # rubocop:disable Metrics/MethodLength
      def parse_lines
        @lines.each do |line|
          case line
          when /^$/
            # do nothing
          when /^#%/
            parse_header line
          when /^#/
            parse_comment line
          # when /^@/
          #   parse_line line
          else
            parse_line line
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def parse_header(line)
        case line
        when /^#%checkm/
          match = /^#%checkm_(\d+)\.(\d+)/.match line
          @version = "#{match[1]}.#{match[2]}" if match
        when /^#%eof/
          @eof = true
        when /^#%fields/
          list = line.split('|')
          list.shift
          @fields = list.map { |v| v.strip.downcase }
        when /^#%prefix/, /^#%profile/
          # do nothing
        end
      end
      # rubocop:enable Metrics/MethodLength

      def parse_comment(_line)
        # do nothing
      end

      def parse_line(line)
        @entries << Entry.new(line, self)
      end
    end
  end
end
