module TestData
  OFFSITE_KEY    = '18bed0f4247a4f79bc9941bfed5b534c' unless const_defined?('OFFSITE_KEY')
  OFFSITE_SECRET = '2e8ebdafbef844a5929086e659e4188c' unless const_defined?('OFFSITE_SECRET')

  ONSITE_KEY = 'http://perisphere.1939worldsfair.com/app.xml' unless const_defined?('ONSITE_KEY')
  ONSITE_SECRET = 'eda0c62773234093bea92645eea0493d' unless const_defined?('ONSITE_SECRET')

  TOKEN = 'iELpLIedJM1N1oz4tbsME4v8bbGiqE8D2DGs1MHvqM9386xJAiBYV7kAbPsKH1LfvMCDNUxk4IDl3KvtKzbqFEZAKW90DK1pkNml0cK1xuU=' unless const_defined?('TOKEN')
  SECRET = '8805c751977a4b1d8bbf0d9913ae5840' unless const_defined?('SECRET')

  USER_ID = '456073223' unless const_defined?('USER_ID')
  ALBUM_ID = '40418' unless const_defined?('ALBUM_ID')
  PHOTO_ID = '100809' unless const_defined?('PHOTO_ID')
  VIDEO_ID = '53551799' unless const_defined?('VIDEO_ID')
  VIDEO_TITLE = '110403na' unless const_defined?('VIDEO_TITLE')

  BAD_IDS = [nil, "", "asdf"] unless const_defined?('BAD_IDS')
end
