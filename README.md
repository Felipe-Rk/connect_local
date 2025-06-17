📄 README.md
markdown
Copiar
Editar
# Connect - Chatwoot Customizado (Produção com Docker)

Este projeto é uma instância personalizada do Chatwoot 4.x com suporte ao canal **Evolution**, configurado para produção usando **Docker Compose** e **Dockerfile multiestágio**.

---

## 🚀 Requisitos

- Docker instalado
- Docker Compose v2+ (`docker compose`)
- Docker Desktop com integração WSL2 (se estiver em Windows)

---

## 🧪 Primeira execução

### 1. Clone o projeto

```bash
git clone https://github.com/seu-usuario/connect.git
cd connect
2. Crie o .env.production
Crie um arquivo .env.production com o seguinte conteúdo:

env
Copiar
Editar
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true

# Acesso inicial
CW_ACCOUNT_NAME=Minha Empresa
CW_ADMIN_EMAIL=admin@empresa.com
CW_ADMIN_PASSWORD=senha123456

# Banco
POSTGRES_USER=chatwoot
POSTGRES_PASSWORD=chatwoot
POSTGRES_DB=chatwoot_production
DATABASE_URL=postgresql://chatwoot:chatwoot@db:5432/chatwoot_production

# Redis
REDIS_URL=redis://redis:6379/0

# Outros
SECRET_KEY_BASE=CHAVE_GERADA_COM_RAKE_SECRET
DB_HOST=db
Gere a chave com: RAILS_ENV=production bundle exec rake secret

🐳 Comandos Docker
🔨 Build da aplicação
bash
Copiar
Editar
docker compose build
A imagem será montada em três estágios: frontend, backend e produção.

🚦 Subir os serviços
bash
Copiar
Editar
docker compose up -d
Isso iniciará: db, redis, web, sidekiq.

🗄️ Rodar migrações + seed (primeira vez)
bash
Copiar
Editar
docker compose exec web bundle exec rails db:setup
docker compose exec web bundle exec rails db:seed
O seed vai criar automaticamente a conta, usuário admin e canal Evolution.

📡 Acessar a aplicação
Acesse:

arduino
Copiar
Editar
http://localhost:3000
Login com:

Email: o que estiver no .env.production

Senha: definida na variável CW_ADMIN_PASSWORD

🛠 Scripts automáticos
O container web possui um entrypoint.sh que:

Aguarda o banco subir.

Executa rails db:migrate.

Inicia o servidor puma.

📁 Estrutura dos serviços
Serviço	Função	Porta
db	PostgreSQL	5432
redis	Redis	6379
web	Rails API + frontend	3000
sidekiq	Workers em background	—

📦 Multi-estágio Dockerfile
frontend: compila assets Vite usando Node + pnpm

backend: instala gems e pré-compila assets

produção: imagem final leve com tudo pronto

🧼 Para parar e remover tudo
bash
Copiar
Editar
docker compose down -v
🧠 Dicas
Use docker compose logs -f para acompanhar os logs.

Use docker compose exec web rails c para acessar o console Rails em produção.

Certifique-se de que a conta admin foi criada corretamente via seed ou console.

🧾 Licença
Este projeto segue a licença original do Chatwoot. Personalizações são livres conforme necessidade.

yaml
Copiar
Editar

---

Deseja que eu te gere esse `README.md` como arquivo também?