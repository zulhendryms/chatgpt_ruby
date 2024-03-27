require 'net/http'
require 'uri'
require 'json'

class ChatGpt
  def initialize(open_api_key)
    @open_api_key = open_api_key
    init_http_client
  end

  def send_message(content)
    @http_client.body = set_body(content) # Set body of the HTTP request with the message content
    http = Net::HTTP.new(@open_api_uri.host, @open_api_uri.port) # Initialize a new Net::HTTP object
    http.use_ssl = true # Use SSL for secure connection
    response = http.request(@http_client) # Send HTTP request and get response
    format_chat_response(response.body) # Format and display the response
  rescue StandardError => e
    puts "Error: #{e.message}" # Display error message if any exception occurs
  end

  private

  def init_http_client
    @open_api_uri = URI('https://api.openai.com/v1/chat/completions') # Define the URI for OpenAI API
    @http_client = Net::HTTP::Post.new(@open_api_uri) # Initialize a new POST request
    @http_client['Content-Type'] = 'application/json' # Set content type of the request
    @http_client['Authorization'] = "Bearer #{@open_api_key}" # Set authorization header with API key
  end

  def set_body(content)
    {
      "model": "gpt-3.5-turbo",
      "messages": [{
        "role": "user",
        "content": content
      }]
    }.to_json # Convert hash to JSON string
  end

  def format_chat_response(response_body)
    body = JSON.parse(response_body) # Parse JSON response
    puts "ChatGPT: #{body.dig('choices', 0, 'message', 'content')}" # Display chat response content
  rescue JSON::ParserError => e
    puts "Error parsing JSON: #{e.message}" # Display error if JSON parsing fails
  end
end

open_api_key = nil
in_chat = true
while in_chat
  puts "Enter 'exit' to quit"
  print "Please enter your OpenAI API Key: "
  message = gets.chomp
  if message.downcase == 'exit'
    puts "Exiting the chat."
    break
  end

  open_api_key = message
  puts "Your OpenAI API Key: #{open_api_key}"
  chatgpt = ChatGpt.new(open_api_key)

  while true
    print "Please enter your message: "
    message = gets.chomp
    if message.downcase == 'exit'
      puts "Exiting the chat."
      in_chat = false
      break
    end

    chatgpt.send_message(message) # Send user message to ChatGpt instance for processing
  end
end
