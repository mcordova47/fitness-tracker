# frozen_string_literal: true

require 'open3'
require 'fileutils'

# Adds PureScript preprocessing to asset pipeline
class PursProcessor
  MIME_TYPE = 'text/purescript'

  class Railtie < ::Rails::Railtie # rubocop:disable Style/Documentation
    initializer :purescript_support do |_|
      Sprockets.tap do |s|
        s.register_mime_type MIME_TYPE, extensions: ['.purs'] unless s.mime_exts['.purs']
        s.register_preprocessor MIME_TYPE, PursProcessor unless s.processors[MIME_TYPE]&.include? PursProcessor
      end

      PursProcessor.ensure_environment only_when_clean: true
    end
  end

  @purs_root = 'app/assets/purs'
  @src_dir = 'src'
  @temp_dir = '.temp'
  @mutex = Mutex.new
  @dev_mode = false

  class << self
    attr_accessor :temp_dir, :src_dir, :dev_mode
  end

  def self.call(input) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    env = input[:environment]
    ensure_environment

    module_path = input[:name]
    out_path = esbuild_bundle module_path
    result = File.read out_path

    json = JSON.parse File.read("#{out_path}.dependencies")
    inputs = json['outputs']&.first&.second&.dig('inputs')&.keys
    raise "Unexpected JSON format of esbuild metafile in #{out_path}.dependencies" unless inputs

    deps = inputs.uniq.map { |f| env.build_file_digest_uri File.expand_path(f.strip, absolute_purs_root) }

    ctx = env.context_class.new(input)
    ctx.metadata.merge(data: result, dependencies: deps)
  end

  def self.esbuild_bundle(module_path) # rubocop:disable Metrics/MethodLength
    sh 'npx', 'spago', 'build', '--no-psa'

    module_name = file_path_to_module_name module_path
    entry_point_file = "output/#{module_name}/index.js"

    unless File.exist? File.expand_path(entry_point_file, absolute_purs_root)
      raise "Cannot build #{module_path} because #{entry_point_file} does not exist"
    end

    out_path = "#{absolute_temp_dir}/.out/#{module_name}.js"
    sh(
      'npx', 'esbuild',
      entry_point_file,
      '--bundle',
      "--outfile=#{out_path}",
      "--global-name=Purs_#{module_name.gsub('.', '_')}",
      '--platform=browser',
      "--define:process.env.NODE_ENV=\"#{dev_mode ? 'development' : 'production'}\"",
      '--loader:.css=text',
      "--metafile=#{out_path}.dependencies",
      ('--minify' unless dev_mode),
      '--target=node10'
    )
    out_path
  end

  def self.file_path_to_module_name(file_path)
    src_dir_canonical = "#{src_dir.delete_suffix('/')}/"
    unless file_path.starts_with? src_dir_canonical
      raise PursCompileError, "PureScript file #{file_path} was expected to be under #{src_dir_canonical}"
    end

    file_path[src_dir_canonical.length, file_path.length].gsub('/', '.')
  end

  def self.absolute_purs_root
    @absolute_purs_root ||= File.expand_path(@purs_root, Rails.root)
  end

  def self.absolute_temp_dir
    @absolute_temp_dir ||= File.expand_path(temp_dir, absolute_purs_root)
  end

  def self.ensure_environment(only_when_clean: false)
    node_modules_exists = Dir.exist? "#{absolute_purs_root}/node_modules"

    return if node_modules_exists && only_when_clean

    @mutex.synchronize do
      return if @environment_initialized

      FileUtils.mkdir_p "#{absolute_temp_dir}/.out"
      sh 'npm', 'install', '--silent', '--no-progress', '--no-audit'

      @environment_initialized = true
    end
  end

  def self.sh(*cmd)
    _, stderr, status = ::Open3.capture3(*cmd.compact, chdir: absolute_purs_root)
    return if status.success?

    raise PursCompileError, "PureScript support: '#{cmd.join(' ')}' returned code #{$CHILD_STATUS}.\n#{stderr}"
  end
end

class PursCompileError < StandardError
end
