require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: google_play_sign.rb [options]'

  Option = Struct.new('Option', :arg_name, :arg_description, :symbol)
  [ Option.new('--package NAME',
               'Your app package, e.g com.test.app',
               :package),
    Option.new('--google-play-key KEY_PATH',
               'Google Play public key (in DER format) used to sign release app',
               :gp_key),
    Option.new('--keystore KEYSTORE_PATH',
               'Path to keystore (.jks file)',
               :keystore),
    Option.new('--keystore-password PASSWORD',
               'Password to the keystore - required only when option "--keystore" is specified',
               :keystore_password),
    Option.new('--key-alias KEY_ALIAS',
               'Alias of key in the keystore - required only when option "--keystore" is specified',
               :key_alias)
  ].each do |option|
    opts.on(option.arg_name, option.arg_description) { |v| options[option.symbol] = v}
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end.parse!

def exit_with_message(msg)
  puts msg
  exit
end

def check_arguments_valid(options)
  if options[:package].nil?
    exit_with_message('You need to specify package of the app!')
  end
  if options[:gp_key].nil? && options[:keystore].nil?
    exit_with_message 'You need to specify either keystore or Google Play signing key'
  end
  if options[:gp_key] && options[:keystore]
    exit_with_message 'You can\'t specify both keystore and Google Play signing key, choose one'
  end
end

def check_file_exists(file_path)
  exit_with_message "File #{file_path} doesn't exist!" unless File.exist?(file_path)
end

def der_to_keystore(der_path)
  key_alias = 'myalias'
  password = 'mypassword'
  temp_keystore_path = 'gp_imported_keystore_temp.jks'
  # import DER file to keystore file (JKS)
  `keytool -importcert \
      -alias #{key_alias} \
      -file #{der_path} \
      -keystore #{temp_keystore_path} \
      -storepass #{password} -noprompt`
  Keystore.new(temp_keystore_path, password, key_alias)
end

def write_out_hash_from_keystore(package, keystore)
  cert_hex = `keytool -exportcert \
          -alias #{keystore.key_alias} \
          -keystore #{keystore.file_path} \
          -storepass #{keystore.password} \
          | xxd -p | tr -d "[:space:]"`
  cert_with_package = "#{package} #{cert_hex}"
  hashed = `printf "#{cert_with_package}" | shasum -a 256 | cut -c1-64`
  base64output = `printf "#{hashed}" | xxd -r -p | base64 | cut -c1-11`
  puts "Your SMS hashcode is: #{base64output}"
end

Keystore = Struct.new('Keystore', :file_path, :password, :key_alias)


check_arguments_valid(options)

if options[:gp_key]
  check_file_exists(options[:gp_key])
  keystore = der_to_keystore(options[:gp_key])
  write_out_hash_from_keystore(options[:package], keystore)
  File.delete(keystore.file_path)
else
  check_file_exists(options[:keystore])
  password = options[:keystore_password]
  key_alias = options[:key_alias]
  keystore = Keystore.new(options[:keystore], password, key_alias)
  write_out_hash_from_keystore(options[:package], keystore)
end
