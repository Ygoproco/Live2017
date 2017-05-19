--クラインアント
--Kleinant
--Scripted by Eerie Code
function c100332003.initial_effect(c)
	--increase stats
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c100332003.atkcon)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_CYBERS))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c100332003.reptg)
	e3:SetOperation(c100332003.repop)
	c:RegisterEffect(e3)
end
function c100332003.atkcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)==0
end
function c100332003.repfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_CYBERS) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function c100332003.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(c100332003.repfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c) end
	if Duel.SelectYesNo(tp,aux.Stringid(100332003,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,c100332003.repfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,c)
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function c100332003.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end