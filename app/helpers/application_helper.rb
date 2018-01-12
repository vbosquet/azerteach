module ApplicationHelper
  def flash_message(flash)
    message = nil
  
    if flash[:notice].present?
      message = flash[:notice]
      title = t('helpers_titles.success')
      klass = "alert-success"
    elsif flash[:warning].present?
      message = flash[:warning]
      title = t('helpers_titles.warning')
      klass = "alert-warning"
    elsif flash[:error].present?
      message = flash[:error]
      title = t('helpers_titles.error')
      klass = "alert-danger"
    elsif flash[:alert].present?
      message = flash[:alert]
      title = t('helpers_titles.error')
      klass = "alert-danger"      
    end
  
    if message.present?
      %Q(
        <br/>
        <div class="row">
          <div class="col-sm-12">
          	<div class="alert #{klass} fade in alert-dismissable">
          	  <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
          	  <strong>#{title}!</strong> #{message}
          	</div>
          </div>
        </div>
      ).html_safe
    end
  end
end