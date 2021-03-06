local cleverbot = {}

function cleverbot:init(config)
	cleverbot.triggers = {
	"^/cbot (.+)$",
	"^[Bb]rawlbot, (.+)$",
	"^[Bb]ot, (.+)$"
	}
	cleverbot.url = config.cleverbot.cleverbot_api
end

cleverbot.command = 'cbot <Text>'

function cleverbot:action(msg, config, matches)
  utilities.send_typing(msg.chat.id, 'typing')
  local text = matches[1]
  local query, code = https.request(cleverbot.url..URL.escape(text))
  if code ~= 200 then
	utilities.send_reply(msg, config.cleverbot.connection)
	return
  end

  local data = json.decode(query)
  if not data.clever then
    utilities.send_reply(msg, config.cleverbot.response)
	return
  end

  local answer = string.gsub(data.clever, "&Auml;", "Ä")
  local answer = string.gsub(answer, "&auml;", "ä")
  local answer = string.gsub(answer, "&Ouml;", "Ö")
  local answer = string.gsub(answer, "&ouml;", "ö")
  local answer = string.gsub(answer, "&Uuml;", "Ü")
  local answer = string.gsub(answer, "&uuml;", "ü")
  local answer = string.gsub(answer, "&szlig;", "ß")
  utilities.send_reply(msg, answer)
end

return cleverbot