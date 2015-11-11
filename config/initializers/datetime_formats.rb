[Time, Date, DateTime].map do |klass|
  klass::DATE_FORMATS[:default]   = ->(t) { t.strftime('%Y-%m-%d %H:%M') }
  klass::DATE_FORMATS[:common]    = ->(t) { t.strftime('%Y-%m-%d %H:%M:%S') }
  klass::DATE_FORMATS[:only_date] = ->(t) { t.strftime('%Y年%m月%d日') }
  klass::DATE_FORMATS[:flat]      = ->(t) { t.strftime('%Y%m%d') }
  klass::DATE_FORMATS[:just_date]      = ->(t) { t.strftime('%Y-%m-%d').remove(' 00:00') }
end