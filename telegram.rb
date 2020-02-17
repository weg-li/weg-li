require 'telegram/bot'
require 'byebug'

token = ENV['TELEGRAM_BOT_SECRET']


STEPS = [
  [{ send_message: { text: 'Moin 👋, bitte lade ein Beweisfoto hoch 📸' } }, ],
  [{ send_chat_action: { action: 'upload_video' }, send_message: { text: 'Soll ich jetzt analysieren?', reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['Ja', 'Nein']], one_time_keyboard: true) }, }, ],
  [{ send_message: { text: 'Ist das Kennzeichen *DA AV 304* korrekt?', parse_mode: 'Markdown', reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['Ja', 'Nein']], one_time_keyboard: true) } }, ],
  [{ send_location: { latitude: 53.5773497, longitude: 9.933147 }, send_message: { text: 'Ist die Adresse Kennzeichen *Tigerstraße 32* korrekt?', parse_mode: 'Markdown', reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['Ja', 'Nein']], one_time_keyboard: true) } }, ],
  [{ send_message: { text: 'Wie lange hat das Fahrzeug gestanden?', parse_mode: 'Markdown', reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['min. 3 Minuten', 'min. 1 Stunde', 'min. 3 Stunden']], one_time_keyboard: true) } }, ],
  [{ send_message: { text: 'Was ist das Parkvergehen?', parse_mode: 'Markdown', reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['auf einem Radfahrstreifen', 'auf einem Fußgängerweg', 'im Halteverbot'], ['im Kreuzungsbereich', 'auf einem Fußgängerüberweg', 'vor einer Bordsteinabsenkung']], one_time_keyboard: true) } }, ],
  [{ send_message: { text: "Willst du jetzt die Anzeige per E-Mail erstatten:\nDA AV 304\nTigerstraße 32\nParken auf einem Fußgängerweg", parse_mode: 'Markdown', reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['Ja', 'Nein']], one_time_keyboard: true) } }, ],
  [{ send_message: { text: '✉️ E-Mail ist raus! Tschüssi 👋, bis bald!', reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true) } }, ],
]

index = 0

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts message.chat.id
    puts message

    case message.text
    when '/start'
      index = 0
    else
      steps = STEPS[index]
      if steps.nil?
        index = 0
      else
        index += 1
        puts steps
        steps.each do |hash|
          hash.each do |method, options|
            bot.api.send(method, options.merge(chat_id: message.chat.id))
          end
        end
      end





      # See more: https://core.telegram.org/bots/api#replykeyboardmarkup
      # bot.api.send_message(chat_id: message.chat.id, text: 'Danke, ich analysiere mal 🤖')
      # bot.api.send_chat_action(chat_id: message.chat.id, action: 'upload_video')
      # sleep(3)
      # bot.api.send_message(chat_id: message.chat.id, text: 'Hier ist der Tatort')
      # bot.api.send_location(chat_id: message.chat.id, latitude: 53.5773497, longitude: 9.933147)
      # sleep(3)
      # question = 'Ich habe mehrere Kennzeichen ausgelesen'
      # answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['DA AV 304', 'OS FS 215']], one_time_keyboard: true)
      # bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
      # bot.api.get_file(file_id: message.photo.first.file_id)
      # {"ok"=>true, "result"=>{"file_id"=>"AgADAgADEasxG5sEEEm6ZPzqK8SEljEEuA8ABAEAAwIAA20AA9gUBQABFgQ", "file_size"=>22040, "file_path"=>"photos/file_0.jpg"}}
      # (byebug) puts "https://api.telegram.org/file/bot#{ENV['TELEGRAM_BOT_SECRET']}/photos/file_0.jpg"
      # https://api.telegram.org/file/bot755455667:AAHuyytHwEELZf4Itie3Y6PVjGrgwFfhFzs/photos/file_0.jpg
    end
  end
end

# require 'telegram/bot'
# require 'byebug'
# Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_SECRET']) {|bot| byebug }
# chat_id = '69405281'
