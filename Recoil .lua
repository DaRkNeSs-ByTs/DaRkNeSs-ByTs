local Activate_Key        = "numlock"     -- Ativa o script com a tecla numlock
local Auto_ADS_Enabled    = false         -- Auto-ADS desabilitado por padrão

local Fire_key            = 1             -- Clique esquerdo (atirar)
local ADS_key             = 3             -- Clique direito (ADS)
local Weapon_switch_key   = 9             -- Trocar entre padrões de arma

-- Definições de padrões de recuo para armas
weapon_table = {
    primary = { Horizontal = -0, Vertical = 2.5, FireDelay = 0, AdsDelay = 0 },  -- Todos os atrasos zerados
}

local current_weapon = "primary"          -- Padrão de arma no início

------------------------------------------ Fim das Configurações do Usuário ---------------------------------------------------

local VERSION = "1.0.0"
local script_active = false

-- Função para mover o mouse com precisão ajustada
function Move_x(horizontal_recoil)
    MoveMouseRelative(math.floor(horizontal_recoil), 0)
end

function Move_y(vertical_recoil)
    MoveMouseRelative(0, math.floor(vertical_recoil))
end

-- Função para aplicar o recuo diretamente com máxima responsividade
function Direct_Fire()
    local horizontal_recoil = weapon_table[current_weapon]["Horizontal"]
    local vertical_recoil = weapon_table[current_weapon]["Vertical"]

    -- Executa o movimento imediatamente enquanto o botão está pressionado
    while IsMouseButtonPressed(Fire_key) do
        if horizontal_recoil < 0 then
            Move_x(horizontal_recoil)  -- Move para a esquerda
        end
        if vertical_recoil > 0 then
            Move_y(vertical_recoil)    -- Move para baixo
        end
        -- Sem Sleep para resposta instantânea
    end
end

-- Função para Auto-ADS com máxima responsividade
function ADS_Fire()
    PressMouseButton(ADS_key)
    Direct_Fire()  -- Chama Direct_Fire sem atraso
    ReleaseMouseButton(ADS_key)
end

-- Função para inicializar as configurações
function Initialize()
    ClearLog()
    OutputLogMessage('--> Anti-Recoil script - Version: %s\n', VERSION)
    OutputLogMessage('--> Ativado com a tecla: %s\n', Activate_Key)
    OutputLogMessage('--> Auto-ADS: %s\n', Auto_ADS_Enabled and "Habilitado" or "Desabilitado")
    OutputLogMessage('--> Padrão de arma atual: %s\n', current_weapon)

    if IsKeyLockOn(Activate_Key) then
        script_active = true
        OutputLogMessage('Script ativado e pronto\n')
    else
        script_active = false
        OutputLogMessage('Script desativado\n')
        OutputLogMessage('Ative-o pressionando: %s\n', Activate_Key)
    end
end

-- Inicializa o script
Initialize()

-- Loop principal do script com foco na responsividade do Fire_key
function OnEvent(event, arg)
    if event == "PROFILE_ACTIVATED" then
        EnablePrimaryMouseButtonEvents(true)  -- Ativa eventos do botão primário imediatamente
    elseif event == "PROFILE_DEACTIVATED" then
        ReleaseMouseButton(Fire_key)
        ReleaseMouseButton(ADS_key)
    end

    -- Verifica ativação do script
    if IsKeyLockOn(Activate_Key) then
        script_active = true

        -- Troca de arma (mantida, mas não interfere na responsividade do disparo)
        if event == "MOUSE_BUTTON_PRESSED" and arg == Weapon_switch_key then
            current_weapon = (current_weapon == "primary") and "secondary" or "primary"
            OutputLogMessage('Padrão de arma %s ativado...\n', current_weapon)
        end

        -- Disparo com máxima prioridade e responsividade
        if event == "MOUSE_BUTTON_PRESSED" and arg == Fire_key then
            if Auto_ADS_Enabled then
                ADS_Fire()  -- Auto-ADS instantâneo
            else
                Direct_Fire()  -- Disparo direto instantâneo
            end
        end
    else
        if script_active then
            script_active = false
            OutputLogMessage('Script desativado\n')
        end
    end
end