require 'spec_helper'

module Text
  module Checkm
    describe :checksum do
      it 'calculates the checksum' do
        file = 'spec/data/test_1/1'
        expected = {
          'md5' => 'b026324c6904b2a9cb4b88d6d61c81d1',
          'sha1' => 'e5fa44f2b31c1fb553b6021e7360d07d5d91ff5e',
          'sha256' => '4355a46b19d348dc2f57c046f8ef63d4538ebb936000f3c9ee954a27460dd865'
        }
        aggregate_failures 'checksums' do
          expected.each do |alg, checksum|
            File.open(file, 'r') do |f|
              actual = Checkm.checksum(f, alg)
              expect(actual).to eq(checksum), "Wrong #{alg} checksum for #{file}, expected #{checksum}, was #{actual}"
            end
          end
        end
      end
    end
  end
end
