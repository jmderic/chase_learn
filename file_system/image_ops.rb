#!/usr/bin/env ruby

# set env variable RUBYOPT=-w; writing it in the shebang line
# (even as #!/usr/bin/env ruby -w -- ) yields:
#/usr/bin/env: ruby -w: No such file or directory

# Usage: [mark@mark-K54C android_data]$ ./image_ops.rb /mnt/share/mark/android_data /mnt/android_device /mnt/android_sdcard

require 'date'
require 'fileutils'

def dummy_fn arg_eater
  return true
end
DEBUG = true

class FilterUserImages
  def matches? path_string
    if File.directory?(path_string)
      return false if File.symlink?(path_string)
      exclude = %r&(?:Android/data|waze/skins|android_device/.images)$& =~ path_string
      return !exclude
    end
    if File.file?(path_string)
      # will execute for symlinked files
      escaped_path_string = path_string.gsub(/ /, '\\\\ ').gsub(/([()])/, '\\\\\1')
      cmd_output = `file #{escaped_path_string}`
      if $?.to_i != 0
        STDERR.print "file fails on #{path_string} as escaped #{escaped_path_string}; ", $?, "\n"
        return true
      end
      # return cmd_output =~ /image data|MPEG/
      return cmd_output =~ /image data/
    end
    # not sure if this choice exists?  Thinking Special file?
    false
  end
end

class UserImageFileOp
  def initialize output_dir
    @output_dir = output_dir
    @dt_string = DateTime.now.strftime('%Y%m%d_%H%M%S')
    @file_map = {}
  end
  def op path_string
    dir = File.dirname path_string
    file = File.basename path_string
    if @file_map.has_key? dir
      @file_map[dir].push file
    else
      @file_map[dir] = [ file ]
    end
  end
  def extra_files
    name2 = @dt_string + "_image_info_2.out"
    fullpath = File.join @output_dir, name2
    out_file2 = File.open(fullpath, 'w')
    keys_sorted = @file_map.keys.sort
    keys_sorted.each { |dirname|
      out_file2.write "#{dirname}\n"
      dir = Dir.new(dirname)
      known_files = @file_map[dirname]
      dir.each { |node|
        next if /^\.\.?$/ =~ node
        next if known_files.include? node
        path_string = File.join dirname, node
        out_file2.write "    #{node}  #{File.stat(path_string).inspect}\n"
      }
    }
  end
  def dump
    name1 = @dt_string + "_image_info_1.out"
    fullpath = File.join @output_dir, name1
    out_file1 = File.open(fullpath, 'w')
    keys_sorted = @file_map.keys.sort
    keys_sorted.each { |dir|
      values_sorted = @file_map[dir].sort
      out_file1.write "#{dir}\n"
      values_sorted.each { |file|
        out_file1.write "    #{file}\n"
      }
    }
  end
  def copy
    name = @dt_string + "_image_copy"
    fullpath = File.join @output_dir, name
    keys_sorted = @file_map.keys.sort
    keys_sorted.each { |dir|
      copyto_dir = dir.gsub(%r:/:, '_')
      copyto_fullpath = File.join fullpath, copyto_dir
      FileUtils.mkdir_p copyto_fullpath
      values_sorted = @file_map[dir].sort
      values_sorted.each { |file|
        copyfrom = File.join dir, file
        copyto = File.join copyto_fullpath, file
        print "#{copyfrom} -> #{copyto}\n" if DEBUG
        FileUtils.cp copyfrom, copyto
      }
    }
  end
end

class DirWalker
  def initialize root_dirname, filter, file_processor
    @root_dirname = root_dirname
    @filter_matches = method :dummy_fn
    @filter_matches = filter.method :matches? if filter.respond_to? :matches?
    @file_op = method :dummy_fn
    @file_op = file_processor.method :op if file_processor.respond_to? :op
    print "#{@root_dirname}\n" if DEBUG
  end

  def enter_directory dirname, level
    dir = Dir.new(dirname)
    prefix = " " * 4 * (level + 1)
    dir.each { |node|
      next if /^\.\.?$/ =~ node
      path_string = File.join dirname, node
      next unless @filter_matches.call path_string
      print "#{prefix}#{node}\n" if DEBUG
      enter_directory path_string, level+1 if File.directory?(path_string)
      @file_op.call path_string if File.file?(path_string)
    }
  end

  def go
    enter_directory @root_dirname, 0
  end
end

print "#{ARGV}\n"

target_dirnames = ARGV[1..-1]
filter = FilterUserImages.new
file_processor = UserImageFileOp.new ARGV[0]
target_dirnames.each { |target_dirname|
  dir_walker = DirWalker.new(target_dirname, filter, file_processor)
  dir_walker.go
}
file_processor.extra_files
file_processor.dump
file_processor.copy
