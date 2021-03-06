local adfly = {}

function adfly:init(config)
	adfly.triggers = {
		'adf.ly/([A-Za-z0-9-_-]+)'
	}
	adfly.inline_triggers = adfly.triggers
	adfly.doc = [[*adf.ly-Link*: Postet vollen Link]]
end

function adfly:expand_adfly_link(adfly_code)
  local BASE_URL = 'https://andibi.tk/dl/adfly.php'
  local url = BASE_URL..'/?url=http://adf.ly/'..adfly_code
  local res,code  = https.request(url)
  if code ~= 200 then return nil end
  if res == 'Fehler: Keine Adf.ly-URL gefunden!' then return 'NOTFOUND' end
  cache_data('adfly', adfly_code, res, 31536000, 'key')
  return res
end

function adfly:inline_callback(inline_query, config, matches)
  local adfly_code = matches[1]
  local hash = 'telegram:cache:adfly:'..adfly_code
  if redis:exists(hash) == false then
    url = adfly:expand_adfly_link(adfly_code)
  else
    url = redis:get(hash)
  end
  
  if not url then abort_inline_query(inline_query) return end
  if url == 'NOTFOUND' then abort_inline_query(inline_query) return end
  
  local results = '[{"type":"article","id":"1","title":"Verlängerte URL","description":"'..url..'","url":"'..url..'","thumb_url":"https://anditest.perseus.uberspace.de/inlineQuerys/generic/internet.jpg","thumb_width":165,"thumb_height":150,"hide_url":true,"input_message_content":{"message_text":"'..url..'"}}]'
  utilities.answer_inline_query(inline_query, results, 3600, true)
end

function adfly:action(msg, config, matches)
  local adfly_code = matches[1]
  local hash = 'telegram:cache:adfly:'..adfly_code
  if redis:exists(hash) == false then
    local expanded_url = adfly:expand_adfly_link(adfly_code)
	if not expanded_url then
      utilities.send_reply(msg, config.errors.connection)
	  return
	end
	if expanded_url == 'NOTFOUND' then
	  utilities.send_reply(msg, 'Fehler: Keine Adf.ly-URL gefunden!')
	  return
	end
	utilities.send_reply(msg, expanded_url)
  else
    local data = redis:get(hash)
	utilities.send_reply(msg, data)
  end
end

return adfly
