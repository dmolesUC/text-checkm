require 'spec_helper'

module Text
  module Checkm
    describe Manifest do
      it 'should be valid if empty' do
        checkm = ''
        res = Manifest.parse(checkm)
        expect(res.entries).to be_empty
        expect(res).to be_valid
      end

      it 'should ignore comments' do
        checkm = '#'
        res = Manifest.parse(checkm)
        expect(res.entries).to be_empty
        expect(res).to be_valid
      end

      it 'should parse the checkm version' do
        checkm = '#%checkm_0.7'
        res = Manifest.parse(checkm)
        expect(res.entries).to be_empty
        expect(res).to be_valid
        expect(res.version).to eq('0.7')
      end

      describe 'simple checkm line' do
        before(:each) do
          @checkm = 'book/Chapter9.xml |   md5   |  49afbd86a1ca9f34b677a3f09655eae9'
          @result = Manifest.parse(@checkm)
          @line = @result.entries.first
        end

        it 'should parse one entry' do
          expect(@result.entries.size).to eq(1)
        end

        it 'should parse a checkm line' do
          expect(@line.values[0]).to eq('book/Chapter9.xml')
          expect(@line.values[1]).to eq('md5')
          expect(@line.values[2]).to eq('49afbd86a1ca9f34b677a3f09655eae9')
        end

        it 'should allow name-based lookups' do
          expect(@line.sourcefileorurl).to eq('book/Chapter9.xml')
          expect(@line.alg).to eq('md5')
          expect(@line.digest).to eq('49afbd86a1ca9f34b677a3f09655eae9')
        end
      end

      it 'should support custom field names' do
        checkm = <<~CHECKM
          #%fields | testa | test b
          book/Chapter9.xml |   md5   |  49afbd86a1ca9f34b677a3f09655eae9
        CHECKM
        checkm.strip!

        res = Manifest.parse(checkm)

        line = res.entries.first

        expect(line.sourcefileorurl).to eq('book/Chapter9.xml')
        expect(line.testa).to eq('book/Chapter9.xml')
        expect(line.alg).to eq('md5')
        expect(line.send(:'test b')).to eq('md5')
        expect(line.digest).to eq('49afbd86a1ca9f34b677a3f09655eae9')
      end

      describe 'validity check' do
        it 'should be valid if the file exists' do
          checkm = '1 | md5 | b026324c6904b2a9cb4b88d6d61c81d1'
          res = Manifest.parse(checkm, path: 'spec/data/test_1')
          expect(res.entries.size).to eq(1)
          expect(res).to be_valid
        end

        it 'should be valid if the directory exists' do
          checkm = 'test_1 | dir'
          res = Manifest.parse(checkm, path: 'spec/data')
          expect(res.entries.size).to eq(1)
          expect(res).to be_valid
        end

        it 'should be invalid if a file is missing' do
          checkm = '2 | md5 | b026324c6904b2a9cb4b88d6d61c81d1'
          res = Manifest.parse(checkm, path: 'spec/data/test_1')
          expect(res.entries.size).to eq(1)
          expect(res).not_to be_valid
        end

        it 'should be invalid if the checksum is different' do
          checkm = '1 | md5 | zzz'
          res = Manifest.parse(checkm, path: 'spec/data/test_1')
          expect(res.entries.size).to eq(1)
          expect(res).not_to be_valid
        end
      end

      describe 'manipulate manifest' do
        it 'should allow files to be added to an existing manifest' do
          m = Manifest.parse('')
          res = m.add('LICENSE.md')
          expect(res.entries.size).to eq(1)
          expect(res).to be_valid
        end
      end

      it 'should be serializable to a string' do
        m = Manifest.parse('')
        n = m.add('LICENSE.md')
        lines = n.to_s.split "\n"
        expect(lines[0]).to eq('#%checkm_0.7')
        expect(lines[1]).to match(/^LICENSE\.md/)
      end

      it 'parses a two-level manifest' do
        m = Manifest.parse(File.read('spec/data/two-level-manifest.checkm'))
        entries = m.entries
        expect(entries.size).to eq(3)
        entry = entries[2]
        expect(entry.sourcefileorurl).to eq('@myfirst.checkm')
      end

      describe :remove do
        attr_reader :original
        attr_reader :modified

        before(:each) do
          @original = Manifest.parse(File.read('spec/data/two-level-manifest.checkm'))
          @modified = original.remove('foo.bar')
        end

        it 'removes entries by name' do
          expect(modified.entries.size).to eq(1)
          expect(modified.entries[0].sourcefileorurl).to eq('@myfirst.checkm')
        end

        it 'does not modify the original' do
          expect(original.entries.size).to eq(3)
          expect(original.entries[0].sourcefileorurl).to eq('foo.bar')
          expect(original.entries[1].sourcefileorurl).to eq('foo.bar')
        end
      end

      describe :to_h do
        it 'returns a hash of entries by source' do
          manifest = Manifest.parse(File.read('spec/data/two-level-manifest.checkm'))
          h = manifest.to_h
          manifest.entries.each do |e|
            expect(h[e.sourcefileorurl]).to include(e)
          end
        end
      end
    end
  end
end
