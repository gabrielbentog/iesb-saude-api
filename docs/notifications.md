# API de Notificações (Frontend)

Este documento descreve os endpoints disponíveis para consumir as notificações do usuário (o sino) na API.

Prefixo: todas as rotas estão sob `/api` e exigem autenticação (devise token auth / headers usados no restante da API).

Endpoints

- GET /api/notifications

  - Descrição: lista as notificações do usuário autenticado.
  - Query params opcionais:
    - `page` (inteiro) — página para paginação
    - `per_page` (inteiro) — itens por página (padrão 20)
  - Exemplo de resposta (200):
    {
    "notifications": [
    {
    "id": "uuid-123",
    "title": "Sua consulta foi agendada",
    "body": "Sua solicitação de consulta para 2025-09-20 às 14:00 foi registrada e aguarda confirmação.",
    "read": false,
    "data": {"event":"appointment_created","status":"pending"},
    "url": "/appointments/45",
    "appointment_id": "uuid-45",
    "created_at": "2025-09-18T12:34:56Z"
    }
    ]
    }

- GET /api/notifications/:id

  - Descrição: obtém os detalhes de uma notificação específica (do usuário autenticado).
  - Resposta (200): objeto `Notification` (igual ao item acima).

- PATCH /api/notifications/:id

  - Descrição: atualizar atributos permitidos (atualmente apenas `read`). Usar para marcar como lida.
  - Body (JSON):
    { "notification": { "read": true } }
  - Resposta (200): notificação atualizada.

- GET /api/notifications/unread_count
  - Descrição: retorna a contagem de notificações não lidas (útil para mostrador do sino).
  - Resposta (200):
    { "unread_count": 3 }

Criação de notificações

- Notificações são persistidas no backend (modelo `Notification`). O frontend normalmente não precisa criar notificações manualmente — o backend cria automaticamente em eventos como criação/alteração de `Appointment`.

Segurança e autenticação

- Todas as rotas exigem usuário autenticado com o mesmo mecanismo da API (Devise token auth). Envie os headers de autenticação conforme o padrão do projeto.

Recomendações para o frontend (sino)

- Ao inicializar a sessão do usuário, chamar `GET /api/notifications/unread_count` para popular o badge do sino.
- Para mostrar uma lista rápida no menu, carregar `GET /api/notifications?per_page=10`.
- Ao abrir a notificação, chamar `PATCH /api/notifications/:id` com `{ notification: { read: true } }` para marcar como lida imediatamente.
- Se o `url` da notificação for relativo (ex.: `/appointments/45`), concatene com a rota frontend apropriada.

Fluxo recomendado para interação do usuário

1. Ao gerar o token, buscar `unread_count` e exibir badge.
2. Ao clicar no sino, buscar a `page=1&per_page=20` para popular o dropdown com as notificações mais recentes.
3. Ao clicar em um item do dropdown:
   - redirecionar para `url` relativo (ou rota correspondente);
   - chamar PATCH para marcar como lida (caso ainda não seja);
   - atualizar badge decrementando `unread_count` localmente ou recarregando o contador.

Exemplos de implementação (JS / pseudo-code)

// buscar unread_count
fetch('/api/notifications/unread_count', { headers })
.then(r => r.json())
.then(({ unread_count }) => setBadge(unread_count))

// listar notificações
fetch('/api/notifications?page=1&per_page=10', { headers })
.then(r => r.json())
.then(data => setNotifications(data.notifications))

// marcar como lida
fetch(`/api/notifications/${id}`, {
method: 'PATCH',
headers: Object.assign({'Content-Type': 'application/json'}, headers),
body: JSON.stringify({ notification: { read: true } })
})

Considerações Finais

- Se quiser push em tempo-real (para atualizar o badge sem polling), recomendo adicionar um broadcast via ActionCable quando uma `Notification` for criada; posso implementar esse broadcast no backend e um consumidor JS para assinar o canal.
