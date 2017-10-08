--ティンダングル・アポストル
--Tindangle Apostle
--Script by nekrozar
function c101003012.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(101003012,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,101003012)
	e1:SetTarget(c101003012.target)
	e1:SetOperation(c101003012.operation)
	c:RegisterEffect(e1)
end
function c101003012.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function c101003012.thfilter(c)
	return c:IsSetCard(0x20b) and c:IsAbleToHand()
end
function c101003012.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,3,nil)
	if g:GetCount()>0 then
		local ct=Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
		if ct==g:GetCount() and g:IsExists(Card.IsSetCard,ct,nil,0x20b) then
			local sg=Duel.GetMatchingGroup(c101003012.thfilter,tp,LOCATION_DECK,0,nil)
			if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(101003012,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local tg=sg:Select(tp,1,ct,nil)
				Duel.SendtoHand(tg,tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end
