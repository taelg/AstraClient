# Auto-abrir janelas no login

Ao entrar no jogo, **Skills** e **Battle** abrem automaticamente (maximizadas) no **painel esquerdo**.

## Onde fica

`modules/game_interface/gameinterface.lua` → lista `loginWindows` (logo acima de `onGameStart`).

## Como adicionar outra janela

Adicione um item na lista `loginWindows`:

```lua
{
  id = 'nomeDaJanela',
  height = 300, -- altura ao abrir
  open = function(panel, height)
    -- reutilize o helper de move do módulo (o mesmo do save/restore das sidebars)
    modules.game_algummodulo.move(panel, height, 1, false)
  end,
},
```

## Como funciona

- `openLoginWindows()` roda ~300ms depois do `onGameStart` (depois do restore das sidebars, então nossa regra sempre vence).
- Coloca cada janela em `getLeftPanel()`, já aberta.
- Roda uma vez a cada login.
