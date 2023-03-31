# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'open-uri'

describe 'building a binary', :run_oracle_php_tests do
  context 'when php8.0 is specified with oracle libraries' do
    before(:all) do
      extensions_file = File.join('spec', 'assets', 'php-extensions.yml')

      run_binary_builder('php', '8.0.0', "--sha256=3ed7b48d64357d3e8fa9e828dbe7416228f84105b8290c2f9779cd66be31ea71 --php-extensions-file=#{extensions_file}")
      @binary_tarball_location = Dir.glob(File.join(Dir.pwd, 'php-8.0.0-linux-x64.tgz')).first
    end

    after(:all) do
      FileUtils.rm(@binary_tarball_location)
    end

    it 'can load the oci8.so and pdo_oci.so PHP extensions' do
      expect(File).to exist(@binary_tarball_location)
      php_oracle_module_arguments = '-dextension=oci8.so -dextension=pdo_oci.so -dextension=pdo.so'
      php_info_modules_command = '-r "phpinfo(INFO_MODULES);"'

      php_info_with_oracle_modules = %(./spec/assets/php-exerciser.sh #{File.basename(@binary_tarball_location)} ./php/bin/php #{php_oracle_module_arguments} #{php_info_modules_command})

      output, status = run(php_info_with_oracle_modules)

      expect(status).to be_success
      expect(output).to include('OCI8 Support => enabled')
      expect(output).to include('PDO Driver for OCI 8 and later => enabled')
    end

    it 'copies in the oracle *.so files ' do
      expect(tar_contains_file('php/lib/libclntshcore.so.12.1')).to eq true
      expect(tar_contains_file('php/lib/libclntsh.so')).to eq true
      expect(tar_contains_file('php/lib/libclntsh.so.12.1')).to eq true
      expect(tar_contains_file('php/lib/libipc1.so')).to eq true
      expect(tar_contains_file('php/lib/libmql1.so')).to eq true
      expect(tar_contains_file('php/lib/libnnz12.so')).to eq true
      expect(tar_contains_file('php/lib/libociicus.so')).to eq true
      expect(tar_contains_file('php/lib/libons.so')).to eq true
    end
  end
end
