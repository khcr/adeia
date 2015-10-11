require 'adeia/database'
require 'adeia/exceptions'

module Adeia

  class Authorization < Database

    def authorize!
      @rights, @resource_ids = token_rights(right_name)
      raise LoginRequired if @rights.empty? && @user.nil?
      if @user
        rights, resource_ids = send("#{right_name}_rights")
        @rights, @resource_ids = @rights + rights, @resource_ids + resource_ids
      end
      raise AccessDenied unless @rights.any? && authorize?
    end

    def can?
      rights, token_rights = send("#{right_name}_rights"), token_rights(right_name)
      @rights, @resource_ids = rights[0] + token_rights[0], rights[1] + rights[1]
      @rights.any? && authorize?
    end

    private

    def authorize?
      all_entries? || on_ownerships? || on_entry?
    end

    def all_entries?
      @rights.any? { |r| r.permission_type == "all_entries" }
    end

    def on_ownerships?
      @user && @resource && @rights.any? { |r| r.permission_type == "on_ownerships" } && @resource.user == @user
    end

    def on_entry?
      @resource && @resource_ids.include?(@resource.id)
    end

    def right_names
      {read: [:index, :show], create: [:new, :create], update: [:edit, :update], destroy: [:destroy]} 
    end

    def right_name
      right_names.select { |k, v| v.include? @action.to_sym }.keys[0] || :action
    end

  end

end