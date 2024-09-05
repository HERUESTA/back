Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:8000', 'http://localhost:3000', 'https://front-pink-nine.vercel.app', 'https://twitch-back-885f64c14cf8.herokuapp.com'
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['X-CSRF-Token'],
      credentials: true
  end
end