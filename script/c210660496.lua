-- Narita Kaihime
-- Scripted By poka-poka

local s,id=GetID()
function s.initial_effect(c)
    -- Unaffected by Spell effects (except Equip Spells)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)
    -- Cannot be targeted for attacks if equipped with Equip Spell
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	e2:SetCondition(s.atkcon)
	c:RegisterEffect(e2)
    -- Equip an Equip Spell from GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_EQUIP)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET) 
    e4:SetTarget(s.eqtg)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)
    -- Add 1 FIRE Warrior Monster from Deck to hand if this card is attacked during the Battle Phase
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1)
    e5:SetCondition(s.battlesendcon)
	e5:SetTarget(s.battlesendtg)
    e5:SetOperation(s.battlesendop)
    c:RegisterEffect(e5)
    -- Add 2 FIRE Warrior Monsters to hand if this monster destroys an opponent's monster in battle
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,2))
    e8:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e8:SetCode(EVENT_BATTLE_DESTROYING)
    e8:SetCondition(aux.bdcon)
    e8:SetTarget(s.thtg2)
    e8:SetOperation(s.thop2)
    e8:SetCountLimit(1,id)
    c:RegisterEffect(e8)
    -- Gain ATK for each Equip Spell
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_SINGLE)
    e9:SetCode(EFFECT_UPDATE_ATTACK)
    e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e9:SetRange(LOCATION_MZONE)
    e9:SetValue(s.atkval)
    c:RegisterEffect(e9)
end

-- Unaffected by Spell effects (except Equip Spells)
function s.immval(e,te)
    return te:IsActiveType(TYPE_SPELL) and not te:GetHandler():IsType(TYPE_EQUIP)
end
-- Cannot be targeted for attacks if equipped with Equip Spell
function s.atkcon(e)
    local c=e:GetHandler()
    local eqg=c:GetEquipGroup()
    return eqg and eqg:GetCount()>0
end
-- Equip an Equip Spell from GY
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToChangeControler()
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local mc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if mc then
            if Duel.Equip(tp,tc,mc) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_EQUIP_LIMIT)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                e1:SetValue(s.eqlimit)
                tc:RegisterEffect(e1)
            end
        end
    end
end
function s.eqlimit(e,c)
    return c==e:GetOwner()
end
-- Add 1 FIRE Warrior Monster from Deck to hand if this card is attacked during the Battle Phase
function s.battlesendcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackAnnouncedCount()~=0
end
function s.battlesendtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.battlesendop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
        if g:GetCount()>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end
-- Add 2 FIRE Warrior Monsters to hand if this monster destroys an opponent's monster in battle
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,2,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
-- Gain ATK for each Equip Spell
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_EQUIP)*300
end
-- Filter for FIRE Warrior Monsters
function s.filter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- Filter for FIRE Warrior Monsters for effect (6)
function s.thfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
