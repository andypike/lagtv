module ApplicationHelper
  def link_to_stream(name, url)
    css_class = @streams[name.downcase.to_sym] ? "live" : "offline"
    link_to url, :target => "_blank", :class => "twitch #{css_class}" do
      content_tag :span, name[0].upcase, :title => "#{name} is#{css_class == "live" ? '' : ' not'} streaming"
    end
  end

  def secure_login_path
    if Rails.env.production?
      main_app.login_url(:protocol => 'https')
    else
      main_app.login_path
    end
  end

  def secure_register_path
    if Rails.env.production?
      main_app.register_url(:protocol => 'https')
    else
      main_app.register_path
    end
  end

  def secure_my_profile_path
    if Rails.env.production?
      main_app.my_profile_url(:protocol => 'https')
    else
      main_app.my_profile_path
    end
  end

  def send_replays_path(user)
    return main_app.new_replay_path if user
    main_app.login_path
  end

  def page_wrapper(&block)
    if controller_name == "pages" && action_name == "home"
      return yield
    else
      haml_tag "div", {:class => "container content"} do
        haml_tag "div", {:class => "main"} do
          haml_tag "div", {:class => "page"} do
            yield
          end
        end  
      end      
    end
  end  

  def google_analytics
    if CONFIG[:ga_tracker].present? 
      "<script type='text/javascript'>

      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '#{CONFIG[:ga_tracker]}']);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();

    </script>".html_safe
    end
  end

  def adsense
    slot = "9694905655"
    slot = "3131851831" if controller_name == "pages" && action_name == "home"

    "<script type='text/javascript'><!--
    google_ad_client = 'ca-pub-6024311774555564';
    google_ad_slot = '#{slot}';
    google_ad_width = 728;
    google_ad_height = 90;
    //-->
    </script>
    <script type='text/javascript'
    src='https://pagead2.googlesyndication.com/pagead/show_ads.js'>
    </script>".html_safe
  end

  def testing_server?
    CONFIG[:testing_server] == true
  end

  def post_path(post, current_page = :unknown)
    return "#post-#{post.id}" if current_page == "1" || current_page.nil? # Performance improvement, if we are on the first page then so must the original post
    
    "#{forem.forum_topic_path(post.topic.forum, post.topic)}?page=#{ForumService.page_post_appears_on(post)}#post-#{post.id}"
  end

  def viewed_post?(post)
    return '<i class="icon-ok" title="Viewed"></i>'.html_safe if current_user.last_viewed_all_at && post.updated_at < current_user.last_viewed_all_at
    ""
  end

  def show_signatures(post)
    return true if current_user.nil? && post.user.show_signature && post.user.signature.present?
    return true if post.user.show_signature && post.user.signature.present? && !current_user.hide_others_signatures

    false
  end

  def analyst_stats(user)
    count = user.comments.count
    return "Has not commented on a replay" if count == 0
    "Comments: #{count}, Average: #{user.comments.average(:rating).round(1)}, Latest: #{time_ago_in_words(user.comments.last.created_at)} ago"
  end
end
