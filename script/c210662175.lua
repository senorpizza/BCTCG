-- Ursamajor
local s,id=GetID()
function s.initial_effect(c)
    --during damage calculation FIRE lose half of their ATK/DEF (1)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_BATTLE_START)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    --Once while this card is face-up on the field: If it would be destroyed; gain 500 ATK instead.
    local e2=Effect.CreateEffect(c)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.desreptg)
    c:RegisterEffect(e2)
end
--during damage calculation function
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    if chk==0 then return bc and bc:IsFaceup() and (bc:IsAttribute(ATTRIBUTE_FIRE)) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=e:GetHandler():GetBattleTarget()
    if c:IsRelateToBattle() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-bc:GetAttack()/2)
        e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
        bc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        e2:SetValue(-bc:GetDefense()/2)
        e2:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
        bc:RegisterEffect(e2)
    end
end
--e2
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE)
	c:RegisterEffect(e1)
	return true
end