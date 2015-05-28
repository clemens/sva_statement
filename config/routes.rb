Rails.application.routes.draw do
  post "statements/parse", as: :parse_statement

  root to: "statements#upload"
end
