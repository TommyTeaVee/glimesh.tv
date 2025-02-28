defmodule GlimeshWeb.AboutController do
  use GlimeshWeb, :controller

  plug :put_layout, "about.html"

  def index(conn, _param) do
    render(conn, "index.html", page_title: format_page_title(gettext("About Glimesh")))
  end

  def streaming(conn, _param) do
    render(conn, "streaming.html", page_title: format_page_title(gettext("Streaming")))
  end

  def team(conn, _param) do
    users = Glimesh.Accounts.list_team_users()

    render(conn, "team.html",
      page_title: format_page_title(gettext("The Team")),
      users: users
    )
  end

  def mission(conn, _param) do
    render(conn, "mission.html", page_title: format_page_title(gettext("Our Mission")))
  end

  def alpha(conn, _param) do
    render(conn, "alpha.html", page_title: format_page_title(gettext("Alpha")))
  end

  # Other layouts

  def faq(conn, _param) do
    conn
    |> put_layout("text.html")
    |> render("faq.html", page_title: format_page_title(gettext("Frequently Asked Questions")))
  end

  def privacy(conn, _param) do
    conn
    |> put_layout("text.html")
    |> render("privacy.html",
      page_title: format_page_title(gettext("Privacy & Cookie Policy")),
      privacy_version: Glimesh.get_privacy_version()
    )
  end

  def accept_privacy(conn, _params) do
    user = conn.assigns.current_user

    user_return_to = get_session(conn, :user_return_to)
    last_path = NavigationHistory.last_path(conn)

    # Unlikely to fail, but we don't care if it does...
    Glimesh.Accounts.update_user_privacy_version(user, Glimesh.get_privacy_version())

    conn
    |> redirect(to: user_return_to || last_path || "/")
  end

  def terms(conn, _param) do
    conn
    |> put_layout("text.html")
    |> render("terms.html",
      page_title: format_page_title(gettext("Terms of Service")),
      terms_version: Glimesh.get_privacy_version()
    )
  end

  def conduct(conn, _param) do
    conn
    |> put_layout("text.html")
    |> render("conduct.html", page_title: format_page_title(gettext("Rules of Conduct")))
  end

  def cookies(conn, _param) do
    conn
    |> put_layout("text.html")
    |> render("cookies.html",
      page_title: format_page_title(gettext("Cookie Policy")),
      cookie_version: Glimesh.get_privacy_version()
    )
  end

  def dmca(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("dmca.html",
      page_title: format_page_title(gettext("DMCA"))
    )
  end

  def credits(conn, _param) do
    %{
      ftl: ftl_credits,
      node: node_credits,
      elixir: elixir_credits
    } = Glimesh.Credits.get_dependencies()

    founder_subscribers = Glimesh.Payments.list_platform_founder_subscribers()
    supporter_subscribers = Glimesh.Payments.list_platform_supporter_subscribers()

    conn
    |> put_layout("text.html")
    |> render("credits.html",
      page_title: format_page_title(gettext("Credits")),
      ftl_credits: ftl_credits,
      elixir_credits: elixir_credits,
      node_credits: node_credits,
      founder_subscribers: founder_subscribers,
      supporter_subscribers: supporter_subscribers
    )
  end
end
