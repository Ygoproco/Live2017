--雷の天気模様
--Thunder Weathery Pattern
--Scripted by Eerie Code
--Prototype, might require a core update for full functionality
function c100419040.initial_effect(c)
	c:SetUniqueOnField(100419040,1,0)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--adjust
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c100419040.effop)
	c:RegisterEffect(e2)
end
function c100419040.efffilter(c,seq,ignore_flag)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsSetCard(0x207)
		and c:GetSequence()<5 and math.abs(c:GetSequence()-seq)<=1 and (ignore_flag or c:GetFlagEffect(100419040)==0)
end
function c100419040.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=c:GetSequence()
	local g=Duel.GetMatchingGroup(c100419040.efffilter,tp,LOCATION_MZONE,0,nil,seq)
	if c:IsDisabled() then return end
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(100419040,RESET_EVENT+0x1fe0000,0,1)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(100419040,0))
		e1:SetCategory(CATEGORY_TOHAND)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetLabelObject(c)
		e1:SetCost(aux.bfgcost)
		e1:SetTarget(c100419040.thtg)
		e1:SetOperation(c100419040.thop)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
function c100419040.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c100419040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local gc=e:GetLabelObject()
	if chk==0 then return gc and gc:IsFaceup() and gc:IsLocation(LOCATION_SZONE)
		and not gc:IsDisabled() and c100419040.efffilter(c,gc:GetSequence(),true)
		and (Duel.GetAttackTarget()==c or (Duel.GetAttacker()==c and Duel.GetAttackTarget()~=nil)) end
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
function c100419040.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc and tc:IsRelateToBattle() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
