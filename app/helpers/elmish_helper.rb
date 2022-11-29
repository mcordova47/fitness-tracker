# frozen_string_literal: true

# Support for purescript-elmish components
module ElmishHelper
  def purescript_include_tag(purs_file)
    javascript_include_tag(purs_file, extname: false)
  end

  def elmish_component(name, props: {}, html_class: '')
    unique_id = SecureRandom.uuid.to_s[0..7]
    client_script = __elmish_client_script_mount(name, unique_id, props)

    content_for :page_scripts do
      @view_helper_frontend_included ||= {}
      concat purescript_include_tag("src/EntryPoints/#{name}.purs") unless @view_helper_frontend_included[name]
      @view_helper_frontend_included[name] = true
      concat(content_tag(:script, "(function() { #{client_script} })()".html_safe))
    end

    content_tag :div, '', id: unique_id, class: html_class
  end

  def __elmish_client_script_mount(module_name, container_id, props) # rubocop:disable Metrics/MethodLength
    "
    var boot = Purs_EntryPoints_#{module_name.gsub('/', '_')}.boot
    var mount = boot && (boot.mount || boot)
    if (typeof mount === 'function') {
      mount('#{container_id}')(#{props.to_json})()
    }
    else {
      throw new Error('Expected module #{module_name} to export a value `boot` ' +
        'which is either a function or has a function field `mount`, but got `' + boot + '`')
    }
    "
  end
end
