class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_action :catch_exception

  def list_sort_params(klass_array, custom_sort_array)
    klass_array.inject([]) do |sort_params, klass|
      attributes = klass.columns.map(&:name)
      attr_with_tablename = attributes.map { |attr| "#{klass.to_s.downcase.pluralize}.#{attr}" }
      sort_params += attributes + attr_with_tablename + custom_sort_array
      sort_params
    end
  end

  def sanitize_order_params(klass_array, custom_sort_array = [])
    klass_array = Array(klass_array)
    @sort = params[:sort]
    @order = params[:order]
    unless @sort.nil? || list_sort_params(klass_array, custom_sort_array).include?(@sort)
      raise SecurityException.new("Sort parameter '#{@sort}' not allowed for #{klass_array.map(&:to_s)}")
    end
    unless @order.nil? || %w[asc desc].include?(@order)
      raise SecurityException.new("Order parameter '#{@order}' not allowed for #{klass_array.map(&:to_s)}")
    end
  end

  def catch_exception
    yield
  rescue StandardError => exception
    flash[:error] = exception.message
    logger.error("WARNING: #{exception.message}. #{Rails.backtrace_cleaner.clean(exception.backtrace)}")
    redirect_to root_path
  end

  class SecurityException < StandardError
  end

  rescue_from SecurityException, :with => :security_exception

  def security_exception(exception)
    Rails.logger.info "Exception: #{exception.message}. IP Address: #{request.remote_ip}"
    redirect_to root_path
  end

end
