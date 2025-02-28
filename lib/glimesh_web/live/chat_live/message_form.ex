defmodule GlimeshWeb.ChatLive.MessageForm do
  use GlimeshWeb, :live_component

  alias Glimesh.Chat
  alias Glimesh.Emotes

  @impl true
  def update(%{chat_message: chat_message, user: user, channel: channel} = assigns, socket) do
    changeset = Chat.change_chat_message(chat_message)

    include_animated = if user, do: Glimesh.Payments.is_platform_subscriber?(user), else: false
    global_emotes = Emotes.list_emotes(include_animated)
    channel_emotes = Emotes.list_emotes_for_channel(channel)
    emotes = Emotes.convert_for_json(channel_emotes ++ global_emotes)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:emotes, emotes)
     |> assign(:channel_username, channel.user.username)
     |> assign(:disabled, is_nil(user))}
  end

  @impl true
  def handle_event("send", %{"chat_message" => chat_message_params}, socket) do
    # Pull a fresh user and channel from the database in case something has changed
    user = Glimesh.Accounts.get_user!(socket.assigns.user.id)
    channel = Glimesh.ChannelLookups.get_channel!(socket.assigns.channel.id)
    save_chat_message(socket, channel, user, chat_message_params)
  end

  defp save_chat_message(socket, channel, user, chat_message_params) do
    case Chat.create_chat_message(user, channel, chat_message_params) do
      {:ok, _chat_message} ->
        {:noreply,
         socket
         |> assign(:changeset, Chat.empty_chat_message())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      # Permissions errors
      {:error, error_message} ->
        error_changeset = %Ecto.Changeset{
          action: :validate,
          changes: chat_message_params,
          errors: [
            message: {error_message, [validation: :required]}
          ],
          data: %Glimesh.Chat.ChatMessage{},
          valid?: false
        }

        {:noreply, assign(socket, changeset: error_changeset)}
    end
  end
end
