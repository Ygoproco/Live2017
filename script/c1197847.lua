--幻煌龍の螺旋波
--Spiral Wave of the Mythic Radiance Dragon
--Script by nekrozar
--fixed by MLD
function c1197847.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL))
	--indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(c1197847.valcon)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1197847,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,1197847)
	e4:SetCondition(c1197847.spcon)
	e4:SetTarget(c1197847.sptg)
	e4:SetOperation(c1197847.spop)
	c:RegisterEffect(e4)
end
function c1197847.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
function c1197847.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetBattledGroupCount()>0
end
function c1197847.spfilter(c,e,tp)
	return c:IsCode(56649609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c1197847.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c1197847.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	end
end
function c1197847.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1197847.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.Equip(tp,c,tc)
			Duel.SpecialSummonComplete()
			if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
				Duel.BreakEffect()
				Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end
