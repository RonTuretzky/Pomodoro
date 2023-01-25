import spotipy
from spotipy.util import prompt_for_user_token

def play_playlist_on_shuffle(playlist_id):
    # Get user's access token
    scope = 'app-remote-control,playlist-read-private'
    token = prompt_for_user_token('YOUR_USERNAME', scope, client_id='YOUR_CLIENT_ID', client_secret='YOUR_CLIENT_SECRET', redirect_uri='YOUR_REDIRECT_URI')

    # Create a Spotipy object
    sp = spotipy.Spotify(auth_manager=spotipy.SpotifyOAuth(token))
    #shuffle the playlist
    sp.shuffle(True,context_uri='spotify:playlist:'+playlist_id)
    #start playing the playlist
    sp.start_playback(context_uri='spotify:playlist:'+playlist_id)
