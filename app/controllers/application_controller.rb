class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :get_category

  private
    def get_category
      @categories = Set.new

      Question.uniq.pluck(:category).each do |d|
        if d
          dd = d.split(";")
          dd.each do |c|
            @categories.add c
          end
        end

      end

    end
end
