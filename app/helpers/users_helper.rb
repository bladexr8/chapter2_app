module UsersHelper
  
  require 'date'
  
  # returns the Gravatar (http://gravatar.com) for the given user
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
  
  def format_order_date(date)
    if !date.nil? 
      return date.strftime("%d %B %Y")
    end
  end
  
end
