--覇王の逆鱗
--Supreme King's Wrath
--Scripted by Eerie Code
function c84869738.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c84869738.target)
	e1:SetOperation(c84869738.activate)
	c:RegisterEffect(e1)
	--material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c84869738.matcost)
	e2:SetTarget(c84869738.mattg)
	e2:SetOperation(c84869738.matop)
	c:RegisterEffect(e2)
end
function c84869738.cfilter(c)
	return c:IsFaceup() and c:IsCode(13331639)
end
function c84869738.desfilter(c)
	return not c84869738.cfilter(c)
end
function c84869738.spfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c84869738.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c84869738.desfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(c84869738.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(c84869738.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
function c84869738.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(c84869738.desfilter,tp,LOCATION_MZONE,0,nil)
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c84869738.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
	local lc=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=4
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	if sg:GetCount()==0 or lc==0 then return end
	local exlc=lc
	if Duel.IsPlayerAffectedByEffect(tp,29724053) then
		exlc=math.min(exlc,c29724053[tp])
	end
	if exlc<=0 then
		sg:Remove(Card.IsLocation,nil,LOCATION_EXTRA)
	end
	local sel=Group.CreateGroup()
	local exsel=Group.CreateGroup()
	repeat
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local s1=sg:Select(tp,1,1,nil):GetFirst()
		sg:Remove(Card.IsCode,nil,s1:GetCode())
		if s1:IsLocation(LOCATION_EXTRA) then
			exsel:AddCard(s1)
			exlc=exlc-1
			if exlc==0 then
				sg:Remove(Card.IsLocation,nil,LOCATION_EXTRA)
			end
		else sel:AddCard(s1) end
		ct=ct-1
		lc=lc-1
	until ct==0 or sg:GetCount()==0 or lc==0 or not Duel.SelectYesNo(tp,aux.Stringid(84869738,0))
	local tc=exsel:GetFirst()
	while tc do
		Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
		tc=exsel:GetNext()
	end
	tc=sel:GetFirst()
	while tc do
		Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
		tc=sel:GetNext()
	end
	Duel.SpecialSummonComplete()
end
function c84869738.matcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c84869738.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x20f8) and c:IsType(TYPE_XYZ)
end
function c84869738.matfilter(c)
	return c:IsSetCard(0x20f8) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c84869738.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c84869738.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c84869738.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c84869738.matfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c84869738.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c84869738.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,c84869738.matfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,2,2,nil)
		if g:GetCount()>0 then
			Duel.Overlay(tc,g)
		end
	end
end
