class UserPresenter
  def name
    Settings.name.presence || github_username || "User"
  end

  def sunetid
    Settings.sunetid.to_s
  end

  def email
    "#{sunetid}@stanford.edu"
  end

  def github_username
    Settings.github.username.presence
  end

  def avatar_url
    return nil unless github_username

    "https://github.com/#{github_username}.png?size=56"
  end

  def github_profile_url
    return nil unless github_username

    "https://github.com/#{github_username}"
  end

  def initials
    name.split.first(2).map { |w| w[0].upcase }.join
  end
end
