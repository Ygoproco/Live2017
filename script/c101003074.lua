--ゴーストリック・リフォーム
--Ghostrick Reform
--Script by nekrozar
function c101003074.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c101003074.target)
	e1:SetOperation(c101003074.activate)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(101003074,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,101003074)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c101003074.sptg)
	e2:SetOperation(c101003074.spop)
	c:RegisterEffect(e2)
end
function c101003074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	if chkc then return false end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0x8d) and tc:IsAbleToHand() and tc:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
function c101003074.actfilter(c,tp)
	return c:IsType(TYPE_FIELD) and c:GetActivateEffect()
		and (c:GetActivateEffect():IsActivatable(tp) or Duel.GetTurnPlayer()~=tp)
end
function c101003074.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		local g=Duel.GetMatchingGroup(c101003074.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,tp)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(101003074,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=sc:GetActivateEffect()
			local tep=sc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			Duel.RaiseEvent(sc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
function c101003074.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x8d)
		and Duel.IsExistingMatchingCard(c101003074.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
end
function c101003074.filter2(c,e,tp,mc,code)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x8d) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function c101003074.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c101003074.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c101003074.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c101003074.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c101003074.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1 then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c101003074.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
