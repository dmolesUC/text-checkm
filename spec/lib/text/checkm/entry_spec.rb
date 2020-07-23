require 'spec_helper'

module Text
  module Checkm
    describe Entry do
      describe :create do
        it 'should return a manifest line' do
          res = Entry.create('LICENSE.md')
          expect(res).to match(/LICENSE\.md | md5 | a02e647a5dcd1fe38abf74f9f0d44dae | 1149 | \d{4}/)
        end
      end

      describe :respond_to_missing? do
        it 'should return true for all base fields' do
          entry = Entry.new('book/Chapter9.xml |   md5   |  49afbd86a1ca9f34b677a3f09655eae9')
          Entry::BASE_FIELDS.each do |f|
            expect(entry.respond_to?(f.to_sym)).to eq(true)
          end
        end

        it 'should return true for all custom fields' do
          expected_fields = %w[
            nfo:fileUrl
            nfo:hashAlgorithm
            nfo:hashValue
            nfo:fileSize
            nfo:fileLastModified
            nfo:fileName
            mrt:primaryIdentifier
            mrt:localIdentifier
            mrt:creator
            mrt:title
            mrt:date
          ]
          manifest = Manifest.parse(File.read('spec/data/merritt-manifest.checkm'))
          entry = manifest.entries[0]
          expected_fields.each do |f|
            expect(entry.respond_to?(f.to_sym)).to eq(true)
          end
        end
      end

      describe :valid do
        it 'handles multi-level manifests' do
          manifest = Manifest.parse(File.read('spec/data/two-level-manifest.checkm'), path: 'spec/data')
          entry = manifest.entries[2]
          expect(entry.valid?).to be_truthy # TODO: something less hacky
        end
      end
    end
  end
end
