--Necro-Dancer Cat
--Scripted By Konstak.
--Effect:
-- 2 monsters with different names, except tokens.
-- (1) You can target 1 face-up monster this card points to; equip that face-up monster to this card (max 1).
-- (2) This card gains ATK equal to half the equipped monster's ATK.
-- (3) While this card is equipped by a monster; your opponent cannot target this card for an attack.
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.NOT(aux.FilterBoolFunctionEx(Card.IsType,TYPE_TOKEN)),2,2,s.lcheck)
    --equip
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.eqcon)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)
    aux.AddEREquipLimit(c,s.eqcon,function(ec,_,tp) return ec:IsControler(tp,1-tp) end,s.equipop,e1)
    --atk/def
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetCondition(s.adcon)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    --cannot be battle target
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e3:SetCondition(s.con)
    e3:SetValue(aux.imval1)
    c:RegisterEffect(e3)
end
--lcheck
function s.lcheck(g,lc,sumtype,tp)
    return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end
--Equip
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetHandler():GetEquipGroup():Filter(s.eqfilter,nil)
    return #g==0
end
function s.eqfilter(c)
    return c:GetFlagEffect(id)~=0 
end
function s.eqfilter2(c,e,tp,lg)
    return c:IsFaceup() and (c:IsControler(tp) or c:IsAbleToChangeControler()) and lg:IsContains(c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local lg=e:GetHandler():GetLinkedGroup()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter2(chkc,e,tp,lg) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,lg) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,s.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,lg)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
    c:EquipByEffectAndLimitRegister(e,tp,tc,id)  
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsFacedown() then return end 
    if tc and tc:IsRelateToEffect(e) and tc:IsMonster() and s.eqcon(e,tp,eg,ep,ev,re,r,rp) then
		s.equipop(c,e,tp,tc)
	end
end
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetEquipGroup():Filter(s.eqfilter,nil)
    return #g>0
end
function s.atkval(e,c)
    local c=e:GetHandler()
    local g=c:GetEquipGroup():Filter(s.eqfilter,nil)
    local atk=g:GetFirst():GetTextAttack()
    if g:GetFirst():GetOriginalType()&TYPE_MONSTER==0 or atk<0 then
        return 0
    else
        return atk/2
    end
end
function s.con(e)
    return e:GetHandler():GetEquipCount()>0
end