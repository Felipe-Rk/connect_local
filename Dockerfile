# Etapa 1: Build frontend com pnpm e Vite
FROM node:20-alpine AS frontend
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install
COPY . .

# Etapa 2: Build backend com Ruby e bundler
FROM ruby:3.3.3 AS backend
WORKDIR /app

# Dependências de sistema
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl git nodejs
RUN apt-get update -qq && apt-get install -y libpq5 curl postgresql-client && rm -rf /var/lib/apt/lists/*


# Copiar arquivos de produção
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle config set without 'development test' && bundle install

# Copiar o restante do app
COPY . .

# Copiar assets buildados do frontend
COPY --from=frontend /app/public/assets ./public/assets
COPY --from=frontend /app/public/vite ./public/vite
RUN RAILS_ENV=production bundle exec rails assets:precompile

# Precompilar assets Rails
ENV RAILS_ENV=production
RUN bundle exec rake assets:precompile

# Etapa final: imagem leve para produção
FROM ruby:3.3.3-slim AS production
WORKDIR /app

# Dependências mínimas
RUN apt-get update -qq && apt-get install -y libpq5 curl postgresql-client && rm -rf /var/lib/apt/lists/*

#executa migrações
COPY entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Copiar app pronto da etapa anterior
COPY --from=backend /app /app

# Variáveis e porta
ENV RAILS_ENV=production
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
