require "./bandit/lib/bandit/version"
require "./bandit/lib/bandit/exceptions"
require "./bandit/lib/bandit/config"
require "./bandit/lib/bandit/experiment"
require "./bandit/lib/bandit/date_hour"
require "./bandit/lib/bandit/memoizable"

require "./bandit/lib/bandit/players/base"
require "./bandit/lib/bandit/players/round_robin"
require "./bandit/lib/bandit/players/epsilon_greedy"
require "./bandit/lib/bandit/players/softmax"
require "./bandit/lib/bandit/players/ucb"

require "./bandit/lib/bandit/storage/base"
require "./bandit/lib/bandit/storage/memory"
require "./bandit/lib/bandit/storage/memcache"
require "./bandit/lib/bandit/storage/redis"
require "./bandit/lib/bandit/storage/dalli"
require "./bandit/lib/bandit/storage/pstore"

require "./bandit/lib/bandit/extensions/controller_concerns"
require "./bandit/lib/bandit/extensions/array"
require "./bandit/lib/bandit/extensions/view_concerns"
require "./bandit/lib/bandit/extensions/time"
require "./bandit/lib/bandit/extensions/string"

require "./bandit/lib/bandit/engine"

module Bandit
  @@storage_failure_at = nil

  def self.config
    @config ||= Config.new
  end

  def self.setup(&block)
    yield config
    config.check!
    # intern keys in storage config
    config.storage_config = config.storage_config.inject({}) { |n,o| n[o.first.intern] = o.last; n }
  end

  def self.storage
    # try using configured storage at least once every 5 minutes until resolved
    if @@storage_failure_at.nil? or (Time.now.to_i - @@storage_failure_at) > 300
      @storage ||= BaseStorage.get_storage(Bandit.config.storage.intern, Bandit.config.storage_config)
    else
      Rails.logger.warn "storage failure detected #{Time.now.to_i - @@storage_failure_at} seconds ago - using memory storage for 5 minutes"
      BaseStorage.get_storage(:memory, Bandit.config.storage_config)
    end
  end

  def self.player
    @player ||= BasePlayer.get_player(Bandit.config.player.intern, Bandit.config.player_config)
  end

  def self.storage_failed!
    @@storage_failure_at = Time.now.to_i
  end

  def self.get_experiment(name)
    exp = Experiment.instances.select { |e| e.name == name }
    exp.length > 0 ? exp.first : nil
  end

  def self.experiments
    Experiment.instances
  end
end

require 'action_controller'
ActionController::Base.send :include, Bandit::ControllerConcerns
ActionController::Base.send :include, Bandit::ViewConcerns

require 'action_view'
ActionView::Base.send :include, Bandit::ViewConcerns
