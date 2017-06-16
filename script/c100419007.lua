--六武衆の影忍術
--Shadow Art of the Six Samurai
--Scripted by Eerie Code
function c100419007.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,100419007+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c100419007.cost)
	e1:SetTarget(c100419007.target)
	e1:SetOperation(c100419007.activate)
	c:RegisterEffect(e1)
end
function c100419007.costfilter(c)
	return c:IsAbleToGraveAsCost()
end
function c100419007.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100419007.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c100419007.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c100419007.filter(c,e,tp)
	return c:IsSetCard(0x3d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c100419007.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c100419007.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(c100419007.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c100419007.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c100419007.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
