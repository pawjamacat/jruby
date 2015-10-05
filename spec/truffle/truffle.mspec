class MSpecScript

  def self.windows?
    ENV.key?('WINDIR') || ENV.key?('windir')
  end

  set :target, File.expand_path("../../../bin/jruby#{windows? ? '.bat' : ''}", __FILE__)

  if ARGV[-2..-1] != %w[-t ruby] # No flags for MRI
    set :flags, %w[-X+T -J-ea -J-esa -J-Xmx2G]
  end

  set :language, [
    "spec/ruby/language"
  ]

  set :core, [
    "spec/ruby/core"
  ]

  set :library, [
    "spec/ruby/library",

    # Not yet explored
    "^spec/ruby/library/continuation",
    "^spec/ruby/library/fiber",
    "^spec/ruby/library/mathn",
    "^spec/ruby/library/readline",
    "^spec/ruby/library/syslog",

    # Doesn't exist as Ruby code - basically need to write from scratch
    "^spec/ruby/library/win32ole",

    # Uses the Rubinius FFI generator
    "^spec/ruby/library/etc",

    # Hangs
    "^spec/ruby/library/net/http",
    "^spec/ruby/library/net/ftp",

    # Load issues with 'delegate'.
    "^spec/ruby/library/delegate/delegate_class/instance_method_spec.rb",
    "^spec/ruby/library/delegate/delegator/protected_methods_spec.rb",
  ]

  set :truffle, [
    "spec/truffle/specs"
  ]

  set :backtrace_filter, /mspec\//

  set :tags_patterns, [
    [%r(^.*/language/),                 'spec/truffle/tags/language/'],
    [%r(^.*/core/),                     'spec/truffle/tags/core/'],
    [%r(^.*/library/),                  'spec/truffle/tags/library/'],
    [%r(^.*/truffle/specs/truffle),     'spec/truffle/tags/truffle/'],
    [/_spec.rb$/,                       '_tags.txt']
  ]

  if windows?
    # exclude specs tagged with 'windows'
    set :xtags, (get(:xtags) || []) + ['windows']
  end

  MSpec.enable_feature :encoding
  MSpec.enable_feature :fiber
  MSpec.disable_feature :fork
  MSpec.enable_feature :generator

  set :files, get(:language) + get(:core) + get(:library) + get(:truffle)
end

if respond_to?(:ruby_exe)
  class SlowSpecsTagger
    def initialize
      MSpec.register :exception, self
    end

    def exception(state)
      if state.exception.is_a? SlowSpecException
        tag = SpecTag.new("slow:#{state.describe} #{state.it}")
        MSpec.write_tag(tag)
      end
    end
  end

  class SlowSpecException < Exception
  end

  class ::Object
    alias old_ruby_exe ruby_exe
    def ruby_exe(*args, &block)
      if (MSpecScript.get(:xtags) || []).include? 'slow'
        raise SlowSpecException, "Was tagged as slow as it uses ruby_exe(). Rerun specs."
      end
      old_ruby_exe(*args, &block)
    end
  end

  SlowSpecsTagger.new
end
