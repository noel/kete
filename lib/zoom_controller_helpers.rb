module ZoomControllerHelpers
  unless included_modules.include? ZoomControllerHelpers
    def zoom_destroy_and_redirect(zoom_class,pretty_zoom_class = nil)
      if pretty_zoom_class.nil?
        pretty_zoom_class = zoom_class
      end
      begin
        item = Module.class_eval(zoom_class).find(params[:id])

        prepare_zoom(item)
        @successful = item.destroy
      rescue
        flash[:error], @successful  = $!.to_s, false
      end

      if @successful
        flash[:notice] = "#{pretty_zoom_class} was successfully deleted."
      end
      redirect_to :action => 'list'
    end
    # TODO: this redundant with application_helper def?
    def zoom_class_controller(zoom_class)
      zoom_class_controller = String.new
      case zoom_class
      when "StillImage"
        zoom_class_controller = 'images'
      when "Video"
        zoom_class_controller = 'video'
      when "Comment"
        zoom_class_controller = 'comments'
      when "AudioRecording"
        zoom_class_controller = 'audio'
      else
        zoom_class_controller = zoom_class.tableize
      end
    end

    def zoom_class_from_controller(controller)
      zoom_class = String.new
      case controller
      when "images"
        zoom_class = 'StillImage'
      when "video"
        zoom_class = 'Video'
      when "comments"
        zoom_class = 'Comment'
      when "audio"
        zoom_class = 'AudioRecording'
      else
        zoom_class = controller.classify
      end
    end

    def prepare_zoom(item)
      # only do this for members of ZOOM_CLASSES
      if ZOOM_CLASSES.include?(item.class.name)
        begin
          item.oai_record = render_oai_record_xml(:item => item, :to_string => true)
          item.basket_urlified_name = @current_basket.urlified_name
        rescue
          logger.error("prepare_and_save_to_zoom error: #{$!.to_s}")
        end
      end
    end

    def prepare_and_save_to_zoom(item)
      prepare_zoom(item)
      item.zoom_save
    end
  end
end