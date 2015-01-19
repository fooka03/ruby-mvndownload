require 'net/http'
require 'fileutils'
require 'digest/md5'
require 'sys/filesystem'

class Mvndownload
    def self.md5_check(source, destination, sourcemd5 = false, destinationmd5 = false)
        smd5 = nil
        dmd5 = nil
        if sourcemd5
            File.open(source, 'rb') { |h| smd5 = h.read } ; nil
        else
            smd5 = Digest::MD5.file(source).hexdigest
        end

        if destinationmd5
            File.open(destination, 'rb') { |h| dmd5 = h.read } ; nil
        else
            dmd5 = Digest::MD5.file(destination).hexdigest
        end
        s5 = ""
        d5 = ""
        smd5.each_byte { |c|
            s5 << c.chr if c==9 || c==10 || c==13 || (c > 31 && c < 127)
        }
        dmd5.each_byte { |c|
            d5 << c.chr if c==9 || c==10 || c==13 || (c > 31 && c < 127)
        }
        s5 = s5.chomp.strip
        d5 = d5.chomp.strip
        return s5 == d5
    end
    private_class_method :md5_check

    def self.dodownload(source, dest, user, pass, p_addr, p_port, p_user, p_pass)
        rc = nil
        uri = nil
        uri = URI(source)
        req = Net::HTTP::Get.new(uri.request_uri)
        unless user == nil
            req.basic_auth(user, pass)
        end
        begin
            h = Net::HTTP.new(uri.host, uri.port, p_addr, p_port, p_user, p_pass)
            h.use_ssl = uri.scheme == 'https'
            h.start do |http|
                http.request req do |response|
                    parent = File.dirname dest
                    stat = Sys::Filesystem.stat(parent)
                    bytes_available = stat.block_size * stat.blocks_available
                    
                    if ( response.content_length() != nil )
                        if ((response['content-length'].to_i *2) >  bytes_available)
                            raise RuntimeError,"Not enough disk space to download the file to " + parent
                        end
                    end
                    
                    rc = response.code
                    if rc == '200'
                        unless File.directory? parent
                            FileUtils.rm_f(parent) if File.exist?(parent)
                            FileUtils.mkdir_p parent
                        end
                        open(dest, 'w') do |io|
                            response.read_body do |chunk|
                                io.write chunk
                            end
                        end
                    else
                        puts "Download failed, return code from download: #{rc}"
                    end
                end
            end
        rescue => downloadException
            abort "The file #{source} failed to be downloaded due to: " + downloadException.message 
        end
        return rc == '200'
    end
    private_class_method :dodownload

    def self.download( vars )
        getfile = true
        vars.each do |key, val|
            if val == ""
                vars[key] = nil 
            end
        end
        if vars[:filename] == nil
            filename = vars[:source][/([^\/]+)$/]
        else
            filename = vars[:filename]
        end
        dest = File.join vars[:destination], filename
        if File.file?(dest)
            if dodownload("#{vars[:source]}.md5", "#{dest}.md5", vars[:username], vars[:password], vars[:proxyhost], vars[:proxyport], vars[:proxyuser], vars[:proxypass])
                getfile = !md5_check("#{dest}.md5", "#{dest}", true, false)
            end
        end
        if getfile
            FileUtils.rm_f dest
            unless dodownload(vars[:source], dest, vars[:username], vars[:password], vars[:proxyhost], vars[:proxyport], vars[:proxyuser], vars[:proxypass])
                abort "Download failed, you may want to check your remote server for issues or the correct file name"
            end
            if dodownload("#{vars[:source]}.md5", "#{dest}.md5", vars[:username], vars[:password], vars[:proxyhost], vars[:proxyport], vars[:proxyuser], vars[:proxypass])
                abort "MD5 check failed, potentially corrupt download" unless md5_check("#{dest}.md5", "#{dest}", true, false)
            end
        end
    end
end
