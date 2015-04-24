require 'cfpropertylist'
require 'pngdefry'

module Lagunitas
  class App
    attr_reader :path, :real_path

    def initialize(path, real_path)
      @path = path
      @real_path = real_path
    end

    def info
      @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: File.join(@path, 'Info.plist')).value)
    end

    def identifier
      info['CFBundleIdentifier']
    end

    def bundle_name
      info['CFBundleName']
    end

    def display_name
      info['CFBundleDisplayName']
    end

    def version
      info['CFBundleVersion']
    end

    def short_version
      info['CFBundleShortVersionString']
    end

    def icon(size)
      icons.each do |icon|
        return icon[:path] if icon[:width] >= size
      end
      nil
    end

    def icons
      @icons ||= begin
        icons = []
        info['CFBundleIcons']['CFBundlePrimaryIcon']['CFBundleIconFiles'].each do |name|
          icons << get_image(name)
          icons << get_image("#{name}@2x")
        end
        icons.delete_if { |i| !i }
      rescue NoMethodError # fix a ipa without icons
        []
      end
    end

    def certificate
      @certificate ||= change_certificate
    end

    def team_name
      certificate['TeamName']
    end

    def name
      certificate['Name']
    end

    def expiration_date
      certificate['ExpirationDate']
    end

    private

    def change_certificate
      certificate ||= File.read(File.join(@path, 'embedded.mobileprovision'))
      require 'iconv' unless String.method_defined?(:encode)
      if String.method_defined?(:encode)
        certificate.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        certificate.encode!('UTF-8', 'UTF-16')
      else
        ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
        certificate = ic.iconv(certificate)
      end

      certificate.gsub!(/.*(?=<\?xml)/){|s|''}
      certificate.gsub!(/(?<=<\/plist>).*$/m){|s|''}

      File.open(File.join(@path, 'embedded.mobileprovision'), 'w') { |file| file.write(certificate) }
      CFPropertyList.native_types(CFPropertyList::List.new(file: File.join(@path, 'embedded.mobileprovision')).value)
    end

    def get_image(name)
      path = File.join(@path, "#{name}.png")
      return nil unless File.exist?(path)

      dimensions = Pngdefry.dimensions(path)
      {
        path: path,
        width: dimensions.first,
        height: dimensions.last
      }
    rescue Errno::ENOENT
      nil
    end
  end
end
