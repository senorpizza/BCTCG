--Type-O4R Annihilate
--Scripted by Konstak
--Effects:
local s,id=GetID()
function s.initial_effect(c)
    --Can only control one
    c:SetUniqueOnField(1,0,id)
    --fusion material
    c:EnableReviveLimit()
    Fusion.AddProcMixRep(c,true,true,s.fil,1,1)
    Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
    --cannot be fusion material (1)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    --Cannot be returned (3)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_TO_HAND)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --Cannot banish
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_REMOVE)
    c:RegisterEffect(e3)
    --Can banish zombie monsters
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BATTLE_START)
    e4:SetTarget(s.bntg)
    e4:SetOperation(s.bnop)
    c:RegisterEffect(e4)
end
--Special Summon Functions
function s.fil(c,fc,sumtype,tp,sub,mg,sg,contact)
	if contact then sumtype=0 end
	return c:IsType(ATTRIBUTE_EARTH,fc,sumtype,tp) and c:IsFaceup() and c:IsCode(210660355) and c:IsRace(RACE_MACHINE,fc,sumtype,tp) and (not contact or c:IsType(TYPE_MONSTER,fc,sumtype,tp))
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil,tp)
end
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and (c:IsControler(tp) or c:IsFaceup())
end
function s.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
--Banish Zombies function
function s.bntg(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    if chk==0 then return bc and bc:IsFaceup() and bc:IsRace(RACE_ZOMBIE) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc:IsRelateToBattle() then
    Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
    end
end